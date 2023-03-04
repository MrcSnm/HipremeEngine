/******************************************************************************
 * Name         : drvgl2platform.h
 *
 * Copyright    : 2004-20010 by Imagination Technologies Limited.
 *              : All rights reserved. No part of this software, either
 *              : material or conceptual may be copied or distributed,
 *              : transmitted, transcribed, stored in a retrieval system or
 *              : translated into any human or computer language in any form
 *              : by form by any means, electronic, mechanical, manual or
 *              : otherwise, or disclosed to third parties without the 
 *              : express written permission of:
 *              : Imagination Technologies Limited, Home Park Estate,
 *              : Kings Langley, Hertfordshire, WD4 8LZ, U.K.
 *
 * $Log: drvgl2platform.h $
*****************************************************************************/
#ifndef __drvgl2platform_h_
#define __drvgl2platform_h_


#ifdef __cplusplus
extern "C" {
#endif

/*
 * This document is licensed under the SGI Free Software B License Version
 * 2.0. For details, see http://oss.sgi.com/projects/FreeB/ .
 */

/* Platform-specific types and definitions for OpenGL ES 2.X  gl2.h
 *
 * Adopters may modify khrplatform.h and this file to suit their platform.
 * You are encouraged to submit all modifications to the Khronos group so that
 * they can be included in future versions of this file.  Please submit changes
 * by sending them to the public Khronos Bugzilla (http://khronos.org/bugzilla)
 * by filing a bug against product "OpenGL-ES" component "Registry".
 */

#include <KHR/khrplatform.h>

#ifndef GL_APICALL
#define GL_APICALL  KHRONOS_APICALL
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

#endif /* __drvgl2platform_h_ */
