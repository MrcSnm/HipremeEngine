module core.memory;

struct GC
{
    static void* addrOf(void* addr)@trusted pure nothrow @nogc {return addr;}
    static void free(void* addr) @trusted nothrow @nogc pure
    {
        pureFree(addr);
    }
}

void pureFree(void* addr) pure nothrow @trusted @nogc
{
    import rt.hooks;
    alias pureFreeT = extern(C) void function(void* addr) pure nothrow @trusted @nogc;
    auto freeAddr = cast(pureFreeT)&free;
    freeAddr(addr);
}

enum pageSize = 516;