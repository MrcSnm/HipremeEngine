module core.memory;

struct GC
{
    static void* addrOf(void* addr)@trusted pure nothrow @nogc {return addr;}
    static void free(void* addr) @trusted nothrow @nogc
    {
        static import core.stdc.stdlib;
        core.stdc.stdlib.free(addr);
    }
}

void pureFree(void* addr) pure nothrow @trusted @nogc
{
    import core.stdc.stdlib;
    auto freeAddr = cast(void function(void* addr) pure nothrow @trusted @nogc)&free;
    freeAddr(addr);
}