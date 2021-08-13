/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

#include "d_game.h"
#include "pch.h"
#include "Def.h"

int  (*HipremeMain)() = nullptr;
bool (*HipremeUpdate)() = nullptr;
void (*HipremeDestroy)() = nullptr;

#define D_ENGINE_IMPORT_LIST \
X(HipremeMain) \
X(HipremeUpdate) \
X(HipremeDestroy)


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