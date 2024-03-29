#pragma once
#include "pch.h"
#include "Def.h"

extern void (*HipremeInit)();
extern int  (*HipremeMain)();
extern bool (*HipremeUpdate)();
extern void (*HipremeRender)();
extern void (*HipremeDestroy)();

//Input Related

extern void (*HipInputOnTouchPressed)(uint32_t id, float x, float y);
extern void (*HipInputOnTouchMoved)(uint32_t id, float x, float y);
extern void (*HipInputOnTouchReleased)(uint32_t id, float x, float y);
extern void (*HipInputOnTouchScroll)(float x, float y, float z);
extern void (*HipInputOnKeyDown)(uint32_t virtualKey);
extern void (*HipInputOnKeyUp)(uint32_t virtualKey);

//Gamepad

extern void (*HipInputOnGamepadConnected)(ubyte id, ubyte type);
extern void (*HipInputOnGamepadDisconnected)(ubyte id, ubyte type);



/// Returns how many functions didn't load
int d_game_LoadDLL(HMODULE lib);