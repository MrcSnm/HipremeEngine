module core.memory;

struct GC
{
    static void* addrOf(void* addr)@trusted pure nothrow @nogc {return addr;}
    static void free(void* addr) @trusted nothrow @nogc pure
    {
        pureFree(addr);
    }

    static size_t extend(void* ptr, size_t max, size_t desiredExtensionInSize, const TypeInfo ti =  null) pure nothrow
    {
        import core.arsd.memory_allocation;
        version(PSVita)
        {
            PSVMem mem = *cast(PSVMem*)getPSVMem(ptr);
            pureRealloc(cast(ubyte[])ptr[0..0], desiredExtensionInSize+mem.size);
        }
        else
        {
            import rt.hooks;
            auto block = getAllocatedBlock(ptr);
            pureRealloc(cast(ubyte[])ptr[0..0], block.blockSize+desiredExtensionInSize);
        }
        return desiredExtensionInSize;
    }

    static BlkInfo qalloc(size_t sz, uint ba = 0, const scope TypeInfo ti = null) pure nothrow
    {
        import core.arsd.memory_allocation;
        return BlkInfo(pureMalloc(sz).ptr, sz);
    }



    enum BlkAttr : uint
    {
        NONE        = 0b0000_0000, /// No attributes set.
        FINALIZE    = 0b0000_0001, /// Finalize the data in this block on collect.
        NO_SCAN     = 0b0000_0010, /// Do not scan through this block on collect.
        NO_MOVE     = 0b0000_0100, /// Do not move this memory block on collect.
        APPENDABLE  = 0b0000_1000,
        NO_INTERIOR = 0b0001_0000,
        STRUCTFINAL = 0b0010_0000, // the block has a finalizer for (an array of) structs
    }
}


struct BlkInfo
{
    void*  base;
    size_t size;
    uint   attr;
}

void pureFree(void* addr) pure nothrow @trusted @nogc
{
    import rt.hooks;
    alias pureFreeT = extern(C) void function(void* addr) pure nothrow @trusted @nogc;
    auto freeAddr = cast(pureFreeT)&free;
    freeAddr(addr);
}

enum pageSize = 516;