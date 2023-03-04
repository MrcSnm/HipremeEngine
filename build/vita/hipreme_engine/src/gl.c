#include <psp2/kernel/modulemgr.h>
#include <psp2/kernel/clib.h>
#include <assert.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include <gpu_es4/psp2_pvr_hint.h>

/**
 * Now we can create an EGL Context
*/
void initializeVitaGL()
{
	sceKernelLoadStartModule("vs0:sys/external/libfios2.suprx", 0, NULL, 0, NULL, NULL);
	sceKernelLoadStartModule("vs0:sys/external/libc.suprx", 0, NULL, 0, NULL, NULL);
	sceKernelLoadStartModule("app0:module/libgpu_es4_ext.suprx", 0, NULL, 0, NULL, NULL);
	sceKernelLoadStartModule("app0:module/libIMGEGL.suprx", 0, NULL, 0, NULL, NULL);

	PVRSRV_PSP2_APPHINT hint;
	if(!PVRSRVInitializeAppHint(&hint))
	{
		sceClibPrintf("Could not initialize VGLES 2\n");
		assert(0);
	}
	if(!PVRSRVCreateVirtualAppHint(&hint))
	{
		sceClibPrintf("Could create virtual app hint for VGLES 2\n");
		assert(0);
	}
}

EGLDisplay Display;
EGLConfig Config;
EGLSurface Surface;
EGLContext Context;
EGLint NumConfigs, MajorVersion, MinorVersion;
EGLint ConfigAttr[] =
{
	EGL_BUFFER_SIZE, EGL_DONT_CARE,
	EGL_DEPTH_SIZE, 16,
	EGL_RED_SIZE, 8,
	EGL_GREEN_SIZE, 8,
	EGL_BLUE_SIZE, 8,
	EGL_ALPHA_SIZE, 8,
	EGL_STENCIL_SIZE, 8,
	EGL_SURFACE_TYPE, 5,
	EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
	EGL_NONE
};
EGLint ContextAttributeList[] = 
{
	EGL_CONTEXT_CLIENT_VERSION, 2,
	EGL_NONE
};
void EGLInit(int* width, int* height)
{
	EGLBoolean Res;
	Display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	if(!Display)
	{
		sceClibPrintf("EGL display get failed.\n");
		return;
	}

	Res = eglInitialize(Display, &MajorVersion, &MinorVersion);
	if (Res == EGL_FALSE)
	{
		sceClibPrintf("EGL initialize failed.\n");
		return;
	}

	//PIB cube demo
	eglBindAPI(EGL_OPENGL_ES_API);

	Res = eglChooseConfig(Display, ConfigAttr, &Config, 1, &NumConfigs);
	if (Res == EGL_FALSE)
	{
		sceClibPrintf("EGL config initialize failed.\n");
		return;
	}

	Surface = eglCreateWindowSurface(Display, Config, (EGLNativeWindowType)0, (void*)0);
	if(!Surface)
	{
		sceClibPrintf("EGL surface create failed.\n");
		return;
	}

	Context = eglCreateContext(Display, Config, EGL_NO_CONTEXT, ContextAttributeList);
	if(!Context)
	{
		sceClibPrintf("EGL content create failed.\n");
		return;
	}

	eglMakeCurrent(Display, Surface, Surface, Context);

	// PIB cube demo
	eglQuerySurface(Display, Surface, EGL_WIDTH, width);
	eglQuerySurface(Display, Surface, EGL_HEIGHT, height);
	sceClibPrintf("Surface Width: %d, Surface Height: %d\n", *width, *height);
	glClearColor(0.0f,0.0f,0.0f,1.0f); // You can change the clear color to whatever
	sceClibPrintf("EGL init OK.\n");
}

void EGLEnd()
{
	eglDestroySurface(Display, Surface);
  	eglDestroyContext(Display, Context);
  	eglTerminate(Display);
	sceClibPrintf("EGL terminated.\n");
}

void hipVitaSwapBuffers()
{
	eglSwapBuffers(Display, Surface);
}
