/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.system;
import hip.util.conv;
import core.stdc.string;
import hip.util.string:fromStringz;
import hip.util.path:pathSeparator;

enum debugger = "asm {int 3;}";

pure nothrow string sanitizePath(string path)
{
    string ret = new string(path.length);

    for(uint i = 0; i < path.length; i++)
    {
        version(Windows)
        {
            if(path[i] == '/')
                ret~= '\\';
            else
                ret~= path[i];
        }
        else
        {
            if(path[i] == '\\')
                ret~= '/';
            else
                ret~= path[i];
        }
    }
    return ret;
}
pure nothrow bool isPathUnixStyle(string path)
{
    for(int i = 0; i < path.length; i++)
        if(path[i] == '/')
            return true;
    return false;
}
string buildPath(string[] args...)
{
    if(args.length == 0)
        return null;
    string ret;
    for(int i = 0; i < cast(int)args.length-1; i++)
        ret~= args[i]~pathSeparator;
    return ret~args[$-1];
}

version(Windows)
{
    // import core.sys.windows.winbase;
    // import core.sys.windows.windef;

    import hip.util.windows;

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

    string getWindowsErrorMessage(HRESULT hr)
    {
        wchar* buffer;
        HRESULT fmt = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | 
        FORMAT_MESSAGE_IGNORE_INSERTS |
        FORMAT_MESSAGE_ALLOCATE_BUFFER,
        null, hr, 0u, cast(LPWSTR)&buffer, 0, null);

        if(fmt == 0)
            return "Error code '"~hip.util.conv.toString(hr)~"' not found";
        string ret = fromUTF16(cast(wstring)buffer[0..fmt]);

        LocalFree(buffer);

        return ret;
    }
}


string dynamicLibraryGetLibName(string libName)
{
    version(Windows) return libName~".dll";
    else version(Posix) return "lib"~libName~".so";
    else assert(0, "Platform not supported");
}

bool dynamicLibraryIsLibNameValid(string libName)
{
    version(Windows)
        return libName[$-4..$] == ".dll";
    else version(Posix)
        return libName[0..3] == "lib" && libName[$-3..$] == ".so";
    else
        return false;
}

///It will open the current executable if libName == null
void* dynamicLibraryLoad(string libName)
{
    import core.runtime;
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
    else assert(0, "Platform not supported");
    return ret;
    // return Runtime.loadLibrary(libName);
}

version(Windows) private const (char)* err;
void* dynamicLibrarySymbolLink(void* dll, const (char)* symbolName)
{
    void* ret;
    version(Windows)
    {
        ret = GetProcAddress(dll, symbolName);
        if(!ret)
            err = ("Could not link symbol "~symbolName.fromStringz).ptr;
    }
    else version(Posix)
    {
        import core.sys.posix.dlfcn : dlsym;
        ret = dlsym(dll, symbolName);
    }
    else assert(0, "Platform not supported");
    return ret;
}


string dynamicLibraryError()
{
    version(Windows)
    {
        const(char)* ret = err;
        err = null;
        return cast(string)fromStringz(ret);
    }
    else version(Posix)
    {
        import core.sys.posix.dlfcn;
        return cast(string)fromStringz(dlerror());
    }
    else assert(0, "Platform not supported");
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
    else assert(0, "Platform not supported");
}
