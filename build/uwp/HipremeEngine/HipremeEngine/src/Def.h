#pragma once
#include "pch.h"
#include <stdio.h>

///Loads a given asset DLL and check for errors
HMODULE LoadDLL(LPCWSTR str);

///Imports a function for D to use
#define d_import extern "C" __declspec( dllexport ) 
#define LoadFunction(lib, funcName) funcName = (decltype(funcName))GetProcAddress(lib, #funcName)

#define dprint(format, ...) {\
char pBuffer[1000];\
sprintf_s(pBuffer, format, __VA_ARGS__);\
OutputDebugStringA(pBuffer);\
}