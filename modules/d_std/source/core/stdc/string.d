module core.stdc.string;

extern(C) extern @nogc nothrow
{
    void* memcpy(void* dest, const(void*) src, size_t n);
    void* memset(void* str, int c, size_t n);
    int memcmp(const(void*) str1, const(void*) str2, size_t n) pure;
    size_t strlen(const(char*) str) pure;
}