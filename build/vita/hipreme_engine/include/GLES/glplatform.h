#ifndef __drvglplatform_h_
#define __drvglplatform_h_

#ifdef __cplusplus
extern "C" {
#endif

/*
 * This document is licensed under the SGI Free Software B License Version
 * 2.0. For details, see http://oss.sgi.com/projects/FreeB/ .
 */

/***********************************************************************
 *			This file was derived from 
 *			http://www.khronos.org/registry/gles/api/2.0/gl2platform.h
 *			on 23/06/10
 *                Subsequent changes are Copyright Imagination Technologies
 * Copyright    : Imagination Technologies Limited.
 ***********************************************************************/

/* Platform-specific types and definitions for OpenGL ES 1.X  gl.h
 *
 * Adopters may modify khrplatform.h and this file to suit their platform.
 * You are encouraged to submit all modifications to the Khronos group so that
 * they can be included in future versions of this file.  Please submit changes
 * by sending them to the public Khronos Bugzilla (http://khronos.org/bugzilla)
 * by filing a bug against product "OpenGL-ES" component "Registry".
 */

#include <KHR/khrplatform.h>

#ifndef GL_API
#define GL_API  	KHRONOS_APICALL
#endif

#ifndef GL_APIENTRY
#define GL_APIENTRY KHRONOS_APIENTRY
#endif

#if defined(__linux__)
#	define GL_API_EXT __attribute__((visibility("hidden")))
#else
#	define GL_API_EXT
#endif

#ifdef __cplusplus
}
#endif

#endif /* __drvglplatform_h_ */
