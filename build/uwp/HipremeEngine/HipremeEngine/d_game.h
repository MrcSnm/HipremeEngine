#pragma once
#include "pch.h"

extern void (*HipremeInit)();
extern int  (*HipremeMain)();
extern bool (*HipremeUpdate)();
extern void (*HipremeRender)();
extern void (*HipremeDestroy)();

//Input Related

extern void (*HipInputOnTouchPressed)(uint32_t id, float x, float y);
extern void (*HipInputOnTouchMoved)(uint32_t id, float x, float y);
extern void (*HipInputOnKeyDown)(uint32_t virtualKey);
extern void (*HipInputOnKeyUp)(uint32_t virtualKey);




/// Returns how many functions didn't load
int d_game_LoadDLL(HMODULE lib);