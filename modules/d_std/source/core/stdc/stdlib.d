module core.stdc.stdlib;
public import core.stdc.stddef;


enum EXIT_SUCCESS = 0;
enum EXIT_FAILURE = 1;
enum RAND_MAX = 0x7fffffff;

extern(C) @nogc extern nothrow:


void free(void* ptr);
void* malloc(uint size);
void* realloc(void* ptr, uint size);
void exit(int exitCode);

@trusted
{
    /// These two were added to Bionic in Lollipop.
    int     rand();
    ///
    void    srand(uint seed);
}


