/*!****************************************************************************
@File           sgxapiperf.h

@Title          SGX API Header (Performance profiling)

@Author         Imagination Technologies

@Date           11/04/2007

@Copyright      Copyright 2007 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either material
                or conceptual may be copied or distributed, transmitted,
                transcribed, stored in a retrieval system or translated into
                any human or computer language in any form by any means,
                electronic, mechanical, manual or otherwise, or disclosed
                to third parties without the express written permission of
                Imagination Technologies Limited, Home Park Estate,
                Kings Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform       Cross platform / environment

@Description    Exported SGX API details

@DoxygenVer

******************************************************************************/
/******************************************************************************
Modifications :-
$Log: sgxapiperf.h $
,
 --- Revision Logs Removed --- 
******************************************************************************/

#ifndef __SGXAPIPERF_H__
#define __SGXAPIPERF_H__

#if defined (__cplusplus)
extern "C" {
#endif

#include "services.h"
#if defined (SUPPORT_SID_INTERFACE)
#include "sgxapi_km.h"
#endif

/****************************************************************************/
/* Performance registers													*/
/****************************************************************************/

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXReadHWPerfCB(PVRSRV_DEV_DATA				*psDevData,
										  IMG_UINT32					ui32ArraySize,
										  PVRSRV_SGX_HWPERF_CB_ENTRY	*psHWPerfCBData,
										  IMG_UINT32					*pui32DataCount,
										  IMG_UINT32					*pui32ClockSpeed,
										  IMG_UINT32					*pui32HostTimeStamp);

#if defined (__cplusplus)
}
#endif

#endif /* __SGXAPIPERF_H__ */

/******************************************************************************
 End of file (sgxapiperf.h)
******************************************************************************/
