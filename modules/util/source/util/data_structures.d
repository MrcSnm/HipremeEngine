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

struct Array(T)
{
    ulong length;
    T* data;

    static Array!T create(ulong length = 0)
    {
        import core.stdc.stdlib:malloc;
        Array!T ret;
        ret.length = length;
        ret.data = cast(T*)malloc(T.sizeof*length);
        return ret;
    }
    static Array!T fromDynamicArray(T[] arr)
    {
        import core.stdc.string:memcpy;
        Array!T ret = Array!(T).create(arr.length);
        memcpy(ret.data, arr.ptr, ret.length*T.sizeof);
        return ret;
    }
    void dispose()
    {
        import core.stdc.stdlib:free;
        free(data);
        data = null;
        length = 0;
    }
    ulong opDollar(){return length;}
    auto opSliceAssign(T)(T value, size_t start, size_t end)
    {
        for(int i = start; i < end; i++)data[i]=value;
        return this;
    }

    ref auto opIndex(size_t index)
    {
        assert(index < length, "Array out of bounds");
        return data[index];
    }
    auto opOpAssign(string op, T)(T value)
    {
        static assert(op == "~", "Operator not supported on Array");
        import core.stdc.stdlib:realloc;
        data = cast(T*)realloc(data, (length+1)*T.sizeof);
        data[length++] = value;
        return this;
    }

    string toString()
    {
        import util.conv:to;
        string ret="[";
        for(int i = 0; i < length; i++)
        {
            if(i != 0)
                ret~=", ";
            ret~=to!string(data[i]);
        }
        return ret~']';
    }

}

/**
*   By using Array2D instead of T[][], only one array instance is created, not "i" arrays. So it is a lot
*   faster when you use that instead of array of arrays.
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
    pragma(inline, true):
    ref auto opIndex(size_t i,  size_t j){return data[i*width+j];}
    ref auto opIndex(size_t i)
    {
        ulong temp = i*width;
        return data[temp..temp+width];
    }
    auto opIndexAssign(T)(T value, size_t i, size_t j){return data[i*width+j] = value;}
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

    ~this(){dispose();}
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