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
import hip.util.string:fromStringz, toStringz;
import hip.util.path:pathSeparator;

version(PSVita) version = NoSharedLibrarySupport;
version(WebAssembly) version = NoSharedLibrarySupport;
version(CustomRuntimeTest) version = NoSharedLibrarySupport;

 version(Windows)
{
    pragma(lib, "psapi.lib");
    pragma(lib, "dbghelp.lib");
    private struct MODLOAD_DATA {DWORD ssize; DWORD ssig; PVOID data; DWORD size; DWORD flags; }
    import hip.util.windows;
    extern(Windows) private 
    {
        alias SymUnloadModule = SymUnloadModule64;
        BOOL SymUnloadModule64(HANDLE hProcess, DWORD64 BaseOfDll);
        DWORD64 SymLoadModuleEx(
            HANDLE        hProcess,
            HANDLE        hFile,
            PCSTR         ImageName,
            PCSTR         ModuleName,
            DWORD64       BaseOfDll,
            DWORD         DllSize,
            MODLOAD_DATA* Data,
            DWORD         Flags
        );
        BOOL SymRefreshModuleList(HANDLE hProcess);

    }
}
enum debugger = "asm {int 3;}";

char[] sanitizePath(string path) @safe pure nothrow
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

    string getLastWindowsErrorMessage()
    {
        return getWindowsErrorMessage(GetLastError());
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

    void winEnforce(scope BOOL delegate() dg, scope string message)
    {
        if(!dg())
            throw new Error(message~": "~getWindowsErrorMessage(GetLastError()));
    }
}


/** 
 * 
 * Params:
 *   libName = Basically a path
 * Returns: libName appended with the dynamic library extension
 */
string dynamicLibraryGetLibName(string libName)
{
    version(NoSharedLibrarySupport) return "";
    else version(Windows) return libName~".dll";
    else version(Posix)
    {
        import hip.util.path;
        libName.filename = "lib"~libName.filename~".so";
        return libName;
    }
    else static assert(0, "Platform not supported");
}

bool dynamicLibraryIsLibNameValid(string libName)
{
    version(NoSharedLibrarySupport)
        return true;
    else version(Windows)
        return libName[$-4..$] == ".dll";
    else version(Posix)
    {
        import hip.util.path;
        return libName.filename[0..3] == "lib" && libName[$-3..$] == ".so";
    }
}

version(NoSharedLibrarySupport)
{
    void* dynamicLibraryLoad(string libName) { return null; }
}
else
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
            import core.sys.posix.dlfcn : dlopen, RTLD_NOW;
            ret = dlopen(null, RTLD_NOW);
        }
    }
    else version (OSX) {}  //OSX gives an error with rt_loadLibrary not found.
    else
    {
        import core.runtime;
        ret = Runtime.loadLibrary(libName);
        version(Windows)
        {
            import core.sys.windows.psapi;
            import core.sys.windows.winbase;
            MODULEINFO moduleInfo;

            winEnforce(() => GetModuleInformation(GetCurrentProcess(), ret, &moduleInfo, MODULEINFO.sizeof), "Could not get module information");
            if(!SymLoadModuleEx(GetCurrentProcess(), null, libName.toStringz, null, cast(ulong)moduleInfo.lpBaseOfDll, moduleInfo.SizeOfImage, null, 0))
            {
                import core.sys.windows.winerror;

                HRESULT lastErr = GetLastError();
                if(lastErr != ERROR_SUCCESS)
                {
                    import core.sys.windows.winuser;
                    MessageBoxA(null, toStringz("Failed to load the DLL named "~libName~" pdb symbols "~getWindowsErrorMessage(lastErr) ~ " " ~ lastErr.to!string), "PDB Loading Failure", MB_ICONERROR | MB_OK);
                }
            }

        }
    }
    return ret;
}

version(Windows) private const (char)* err;
void* dynamicLibrarySymbolLink(void* dll, const (char)* symbolName)
{
    void* ret;
    version(NoSharedLibrarySupport)
        ret = null;
    else version(Windows)
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
    version(NoSharedLibrarySupport)
        return "Current platform does not load dynamic libraries";
    else version(Windows)
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
    version(NoSharedLibrarySupport)
        return false;
    else version(UWP)
    {
        return cast(bool)FreeLibrary(dll);
    }
    else version(Android)
    {
        import core.sys.posix.dlfcn:dlclose;
        return cast(bool)dlclose(dll);
    }
    else version(Posix)
    {
        import core.sys.posix.dlfcn:dlclose;
        return cast(bool)dlclose(dll);
    }
    else
    {
        import core.runtime;
        debug version(Windows)
        {
            import core.sys.windows.winbase;
            import core.sys.windows.psapi;
            MODULEINFO moduleInfo;
            winEnforce(() => GetModuleInformation(GetCurrentProcess(), dll, &moduleInfo, MODULEINFO.sizeof), "Could not get module information");
            winEnforce(() => SymUnloadModule(GetCurrentProcess(), cast(ulong)moduleInfo.lpBaseOfDll), "Could not unload PDB");
        }
        return Runtime.unloadLibrary(dll);
    }
}
