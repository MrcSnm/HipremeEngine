#pragma once
#include "pch.h"

extern void (*HipremeInit)();
extern int  (*HipremeMain)();
extern bool (*HipremeUpdate)();
extern void (*HipremeRender)();
extern void (*HipremeDestroy)();



/// Returns how many functions didn't load
int d_game_LoadDLL(HMODULE lib);