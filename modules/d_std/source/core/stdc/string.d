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
        size_t strlen(const(char*) str) pure
        {
            if(str == null) return 0;
            size_t l = 0;
            while(str[l] != '\0') l++;
            return l;
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