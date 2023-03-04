/*!****************************************************************************
@File           sgxtransfer_buffer.h

@Title         	Transfer queue circular buffer management 

@Author         Imagination Technologies

@date          	06/10/09 
 
@Copyright      Copyright 2009 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either
                material or conceptual may be copied or distributed,
                transmitted, transcribed, stored in a retrieval system
                or translated into any human or computer language in any
                form by any means, electronic, mechanical, manual or
                other-wise, or disclosed to third parties without the
                express written permission of Imagination Technologies
                Limited, Unit 8, HomePark Industrial Estate,
                King's Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform       Generic

@Description   	Transfer queue circular buffer management 

@DoxygenVer     

******************************************************************************/

/******************************************************************************
Modifications :-

$Log: sgxtransfer_buffer.h $
*****************************************************************************/

#ifndef _SGXTRANSFER_BUFFER_H_
#define _SGXTRANSFER_BUFFER_H_

#include "img_types.h"
#include "services.h"

#define SGXTQ_MAX_QUEUED_BLITS		32

typedef struct _SGXTQ_CB_PACKET_
{		
	IMG_UINT32		ui32FenceID;
	IMG_UINT32		ui32Roff;
#if defined(PDUMP)
	/* stuff we need to PDUMP the CB packet */
	IMG_UINT32		ui32Offset;
	IMG_UINT32		ui32PacketSize;
	IMG_BOOL		bWasDumped;
#endif
} SGXTQ_CB_PACKET;


typedef struct _SGXTQ_CB_
{
	IMG_UINT32				ui32Woff; 
	/* non-commited woff*/
	IMG_UINT32				ui32NCWoff;
	IMG_UINT32				ui32Roff;

	IMG_UINT32				ui32BufferSize;
	/* every packet or (non commited sub-packet) is aligned*/
	IMG_UINT32				ui32Alignment;
	IMG_BOOL				bAllowPageBr;

	PVRSRV_CLIENT_MEM_INFO* psBufferMemInfo;

	/* list of packets inserted into the Buffer */
	SGXTQ_CB_PACKET			asCBPackets[SGXTQ_MAX_QUEUED_BLITS];
	IMG_UINT32				ui32PacketRoff;
	IMG_UINT32				ui32PacketWoff;
	IMG_UINT32				ui32PacketNCWoff;

	/* small label for the buffer*/
	IMG_CHAR				*pbyLabel;

	PVRSRV_DEV_DATA			*psDevData;
} SGXTQ_CB;

PVRSRV_ERROR SGXTQ_CreateCB(PVRSRV_DEV_DATA		*psDevData,
							IMG_HANDLE hTQContext,
							IMG_UINT32	ui32CBSize,
							IMG_UINT32	ui32Alignment,
							IMG_BOOL	bAllowPageBr,
							IMG_BOOL	bAllowWrite,
#if defined (SUPPORT_SID_INTERFACE)
							IMG_SID		hDevMemHeap,
#else
							IMG_HANDLE	hDevMemHeap,
#endif
							IMG_CHAR	* pbyPDumpLabel,
							SGXTQ_CB	**ppsCB);

IMG_VOID SGXTQ_DestroyCB(IMG_HANDLE hTQContext,
						 SGXTQ_CB *psCB);


IMG_BOOL SGXTQ_AcquireCB(PVRSRV_CLIENT_MEM_INFO	* psFenceIDMemInfo,
									IMG_UINT32      ui32CurrentFence,
#if defined (SUPPORT_SID_INTERFACE)
									IMG_EVENTSID	hOSevent,
#else
									IMG_HANDLE	hOSevent,
#endif
									SGXTQ_CB      * psCB,
									IMG_UINT32      ui32Size,
									IMG_BOOL        bPreparedForWait,
									IMG_VOID      **ppvLinAddr,
									IMG_PUINT32     pui32DevVAddr,
									IMG_BOOL        bPDumpContinuous);

IMG_VOID SGXTQ_BeginCB(SGXTQ_CB					*psCB);

IMG_VOID SGXTQ_FlushCB(SGXTQ_CB					*psCB,
									IMG_BOOL	bPDumpContinuous);

typedef struct _SQXTQ_CLIENT_TRANSFER_CONTEXT_ *PSQXTQ_CLIENT_TRANSFER_CONTEXT;
#if defined(SUPPORT_KERNEL_SGXTQ)
PVRSRV_ERROR TQAllocDeviceMem(IMG_HANDLE hDevice,
							  IMG_HANDLE hHeap,
							  IMG_UINT32 ui32Flags,
							  IMG_UINT32 ui32Size,
							  IMG_UINT32 ui32Alignment,
							  PVRSRV_CLIENT_MEM_INFO **ppsMemInfo);
PVRSRV_ERROR TQFreeDeviceMem(IMG_HANDLE hDevice,
							 PVRSRV_CLIENT_MEM_INFO *psMemInfo);

#define ALLOCDEVICEMEM(Ctx, heap, flags, size, align, meminfo) TQAllocDeviceMem(((PSQXTQ_CLIENT_TRANSFER_CONTEXT) Ctx)->hCallbackHandle, heap, flags, size, align, meminfo)
#define FREEDEVICEMEM(Ctx, meminfo) TQFreeDeviceMem(((PSQXTQ_CLIENT_TRANSFER_CONTEXT)Ctx)->hCallbackHandle, meminfo)
#else
#define ALLOCDEVICEMEM(Ctx, heap, flags, size, align, meminfo) PVRSRVAllocDeviceMem(((PSQXTQ_CLIENT_TRANSFER_CONTEXT) Ctx)->psDevData, heap, flags, size, align, meminfo)
#define FREEDEVICEMEM(Ctx, meminfo) PVRSRVFreeDeviceMem(((PSQXTQ_CLIENT_TRANSFER_CONTEXT) Ctx)->psDevData, meminfo)
#endif

#endif /*_SGXTRANSFER_BUFFER_H_*/

/******************************************************************************
 End of file (sgxtransfer_buffer.h)
******************************************************************************/
