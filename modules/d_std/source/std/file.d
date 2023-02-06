module std.file;
import core.stdc.stdio;

string getcwd(){return "";}

bool exists(string file)
{
    auto fHandle = fopen(file.ptr, "r");
    if(fHandle != null)
    {
        fclose(fHandle);
        return true;
    }
    return false;
}

ubyte[] read(string file)
{
    auto fHandle = fopen(file.ptr, "rb");
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
    assert(false, "No generic implementation for isDir");
}