module core.stdc.stdlib;
public import core.stdc.stddef;

enum EXIT_SUCCESS = 0;
enum EXIT_FAILURE = 1;
enum RAND_MAX = 0x7fffffff;


alias _compare_fp_t = extern(C) int function(const(void*) a, const(void*) b);

version(WebAssembly) version = CustomRuntime;
version(PSVita) version = CustomRuntime;

version(CustomRuntime)
{
    private alias nogc_free_t = @nogc nothrow void function(ubyte* ptr);
    private alias nogc_malloc_t = @nogc nothrow ubyte[] function(size_t size, string file, size_t line);
    private alias nogc_calloc_t = @nogc nothrow ubyte[] function(size_t size, size_t count, string file, size_t line);
    private alias nogc_realloc_t = @nogc nothrow ubyte[] function(ubyte* ptr, size_t size, string file, size_t line);
    static import rt.hooks;

    @nogc nothrow
    {
        void free(void* ptr)
        {
            auto nogc_free = cast(nogc_free_t)&rt.hooks.free;
            nogc_free(cast(ubyte*)ptr);
        }
        void* malloc(size_t size, string file = __FILE__, size_t line = __LINE__)
        {
            auto nogc_malloc = cast(nogc_malloc_t)&rt.hooks.malloc;
            return cast(void*)nogc_malloc(size, file, line).ptr;
        }
        void* calloc(size_t count, size_t size, string file = __FILE__, size_t line = __LINE__)
        {
            auto nogc_calloc = cast(nogc_calloc_t)&rt.hooks.calloc;
            return cast(void*)nogc_calloc(count, size, file, line).ptr;
        }
        void* realloc(void* ptr, size_t size, string file = __FILE__, size_t line = __LINE__)
        {
            auto nogc_realloc = cast(nogc_realloc_t)&rt.hooks.realloc;
            version(PSVita)
            {
                void* ret = cast(void*)nogc_realloc(cast(ubyte*)ptr, size, file, line).ptr;
                free(ptr);
                return ret;
            }
            else return cast(void*)nogc_realloc(cast(ubyte*)ptr, size, file, line).ptr;
        }
    }   
}
else
{
    extern(C) @nogc extern nothrow:
    void free(void* ptr);
    void* malloc(size_t size);
    void* calloc(size_t count, size_t size);
    void* realloc(void* ptr, size_t size);
}
version(WebAssembly)
{
    void qsort(void* base, size_t nmemb, size_t size, _compare_fp_t compar){assert(false, "No sort implemented");}
    void exit(int exitCode){assert(false, "Exit with code unknown");}
}
else
{
    extern(C) @nogc extern nothrow:
    void* memmove(void* str1, const(void)* str2, size_t n);
    void exit(int exitCode);
    void qsort(void *base, size_t nitems, size_t size, int function (void *, void*) compare);
    int abs(int a){return a > 0 ? a : -a;}

    @trusted
    {
        /// These two were added to Bionic in Lollipop.
        int     rand();
        ///
        void    srand(uint seed);
    }
}

