/*!****************************************************************************
@File           sgxtransfer_client.h

@Title          Device specific transfer queue routines

@Author         Imagination Technologies

@date           08/02/06
 
@Copyright      Copyright 2007-2010 by Imagination Technologies Limited.
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

@Description    Device specific functions

@DoxygenVer

******************************************************************************/

/******************************************************************************
Modifications :-

$Log: sgxtransfer_client.h $

*****************************************************************************/

#ifndef _SGXTRANSFER_CLIENT_H_
#define _SGXTRANSFER_CLIENT_H_
#if defined(TRANSFER_QUEUE)

#include "sgxtransfer_buffer.h"

/* Stuff only accessible by the client (which the kernel will not touch) */

#ifndef ALIGNFIELD
#define ALIGNFIELD(V, A)			(((V) + ((1UL << (A)) - 1)) >> (A))
#endif

/* returns FALSE if not aligned*/
#define ISALIGNED(V, A)				(((V) & ((1UL << (A)) - 1)) == 0)
/* checks if value doesn't have bits at the bottom part shifted out by alignshift*/
#define CHECKBITSNOTLOST(V, A)		PVR_ASSERT(ISALIGNED(V, A))
/* checks if value fits into the bitfield marked by the clearmask*/
#define CHECKOVERFLOW(V, CLRM, SH)	PVR_ASSERT(((V) & (~((~(CLRM)) >> (SH)))) == 0)


/* PRQA S 0881 4 */ /* ignore 'order of evaluation' warning */
#define ACCUMLATESET(state, val, sel)									\
	(state) &= (sel##_CLRMSK);											\
	PVR_ASSERT(((val) & (~((~sel##_CLRMSK) >> (sel##_SHIFT)))) == 0);	\
	(state) |= (val) << (sel##_SHIFT)

/* PRQA S 0881 4 */ /* ignore 'order of evaluation' warning */
#define ACCUMLATESETNS(state, val, sel)									\
	(state) &= (sel##_CLRMSK);											\
	PVR_ASSERT(((val) & (sel##_CLRMSK)) == 0);							\
	(state) |= (val)


#define FLOAT32_ONE     0x3f800000
#define FLOAT32_HALF    0x3f000000
#define FIXEDPT_FRAC	20

/* number of bits in a pixel per plane - for planar formats only*/
#define SGXTQ_BITS_IN_PLANE			32
/* number of maximal number of passes for a multi-chunk format*/
#define SGXTQ_MAX_CHANCHUNKS		8

/* hw bg objects starting with 0 input layer up to this -1*/
#define SGXTQ_NUM_HWBGOBJS			4

#if SGXTQ_MAX_SURFACES >= SGXTQ_NUM_HWBGOBJS
#error Client API supports more texture layers than the TQ.
#endif

#define SGXTQ_MAX_DIRECT_ATTRIBUTES	7

/* max number of rects whose F2D ISP stream can fit into CB. */
#define SGXTQ_MAX_F2DRECTS          51

#define SGXTQ_PDS_CODE_GRANULARITY	(1UL << EURASIA_PDS_BASEADD_ALIGNSHIFT)
#define SGXTQ_PDS_CODE_AVERAGE_SIZE	(200UL / SGXTQ_PDS_CODE_GRANULARITY)
#define	SGXTQ_PDS_CODE_CBSIZE		SGXTQ_PDS_CODE_AVERAGE_SIZE * SGXTQ_MAX_QUEUED_BLITS * SGXTQ_PDS_CODE_GRANULARITY

#define SGXTQ_PDSPRIMFRAG_SINGLESOURCE_INSTANCENUM 16

#define SGXTQ_USSE_CODE_GRANULARITY	EURASIA_PDS_DOUTU_PHASE_START_ALIGN
#define SGXTQ_USSE_CODE_AVERAGE_SIZE	(64UL / SGXTQ_USSE_CODE_GRANULARITY)
#define	SGXTQ_USSE_CODE_CBSIZE		SGXTQ_USSE_CODE_AVERAGE_SIZE * SGXTQ_USSE_CODE_GRANULARITY * SGXTQ_MAX_QUEUED_BLITS

/* as this is huge, only allocate 4 instances. this means that we can't queue
 * 5 subtwiddled blits without doing a submit
 */
#define SGXTQ_USEEOTHANDLER_SUBTWIDDLED_INSTANCENUM	4

/* TODO : move corresponding define into hwdefs */
#define SGXTQ_ISP_STREAM_GRANULARITY	(16 * sizeof(IMG_UINT32))
/* we need at least as big as the F2D with the maximum no of
 * cliprects in clipblit - the average is way below that ; this
 * should be consistent with the Fast 2D ISP stream writer function
 * on roundings we go one step further than needed*/
#define SGXTQ_ISP_MAX_BATCHES			((SGXTQ_MAX_F2DRECTS + 4) >> 2)
#if defined(SGX545)
#define SGXTQ_ISP_STREAM_AVERAGE_SIZE	((4 * SGXTQ_ISP_MAX_BATCHES + 2 * SGXTQ_MAX_F2DRECTS) \
										* sizeof(IMG_UINT32) / SGXTQ_ISP_STREAM_GRANULARITY)
#else
#define SGXTQ_ISP_STREAM_AVERAGE_SIZE	((2 + 10 * SGXTQ_ISP_MAX_BATCHES + 17 * SGXTQ_MAX_F2DRECTS) \
										* sizeof(IMG_UINT32) / SGXTQ_ISP_STREAM_GRANULARITY)
#endif
#define	SGXTQ_ISP_STREAM_CBSIZE		SGXTQ_ISP_STREAM_GRANULARITY * SGXTQ_ISP_STREAM_AVERAGE_SIZE * SGXTQ_MAX_QUEUED_BLITS


#if ((16 == EURASIA_ISPREGION_SIZEX && 16 == EURASIA_ISPREGION_SIZEY && EURASIA_TAPDSSTATE_PIPECOUNT == 2) ||	\
    (32 == EURASIA_ISPREGION_SIZEX && 32 == EURASIA_ISPREGION_SIZEY && EURASIA_TAPDSSTATE_PIPECOUNT == 4)) &&	\
	! (defined(FIX_HW_BRN_23615) && defined(FIX_HW_BRN_23070)) &&												\
	! defined(FIX_HW_BRN_26361) &&																				\
	! defined(FIX_HW_BRN_28825)
#define SGXTQ_SUBTILE_TWIDDLING
#if ! defined(FIX_HW_BRN_30842)
#define SGXTQ_SUBTWIDDLED_TMP6_2PIPE_MODE_MASK	(1UL<<31)
#define SGXTQ_SUBTWIDDLED_TMP6_DIRECTION_X_MASK	(1UL<<30)
#define SGXTQ_SUBTWIDDLED_TMP6_FBADDR_MOVE_MASK	0x0fffffff

#define SGXTQ_SUBTWIDDLED_TMP7_U_MASK			0xffff0000	
#define SGXTQ_SUBTWIDDLED_TMP7_U_SHIFT			16	
#define SGXTQ_SUBTWIDDLED_TMP7_V_MASK			0x0000ffff
#define SGXTQ_SUBTWIDDLED_TMP7_V_SHIFT			0	
#endif
#endif

#define SGXTQ_STAGINGBUFFER_ALLOC_GRAN	(1UL << EURASIA_PDS_DOUTT2_TEXADDR_ALIGNSHIFT)
#define SGXTQ_STAGINGBUFFER_MIN_SIZE	((EURASIA_ISPREGION_SIZEY * EURASIA_RENDERSIZE_MAXX * 4) + SGXTQ_STAGINGBUFFER_ALLOC_GRAN) // 4 = BytesPerPixel

typedef IMG_UINT32 IMG_UFIXED;

/* Defines used to determine heaps used for allocations */
	#define SGXTQ_SYNCINFO_HEAP_ID	SGX_SYNCINFO_HEAP_ID
	#define SGXTQ_PDS_HEAP_ID 		SGX_PDSPIXEL_CODEDATA_HEAP_ID
	#define SGXTQ_USSE_HEAP_ID		SGX_PIXELSHADER_HEAP_ID
	#define SGXTQ_KERNEL_DATA_ID	SGX_KERNEL_DATA_HEAP_ID
	#define SGXTQ_BGOBJ_HEAP_ID		SGX_GENERAL_HEAP_ID
	#if defined(SGX_FEATURE_2D_HARDWARE)
		#define SGXTQ_BUFFER_HEAP_ID	SGX_2D_HEAP_ID
	#else
		#define SGXTQ_BUFFER_HEAP_ID	SGX_GENERAL_HEAP_ID
	#endif

/* Defines used to determine the base register for the USE code */
#define SGXTQ_USE_CODE_BASE_INDEX	SGX_PIXSHADER_USE_CODE_BASE_INDEX

#if defined(PDUMP) && defined(DEBUG)
#define SGXTQ_DEBUG_PDUMP_TQINPUT 1
#endif

typedef struct _SGXTQ_HEAP_INFO_
{
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID hSyncMemHeap;
	IMG_SID hPDSMemHeap;
	IMG_SID hUSEMemHeap;
	IMG_SID hCtrlMemHeap;
	IMG_SID hParamMemHeap;
	IMG_SID hBufferMemHeap;
#else	
	IMG_HANDLE hSyncMemHeap;
	IMG_HANDLE hPDSMemHeap;
	IMG_HANDLE hUSEMemHeap;
	IMG_HANDLE hCtrlMemHeap;
	IMG_HANDLE hParamMemHeap;
	IMG_HANDLE hBufferMemHeap;
#endif	
} SGXTQ_HEAP_INFO;


/* includes full layer info with TAG & ITERATORS states*/
typedef struct _SGXTQ_LAYER_
{
	IMG_UINT32 aui32TAGState[EURASIA_TAG_TEXTURE_STATE_SIZE];
	IMG_UINT32 aui32ITERState[EURASIA_PDS_DOUTI_STATE_SIZE];
} SGXTQ_LAYER;


typedef struct _SGXTQ_PDS_UPDATE__
{
	/* USSE kick */
	IMG_UINT32	ui32U0;
	IMG_UINT32	ui32U1;
	IMG_UINT32	ui32U2;
#if defined(SGX_FEATURE_UNIFIED_TEMPS_AND_PAS)
	IMG_UINT32	ui32TempRegs;
#endif

	/* the input layer stack, list of TAG/ITERATORS states*/
	SGXTQ_LAYER	asLayers[SGXTQ_NUM_HWBGOBJS - 1];

	/* used in secondaries to pass args to the shader*/
	IMG_UINT32	aui32A[SGXTQ_MAX_DIRECT_ATTRIBUTES];

	/* DMA */
	IMG_UINT32	ui32D0;
	IMG_UINT32	ui32D1;
	IMG_UINT32	ui32DMASize;

} SGXTQ_PDS_UPDATE;


/*
 * used for multi layered HW BGObjs
 */
typedef struct _SGXTQ_TSP_COORDS__
{
	/* layer 0*/
	IMG_UINT32 ui32Src0U0;
	IMG_UINT32 ui32Src0U1;
	IMG_UINT32 ui32Src0V0;
	IMG_UINT32 ui32Src0V1;

	/* layer 1*/
	IMG_UINT32 ui32Src1U0;
	IMG_UINT32 ui32Src1U1;
	IMG_UINT32 ui32Src1V0;
	IMG_UINT32 ui32Src1V1;

	/* layer 2*/
	IMG_UINT32 ui32Src2U0;
	IMG_UINT32 ui32Src2U1;
	IMG_UINT32 ui32Src2V0;
	IMG_UINT32 ui32Src2V1;
} SGXTQ_TSP_COORDS;


/* used for single layered real geometries
 * (rasterized from the same slice of src)
 */
typedef struct _SGXTQ_TSP_SINGLE_
{
	/* single set of TSP floats*/ 
	IMG_UINT32		ui32Src0U0;
	IMG_UINT32		ui32Src0U1;
	IMG_UINT32		ui32Src0V0;
	IMG_UINT32		ui32Src0V1;
	
} SGXTQ_TSP_SINGLE;

typedef struct _SGXTQ_SURF_DESC__
{
	SGXTQ_SURFACE*	psSurf;
	IMG_RECT*		psRect;
	IMG_UINT32		ui32DevVAddr;
	IMG_UINT32		ui32Width;
	IMG_UINT32		ui32Height;
	IMG_UINT32		ui32LineStride;
	IMG_UINT32		ui32BytesPerPixel;

	/* used only if it's input*/
	IMG_UINT32		ui32TAGFormat;

	/* used only if it's output*/
	IMG_UINT32		ui32PBEPackMode;
} SGXTQ_SURF_DESC;

typedef enum _SGXTQ_USEFRAGS_
{
    SGXTQ_USEBLIT_NORMAL = 0,
#if ! defined(SGX_FEATURE_USE_VEC34)
    SGXTQ_USEBLIT_STRIDE,
    SGXTQ_USEBLIT_STRIDE_HIGHBPP,
#endif
    SGXTQ_USEBLIT_FILL,
	SGXTQ_USEBLIT_A2R10G10B10,
	SGXTQ_USEBLIT_A2B10G10R10,
#if !defined(SGX_FEATURE_USE_VEC34)
	SGXTQ_USEBLIT_SRGB,
#endif

#if defined(EURASIA_PDS_DOUTT0_CHANREPLICATE)
	SGXTQ_USEBLIT_A8,
#endif

	SGXTQ_USEBLIT_ROP_NOTSANDNOTD,
	SGXTQ_USEBLIT_ROP_NOTSANDD,
	SGXTQ_USEBLIT_ROP_NOTS,
	SGXTQ_USEBLIT_ROP_SANDNOTD,
	SGXTQ_USEBLIT_ROP_NOTD,
	SGXTQ_USEBLIT_ROP_SXORD,
	SGXTQ_USEBLIT_ROP_NOTSORNOTD,
	SGXTQ_USEBLIT_ROP_SANDD,
	SGXTQ_USEBLIT_ROP_NOTSXORD,
	SGXTQ_USEBLIT_ROP_D,
	SGXTQ_USEBLIT_ROP_NOTSORD,
	SGXTQ_USEBLIT_ROP_S,
	SGXTQ_USEBLIT_ROP_SORNOTD,
	SGXTQ_USEBLIT_ROP_SORD,

	SGXTQ_USEBLIT_SRC_BLEND,
	SGXTQ_USEBLIT_ACCUM_SRC_BLEND,
	SGXTQ_USEBLIT_PREMULSRC_BLEND,
	SGXTQ_USEBLIT_GLOBAL_BLEND,
	SGXTQ_USEBLIT_PREMULSRCWITHGLOBAL_BLEND,
	SGXTQ_USEBLIT_ROPFILL_AND,
	SGXTQ_USEBLIT_ROPFILL_ANDNOT,
	SGXTQ_USEBLIT_ROPFILL_NOTAND,
	SGXTQ_USEBLIT_ROPFILL_XOR,
	SGXTQ_USEBLIT_ROPFILL_OR,
	SGXTQ_USEBLIT_ROPFILL_NOTANDNOT,
	SGXTQ_USEBLIT_ROPFILL_NOTXOR,
	SGXTQ_USEBLIT_ROPFILL_ORNOT,
	SGXTQ_USEBLIT_ROPFILL_NOT,
	SGXTQ_USEBLIT_ROPFILL_NOTOR,
	SGXTQ_USEBLIT_ROPFILL_NOTORNOT,
	SGXTQ_USEBLIT_ROPFILL_NOTD,
#if ! defined(SGX_FEATURE_USE_VEC34)
	SGXTQ_USEBLIT_LUT256,
	SGXTQ_USEBLIT_LUT16,
	SGXTQ_USEBLIT_LUT2,
#endif /* SGX_FEATURE_USE_VEC34*/

	SGXTQ_USEBLIT_SOURCE_COLOUR_KEY,
	SGXTQ_USEBLIT_DEST_COLOUR_KEY,

    SGXTQ_USEBLIT_VIDEOPROCESSBLIT_3PLANAR,
    SGXTQ_USEBLIT_VIDEOPROCESSBLIT_2PLANAR,
    SGXTQ_USEBLIT_VIDEOPROCESSBLIT_PACKED,
	SGXTQ_USEBLIT_CLEARTYPEBLEND_GAMMA,
	SGXTQ_USEBLIT_CLEARTYPEBLEND_INVALIDGAMMA,

	SGXTQ_USESECONDARY_UPDATE,
	SGXTQ_USESECONDARY_UPDATE_DMA,

	SGXTQ_USEBLIT_ARGB2NV12_Y_PLANE,
	SGXTQ_USEBLIT_ARGB2NV12_UV_PLANE,

    SGXTQ_NUM_USEFRAGS
} SGXTQ_USEFRAGS;

typedef enum _SGXTQ_PDSPRIMFRAGS_
{
    SGXTQ_PDSPRIMFRAG_KICKONLY = 0,
    SGXTQ_PDSPRIMFRAG_SINGLESOURCE,
    SGXTQ_PDSPRIMFRAG_TWOSOURCE,
    SGXTQ_PDSPRIMFRAG_THREESOURCE,
    SGXTQ_PDSPRIMFRAG_ITER,

    SGXTQ_NUM_PDSPRIMFRAGS
} SGXTQ_PDSPRIMFRAGS;

typedef enum _SGXTQ_PDSSECFRAGS_
{
    SGXTQ_PDSSECFRAG_BASIC = 0,

    SGXTQ_PDSSECFRAG_DMA_ONLY,		/* PDS sec program using dma only (no direct attr) */

    SGXTQ_PDSSECFRAG_1ATTR,
    SGXTQ_PDSSECFRAG_3ATTR,
    SGXTQ_PDSSECFRAG_4ATTR,
	SGXTQ_PDSSECFRAG_4ATTR_DMA,
	SGXTQ_PDSSECFRAG_5ATTR_DMA,
	SGXTQ_PDSSECFRAG_6ATTR,
	SGXTQ_PDSSECFRAG_7ATTR,

    SGXTQ_NUM_PDSSECFRAGS
} SGXTQ_PDSSECFRAGS;

#if (EURASIA_TAG_TEXTURE_STATE_SIZE == 4)
#define SGXTQ_PDSSECFRAG_TEXSETUP					SGXTQ_PDSSECFRAG_4ATTR
#elif (EURASIA_TAG_TEXTURE_STATE_SIZE == 3)
#define SGXTQ_PDSSECFRAG_TEXSETUP					SGXTQ_PDSSECFRAG_3ATTR
#else
#error "Unexpected texture state size"
#endif

typedef enum _SGXTQ_USEEOTHANDLER_
{
    SGXTQ_USEEOTHANDLER_BASIC = 0,
#if defined(SGXTQ_SUBTILE_TWIDDLING)
	SGXTQ_USEEOTHANDLER_SUBTWIDDLED,
#endif

    SGXTQ_NUM_USEEOTHANDLERS
} SGXTQ_USEEOTHANDLER;

typedef enum _SGXTQ_PDSPIXEVENTHANDLER_
{
	SGXTQ_PDSPIXEVENTHANDLER_BASIC = 0,
	SGXTQ_PDSPIXEVENTHANDLER_TILEXY,

	SGXTQ_NUM_PDSPIXEVENTHANDLERS
} SGXTQ_PDSPIXEVENTHANDLER;


/****************************************************************
 * Resources
 ****************************************************************/
typedef struct _SGXTQ_PDS_RESOURCE_
{
	/* data segment size */
	IMG_UINT32			ui32DataLen;

	/* no of SAs/PAs */
	IMG_UINT32			ui32Attributes;

#if defined(SGX_FEATURE_UNIFIED_TEMPS_AND_PAS)
	IMG_UINT32			ui32TempRegs;
#endif

	/* TODO : ? merge in the PDS updates ?? that way we
	 * don't have to worry about the setup for one PDS res
	 * corrupting others PDS values..
	 */
} SGXTQ_PDS_RESOURCE;

typedef struct _SGXTQ_USE_RESOURCE_
{
	/* no of allocated temp regs, from r0 -> r(n-1) */
	IMG_UINT32			ui32NumTempRegs;

	/* only for shaders*/
	IMG_UINT32			ui32NumLayers;
} SGXTQ_USE_RESOURCE;

typedef enum _SGXTQ_DEV_RESOURCE_
{
	SGXTQ_STREAM,
	SGXTQ_PDS,
	SGXTQ_USE,
} SGXTQ_DEV_RESOURCE;

typedef struct _SGXTQ_STATIC_RESOURCE_
{
	/* the resource allocation */
	PVRSRV_CLIENT_MEM_INFO	*psMemInfo;
} SGXTQ_STATIC_RESOURCE;

typedef struct _SGXTQ_CB_RESOURCE_
{
	SGXTQ_CB	* psCB;
	const IMG_UINT32	* pui32SrcAddr;
	IMG_UINT32	ui32Size;
} SGXTQ_CB_RESOURCE;

typedef enum _SGXTQ_RESOURCE_STORAGE_
{
	/* resource comes from a CB */
	SGXTQ_STORAGE_CB,

	/* resource is allocated in the context */
	SGXTQ_STORAGE_STATIC,

	/* resource skeleton buffer*/
	SGXTQ_STORAGE_NBUFFER,

	/* resource is coming from the client driver*/
	SGXTQ_STORAGE_FOREIGN,

} SGXTQ_RESOURCE_STORAGE;

typedef struct _SGXTQ_RESOURCE_
{
	/* where the resource is stored */
	SGXTQ_RESOURCE_STORAGE		eStorage;
	union {
		SGXTQ_STATIC_RESOURCE	sStatic;
		SGXTQ_CB_RESOURCE		sCB;
	} uStorage;

	IMG_DEV_VIRTADDR			sDevVAddr;

	/* what kind of resource */
	SGXTQ_DEV_RESOURCE			eResource;
	union {
		SGXTQ_PDS_RESOURCE		sPDS;
		SGXTQ_USE_RESOURCE		sUSE;
	} uResource;
} SGXTQ_RESOURCE;

/****************************************************************/

typedef struct _SQXTQ_CLIENT_TRANSFER_CONTEXT_
{
    PVRSRV_DEV_DATA 		*psDevData;
    PVRSRV_MUTEX_HANDLE		hMutex;
#if defined (SUPPORT_SID_INTERFACE)
    IMG_EVENTSID			hOSEvent;

    IMG_SID					hHWTransferContext;
#else
    IMG_HANDLE				hOSEvent;

    IMG_HANDLE				hHWTransferContext;
#endif

    /* devVAddr of HW transfer context */
    IMG_DEV_VIRTADDR 		sHWTransferContextDevVAddr;

	/* Sync info for TA/TQ dependencies */
	PVRSRV_CLIENT_MEM_INFO	*psTASyncObjectMemInfo;
	PVRSRV_CLIENT_SYNC_INFO	*psTASyncObject;

	/* Sync info for 3D/TQ dependencies */
	PVRSRV_CLIENT_MEM_INFO	*ps3DSyncObjectMemInfo;
	PVRSRV_CLIENT_SYNC_INFO	*ps3DSyncObject;

	/* transfer command CCB */
	SGX_CLIENT_CCB 			*psTransferCCB;

#if defined(SGX_FEATURE_2D_HARDWARE)
	/*  */
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hHW2DContext;
#else
	IMG_HANDLE				hHW2DContext;
#endif
    /* devVAddr of HW 2D context */
    IMG_DEV_VIRTADDR 		sHW2DContextDevVAddr;
    /* 2D command CCB */
	SGX_CLIENT_CCB 			*ps2DCCB;
#endif

    /* Bases */
    IMG_DEV_VIRTADDR 		sUSEExecBase;
#if ! defined(SGX_FEATURE_PIXEL_PDSADDR_FULL_RANGE)
    IMG_DEV_VIRTADDR 		sPDSExecBase;
#endif
    IMG_DEV_VIRTADDR 		sISPStreamBase;

	/* Fence ID */
    PVRSRV_CLIENT_MEM_INFO	*psFenceIDMemInfo;
	IMG_UINT32				ui32FenceID;

    /* Resource buffers */
	SGXTQ_CB				*psPDSCodeCB;
 	SGXTQ_CB				*psUSECodeCB;
 	SGXTQ_CB				*psStreamCB;

	/* skeleton buffer for SGXTQ_PDSPRIMFRAG_SINGLESOURCE*/
	SGXTQ_CB				*psPDSPrimFragSingleSNB;

#if defined(SGXTQ_SUBTILE_TWIDDLING)
	/* skeleton buffer for SGXTQ_USEEOTHANDLER_SUBTWIDDLED*/
	SGXTQ_CB				*psUSEEOTSubTwiddledSNB;
#endif

	/* PDS resources */
	SGXTQ_RESOURCE			*apsPDSPrimResources[SGXTQ_NUM_PDSPRIMFRAGS];
	SGXTQ_RESOURCE			*apsPDSSecResources[SGXTQ_NUM_PDSSECFRAGS];
	SGXTQ_RESOURCE			*apsPDSPixeventHandlers[SGXTQ_NUM_PDSPIXEVENTHANDLERS];

	/* USE resources */
	SGXTQ_RESOURCE			*apsUSEResources[SGXTQ_NUM_USEFRAGS];
	SGXTQ_RESOURCE			*apsUSEEOTHandlers[SGXTQ_NUM_USEEOTHANDLERS];
	/* we shouldn't hit eop, it used to be set to eot, but eot isn't static and eor is,
	 * so now it's easier to set it to eor. ; might need to be changed later */
	SGXTQ_RESOURCE			*psUSEEOPHandler;
	SGXTQ_RESOURCE			*psUSEEORHandler;

	/* ISP resources */
	SGXTQ_RESOURCE			*apsISPResources[SGXTQ_NUM_HWBGOBJS];
	/* Fast 2d ISP control stream */
	SGXTQ_RESOURCE			*psFast2DISPControlStream;

#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH) && defined(SGX_FEATURE_FAST_RENDER_CONTEXT_SWITCH)
	/* meminfo for PDS state on ISP ctx switch */
	PVRSRV_CLIENT_MEM_INFO 	*apsPDSCtxSwitchMemInfo[SGX_FEATURE_MP_CORE_COUNT_3D][SGX_FEATURE_NUM_PDS_PIPES];
#endif

#if defined(SUPPORT_SGX_PRIORITY_SCHEDULING)
	IMG_BOOL				bKickSubmitted;
	IMG_BOOL				bPrioritySet;
    SGX_CONTEXT_PRIORITY    ePriority;
#endif

    /* Staging Buffer */
	SGXTQ_CB				* psStagingBuffer;

#if defined(SUPPORT_KERNEL_SGXTQ)
	IMG_HANDLE hCallbackHandle;
#endif

#if defined(BLITLIB)
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					ahSyncModObjPool[SGXTQ_MAX_SURFACES + 1];
#else
	IMG_HANDLE				ahSyncModObjPool[SGXTQ_MAX_SURFACES + 1];
#endif	
#endif
	IMG_HANDLE				hDevMemContext;
} SGXTQ_CLIENT_TRANSFER_CONTEXT;

typedef struct _SGXTQ_BLIT_DATA_
{
    IMG_UINT32			ui32SrcSel;
    IMG_UINT32			ui32SrcBytesPerPixel;
    IMG_UINT32			ui32DstBytesPerPixel;

	IMG_UINT32			ui32SrcLineStride;
	IMG_UINT32			ui32SrcWidth;
	IMG_UINT32			ui32DstLineStride;
	IMG_UINT32			ui32DstWidth;
	IMG_UINT32			ui32DstTAGWidth;
	IMG_UINT32			ui32DstTAGLineStride;

	IMG_RECT			sSrcRect;
	IMG_RECT			sDstRect;

	IMG_UINT32			ui32NumLayers;
	SGXTQ_PDSPRIMFRAGS	ePDSPrim;
	SGXTQ_PDSSECFRAGS	ePDSSec;
	SGXTQ_USEFRAGS		eUSEProg;

	SGXTQ_TSP_COORDS	sTSPCoords;

	IMG_UINT32			ui32SrcDevVAddr;
	IMG_UINT32			ui32DstDevVAddr;

#if defined(SGX_FEATURE_NATIVE_BACKWARD_BLIT)
	IMG_UINT32			ui32ScanDirection;
#else
	IMG_BOOL			bBackBlit;
#endif

} SGXTQ_BLIT_DATA;

typedef struct _SGXTQ_MIPGEN_DATA_
{
	IMG_UINT32 ui32NextSourceDevVAddr;
	IMG_UINT32 ui32SourceDevVAddr;
	IMG_UINT32 ui32DestDevVAddr;

    IMG_UINT32 ui32BytesPerPixel;

	IMG_UINT32 ui32BatchWidth;
	IMG_UINT32 ui32BatchHeight;
	IMG_UINT32 ui32Width;
	IMG_UINT32 ui32Height;
	IMG_UINT32	ui32FirstWidth;
	IMG_UINT32	ui32FirstHeight;
	IMG_UINT32	ui32FirstSrcDevVAddr;

	IMG_UINT32	ui32ChunksLeft;
	IMG_UINT32	ui32LevelsLeft;
	IMG_UINT32	ui32BatchesLeft;
	IMG_UINT32 ui32BatchSize;
	IMG_UINT32 ui32DstBatchSize;

} SGXTQ_MIPGEN_DATA;

typedef struct _SGXTQ_TEXTURE_UPLOAD_DATA
{
	IMG_BOOL	bSubTwiddled;

	IMG_PBYTE	apbySrcLinAddr[SGXTQ_MAX_CHANCHUNKS];
	IMG_UINT32	ui32SrcBytesPP;
	IMG_UINT32	ui32PixelByteStride;
	IMG_UINT32	ui32U2Float;

	IMG_UINT32	aui32HeightLeft[SGXTQ_MAX_CHANCHUNKS];
	IMG_RECT	asSBRect[SGXTQ_MAX_CHANCHUNKS];
	IMG_UINT32	ui32BatchHeight;
	IMG_UINT32	ui32NumChunks;
	IMG_PVOID	pvSBLinAddr;
	IMG_UINT32	ui32SBLineStride;

	IMG_RECT	sDstRect;
	IMG_UINT32	ui32DstWidth;
	IMG_UINT32	ui32DstHeight;
	IMG_UINT32	ui32DstBytesPP;
	IMG_UINT32	ui32DstLineStride;
} SGXTQ_TEXTURE_UPLOAD_DATA;


typedef struct _SGXTQ_BUFBLT_DATA_
{
	IMG_BOOL	bInterleaved;
	IMG_UINT32	ui32BytesLeft;
	IMG_UINT32	ui32SrcStart;
	IMG_UINT32	ui32DstStart;
} SGXTQ_BUFBLT_DATA;

typedef struct _SGXTQ_ARGB2NV12_DATA_
{
	IMG_UINT32	ui32SrcWidth;
	IMG_UINT32	ui32SrcLineStride;

	IMG_UINT32	ui32DstWidth;
	IMG_UINT32	ui32DstLineStride;
} SGXTQ_ARGB2NV12_DATA;

/*
	For Prepare functions to easily store info
	required across multiple passes.
*/
typedef struct _SGXTQ_PREP_INTERNAL_
{
#if ! defined(SGX_FEATURE_NATIVE_BACKWARD_BLIT)
	struct
	{
		IMG_RECT			sClampedSrcRect;
		IMG_RECT			sClampedDstRect;
		IMG_DEV_VIRTADDR	sBufferDevAddr;
		IMG_UINT32			ui32SrcLineStride;
		IMG_UINT32			ui32BlockHeight;
	} sBackwardBlitData;
#endif

	SGXTQ_PDS_UPDATE		sPDSUpdate;
	IMG_UINT32				aui32PBEState[SGXTQ_PBESTATE_WORDS];

	union {
		SGXTQ_BLIT_DATA				sBlitData;
		SGXTQ_MIPGEN_DATA			sMipData;
		SGXTQ_BUFBLT_DATA			sBufBltData;
		SGXTQ_TEXTURE_UPLOAD_DATA	sTexUplData;
		SGXTQ_ARGB2NV12_DATA		sARGB2NV12Data;
	} Details;
} SGXTQ_PREP_INTERNAL;


#if defined(SGX_FEATURE_2D_HARDWARE)
typedef struct _SGXMKIF_2DCMD_SUBMIT_
{
	PSGXMKIF_2DCMD		ps2DCmd;

	PVRSRV_2D_SGX_KICK	s2DKick;
} SGXMKIF_2DCMD_SUBMIT, *PSGXMKIF_2DCMD_SUBMIT;
#endif /* SGX_FEATURE_2D_HARDWARE */


/* The common submits structure */
typedef struct _SGXTQ_SUBMITS_
{
	IMG_UINT32			ui32NumSubmits;
	/* Max queued submits per prep call */
	IMG_UINT32			aui32FenceIDs[SGXTQ_MAX_COMMANDS];

	SGXMKIF_TRANSFERCMD		asTransferCmd[SGXTQ_MAX_COMMANDS];
	PVRSRV_TRANSFER_SGX_KICK	asKick[SGXTQ_MAX_COMMANDS];
#if defined(SGX_FEATURE_2D_HARDWARE)
	IMG_UINT32 			ui32Num2DSubmits;
	SGXMKIF_2DCMD_SUBMIT		as2DSubmit[SGXTQ_MAX_COMMANDS];
#endif

	IMG_UINT32 ui32CCBOffset;
} SGXTQ_SUBMITS;


/* Utils Function Declarations */
IMG_UFIXED SGXTQ_FixedIntDiv(IMG_UINT16 ui16A, IMG_UINT16 ui16B);
IMG_UINT32 SGXTQ_FixedToFloat(IMG_UFIXED ufxVal);
IMG_UINT32 SGXTQ_FixedToF16(IMG_UFIXED ufxVal);
IMG_UINT32 SGXTQ_FloatIntDiv(IMG_UINT32 ui32A, IMG_UINT32 uiB);
IMG_UINT32 SGXTQ_ByteToF16(IMG_UINT32 byte);

PVRSRV_ERROR SGXTQ_GetPixelFormats(PVRSRV_PIXEL_FORMAT	eSrcPix,
								   IMG_BOOL				bSrcPacked,
								   PVRSRV_PIXEL_FORMAT	eDstPix,
								   IMG_BOOL				bDstPacked,
								   SGXTQ_FILTERTYPE 	eFilter,
								   IMG_UINT32			* pui32TagState,
								   IMG_BOOL				* pbTagPlanarizerNeeded,
								   IMG_UINT32			* pui32TAGBpp,
								   IMG_UINT32			* pui32PBEState,
								   IMG_UINT32			* pui32PBEBpp,
								   IMG_UINT32			ui32Pass,
								   IMG_UINT32			* pui32PassesRequired);

IMG_UINT32 SGXTQ_FilterFromEnum(SGXTQ_FILTERTYPE eFilter);

IMG_UINT32 SGXTQ_RotationFromEnum(SGXTQ_ROTATION eRotation);

IMG_UINT32 SGXTQ_MemLayoutFromEnum(SGXTQ_MEMLAYOUT eMemLayout, IMG_BOOL bIsInput);

IMG_VOID SGXTQ_ShaderFromAlpha(SGXTQ_ALPHA eAlpha,
										SGXTQ_USEFRAGS* peUSEProgram,
										SGXTQ_PDSSECFRAGS* pePDSSec);

PVRSRV_ERROR SGXTQ_ShaderFromRop(IMG_BYTE byCustomRop3,
										SGXTQ_USEFRAGS* peUSEProg,
										SGXTQ_PDSPRIMFRAGS* pePDSPrim,
										IMG_UINT32* pui32NumLayers);

IMG_UINT32 SGXTQ_GetStrideGran(IMG_UINT32 ui32LineStride, IMG_UINT32 ui32BytesPerPixel);

PVRSRV_ERROR SGXTQ_GetSurfaceStride(SGXTQ_SURFACE*	psSurf,
									   	IMG_UINT32	ui32BytesPP,
										IMG_BOOL	bIsInput,
										IMG_BOOL	bStridedBlitEnabled,
										IMG_UINT32* pi32LineStride);


PVRSRV_ERROR SGXTQ_GetSurfaceWidth(SGXTQ_SURFACE*	psSurf,
										IMG_UINT32	ui32BytesPP,
										IMG_BOOL	bIsInput,
										IMG_BOOL	bStridedBlitEnabled,
										IMG_UINT32*	pui32RightEdge);

IMG_VOID SGXTQ_SetTAGState(SGXTQ_PDS_UPDATE* psPDSUpdate,
										IMG_UINT32 ui32LayerNo,
										IMG_UINT32 ui32SrcDevVAddr,
										SGXTQ_FILTERTYPE eFilter,
										IMG_UINT32 ui32Width,
										IMG_UINT32 ui32Height,
										IMG_UINT32 ui32Stride,
										IMG_UINT32 ui32TAGFormat,
										IMG_UINT32 ui32BytesPP,
										IMG_BOOL bNewPixelHandling,
										SGXTQ_MEMLAYOUT eMemLayout);

#if ! defined(SGX_FEATURE_USE_VEC34)
PVRSRV_ERROR SGXTQ_SetupStridedBlit(IMG_UINT32						* pui32TAGState,
										SGXTQ_SURFACE				*psSrcSurf,
										SGXTQ_USEFRAGS				eUSEProg,
										IMG_UINT32					ui32SrcLineStride,
										IMG_UINT32					ui32SrcBytesPerPixel,
										IMG_UINT32					ui32PassesRequired,
										IMG_UINT32					ui32CurPass,
										IMG_UINT32					aui32Limms[]);
#endif


IMG_VOID SGXTQ_SetUSSEKick(SGXTQ_PDS_UPDATE					*psPDSUpdate,
										IMG_DEV_VIRTADDR	sUSEExecAddr,
										IMG_DEV_VIRTADDR	sUSEExecBase,
										IMG_UINT32			ui32NumTempsRegs);


IMG_VOID SGXTQ_SetDMAState(SGXTQ_PDS_UPDATE					*psPDSUpdate,
										IMG_DEV_VIRTADDR	sDevVaddr,
										IMG_UINT32			ui32LineLen,
										IMG_UINT32			ui32LineNo,
										IMG_UINT32			ui32Offset);


PVRSRV_ERROR SGXTQ_CreateUSEEOTHandler(SGXTQ_CLIENT_TRANSFER_CONTEXT	*psTQContext,
										IMG_UINT32						*aui32PBEState,
										SGXTQ_USEEOTHANDLER				eEot,
										IMG_UINT32						ui32UV,
										IMG_UINT32						ui32DstBytesPP,
										IMG_BOOL						bPDumpContinuous);


PVRSRV_ERROR SGXTQ_CreatePDSPixeventHandler(SGXTQ_CLIENT_TRANSFER_CONTEXT	* psTQContext,
									  SGXTQ_RESOURCE						* psEORHandler,
									  SGXTQ_RESOURCE						* psEOTHandler,
									  SGXTQ_PDSPIXEVENTHANDLER				ePixev,
									  IMG_BOOL								bPDumpContinuous);

PVRSRV_ERROR SGXTQ_SetPBEState(IMG_RECT					* psDstRect,
										SGXTQ_MEMLAYOUT	eMemLayout,
										IMG_UINT32		ui32DstWidth,
										IMG_UINT32		ui32DstHeight,
										IMG_UINT32		ui32DstLineStride,
										IMG_UINT32		ui32DstPBEPackMode,
										IMG_UINT32		ui32DstDevVAddr,
										IMG_UINT32		ui32SrcSel,
										SGXTQ_ROTATION	eRotation,
										IMG_BOOL 		bEnableDithering,
										IMG_BOOL		bNewPixelHandling,
										IMG_UINT32		* aui32PBEState);


IMG_VOID SGXTQ_SetupPixeventRegs(SGXTQ_CLIENT_TRANSFER_CONTEXT	*psTQContext,
										SGXMKIF_TRANSFERCMD		*psSubmit,
										SGXTQ_RESOURCE			*psPixEvent);

IMG_VOID SGXTQ_SetupTransferRegs(SGXTQ_CLIENT_TRANSFER_CONTEXT	*psTQContext,
										IMG_UINT32				ui32BIFTile0Config,
										SGXMKIF_TRANSFERCMD 	*psSubmit,
										SGXTQ_RESOURCE			*psPixEvent,
										IMG_UINT32				ui32NumLayers,
										IMG_UINT32				ui32ScanDirection,
										IMG_UINT32				ui32ISPRenderType);


PVRSRV_ERROR SGXTQ_CreatePDSPrimResource(SGXTQ_CLIENT_TRANSFER_CONTEXT	* psTQContext,
										SGXTQ_PDSPRIMFRAGS				ePDSPrim,
										SGXTQ_PDS_UPDATE				* psPDSValues,
										IMG_BOOL						bPDumpContinuous);


PVRSRV_ERROR SGXTQ_CreatePDSSecResource(SGXTQ_CLIENT_TRANSFER_CONTEXT	* psTQContext,
										SGXTQ_PDSSECFRAGS				ePDSSec,
										SGXTQ_PDS_UPDATE				* psPDSValues,
										IMG_BOOL						bPDumpContinuous);


PVRSRV_ERROR SGXTQ_CreateUSESecondaryResource(SGXTQ_CLIENT_TRANSFER_CONTEXT	* psTQContext,
											SGXTQ_PDSSECFRAGS				ePDSSec,
											SGXTQ_PDS_UPDATE				* psPDSValues,
											IMG_BOOL						bPDumpContinuous);


PVRSRV_ERROR SGXTQ_CreateUSEResource(SGXTQ_CLIENT_TRANSFER_CONTEXT	* psTQContext,
										SGXTQ_USEFRAGS				eUSEId,
										IMG_UINT32					* aui32USELimm,
										IMG_BOOL					bPDumpContinuous);


IMG_VOID SGXTQ_SetupTransferRenderBox(SGXMKIF_TRANSFERCMD *psSubmit,
										IMG_UINT32 x0,
										IMG_UINT32 y0,
										IMG_UINT32 x1,
										IMG_UINT32 y1);

PVRSRV_ERROR SGXTQ_SetupTransferClipRenderBox(SGXMKIF_TRANSFERCMD *psSubmit,
											 IMG_UINT32 x0,
											 IMG_UINT32 y0,
											 IMG_UINT32 x1,
											 IMG_UINT32 y1,
											 IMG_UINT32 ui32DstWidth,
											 IMG_UINT32 ui32DstHeight);

PVRSRV_ERROR SGXTQ_CreateISPResource(SGXTQ_CLIENT_TRANSFER_CONTEXT	*psTQContext,
									  SGXTQ_RESOURCE				*psPrimary,
									  SGXTQ_RESOURCE				*psSecondary,
									  IMG_RECT						*psDstRect,
									  SGXTQ_TSP_COORDS				*psTSPCoords,
									  IMG_BOOL						bConservativeResUsage,
									  IMG_BOOL						bInvertTriangle,
									  IMG_UINT32					ui32NumLayers,
									  IMG_BOOL						bPDumpContinuous,
									  IMG_UINT32					ui32Flags);


PVRSRV_ERROR SGXTQ_CreateISPF2DResource(SGXTQ_CLIENT_TRANSFER_CONTEXT	*psTQContext,
										SGXTQ_RESOURCE					*psPrimary,
										SGXTQ_RESOURCE					*psSecondary,
										IMG_RECT						*psDstRect,
										SGXTQ_TSP_SINGLE				*psTSPCoords,
										IMG_UINT32                      ui32NumRects,
										IMG_BOOL						bTranslucent,
										IMG_BOOL						bPDumpContinuous);

IMG_VOID SGXTQ_ClampInputRects(IMG_RECT *psSrcRect,
										IMG_UINT32 ui32SrcWidth,
										IMG_UINT32 ui32SrcHeight,
										IMG_RECT *psDstRect,
										IMG_UINT32 ui32DstWidth,
										IMG_UINT32 ui32DstHeight);

IMG_VOID SGXTQ_CopyToStagingBuffer(IMG_VOID							*pvSBLinAddr,
									IMG_UINT32						ui32SBStrideInBytes,
									IMG_PBYTE						pbySrcLinAddr,
									IMG_UINT32						ui32SrcStrideInBytes,
									IMG_UINT32						ui32BytesPP,
									IMG_UINT32						ui32PixelByteStride,
									IMG_UINT32						ui32HeightToCopy,
									IMG_UINT32						ui32WidthToCopy);

#if defined(SGX_FEATURE_2D_HARDWARE) && defined (PDUMP)
IMG_VOID SGXTQ_PDump2DCmd(IMG_CONST PVRSRV_CONNECTION* psConnection, SGX_QUEUETRANSFER * psQueueTransfer, PSGXMKIF_2DCMD ps2DCmd);
#endif //#if defined(SGX_FEATURE_2D_HARDWARE) && defined (PDUMP)

#if defined(PDUMP) && defined(SGXTQ_DEBUG_PDUMP_TQINPUT)
IMG_VOID SGXTQ_PDumpTQInput(IMG_CONST PVRSRV_CONNECTION	* psConnection,
									SGX_QUEUETRANSFER	* psQueueTransfer,
									IMG_UINT32			ui32FenceId);
#endif//#if defined(PDUMP) && defined(SGXTQ_DEBUG_PDUMP_TQINPUT)

#if defined(SGX_FEATURE_PTLA)
PVRSRV_ERROR SGXSubmitTransfer(IMG_HANDLE hTransferContext,
							   SGX_SUBMITTRANSFER *psSubmitTransfer);

#if defined(__psp2__)
IMG_INTERNAL
PVRSRV_ERROR IMG_CALLCONV SGXQueue2DTransfer(PVRSRV_DEV_DATA *psDevData,
											 IMG_HANDLE			hTransferContext,
											 SGX_QUEUETRANSFER	*psQueueTransfer);
#else
PVRSRV_ERROR IMG_CALLCONV SGXQueue2DTransfer(IMG_HANDLE			hTransferContext,
											 SGX_QUEUETRANSFER	*psQueueTransfer);
#endif
#endif /* defined(SGX_FEATURE_PTLA) */

#if defined(SGX_FEATURE_2D_HARDWARE)
PVRSRV_ERROR Prepare2DCoreBlit(SGXTQ_CLIENT_TRANSFER_CONTEXT *psTQContext,
							   SGX_QUEUETRANSFER *psQueueTransfer,
							   SGXMKIF_2DCMD_SUBMIT *ps2DSubmit);
#endif /* defined(SGX_FEATURE_2D_HARDWARE) */

#endif /* TRANSFER_QUEUE */
#endif /*_SGXTRANSFER_CLIENT_H_*/

/******************************************************************************
 End of file (sgxtransfer_client.h)
******************************************************************************/
