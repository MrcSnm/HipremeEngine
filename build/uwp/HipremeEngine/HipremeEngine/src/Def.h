#pragma once
#include "pch.h"
#include <stdio.h>
#include <stdlib.h>

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

typedef uint8_t ubyte;
typedef uint16_t ushort;
typedef uint32_t uint;
typedef uint64_t ulong;
