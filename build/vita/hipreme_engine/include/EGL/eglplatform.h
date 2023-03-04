/***********************************************************************
<module>
 * Name         : drveglplatform.h
 * Title        : Platform defines for EGL.
 * Author       : Ben Bowman
 * Created      : 7 Nov 2006
 *
 * Copyright    : 2003-2006 by Imagination Technologies Limited.
 *                All rights reserved. No part of this software, either
 *                material or conceptual may be copied or distributed,
 *                transmitted, transcribed, stored in a retrieval system
 *                or translated into any human or computer language in any
 *                form by any means, electronic, mechanical, manual or
 *                other-wise, or disclosed to third parties without the
 *                express written permission of Imagination Technologies
 *                Limited, Unit 8, HomePark Industrial Estate,
 *                King's Langley, Hertfordshire, WD4 8LZ, U.K.
 *
 * Description  : Type definitions exported by Khronos EGL.
 * 
 * Platform     : ALL
 *
 * $Log: drveglplatform.h $
 ***********************************************************************/

#ifndef _drveglplatform_h_
#define _drveglplatform_h_

#include "KHR/khrplatform.h"

#if !defined(IMG_EXPORT)
#define	IMG_EXPORT
#endif

/* Windows calling convention boilerplate */

#if defined(LINUX)
#include <stdint.h>
#else
typedef int int32_t;
#endif

/* Macros used in EGL function prototype declarations.
 *
 * EGL functions should be prototyped as:
 *
 * EGLAPI return-type EGLAPIENTRY eglFunction(arguments);
 * typedef return-type (EXPAPIENTRYP PFNEGLFUNCTIONPROC) (arguments);
 *
 * KHRONOS_APICALL and KHRONOS_APIENTRY are defined in KHR/khrplatform.h
 */

#ifndef EGLAPI
#define EGLAPI IMG_EXPORT
#endif

/* On Windows, EGLAPIENTRY can be defined like APIENTRY.
 * On most other platforms, it should be empty.
 */
#if defined(APIENTRY) && !defined(__psp2__)
#define EGLAPIENTRY APIENTRY
#else
#define EGLAPIENTRY
#endif

#define EGLAPIENTRYP EGLAPIENTRY*

/* The types NativeDisplayType, NativeWindowType, and NativePixmapType
 * are aliases of window-system-dependent types, such as X Display * or
 * Windows Device Context. They must be defined in platform-specific
 * code below. The EGL-prefixed versions of Native*Type are the same
 * types, renamed in EGL 1.3 so all types in the API start with "EGL".
 */
#if defined(SUPPORT_X11)

#include <X11/Xlib.h>

typedef Display* NativeDisplayType;
typedef Window NativeWindowType;
typedef Pixmap NativePixmapType;

#else

#if defined(SUPPORT_WINCEWS)

typedef HDC		NativeDisplayType;
typedef HWND	NativeWindowType;
typedef HBITMAP NativePixmapType;

#else

#if defined(__psp2__)

typedef enum Psp2DrawableType
{
	PSP2_DRAWABLE_TYPE_UNKNOWN,
	PSP2_DRAWABLE_TYPE_WINDOW,
	PSP2_DRAWABLE_TYPE_PIXMAP
} Psp2DrawableType;

typedef enum Psp2WindowSize
{
	PSP2_WINDOW_960X544,
	PSP2_WINDOW_480X272,
	PSP2_WINDOW_640X368,
	PSP2_WINDOW_720X408,
	PSP2_WINDOW_1280X725,
	PSP2_WINDOW_1920X1088
} Psp2WindowSize;

typedef struct Psp2NativeWindow
{
	unsigned int type;
	unsigned int windowSize;
	unsigned int numFlipBuffers;
	unsigned int flipChainThrdAffinity;

	unsigned int swapChainId;
	void *swapChain;
	void *psConnection;
	unsigned int ahSwapChainBuffers[4]; //PSP2_SWAPCHAIN_MAX_BUFFER_NUM
	void *apsSwapBufferMemInfo[4]; //PSP2_SWAPCHAIN_MAX_BUFFER_NUM
	void *psDevData;
	unsigned int hDevMemContext;
	unsigned int currBufIdx;
	unsigned int swapInterval;
} Psp2NativeWindow;

typedef struct Psp2NativePixmap
{
	Psp2DrawableType type;
	unsigned int sizeX;
	unsigned int sizeY;
	unsigned int memType;

	SceUID memUID;
	void *memBase;
	void *psDevData;
	unsigned int hDevMemContext;
} Psp2NativePixmap;

typedef int	NativeDisplayType;
typedef Psp2NativeWindow *NativeWindowType;
typedef Psp2NativePixmap *NativePixmapType;

#else

typedef int	 NativeDisplayType;
typedef void  *NativeWindowType;
typedef void *NativePixmapType;

#endif
#endif
#endif

/* EGL 1.2 types, renamed for consistency in EGL 1.3 */
typedef NativeDisplayType EGLNativeDisplayType;
typedef NativePixmapType EGLNativePixmapType;
typedef NativeWindowType EGLNativeWindowType;

/* Define EGLint. This must be a signed integral type large enough to contain
 * all legal attribute names and values passed into and out of EGL, whether
 * their type is boolean, bitmask, enumerant (symbolic constant), integer,
 * handle, or other.  While in general a 32-bit integer will suffice, if
 * handles are 64 bit types, then EGLint should be defined as a signed 64-bit
 * integer type.
 */
typedef khronos_int32_t EGLint;

#endif /* _drveglplatform_h_ */
