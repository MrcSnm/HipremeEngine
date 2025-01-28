module std.stdio;
import core.stdc.stdio;

version(WebAssembly)
{
    import arsd.webassembly;
    extern(C) void jsprint(uint length, const(char)* str) @nogc nothrow;
    void writeln(Args...)(Args args) nothrow @nogc
    {
        static if(args.length == 1 && is(typeof(args[0]) == string))
        {
            jsprint(args[0].length, args[0].ptr);
        }
        else
        {
            // version(Have_util)
            // {
            //     import hip.util.string;
            //     String s = String(args);
            //     jsprint(s.length, s.chars.ptr);
            // }
            // else
            // {
                eval(q{
                console.log.apply(null, arguments);
                }, args);
            // }
        }
    }
}
version(PSVita)
{
    extern(C) void hipVitaPrint(uint length, const(char)* str);
    void writeln(Args...)(Args args)
    {
        import hip.util.string;
        String str = String(args);
        hipVitaPrint(str.length, cast(const(char)*)str.ptr);
    }
}
version(CustomRuntimeTest)
{
    void writeln(Args...)(Args args)
    {
        import hip.util.string;
        String str = String(args);
        printf("%.*s", str.length, cast(const(char)*)str.ptr);
    }
}

struct File
{
    FILE* fptr;
    private size_t _size;

    size_t size(){return _size;}

    this(string path, string openMode = "r")
    {
        fptr = fopen((path~'\0').ptr, (openMode~'\0').ptr);
        if(fptr != null)
        {
            fseek(fptr, 0, SEEK_END);
            auto tempSize = ftell(fptr);
            if(tempSize > 0)
                _size = cast(size_t)tempSize;
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