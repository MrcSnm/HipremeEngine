/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module bind.external;


version(UWP)
{
    import core.sys.windows.windows;
    struct HipExternalCoreWindow
    {
        IUnknown coreWindow;
        uint logicalWidth;
        uint logicalHeight;
    }
    extern(Windows) nothrow @system 
    {
        HWND function() getCoreWindowHWND;
        HipExternalCoreWindow function() getCoreWindow;
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
        dll_import_varS!getCoreWindow;
        dll_import_varS!OutputUWP;
    }
}