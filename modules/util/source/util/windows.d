module util.windows;

import core.stdc.stdarg;

version(Windows):

	
@nogc nothrow extern(Windows)
{
    void* GetModuleHandleA(const(char)* str);
    void* GetModuleHandleW(const(wchar)* str);
    void* GetProcAddress(void* mod, const(char)* func);
    void* LoadLibraryA(const char* fileName);
    BOOL  FreeLibrary(void* lib);
    uint GetLastError();

    DWORD FormatMessageW(DWORD, PCVOID, DWORD, DWORD, LPWSTR, DWORD, va_list*);

    int SetEndOfFile(void* handle);

    alias GetModuleHandle = GetModuleHandleW;
    alias FormatMessage = FormatMessageW;



    HLOCAL LocalAlloc(UINT, SIZE_T);
    HLOCAL LocalDiscard(HLOCAL);
    HLOCAL LocalFree(HLOCAL);
    HLOCAL LocalHandle(LPCVOID);
}

enum DWORD
    FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x0100,
    FORMAT_MESSAGE_IGNORE_INSERTS  = 0x0200,
    FORMAT_MESSAGE_FROM_STRING     = 0x0400,
    FORMAT_MESSAGE_FROM_HMODULE    = 0x0800,
    FORMAT_MESSAGE_FROM_SYSTEM     = 0x1000,
    FORMAT_MESSAGE_ARGUMENT_ARRAY  = 0x2000;

enum DWORD FORMAT_MESSAGE_MAX_WIDTH_MASK = 255;

alias ubyte        BYTE;
alias ubyte*       PBYTE, LPBYTE;
alias ushort       USHORT, WORD, ATOM;
alias ushort*      PUSHORT, PWORD, LPWORD;
alias uint         ULONG, DWORD, UINT, COLORREF;
alias uint*        PULONG, PDWORD, LPDWORD, PUINT, LPUINT, LPCOLORREF;
alias int          WINBOOL, BOOL, INT, LONG, HFILE, HRESULT;
alias int*         PWINBOOL, LPWINBOOL, PBOOL, LPBOOL, PINT, LPINT, LPLONG;
alias float        FLOAT;
alias float*       PFLOAT;
alias const(void)* PCVOID, LPCVOID;

alias void*  PVOID, LPVOID;
alias char*  PSZ, PCHAR, PCCHAR, LPCH, PCH, LPSTR, PSTR;
alias wchar* PWCHAR, LPWCH, PWCH, LPWSTR, PWSTR;
alias bool*  PBOOLEAN;
alias ubyte* PUCHAR;
alias short* PSHORT;
alias int*   PLONG;
alias uint*  PLCID, PACCESS_MASK;
alias long*  PLONGLONG;
alias ulong* PDWORDLONG, PULONGLONG;



alias HMODULE = void*;
alias HLOCAL = void*;
alias SIZE_T = ulong;