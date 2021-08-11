#pragma once
#include "pch.h"

extern int  (*getMy50)();
extern int  (*init_D_runtime)();
extern char*(*concatenateStringFromCWRT)(char*);
extern void (*set_maps)(char* key, int value);
extern int  (*get_maps)(char* key);


/// Returns how many functions didn't load
int d_game_LoadDLL(HMODULE lib);