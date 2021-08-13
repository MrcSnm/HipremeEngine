/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

#pragma once
#include "pch.h"

extern int  (*getMy50)();
extern int  (*init_D_runtime)();
extern char*(*concatenateStringFromCWRT)(char*);
extern void (*set_maps)(char* key, int value);
extern int  (*get_maps)(char* key);


/// Returns how many functions didn't load
int d_game_LoadDLL(HMODULE lib);