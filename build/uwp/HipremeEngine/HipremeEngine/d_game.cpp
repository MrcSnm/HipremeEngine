#include "d_game.h"
#include "pch.h"
#include "Def.h"

void (*HipremeInit)() = nullptr;
int  (*HipremeMain)() = nullptr;
bool (*HipremeUpdate)() = nullptr;
void (*HipremeRender)() = nullptr;
void (*HipremeDestroy)() = nullptr;

void(*HipInputOnTouchPressed)(uint32_t, float, float) = nullptr;
void(*HipInputOnTouchMoved)(uint32_t, float, float) = nullptr;
void(*HipInputOnKeyDown)(uint32_t) = nullptr;
void(*HipInputOnKeyUp)(uint32_t) = nullptr;

#define D_ENGINE_IMPORT_LIST \
X(HipremeInit) \
X(HipremeMain) \
X(HipremeUpdate) \
X(HipremeRender) \
X(HipremeDestroy) \
/* Input Related */ \
X(HipInputOnTouchPressed) \
X(HipInputOnTouchMoved) \
X(HipInputOnKeyDown) \
X(HipInputOnKeyUp)


int d_game_LoadDLL(HMODULE lib)
{
	int failedFuncs = 0;
#define LoadFunctionC(lib, name) if((LoadFunction(lib, name)) == nullptr){\
failedFuncs++;\
OutputDebugString(L"Failed loading function " #name "\n");}


#define X(name) LoadFunctionC(lib, name);
	D_ENGINE_IMPORT_LIST;
#undef X

#undef LoadFunctionC
	return failedFuncs;
}