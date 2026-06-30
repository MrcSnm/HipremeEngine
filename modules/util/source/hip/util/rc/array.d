module hip.util.rc.array;
public import hip.util.allocator;

/**
*   RefCounted, Array @nogc, OutputRange compatible, it aims to bring the same result as one would have by using
*   int[], Array!int should be equivalent, any different behaviour should be contacted. 
*   It may use more memory than requested for not making reallocation a big bottleneck
*/
pragma(LDC_no_typeinfo)
struct Array(T) 
{
    size_t length;
    size_t capacity;
    private struct DataInfo
    {
        ptrdiff_t refCount;
        T* data(){return cast(T*)(&this+1); }
    }
    DataInfo* info;
    private Allocator* allocator;
    import core.stdc.string:memcpy, memset;

    this(this) @nogc
    {
        retain();
    }

    void opAssign(typeof(this) other)
    {
        other.retain();
        release();
        this.length = other.length;
        this.info = other.info;
        this.capacity = other.capacity;
        this.allocator = other.allocator;
    }

    pragma(inline) int opApply(scope int delegate(size_t idx, ref T) dg)
    {
        int result = 0;
        for(int i = 0; i < length; i++)
        {
            result = dg(i, info.data[i]);
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
            result = dg(info.data[i]);
            if(result) break;
        }
        return result;
    }
    private void initialize(size_t capacity, Allocator* allocator) @nogc
    {
        this.allocator = allocator;
        this.info = cast(DataInfo*)allocator.alloc(capacity*T.sizeof + DataInfo.sizeof).ptr;
        this.info.refCount = 1;
        this[0..capacity] = T.init;
        this.capacity = capacity;
    }

    static Array!T opCall(Allocator* allocator = mallocAllocator.ptr) @nogc
    {
        assert(allocator !is null);
        Array!T ret;
        ret.initialize(1, allocator);
        return ret;
    }


    static Array!T opCall(size_t capacity = 1, Allocator* allocator = mallocAllocator.ptr) @nogc
    {
        assert(allocator !is null);
        Array!T ret;
        ret.initialize(capacity, allocator);
        return ret;
    }

    static Array!T opCall(size_t length, T value, Allocator* allocator = mallocAllocator.ptr) @nogc
    {
        Array!T ret = Array!(T)(length, allocator);
        ret.length = length;
        ret[] = value;
        return ret;
    }
    
    static Array!T opCall(scope T[] arr, Allocator* allocator = mallocAllocator.ptr) @nogc
    {
        Array!T ret = Array!(T)(arr.length, allocator);
        ret.length = arr.length;
        ret.info.data[0..ret.length] = arr[];
        return ret;
    }

    void retain()
    {
        if(info !is null)
            info.refCount++;
    }

    pragma(inline) bool opEquals(R)(const R other) const
    if(is(R == typeof(null)))
    {
        return info is null;
    }
    void dispose() @nogc
    {
        allocator.free((cast(void*)info)[0..capacity*T.sizeof+DataInfo.sizeof]);
    }
    immutable(T*) ptr(){return cast(immutable(T*))info.data;}
    size_t opDollar() @nogc {return length;}

    T[] opSlice() @nogc
    {
        return info.data[0..length];
    }

    T[] opSlice(size_t start, size_t end) @nogc
    {
        return info.data[start..end];
    }
    auto ref opSliceAssign(T)(T value) @nogc
    {
        info.data[0..length] = value;
        return this;
    }
    auto ref opSliceAssign(T)(T value, size_t start, size_t end) @nogc
    {
        info.data[start..end] = value;
        return this;
    }
    import hip.util.reflection:isArray;
    auto ref opAssign(Q)(Q value) @nogc
    if(isArray!Q)
    {
        if(info == null)
            info = cast(DataInfo*)allocator.alloc(T.sizeof*value.length+DataInfo.sizeof);
        else
            info = cast(DataInfo*)allocator.realloc(info, T.sizeof*value.length+DataInfo.sizeof);
        length = value.length;
        capacity = value.length;
        memcpy(info, value.ptr, T.sizeof*value.length);
        return this;
    }

    ref auto opIndex(size_t index) @nogc
    {
        assert(index>= 0 && index < length, "Array out of bounds");
        return info.data[index];
    }

    pragma(inline) private void resize(uint newSize) @nogc
    {
        if(info == null || capacity == 0)
            initialize(newSize, allocator);
        else
        {
            info = cast(DataInfo*)allocator.realloc((cast(void*)info)[0..capacity*T.sizeof+DataInfo.sizeof], newSize*T.sizeof+DataInfo.sizeof).ptr;
            capacity = newSize;
        }
    }
    ///Guarantee that no allocation will occur for the specified reserve amount of memory
    void reserve(size_t newSize){if(newSize > capacity)resize(cast(uint)newSize);}
    auto ref opOpAssign(string op, Q)(Q value) @nogc if(op == "~")
    {
        if(info !is null && info.refCount > 1)
        {
            //Save old data
            T* oldData = info.data;
            //Remove from the ref counter
            info.refCount--;
            //Re initialize
            initialize(length, allocator);
            memcpy(info.data, oldData, T.sizeof*length);
        }
        static if(is(Q == T))
        {
            if(info == null)
                initialize(1, allocator);
            if(length + 1 >= capacity)
                resize(cast(uint)((length+1)*1.5));
            info.data[length++] = value;
        }
        else static if(is(Q == T[]) || is(Q == Array!T))
        {
            if(info == null)
                initialize(value.length, allocator);
            if(length + value.length >= capacity)
                resize(cast(uint)((length+value.length)*1.5));
            memcpy(info.data+length, value.ptr, T.sizeof*value.length);
            length+= value.length;
        }
        return this;
    }

    // String asString() @nogc
    // {
    //     return String(this[0..$]);
    // }
    void put(T data) @nogc {this~= data;}

    private void release()
    {
        if(info !is null)
        {
            assert(--info.refCount >= 0);
            if(info.refCount == 0)
                dispose();
            info = null;
            length = 0;
            capacity = 0;
        }
    }
    ~this() @nogc
    {
        release();
    }
}