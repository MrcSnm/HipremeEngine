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
/**
*   RefCounted, Array @nogc, OutputRange compatible, it aims to bring the same result as one would have by using
*   int[], Array!int should be equivalent, any different behaviour should be contacted. 
*   It may use more memory than requested for not making reallocation a big bottleneck
*/
pragma(LDC_no_typeinfo)
struct Array(T) 
{
    size_t length;
    T* data;
    private size_t capacity;
    private int* countPtr;
    import core.stdc.stdlib:malloc, calloc;
    import core.stdc.string:memcpy, memset;
    import core.stdc.stdlib:realloc;

    this(this) @nogc
    {
        if(countPtr !is null)
            *countPtr = *countPtr + 1;
    }

    pragma(inline) int opApply(scope int delegate(size_t idx, ref T) dg)
    {
        int result = 0;
        for(int i = 0; i < length; i++)
        {
            result = dg(i, data[i]);
            if(result)
                break;
        }
        return result;
    }

    pragma(inline) int opApply(scope int delegate(ref T) dg)
    {
        int result = 0;
        for(int i = 0; i < length; i++)
        {
            result = dg(data[i]);
            if(result) break;
        }
        return result;
    }
    private void initialize(size_t capacity) @nogc
    {
        this.data = cast(T*)calloc(capacity, T.sizeof);
        this.capacity = capacity;
        this.countPtr = cast(int*)malloc(int.sizeof);
        *this.countPtr = 1;
        this[0..capacity] = T.init;
    }

    static Array!T opCall(size_t capacity = 1) @nogc
    {
        Array!T ret;
        ret.initialize(capacity);
        return ret;
    }

    static Array!T opCall(size_t length, T value) @nogc
    {
        Array!T ret = Array!(T)(length);
        ret.length = length;
        ret[] = value;
        return ret;
    }
    
    static Array!T opCall(scope T[] arr) @nogc
    {
        Array!T ret = Array!(T)(arr.length);
        ret.length = arr.length;
        ret.data[0..ret.length] = arr[];
        return ret;
    }

    void* getRef()
    {
        *countPtr = *countPtr + 1;
        return cast(void*)&this;
    }

    pragma(inline) bool opEquals(R)(const R other) const
    if(is(R == typeof(null)))
    {
        return data == null;
    }
    void dispose() @nogc
    {
        import core.stdc.stdlib:free;
        free(data);
        free(countPtr);
    }
    immutable(T*) ptr(){return cast(immutable(T*))data;}
    size_t opDollar() @nogc {return length;}

    T[] opSlice() @nogc
    {
        return data[0..length];
    }

    T[] opSlice(size_t start, size_t end) @nogc
    {
        return data[start..end];
    }
    auto ref opSliceAssign(T)(T value) @nogc
    {
        data[0..length] = value;
        return this;
    }
    auto ref opSliceAssign(T)(T value, size_t start, size_t end) @nogc
    {
        data[start..end] = value;
        return this;
    }
    import hip.util.reflection:isArray;
    auto ref opAssign(Q)(Q value) @nogc
    if(isArray!Q)
    {
        if(data == null)
            data = cast(T*)malloc(T.sizeof*value.length);
        else
            data = cast(T*)realloc(data, T.sizeof*value.length);
        length = value.length;
        capacity = value.length;
        memcpy(data, value.ptr, T.sizeof*value.length);
        return this;
    }

    ref auto opIndex(size_t index) @nogc
    {
        assert(index>= 0 && index < length, "Array out of bounds");
        return data[index];
    }

    pragma(inline) private void resize(uint newSize) @nogc
    {
        if(data == null || capacity == 0)
            initialize(newSize);
        else
        {
            data = cast(T*)realloc(data, newSize*T.sizeof);
            capacity = newSize;
        }
    }
    ///Guarantee that no allocation will occur for the specified reserve amount of memory
    void reserve(size_t newSize){if(newSize > capacity)resize(cast(uint)newSize);}
    auto ref opOpAssign(string op, Q)(Q value) @nogc if(op == "~")
    {
        if(*countPtr != 1)
        {
            //Save old data
            T* oldData = data;
            //Remove from the ref counter
            *countPtr = *countPtr - 1;
            //Re initialize
            initialize(length);
            memcpy(data, oldData, T.sizeof*length);
        }
        static if(is(Q == T))
        {
            if(data == null)
                initialize(1);
            if(length + 1 >= capacity)
                resize(cast(uint)((length+1)*1.5));
            data[length++] = value;
        }
        else static if(is(Q == T[]) || is(Q == Array!T))
        {
            if(data == null)
                initialize(value.length);
            if(length + value.length >= capacity)
                resize(cast(uint)((length+value.length)*1.5));
            memcpy(data+length, value.ptr, T.sizeof*value.length);
            length+= value.length;    
        }
        return this;
    }

    // String asString() @nogc
    // {
    //     return String(this[0..$]);
    // }
    void put(T data) @nogc {this~= data;}
    ~this() @nogc
    {
        if(countPtr != null)
        {
            *countPtr = *countPtr - 1;
            assert(*countPtr >= 0);
            if(*countPtr == 0)
                dispose();
            data = null;
            countPtr = null;
            length = 0;
        }
    }
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
    private T* data;
    import core.stdc.stdlib;

    private int* countPtr;

    this(this){*countPtr = *countPtr + 1;}
    this(uint lengthHeight, uint lengthWidth)
    {
        data = cast(T*)malloc((lengthHeight*lengthWidth)*T.sizeof);
        countPtr = cast(int*)malloc(int.sizeof);
        *countPtr = 0;
        height = lengthHeight;
        width = lengthWidth;
    }
    ~this()
    {
        if(countPtr == null)
            return;
        *countPtr = *countPtr - 1;
        if(*countPtr <= 0)
        {
            free(data);
            free(countPtr);
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

private uint hash_fnv1(T)(T value)
{
    import hip.util.reflection:isArray, isPointer;
    enum fnv_offset_basis = 0x811c9dc5;
    enum fnv_prime = 0x01000193;

    byte[] data;
    static if(isArray!T)
        data = (cast(byte*)value.ptr)[0..value.length*T.sizeof];
    else static if(is(T == interface) || is(T == class) || isPointer!T)
        data = cast(byte[])(cast(void*)value)[0..(void*).sizeof];
    else //Value types: int, float, struct, etc
        data = (cast(byte*)&value)[0..T.sizeof];

    typeof(return) hash = fnv_offset_basis;

    foreach(byteFromData; data)
    {
        hash*= fnv_prime;
        hash^= byteFromData;
    }
    return hash;
}

struct Map(K, V)
{
    import core.stdc.stdlib;
    static enum initializationLength = 128;
    private static enum increasingFactor = 1.5;
    private static enum increasingThreshold = 0.7;
    private alias hashFunc = hash_fnv1;

    private struct MapData
    {
        K key;
        V value;
    }
    private struct MapBucket
    {
        MapData data;
        MapBucket* next;
    }
    private Array!MapBucket dataSet;

    private int* countPtr;

    this(this)
    {
        if(countPtr !is null)
            *countPtr = *countPtr + 1;
    }

    private int entriesCount;

    private void initialize() @nogc
    {
        dataSet = Array!(MapBucket)(initializationLength);
        dataSet.length = initializationLength;
        dataSet[] = MapBucket.init;
        countPtr = cast(int*)malloc(int.sizeof);
        *countPtr = 0;
    }
    static auto opCall() @nogc
    {
        Map!(K, V) ret;
        ret.initialize();
        return ret;
    }



    void clear() @nogc 
    {
        entriesCount = 0;
        for(int i = 0; i < dataSet.length; i++)
        {
            if(dataSet[i] != MapBucket.init)
            {
                MapBucket* buck = dataSet[i].next;
                while(buck != null)
                {
                    MapBucket copy = *buck;
                    free(buck);
                    buck = copy.next;
                }
            }
        }
    }
    //Called when array is filled at least increasingThreshold
    private void recalculateHashes() @nogc
    {
        size_t newSize = cast(size_t)(dataSet.capacity * increasingFactor);
        Array!MapBucket newArray = Array!MapBucket(newSize);

        for(int i = 0; i < dataSet.length; i++)
        {
            if(dataSet[i] != MapBucket.init)
            {
                newArray[hashFunc(dataSet[i].data.key) % newSize] = dataSet[i];
            }
        }

        dataSet = newArray;
    }
    
    bool has(K key) @nogc {return dataSet[getIndex(key)] != MapBucket.init;}
    pragma(inline) uint getIndex(K key) @nogc {return hashFunc(key) % dataSet.length;}


    ref auto opIndex(K index) @nogc
    {
        if(dataSet.length == 0)
            initialize();
        return dataSet[getIndex(index)].data.value;
    }
    ref auto opIndexAssign(V value, K key) @nogc
    {
        if(dataSet.length == 0)
            initialize();
        uint i = getIndex(key);
        //Unexisting bucket
        if(dataSet[i] == MapBucket.init)
        {
            entriesCount++;
            dataSet[i] = MapBucket(MapData(key, value), null);
            if(entriesCount > dataSet.length * increasingThreshold)
                recalculateHashes();
        }
        else //Existing bucket
        {
            MapBucket* curr = &dataSet[i];
            do
            {
                //Check if the key is the same as the other.
                if(curr.data.key == key)
                {
                    curr.data.value = value;
                    return this;
                }
                else if(curr.next != null)
                    curr = curr.next;
            }
            while(curr.next != null);
            curr.next = cast(MapBucket*)malloc(MapBucket.sizeof);
            *curr.next = MapBucket(MapData(key, value), null);

        }
        return this;
    }

    auto opBinaryRight(string op, L)(const L lhs) const @nogc
    if(op == "in")
    {
        if(dataSet.length == 0)
            initialize();
        uint i = getIndex(key);
        if(dataSet[i] == MapBucket.init)
            return null;
        return &dataSet[i];
    }

    ~this() @nogc
    {
        if(countPtr !is null)
        {
            *countPtr = *countPtr - 1;
            if(*countPtr == 0)
            {
                //Dispose
                clear();
                free(countPtr);
            }
            countPtr = null;
        }
    }

}
alias AArray = Map;


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
        foreach(child; children)
        {
            if(cb(child) || child.opApply(cb))
                return 1;
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