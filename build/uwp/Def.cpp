#include "Def.h"
#include "pch.h"
#include <iostream>


HMODULE LoadDLL(LPCWSTR str)
{
	HMODULE ret = LoadPackagedLibrary(str, 0);
	if (ret == NULL)
		OutputDebugString(L"Could not load library"); //str << " Error:\n\t " << GetLastError();
	return ret;
}