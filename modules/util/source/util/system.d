/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module util.system;
import std.conv:to;
import std.system:os;
import core.stdc.string;
import std.array:replace;

version(Standalone){}
else{public import fswatch;}

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
pure nothrow bool isPathUnixStyle(string path)
{
    for(int i = 0; i < path.length; i++)
        if(path[i] == '/')
            return true;
    return false;
}
version(Windows)
{
    import core.sys.windows.dll;
    import core.sys.windows.windows;
    private HMODULE moduleHandle;
    extern(Windows) nothrow @system void* dll_import_var(string name)
    {
        if(moduleHandle == null)
            moduleHandle = GetModuleHandle(null);
        return GetProcAddress(moduleHandle, (name~"\0").ptr);
    }
    void dll_import_varS(alias varSymbol, string s = "")()
    {
        static if(s == "")
            varSymbol = cast(typeof(varSymbol))dll_import_var(varSymbol.stringof);
        else
            varSymbol = cast(typeof(varSymbol))dll_import_var(s);
    }
}


string dynamicLibraryGetLibName(string libName)
{
    version(Windows) return libName~".dll";
    else version(Posix) return "lib"~libName~".so";
    else static assert(0, "Platform not supported");
}

bool dynamicLibraryIsLibNameValid(string libName)
{
    version(Windows)
        return libName[$-4..$] == ".dll";
    else version(Posix)
        return libName[0..3] == "lib" && libName[$-3..$] == ".so";
    else
        return true;
}

///It will open the current executable if libName == null
void* dynamicLibraryLoad(string libName)
{
    void* ret;
    version(Windows)
    {
        if(libName == null)
            ret = GetModuleHandle(null);
        else
            ret = LoadLibraryA((libName~"\0").ptr);
    }
    else version(Posix)
    {
        import core.sys.posix.dlfcn : dlopen, RTLD_LAZY;
        if(libName == null)
            ret = dlopen(null, RTLD_LAZY);
        else
            ret = dlopen((libName~"\0").ptr, RTLD_LAZY);
    }
    return ret;
}

version(Windows) private const (char)* err;
void* dynamicLibrarySymbolLink(void* dll, const (char)* symbolName)
{
    void* ret;
    version(Windows)
    {
        ret = GetProcAddress(dll, symbolName);
        if(!ret)
            err = ("Could not link symbol "~to!string(symbolName)).ptr;
    }
    else version(Posix)
    {
        import core.sys.posix.dlfcn : dlsym;
        ret = dlsym(dll, symbolName);
    }
    return ret;
}


string dynamicLibraryError()
{
    version(Windows)
    {
        const(char)* ret = err;
        err = null;
        return to!string(ret);
    }
    else version(Posix)
    {
        import core.sys.posix.dlfcn;
        return to!string(dlerror());
    }
    else static assert(0, "Platform not supported");
}

bool dynamicLibraryRelease(void* dll)
{
    version(Windows)
        return FreeLibrary(dll) == 0;
    else version(Posix)
    {
        import core.sys.posix.dlfcn;
        return dlclose(dll) == 0;
    }
    else static assert(0, "Platform not supported");
}