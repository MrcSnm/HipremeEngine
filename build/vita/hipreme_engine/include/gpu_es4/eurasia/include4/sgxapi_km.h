/*!****************************************************************************
@File           sgxapi_km.h

@Title          SGX KM API Header

@Author         Imagination Technologies

@Date           01/06/2004

@Copyright      Copyright 2004-2009 by Imagination Technologies Limited.
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

Modifications :-
$Log: sgxapi_km.h $
******************************************************************************/

#ifndef __SGXAPI_KM_H__
#define __SGXAPI_KM_H__

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

/******************************************************************************
 Some defines...
******************************************************************************/

/* SGX Heap IDs, note: not all heaps are available to clients */
#define SGX_UNDEFINED_HEAP_ID					(~0LU)
#define SGX_GENERAL_HEAP_ID						0
#define SGX_TADATA_HEAP_ID						1
#define SGX_KERNEL_CODE_HEAP_ID					2
#define SGX_KERNEL_DATA_HEAP_ID					3
#define SGX_PIXELSHADER_HEAP_ID					4
#define SGX_VERTEXSHADER_HEAP_ID				5
#define SGX_PDSPIXEL_CODEDATA_HEAP_ID			6
#define SGX_PDSVERTEX_CODEDATA_HEAP_ID			7
#define SGX_SYNCINFO_HEAP_ID					8
#define SGX_SHARED_3DPARAMETERS_HEAP_ID				9
#define SGX_PERCONTEXT_3DPARAMETERS_HEAP_ID			10
#if defined(SUPPORT_SGX_GENERAL_MAPPING_HEAP)
#define SGX_GENERAL_MAPPING_HEAP_ID				11
#endif
#if defined(SGX_FEATURE_2D_HARDWARE)
#define SGX_2D_HEAP_ID							12
#else
#if defined(FIX_HW_BRN_26915)
#define SGX_CGBUFFER_HEAP_ID					13
#endif
#endif

#if !defined(__psp2__)
#if defined(SUPPORT_MEMORY_TILING)
#define SGX_VPB_TILED_HEAP_ID			14
#endif

#define SGX_MAX_HEAP_ID							15
#else
#define SGX_USER_CPU_VA_HEAP_ID					14
#define SGX_USER_CDRAM_VA_HEAP_ID				15

/* CDRAM 3DParameter Heaps */
#define SGX_PERCONTEXT_CDRAM_3DPB_HEAP_ID		16
#define SGX_SHARED_CDRAM_3DPB_HEAP_ID			17

#define SGX_CD_PIXELSHADER_HEAP_ID				18
#define SGX_CD_VERTEXSHADER_HEAP_ID				19

#define SGX_USER_CPU_NC_VA_HEAP_ID				20
#define SGX_PERFMON_VA_HEAP_ID					21

#define SGX_MAX_HEAP_ID							22
#endif /* __psp2__ */

/*
 * Keep SGX_3DPARAMETERS_HEAP_ID as TQ full custom
 * shaders need it to select which heap to write
 * their ISP controll stream to.
 */
#if (defined(SUPPORT_PERCONTEXT_PB) || defined(SUPPORT_HYBRID_PB))
#define SGX_3DPARAMETERS_HEAP_ID			SGX_PERCONTEXT_3DPARAMETERS_HEAP_ID	
#else
#define SGX_3DPARAMETERS_HEAP_ID			SGX_SHARED_3DPARAMETERS_HEAP_ID
#endif
/* Define for number of bytes between consecutive code base registers */
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
#define SGX_USE_CODE_SEGMENT_RANGE_BITS		23
#else
#define SGX_USE_CODE_SEGMENT_RANGE_BITS		19
#endif

#define SGX_MAX_TA_STATUS_VALS	32
#define SGX_MAX_3D_STATUS_VALS	4

#if defined(SUPPORT_SGX_GENERALISED_SYNCOBJECTS)
/* sync info structure array size */
#define SGX_MAX_TA_DST_SYNCS			1
#define SGX_MAX_TA_SRC_SYNCS			1
#define SGX_MAX_3D_SRC_SYNCS			4
/* note: there is implicitly 1 3D Dst Sync */
#else
/* sync info structure array size */
#define SGX_MAX_SRC_SYNCS				8
#define SGX_MAX_DST_SYNCS				1
/* note: there is implicitly 1 3D Dst Sync */
#endif


#if defined(SGX_FEATURE_EXTENDED_PERF_COUNTERS)
#define	PVRSRV_SGX_HWPERF_NUM_COUNTERS	8
#define	PVRSRV_SGX_HWPERF_NUM_MISC_COUNTERS 11
#else
#define	PVRSRV_SGX_HWPERF_NUM_COUNTERS	9
#define	PVRSRV_SGX_HWPERF_NUM_MISC_COUNTERS 8
#endif /* SGX543 */

#define PVRSRV_SGX_HWPERF_INVALID					0x1

#define PVRSRV_SGX_HWPERF_TRANSFER					0x2
#define PVRSRV_SGX_HWPERF_TA						0x3
#define PVRSRV_SGX_HWPERF_3D						0x4
#define PVRSRV_SGX_HWPERF_2D						0x5
#define PVRSRV_SGX_HWPERF_POWER						0x6
#define PVRSRV_SGX_HWPERF_PERIODIC					0x7
#define PVRSRV_SGX_HWPERF_3DSPM						0x8

#define PVRSRV_SGX_HWPERF_MK_EVENT					0x101
#define PVRSRV_SGX_HWPERF_MK_TA						0x102
#define PVRSRV_SGX_HWPERF_MK_3D						0x103
#define PVRSRV_SGX_HWPERF_MK_2D						0x104
#define PVRSRV_SGX_HWPERF_MK_TRANSFER_DUMMY				0x105
#define PVRSRV_SGX_HWPERF_MK_TA_DUMMY					0x106
#define PVRSRV_SGX_HWPERF_MK_3D_DUMMY					0x107
#define PVRSRV_SGX_HWPERF_MK_2D_DUMMY					0x108
#define PVRSRV_SGX_HWPERF_MK_TA_LOCKUP					0x109
#define PVRSRV_SGX_HWPERF_MK_3D_LOCKUP					0x10A
#define PVRSRV_SGX_HWPERF_MK_2D_LOCKUP					0x10B

#define PVRSRV_SGX_HWPERF_TYPE_STARTEND_BIT			28
#define PVRSRV_SGX_HWPERF_TYPE_OP_MASK				((1UL << PVRSRV_SGX_HWPERF_TYPE_STARTEND_BIT) - 1)
#define PVRSRV_SGX_HWPERF_TYPE_OP_START				(0UL << PVRSRV_SGX_HWPERF_TYPE_STARTEND_BIT)
#define PVRSRV_SGX_HWPERF_TYPE_OP_END				(1Ul << PVRSRV_SGX_HWPERF_TYPE_STARTEND_BIT)

#define PVRSRV_SGX_HWPERF_TYPE_TRANSFER_START		(PVRSRV_SGX_HWPERF_TRANSFER | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_TRANSFER_END			(PVRSRV_SGX_HWPERF_TRANSFER | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_TA_START				(PVRSRV_SGX_HWPERF_TA | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_TA_END				(PVRSRV_SGX_HWPERF_TA | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_3D_START				(PVRSRV_SGX_HWPERF_3D | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_3D_END				(PVRSRV_SGX_HWPERF_3D | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_2D_START				(PVRSRV_SGX_HWPERF_2D | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_2D_END				(PVRSRV_SGX_HWPERF_2D | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_POWER_START			(PVRSRV_SGX_HWPERF_POWER | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_POWER_END			(PVRSRV_SGX_HWPERF_POWER | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_PERIODIC				(PVRSRV_SGX_HWPERF_PERIODIC)
#define PVRSRV_SGX_HWPERF_TYPE_3DSPM_START			(PVRSRV_SGX_HWPERF_3DSPM | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_3DSPM_END			(PVRSRV_SGX_HWPERF_3DSPM | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TRANSFER_DUMMY_START		(PVRSRV_SGX_HWPERF_MK_TRANSFER_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TRANSFER_DUMMY_END		(PVRSRV_SGX_HWPERF_MK_TRANSFER_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TA_DUMMY_START		(PVRSRV_SGX_HWPERF_MK_TA_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TA_DUMMY_END			(PVRSRV_SGX_HWPERF_MK_TA_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_3D_DUMMY_START		(PVRSRV_SGX_HWPERF_MK_3D_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_3D_DUMMY_END			(PVRSRV_SGX_HWPERF_MK_3D_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_2D_DUMMY_START		(PVRSRV_SGX_HWPERF_MK_2D_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_2D_DUMMY_END			(PVRSRV_SGX_HWPERF_MK_2D_DUMMY | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TA_LOCKUP			(PVRSRV_SGX_HWPERF_MK_TA_LOCKUP)
#define PVRSRV_SGX_HWPERF_TYPE_MK_3D_LOCKUP			(PVRSRV_SGX_HWPERF_MK_3D_LOCKUP)
#define PVRSRV_SGX_HWPERF_TYPE_MK_2D_LOCKUP			(PVRSRV_SGX_HWPERF_MK_2D_LOCKUP)

#define PVRSRV_SGX_HWPERF_TYPE_MK_EVENT_START		(PVRSRV_SGX_HWPERF_MK_EVENT | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_EVENT_END			(PVRSRV_SGX_HWPERF_MK_EVENT | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TA_START			(PVRSRV_SGX_HWPERF_MK_TA | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_TA_END			(PVRSRV_SGX_HWPERF_MK_TA | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_3D_START			(PVRSRV_SGX_HWPERF_MK_3D | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_3D_END			(PVRSRV_SGX_HWPERF_MK_3D | PVRSRV_SGX_HWPERF_TYPE_OP_END)
#define PVRSRV_SGX_HWPERF_TYPE_MK_2D_START			(PVRSRV_SGX_HWPERF_MK_2D | PVRSRV_SGX_HWPERF_TYPE_OP_START)
#define PVRSRV_SGX_HWPERF_TYPE_MK_2D_END			(PVRSRV_SGX_HWPERF_MK_2D | PVRSRV_SGX_HWPERF_TYPE_OP_END)

#define PVRSRV_SGX_HWPERF_STATUS_OFF				(0x0)
#define PVRSRV_SGX_HWPERF_STATUS_RESET_COUNTERS		(1UL << 0)
#define PVRSRV_SGX_HWPERF_STATUS_GRAPHICS_ON		(1UL << 1)
#define PVRSRV_SGX_HWPERF_STATUS_PERIODIC_ON		(1UL << 2)
#define PVRSRV_SGX_HWPERF_STATUS_MK_EXECUTION_ON	(1UL << 3)


/*!
 *****************************************************************************
 * One entry in the HWPerf Circular Buffer. 
 *****************************************************************************/
typedef struct _PVRSRV_SGX_HWPERF_CB_ENTRY_
{
	IMG_UINT32	ui32FrameNo;
	IMG_UINT32	ui32PID;
	IMG_UINT32	ui32RTData;
	IMG_UINT32	ui32Type;
	IMG_UINT32	ui32Ordinal;
	IMG_UINT32	ui32Info;
	IMG_UINT32	ui32Clocksx16;
	/* NOTE: There should always be at least as many 3D cores as TA cores. */	
	IMG_UINT32	ui32Counters[SGX_FEATURE_MP_CORE_COUNT_3D][PVRSRV_SGX_HWPERF_NUM_COUNTERS];
	IMG_UINT32	ui32MiscCounters[SGX_FEATURE_MP_CORE_COUNT_3D][PVRSRV_SGX_HWPERF_NUM_MISC_COUNTERS];
} PVRSRV_SGX_HWPERF_CB_ENTRY;


/*
	Status values control structure
*/
typedef struct _CTL_STATUS_
{
	IMG_DEV_VIRTADDR	sStatusDevAddr;
	IMG_UINT32			ui32StatusValue;
} CTL_STATUS;


/*!
	List of possible requests/commands to SGXGetMiscInfo()
*/
typedef enum _SGX_MISC_INFO_REQUEST_
{
	SGX_MISC_INFO_REQUEST_CLOCKSPEED = 0,
	SGX_MISC_INFO_REQUEST_SGXREV,
	SGX_MISC_INFO_REQUEST_DRIVER_SGXREV,
#if defined(SUPPORT_SGX_EDM_MEMORY_DEBUG)
	SGX_MISC_INFO_REQUEST_MEMREAD,
	SGX_MISC_INFO_REQUEST_MEMCOPY,
#endif /* SUPPORT_SGX_EDM_MEMORY_DEBUG */
	SGX_MISC_INFO_REQUEST_SET_HWPERF_STATUS,
#if defined(SGX_FEATURE_DATA_BREAKPOINTS)
	SGX_MISC_INFO_REQUEST_SET_BREAKPOINT,
	SGX_MISC_INFO_REQUEST_POLL_BREAKPOINT,
	SGX_MISC_INFO_REQUEST_RESUME_BREAKPOINT,
#endif /* SGX_FEATURE_DATA_BREAKPOINTS */
	SGX_MISC_INFO_DUMP_DEBUG_INFO,
	SGX_MISC_INFO_PANIC,
	SGX_MISC_INFO_REQUEST_SPM,
	SGX_MISC_INFO_REQUEST_ACTIVEPOWER,
	SGX_MISC_INFO_REQUEST_LOCKUPS,
#if defined(__psp2__)
	SGX_MISC_INFO_REQUEST_TIMERS,
#endif
	SGX_MISC_INFO_REQUEST_FORCE_I16 				=  0x7fff
} SGX_MISC_INFO_REQUEST;


/******************************************************************************
 * Struct for passing SGX core rev/features from ukernel to driver.
 * This is accessed from the kernel part of the driver and microkernel; it is
 * only accessed in user space during buffer allocation in srvinit.
 ******************************************************************************/
typedef struct _PVRSRV_SGX_MISCINFO_FEATURES
{
	IMG_UINT32			ui32CoreRev;	/*!< SGX Core revision from HW register */
	IMG_UINT32			ui32CoreID;		/*!< SGX Core ID from HW register */
	IMG_UINT32			ui32DDKVersion;	/*!< software DDK version */
	IMG_UINT32			ui32DDKBuild;	/*!< software DDK build no. */
	IMG_UINT32			ui32CoreIdSW;	/*!< software core version (ID), e.g. SGX535, SGX540 */
	IMG_UINT32			ui32CoreRevSW;	/*!< software core revision */
	IMG_UINT32			ui32BuildOptions;	/*!< build options bit-field */
#if defined(SUPPORT_SGX_EDM_MEMORY_DEBUG)
	IMG_UINT32			ui32DeviceMemValue;		/*!< device mem value read from ukernel */
#endif
#if defined(PVRSRV_USSE_EDM_STATUS_DEBUG)
	IMG_DEV_VIRTADDR	sDevVAEDMStatusBuffer;	/*!< DevVAddr of the EDM status buffer */
	IMG_PVOID			pvEDMStatusBuffer;		/*!< CPUVAddr of the EDM status buffer */
#endif
} PVRSRV_SGX_MISCINFO_FEATURES;


/******************************************************************************
 * Struct for getting lock-up stats from the kernel driver
 ******************************************************************************/
typedef struct _PVRSRV_SGX_MISCINFO_LOCKUPS
{
	IMG_UINT32			ui32HostDetectedLockups; /*!< Host timer detected lockups */
	IMG_UINT32			ui32uKernelDetectedLockups; /*!< Microkernel detected lockups */
} PVRSRV_SGX_MISCINFO_LOCKUPS;


/******************************************************************************
 * Struct for getting lock-up stats from the kernel driver
 ******************************************************************************/
typedef struct _PVRSRV_SGX_MISCINFO_ACTIVEPOWER
{
	IMG_UINT32			ui32NumActivePowerEvents; /*!< active power events */
} PVRSRV_SGX_MISCINFO_ACTIVEPOWER;


/******************************************************************************
 * Struct for getting SPM stats fro the kernel driver
 ******************************************************************************/
typedef struct _PVRSRV_SGX_MISCINFO_SPM
{
	IMG_HANDLE			hRTDataSet;				/*!< render target data set handle returned from SGXAddRenderTarget */
	IMG_UINT32			ui32NumOutOfMemSignals; /*!< Number of Out of Mem Signals */
	IMG_UINT32			ui32NumSPMRenders;	/*!< Number of SPM renders */
} PVRSRV_SGX_MISCINFO_SPM;


#if defined(SGX_FEATURE_DATA_BREAKPOINTS)
/*!
 ******************************************************************************
 * Structure for SGX break points control
 *****************************************************************************/
typedef struct _SGX_BREAKPOINT_INFO
{
	/* set/clear BP boolean */
	IMG_BOOL					bBPEnable;
	/* Index of BP to set */
	IMG_UINT32					ui32BPIndex;
	/* On which DataMaster(s) should the breakpoint fire? */
	IMG_UINT32                  ui32DataMasterMask;
	/* DevVAddr of BP to set */
	IMG_DEV_VIRTADDR			sBPDevVAddr, sBPDevVAddrEnd;
	/* Whether or not the desired breakpoint will be trapped */
	IMG_BOOL                    bTrapped;
	/* Will the requested breakpoint fire for reads? */
	IMG_BOOL                    bRead;
	/* Will the requested breakpoint fire for writes? */
	IMG_BOOL                    bWrite;
	/* Has a breakpoint been trapped? */
	IMG_BOOL                    bTrappedBP;
	/* Extra information recorded about a trapped breakpoint */
	IMG_UINT32                  ui32CoreNum;
	IMG_DEV_VIRTADDR            sTrappedBPDevVAddr;
	IMG_UINT32                  ui32TrappedBPBurstLength;
	IMG_BOOL                    bTrappedBPRead;
	IMG_UINT32                  ui32TrappedBPDataMaster;
	IMG_UINT32                  ui32TrappedBPTag;
} SGX_BREAKPOINT_INFO;
#endif /* SGX_FEATURE_DATA_BREAKPOINTS */


/*!
 ******************************************************************************
 * Structure for setting the hardware performance status
 *****************************************************************************/
typedef struct _PVRSRV_SGX_MISCINFO_SET_HWPERF_STATUS
{
	/* See PVRSRV_SGX_HWPERF_STATUS_* */
	IMG_UINT32	ui32NewHWPerfStatus;
	
	#if defined(SGX_FEATURE_EXTENDED_PERF_COUNTERS)
	/* Specifies the HW's active group selectors */
	IMG_UINT32	aui32PerfGroup[PVRSRV_SGX_HWPERF_NUM_COUNTERS];
	/* Specifies the HW's active bit selectors */
	IMG_UINT32	aui32PerfBit[PVRSRV_SGX_HWPERF_NUM_COUNTERS];
	#else
	/* Specifies the HW's active group */
	IMG_UINT32	ui32PerfGroup;
	#endif /* SGX_FEATURE_EXTENDED_PERF_COUNTERS */
} PVRSRV_SGX_MISCINFO_SET_HWPERF_STATUS;


#if defined(__psp2__)
/*!
 ******************************************************************************
 * Structure for getting the CPU and GPU timers
 *****************************************************************************/
typedef struct _PVRSRV_SGX_MISCINFO_TIMERS_
{
	/* Based on process time */
	IMG_UINT64	ui64CPUTimer;
	/* See EUR_CR_TIMER */
	IMG_UINT32	ui32GPUTimer;
} PVRSRV_SGX_MISCINFO_TIMERS;
#endif


/*!
 ******************************************************************************
 * Structure for misc SGX commands in services
 *****************************************************************************/
typedef struct _SGX_MISC_INFO_
{
	SGX_MISC_INFO_REQUEST	eRequest;	/*!< Command request to SGXGetMiscInfo() */
	IMG_UINT32				ui32Padding;
#if defined(SUPPORT_SGX_EDM_MEMORY_DEBUG)
	IMG_DEV_VIRTADDR			sDevVAddrSrc;		/*!< dev virtual addr for mem read */
	IMG_DEV_VIRTADDR			sDevVAddrDest;		/*!< dev virtual addr for mem write */
	IMG_HANDLE					hDevMemContext;		/*!< device memory context for mem debug */
#endif
	union
	{
		IMG_UINT32	reserved;	/*!< Unused: ensures valid code in the case everything else is compiled out */
		PVRSRV_SGX_MISCINFO_FEATURES						sSGXFeatures;
		IMG_UINT32											ui32SGXClockSpeed;
		PVRSRV_SGX_MISCINFO_ACTIVEPOWER						sActivePower;
		PVRSRV_SGX_MISCINFO_LOCKUPS							sLockups;
		PVRSRV_SGX_MISCINFO_SPM								sSPM;
#if defined(SGX_FEATURE_DATA_BREAKPOINTS)
		SGX_BREAKPOINT_INFO									sSGXBreakpointInfo;
#endif
		PVRSRV_SGX_MISCINFO_SET_HWPERF_STATUS				sSetHWPerfStatus;
#if defined(__psp2__)
		PVRSRV_SGX_MISCINFO_TIMERS							sTimers;
#endif
	} uData;
} SGX_MISC_INFO;

#if defined(SGX_FEATURE_2D_HARDWARE)
/*
 * The largest number of source sync objects that can be associated with a blit
 * command.  Allows for src, pattern, and mask
 */
#define PVRSRV_MAX_BLT_SRC_SYNCS		3
#endif


#define SGX_KICKTA_DUMPBITMAP_MAX_NAME_LENGTH		256

/*
	Structure for dumping bitmaps
*/
typedef struct _SGX_KICKTA_DUMPBITMAP_
{
	IMG_DEV_VIRTADDR	sDevBaseAddr;
	IMG_UINT32			ui32Flags;
	IMG_UINT32			ui32Width;
	IMG_UINT32			ui32Height;
	IMG_UINT32			ui32Stride;
	IMG_UINT32			ui32PDUMPFormat;
	IMG_UINT32			ui32BytesPP;
	IMG_CHAR			pszName[SGX_KICKTA_DUMPBITMAP_MAX_NAME_LENGTH];
} SGX_KICKTA_DUMPBITMAP, *PSGX_KICKTA_DUMPBITMAP;

#define PVRSRV_SGX_PDUMP_CONTEXT_MAX_BITMAP_ARRAY_SIZE	(16)

/*!
 ******************************************************************************
 * Data required only when dumping parameters
 *****************************************************************************/
typedef struct _PVRSRV_SGX_PDUMP_CONTEXT_
{
	/* cache control word for micro kernel cache flush/invalidates */
	IMG_UINT32						ui32CacheControl;

} PVRSRV_SGX_PDUMP_CONTEXT;


#if !defined (SUPPORT_SID_INTERFACE)
typedef struct _SGX_KICKTA_DUMP_ROFF_
{
	IMG_HANDLE			hKernelMemInfo;						/*< Buffer handle */
	IMG_UINT32			uiAllocIndex;						/*< Alloc index for LDDM */
	IMG_UINT32			ui32Offset;							/*< Byte offset to value to dump */
	IMG_UINT32			ui32Value;							/*< Actual value to dump */
	IMG_PCHAR			pszName;							/*< Name of buffer */
} SGX_KICKTA_DUMP_ROFF, *PSGX_KICKTA_DUMP_ROFF;
#endif

#if defined (SUPPORT_SID_INTERFACE)
typedef struct _SGX_KICKTA_DUMP_BUFFER_KM_
#else
typedef struct _SGX_KICKTA_DUMP_BUFFER_
#endif
{
	IMG_UINT32			ui32SpaceUsed;
	IMG_UINT32			ui32Start;							/*< Byte offset of start to dump */
	IMG_UINT32			ui32End;							/*< Byte offset of end of dump (non-inclusive) */
	IMG_UINT32			ui32BufferSize;						/*< Size of buffer */
	IMG_UINT32			ui32BackEndLength;					/*< Size of back end portion, if End < Start */
	IMG_UINT32			uiAllocIndex;
	IMG_HANDLE			hKernelMemInfo;						/*< MemInfo handle for the circular buffer */
	IMG_PVOID			pvLinAddr;
#if defined(SUPPORT_SGX_NEW_STATUS_VALS)
	IMG_HANDLE			hCtrlKernelMemInfo;					/*< MemInfo handle for the control structure of the
																circular buffer */
	IMG_DEV_VIRTADDR	sCtrlDevVAddr;						/*< Device virtual address of the memory in the 
																control structure to be checked */
#endif
	IMG_PCHAR			pszName;							/*< Name of buffer */
#if defined (SUPPORT_SID_INTERFACE)
} SGX_KICKTA_DUMP_BUFFER_KM, *PSGX_KICKTA_DUMP_BUFFER_KM;
#else
} SGX_KICKTA_DUMP_BUFFER, *PSGX_KICKTA_DUMP_BUFFER;
#endif

#if !defined (SUPPORT_SID_INTERFACE)
#ifdef PDUMP
/*
	PDUMP version of above kick structure
*/
typedef struct _SGX_KICKTA_PDUMP_
{
	// Bitmaps to dump
	PSGX_KICKTA_DUMPBITMAP		psPDumpBitmapArray;
	IMG_UINT32						ui32PDumpBitmapSize;

	// Misc buffers to dump (e.g. TA, PDS etc..)
	PSGX_KICKTA_DUMP_BUFFER	psBufferArray;
	IMG_UINT32						ui32BufferArraySize;

	// Roffs to dump
	PSGX_KICKTA_DUMP_ROFF		psROffArray;
	IMG_UINT32						ui32ROffArraySize;
} SGX_KICKTA_PDUMP, *PSGX_KICKTA_PDUMP;
#endif	/* PDUMP */
#endif /* #if !defined (SUPPORT_SID_INTERFACE) */

#if defined(TRANSFER_QUEUE)
#if defined(SGX_FEATURE_2D_HARDWARE)
/* Maximum size of ctrl stream for 2d blit command (in 32 bit words) */
#define SGX_MAX_2D_BLIT_CMD_SIZE 		26
#define SGX_MAX_2D_SRC_SYNC_OPS			3
#endif
#define SGX_MAX_TRANSFER_STATUS_VALS	2
#define SGX_MAX_TRANSFER_SYNC_OPS	5
#endif

#if defined (__cplusplus)
}
#endif

#endif /* __SGXAPI_KM_H__ */

/******************************************************************************
 End of file (sgxapi_km.h)
******************************************************************************/
