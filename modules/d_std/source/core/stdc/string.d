module core.stdc.string;

extern(C) extern @nogc nothrow pure
{
    version(WebAssembly) version = CustomDefinitions;


    version(WebAssembly) version = CustomRuntime;
    version(PSVita) version = CustomRuntime;
    version(CustomRuntimeTest) version = CustomRuntime;
    

    version(CustomRuntime)
    {
        public import object: memcpy, memset, memcmp, memmove;
    }
    else
    {
        void* memcpy(void* dest, const(void*) src, size_t n);
        void* memset(void* str, int c, size_t n);
        int memcmp(const(void*) str1, const(void*) str2, size_t n) pure;
        void* memmove(return scope void* s1, scope const void* s2, size_t n) pure;
        const(char)* strchr(const(char)* str, char c) pure @nogc nothrow @trustred;
    }

    version(CustomDefinitions)
    {
        size_t strlen(const(char)* str) pure @nogc nothrow @trusted
        {
            enum ulong mask = 0x8080808080808080; // Mask to check the highest bit of each byte
            enum ulong magic = 0x0101010101010101; // Magic number to propagate carry
            size_t* ptr = cast(size_t*)str;

            size_t len = 0;
            while(true)
            {
                // Step 2: Check for 0x00 bytes
                // If a byte is 0x00, the highest bit of (value - magic) will be 1
                ulong value = *ptr;
                if(((value - magic) & ~value & mask) != 0)
                    break;
                ptr++;
                len+= 8;
            }
            while(str[len++] != '\0'){}

            return len;
        }

        const(char)* strchr(const(char)* str, char c) pure @nogc nothrow @trusted
        {
            enum ulong mask  = 0x8080808080808080;
            enum ulong magic = 0x0101010101010101;
            ulong cc = cast(ubyte)c;
            cc |= cc << 8;
            cc |= cc << 16;
            cc |= cc << 32;

            auto ptr = cast(const(ulong)*)str;
            size_t offset = 0;

            for(;; ptr++, offset += 8)
            {
                ulong value = *ptr;

                // detect match with c
                ulong diff = value ^ cc;
                if(((diff - magic) & ~diff & mask) != 0)
                    break;

                // detect null terminator
                if(((value - magic) & ~value & mask) != 0)
                    break;
            }

            // refine, byte by byte
            for(;; offset++)
            {
                if(str[offset] == c)
                    return str + offset;
                if(str[offset] == '\0')
                    return null;
            }
        }


        const(char)* strerror(int errnum){return errnum == 0 ? "Success" : "Error";}
    }
    else
    {
        const(char)* strerror(int errnum);
        size_t strlen(const(char*) str) pure;
    }

    int strncmp (const(char)* str1, const(char)* str2, size_t num );
    int strcmp (const char* str1, const char* str2);
    char *strstr(const char *haystack, const char *needle);
    char* strcpy(char* destination, const char* source);



    version(PSVita)
    {
        int strerror_r(int errnum, scope char* buf, size_t buflen);
    }
}