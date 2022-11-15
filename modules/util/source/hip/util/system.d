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

string sanitizePath(string path) @safe pure nothrow
{
    char[] ret = new char[](path.length);

    foreach(i, c; path)
    {
        version(Windows)
        {
            if(c == '/')
                ret[i] = '\\';
            else
                ret[i] = c;
        }
        else
        {
            if(c == '\\')
                ret[i] = '/';
            else
                ret[i] = c;
        }
    }
    return ret;
}
bool isPathUnixStyle(string path) @safe pure nothrow 
{
    for(size_t i = 0; i < path.length; i++)
        if(path[i] == '/')
            return true;
    return false;
}
string buildPath(string[] args...) @safe pure nothrow
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
    string[] dllImportVariables(Args...)()
    {
        import std.traits:isFunctionPointer;
        string[] failedFunctions;
        static foreach(a; Args)
        {
            static assert(isFunctionPointer!a, "Can't dll import a non function pointer ( "~a.stringof~" )");
            a = cast(typeof(a))dll_import_var(a.stringof);
            if(a is null)
                failedFunctions~= a.stringof;
        }
        return failedFunctions;
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
    if(libName == null)
    {
        version(Windows)
        {
            ret = GetModuleHandle(null);
        }
        else version(Posix)
        {
            import core.sys.posix.dlfcn : dlopen, RTLD_LAZY;
            ret = dlopen(null, RTLD_LAZY);
        }
        else
            ret = null;
    }
    else
    {
        // version(UWP)
        //     ret = GetModuleHandleA((libName~'\0').ptr);
        // else
        // {
            import core.runtime;
            ret = Runtime.loadLibrary(libName);
        // }
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
    // version(UWP)
    // {
    //     return cast(bool)FreeLibrary(dll);
    // }
    // else
    // {
        import core.runtime;
        return Runtime.unloadLibrary(dll);
    // }
}
