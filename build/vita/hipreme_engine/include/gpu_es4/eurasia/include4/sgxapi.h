/*!****************************************************************************
@File           sgxapi.h

@Title          SGX API Header

@Author         Imagination Technologies

@Date           01/06/2004

@Copyright      Copyright 2004-2008 by Imagination Technologies Limited.
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
$Log: sgxapi.h $
******************************************************************************/

#ifndef __SGXAPI_H__
#define __SGXAPI_H__

#if defined (__cplusplus)
extern "C" {
#endif

#include "sgxdefs.h"

#if defined(__linux__) && !defined(USE_CODE)
	#if defined(__KERNEL__)
		#include <asm/unistd.h>
	#else
		#include <unistd.h>
	#endif
#endif

#if !defined (SUPPORT_SID_INTERFACE)
#include "sgxapi_km.h"
#endif
#include "sgxapiperf.h"
#include "services.h"

/*
	SGX USSE code execution register base indices
*/
#if defined(__psp2__)
#define SGX_PIXSHADER_USE_CODE_BASE_INDEX	4
#define SGX_VTXSHADER_USE_CODE_BASE_INDEX	0

/* 
	Mapped to the CD Pixel/VertexShader Heaps 
*/
#define SGX_CD_PIXSHADER_USE_CODE_BASE_INDEX	9
#define SGX_CD_VTXSHADER_USE_CODE_BASE_INDEX	8
#else	
#define SGX_PIXSHADER_USE_CODE_BASE_INDEX	0
#define SGX_VTXSHADER_USE_CODE_BASE_INDEX	10
#endif

/******************************************************************************
 Local ISR handler structures
******************************************************************************/

#define SGXISR_FLAG_CRTC_VSYNC		0x0001
#define SGXISR_FLAG_DMA_COMPLETE	0x0002
#define SGXISR_FLAG_DMA_PREEMPTED	0x0004
#define SGXISR_FLAG_DMA_FAULTED		0x0008

typedef struct _SGXISRINFO
{
	IMG_HANDLE	hDevCookie;		/* input */
	IMG_UINT32	ui32Flags;		/* returns flag settings relating to interrupts */
	IMG_BOOL	bInterruptProcessed; /* set to IMG_TRUE to let the calee know that the
										Flags are valid */
} SGXISRINFO, *PSGXISRINFO;



/******************************************************************************
 Visibility test back door condition defines
******************************************************************************/
#define BDVISTEST_COND_ALWAYS				0x00000000
#define BDVISTEST_COND_EQUAL				0x00000001
#define BDVISTEST_COND_LSEQUAL				0x00000002
#define BDVISTEST_COND_GREQUAL				0x00000003
#define BDVISTEST_COND_MASK					0x00000003

#define BDVISTEST_REG_MASK					0x0000001C
#define BDVISTEST_REG_SHIFT					2

#define BDVISTEST_VAL_MASK					0xFFFFFFE0
#define BDVISTEST_VAL_SHIFT					5

/******************************************************************************
 Structures used in API calls
******************************************************************************/

/*
	Maximum number of queued renders per render target is
	(3 * ui32RendersPerFrame) - see SGX_ADDRENDTARG.
*/

#if defined(SUPPORT_SGX_PRIORITY_SCHEDULING)
#define SGX_MAX_CONTEXT_PRIORITY		3
#else
#define SGX_MAX_CONTEXT_PRIORITY		1
#endif

/*
	SGX render context scheduling priority
*/
typedef enum _SGX_CONTEXT_PRIORITY_
{
	SGX_CONTEXT_PRIORITY_LOW	= 0,
	SGX_CONTEXT_PRIORITY_MEDIUM	= 1,
	SGX_CONTEXT_PRIORITY_HIGH	= 2,
	SGX_CONTEXT_PRIORITY_FORCE_I32	= 0x7fffffff
} SGX_CONTEXT_PRIORITY;

#if defined(__psp2__)
typedef struct _SGX_CREATERENDERCONTEXT_
{
	IMG_UINT32				ui32Flags;
	IMG_SID					hDevCookie;
	IMG_SID					hDevMemContext;
	IMG_UINT32				ui32PBSize;
	IMG_UINT32				ui32PBSizeLimit;
	IMG_UINT32				ui32VisTestResultBufferSize;
	IMG_UINT32				ui32MaxSACount;
	IMG_SID					hMemBlockProcRef;
	IMG_BOOL				bPerContextPB;
} SGX_CREATERENDERCONTEXT, *PSGX_CREATERENDERCONTEXT;
#else
typedef struct _SGX_CREATERENDERCONTEXT_
{
	IMG_UINT32				ui32Flags;
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hDevCookie;
	IMG_SID					hDevMemContext;
	IMG_EVENTSID			hOSEvent;
#else
	IMG_HANDLE				hDevCookie;
	IMG_HANDLE				hDevMemContext;
	IMG_HANDLE				hOSEvent;
#endif
	IMG_UINT32				ui32PBSize;
	IMG_UINT32				ui32PBSizeLimit;
	IMG_UINT32				ui32VisTestResultBufferSize;
	IMG_UINT32				ui32MaxSACount;
	IMG_BOOL				bPerContextPB;
} SGX_CREATERENDERCONTEXT, *PSGX_CREATERENDERCONTEXT;
#endif

#define SGX_CREATERCTXTFLAGS_SHAREDPB	0x00000001 /* On PSP2 a shared PB is created only if this flag is used */
#if defined(__psp2__)
#define SGX_CREATERCTXTFLAGS_CDRAMPB				0x00000002
#define SGX_CREATERCTXTFLAGS_PERCONTEXT_SYNC_INFO	0x00000004 /* Sync info is not shared with other render contexts */
#endif

typedef enum _SGX_SCALING_
{
	SGX_SCALING_NONE = 0,
	SGX_DOWNSCALING,
	SGX_UPSCALING,
	SGX_SCALING_FORCE_I32 = 0x7FFFFFFF
} SGX_SCALING;

#if defined (__psp2__)

typedef struct _SGX_ADDRENDTARG_
{
	IMG_UINT32				ui32Flags;
	IMG_UINT32				ui32NumRTData;    /* Renders per frame * 2 */
	IMG_UINT32				ui32MaxQueuedRenders;    /* Renders per frame * Max frames in progress */
	IMG_HANDLE				hRenderContext;
	IMG_SID					hDevCookie;
	IMG_UINT32				ui32NumPixelsX;
	IMG_UINT32				ui32NumPixelsY;
	IMG_UINT16				ui16MSAASamplesInX;
	IMG_UINT16				ui16MSAASamplesInY;
	SGX_SCALING				eForceScalingInX;
	SGX_SCALING				eForceScalingInY;
	IMG_UINT32				ui32BGObjUCoord;	/* Texture U-coordinate of right-hand vertex of background object */
	PVRSRV_ROTATION			eRotation;
	IMG_UINT16				ui16NumRTsInArray;
	IMG_UINT8				ui8MacrotileCountX;
	IMG_UINT8				ui8MacrotileCountY;
	IMG_INT32				i32DataMemblockUID;
	IMG_BOOL				bUseExternalUID;
	IMG_SID					hMemBlockProcRef;
	IMG_UINT32				ui32MultisampleLocations;
} SGX_ADDRENDTARG, *PSGX_ADDRENDTARG;

#else

typedef struct _SGX_ADDRENDTARG_
{
	IMG_UINT32				ui32Flags;
	IMG_UINT32				ui32RendersPerFrame;	/* Maximum renders per frame before blocking behaviour, pass 0 for defaults */
	IMG_HANDLE				hRenderContext;
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hDevCookie;
#else
	IMG_HANDLE				hDevCookie;
#endif
	IMG_UINT32				ui32NumPixelsX;
	IMG_UINT32				ui32NumPixelsY;
	IMG_UINT16				ui16MSAASamplesInX;
	IMG_UINT16				ui16MSAASamplesInY;
	SGX_SCALING				eForceScalingInX;
	SGX_SCALING				eForceScalingInY;
	IMG_UINT32				ui32BGObjUCoord;	/* Texture U-coordinate of right-hand vertex of background object */
	PVRSRV_ROTATION			eRotation;
	IMG_UINT16				ui16NumRTsInArray;
} SGX_ADDRENDTARG, *PSGX_ADDRENDTARG;

#endif

#define SGX_ADDRTFLAGS_SHAREDRTDATA						0x00000001
#define SGX_ADDRTFLAGS_USEOGLMODE						0x00000002
#define SGX_ADDRTFLAGS_FORCE_MT_MODE_SELECT				0x00000004
#define SGX_ADDRTFLAGS_MSAA5THPOSNDISABLE				0x00000008
#define SGX_ADDRTFLAGS_DPMZLS							0x00000010
#if defined(__psp2__)
#define SGX_ADDRTFLAGS_CUSTOM_MULTISAMPLELOCATIONS		0x00010000
#define SGX_ADDRTFLAGS_MACROTILE_SYNC					0x00020000
#define SGX_ADDRTFLAGS_CUSTOM_MACROTILE_COUNTS			0x00040000
#endif

#define SGX_KICKTA_FLAGS_RESETTPC						0x00000001
#define SGX_KICKTA_FLAGS_KICKRENDER						0x00000002
#define SGX_KICKTA_FLAGS_FIRSTTAPROD					0x00000004
#define SGX_KICKTA_FLAGS_COLOURALPHAVALID				0x00000008
#define SGX_KICKTA_FLAGS_RENDEREDMIDSCENE				0x00000010
#define SGX_KICKTA_FLAGS_GETVISRESULTS					0x00000020
#define SGX_KICKTA_FLAGS_DISABLE_ACCUMVISRESULTS		0x00000040
#define SGX_KICKTA_FLAGS_TAUSEDAFTERRENDER				0x00000080
#define SGX_KICKTA_FLAGS_RENDEREDMIDSCENENOFREE			0x00000100
#define SGX_KICKTA_FLAGS_TERMINATE						0x00000200
#define SGX_KICKTA_FLAGS_BBOX_TERMINATE					0x00000400
#define SGX_KICKTA_FLAGS_ABORT							0x00000800
#define SGX_KICKTA_FLAGS_VISTESTTERM					0x00001000
#define SGX_KICKTA_FLAGS_MIDSCENENOFREE					0x00002000
#define SGX_KICKTA_FLAGS_ZONLYRENDER					0x00004000
#define SGX_KICKTA_FLAGS_MIDSCENETERM					0x00008000
#define SGX_KICKTA_FLAGS_FLUSHDATACACHE					0x00010000
#define SGX_KICKTA_FLAGS_FLUSHPDSCACHE					0x00020000
#define SGX_KICKTA_FLAGS_FLUSHUSECACHE					0x00040000
#define SGX_KICKTA_FLAGS_DEPTHBUFFER					0x00080000
#define SGX_KICKTA_FLAGS_STENCILBUFFER					0x00100000
#define SGX_KICKTA_FLAGS_TQTA_SYNC						0x00200000
#define SGX_KICKTA_FLAGS_TQ3D_SYNC						0x00400000
#define SGX_KICKTA_FLAGS_DEPENDENT_TA					0x00800000
#define SGX_KICKTA_FLAGS_TA_DEPENDENCY					0x01000000
#define SGX_KICKTA_FLAGS_COMPLEX_GEOMETRY_PRESENT		0x02000000
#define SGX_KICKTA_FLAGS_POST_RENDER_SLC_FLUSH			0x04000000
#define SGX_KICKTA_FLAGS_ABC_REORDER					0x08000000
#if defined(FIX_HW_BRN_31079)
#define SGX_KICKTA_FLAGS_VDM_PIM_SPLIT					0x10000000
#endif
#define SGX_KICKTA_FLAGS_COMPUTE_TASK_OPENCL			0x20000000
#if defined(__psp2__)
#define SGX_KICKTA_FLAGS_POST_TA_SLC_FLUSH				0x40000000

#define SGX_KICKTA_SCENEFLAGS_VDM_BUFFER_HIGHMARK				0x00000001
#define SGX_KICKTA_SCENEFLAGS_VERTEX_BUFFER_HIGHMARK			0x00000002
#define SGX_KICKTA_SCENEFLAGS_FRAGMENT_BUFFER_HIGHMARK			0x00000004
#define SGX_KICKTA_SCENEFLAGS_FRAGMENT_USSE_BUFFER_HIGHMARK		0x00000008
#define SGX_KICKTA_SCENEFLAGS_MIDSCENE_KICK						0x00000010
#endif


/*!
 ******************************************************************************
 * Client device information structure for SGX
 *****************************************************************************/
typedef struct _PVRSRV_SGX_CLIENT_INFO_
{
	IMG_UINT32					ui32ProcessID;			/*!< ID of process controlling SGX device */
#if !defined(__psp2__)
	IMG_VOID					*pvProcess;				/*!< pointer to OS specific 'process' structure */
#endif
	PVRSRV_MISC_INFO			sMiscInfo;				/*!< Misc. Information, inc. SOC specifics */

	IMG_UINT32					ui32EVMConfig;			/*!< used by pdumping kicks */
	IMG_UINT32					ui32ClientKickFlags;	/*!< misc flags used between kicks, per client */
	IMG_UINT32					ui32NumUSETemporaryRegisters;	/*!< Number of temporary registers available */
	IMG_UINT32					ui32NumUSEAttributeRegisters;	/*!< Number of attribute registers available */

	IMG_DEV_VIRTADDR			uPDSExecBase;

	IMG_DEV_VIRTADDR			uUSEExecBase;

} PVRSRV_SGX_CLIENT_INFO;


/*!
 ******************************************************************************
 * Internal device information structure for SGX
 *****************************************************************************/
typedef struct _PVRSRV_SGX_INTERNALDEV_INFO
{
	IMG_UINT32			ui32Flags;
	IMG_BOOL			bPDSTimerEnable;
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID				hHostCtlKernelMemInfoHandle;
#else
	IMG_HANDLE			hHostCtlKernelMemInfoHandle;
#endif
	IMG_DEV_VIRTADDR	sDummyStencilLoadDevVaddr;
	IMG_DEV_VIRTADDR	sDummyStencilStoreDevVAddr;
	IMG_BOOL			bForcePTOff;
	IMG_UINT32			ui32RegFlags;
}PVRSRV_SGX_INTERNALDEV_INFO;


/*
	Structures for KickTA API
*/
#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH) && !defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
#define SGX_MAX_VDM_STATE_RESTORE_PROGS		(2)

typedef struct _SGX_VDM_STATE_RESTORE_DATA_
{
    IMG_UINT32       ui32StateWord0;
    IMG_UINT32       ui32StateWord1;
} SGX_VDM_STATE_RESTORE_DATA;
#endif

typedef struct _SGX_KICKTA_COMMON_
{
	IMG_UINT32			ui32Frame;
	IMG_UINT32			ui32KickFlags;			/*!< Combination of SGX_KICKTA_FLAGS_xxxx flags */
	IMG_DEV_VIRTADDR	sVisTestResultMem;
	IMG_UINT32			ui32VisTestCount;

#if defined(__psp2__)
	IMG_UINT32			ui32Scene;
	IMG_UINT32			ui32SceneFlags;		/*!< Combination of SGX_KICKTA_SCENEFLAGS_xxxx flags */

	/*
		X and Y Max for MTE/TE Screens in pixels

		See SGXMKIF_TAREGISTERS::ui32MTEScreen/ui32TEScreen
	*/
	IMG_UINT32			ui32TAScreenXMax;
	IMG_UINT32			ui32TAScreenYMax;

	/*
		See EUR_CR_MASTER_MP_PRIMITIVE
	*/
	IMG_UINT16			ui16MaxDrawCallsPerCore;
	IMG_UINT16			ui16PrimitiveSplitThreshold;
#endif

#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#if !defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
	IMG_DEV_VIRTADDR	sVDMSARestoreDataDevAddr[SGX_MAX_VDM_STATE_RESTORE_PROGS];
	#endif
	#if !defined(SGX_FEATURE_MTE_STATE_FLUSH)
	IMG_DEV_VIRTADDR	sTAStateShadowDevAddr;
	#endif
#endif

	IMG_UINT32			ui32ISPBGObjDepth;
	IMG_UINT32			ui32ISPBGObj;
	IMG_UINT32			ui32ISPIPFMisc;

#if defined(SGX545)
	IMG_UINT32			ui32GSGBase;
	IMG_UINT32			ui32GSGStride;
	IMG_UINT32			ui32GSGWrapAddr;
	IMG_UINT32			ui32GSGStateStoreBase;
	IMG_UINT32			ui321stPhaseComplexGeomBufferBase;
	IMG_UINT32			ui321stPhaseComplexGeomBufferSize;
	IMG_UINT32			ui32VtxBufWritePointerPDSProgBaseAddr;
	IMG_UINT32			ui32VtxBufWritePointerPDSProgDataSize;
	IMG_UINT32			ui32SCWordCopyProgram;
	IMG_UINT32			ui32ITPProgram;
	IMG_UINT32			ui32OrderDepAASampleGrid;
	IMG_UINT32			ui32OrderDepAASampleGrid2;
#else
	IMG_UINT32			ui32ISPPerpendicular;
	IMG_UINT32			ui32ISPCullValue;
#endif
#if defined(EUR_CR_DOUBLE_PIXEL_PARTITIONS)
	IMG_UINT32			ui32DoublePixelPartitions;
#endif
#if defined(EUR_CR_PDS_PP_INDEPENDANT_STATE)
	IMG_UINT32			ui32TriangleSplitPixelThreshold;
#if defined(__psp2__)
	/*
		Controls the value of EUR_CR_PDS_PP_INDEPENDANT_STATE

		This value is ignored if ui32TriangleSplitPixelThreshold > 0
	*/
	IMG_BOOL			bPerQuadrantPixelSplit;
#endif
#endif
	IMG_DEV_VIRTADDR	sISPZLoadBase;
	IMG_DEV_VIRTADDR	sISPStencilLoadBase;
	IMG_DEV_VIRTADDR	sISPZStoreBase;
	IMG_DEV_VIRTADDR	sISPStencilStoreBase;
#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32			ui32RTAStideZ;
	IMG_UINT32			ui32RTAStideS;
#endif

#if defined(__psp2__)
	IMG_BOOL			bSeperateStencilLoad;
	IMG_BOOL			bSeperateStencilStore;
#else
	IMG_BOOL			bSeperateStencilLoadStore;
#endif

	IMG_UINT32			ui32ZLSCtl;
	IMG_UINT32			ui32ISPValidId;
	IMG_UINT32			ui32ISPDBias;		
#if defined(SGX_FEATURE_DEPTH_BIAS_OBJECTS)
	IMG_UINT32			ui32ISPDBias1;
	IMG_UINT32			ui32ISPDBias2;
#endif
	IMG_UINT32			ui32ISPSceneBGObj;

	IMG_UINT32			ui32EDMPixelPDSAddr;
	IMG_UINT32			ui32EDMPixelPDSDataSize;
	IMG_UINT32			ui32EDMPixelPDSInfo;

	IMG_UINT32			ui32PixelBE;
#if defined(SGX_FEATURE_TAG_YUV_TO_RGB)
	IMG_UINT32			ui32CSC0Coeff01;
	IMG_UINT32			ui32CSC0Coeff23;
	IMG_UINT32			ui32CSC0Coeff45;
	IMG_UINT32			ui32CSC0Coeff67;
	IMG_UINT32			ui32CSC1Coeff01;
	IMG_UINT32			ui32CSC1Coeff23;
	IMG_UINT32			ui32CSC1Coeff45;
	IMG_UINT32			ui32CSC1Coeff67;

	#if !defined(SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC)
	IMG_UINT32			ui32CSC0Coeff8;
	IMG_UINT32			ui32CSC1Coeff8;
	IMG_UINT32			ui32CSCScale;
	#else
	IMG_UINT32			ui32CSC0Coeff89;
	IMG_UINT32			ui32CSC1Coeff89;
	IMG_UINT32			ui32CSC0Coeff1011;
	IMG_UINT32			ui32CSC1Coeff1011;
	#endif

#endif
	IMG_UINT32			ui32Filter0Left;
	#if defined(SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF)
	IMG_UINT32			ui32Filter0Centre;
	#endif
	IMG_UINT32			ui32Filter0Right;
	IMG_UINT32			ui32Filter0Extra;
	IMG_UINT32			ui32Filter1Left;
	#if defined(SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF)
	IMG_UINT32			ui32Filter1Centre;
	#endif
	IMG_UINT32			ui32Filter1Right;
	IMG_UINT32			ui32Filter1Extra;
	IMG_UINT32			ui32Filter2Left;
	IMG_UINT32			ui32Filter2Right;
	IMG_UINT32			ui32Filter2Extra;
	IMG_UINT32			ui32FilterTable;

	IMG_UINT32			ui32USEStoreRange;
	IMG_UINT32			ui32USELoadRedirect;
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
	IMG_UINT32			ui32BIFTile0Config;
#endif
#if defined(EUR_CR_TPU_LUMA0)
	IMG_UINT32			ui32TPULuma0;
	IMG_UINT32			ui32TPULuma1;
	IMG_UINT32			ui32TPULuma2;
#endif

	/*
		TA Ctrl stream base
	*/
	IMG_DEV_VIRTADDR	sTABufferCtlStreamBase;
	/*
		Address of terminate in control stream
	*/
	IMG_DEV_VIRTADDR	sTABufferCtlStreamTerminate;

	IMG_UINT32			ui32MTECtrl;

	IMG_UINT32			aui32SpecObject[3];			/*!< 3 words for PDS hardware background object */
#if defined(__psp2__)
	/*
		Used for the background object vertex positions
	*/
	IMG_UINT32			ui32BGObjWidth;
	IMG_UINT32			ui32BGObjHeight;
#endif

	IMG_UINT32			ui32NumTAStatusVals;
	IMG_UINT32			ui32Num3DStatusVals;
	IMG_UINT32			ui32NumSrcSyncs;


} SGX_KICKTA_COMMON;

#if defined(TRANSFER_QUEUE)
#define SGX_MAX_TRANSFER_UPDATES		5
#if defined(SGXTQ_PREP_SUBMIT_SEPERATE)
#define SGXTQ_MAX_COMMANDS 96 /* 10 mipmap levels for 128bit textures */
#else
#define SGXTQ_MAX_COMMANDS 1 /* 10 mipmap levels for 128bit textures */
#endif
#define SGXTQ_MAX_SURFACES				3
#define SGXTQ_MAX_RECTS					3
#endif

typedef struct _SGX_STATUS_UPDATE_
{
	CTL_STATUS				sCtlStatus;
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hKernelMemInfo;
#else
	IMG_HANDLE				hKernelMemInfo;
#endif
} SGX_STATUS_UPDATE;

typedef struct _SGX_KICKTA_
{
	SGX_KICKTA_COMMON		sKickTACommon;

	PVRSRV_CLIENT_SYNC_INFO	**ppsRenderSurfSyncInfo;
	IMG_DEV_VIRTADDR 		sPixEventUpdateDevAddr;
	IMG_UINT32				*psPixEventUpdateList;
	IMG_UINT32				*psHWBgObjPrimPDSUpdateList;

#if defined(SUPPORT_SGX_GENERALISED_SYNCOBJECTS)
	/* TA phase */
	IMG_UINT32				ui32NumTADstSyncs;
	PVRSRV_CLIENT_SYNC_INFO *apsTADstSurfSyncInfo[SGX_MAX_TA_DST_SYNCS];
	IMG_UINT32				ui32NumTASrcSyncs;
	PVRSRV_CLIENT_SYNC_INFO *apsTASrcSurfSyncInfo[SGX_MAX_TA_SRC_SYNCS];
	/* 3D Phase */
	IMG_UINT32				ui32Num3DSrcSyncs;
	PVRSRV_CLIENT_SYNC_INFO *aps3DSrcSurfSyncInfo[SGX_MAX_3D_SRC_SYNCS];
#else
	PVRSRV_CLIENT_SYNC_INFO *apsSrcSurfSyncInfo[SGX_MAX_SRC_SYNCS];
#endif

#if defined(SUPPORT_SGX_NEW_STATUS_VALS)
	SGX_STATUS_UPDATE		asTAStatusUpdate[SGX_MAX_TA_STATUS_VALS];
	SGX_STATUS_UPDATE		as3DStatusUpdate[SGX_MAX_3D_STATUS_VALS];
#else
	PVRSRV_CLIENT_SYNC_INFO	*apsTAStatusInfo[SGX_MAX_TA_STATUS_VALS];
	PVRSRV_CLIENT_SYNC_INFO	*aps3DStatusInfo[SGX_MAX_3D_STATUS_VALS];
#endif

	IMG_HANDLE				hTQContext;
	IMG_HANDLE				hRenderContext;
	IMG_HANDLE				hRTDataSet;

#if defined (SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32				ui32NumRTs;
	IMG_UINT32				ui32IdxRT;
#endif

} SGX_KICKTA;

typedef struct _SGX_KICKTA_OUTPUT_
{
	IMG_BOOL			bSPMOutOfMemEvent;
	IMG_UINT32			ui32NumPBPagesFree;
	IMG_UINT32			ui32MaxZTileX;
	IMG_UINT32			ui32MaxZTileY;

	PVRSRV_HWREG		*psZLSReg;
	IMG_PUINT32			pui32VDMBaseRegVal;

} SGX_KICKTA_OUTPUT;


#if defined (SUPPORT_SID_INTERFACE)
typedef struct _SGX_KICKTA_DUMP_ROFF_
{
	IMG_SID				hKernelMemInfo;						/*< Buffer handle */
	IMG_UINT32			uiAllocIndex;						/*< Alloc index for LDDM */
	IMG_UINT32			ui32Offset;							/*< Byte offset to value to dump */
	IMG_UINT32			ui32Value;							/*< Actual value to dump */
	IMG_PCHAR			pszName;							/*< Name of buffer */
} SGX_KICKTA_DUMP_ROFF, *PSGX_KICKTA_DUMP_ROFF;


typedef struct _SGX_KICKTA_DUMP_BUFFER_
{
	IMG_UINT32			ui32SpaceUsed;
	IMG_UINT32			ui32Start;							/*< Byte offset of start to dump */
	IMG_UINT32			ui32End;							/*< Byte offset of end of dump (non-inclusive) */
	IMG_UINT32			ui32BufferSize;						/*< Size of buffer */
	IMG_UINT32			ui32BackEndLength;					/*< Size of back end portion, if End < Start */
	IMG_UINT32			uiAllocIndex;
	IMG_SID				hKernelMemInfo;						/*< MemInfo handle for the circular buffer */
	IMG_PVOID			pvLinAddr;
#if defined(SUPPORT_SGX_NEW_STATUS_VALS)
	IMG_SID				hCtrlKernelMemInfo;					/*< MemInfo handle for the control structure of the
																circular buffer */
	IMG_DEV_VIRTADDR	sCtrlDevVAddr;						/*< Device virtual address of the memory in the 
																control structure to be checked */
#endif
	IMG_PCHAR			pszName;							/*< Name of buffer */
} SGX_KICKTA_DUMP_BUFFER, *PSGX_KICKTA_DUMP_BUFFER;


#ifdef PDUMP
/*
	PDUMP version of above kick structure
*/
typedef struct _SGX_KICKTA_PDUMP_
{
	// Bitmaps to dump
	PSGX_KICKTA_DUMPBITMAP      psPDumpBitmapArray;
	IMG_UINT32                  ui32PDumpBitmapSize;

	// Misc buffers to dump (e.g. TA, PDS etc..)
	PSGX_KICKTA_DUMP_BUFFER	psBufferArray;
	IMG_UINT32                  ui32BufferArraySize;

	// Roffs to dump
	PSGX_KICKTA_DUMP_ROFF       psROffArray;
	IMG_UINT32                  ui32ROffArraySize;
} SGX_KICKTA_PDUMP, *PSGX_KICKTA_PDUMP;
#endif	/* PDUMP */
#endif /* #if defined (SUPPORT_SID_INTERFACE) */


/******************************************************************************
 General constants associated with interface
******************************************************************************/
#define SGX_SPECIALOBJECT_SIZE		512

#define SGX_USE_MINTEMPREGS		0


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
////////////////////////////new APIs///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


#define PVRSRV_SGX_HOSTRENDER_FORCECTXRESET				(0x00000001)


/*
	FIXME: allow pointer to Kernel CCB
	remove when the HAL stops queuing blits and migrates work to srvkm
*/

/*
	ui32ClientKickFlags
*/
#define PVRSRV_SGX_CLIENT_INFO_KICKFLAGS_DEFERWAITFORRENDERCOMPLETE		0x00000001
#define PVRSRV_SGX_CLIENT_INFO_KICKFLAGS_DEFERWAITFORFREE3DMEMORY		0x00000002

#if defined(TRANSFER_QUEUE)
/******************************************************************************
 * transfer queue structures
 *****************************************************************************/



/* enum types that are available to the client */


/* Filter type to use when performing operations */
typedef enum _SGXTQ_FILTERTYPE_
{
	SGXTQ_FILTERTYPE_POINT = 0,
	SGXTQ_FILTERTYPE_LINEAR,
	SGXTQ_FILTERTYPE_ANISOTROPIC
} SGXTQ_FILTERTYPE;

/* Colourkey */
typedef enum _SGXTQ_COLOURKEY_
{
	SGXTQ_COLOURKEY_NONE = 0,
	SGXTQ_COLOURKEY_SOURCE,
	SGXTQ_COLOURKEY_DEST,
	SGXTQ_COLOURKEY_SOURCE_PASS
} SGXTQ_COLOURKEY;

/* Copy order */
typedef enum _SGXTQ_COPYORDER_
{
	SGXTQ_COPYORDER_AUTO = 0,
	SGXTQ_COPYORDER_TL2BR,
	SGXTQ_COPYORDER_TR2BL,
	SGXTQ_COPYORDER_BR2TL,
	SGXTQ_COPYORDER_BL2TR
} SGXTQ_COPYORDER;

/* Rotation */
typedef enum _SGXTQ_ROTATION_
{
	SGXTQ_ROTATION_NONE = 0,
	SGXTQ_ROTATION_90,
	SGXTQ_ROTATION_180,
	SGXTQ_ROTATION_270
} SGXTQ_ROTATION;

/* Alpha blend */
typedef enum _SGXTQ_ALPHA_
{
	SGXTQ_ALPHA_NONE = 0,
	SGXTQ_ALPHA_SOURCE,						/* Cdst = Csrc*Asrc		+ Cdst*(1-Asrc)				*/
	SGXTQ_ALPHA_PREMUL_SOURCE,				/* Cdst = Csrc			+ Cdst*(1-Asrc)				*/
	SGXTQ_ALPHA_GLOBAL,						/* Cdst = Csrc*Aglob	+ Cdst*(1-Aglob)			*/
	SGXTQ_ALPHA_PREMUL_SOURCE_WITH_GLOBAL	/* Cdst = Csrc*Aglob	+ Cdst*(1-Asrc)*(1-Aglob)	*/
} SGXTQ_ALPHA;

typedef enum _SGXTQ_MEMLAYOUT_
{
	SGXTQ_MEMLAYOUT_2D = 0,
	SGXTQ_MEMLAYOUT_3D,
	SGXTQ_MEMLAYOUT_CEM,
	SGXTQ_MEMLAYOUT_STRIDE,
	SGXTQ_MEMLAYOUT_TILED,
	SGXTQ_MEMLAYOUT_OUT_LINEAR,
	SGXTQ_MEMLAYOUT_OUT_TILED,
	SGXTQ_MEMLAYOUT_OUT_TWIDDLED
} SGXTQ_MEMLAYOUT;

/* Available transfer queue operation types */
typedef enum _SGXTQ_BLITTYPE_
{
	SGXTQ_BLIT = 1,
#if defined(SGX_FEATURE_2D_HARDWARE)
	SGXTQ_2DHWBLIT,
#endif
	SGXTQ_MIPGEN,
	SGXTQ_VIDEO_BLIT,
	SGXTQ_FILL,
	SGXTQ_BUFFERBLT,
	SGXTQ_CUSTOM,
	SGXTQ_FULL_CUSTOM,
	SGXTQ_TEXTURE_UPLOAD,
	SGXTQ_CLIP_BLIT,
	SGXTQ_CUSTOMSHADER_BLIT,
	SGXTQ_COLOURLUT_BLIT,
	SGXTQ_CLEAR_TYPE_BLEND,
	SGXTQ_TATLAS_BLIT,
	SGXTQ_ARGB2NV12_BLIT,

} SGXTQ_BLITTYPE;

/* Support structures that are used in transfer queue operations */

/* A surface describes a source or destination for a transfer operation */
typedef struct _SGXTQ_TQSURFACE_
{
#ifdef BLITLIB
	const PVRSRV_CLIENT_MEM_INFO	*psClientMemInfo; /*Memory info, to get device and cpu virtual addresses */
	IMG_SIZE_T			uiMemoryOffset; /*offset of the beginning of the surface from the base psClientMemInfo*/
#define SGX_TQSURFACE_GET_LINADDR(sSurf) ((sSurf).psClientMemInfo->pvLinAddr + (sSurf).uiMemoryOffset)
#define SGX_TQSURFACE_GET_DEV_VADDR(sSurf) (((sSurf).psClientMemInfo ? (sSurf).psClientMemInfo->sDevVAddr.uiAddr : 0) + (sSurf).uiMemoryOffset)
#define SGX_TQSURFACE_SET_ADDR(sSurf, psClMemInf, offset) ((sSurf).psClientMemInfo=(psClMemInf), (sSurf).uiMemoryOffset=(offset))
#else
	IMG_DEV_VIRTADDR sDevVAddr;
#define SGX_TQSURFACE_GET_DEV_VADDR(sSurf) ((sSurf).sDevVAddr.uiAddr)
#define SGX_TQSURFACE_SET_ADDR(sSurf, psClMemInf, offset) ((sSurf).sDevVAddr.uiAddr=((psClMemInf) ? (psClMemInf)->sDevVAddr.uiAddr : 0) + (offset))
#endif
	IMG_UINT32			ui32Width; /* In texels - Ignored for sources in custom blits */
	IMG_UINT32			ui32Height;  /* In texels - Ignored for sources in custom blits */
	IMG_INT32			i32StrideInBytes; /* In bytes - Ignored for sources in custom blits */
	PVRSRV_PIXEL_FORMAT	eFormat;    /* - Ignored for sources in custom blits */
	SGXTQ_MEMLAYOUT		eMemLayout; /* - Ignored for sources in custom blits */
	IMG_UINT32			ui32ChunkStride; /* Chunk stride for >32 bpp surfaces */
	PVRSRV_CLIENT_SYNC_INFO	*psSyncInfo; /* XXX it's also in psClientMemInfo, but don't remove as it's set to NULL when not supposed to be used */
#ifdef BLITLIB
	IMG_RECT			sRect;
#endif
	IMG_UINT32			ui32ChromaPlaneOffset[2]; // Offset to chroma planes from start of surface memory
} SGXTQ_SURFACE;

/* Entries specific to different blit types */

/* Blit operation is a copy from 1 source to 1 destination.
	Supported operations:
	- Stretch
	- Gamma
	- Format conversion
	- Rotation
	- Colour key
	- Alpha
	- Custom Rop
*/
typedef struct _SGXTQ_BLITOP_
{
	SGXTQ_FILTERTYPE	eFilter;
	IMG_UINT32			ui32ColourKey; /* In A8R8G8B8 format */
	IMG_UINT32			ui32ColourKeyMask;	/* In A8R8G8B8 format */
	IMG_BOOL			bEnableGamma;
	SGXTQ_COLOURKEY		eColourKey;
	SGXTQ_ROTATION		eRotation;
	SGXTQ_COPYORDER		eCopyOrder;
	SGXTQ_ALPHA			eAlpha;
	IMG_BYTE			byGlobalAlpha;
	IMG_BYTE			byCustomRop3;
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
	IMG_UINT32 ui32BIFTile0Config;
#endif
	IMG_DEV_VIRTADDR	sUSEExecAddr;	/* Caller's pixel shader code, or NULL for default source copy blt */
	IMG_UINT32			UseParams[2];	/* Per-blt params used in above code */
	IMG_UINT32	 		uiNumTemporaryRegisters; /* Number of temporary registers that the pixel shader sUSEExecAddr uses */
	IMG_BOOL			bEnablePattern; /* Disable scaling, enable pattern wrapping, when source rect < dest rect */
    IMG_BOOL            bSingleSource;  /* It allows to use SINGLESOURCE texture in one TQ branch condition instead of forcing to use TWOSOURCE */
} SGXTQ_BLITOP;

typedef struct _SGXTQ_MIPGENOP_
{
	SGXTQ_FILTERTYPE	eFilter;
	IMG_UINT32			ui32Levels;
} SGXTQ_MIPGENOP;

typedef struct _SGXTQ_FILLOP_
{
	IMG_UINT32 ui32Colour;
	IMG_BYTE byCustomRop3;
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
	IMG_UINT32 ui32BIFTile0Config;
#endif
} SGXTQ_FILLOP;

typedef struct _SGXTQ_BUFFERBLTOP_
{
	IMG_UINT32 ui32Bytes;
} SGXTQ_BUFFERBLTOP;


#if defined (SGX_FEATURE_UNIFIED_STORE_64BITS)
#define SGXTQ_PBESTATE_WORDS            7
#else
#if defined(SGX_FEATURE_PIXELBE_32K_LINESTRIDE)
#define SGXTQ_PBESTATE_WORDS            6       /* 2 for emitpix1 3 for emitpix2 + 1 sideband*/
#else
#define SGXTQ_PBESTATE_WORDS            5       /* 2 for emitpix1 2 for emitpix2 + 1 sideband*/
#endif
#endif
/* the sideband is always the last, the rest is packed in front*/
#define SGXTQ_PBESTATE_SBINDEX          (SGXTQ_PBESTATE_WORDS - 1)


typedef struct _SGXTQ_CUSTOMOP_
{
	/*
		This type of custom operation specifies the USE and PDS address
	*/
	IMG_DEV_VIRTADDR	sDevVAddrUSECode;
	IMG_DEV_VIRTADDR	sDevVAddrPDSPrimCode;
	IMG_UINT32			ui32PDSPrimDataSize;
	IMG_DEV_VIRTADDR	sDevVAddrPDSSecCode;
	IMG_UINT32			ui32PDSSecDataSize;
	IMG_UINT32			ui32PDSPrimNumAttr;
	IMG_UINT32			ui32PDSSecNumAttr;
	IMG_UINT32			ui32NumTempRegs;

	IMG_UINT32			aui32PBEState[SGXTQ_PBESTATE_WORDS];

	IMG_BOOL			bLoadFIRCoefficients;
	IMG_UINT32			ui32FIRHFilterTable;
	IMG_UINT32			ui32FIRHFilterLeft0;
	IMG_UINT32			ui32FIRHFilterRight0;
	IMG_UINT32			ui32FIRHFilterExtra0;
	IMG_UINT32			ui32FIRHFilterLeft1;
	IMG_UINT32			ui32FIRHFilterRight1;
	IMG_UINT32			ui32FIRHFilterExtra1;
	IMG_UINT32			ui32FIRHFilterLeft2;
	IMG_UINT32			ui32FIRHFilterRight2;
	IMG_UINT32			ui32FIRHFilterExtra2;
#if defined(SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF)
	IMG_UINT32			ui32FIRHFilterCentre0;
	IMG_UINT32			ui32FIRHFilterCentre1;
#endif
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
	IMG_UINT32			ui32BIFTile0Config;
#endif

	IMG_UINT32			ui32NumPatches;
	PVRSRV_MEMUPDATE	asMemUpdates[SGX_MAX_TRANSFER_UPDATES];
} SGXTQ_CUSTOMOP;

typedef struct _SGXTQ_FULLCUSTOMOP_
{
	/*
		This type of custom blit specifies everything
	*/
	IMG_DEV_VIRTADDR	sDevVAddrVertexData;
	IMG_UINT32			ui32StateSize;
	IMG_UINT32			ui32BIFBase;


	IMG_RECT			sRenderBox;
	IMG_UINT32			aui32PBEState[SGXTQ_PBESTATE_WORDS];

	IMG_UINT32			ui32ISPBgObjReg;
	IMG_UINT32			ui32ISPBgObjTagReg;
	IMG_UINT32			ui32ISPRenderReg;
	IMG_UINT32			ui32ISPRgnBaseReg;

#if defined(SGX_FEATURE_TAG_YUV_TO_RGB)
	IMG_BOOL			bLoadYUVCoefficients;
	IMG_UINT32			ui32CSC0Coeff01;
	IMG_UINT32			ui32CSC0Coeff23;
	IMG_UINT32			ui32CSC0Coeff45;
	IMG_UINT32			ui32CSC0Coeff67;
#if !defined(SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC)
	IMG_UINT32			ui32CSC0Coeff8;
#else
	IMG_UINT32			ui32CSC0Coeff89;
	IMG_UINT32			ui32CSC0Coeff1011;
#endif
	IMG_UINT32			ui32CSC1Coeff01;
	IMG_UINT32			ui32CSC1Coeff23;
	IMG_UINT32			ui32CSC1Coeff45;
	IMG_UINT32			ui32CSC1Coeff67;
#if !defined(SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC)
	IMG_UINT32			ui32CSC1Coeff8;
#else
	IMG_UINT32			ui32CSC1Coeff89;
	IMG_UINT32			ui32CSC1Coeff1011;
#endif
	IMG_UINT32			ui32CSCScale;
#endif

#if defined(SGX_FEATURE_TAG_LUMAKEY)
	IMG_BOOL			bLoadLumaKeyCoefficients;
	IMG_UINT32			ui32LumaKeyCoeff0;
	IMG_UINT32			ui32LumaKeyCoeff1;
	IMG_UINT32			ui32LumaKeyCoeff2;
#endif

	IMG_BOOL			bLoadFIRCoefficients;
	IMG_UINT32			ui32FIRHFilterTable;
	IMG_UINT32			ui32FIRHFilterLeft0;
	IMG_UINT32			ui32FIRHFilterRight0;
	IMG_UINT32			ui32FIRHFilterExtra0;
	IMG_UINT32			ui32FIRHFilterLeft1;
	IMG_UINT32			ui32FIRHFilterRight1;
	IMG_UINT32			ui32FIRHFilterExtra1;
	IMG_UINT32			ui32FIRHFilterLeft2;
	IMG_UINT32			ui32FIRHFilterRight2;
	IMG_UINT32			ui32FIRHFilterExtra2;
#if defined(SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF)
	IMG_UINT32			ui32FIRHFilterCentre0;
	IMG_UINT32			ui32FIRHFilterCentre1;
#endif
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
	IMG_UINT32			ui32BIFTile0Config;
#endif

	IMG_UINT32			ui32NumPatches;
	PVRSRV_MEMUPDATE	asMemUpdates[SGX_MAX_TRANSFER_UPDATES];
} SGXTQ_FULLCUSTOMOP;

typedef struct _SGXTQ_TEXTURE_UPLOADOP_
{
	IMG_PBYTE pbySrcLinAddr;
	IMG_UINT32 ui32BytesPP;
} SGXTQ_TEXTURE_UPLOADOP;

#if defined(SGX_FEATURE_2D_HARDWARE)
typedef struct __SGXTQ_2DBLITOP_
{
	IMG_UINT32	ui32CtrlSizeInDwords;
	IMG_UINT32	* pui32CtrlStream;
	IMG_UINT32  ui32AlphaRegValue;

} SGXTQ_2DBLITOP;
#endif

typedef struct _SGXTQ_CUSTOMSHADEROP_
{
	IMG_DEV_VIRTADDR	sUSEExecAddr;
	IMG_UINT32	 		ui32NumPAs;
	IMG_UINT32	 		ui32NumSAs;
	IMG_UINT32			UseParams[2];		// Per blt constants via secondaries
	IMG_UINT32	 		ui32NumTempRegs;

	/* enable load SAs from DMA */
	IMG_BOOL			bUseDMAForSAs;			/*!< DMA copy enabled if this is true */
	IMG_DEV_VIRTADDR	sDevVAddrDMASrc;		/*!< src addr for DMA */
	IMG_UINT32			ui32LineOffset;			/*!< primary instance data offset */

	/* PBE rotation on the destination */
	SGXTQ_ROTATION		eRotation;

	/* per input layer TF method*/
	SGXTQ_FILTERTYPE	aeFilter[SGXTQ_MAX_SURFACES];
} SGXTQ_CUSTOMSHADEROP;

typedef struct _SGXTQ_COLOURLUTOP_
{
	PVRSRV_PIXEL_FORMAT	eLUTPxFmt;			// Not supported yet
	IMG_UINT32			ui32KeySizeInBits;	// LUT key size 8 bits -> 256 entries
	IMG_DEV_VIRTADDR	sLUTDevVAddr;
} SGXTQ_COLOURLUTOP;

typedef struct _SGXTQ_CLIPBLITOP_
{
	IMG_RECT			* psRects;
	IMG_UINT32			ui32RectNum;
	
	/* Determines whether to use source rects or clip rects 
	   to to generate tex coords */
	IMG_BOOL			bUseSrcRectsForTexCoords; 
} SGXTQ_CLIPBLITOP;

typedef struct _SGXTQ_VPBCOEFFS_
{
	/* red*/
	IMG_INT16		i16YR;
	IMG_INT16		i16UR;
	IMG_INT16		i16VR;

	IMG_INT16		i16ConstR;
	IMG_INT16		i16ShiftR;

	/* green*/
	IMG_INT16		i16YG;
	IMG_INT16		i16UG;
	IMG_INT16		i16VG;

	IMG_INT16		i16ConstG;
	IMG_INT16		i16ShiftG;

	/* blue*/
	IMG_INT16		i16YB;
	IMG_INT16		i16UB;
	IMG_INT16		i16VB;

	IMG_INT16		i16ConstB;
	IMG_INT16		i16ShiftB;
} SGXTQ_VPBCOEFFS;


typedef struct _SGXTQ_VPBLITOP_
{
	/* set to IMG_FALSE to use the default set of coefficients*/
	IMG_BOOL			bCoeffsGiven;
	SGXTQ_VPBCOEFFS		sCoeffs;

	/* if set the Y plane is separate from U/V plane(s) */
	IMG_BOOL			bSeparatePlanes;
	/* first plane is at the first src DevVAddr, this array is for subsequent planes*/
	IMG_DEV_VIRTADDR	asPlaneDevVAddr[2];
} SGXTQ_VPBLITOP;


/* Structures passed in as parameters to transfer queue functions */
#if defined (__psp2__)
typedef struct _SGX_TRANSFERCONTEXTCREATE_
{
	IMG_SID					hDevMemContext;
	IMG_UINT32				hMemBlockProcRef;
} SGX_TRANSFERCONTEXTCREATE;
#else
typedef struct _SGX_TRANSFERCONTEXTCREATE_
{
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hDevMemContext;
	IMG_EVENTSID			hOSEvent;
#else
	IMG_HANDLE				hDevMemContext;
	IMG_HANDLE				hOSEvent;
#endif
#if defined(SUPPORT_KERNEL_SGXTQ)
	IMG_HANDLE hCallbackHandle;
#endif
} SGX_TRANSFERCONTEXTCREATE;
#endif


/* transfer queue flags */
#define SGX_KICKTRANSFER_FLAGS_TATQ_SYNC		0x00000001U
#define SGX_KICKTRANSFER_FLAGS_3DTQ_SYNC		0x00000002U

/* these flags refer to the first source */
#define SGX_TRANSFER_FLAGS_INVERTX				0x00000004U
#define SGX_TRANSFER_FLAGS_INVERTY				0x00000008U
#define SGX_TRANSFER_FLAGS_INVERSE_TRIANGLE		0x00000010U

#define SGX_TRANSFER_FLAGS_DITHER				0x00000020U

#define SGX_TRANSFER_DISPATCH_DISABLE_PTLA		0x00010000U
#define SGX_TRANSFER_DISPATCH_DISABLE_3D		0x00020000U
#define SGX_TRANSFER_DISPATCH_DISABLE_SW		0x00040000U
#define SGX_TRANSFER_DISPATCH_MASK				(SGX_TRANSFER_DISPATCH_DISABLE_PTLA	| \
												SGX_TRANSFER_DISPATCH_DISABLE_3D	| \
												SGX_TRANSFER_DISPATCH_DISABLE_SW)

/* Source layer 0 rotation via UV coords (not dest via PBE) */
#define SGX_TRANSFER_LAYER_0_ROT_90				0x00000100
#define SGX_TRANSFER_LAYER_0_ROT_180			0x00000200
#define SGX_TRANSFER_LAYER_0_ROT_270			0x00000400

typedef struct _SGXTQ_CLEARTYPEBLEND_
{
	IMG_UINT32 			ui32GammaSurfaceIndex;
	IMG_UINT32 			ui32Colour;
	IMG_UINT32 			ui32Colour2;
	IMG_UINT32			ui32Gamma;
	IMG_UINT32			ui32GammaSurfacePitch;
} SGXTQ_CLEARTYPEBLEND;


typedef struct _SGXTQ_TATLASBLITOP_
{
	SGXTQ_ALPHA			eAlpha;
	IMG_UINT32			ui32NumMappings;
	IMG_RECT			* psSrcRects;
	IMG_RECT			* psDstRects;
} SGXTQ_TATLASBLITOP;


typedef struct _SGXTQ_ARGB2NV12OP_
{
	IMG_DEV_VIRTADDR	sUVDevVAddr;
} SGXTQ_ARGB2NV12OP;


typedef struct _SGX_QUEUETRANSFER_
{
	IMG_UINT32		ui32Flags;
	SGXTQ_BLITTYPE	eType; /* Type of transfer operation */

	union {
		SGXTQ_BLITOP			sBlit;
		SGXTQ_MIPGENOP			sMipGen;
		SGXTQ_BUFFERBLTOP		sBufBlt;
		SGXTQ_CUSTOMOP			sCustom;
		SGXTQ_FULLCUSTOMOP		sFullCustom;
		SGXTQ_FILLOP			sFill;
		SGXTQ_TEXTURE_UPLOADOP 	sTextureUpload;
#if defined(SGX_FEATURE_2D_HARDWARE)
		SGXTQ_2DBLITOP			s2DBlit;
#endif
		SGXTQ_CUSTOMSHADEROP	sCustomShader;
		SGXTQ_COLOURLUTOP		sColourLUT;
		SGXTQ_CLIPBLITOP		sClipBlit;
		SGXTQ_VPBLITOP			sVPBlit;
		SGXTQ_CLEARTYPEBLEND	sClearTypeBlend;
		SGXTQ_TATLASBLITOP		sTAtlas;
		SGXTQ_ARGB2NV12OP		sARGB2NV12;
	} Details;

	IMG_UINT32		ui32NumSources;
	SGXTQ_SURFACE	asSources[SGXTQ_MAX_SURFACES];

	IMG_UINT32		ui32NumDest;
	SGXTQ_SURFACE	asDests[1];
	
#ifdef BLITLIB
#define SGX_QUEUETRANSFER_SRC_RECT(sQueueTransfer,i) (sQueueTransfer).asSources[i].sRect
#define SGX_QUEUETRANSFER_DST_RECT(sQueueTransfer,i) (sQueueTransfer).asDests[i].sRect
#define SGX_QUEUETRANSFER_NUM_SRC_RECTS(sQueueTransfer) (sQueueTransfer).ui32NumSources
#define SGX_QUEUETRANSFER_NUM_DST_RECTS(sQueueTransfer) (sQueueTransfer).ui32NumDest
#else
	/* FIXME: move these into the surface structure, dropping src and dst prefix */
	IMG_UINT32 ui32NumSrcRects;
	IMG_RECT asSrcRects[SGXTQ_MAX_RECTS];

	/* FIXME: move these into the surface structure, dropping src and dst prefix */
	IMG_UINT32 ui32NumDestRects;
	IMG_RECT asDestRects[1];

#define SGX_QUEUETRANSFER_SRC_RECT(sQueueTransfer,i) (sQueueTransfer).asSrcRects[i]
#define SGX_QUEUETRANSFER_DST_RECT(sQueueTransfer,i) (sQueueTransfer).asDestRects[i]
#define SGX_QUEUETRANSFER_NUM_SRC_RECTS(sQueueTransfer) (sQueueTransfer).ui32NumSrcRects
#define SGX_QUEUETRANSFER_NUM_DST_RECTS(sQueueTransfer) (sQueueTransfer).ui32NumDestRects
#endif

#if defined(SGXTQ_PREP_SUBMIT_SEPERATE)
	IMG_HANDLE		*phTransferSubmit;
#endif

	/* Dump transfer even if frame isn't captured*/
	IMG_BOOL		bPDumpContinuous;

	IMG_UINT32			ui32NumStatusValues;
	PVRSRV_MEMUPDATE	asMemUpdates[SGX_MAX_TRANSFER_STATUS_VALS];
} SGX_QUEUETRANSFER;

typedef struct _SGX_SUBMITTRANSFER_
{
	IMG_UINT32			ui32NumStatusValues;
	PVRSRV_MEMUPDATE	asMemUpdates[SGX_MAX_TRANSFER_STATUS_VALS];

	IMG_HANDLE hTransferSubmit;

#if defined(PDUMP)
	SGX_KICKTA_PDUMP	sTransferPDUMP;

	/* Dump transfer even if frame isn't captured*/
	IMG_BOOL		bPDumpContinuous;
#endif
} SGX_SUBMITTRANSFER;

#endif /* TRANSFER_QUEUE */


/******************************************************************************
 * device specific API prototypes
 *****************************************************************************/

/* returns SGX HW mappings for the client, e.g. CCB and CCBkicker */
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXGetClientInfo(PVRSRV_DEV_DATA *psDevData,
										   PVRSRV_SGX_CLIENT_INFO *psSGXInfo);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXReleaseClientInfo(PVRSRV_DEV_DATA *psDevData,
											   PVRSRV_SGX_CLIENT_INFO *psSGXInfo);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXGetInternalDevInfo(const PVRSRV_DEV_DATA *psDevData,
												PVRSRV_SGX_INTERNALDEV_INFO *psSGXInternalDevInfo);


IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXScheduleProcessQueues(PVRSRV_DEV_DATA *psDevData);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXKickTA(PVRSRV_DEV_DATA			*psDevData,
									SGX_KICKTA				*psKickTA,
									SGX_KICKTA_OUTPUT *psKickTAOutput,
									IMG_PVOID				pvKickTAPDUMP,
									IMG_PVOID				pvKickSubmit);
#if defined(SGXTQ_PREP_SUBMIT_SEPERATE)
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXKickSubmit (PVRSRV_DEV_DATA *psDevData,
									   IMG_PVOID psKickSubmit);
#endif


IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXCreateRenderContext(PVRSRV_DEV_DATA *psDevData,
												 PSGX_CREATERENDERCONTEXT psCreateRenderContext,
												 IMG_HANDLE *phRenderContext,
												 PPVRSRV_CLIENT_MEM_INFO *psVisTestResultMemInfo);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXDestroyRenderContext(PVRSRV_DEV_DATA *psDevData,
												  IMG_HANDLE hRenderContext,
												  PVRSRV_CLIENT_MEM_INFO *psVisTestResultMemInfo,
												  IMG_BOOL bForceCleanup);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXAddRenderTarget(PVRSRV_DEV_DATA *psDevData,
											 SGX_ADDRENDTARG *psAddRTInfo,
											 IMG_HANDLE *phRTDataSet);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXRemoveRenderTarget(PVRSRV_DEV_DATA *psDevData,
												IMG_HANDLE hRenderContext,
												IMG_HANDLE hRTDataSet);


IMG_IMPORT
PVRSRV_ERROR SGXSetContextPriority(PVRSRV_DEV_DATA *psDevData,
									SGX_CONTEXT_PRIORITY *pePriority,
									IMG_HANDLE hRenderContext,
									IMG_HANDLE hTransferContext);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXGetPhysPageAddr(PVRSRV_DEV_DATA *psDevData,
											 IMG_HANDLE hDevMemHeap,
											 IMG_DEV_VIRTADDR sDevVAddr,
											 IMG_DEV_PHYADDR *pDevPAddr,
											 IMG_CPU_PHYADDR *pCpuPAddr);

/* FIXME: remove this API and associated code when SGX video is fully integrated */
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXGetMMUPDAddr(PVRSRV_DEV_DATA	*psDevData,
										  IMG_HANDLE		hDevMemContext,
										  IMG_DEV_PHYADDR	*psPDDevPAddr);

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXGetMiscInfo(PVRSRV_DEV_DATA *psDevData,
										 SGX_MISC_INFO *psData);

#if defined(TRANSFER_QUEUE)
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXCreateTransferContext(PVRSRV_DEV_DATA *psDevData,
												   IMG_UINT32 ui32RequestedSBSize,
												   SGX_TRANSFERCONTEXTCREATE *psCreateTransfer,
												   IMG_HANDLE *phTransferContext);

#if defined (__psp2__)
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXDestroyTransferContext(PVRSRV_DEV_DATA *psDevData,
													IMG_HANDLE hTransferContext,
													IMG_BOOL bForceCleanup);
#else
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXDestroyTransferContext(IMG_HANDLE hTransferContext,
													IMG_BOOL bForceCleanup);
#endif

#if defined(__psp2__)
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXQueueTransfer(PVRSRV_DEV_DATA *psDevData,
											IMG_HANDLE hTransferContext,
											SGX_QUEUETRANSFER *psQueueTransfer);
#else
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXQueueTransfer(IMG_HANDLE hTransferContext,
										  SGX_QUEUETRANSFER *psQueueTransfer);
#endif

#if defined(SGXTQ_PREP_SUBMIT_SEPERATE)
IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGXSubmitTransfer(IMG_HANDLE hTransferContext,
											SGX_SUBMITTRANSFER *psSubmitTransfer);
#endif
#endif /* TRANSFER_QUEUE */

IMG_IMPORT
PVRSRV_ERROR IMG_CALLCONV SGX2DQueryBlitsComplete(PVRSRV_DEV_DATA *psDevData,
												  PVRSRV_CLIENT_SYNC_INFO *psSyncInfo,
												  IMG_BOOL bWaitForComplete);

#ifdef PDUMP
#define SGX_KICKTA_DUMPBITMAP_FLAGS_TWIDDLED		0x00000001
#define SGX_KICKTA_DUMPBITMAP_FLAGS_TILED			0x00000002
#endif

#if defined (__cplusplus)
}
#endif

#endif /* __SGXAPI_H__ */

/******************************************************************************
 End of file (sgxapi.h)
******************************************************************************/
