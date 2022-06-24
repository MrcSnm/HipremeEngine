module std.stdio;
import core.stdc.stdio;

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