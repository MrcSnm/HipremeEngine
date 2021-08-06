module util.system;
import std.system:os;
import core.stdc.string;
import std.array:replace;

pure nothrow string sanitizePath(string path)
{
    switch(os)
    {
        case os.win32:
        case os.win64:
            return replace(path, "/", "\\");
        default:
            return replace(path, "\\", "/");
    }
}

void setZeroMemory(T)(ref T variable)
{
    memset(&variable, 0, T.sizeof);
}