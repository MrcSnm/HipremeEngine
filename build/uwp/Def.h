#pragma once
#include "pch.h"

extern int  (*HipremeMain)();
extern bool (*HipremeUpdate)();
extern void (*HipremeDestroy)();

/// Returns how many functions didn't load
int d_game_LoadDLL(HMODULE lib);