module std.stdio;
import core.stdc.stdio;

version(WebAssembly)
{
    import arsd.webassembly;

    void writeln(T...)(T t) {
        eval(q{
            console.log.apply(null, arguments);
        }, t);
    }
}
else
{
    struct File
    {
        FILE* fptr;

        this(string path, string openMode)
        {
            fptr = fopen((path~'\0').ptr, (openMode~'\0').ptr);
        }

        ~this()
        {
            if(fptr != null)
            {
                fclose(fptr);
                fptr = null;
            }
        }
    }
}
