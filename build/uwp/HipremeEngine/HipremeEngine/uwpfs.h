#pragma once
#include "Def.h"

d_import HANDLE UWPCreateFileFromAppW(
	LPCWSTR               lpFileName,
	DWORD                 dwDesiredAccess,
	DWORD                 dwShareMode,
	LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	DWORD                 dwCreationDisposition,
	DWORD                 dwFlagsAndAttributes,
	HANDLE                hTemplateFile
);

d_import BOOL UWPDeleteFileFromAppW(
	LPCWSTR lpFileName
);

d_import BOOL UWPGetFileAttributesExFromAppW(
	LPCWSTR                lpFileName,
	GET_FILEEX_INFO_LEVELS fInfoLevelId,
	LPVOID                 lpFileInformation
);
