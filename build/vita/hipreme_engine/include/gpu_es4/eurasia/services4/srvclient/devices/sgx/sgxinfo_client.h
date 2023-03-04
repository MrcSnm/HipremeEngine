/*!****************************************************************************
@File           sgxinfo_client.h

@Title          sgx services structures/functions

@Author         Imagination Technologies

@Date           30th Jan 2008

@Copyright      Copyright 2003-2009 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either material
                or conceptual may be copied or distributed, transmitted,
                transcribed, stored in a retrieval system or translated into
                any human or computer language in any form by any means,
                electronic, mechanical, manual or otherwise, or disclosed to
                third parties without the express written permission of
                Imagination Technologies Limited, Home Park Estate,
                Kings Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform       Generic

@Description    inline functions/structures shared across UM and KM services components

@DoxygenVer

******************************************************************************/

/******************************************************************************
Modifications :-
$Log: sgxinfo_client.h $
*****************************************************************************/
#if !defined (__SGXINFO_CLIENT_H__)
#define __SGXINFO_CLIENT_H__

#include "sgx_mkif_client.h"


#if defined(SGX543) || defined(SGX544) 
/* 
EUR_CR_DMS_CTRL / EUR_CR_PDS_DMS_CTRL2 config(SGX543, 544):
----------------------------------------------
tile size is 32 x 32 (1024 pixels)
	1 partition is 128 DWORDs, 4 x USSE pipes, 16x16 pixels per pipe
	Based on number of dwords for each pipe (256, 512) for single/double
	the minimum allocation granularity are 2 and 4  contiguous 
	pixel partitions respectively for single and double pixels
	Vertex partition allocation granularity is 1

	When in SPM, the vertex partitions are not freed until a
	resume or restart, therefore, we guard for fragmentation
	max_num_contig_partitions = ceil ( partitions_available / (max_vertex_paritions + 1) ) 
	where partitions_available == max_partitions - max_vertex_partitions

	The choice of 9 for total output partitions is based on 
		(8 for pixel + 1 for vertex).

	when the PDS threshold is reached the microkernel will lower the max_vertex_partitions 
	to 1 if the SUPPORT_SGX_DOUBLE_PIXEL_PARTITIONS is enabled
*/	 

	#if defined(SUPPORT_SGX_DOUBLE_PIXEL_PARTITIONS)
		#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 3
		#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 8
		#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 1
	#else
		#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 3
		#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 8
		#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 3
	#endif
#else
	#if defined(SGX554)
		#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 3
		#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 8
		#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 3
	#else
		#if defined(SGX545)
			/* This is moving the magic number that
			 * were in the code unmodified to defines to start with */
			#define SGX_MAX_VERTEX_PARTITIONS_CHECK_COMPLEX_GEOMETRY
			#define SGX_MAX_VERTEX_PARTITIONS_COMPLEX_GEOMETRY_REDUCTION 2
			/* The if else have same values, this is in anticipation of
			 * different configuration based on DOUBLE_PIXELs */
			#if defined(SUPPORT_SGX_DOUBLE_PIXEL_PARTITIONS)
				#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 10
				#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 31
				#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 10
			#else
				#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 10
				#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 31
				#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 10
			#endif
		#else
			#if defined(SGX535)
				#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 4
				#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 4
				#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 4
			#else
				#if defined(SGX540)
					#define SGX_MAX_PIXEL_PARTITIONS_CHECK_MSAA 
					#define SGX_MAX_PIXEL_PARTITIONS_MSAA_REDUCTION 4
					#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 4
					#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 6
					#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 4
				#else
					/* See BRN20913 */
					#define SGX_MAX_PIXEL_PARTITIONS_CHECK_MSAA
					#define SGX_MAX_PIXEL_PARTITIONS_MSAA_REDUCTION 2
					#define SGX_DEFAULT_MAX_NUM_PIXEL_PARTITIONS 6
					#if defined(FIX_HW_BRN_32302)
						#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 2
						#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 2
					#else
						#define SGX_DEFAULT_MAX_NUM_VERTEX_PARTITIONS 4
						#define SGX_DEFAULT_SPM_MAX_NUM_VERTEX_PARTITIONS 4
					#endif
				#endif /* SGX540 */
			#endif /* SGX535 */
		#endif /*SGX545 */
	#endif /* 554 */
#endif

/*!
 ******************************************************************************
 * per context CCB control structure for SGX
 *****************************************************************************/
typedef struct _SGX_CLIENT_CCB_
{
	PVRSRV_CLIENT_MEM_INFO	*psCCBClientMemInfo;	/*!< meminfo for CCB in device accessible memory */
	PVRSRV_CLIENT_MEM_INFO	*psCCBCtlClientMemInfo;	/*!< meminfo for CCB control in device accessible memory */
	IMG_UINT32				*pui32CCBLinAddr;		/*!< linear address of the buffer */
	IMG_DEV_VIRTADDR		sCCBDevAddr;			/*!< device virtual address of the buffer */
	IMG_UINT32				*pui32WriteOffset;	/*!< linear address of the write offset into array of commands */
	volatile IMG_UINT32		*pui32ReadOffset;		/*!< linear address of the read offset into array of commands */
	IMG_UINT32				ui32Size;				/*!< ((Size of the buffer) - (overrun size)) */
	IMG_UINT32				ui32AllocGran;			/*!< Allocation granularity */

	#ifdef PDUMP
	IMG_UINT32				ui32CCBDumpWOff;		/*!< for pdumping */
	#endif
}SGX_CLIENT_CCB;

/*!
 *****************************************************************************
 * SGXPBRTA data
 *****************************************************************************/
/* Indicates this parameter buffer can be shared between rendering contexts */
#define SGX_PBDESCFLAGS_SHARED						0x00000001UL
/* indicates whether the values have been over-ridden */
#define SGX_PBDESCFLAGS_TA_OVERRIDE					0x00000002UL
#define SGX_PBDESCFLAGS_ZLS_OVERRIDE				0x00000004UL
#define SGX_PBDESCFLAGS_GLOBAL_OVERRIDE				0x00000008UL
#define SGX_PBDESCFLAGS_PDS_OVERRIDE				0x00000010UL
#define SGX_PBDESCFLAGS_THRESHOLD_UPDATE_PENDING	0x00000020UL
#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
#define SGX_PBDESCFLAGS_GROW_PENDING				0x00000040UL
#define SGX_PBDESCFLAGS_SHRINK_PENDING				0x00000080UL
#define SGX_PBDESCFLAGS_SHRINK_QUEUED				0x00000100UL
#endif



/* PB Memblock flags */
#define PBMEM_FLAGS_BLOCKFREE		0x00000001UL

/* RT Data Set flags */
#define SGX_RTDSFLAGS_OPENGL			0x00000001UL
#define SGX_RTDSFLAGS_DPMZLS			0x00000002UL


/* Host parameter buffer block */
typedef struct _SGX_PBBLOCK_
{
	/* size of block in pages */
	IMG_UINT32					ui32PageCount;
	/* index of head of block */
	IMG_UINT16					ui16Head;
	/* index of tail of block */
	IMG_UINT16					ui16Tail;

	/* info for the PB memory */
	PVRSRV_CLIENT_MEM_INFO		*psPBClientMemInfo;

	/* info for HW PB Block */
	PVRSRV_CLIENT_MEM_INFO		*psHWPBBlockClientMemInfo;
	SGXMKIF_HWPBBLOCK			*psHWPBBlock;
	IMG_DEV_VIRTADDR			sHWPBBlockDevVAddr;

	/* ptr to parent PB Desc */
	struct _SGX_PBDESC_	*psParentPBDesc;
	/* ptr to next PB Block */
	struct _SGX_PBBLOCK_	*psPrev;
	/* ptr to next PB Block */
	struct _SGX_PBBLOCK_	*psNext;
} SGX_PBBLOCK, *PSGX_PBBLOCK;

/*
 * if SUPPORT_PERCONTEXT_PB then this is a per client structure.
 * if the PB is shared then this is mapped from the kernel.
 */
typedef struct _SGX_PBDESC_
{
	IMG_UINT32	ui32Flags;

	IMG_UINT32	ui32TotalPBSize;    /*!< Size of parameter buffer in bytes */
	IMG_UINT32	ui32NumPages;       /*!< Size of parameter buffer in pages (incl. reserve pages) */

	IMG_UINT32	ui32FreeListInitialHT;
	IMG_UINT32	ui32FreeListInitialPrev;

	IMG_UINT32	ui32TAThreshold;    /*!< Number of pages allocated before almost
                                         out of memory interrupt */
	IMG_UINT32	ui32ZLSThreshold;   /*!< Number of pages allocated before completely
                                         out of memory interrupt */
	IMG_UINT32	ui32GlobalThreshold;/*!< Number of pages allocated to global
                                         list before Global out of memory
                                         interrupt */
	IMG_UINT32	ui32PDSThreshold;   /*!<  Number of pages allocated before PDS stops
										  double buffering of output buffers */

	IMG_DEV_VIRTADDR	sParamHeapBaseDevVAddr;  /*!< device virtual address of base of
                                                     base of param buffer */
	IMG_DEV_VIRTADDR	sHWPBDescDevVAddr;

	SGX_PBBLOCK    *psListPBBlockHead;
	SGX_PBBLOCK    *psListPBBlockTail;
#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
	SGX_PBBLOCK    *psGrowListPBBlockHead;
	SGX_PBBLOCK    *psGrowListPBBlockTail;
	SGX_PBBLOCK    *psShrinkListPBBlock;

	IMG_UINT32		ui32BusySceneCount;
	IMG_UINT32		ui32RenderCount;
	IMG_UINT32		ui32ShrinkRender;
	IMG_UINT32		ui32PBSizeLimit;
	IMG_UINT32		ui32PBGrowBlockSize;
	
	#if defined(PDUMP)
	IMG_BOOL		bPdumpRequired;
	IMG_UINT32		ui32PdumpNumPages;       /*!< Size of parameter buffer in pages */
	IMG_UINT32		ui32PdumpFreeListInitialHT;
	IMG_UINT32		ui32PdumpFreeListInitialPrev;
	IMG_UINT32		ui32PdumpTAThreshold;    	/*!< Number of pages allocated before almost
                                         		out of memory interrupt */
	IMG_UINT32		ui32PdumpZLSThreshold;  	/*!< Number of pages allocated before completely
                                         		out of memory interrupt */
	IMG_UINT32		ui32PdumpGlobalThreshold;	/*!< Number of pages allocated to global
                                         		list before Global out of memory interrupt */
	IMG_UINT32		ui32PdumpPDSThreshold;   	/*!<  Number of pages allocated before PDS stops
										  		double buffering of output buffers */
	#endif
#endif

	SGXMKIF_HWPBDESC			*psHWPBDesc;
	IMG_BOOL				bPerContextPB;
	IMG_BOOL				bGrowShrink;
} SGX_PBDESC;


/*
 * Per app info about the PB
 */
typedef struct _SGX_CLIENTPBDESC_
{
#if defined(SUPPORT_SHARED_PB)
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID						hSharedPBDesc;
#else
	IMG_HANDLE					hSharedPBDesc;
#endif
#endif
	PVRSRV_CLIENT_MEM_INFO		*psPBDescClientMemInfo;
	PVRSRV_CLIENT_MEM_INFO		*psHWPBDescClientMemInfo;
	PVRSRV_CLIENT_MEM_INFO		*psEVMPageTableClientMemInfo;
#if defined(SUPPORT_SHARED_PB)
	PVRSRV_CLIENT_MEM_INFO		*psBlockClientMemInfo;
	PVRSRV_CLIENT_MEM_INFO		*psHWBlockClientMemInfo;
#endif

	SGX_PBDESC				*psPBDesc;
} SGX_CLIENTPBDESC;


/**
 *	Host side render details control
 */
typedef struct _SGX_RENDERDETAILS_
{

	PSGXMKIF_HWRENDERDETAILS	psHWRenderDetails;

	PVRSRV_CLIENT_MEM_INFO	*psHWRenderDetailsClientMemInfo;
	PVRSRV_CLIENT_MEM_INFO	*psAccessResourceClientMemInfo;

	volatile IMG_UINT32		*pui32Lock;

	SGXMKIF_3DREGISTERS	s3DRegs; /*!< Last register values sent from the
                                          driver - can be used to check if any
                                          values need updating */
#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	PVRSRV_CLIENT_MEM_INFO	*psHWPixEventUpdateListClientMemInfo;
	IMG_UINT32				*psHWPixEventUpdateList;

	PVRSRV_CLIENT_MEM_INFO	*psHWBgObjPrimPDSUpdateListClientMemInfo;
	IMG_UINT32				*psHWBgObjPrimPDSUpdateList;
#endif
#if defined(NO_HARDWARE)
	IMG_UINT32	ui32WriteOpsPendingVal;
#endif
	struct _SGX_RENDERDETAILS_	*psNext;
} SGX_RENDERDETAILS, *PSGX_RENDERDETAILS;




/**
 * Host side per target size data.
 */
typedef struct _SGX_RTDATA_
{
	PVRSRV_CLIENT_MEM_INFO 	*apsRgnHeaderClientMemInfo[SGX_FEATURE_MP_CORE_COUNT_TA]; /*!< meminfo for region headers */
	PVRSRV_CLIENT_MEM_INFO 	*psContextStateClientMemInfo; /*!< meminfo for context state */

#if !defined(SGX_FEATURE_ISP_BREAKPOINT_RESUME_REV_2) && !defined(FIX_HW_BRN_23761) && !defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	PVRSRV_CLIENT_MEM_INFO 	*psTileRgnLUTClientMemInfo; /*!< LUT for the address of each tile's region header */
#endif

#if defined(SGX_FEATURE_SW_ISP_CONTEXT_SWITCH) || defined(FIX_HW_BRN_23862) || defined(FIX_HW_BRN_30089) || defined(FIX_HW_BRN_29504) \
	|| defined(FIX_HW_BRN_33753)
	PVRSRV_CLIENT_MEM_INFO 	*psLastRgnLUTClientMemInfo;
#endif /* defined(FIX_HW_BRN_23862) */
#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	PVRSRV_CLIENT_MEM_INFO 	*psStatusClientMemInfo;
#endif
	IMG_UINT32				ui32BGObjU;
	IMG_UINT32				ui32BGObjV;
	IMG_UINT32				ui32BGObjPtr1;
	IMG_UINT32				ui32BGObjPtr2;
	IMG_UINT32				ui32BGObjTexPtr;
	IMG_UINT32				ui32BGObjObjPtr;
	IMG_UINT32				ui32BGObjBlendPtr;
	volatile IMG_UINT32		*pui32RTStatus;
} SGX_RTDATA, *PSGX_RTDATA;

/* forward reference */
typedef struct _SGX_RENDERCONTEXT_ SGX_RENDERCONTEXT;
typedef struct _SGX_RENDERCONTEXT_ *PSGX_RENDERCONTEXT;


/**
 * Higher level host structure combining two copies of above structures
 * with the actual dimensions.
 */
typedef struct _SGX_RTDATASET_
{
	PVRSRV_MUTEX_HANDLE	hMutex;
	IMG_UINT32	ui32Flags;
	IMG_UINT32	ui32NumPixelsX;
	IMG_UINT32	ui32NumPixelsY;
	IMG_UINT32	ui323DAAMode;
	IMG_UINT32	ui32MTEMultiSampleCtl;
	IMG_UINT32	ui32ISPMultiSampleCtl;
#if defined(EUR_CR_ISP_MULTISAMPLECTL2)
	IMG_UINT32	ui32ISPMultiSampleCtl2;
#endif
	IMG_UINT16	ui16MSAASamplesInX;
	IMG_UINT16	ui16MSAASamplesInY;
	SGX_SCALING	eScalingInX;
	SGX_SCALING	eScalingInY;
	PVRSRV_ROTATION eRotation;
	IMG_UINT32	ui32BGObjUCoord;
	IMG_UINT32	ui32MTileNumber;
	IMG_UINT32	ui32MTileX1;
	IMG_UINT32	ui32MTileX2;
	IMG_UINT32	ui32MTileX3;
	IMG_UINT32	ui32MTileY1;
	IMG_UINT32	ui32MTileY2;
	IMG_UINT32	ui32MTileY3;
	IMG_UINT32	ui32ScreenXMax;
	IMG_UINT32	ui32ScreenYMax;
	IMG_UINT32	ui32MTileStride;
	IMG_UINT32	ui32RTDataSel; /*!< Used by host to decide which data set to select */
	IMG_UINT32	ui32RefCount; /*!< Reference count of targets using this size data */
	IMG_UINT16	ui16NumRTsInArray;
#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32	ui32TPCStride;
	IMG_UINT32	ui32RgnPageStride;
#endif
#if defined(FIX_HW_BRN_23862)
	IMG_DEV_VIRTADDR		sBRN23862FixObjectDevAddr;
	IMG_DEV_VIRTADDR		sBRN23862PDSStateDevAddr;
#endif /* defined(FIX_HW_BRN_23862) */
	SGXMKIF_HWRTDATASET			*psHWRTDataSet; /*!< Pointer to an HW size data set. */
	IMG_UINT32					ui32NumRTData; /*!< Number of HW rtdata */
	SGX_RTDATA					*psRTData; /*!< Pointer to array containing ui32NumRTData elements */
	PVRSRV_CLIENT_MEM_INFO 		*psHWRTDataSetClientMemInfo;
	PVRSRV_CLIENT_MEM_INFO		*psPendingCountClientMemInfo;
	IMG_UINT32					*pui32PendingCount;
	PVRSRV_CLIENT_MEM_INFO 		*apsTailPtrsClientMemInfo[SGX_FEATURE_MP_CORE_COUNT_TA];
	PVRSRV_CLIENT_MEM_INFO 		*psContextControlClientMemInfo[SGX_FEATURE_MP_CORE_COUNT_TA];
	PVRSRV_CLIENT_MEM_INFO 		*psContextOTPMClientMemInfo[SGX_FEATURE_MP_CORE_COUNT_TA];
	PVRSRV_CLIENT_MEM_INFO 		*psSpecialObjClientMemInfo;
#if defined(SGX_FEATURE_MP) 
#if defined(EUR_CR_MASTER_DPM_MTILE_PARTI_PIM_TABLE_BASE_ADDR)
	PVRSRV_CLIENT_MEM_INFO 		*psPIMTableClientMemInfo;
#endif
#endif
	struct _SGX_RTDATASET_		*psNext;
	volatile IMG_UINT32			*pui32UserModeFlagsPtr;
	SGX_RENDERDETAILS			*psRenderDetailsList;
	SGX_RENDERDETAILS			*psCurrentRenderDetails; /*!< Render details used for rendering */
	SGX_DEVICE_SYNC_LIST		*psDeviceSyncList;
	SGX_DEVICE_SYNC_LIST		*psCurrentDeviceSyncList; /*!< Render details used for rendering */
	SGX_RENDERCONTEXT			*psRenderContext; 		 /*!< Back-pointer to containing render context */
	IMG_HANDLE					hResItem; /*!< Resource Manager handle */
#if defined(PDUMP)
#if defined(NO_HARDWARE)
	SGX_RENDERDETAILS  			*psLastFreedRenderDetails;
	SGX_DEVICE_SYNC_LIST 		*psLastFreedDeviceSyncList;
#endif /* NO_HARDWARE */
	IMG_UINT32					ui32PDumpPendingCount;
#endif /* PDUMP */

#if defined(FIX_HW_BRN_32044)
	PVRSRV_CLIENT_MEM_INFO *ps32044CtlStrmClientMemInfo;
	PVRSRV_CLIENT_MEM_INFO *ps32044PDSPrgClientMemInfo;
#endif

} SGX_RTDATASET, *PSGX_RTDATASET;


/* Registry TA Kick flags */
#define PVRSRV_SGX_TAREGFLAGS_FORCEPSGPADZER0	0x00000002
#define PVRSRV_SGX_TAREGFLAGS_TACOMPLETESYNC	0x00000004
#define PVRSRV_SGX_TAREGFLAGS_RENDERSYNC		0x00000008

/**
 * Render context control struct.
 */
struct _SGX_RENDERCONTEXT_
{
	PVRSRV_MUTEX_HANDLE			hMutex; /*!< Mutex to hold whilst modifying this structure. */

	SGX_CLIENTPBDESC		*psClientPBDesc; /*!< Parameter buffer */

    /* It doesn't look like this is used? */
	PSGX_RTDATASET			psRTDataSets; /*!< Pointer to linked list of render target data sets */
	SGX_CLIENT_CCB		*psTACCB; /*!< Pointer to circular command buffer */
    IMG_DEV_VIRTADDR            sHWRenderContextDevVAddr;

	/* Sync info for 3D/TA dependencies */
	PVRSRV_CLIENT_MEM_INFO		*psTA3DSyncObjectMemInfo;
	PVRSRV_CLIENT_SYNC_INFO		*psTA3DSyncObject;

#if defined(SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH)
	PPVRSRV_CLIENT_MEM_INFO		psMasterVDMSnapShotBufferMemInfo;
#endif
#if defined(SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH)
	PPVRSRV_CLIENT_MEM_INFO		psVDMSnapShotBufferMemInfo[SGX_FEATURE_MP_CORE_COUNT_TA];
#endif
#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#if defined(SGX_FEATURE_MTE_STATE_FLUSH)
		#if defined(SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH) && defined(SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH)
	PVRSRV_CLIENT_MEM_INFO		*psMTEStateFlushMemInfo[SGX_FEATURE_MP_CORE_COUNT_TA];
		#else
	PVRSRV_CLIENT_MEM_INFO		*psMTEStateFlushMemInfo[1];
		#endif
	#endif
	#if defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
	PVRSRV_CLIENT_MEM_INFO		*psSABufferMemInfo;
	#endif
#endif
#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH)
	PVRSRV_CLIENT_MEM_INFO 	*apsPDSCtxSwitchMemInfo[SGX_FEATURE_MP_CORE_COUNT_3D][SGX_FEATURE_NUM_PDS_PIPES]; /*!< meminfo for PDS state on ISP ctx switch */
	PVRSRV_CLIENT_MEM_INFO 	*psZLSCtxSwitchMemInfo[SGX_FEATURE_MP_CORE_COUNT_3D]; /*!< meminfo for ZLS tile on ISP ctx switch */
#endif
#if defined(SGX_SCRATCH_PRIM_BLOCK_ENABLE)
	PPVRSRV_CLIENT_MEM_INFO		psScratchPrimBlockClientMemInfo; /*!< Mem info for scratch primitive block
																	  potentially used if a render is interrupted */
#endif

#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hDevMemContext;
	IMG_SID					hTQContext;
#else
	IMG_HANDLE				hDevMemContext;
	IMG_HANDLE				hTQContext;
#endif
	#ifdef PDUMP
	IMG_BOOL				bPDumped; /*!< Flags whether or not context has been pdumped */
	#endif
	PPVRSRV_CLIENT_MEM_INFO	psVisTestResultClientMemInfo; /*!< Mem Info for visability test results. */
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID					hHWRenderContext; /*!< HW render context registration handle */
#else
	IMG_HANDLE			hHWRenderContext; /*!< HW render context registration handle */
#endif
	/* Copies of some items from SGX device information structure */
	IMG_BOOL				bForcePTOff;
	IMG_UINT32				ui32TAKickRegFlags;
#if defined(PDUMP)
	IMG_UINT32				ui32KickTANum; /*!< TA Num since last render */
	IMG_UINT32				ui32RenderNum; /*!< Render num for pdumping */
#endif	/* PDUMP */

#if defined (SUPPORT_SID_INTERFACE)
	IMG_EVENTSID			hOSEvent;
#else
	IMG_HANDLE 				hOSEvent;
#endif

#if defined(DEBUG)
	IMG_UINT32				ui32LastKickFlags;
#endif

#if defined(SUPPORT_SGX_PRIORITY_SCHEDULING)
	IMG_BOOL				bKickSubmitted;
	IMG_BOOL				bPrioritySet;
    SGX_CONTEXT_PRIORITY    ePriority;
#endif

	/* Used when apphints are set to override default values */
	IMG_UINT32			ui32NumPixelPartitions;
	IMG_UINT32			ui32NumVertexPartitions;

	IMG_BOOL			bPerContextPB;
};

typedef struct _SGX_KICKTAKM_
{
	SGX_KICKTA_COMMON *psKickTACommon;

	PVRSRV_CLIENT_SYNC_INFO	*psRenderSurfSyncInfo;
#if defined(SUPPORT_SGX_NEW_STATUS_VALS)
	CTL_STATUS				asTAStatusUpdate[SGX_MAX_TA_STATUS_VALS];
	CTL_STATUS				as3DStatusUpdate[SGX_MAX_3D_STATUS_VALS];
#else
	PVRSRV_CLIENT_SYNC_INFO	*apsTAStatusInfo[SGX_MAX_TA_STATUS_VALS];
	PVRSRV_CLIENT_SYNC_INFO	*aps3DStatusInfo[SGX_MAX_3D_STATUS_VALS];
#endif

} SGX_KICKTAKM, *PSGX_KICKTAKM;

/*
	KICKTA_SUBMIT struct stores info needed when submitting the kick
*/
typedef struct _SGX_KICKTA_SUBMIT_
{
	/*
		pvTACmd and ui32TACmdBytes should be set up by client ONLY on Vista
		where pvTACmd points to ui32TACmdBytes of reserved data
	*/
	IMG_PVOID						pvTACmd;
	IMG_UINT32						ui32TACmdBytes;

	struct _SGX_RTDATA_				*psRTData;
	struct _SGX_RTDATASET_			*psRTDataSet;
	struct _SGX_RENDERDETAILS_		*psRenderDetails;
	struct _SGX_DEVICE_SYNC_LIST_	*psDstDeviceSyncList;
	struct _SGX_RENDERCONTEXT_		*psRenderContext;
	IMG_UINT32						ui32KickFlags;


	IMG_UINT32		ui32Frame;

	IMG_BOOL		bFirstKickOrResume;
#if (defined(NO_HARDWARE) || defined(PDUMP))
	IMG_BOOL		bTerminateOrAbort;
#endif

	IMG_HANDLE		hRenderSurfSyncInfo;

	IMG_UINT32		ui32NumTAStatusVals;
	IMG_UINT32		ui32Num3DStatusVals;

#if defined(SUPPORT_SGX_NEW_STATUS_VALS)
	SGX_INTERNEL_STATUS_UPDATE	asTAStatusUpdate[SGX_MAX_TA_STATUS_VALS];
	SGX_INTERNEL_STATUS_UPDATE	as3DStatusUpdate[SGX_MAX_3D_STATUS_VALS];
#else
	IMG_HANDLE					ahTAStatusInfo[SGX_MAX_TA_STATUS_VALS];
	IMG_HANDLE					ah3DStatusInfo[SGX_MAX_3D_STATUS_VALS];
#endif

#if defined(PDUMP)
	struct _SGX_KICKTA_PDUMP_	*psKickPDUMP;
#endif

	/* source dependency details */
#if defined(SUPPORT_SGX_GENERALISED_SYNCOBJECTS)
	IMG_UINT32					ui32NumTASrcSyncs;
	PVRSRV_CLIENT_SYNC_INFO		*apsTASrcSurfSyncInfo[SGX_MAX_TA_SRC_SYNCS];
	IMG_UINT32					ui32NumTADstSyncs;
	PVRSRV_CLIENT_SYNC_INFO		*apsTADstSurfSyncInfo[SGX_MAX_TA_DST_SYNCS];
	IMG_UINT32					ui32Num3DSrcSyncs;
	PVRSRV_CLIENT_SYNC_INFO		*aps3DSrcSurfSyncInfo[SGX_MAX_3D_SRC_SYNCS];
#else
	IMG_UINT32					ui32NumSrcSyncs;
	PVRSRV_CLIENT_SYNC_INFO		*apsSrcSurfSyncInfo[SGX_MAX_SRC_SYNCS];
#endif

	/* TA/3D dependency details */
	PVRSRV_CLIENT_SYNC_INFO         *psTA3DSyncInfo;
	IMG_BOOL						bTADependency;

	PVRSRV_CLIENT_SYNC_INFO         *psTASyncInfo;
	PVRSRV_CLIENT_SYNC_INFO         *ps3DSyncInfo;

#if defined(PDUMP) || defined(DEBUG)
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID				hLastSyncInfo;
#else
	PVRSRV_CLIENT_SYNC_INFO		*psLastSyncInfo;
#endif
#endif

} SGX_KICKTA_SUBMIT, *PSGX_KICKTA_SUBMIT;


/* Setting/requesting kernel devinfo members */
typedef enum _SGX_DEV_DATA_
{
	/* DPM device dat*/
	SGX_DEV_DATA_DPM_TA_ALLOC_FREE_LIST,
	SGX_DEV_DATA_DPM_TA_ALLOC,
	SGX_DEV_DATA_DPM_3D_FREE_LIST,
	SGX_DEV_DATA_DPM_3D,
#if defined(SGX_FEATURE_HOST_ALLOC_FROM_DPM)
	SGX_DEV_DATA_DPM_HOST_DALLOC_FREE_LIST,
	SGX_DEV_DATA_DPM_HOST_DALLOC,
	SGX_DEV_DATA_DPM_HOST_ALLOC_FREE_LIST,
	SGX_DEV_DATA_DPM_HOST_ALLOC,
#endif

	/* Misc client data */
	SGX_DEV_DATA_EVM_CONFIG,
	SGX_DEV_DATA_CLIENT_KICK_FLAGS,

	SGX_DEV_DATA_NUM_USE_TEMP_REGS,
	SGX_DEV_DATA_NUM_USE_ATTRIBUTE_REGS,

	SGX_DEV_DATA_PDS_EXEC_BASE,
	SGX_DEV_DATA_USE_EXEC_BASE,

#if defined(FIX_HW_BRN_23861)
	SGX_DUMMY_STENCIL_LOAD_BASE_ADDR,
	SGX_DUMMY_STENCIL_STORE_BASE_ADDR,
#endif

	SGX_DEV_DATA_LAST = SGX_MAX_DEV_DATA
} SGX_DEV_DATA;

/* Anonymous memory handles passed to the kernel at initialisation time */
typedef enum _SGX_INIT_MEM_HANDLES_
{
	SGX_INIT_MEM_USE,
#if defined(SGX_FEATURE_MONOLITHIC_UKERNEL)
	#if defined(SGX_FEATURE_MP)
	SGX_INIT_MEM_SLAVE_PDS,
	SGX_INIT_MEM_SLAVE_USE,
	#endif
#else
	SGX_INIT_MEM_TA_USE,
	SGX_INIT_MEM_3D_USE,
	SGX_INIT_MEM_SPM_USE,
#if defined(SGX_FEATURE_2D_HARDWARE)
	SGX_INIT_MEM_2D_USE,
#endif
#endif /* SGX_FEATURE_MONOLITHIC_UKERNEL */
	SGX_INIT_MEM_PDS_INIT_PRIM1,
	SGX_INIT_MEM_PDS_INIT_SEC,
	SGX_INIT_MEM_PDS_INIT_PRIM2,
	SGX_INIT_MEM_PDS_EVENT,
	SGX_INIT_MEM_PDS_LOOPBACK,
#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	SGX_INIT_MEM_USE_CTX_SWITCH_TERM,
	SGX_INIT_MEM_PDS_CTX_SWITCH_TERM,
	SGX_INIT_MEM_USE_TA_STATE,
	SGX_INIT_MEM_PDS_TA_STATE,
#if defined(SGX_FEATURE_MTE_STATE_FLUSH) && defined(SGX_FEATURE_COMPLEX_GEOMETRY_REV_2)
	SGX_INIT_MEM_USE_CMPLX_TA_STATE,
	SGX_INIT_MEM_PDS_CMPLX_TA_STATE,
#endif
#if defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
	SGX_INIT_MEM_USE_SA_RESTORE,
	SGX_INIT_MEM_PDS_SA_RESTORE,
#endif
#endif
#if defined(FIX_HW_BRN_23861)
	SGX_INIT_MEM_DUMMY_STENCIL_LOAD,
	SGX_INIT_MEM_DUMMY_STENCIL_STORE,
#endif
	SGX_INIT_MEM_LAST = SGX_MAX_INIT_MEM_HANDLES
} SGX_INIT_MEM_HANDLES;

#endif /*  __SGXINFO_CLIENT_H__ */

/******************************************************************************
 End of file (sgxinfo_client.h)
******************************************************************************/


