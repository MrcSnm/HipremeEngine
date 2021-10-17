#include "pch.h"
#include "Def.h"


HMODULE LoadDLL(LPCWSTR str)
{
	HMODULE ret = LoadPackagedLibrary(str, 0);
	if (ret == NULL)
	{
		wchar_t outputBuffer[4096] = { 0 };
		wchar_t buff[1024] = { 0 };
		DWORD err = GetLastError();
		FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,
			NULL, err, 0, buff, 1024, NULL);

		swprintf(outputBuffer, 4096, L"Could not load library %ls\nError %d: %ls", str, err, buff);
		OutputDebugString(outputBuffer);
	}
	return ret;
}