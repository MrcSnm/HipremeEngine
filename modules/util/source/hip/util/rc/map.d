module hip.util.rc.map;
public import hip.util.allocator;

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
    private Allocator* allocator;

    private int* countPtr;

    this(this)
    {
        if(countPtr !is null)
            *countPtr = *countPtr + 1;
    }

    private int entriesCount;

    private void initialize(Allocator* allocator) @nogc
    {
        this.allocator = allocator;
        dataSet = Array!(MapBucket)(initializationLength, allocator);
        dataSet.length = initializationLength;
        dataSet[] = MapBucket.init;
        countPtr = cast(int*)allocator.alloc(ptrdiff_t.sizeof).ptr;
        *countPtr = 0;
    }
    static auto opCall(Allocator* allocator = mallocAllocator) @nogc
    {
        Map!(K, V) ret;
        ret.initialize(allocator);
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
                    allocator.free(buck[0..1]);
                    buck = copy.next;
                }
            }
        }
    }
    //Called when array is filled at least increasingThreshold
    private void recalculateHashes() @nogc
    {
        size_t newSize = cast(size_t)(dataSet.capacity * increasingFactor);
        Array!MapBucket newArray = Array!MapBucket(newSize, allocator);

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
            initialize(allocator);
        return dataSet[getIndex(index)].data.value;
    }
    ref auto opIndexAssign(V value, K key) @nogc
    {
        if(dataSet.length == 0)
            initialize(allocator);
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
            curr.next = cast(MapBucket*)allocator.alloc(MapBucket.sizeof).ptr;
            *curr.next = MapBucket(MapData(key, value), null);

        }
        return this;
    }

    auto opBinaryRight(string op, L)(const L lhs) const @nogc
    if(op == "in")
    {
        if(dataSet.length == 0)
            initialize(allocator);
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
                allocator.free(countPtr[0..1]);
            }
            countPtr = null;
        }
    }

}
alias AArray = Map;