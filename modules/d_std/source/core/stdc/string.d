module core.stdc.string;

extern(C) extern @nogc nothrow pure
{
    void* memcpy(void* dest, const(void*) src, size_t n);
    void* memset(void* str, int c, size_t n);
    int memcmp(const(void*) str1, const(void*) str2, size_t n) pure;
    version(WebAssembly)
    {
        size_t strlen(const(char*) str) pure
        {
            if(str == null) return 0;
            size_t l = 0;
            while(str[l] != '\0') l++;
            return l;
        }
    }
    else
    size_t strlen(const(char*) str) pure;
}