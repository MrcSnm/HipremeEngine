/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module util.data_structures;

struct Pair(A, B)
{
    A first;
    B second;

    alias a = first;
    alias b = second;
}
/** 
 * RangeMap allows specifying a range in which a value spams, quite useful for defining outcomes
 *  based on an input, experience gain progression, etc. Example Usage:
 *  ```d
 *  RangeMap!(int, string) colorRanges;
 *  colorRanges.setDefault("White");
 *  colorRanges[0..9] = "Red";
 *  colorRanges[10..19] = "Green";
 *  colorRanges[20..29] = "Blue"
 *  
 *  writeln(colorRanges[5]); //Prints "Red"
 *  ```
 */
struct RangeMap(K, V)
{
    import std.traits:isNumeric;
    static assert(isNumeric!K, "RangeMap key must be a numeric type");
    K[] ranges;
    V[] values;
    V _default;

    /**
    *   When the value is out of range, the value returned is the _default one.
    */
    RangeMap setDefault(V _default)
    {
        this._default = _default;
        return this;
    }
    /** 
     * Alternative to the slice syntax
     */
    RangeMap setRange(K a, K b, V value)
    {
        int rLength = cast(int)ranges.length;
        ranges.reserve(ranges.length+2);
        if(a > b)
        {
            K temp = a;
            a = b;
            b = temp;
        }
        if(rLength != 0 && ranges[rLength-1] > a) //Silently ignore for now
            return this;
        ranges~=a;
        ranges~=b;
        values~=value;
        return this;
    }

    /**
    *   Uses binary search for finding the value range.
    */
    V get(K value)
    {
        int l = 0;
        int length = cast(int)ranges.length;
        int r = length-1;

        while(l < r)
        {
            int m = cast(int)((l+r)/2);
            if(m % 2 != 0)
                m--;
            K k = ranges[m];
            //Check if value is between a[m] and a[m-1]
            if(m+1 < length && value >= k && value <= ranges[m+1])
                return values[cast(int)(m/2)];
            else if(k < value)
                l = m + 1;
            else if(m > value)
                r = m - 1;
            //Check if both values on the right is greater than value
            else if(m+1 < length && k > value && ranges[m+1] > value)
                break;
        }
        return _default;
    }

    pragma(inline) V opSliceAssign(V value, K start, K end)
    {
        setRange(start, end, value);
        return value;
    }
    pragma(inline) V opIndex(K index){return get(index);}
}
public import util.string: String;
/**
*   RefCounted, Array @nogc, OutputRange compatible, it aims to bring the same result as one would have by using
*   int[], Array!int should be equivalent, any different behaviour should be contacted. 
*/
struct Array(T) 
{
    size_t length;
    T* data;
    private int* countPtr;
    import core.stdc.stdlib:malloc;
    import core.stdc.string:memcpy, memset;
    import core.stdc.stdlib:realloc;

    this(this) @nogc
    {
        *countPtr = *countPtr + 1;
    }
    alias _opApplyFn = int delegate(ref T) @nogc;
    int opApply(scope _opApplyFn dg) @nogc
    {
        int result = 0;
        for(int i = 0; i < length && result; i++)
            result = dg(data[i]);
        return result;
    }

    static Array!T opCall(size_t length = 0) @nogc
    {
        Array!T ret;
        ret.length = length;
        ret.countPtr = cast(int*)malloc(int.sizeof);
        *ret.countPtr = 1;
        ret.data = cast(T*)malloc(T.sizeof*length);
        return ret;
    }
    static Array!T opCall(in T[] arr) @nogc
    {
        Array!T ret = Array!(T)(arr.length);
        memcpy(ret.data, arr.ptr, ret.length*T.sizeof);
        return ret;
    }
    static Array!T opCall(T[] arr...) @nogc
    {
        Array!T ret = Array!(T)(arr.length);
        memcpy(ret.data, arr.ptr, ret.length*T.sizeof);
        return ret;
    }
    void dispose() @nogc
    {
        import core.stdc.stdlib:free;
        if(data != null)
        {
            free(data);
            data = null;
            free(countPtr);
            countPtr = null;
            length = 0;
        }
    }
    size_t opDollar() @nogc {return length;}
    T[] opSlice(size_t start, size_t end) @nogc
    {
        return data[start..end];
    }
    auto opSliceAssign(T)(T value, size_t start, size_t end) @nogc
    {
        data[start..end] = value;
        return this;
    }
    auto ref opAssign(Q)(Q value) @nogc
    {
        if(data == null)
            data = cast(T*)malloc(T.sizeof*value.length);
        else
            data = cast(T*)realloc(data, T.sizeof*value.length);
        length = value.length;
        memcpy(data, value.ptr, T.sizeof*value.length);
        return this;
    }

    ref auto opIndex(size_t index) @nogc
    {
        assert(index < length, "Array out of bounds");
        return data[index];
    }
    auto opOpAssign(string op, Q)(Q value) @nogc if(op == "~")
    {
        static if(is(Q == T))
        {
            data = cast(T*)realloc(data, (length+1)*T.sizeof);
            data[length++] = value;
        }
        else static if(is(Q == T[]) || is(Q == Array!T))
        {
            data = cast(T*)realloc(data, (length+values.length)*T.sizeof);
            memcpy(data+length, values.ptr, T.sizeof*values.length);
            length+= values.length;    
        }
        return this;
    }

    String toString() @nogc
    {
        return String(this[0..$]);
    }
    void put(T data) @nogc {this~= data;}
    ~this() @nogc
    {
        *countPtr = *countPtr - 1;
        if(*countPtr <= 0)
            dispose();
    }

}

/**
*   By using Array2D instead of T[][], only one array instance is created, not "n" arrays. So it is a lot
*   faster when you use that instead of array of arrays.
*   
*   Its main usage is for avoiding a[i][j] static array, and not needing to deal with array of arrays.
*/
struct Array2D(T)
{
    private T[] data;
    private uint height;
    private uint width;

    this(uint lengthHeight, uint lengthWidth)
    {
        data = new T[](lengthHeight*lengthWidth);
        height = lengthHeight;
        width = lengthWidth;
    }
    pragma(inline, true)
    {
        ref auto opIndex(size_t i,  size_t j){return data[i*width+j];}
        ref auto opIndex(size_t i)
        {
            ulong temp = i*width;
            return data[temp..temp+width];
        }
        auto opIndexAssign(T)(T value, size_t i, size_t j){return data[i*width+j] = value;}
    }
}

struct RingBuffer(T, uint Length)
{
    import core.stdc.stdlib:malloc, free;
    import util.concurrency:Volatile;

    T[Length] data;
    private Volatile!uint writeCursor;
    private Volatile!uint readCursor;

    this()
    {
        this.writeCursor = 0;
        this.readCursor = 0;
    }

    void push(T data)
    {
        this.data[writeCursor] = data;
        writeCursor = (writeCursor+1) % Length;
    }
    ///It may read less than count if it is out of bounds
    immutable T[] read(uint count)
    {
        uint temp = readCursor;
        if(temp + count > Length)
        {
            readCursor = 0;
            return data[temp..Length];
        }
        readCursor = (temp+count)%Length;
        return data[temp .. count];
    }

    immutable T read()
    {
        uint temp = readCursor;
        immutable T ret = data[temp];
        readCursor = (temp+1)%Length;
        return ret;
    }

    void dispose()
    {
        data = null;
        length = 0;
        writeCursor = 0;
        readCursor = 0;
    }

    ~this()
    {
        dispose();
    }
}

/**
*   High efficient(at least memory-wise), tightly packed Input queue that supports any kind of data in
*   a single allocated memory pool(no fragmentation).
*
*   This class could probably be extendeded to be every event handler
*/
class EventQueue
{
    import util.memory;
    
    struct Event
    {
        ubyte type;
        ubyte evSize;
        void[0] evData;
    }

    ///Linearly allocated variable length Events
    void* eventQueue;
    ///BytesOffset should never be greater than capacity
    uint bytesCapacity;
    uint bytesOffset;
    protected uint pollCursor;

    protected this(uint capacity)
    {
        ///Uses capacity*greatest structure size
        bytesCapacity = cast(uint)capacity;
        bytesOffset = 0;
        eventQueue = malloc(bytesCapacity);
    }


    void post(T)(ubyte type, T ev)
    {
        assert(bytesOffset+T.sizeof+Event.sizeof < bytesCapacity, "InputQueue Out of bounds");
        if(pollCursor == bytesOffset) //It will restart if everything was polled
        {
            pollCursor = 0;
            bytesOffset = 0;
        }
        else if(pollCursor != 0) //It will copy everything from the right to the start
        {
            memcpy(eventQueue, eventQueue+pollCursor, bytesOffset-pollCursor);
            //Compensates the offset into the cursor.
            bytesOffset-= pollCursor;
            //Restarts the poll cursor, as everything from the right moved to left
            pollCursor = 0;
        }
        Event temp;
        temp.type = type;
        temp.evSize = T.sizeof;
        memcpy(eventQueue+bytesOffset, &temp, Event.sizeof);
        memcpy(eventQueue+bytesOffset+Event.sizeof, &ev, T.sizeof);
        bytesOffset+= T.sizeof+Event.sizeof;
    }

    void clear()
    {
        //By setting it equal, no one will be able to poll it
        pollCursor = bytesOffset;
    }

    Event* poll()
    {
        if(bytesOffset - pollCursor <= 0)
            return null;
        Event* ev = cast(Event*)(eventQueue+pollCursor);
        pollCursor+= ev.evSize+Event.sizeof;
        return ev;
    }

    protected ~this()
    {
        free(eventQueue);
        eventQueue = null;
        pollCursor = 0;
        bytesCapacity = 0;
        bytesOffset = 0;
    }
}

struct Signal(A...)
{
    void function(A)[] listeners;
    void dispatch(A a)
    {
        foreach (void function(A) l; listeners)
            l(a);
    }
}