module core.memory;

struct GC
{
    static void* addrOf(void* addr)@trusted pure nothrow @nogc {return addr;}
    static void free(void* addr, string f = __FILE__, size_t l = __LINE__ ) @trusted nothrow @nogc pure
    {
        pureFree(addr, f, l);
    }

    static size_t extend(void* ptr, size_t max, size_t desiredExtensionInSize, const TypeInfo ti =  null) pure nothrow
    {
        import core.arsd.memory_allocation;
        import rt.hooks;
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
        import rt.hooks;
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

void pureFree(void* addr, string f = __FILE__, size_t l = __LINE__) pure nothrow @trusted @nogc
{
    import rt.hooks;
    alias pureFreeT = extern(C) void function(void* addr, string f, size_t l) pure nothrow @trusted @nogc;
    auto freeAddr = cast(pureFreeT)&free;
    freeAddr(addr, f, l);
}

enum pageSize = 516;