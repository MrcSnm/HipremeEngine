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
    import core.stdc.stdlib;
    auto freeAddr = cast(void function(void* addr) pure nothrow @trusted @nogc)&free;
    freeAddr(addr);
}