module core.stdc.string;

extern(C) extern @nogc nothrow pure
{
    version(WebAssembly) version = CustomDefinitions;


    version(WebAssembly) version = CustomRuntime;
    version(PSVita) version = CustomRuntime;
    version(CustomRuntimeTest) version = CustomRuntime;
    

    version(CustomRuntime)
    {
        public import object: memcpy, memset, memcmp; 
    }
    else
    {
        void* memcpy(void* dest, const(void*) src, size_t n);
        void* memset(void* str, int c, size_t n);
        int memcmp(const(void*) str1, const(void*) str2, size_t n) pure;
    }

    version(CustomDefinitions)
    {
        size_t strlen(immutable(char)* str) pure @nogc nothrow @trusted
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