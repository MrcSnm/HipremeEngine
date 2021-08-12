/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module bind.external;

enum Platforms
{
    DEFAULT,
    DESKTOP,
    ANDROID,
    UWP,
    NULL
}


version(UWP)
{
    import core.sys.windows.windows;
    extern(Windows) nothrow @system 
    {
        HWND function() getCoreWindowHWND;
        void function(wchar* wcstr) OutputUWP;
    }
    void uwpPrint(string str)
    {
        import std.conv:to;
        OutputUWP(cast(wchar*)to!wstring(str).ptr);
    } 
}
alias myFunPtr = extern(Windows) nothrow @system int function();

void importExternal()
{
    import util.system;
    version(UWP)
    {
        dll_import_varS!getCoreWindowHWND;
        dll_import_varS!OutputUWP;
    }
}