/******************************************************************************
* Name         : pvr_debug.h
* Title        : PVR Debug Declarations
* Author       : J R Morrissey
* Created      : 20 May 2002
*
* Copyright    : 2002-2008 by Imagination Technologies Limited.
*                All rights reserved. No part of this software, either
*                material or conceptual may be copied or distributed,
*                transmitted, transcribed, stored in a retrieval system
*                or translated into any human or computer language in any
*                form by any means, electronic, mechanical, manual or
*                otherwise, or disclosed to third parties without the
*                express written permission of
*                Imagination Technologies Limited, Home Park Estate,
*                Kings Langley, Hertfordshire, WD4 8LZ, U.K.
*
* Description  : Provides debug functionality
*
* Platform     : Generic
*
* Modifications:-
* $Log: pvr_debug.h $
******************************************************************************/

#ifndef __PVR_DEBUG_H__
#define __PVR_DEBUG_H__


#include "img_types.h"

#if defined (__cplusplus)
extern "C" {
#endif

#define PVR_MAX_DEBUG_MESSAGE_LEN	(512)

/* These are privately used by pvr_debug, use the PVR_DBG_ defines instead */
#define DBGPRIV_FATAL			0x01UL
#define DBGPRIV_ERROR			0x02UL
#define DBGPRIV_WARNING			0x04UL
#define DBGPRIV_MESSAGE			0x08UL
#define DBGPRIV_VERBOSE			0x10UL
#define DBGPRIV_CALLTRACE		0x20UL
#define DBGPRIV_ALLOC			0x40UL
#define DBGPRIV_DBGDRV_MESSAGE  0x80UL

#if !defined(PVRSRV_NEED_PVR_ASSERT) && defined(DEBUG)
#define PVRSRV_NEED_PVR_ASSERT
#endif

#if defined(PVRSRV_NEED_PVR_ASSERT) && !defined(PVRSRV_NEED_PVR_DPF)
#define PVRSRV_NEED_PVR_DPF
#endif

#if !defined(PVRSRV_NEED_PVR_TRACE) && (defined(DEBUG) || defined(TIMING))
#define PVRSRV_NEED_PVR_TRACE
#endif

/* PVR_ASSERT() and PVR_DBG_BREAK handling */

#if defined(PVRSRV_NEED_PVR_ASSERT)

	#define PVR_ASSERT(EXPR) if (!(EXPR)) PVRSRVDebugAssertFail(__FILE__, __LINE__);

IMG_IMPORT IMG_VOID IMG_CALLCONV PVRSRVDebugAssertFail(const IMG_CHAR *pszFile,
													   IMG_UINT32 ui32Line);

			#define PVR_DBG_BREAK	PVRSRVDebugAssertFail(__FILE__, __LINE__)

#else  /* defined(PVRSRV_NEED_PVR_ASSERT) */

	#define PVR_ASSERT(EXPR)
	#define PVR_DBG_BREAK

#endif /* defined(PVRSRV_NEED_PVR_ASSERT) */


/* PVR_DPF() handling */

#if defined(PVRSRV_NEED_PVR_DPF)

#if defined(PVRSRV_NEW_PVR_DPF)

	/* New logging mechanism */
	#define PVR_DBG_FATAL		DBGPRIV_FATAL
	#define PVR_DBG_ERROR		DBGPRIV_ERROR
	#define PVR_DBG_WARNING		DBGPRIV_WARNING
	#define PVR_DBG_MESSAGE		DBGPRIV_MESSAGE
	#define PVR_DBG_VERBOSE		DBGPRIV_VERBOSE
	#define PVR_DBG_CALLTRACE	DBGPRIV_CALLTRACE
	#define PVR_DBG_ALLOC		DBGPRIV_ALLOC
	#define PVR_DBGDRIV_MESSAGE	DBGPRIV_DBGDRV_MESSAGE

	/* These levels are always on with PVRSRV_NEED_PVR_DPF */
	#define __PVR_DPF_0x01UL(x...) PVRSRVDebugPrintf(DBGPRIV_FATAL, x)
	#define __PVR_DPF_0x02UL(x...) PVRSRVDebugPrintf(DBGPRIV_ERROR, x)

	/* Some are compiled out completely in release builds */
#if defined(DEBUG)
	#define __PVR_DPF_0x04UL(x...) PVRSRVDebugPrintf(DBGPRIV_WARNING, x)
	#define __PVR_DPF_0x08UL(x...) PVRSRVDebugPrintf(DBGPRIV_MESSAGE, x)
	#define __PVR_DPF_0x10UL(x...) PVRSRVDebugPrintf(DBGPRIV_VERBOSE, x)
	#define __PVR_DPF_0x20UL(x...) PVRSRVDebugPrintf(DBGPRIV_CALLTRACE, x)
	#define __PVR_DPF_0x40UL(x...) PVRSRVDebugPrintf(DBGPRIV_ALLOC, x)
	#define __PVR_DPF_0x80UL(x...) PVRSRVDebugPrintf(DBGPRIV_DBGDRV_MESSAGE, x)
#else
	#define __PVR_DPF_0x04UL(x...)
	#define __PVR_DPF_0x08UL(x...)
	#define __PVR_DPF_0x10UL(x...)
	#define __PVR_DPF_0x20UL(x...)
	#define __PVR_DPF_0x40UL(x...)
	#define __PVR_DPF_0x80UL(x...)
#endif

	/* Translate the different log levels to separate macros
	 * so they can each be compiled out.
	 */
#if defined(DEBUG)
	#define __PVR_DPF(lvl, x...) __PVR_DPF_ ## lvl (__FILE__, __LINE__, x)
#else
	#define __PVR_DPF(lvl, x...) __PVR_DPF_ ## lvl ("", 0, x)
#endif

	/* Get rid of the double bracketing */
	#define PVR_DPF(x) __PVR_DPF x

#else /* defined(PVRSRV_NEW_PVR_DPF) */

	/* Old logging mechanism */
	#define PVR_DBG_FATAL		DBGPRIV_FATAL,__FILE__, __LINE__
	#define PVR_DBG_ERROR		DBGPRIV_ERROR,__FILE__, __LINE__
	#define PVR_DBG_WARNING		DBGPRIV_WARNING,__FILE__, __LINE__
	#define PVR_DBG_MESSAGE		DBGPRIV_MESSAGE,__FILE__, __LINE__
	#define PVR_DBG_VERBOSE		DBGPRIV_VERBOSE,__FILE__, __LINE__
	#define PVR_DBG_CALLTRACE	DBGPRIV_CALLTRACE,__FILE__, __LINE__
	#define PVR_DBG_ALLOC		DBGPRIV_ALLOC,__FILE__, __LINE__
	#define PVR_DBGDRIV_MESSAGE	DBGPRIV_DBGDRV_MESSAGE, "", 0

	#define PVR_DPF(X)			PVRSRVDebugPrintf X

#endif /* defined(PVRSRV_NEW_PVR_DPF) */

IMG_IMPORT IMG_VOID IMG_CALLCONV PVRSRVDebugPrintf(IMG_UINT32 ui32DebugLevel,
												   const IMG_CHAR *pszFileName,
												   IMG_UINT32 ui32Line,
												   const IMG_CHAR *pszFormat,
												   ...) IMG_FORMAT_PRINTF(4, 5);

#else  /* defined(PVRSRV_NEED_PVR_DPF) */

	#define PVR_DPF(X)

#endif /* defined(PVRSRV_NEED_PVR_DPF) */


/* PVR_TRACE() handling */

#if defined(PVRSRV_NEED_PVR_TRACE)

	#define PVR_TRACE(X)	PVRSRVTrace X

IMG_IMPORT IMG_VOID IMG_CALLCONV PVRSRVTrace(const IMG_CHAR* pszFormat, ... )
	IMG_FORMAT_PRINTF(1, 2);

#else /* defined(PVRSRV_NEED_PVR_TRACE) */

	#define PVR_TRACE(X)

#endif /* defined(PVRSRV_NEED_PVR_TRACE) */


#if defined (__cplusplus)
}
#endif

#endif	/* __PVR_DEBUG_H__ */

/******************************************************************************
 End of file (pvr_debug.h)
******************************************************************************/

