module std.file;
import core.stdc.stdio;

version(Windows)
{
    import core.sys.windows.windef;
    extern(Windows) nothrow @nogc DWORD GetCurrentDirectoryA(DWORD, LPSTR);
}

string getcwd()
{
    version(Windows)
    {
        char[4096] buff = void;
        immutable n = GetCurrentDirectoryA(cast(DWORD)buff.length, buff.ptr);
        char[] ret = new char[n];
        ret[] = buff[0..n];
        return cast(string)ret;
    }
    else return "";
}

bool exists(string file)
{
    auto fHandle = fopen((file~'\0').ptr, "r");
    if(fHandle != null)
    {
        fclose(fHandle);
        return true;
    }
    return false;
}

ubyte[] read(string file)
{
    auto fHandle = fopen((file~'\0').ptr, "rb");
    if(fHandle != null)
    {
        ubyte[] ret;
        fseek(fHandle, 0, SEEK_END);
        auto sz = ftell(fHandle);
        scope(exit) fclose(fHandle);
        if(sz > 0)
        {
            fseek(fHandle, 0, SEEK_SET);
            size_t fileSize = cast(size_t)sz;
            ret = new ubyte[fileSize];
            auto readSize = fread(cast(void*)ret.ptr, fileSize, 1, fHandle);
            return ret[0..readSize];
        }
    }
    return [];
}


void write(string path, ubyte[] buffer)
{
    auto fHandle = fopen((path~"\0").ptr, "w");
    if(fHandle != null)
    {
        scope(exit) fclose(fHandle);
        foreach(b; buffer)
            if(fputc(cast(int)b, fHandle) == EOF) return;
    }
}
void write(string path, void[] buffer){write(path, cast(ubyte[])buffer);}
void write(string path, string buffer){write(path, cast(ubyte[])buffer);}

void remove(string filename)
{
    if(!core.stdc.stdio.remove((filename~"\0").ptr))
    {
        assert(false, "Could not remove "~filename);
    }
}

bool isDir(string path)
{
    return path[$-1] == '/' || path[$-1] == '\\';
}