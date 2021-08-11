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

version(Windows)
{
    import core.sys.windows.dll;
    import core.sys.windows.windows;
    private HMODULE moduleHandle;
    void* dll_import_var(string name)
    {
        if(moduleHandle == null)
            moduleHandle = GetModuleHandle(null);
        return GetProcAddress(moduleHandle, (name~"\0").ptr);
    }
}