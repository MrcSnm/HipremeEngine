#include <psp2/kernel/threadmgr.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/clib.h>
#include <psp2/types.h>
#include <psp2/ime_dialog.h>
#include <psp2/sysmodule.h>
#include <psp2/touch.h>
#include <psp2/ctrl.h>


#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <pthread.h>

#include "debugScreen.h"

extern char* getDebugInfo();
extern char* getDebugInfoFromApp();

#define MAX_PATH 256

unsigned int sceLibcHeapSize = 32 * 1024 * 1024;
int _newlib_heap_size_user   = 64 * 1024 * 1024;


void hipVitaPrint(size_t sz, const char* str)
{
	sceClibPrintf("%.*s\n", sz, str);
}

uint64_t get_psv_time()
{
	SceKernelSysClock clock;
	if(sceKernelGetProcessTime(&clock) == 0)
		return clock;
	return 0;
}

float longToFloat(int64_t v ){ return (float) v;}
float ulongToFloat(uint64_t v){ return (float) v;}

double longToDouble(int64_t v) { return (double) v; }
double ulongToDouble(uint64_t v) { return (double) v; }


void initializeVitaGL();
void EGLInit(int* width, int* height);
void EGLEnd();
void hipVitaSwapBuffers();
void psv_abort();


void initializeVitaInput()
{
	sceCtrlSetSamplingMode(SCE_CTRL_MODE_ANALOG);

	sceTouchSetSamplingState(SCE_TOUCH_PORT_FRONT, SCE_TOUCH_SAMPLING_STATE_START);
	sceTouchSetSamplingState(SCE_TOUCH_PORT_BACK, SCE_TOUCH_SAMPLING_STATE_START);
	sceTouchEnableTouchForce(SCE_TOUCH_PORT_FRONT);
	sceTouchEnableTouchForce(SCE_TOUCH_PORT_BACK);
}


typedef struct HipInputPSVGamepadState
{
    unsigned int buttons;
    unsigned char leftAnalog[2]; ///X, Y
    unsigned char rightAnalog[2]; ///X, Y
} HipInputPSVGamepadState;


enum HipGamepadTypes
{
	HipGamepadTypes_xbox,
	HipGamepadTypes_psvita,
};

void HipInputOnGamepadConnected(unsigned char id, unsigned char type);

void hipVitaPollGamepad(HipInputPSVGamepadState* state)
{
	SceCtrlData padData;
	if(sceCtrlPeekBufferPositive(0, &padData, 1) < 0)
	{
		sceClibPrintf("Error while reading Vita Gamepad\n");
		psv_abort();
	}

	state->buttons = padData.buttons;
	state->leftAnalog[0] = padData.lx;
	state->leftAnalog[1] = padData.ly;
	state->rightAnalog[0] = padData.rx;
	state->rightAnalog[1] = padData.ry;
}



///Function required to check if memory is in heap to being able to reallocate.
void psv_init_mem();

void HipremeInit();
int HipremeMain(int width, int height);
void HipremeRender();

unsigned char HipremeUpdate(float dt);
int VITA_ShowMessageBoxStr(const char* title, const char* msg);

//This function is called from D's main
void hipVitaPollTouch();
int main(int argc, char* argv)
{
	psv_init_mem();
	psvDebugScreenInit();
	initializeVitaGL();
	int width, height;

	EGLInit(&width, &height);

	initializeVitaInput();

	HipremeMain(width, height);
	HipInputOnGamepadConnected(0,HipGamepadTypes_psvita);
	while(1)
	{
		hipVitaPollTouch();
		if(!HipremeUpdate(0.016)) break;
		HipremeRender();
		hipVitaSwapBuffers();
	}
	EGLEnd();
	sceKernelExitProcess(0);
	return 0;
}
