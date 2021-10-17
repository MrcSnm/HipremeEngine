#include "pch.h"
#include "uwpfs.h"

HANDLE UWPCreateFileFromAppW(
	LPCWSTR               lpFileName,
	DWORD                 dwDesiredAccess,
	DWORD                 dwShareMode,
	LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	DWORD                 dwCreationDisposition,
	DWORD                 dwFlagsAndAttributes,
	HANDLE                hTemplateFile
)
{
	return CreateFileFromAppW(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
}

BOOL UWPDeleteFileFromAppW(
	LPCWSTR lpFileName
)
{
	return DeleteFileFromAppW(lpFileName);
}

BOOL UWPGetFileAttributesExFromAppW(
	LPCWSTR                lpFileName,
	GET_FILEEX_INFO_LEVELS fInfoLevelId,
	LPVOID                 lpFileInformation
)
{
	return GetFileAttributesExFromAppW(lpFileName, fInfoLevelId, lpFileInformation);
}
