/*!****************************************************************************
@File           sgxutils_client.h

@Title          Device specific utility routines declarations

@Author         Imagination Technologies

@Date           15 / 5 / 06

@Copyright      Copyright 2006-2008 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either material
                or conceptual may be copied or distributed, transmitted,
                transcribed, stored in a retrieval system or translated into
                any human or computer language in any form by any means,
                electronic, mechanical, manual or otherwise, or disclosed
                to third parties without the express written permission of
                Imagination Technologies Limited, Home Park Estate,
                Kings Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform       Generic

@Description    Inline functions/structures specific to SGX

@DoxygenVer

******************************************************************************/

/******************************************************************************
Modifications :-
$Log: sgxutils_client.h $
******************************************************************************/

// FIXME:Services 4.0: There is some duplication between the contents
// of this file, and sgxutils.h in srvkm.


/*
	We use a buffer on the stack to contain a command followed by a
	variable number of registers.
	The SGXMKIF_CMDTA structure contains one PVRSRV_HWREG structure and is
	followed by more. The function Update3DRegs() writes these structures
	up to a maximum of NUM_3D_REGS_UPDATED.
*/
#define SGX_NUM_3D_REGS_UPDATED	46
#define SGX_TEMP_CMD_BUF_SIZE	(sizeof(SGXMKIF_CMDTA) + (SGX_NUM_3D_REGS_UPDATED-1) * sizeof(PVRSRV_HWREG))/sizeof(IMG_UINT32)

#define GET_CCB_SPACE(WOff, ROff, CCBSize) \
	((((ROff) - (WOff)) + ((CCBSize) - 1)) & ((CCBSize) - 1))

#define UPDATE_CCB_OFFSET(Off, PacketSize, CCBSize) \
	(Off) = (((Off) + (PacketSize)) & ((CCBSize) - 1))

/******************************************************************************
 FUNCTION	: SGXCalcContextCCBParamSize

 PURPOSE	: Calculate param size including alloc granularity limitation

 PARAMETERS	: ui32ParamSize - size of params structure

 RETURNS	: Tweaked CCB param size
******************************************************************************/
static INLINE IMG_UINT32 SGXCalcContextCCBParamSize(IMG_UINT32 ui32ParamSize, IMG_UINT32 ui32AllocGran)
{
	return (ui32ParamSize + (ui32AllocGran - 1)) & ~(ui32AllocGran - 1);
}

// FIXME: Services 4.0: Temporarily required by sgxkick.c
#define	CURRENT_CCB_OFFSET(psCCB) (*(psCCB)->pui32WriteOffset)

#if defined (PDUMP)
IMG_VOID DumpBufferArray(PSGX_KICKTA_DUMP_BUFFER	psBufferArray,
						 IMG_UINT32						ui32BufferArrayLength,
						 IMG_BOOL						bDumpPolls);
#endif



PVRSRV_ERROR CreateCCB(PVRSRV_DEV_DATA		*psDevData,
					   IMG_UINT32			ui32CCBSize,
					   IMG_UINT32			ui32AllocGran,
					   IMG_UINT32			ui32OverrunSize,
#if defined (SUPPORT_SID_INTERFACE)
					   IMG_SID				hDevMemHeap,
#else
					   IMG_HANDLE			hDevMemHeap,
#endif
					   SGX_CLIENT_CCB	**ppsCCB);

IMG_VOID DestroyCCB(PVRSRV_DEV_DATA *psDevData,
					SGX_CLIENT_CCB *psCCB);

#if defined (SUPPORT_SID_INTERFACE)
IMG_PVOID SGXAcquireCCB(PVRSRV_DEV_DATA *psDevData, SGX_CLIENT_CCB *psCCB, IMG_UINT32 ui32CmdSize, IMG_EVENTSID hOSEvent);
#else
IMG_PVOID SGXAcquireCCB(PVRSRV_DEV_DATA *psDevData, SGX_CLIENT_CCB *psCCB, IMG_UINT32 ui32CmdSize, IMG_HANDLE hOSEvent);
#endif

IMG_INTERNAL PVRSRV_ERROR AllocSharedMem(const PVRSRV_CONNECTION *psConnection,
										 IMG_UINT32 ui32Flags,
										 IMG_UINT32 ui32Size,
										 IMG_VOID **ppvCpuVAddrUM,
										 IMG_VOID **ppvCpuVAddrKM);

IMG_INTERNAL PVRSRV_ERROR FreeSharedMem(const PVRSRV_CONNECTION *psConnection,
										IMG_VOID *pvCpuVAddrUM);

/* TODO */
#define PVRSRVMapKernelMemInfoToClient(A,B) (PVRSRV_ERROR_NOT_SUPPORTED)

/******************************************************************************
 End of file (sgxutils_client.h)
******************************************************************************/
