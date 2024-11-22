/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.bind.external;


version(UWP)
{
    import core.sys.windows.windef;
    import core.sys.windows.unknwn;
    import core.sys.windows.winbase;
    struct HipExternalCoreWindow
    {
        IUnknown coreWindow;
        uint logicalWidth;
        uint logicalHeight;
    }
    extern(Windows) nothrow @system __gshared
    {
        HipExternalCoreWindow function() getCoreWindow;
        void function(const(wchar*) wcstr) OutputUWP;

        HANDLE function(
        LPCWSTR               lpFileName,
        DWORD                 dwDesiredAccess,
        DWORD                 dwShareMode,
        LPSECURITY_ATTRIBUTES lpSecurityAttributes,
        DWORD                 dwCreationDisposition,
        DWORD                 dwFlagsAndAttributes,
        HANDLE                hTemplateFile
        ) UWPCreateFileFromAppW;

        BOOL function(LPCWSTR lpFileName
        ) UWPDeleteFileFromAppW;

        BOOL function(
        LPCWSTR                lpFileName,
        GET_FILEEX_INFO_LEVELS fInfoLevelId,
        LPVOID                 lpFileInformation
        ) UWPGetFileAttributesExFromAppW;
    }
    void uwpPrint(string str)
    {
        import std.utf:toUTF16z;
        OutputUWP(toUTF16z(str));
        OutputUWP("\n");
    } 
}


void importExternal()
{
    import hip.util.system;
    version(UWP)
    {
        string[] errors = dllImportVariables!(
            ///App.cpp
            getCoreWindow, 
            OutputUWP,

            ///uwpfs.h
            UWPCreateFileFromAppW,
            UWPDeleteFileFromAppW,
            UWPGetFileAttributesExFromAppW
        );

        assert(OutputUWP != null, "Failed loading OutputUWP");
        
        foreach(err; errors)
            uwpPrint("HIPREME_ENGINE: Could not load function "~err);
    }
}
