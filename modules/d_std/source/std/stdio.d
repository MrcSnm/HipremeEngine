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
struct File
{
    FILE* fptr;
    const size_t size;

    this(string path, string openMode = "r")
    {
        fptr = fopen((path~'\0').ptr, (openMode~'\0').ptr);
        if(fptr != null)
        {
            fseek(fptr, 0, SEEK_END);
            auto tempSize = ftell(fptr);
            if(tempSize > 0)
                size = cast(size_t)tempSize;
            fseek(fptr, 0, SEEK_SET);
        }
    }

    void rawWrite(string data){rawWrite(cast(ubyte[])data);}
    void rawWrite(ubyte[] data)
    {
        if(fptr != null)
        {
            foreach(b; data)
            {
                if(fputc(b, fptr) == EOF)
                    break;
            }
        }
    }

    void[] rawRead(void[] buffer){return cast(void[])rawRead(cast(ubyte[])buffer);}
    ubyte[] rawRead(ubyte[] buffer)
    {
        if(fptr != null)
        {
            int ch = -1;
            size_t totalRead = 0;
            while((ch = fgetc(fptr)) != EOF && totalRead < buffer.length)
                buffer[totalRead++] = cast(ubyte)ch;
            
            return buffer[0..totalRead];
        }
        return buffer;
    }

    void seek(ptrdiff_t offset, int origin = SEEK_SET)
    {
        if(fptr != null)
        {
            fseek(fptr, offset, origin);
        }
    }
    void close()
    {
        if(fptr != null)
        {
            fclose(fptr);
            fptr = null;
        }
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