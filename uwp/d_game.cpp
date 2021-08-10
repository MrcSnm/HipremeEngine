#include "d_game.h"
#include "pch.h"
#include "Def.h"

int  (*getMy50)() = nullptr;
int  (*init_D_runtime)() = nullptr;
char*(*concatenateStringFromCWRT)(char*) = nullptr;
void (*set_maps)(char* key, int value) = nullptr;
int  (*get_maps)(char* key) = nullptr;

int d_game_LoadDLL(HMODULE lib)
{
	int failedFuncs = 0;
#define LoadFunctionC(lib, name) if((LoadFunction(lib, name)) == nullptr){\
failedFuncs++;\
OutputDebugString(L"Failed loading function " #name "\n");}

	LoadFunctionC(lib, getMy50);
	LoadFunctionC(lib, init_D_runtime);
	LoadFunctionC(lib, concatenateStringFromCWRT);
	LoadFunctionC(lib, set_maps);
	LoadFunctionC(lib, get_maps);

	return failedFuncs;
#undef LoadFunctionC
}