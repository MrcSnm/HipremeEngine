/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

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
pure nothrow bool isPathUnixStyle(string path)
{
    for(int i = 0; i < path.length; i++)
        if(path[i] == '/')
            return true;
    return false;
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
    extern(Windows) nothrow @system void* dll_import_var(string name)
    {
        if(moduleHandle == null)
            moduleHandle = GetModuleHandle(null);
        return GetProcAddress(moduleHandle, (name~"\0").ptr);
    }

    void dll_import_varS(alias varSymbol)()
    {
        varSymbol = cast(typeof(varSymbol))dll_import_var(varSymbol.stringof);
    }
}