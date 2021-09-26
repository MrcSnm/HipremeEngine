/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module bind.external;


version(UWP)
{
    import core.sys.windows.windows;
    extern(Windows) nothrow @system 
    {
        HWND function() getCoreWindowHWND;
        void function(const(wchar*) wcstr) OutputUWP;
    }
    void uwpPrint(string str)
    {
        import std.utf:toUTF16z;
        OutputUWP(toUTF16z(str));
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