/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.data_structures;
public import hip.util.allocator;
public import hip.util.rc.array;
public import hip.util.rc.map;

public import hip.util.string: String;
struct Pair(A, B, string aliasA = "", string aliasB = "")
{

    A first;
    B second;

    alias a = first;
    alias b = second;

    static if(aliasA != "")
        mixin("alias "~aliasA~" = first;");
    static if(aliasB != "")
        mixin("alias "~aliasB~" = second;");
}
struct Dirty(T)
{
    T value;
    private bool isDirty;

    auto opAssign(T value)
    {
        if(value != this.value) this.value = value, isDirty = true;
        return this;
    }
    void clearDirtyFlag(){isDirty = false;}
}

mixin template DirtyFlagFields(string flagName, T, string[] fields)
{
    static foreach(f; fields)
    {
        mixin("T _",f,";",
        "T ",f,"() => _",f,";",
        "T ",f,"(T v){if(_",f," != v) ",flagName," = true; return _",f," = v;}");
    }
}

struct Tuple(Fields...)
{
    Fields fields;
    alias fields this;
    pragma(inline, true) size_t length(){ return Fields.length; }
}
auto tuple(Args...)(Args a){ return Tuple!(Args)(a); }

pragma(LDC_no_typeinfo)
struct DirtyFlagsCmp(alias flag, Fields...)
{
    import std.typecons;
    static if(is(__traits(parent, Fields[0]) == struct))
    	private static alias P = __traits(parent, Fields[0])*;
   	else
    	private static alias P = __traits(parent, Fields[0]);
	P parent;
    Tuple!(typeof(Fields)) base;

    this(P parent)
    {
        start(parent);
    }

    void start(P parent)
    {
        this.parent = parent;
        static foreach (i, f; Fields)
            base[i] = __traits(child, parent, f);
    }

    void update()
    {
        bool changed;
        static foreach (i, f; Fields)
        {
            {
                alias T = typeof(f);
                changed = changed || (__traits(child, parent, f) !is base[i]);
            }
        }
        __traits(child, parent, flag) = __traits(child, parent, flag) || changed;
    }
    alias opCall = update;
}

template DelayedBindable(T, bool needsUnbind, bool bindReplacesUnbind, int slots = 1, alias bindFn = null, alias unbindFn = null)
{
    import hip.util.reflection:isReference;


    __gshared T[slots] bound;

    static if(bindFn !is null)
        alias actualBind = bindFn;
    else
    {
        static if(slots != 1)
            alias actualBind = (T d, int slot){d.bind(slot);};
        else
            alias actualBind = (T d){d.bind();};
    }

    static if(unbindFn !is null)
        alias actualUnbind = unbindFn;
    else
    {
        static if(slots != 1)
            alias actualUnbind = (T d, int slot){d.unbind(slot);};
        else
            alias actualUnbind = (T d){d.unbind();};
    }
    
    void bind(T data, int slot = 0)
    {
        bool changed;
        static if (!isReference!T)
            changed = bound[slot] != data;
        else
            changed = bound[slot] !is data;
        if(changed)
        {
            static if(needsUnbind)
                unbind(bound[slot], slot);
            static if(slots == 1)
                actualBind(data);
            else
                actualBind(data, slot);
            bound[slot] = data;
        }
    }

    void unbind(T data, int slot = 0) 
    {
        static if(!bindReplacesUnbind || needsUnbind)
        {
            bool isSame;
            static if(!isReference!T)
                isSame = bound[slot] == data && bound[slot] != T.init;
            else
                isSame = bound[slot] is data && bound[slot] !is null;
            if(isSame)
            {
                static if(slots == 1)
                    actualUnbind(data);
                else
                    actualUnbind(data, slot);
                bound[slot] = T.init;
            }
        }
    }
}

/** 
 * RangeMap allows specifying a range in which a value spams, quite useful for defining outcomes
 *  based on an input, experience gain progression, etc. Example Usage:
 *  ```d
 *  RangeMap!(int, string) colorRanges = "White"; //Default is "White"
 *  colorRanges[0..9] = "Red";
 *  colorRanges[10..19] = "Green";
 *  colorRanges[20..29] = "Blue"
 *  
 *  writeln(colorRanges[5]); //Prints "Red"
 *  ```
 */
struct RangeMap(K, V)
{
    import hip.util.reflection:isNumeric;
    @nogc:
    static assert(isNumeric!K, "RangeMap key must be a numeric type");
    protected Array!K ranges;
    protected Array!V values;
    protected V _default;

    /**
    *   When the value is out of range, the value returned is the _default one.
    */
    ref RangeMap setDefault(V _default)
    {
        this._default = _default;
        return this;
    }
    /** 
     * Alternative to the slice syntax
     */
    ref RangeMap setRange(K a, K b, V value)
    {
        if(ranges == null)
        {
            ranges = Array!K(8);
            values = Array!V(8);
        }
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

    pragma(inline) auto ref opAssign(V value)
    {
        setDefault(value);
        return this;
    }
    pragma(inline) V opSliceAssign(V value, K start, K end)
    {
        setRange(start, end, value);
        return value;
    }
    pragma(inline) V opIndex(K index){return get(index);}
}

private mixin template Array2DMixin(T)
{
    int opApply(scope int delegate(ref T) dg)
    {
        int result = 0;
        for(int i = 0; i < width*height; i++)
        {
            result = dg(data[i]);
            if (result)
                break;
        }
        return result;
    }

    private uint height;
    private uint width;
    @nogc int getWidth() const {return width;}
    @nogc int getHeight() const {return height;}
    @nogc T[] opSlice(size_t start, size_t end)
    {
        if(end < start)
        {
            size_t temp = end;
            end = start; end = temp;
        }
        if(end > width*height)
            end = width*height;
        return data[start..end];
    }
    pragma(inline, true)
    {
        @nogc ref auto opIndex(size_t i,  size_t j){return data[i*width+j];}
        @nogc ref auto opIndex(size_t i)
        {
            size_t temp = i*width;
            return data[temp..temp+width];
        }
        @nogc auto opIndexAssign(T)(T value, size_t i, size_t j){return data[i*width+j] = value;}
        @nogc size_t opDollar() const {return width*height;}
        @nogc bool opCast() const{return data !is null;}
    }
}

/**
*   By using Array2D instead of T[][], only one array instance is created, not "n" arrays. So it is a lot
*   faster when you use that instead of array of arrays.
*   
*   Its main usage is for avoiding a[i][j] static array, and not needing to deal with array of arrays.
*/
pragma(LDC_no_typeinfo)
struct Array2D(T)
{

    mixin Array2DMixin!T;
    Array2D_GC!T toGC()
    {
        Array2D_GC!T ret = new Array2D_GC!T(width, height);
        ret.data[0..width*height] = data[0..width*height];
        destroy(this);

        return ret;
    }
    @nogc:
    private T[] data;
    private Allocator* allocator;
    import core.stdc.stdlib;

    private int[] countPtr;

    this(this){countPtr[0]++;}
    this(uint lengthHeight, uint lengthWidth, Allocator* allocator = mallocAllocator.ptr)
    {
        this.allocator = allocator;
        data = cast(T[])allocator.alloc((lengthHeight*lengthWidth)*T.sizeof);
        countPtr = cast(int[])allocator.alloc(int.sizeof);
        countPtr[0] = 0;
        height = lengthHeight;
        width = lengthWidth;
    }
    ~this()
    {
        if(countPtr == null)
            return;
        countPtr[0]--;
        if(countPtr[0] <= 0)
        {
            allocator.free(data);
            allocator.free(countPtr);
            data = null;
            countPtr = null;
            width = height = 0;
        }
    }
    

}

class Array2D_GC(T)
{
    private T[] data;
    this(uint lengthHeight, uint lengthWidth)
    {
        data = new T[](lengthHeight*lengthWidth);
        width = lengthWidth;
        height = lengthHeight;
    }
    mixin Array2DMixin!T;
}

/**
*   High efficient(at least memory-wise), tightly packed Input queue that supports any kind of data in
*   a single allocated memory pool(no fragmentation).
*
*   This class could probably be extendeded to be every event handler
*/
class EventQueue
{
    import hip.util.memory;
    @nogc:
    
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

class Node(T)
{
    T data;
    Node!(T)[] children;
    Node!T parent;

    this(T data){this.data = data;}

    pragma(inline) bool isRoot() const @nogc nothrow {return parent is null;}
    pragma(inline) bool hasChildren() const @nogc nothrow {return children.length != 0;}
    Node!T get(T data)
    {
        foreach(node; this)
        {
            if(node.data == data)
                return node;
        }
        return null;
    }
    pragma(inline) Node!T addChild(T data)
    {
        Node!T ret = new Node(data);
        ret.parent = this;
        children~= ret;
        return ret;
    }

    Node!T getRoot()
    {
        Node!T ret = this;
        while(ret.parent !is null)
            ret = ret.parent;
        return ret;
    }
    
    int opApply(scope int delegate(Node!T) cb)
    {
        int ret = cb(this);
        if(ret)
            return ret;
        foreach(child; children)
        {
            ret = child.opApply(cb);
            if(ret)
                return ret;
        }
        return 0;
    }
}


struct Signal(A...)
{
    Array!(void function(A)) listeners;
    void dispatch(A a)
    {
        foreach (void function(A) l; listeners)
            l(a);
    }
}

/**
* Basically same code from std.array.staticArray but no need to import std.
* Use static arrays whenever needing to "fire-and-forget" small arrays
*/
T[N] staticArray(T, size_t N)(auto ref T[N] arr){return arr;}