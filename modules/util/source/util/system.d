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
import util.conv;
import core.stdc.string;
import util.string:fromStringz;

version(Standalone){}
else{public import fswatch;}

pure nothrow string sanitizePath(string path)
{
    string ret;
    ret.reserve(path.length);

    for(ulong i = 0; i < path.length; i++)
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
    {
        version(Windows)
            ret~= args[i]~'\\';
        else
        	ret~= args[i]~'/';
    }
    return ret~args[$-1];
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

    string getWindowsErrorMessage(HRESULT hr)
    {
        wchar[4096] buffer;
        FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        null, hr, 0u, buffer.ptr, buffer.length, null);
        return fromUTF16(cast(wstring)buffer);
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
