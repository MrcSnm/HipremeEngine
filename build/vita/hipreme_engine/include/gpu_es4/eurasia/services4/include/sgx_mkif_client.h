/*!****************************************************************************
@File           sgx_mkif_client.h

@Title          SGX microkernel interface structures

@Author         Imagination Technologies

@Date           29th Jul 2009

@Copyright      Copyright 2009 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either material
                or conceptual may be copied or distributed, transmitted,
                transcribed, stored in a retrieval system or translated into
                any human or computer language in any form by any means,
                electronic, mechanical, manual or otherwise, or disclosed to
                third parties without the express written permission of
                Imagination Technologies Limited, Home Park Estate,
                Kings Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform       SGX

@Description    SGX microkernel interface structures used by srvclient

@DoxygenVer

******************************************************************************/

/******************************************************************************
Modifications :-
$Log: sgx_mkif_client.h $
*****************************************************************************/
#if !defined (__SGX_MKIF_CLIENT_H__)
#define __SGX_MKIF_CLIENT_H__


#if !defined(FIX_HW_BRN_23761) && !defined(SGX_FEATURE_ISP_CONTEXT_SWITCH) && !defined(SGX_FEATURE_VISTEST_IN_MEMORY)
#define	SGX_SCRATCH_PRIM_BLOCK_ENABLE
#endif


#define SGXMKIF_RENDERFLAGS_NORENDER			0x00000001UL	/*!< Only run the TA phase on the hardware, on terminate
																	 free the parameters and dummy process 3D phase */
#define SGXMKIF_RENDERFLAGS_ABORT				0x00000002UL	/*!< The scene has been aborted free the parameters and dummy
																	 process to completion */
#define SGXMKIF_RENDERFLAGS_RENDERMIDSCENE		0x00000004UL	/*!< Indicates this is a midscene render and the render resources
																	 should not be released */
#define SGXMKIF_RENDERFLAGS_NODEALLOC			0x00000008UL	/*!< Do not free the parameter memory when rendering. Typically
																	 used when doing z-only renders */
#define SGXMKIF_RENDERFLAGS_ZONLYRENDER			0x00000010UL	/*!< This render is only being used to generate z buffer data
																	 so some registers need to be tweaked (e.g. TE_PSG, ISP_ZLSCTL).
																     Setting this flag will cause the TA to terminate the control streams,
																	 but keep the TPC entries. This is so more primitives can be sent if needed and
																	 added to the control streams ready for any more renders of this scene. */
#define SGXMKIF_RENDERFLAGS_GETVISRESULTS		0x00000020UL	/*!< This render has visibility result associated with it.
																	 Setting this flag will cause the uKernel to collect the visibility results */
#define SGXMKIF_RENDERFLAGS_ACCUMVISRESULTS		0x00000040UL	/*!< Setting this flag will cause the ukernel to accumulate (sum)
																	 the visibility results */
#define SGXMKIF_RENDERFLAGS_DEPTHBUFFER			0x00000080UL	/*!< Indicates whether a depth buffer is present */
#define SGXMKIF_RENDERFLAGS_STENCILBUFFER		0x00000100UL	/*!< Indicates whether a stencil buffer is present */ 
#define SGXMKIF_RENDERFLAGS_TA_DEPENDENCY		0x00000200UL	/*!< Update 3D dependancy sync object after the render has completed */
#define SGXMKIF_RENDERFLAGS_RENDERSCENE			0x00000400UL	/*!< Update HWRTDataset completed ops after the render has completed */
#define	SGXMKIF_RENDERFLAGS_FLUSH_SLC			0x00000800UL	/*!< Flush the system cache after the render has completed */
#define SGXMKIF_RENDERFLAGS_BBOX_RENDER			0x00001000UL	/*!< This is a bounding box render */
#define SGXMKIF_RENDERFLAGS_NO_MT_SPLIT			0x00002000UL	/*!< Full render, don't split MTs */

#if !defined(__psp2__)
/*
	Bit above bit 12 are reserved for frame number
*/
#define SGXMKIF_RENDERFLAGS_FRAMENUM			0xFFFFC000UL
#define SGXMKIF_RENDERFLAGS_FRAMENUM_SHIFT		(14)
#else
#define SGXMKIF_RENDERFLAGS_SCENE_FRAGMENT_BUFFER_HIGHMARK			0x00004000UL /*!< High-water mark reached on fragment ring buffer */
#define SGXMKIF_RENDERFLAGS_SCENE_FRAGMENT_USSE_BUFFER_HIGHMARK		0x00008000UL /*!< High-water mark reached on fragment USSE ring buffer */
#endif

/*****************************************************************************
 RTData and control stream status flags.
 Note, TA complete flag on RTData means whole scene is complete, on control
 stream it means just that kick is complete.
*****************************************************************************/

#define SGXMKIF_HWRTDATA_CMN_STATUS_ALL_MASK			0x00000FF0UL
#define SGXMKIF_HWRTDATA_CMN_STATUS_READY				0x00000010UL
#define SGXMKIF_HWRTDATA_CMN_STATUS_TACOMPLETE			0x00000020UL

#define SGXMKIF_HWRTDATA_CMN_STATUS_DUMMYPROC			0x00000040UL	/*!< The scene will be dummy processed due to HW recovery ocurring  */
#define SGXMKIF_HWRTDATA_CMN_STATUS_OUTOFMEM			0x00000080UL	/*!< Indicates that an out of memory event ocurred during the TA phase */

#define SGXMKIF_HWRTDATA_CMN_STATUS_ENABLE_ZLOAD_SHIFT	(8)
#define SGXMKIF_HWRTDATA_CMN_STATUS_ENABLE_ZLOAD_MASK	0x00000100UL	/*!< Indicates that we have done a free_state_render and therefore need to force a zload */

#define SGXMKIF_HWRTDATA_CMN_STATUS_ABORT				0x00000200UL	/*!< This scene had to be aborted by the uKernel */
#define SGXMKIF_HWRTDATA_CMN_STATUS_TATIMEOUT			0x00000400UL	/*!< This scene caused the HW to lockup in the TA */
#define SGXMKIF_HWRTDATA_CMN_STATUS_RENDERTIMEOUT		0x00000800UL	/*!< This scene caused the HW to lockup in the 3D */
#define SGXMKIF_HWRTDATA_CMN_STATUS_ERROR_MASK			\
			(SGXMKIF_HWRTDATA_CMN_STATUS_ABORT | 		\
			 SGXMKIF_HWRTDATA_CMN_STATUS_TATIMEOUT |	\
			 SGXMKIF_HWRTDATA_CMN_STATUS_RENDERTIMEOUT)
#define SGXMKIF_HWRTDATA_CMN_STATUS_FRAMENUM_SHIFT		(12)			/*!< Defines the left shift required for the frame number */

#define SGXMKIF_HWRTDATA_RT_STATUS_ALL_MASK				0x0000001FUL	/*!< Mask for all render target specific state fields */
#define SGXMKIF_HWRTDATA_RT_STATUS_RENDERCOMPLETE		0x00000001UL	/*!< The 3D phase for the render target has completed  */
#define SGXMKIF_HWRTDATA_RT_STATUS_SPMRENDER			0x00000002UL	/*!< A partial render on this render target occurred due to SPM in the TA phase */
#define SGXMKIF_HWRTDATA_RT_STATUS_ISPCTXSWITCH			0x00000004UL	/*!< Set if we have context switch this RT in the 3D */
#define SGXMKIF_HWRTDATA_RT_STATUS_VDMCTXSWITCH			0x00000008UL	/*!< Set if we have context switch this RT in the 3D */

#if defined(FIX_HW_BRN_33657) && defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
/* README: This flag differs from SGXMKIF_HWRTDATA_RT_STATUS_VDMCTXSWITCH because it is cleared
 * on each new HW kick. The flag is only set if the current TA kick has to be stored out.
 * In this case the workaround requires that the corresponding partial PIM state must be
 * patched in memory.
 */
#define SGXMKIF_HWRTDATA_RT_STATUS_VDMCTXSTORE			0x00000010UL	/*!< Set if the current TA operation on this RT was stored */
#endif

/* entry in the LastRgn LUT */
#define SGXMKIF_HWRTDATA_RGNOFFSET_VALID		(1)
#define SGXMKIF_HWRTDATA_RGNOFFSET_MASK			(EUR_CR_ISP_RGN_BASE_ADDR_MASK)


/*
	The host must indicate if this is the first and/or last command to
	be issued for the specified task
*/
#define SGXMKIF_TAFLAGS_FIRSTKICK				0x00000001UL
#define SGXMKIF_TAFLAGS_LASTKICK				0x00000002UL

/*
	When a mid-scene render has been kicked this flag tells the pcore code
	to wait for it to complete before kicking TA
*/

#define SGXMKIF_TAFLAGS_RESUMEMIDSCENE			0x00000004UL

/*
	Tells the primary core that we are sending another ta command after a
	mid-scene render which freed the associated parameters so a ta context
	reset is required.
*/
#define SGXMKIF_TAFLAGS_RESUMEDAFTERFREE		0x00000008UL

/*
	Invalidate the USE cache before this TA kick.
*/
#define SGXMKIF_TAFLAGS_INVALIDATEUSECACHE		0x00000010UL

/*
	Invalidate the PDS cache before this TA kick.
*/
#define SGXMKIF_TAFLAGS_INVALIDATEPDSCACHE		0x00000020UL

/*
	Flush the data cache before this ta kick.
*/
#define SGXMKIF_TAFLAGS_INVALIDATEDATACACHE		0x00000040UL

/*
	Indicates that complex geometry is used during the TA stream
*/
#define SGXMKIF_TAFLAGS_CMPLX_GEOMETRY_PRESENT	0x00000080UL


/*
	Flags to check 3D dependency sync object
*/
#define SGXMKIF_TAFLAGS_DEPENDENT_TA			0x00000400UL

#define SGXMKIF_TAFLAGS_VDM_CTX_SWITCH			0x00000800UL

#if defined(__psp2__)
/* Flag to determine an OpenCL task */
#define SGXMKIF_TAFLAGS_TA_TASK_OPENCL			0x00004000UL


/* Flags to indicate this cmd has an update to the PB */
#define SGXMKIF_TAFLAGS_PB_THRESHOLD_UPDATE		0x00010000UL
#define SGXMKIF_TAFLAGS_PB_UPDATE_MASK			(SGXMKIF_TAFLAGS_PB_THRESHOLD_UPDATE)

/*
	Indicates that the ring buffer reached its high-water mark
 */
#define SGXMKIF_TAFLAGS_SCENE_VDM_BUFFER_HIGHMARK			0x00400000UL
#define SGXMKIF_TAFLAGS_SCENE_VERTEX_BUFFER_HIGHMARK		0x00800000UL
#define SGXMKIF_TAFLAGS_SCENE_FRAGMENT_BUFFER_HIGHMARK		0x01000000UL
#define SGXMKIF_TAFLAGS_SCENE_FRAGMENT_USSE_BUFFER_HIGHMARK	0x02000000UL

 /*
	 Indicates that the kick was initiated as a mid-scene kick
  */
#define SGXMKIF_TAFLAGS_SCENE_MIDSCENE_KICK					0x04000000UL

  /*
	  Flush the SLC after completing this TA job.
  */
#define SGXMKIF_TAFLAGS_FLUSH_SLC					0x10000000UL
#else
/* Flag to determine an OpenCL task */
#define SGXMKIF_TAFLAGS_TA_TASK_OPENCL			0x00001000UL


/* Flags to indicate this cmd has an update to the PB */
#define SGXMKIF_TAFLAGS_PB_THRESHOLD_UPDATE		0x00002000UL
#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
#define SGXMKIF_TAFLAGS_PB_GROW					0x00004000UL
#define SGXMKIF_TAFLAGS_PB_SHRINK				0x00008000UL
#define SGXMKIF_TAFLAGS_PB_UPDATE_MASK			(SGXMKIF_TAFLAGS_PB_GROW | \
												 SGXMKIF_TAFLAGS_PB_SHRINK | \
												 SGXMKIF_TAFLAGS_PB_THRESHOLD_UPDATE)
#else
#define SGXMKIF_TAFLAGS_PB_UPDATE_MASK			(SGXMKIF_TAFLAGS_PB_THRESHOLD_UPDATE)
#endif
#if defined(SGX_FEATURE_MP) && defined(FIX_HW_BRN_31079)
#define	SGXMKIF_TAFLAGS_VDM_PIM_WRAP_BIT		(16)
#define SGXMKIF_TAFLAGS_VDM_PIM_WRAP			(1 << SGXMKIF_TAFLAGS_VDM_PIM_WRAP_BIT)
#endif
#endif

/*****************************************************************************
 Parameter buffer control structures.
*****************************************************************************/
/*! Microkernel parameter buffer block */
typedef struct _SGXMKIF_HWPBBLOCK_
{
	IMG_UINT32			ui32PageCount;/*!< size of block in pages */
	IMG_UINT16			ui16Head;/*!< index of head of block */
	IMG_UINT16			ui16Tail;/*!< index of tail of block */
	IMG_DEV_VIRTADDR	sParentHWPBDescDevVAddr;/*!< ptr to parent HW PB Desc */
	IMG_DEV_VIRTADDR	sNextHWPBBlockDevVAddr;/*!< ptr to next HW PB Block */
} SGXMKIF_HWPBBLOCK, *PSGXMKIF_HWPBBLOCK;

/*! Microkernel parameter buffer descriptor */
typedef struct _SGXMKIF_HWPBDESC_
{
	/* THIS HAS TO BE THE FIRST MEMBER */
	IMG_UINT32				ui32PBFlags;/*!< PB flags */

	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32NumPages;/*!< number of pages in the PB */
	IMG_UINT32				ui32FreeListInitialHT;/*!< Freelist Initial head/tail value */
	IMG_UINT32				ui32FreeListInitialPrev;/*!< Freelist Initial previous value */
	IMG_DEV_VIRTADDR		sEVMPageTableDevVAddr;/*!< DPM pagetable device virtual address */

	IMG_UINT32				ui32AllocPages;/*!< Snapshot of pages allocated */

	IMG_UINT32				ui32FreeListHT;/*!< free list info */
	IMG_UINT32				ui32FreeListPrev;/*!< free list info */


	IMG_UINT32				uiLocalPages;/*!< local page memory that's been allocated */
	IMG_UINT32				uiGlobalPages;/*!< global page memory that's been allocated */

#if defined(DEBUG)
	volatile IMG_UINT32		ui32AllocPagesWatermark;/*!< Max number of pages allocated */
#endif

	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32TAThreshold;/*!< TA threshold */
	IMG_UINT32				ui32ZLSThreshold;/*!< ZLS threshold */
	IMG_UINT32				ui32GlobalThreshold;/*!< Global threshold */
	IMG_UINT32				ui32PDSThreshold;/*!< PDS threshold */

	IMG_DEV_VIRTADDR		sListPBBlockDevVAddr;/*!< List of HW PB Blocks in this PB (Desc) */


#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
	volatile IMG_UINT32		ui32ShrinkComplete;/*!< shrink complete */
	IMG_DEV_VIRTADDR		sGrowListPBBlockDevVAddr;/*!< List of HW PB Blocks to be initialised following a grow */
#endif
} SGXMKIF_HWPBDESC, *PSGXMKIF_HWPBDESC;


/* HW PB Desc flags */
#define HWPBDESC_FLAGS_INITPT				(1 << 0)	/* DPM Page table needs to be initialised */
#define HWPBDESC_FLAGS_THRESHOLD_UPDATE		(1 << 1)	/* New threshold values to be used */
#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
#define HWPBDESC_FLAGS_GROW					(1 << 2)	/* New PBBlock Page table needs to be initialised */
#define HWPBDESC_FLAGS_UPDATE_MASK			(HWPBDESC_FLAGS_INITPT | \
											HWPBDESC_FLAGS_THRESHOLD_UPDATE | \
											HWPBDESC_FLAGS_GROW)
#else
#define HWPBDESC_FLAGS_UPDATE_MASK			(HWPBDESC_FLAGS_INITPT | \
											HWPBDESC_FLAGS_THRESHOLD_UPDATE)
#endif

/*! Microkernel HW parameter buffer descriptir update structure */
typedef	struct _SGXMKIF_HWPBDESC_UPDATE_
{
	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32TAThreshold; /*!< TA threshold */
	IMG_UINT32				ui32ZLSThreshold;/*!< ZLS threshold */
	IMG_UINT32				ui32GlobalThreshold;/*!< GLobal threshold */
	IMG_UINT32				ui32PDSThreshold;/*!< PDS threshold */

#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32NumPages;/*!< number of pages */
	IMG_UINT32				ui32FreeListInitialHT;/*!< free list initial head/tail values */
	IMG_UINT32				ui32FreeListInitialPrev;/*!< free list initial previous value */

	/* KEEP THESE 2 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_DEV_VIRTADDR		sPBBlockPtrUpdateDevAddr;/*!< PB block ptr update device virtual address */
	IMG_UINT32				ui32PBBlockPtrUpdate;/*!< PB block ptr update */
#endif

}SGXMKIF_HWPBDESC_UPDATE;


/*!
	HW specific structure defining which registers need to be loaded
	before a TA kick can be started
*/
#if defined(__psp2__)
typedef struct _SGXMKIF_TAREGISTERS_
{
	IMG_UINT32	ui32TEAA;/*!< TE AA mode control register value */
	IMG_UINT32	ui32TEMTile1;/*!< TE macrotile control register value */
	IMG_UINT32	ui32TEMTile2;/*!< TE macrotile control register value */
	IMG_UINT32	ui32TEScreen;/*!< TE screen config register value */
	IMG_UINT32	ui32TEMTileStride;/*!< TE macrotile stride control register value */
	IMG_UINT32	ui32TEPSG;/*!< TE PSG register value */
	IMG_UINT32	ui32VDMCtrlStreamBase;/*!< VDM control stream base register value */
	IMG_UINT32	ui32MTECtrl;/*!< MTE ccontrol register value */
	IMG_UINT32	aui32TEPSGRgnBase[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< TE PSG region base(s) register value(s) */
	IMG_UINT32	aui32TETPCBase[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< TE TPC base(s) register value(s) */
	IMG_UINT32	ui32MTEWCompare;/*!< MTE W Compare register value */
	IMG_UINT32	ui32MTEWClamp;/*!< MTE W Clamp register value */
	IMG_UINT32	ui32MTEScreen;/*!< MTE Screen config register value */
	IMG_UINT32	ui32USELDRedirect;/*!< USE LD redirect register value */
	IMG_UINT32	ui32USESTRange;/*!< USE ST Range control register value */
	IMG_UINT32	ui32BIFTAReqBase;/*!< TA requestor base register value */
#if defined(EUR_CR_MTE_FIXED_POINT)
	IMG_UINT32	ui32MTEFixedPoint;/*!< MTE Fixed point control register value */
#endif
#if defined(SGX545)
	#if defined(FIX_HW_BRN_26915)
	IMG_UINT32	ui32GSGBaseAndStride;/*!< GSG Base and stride register value */
	#else
	IMG_UINT32	ui32GSGStride;/*!< GSG Stride register value */
	IMG_UINT32	ui32GSGBase;/*!< GSG Base register value */
	#endif
	IMG_UINT32	ui32GSGWrap;/*!< GSG Wrap register value */
	IMG_UINT32	ui32GSGStateStore;/*!< GSG State Store register value */
	IMG_UINT32	ui32MTE1stPhaseCompGeomBase;/*!< MTE 1st Phase compllext geometry base register value */
	IMG_UINT32	ui32MTE1stPhaseCompGeomSize;/*!< MTE 1st Phase compllext geometry size register value */
	IMG_UINT32	ui32VtxBufWritePointerPDSProg;/*!< Vertex buffer write pointer (PDS program) register value */
	IMG_UINT32	ui32SCWordCopyProgram;/*!< SC word copy program register value */
	IMG_UINT32	ui32ITPProgram;/*!< ITP program register value */
	#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32	ui32TARTMax;/*!< max render targets */
	IMG_UINT32	ui32TETPC;/*!< TPC control */
	#endif
#endif
	IMG_UINT32	ui32MTEMSCtrl;/*!< MTE MS control register value */

	IMG_UINT32	ui32MasterMPPrimitive;/*!< Master MP Primitive register value */
} SGXMKIF_TAREGISTERS, *PSGXMKIF_TAREGISTERS;
#else
typedef struct _SGXMKIF_TAREGISTERS_
{
	IMG_UINT32	ui32TEAA;/*!< TE AA mode control register value */
	IMG_UINT32	ui32TEMTile1;/*!< TE macrotile control register value */
	IMG_UINT32	ui32TEMTile2;/*!< TE macrotile control register value */
	IMG_UINT32	ui32TEScreen;/*!< TE screen config register value */
	IMG_UINT32	ui32TEMTileStride;/*!< TE macrotile stride control register value */
	IMG_UINT32	ui32TEPSG;/*!< TE PSG register value */
	IMG_UINT32	ui32VDMCtrlStreamBase;/*!< VDM control stream base register value */
	IMG_UINT32	ui32MTECtrl;/*!< MTE ccontrol register value */
	IMG_UINT32	aui32TEPSGRgnBase[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< TE PSG region base(s) register value(s) */
	IMG_UINT32	aui32TETPCBase[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< TE TPC base(s) register value(s) */
	IMG_UINT32	ui32MTEWCompare;/*!< MTE W Compare register value */
	IMG_UINT32	ui32MTEWClamp;/*!< MTE W Clamp register value */
	IMG_UINT32	ui32MTEScreen;/*!< MTE Screen config register value */
	IMG_UINT32	ui32USELDRedirect;/*!< USE LD redirect register value */
	IMG_UINT32	ui32USESTRange;/*!< USE ST Range control register value */
	IMG_UINT32	ui32BIFTAReqBase;/*!< TA requestor base register value */
#if defined(EUR_CR_MTE_FIXED_POINT)
	IMG_UINT32	ui32MTEFixedPoint;/*!< MTE Fixed point control register value */
#endif
#if defined(SGX545)
	#if defined(FIX_HW_BRN_26915)
	IMG_UINT32	ui32GSGBaseAndStride;/*!< GSG Base and stride register value */
	#else
	IMG_UINT32	ui32GSGStride;/*!< GSG Stride register value */
	IMG_UINT32	ui32GSGBase;/*!< GSG Base register value */
	#endif
	IMG_UINT32	ui32GSGWrap;/*!< GSG Wrap register value */
	IMG_UINT32	ui32GSGStateStore;/*!< GSG State Store register value */
	IMG_UINT32	ui32MTE1stPhaseCompGeomBase;/*!< MTE 1st Phase compllext geometry base register value */
	IMG_UINT32	ui32MTE1stPhaseCompGeomSize;/*!< MTE 1st Phase compllext geometry size register value */
	IMG_UINT32	ui32VtxBufWritePointerPDSProg;/*!< Vertex buffer write pointer (PDS program) register value */
	IMG_UINT32	ui32SCWordCopyProgram;/*!< SC word copy program register value */
	IMG_UINT32	ui32ITPProgram;/*!< ITP program register value */
	#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32	ui32TARTMax;/*!< max render targets */
	IMG_UINT32	ui32TETPC;/*!< TPC control */
	#endif
#endif
	IMG_UINT32	ui32MTEMSCtrl;/*!< MTE MS control register value */
} SGXMKIF_TAREGISTERS, *PSGXMKIF_TAREGISTERS;
#endif

/*!
	TA command. The SGX TA can be used to tile a whole scene's objects
	as per TA behaviour on SGX.
*/
#if defined(__psp2__)
typedef struct _SGXMKIF_CMDTA_
{
	IMG_UINT32				ui32Size; /*!< command size */
	IMG_UINT32				ui32Flags; /*!< command control flags */
	IMG_UINT32				aui32SpecObject[3];/*!< special object pathing words */
	IMG_UINT32				ui32BGObjDims;/*!< Dimensions for the BGObj */
	IMG_UINT32				ui32NumVertexPartitions;/*!< number of vertex partitions */
	IMG_UINT32				ui32SPMNumVertexPartitions;/*!< number of vertex partitions */
	IMG_UINT32				ui32RenderFlags;/*!< render control flags */
	IMG_UINT32				ui32FrameNum;/*!< associated frame number */
	IMG_UINT32				ui32SceneNum;/*!< associated scene number */
	IMG_DEV_VIRTADDR		sHWPBDescDevVAddr;/*!< Device virtual address of parameter buffer */
	SGXMKIF_HWPBDESC_UPDATE	sHWPBDescUpdate;/*!< HW parameter buffer update descriptor */
	IMG_DEV_VIRTADDR		sHWRenderDetailsDevAddr;/*!< HW render details Device Virtual Address */
	IMG_DEV_VIRTADDR		sHWDstSyncListDevAddr;/*!< HW Dst Sync List Device Virtual Address */
	IMG_DEV_VIRTADDR		sHWRTDataSetDevAddr;/*!< HW RTDataSet Device Virtual Address */
	IMG_DEV_VIRTADDR		sHWRTDataDevAddr;/*!< HW RTData Device Virtual Address */

#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#if !defined(SGX_FEATURE_MTE_STATE_FLUSH)
	IMG_DEV_VIRTADDR		sTAStateShadowDevAddr;/*!< TA State shadow buffer device virtual address */
	#endif
	#if !defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
	IMG_DEV_VIRTADDR		sVDMSARestoreDataDevAddr[SGX_MAX_VDM_STATE_RESTORE_PROGS];/*!< VDM SA restore Device Virtual Address */
	#endif
#endif /* SGX_FEATURE_VDM_CONTEXT_SWITCH_REV_2 */

#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	IMG_UINT32				ui32VisTestCount;/*!< Visibility test count */
#else
	IMG_DEV_VIRTADDR		sVisTestResultsDevAddr;/*!< Visibility test results buffer device virtual address */
#endif
#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32				ui32ZBufferStride;
	IMG_UINT32				ui32SBufferStride;
#endif
	IMG_UINT32				ui32Num3DRegs;/*!< number of 3d registers to write */

	SGXMKIF_CMDTA_SHARED	sShared;/*!< CMDTA shared command */
	SGXMKIF_TAREGISTERS		sTARegs;/*!< TA registers */
	
	PVRSRV_HWREG			s3DRegUpdates[1];/*!< 3D register updates */
	
	/*** README ***
	 *
	 * 3D register updates may be larger than 1 and will be allocated in the
	 * driver when the command is inserted in the TA cmd circular buffer.
	 * Don't add structure members here as they will potentially conflict with
	 * register updates causing the driver to crash.
	 */
} SGXMKIF_CMDTA,*PSGXMKIF_CMDTA;
#else
typedef struct _SGXMKIF_CMDTA_
{
	IMG_UINT32				ui32Size; /*!< command size */
	IMG_UINT32				ui32Flags; /*!< command control flags */
	IMG_UINT32				aui32SpecObject[3];/*!< special object pathing words */
	IMG_UINT32				ui32NumVertexPartitions;/*!< number of vertex partitions */
	IMG_UINT32				ui32SPMNumVertexPartitions;/*!< number of vertex partitions */
	IMG_UINT32				ui32RenderFlags;/*!< render control flags */
	IMG_UINT32				ui32FrameNum;/*!< associated frame number */
	IMG_DEV_VIRTADDR		sHWPBDescDevVAddr;/*!< Device virtual address of parameter buffer */
	SGXMKIF_HWPBDESC_UPDATE	sHWPBDescUpdate;/*!< HW parameter buffer update descriptor */
	IMG_DEV_VIRTADDR		sHWRenderDetailsDevAddr;/*!< HW render details Device Virtual Address */
	IMG_DEV_VIRTADDR		sHWDstSyncListDevAddr;/*!< HW Dst Sync List Device Virtual Address */
	IMG_DEV_VIRTADDR		sHWRTDataSetDevAddr;/*!< HW RTDataSet Device Virtual Address */
	IMG_DEV_VIRTADDR		sHWRTDataDevAddr;/*!< HW RTData Device Virtual Address */

#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#if !defined(SGX_FEATURE_MTE_STATE_FLUSH)
	IMG_DEV_VIRTADDR		sTAStateShadowDevAddr;/*!< TA State shadow buffer device virtual address */
	#endif
	#if !defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
	IMG_DEV_VIRTADDR		sVDMSARestoreDataDevAddr[SGX_MAX_VDM_STATE_RESTORE_PROGS];/*!< VDM SA restore Device Virtual Address */
	#endif
#endif /* SGX_FEATURE_VDM_CONTEXT_SWITCH_REV_2 */

#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	IMG_UINT32				ui32VisTestCount;/*!< Visibility test count */
#else
	IMG_DEV_VIRTADDR		sVisTestResultsDevAddr;/*!< Visibility test results buffer device virtual address */
#endif
#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32				ui32ZBufferStride;
	IMG_UINT32				ui32SBufferStride;
#endif
	IMG_UINT32				ui32Num3DRegs;/*!< number of 3d registers to write */

	SGXMKIF_CMDTA_SHARED	sShared;/*!< CMDTA shared command */
	SGXMKIF_TAREGISTERS		sTARegs;/*!< TA registers */
	
	PVRSRV_HWREG			s3DRegUpdates[1];/*!< 3D register updates */
	
	/*** README ***
	 *
	 * 3D register updates may be larger than 1 and will be allocated in the
	 * driver when the command is inserted in the TA cmd circular buffer.
	 * Don't add structure members here as they will potentially conflict with
	 * register updates causing the driver to crash.
	 */
} SGXMKIF_CMDTA,*PSGXMKIF_CMDTA;
#endif

/*!
	microkernel structure contains all set-up info associated with one set
	of unique render target dimension data, there will be two of these
	(allocated as an array) per unique dimension to allow for simultaneous
	TA and 3D core operation.
*/
typedef struct _SGXMKIF_HWRTDATA_
{
	IMG_DEV_VIRTADDR		sHWRenderContextDevAddr;/*!< parent HW register context device virtual address */
	IMG_DEV_VIRTADDR		sHWRenderDetailsDevAddr;/*!< assigned HW render details device virtual address */

#if !defined(SGX_FEATURE_ISP_CONTEXT_SWITCH)
	#if !defined(SGX_FEATURE_ISP_BREAKPOINT_RESUME_REV_2) && !defined(FIX_HW_BRN_23761) && !defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	IMG_DEV_VIRTADDR		sTileRgnLUTDevAddr;/*!< tile lookup table device virtual address */
	#endif
#endif

	#if defined(SGX_FEATURE_SW_ISP_CONTEXT_SWITCH)
	IMG_UINT32				ui32LastMTIdx;/*!< Last macrotile index */
	#endif

#if defined(FIX_HW_BRN_27311) && !defined(FIX_HW_BRN_23055) || defined(FIX_HW_BRN_30089) || defined(FIX_HW_BRN_29504) || defined(FIX_HW_BRN_33753)
	IMG_UINT16				ui16NumMTs;			/* !< Number of MTs */
#endif

#if defined(FIX_HW_BRN_27311) && !defined(FIX_HW_BRN_23055)
	IMG_UINT16				ui16SPMRenderMask;	/* !< Mask to indicate which MTs have been rendered */
	IMG_UINT16				ui16BRN27311Mask;	/* !< Mask to detect when all MTs have been rendered */
#endif

	IMG_UINT32				ui32NumTileBlocksPerMT;/*!< number of tile block per macro tile */
	IMG_UINT32				ui32MTRegionArraySize;
#if defined(SGX_FEATURE_SW_ISP_CONTEXT_SWITCH) || defined(FIX_HW_BRN_23862) || defined(FIX_HW_BRN_30089) || defined(FIX_HW_BRN_29504) || defined(FIX_HW_BRN_33753)
	IMG_DEV_VIRTADDR		sLastRgnLUTDevAddr;/*!< last region offset lookup table virtual address */
	IMG_DEV_VIRTADDR		sRegionArrayDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< region array device virtual addresses */
	IMG_DEV_VIRTADDR		sLastRegionDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< last region device virtual address (in the last MT) */
#endif
	#if defined(FIX_HW_BRN_23862)
	IMG_DEV_VIRTADDR		sBRN23862FixObjectDevAddr;/*!< BRN23862 fix object device virtual address */
	IMG_DEV_VIRTADDR		sBRN23862PDSStateDevAddr;/*!< BRN23862 PDS state device virtual address */
	#endif /* defined(FIX_HW_BRN_23862) */
	IMG_DEV_VIRTADDR		sBGObjBaseDevAddr;/*!< Background object device virtual address */
	IMG_DEV_VIRTADDR		sContextStateDevAddr;/*!< context state device virtual address */

#if defined(SGX_FEATURE_MP)
	#if defined(EUR_CR_MASTER_DPM_MTILE_PARTI_PIM_TABLE_BASE_ADDR)
	IMG_DEV_VIRTADDR		sPIMTableDevAddr;/*!< PIM table device virtual address */
	#endif
#endif
#if defined(FIX_HW_BRN_33657) && defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	IMG_UINT32			ui32VDMPIM;	/*!< VDM PIM value for partial PIM patching */
#endif

	//FIXME: these 3 things are not double buffered and can be moved to SGXMKIF_HWRTDATASET
	IMG_DEV_VIRTADDR		sContextControlDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< per core DPM control table device virtual address */
	IMG_DEV_VIRTADDR		sContextOTPMDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< per core OTPM device virtual address */
	IMG_DEV_VIRTADDR		asTailPtrDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< per core tail ptr buffer device virtual address */
	IMG_UINT32				ui32TailSize;/*!< tail ptr buffer size */

#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	IMG_UINT32				ui32NumRTsInArray;/*!< Number of render targets in the array */
	IMG_UINT32				ui32RgnStride;/*!< region stride */
#endif
	IMG_DEV_VIRTADDR		sRTStatusDevAddr;/*!< render target status device virtual address */
	volatile IMG_UINT32		ui32CommonStatus;/*!< common status value */
} SGXMKIF_HWRTDATA, *PSGXMKIF_HWRTDATA;


/*!
	Render target data set HW structure,

	ui32MTileWidth				- Render width rounded to macrotile size

	asHWRTData[]	- Buffered set of target data.
*/
typedef struct _SGXMKIF_HWRTDATASET_
{
	IMG_DEV_VIRTADDR		sPendingCountDevAddr;/*!< pending count */
	IMG_UINT32				ui32CompleteCount;/*!< complete count */

	IMG_UINT32				ui32MTileWidth;/*!< Macro tile width */
#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#if defined(FIX_HW_BRN_33657) && defined(SUPPORT_SECURE_33657_FIX)
	IMG_UINT32				ui32MTileHeight;/*!< Macro tile height */
	#endif
#endif
	IMG_UINT32				ui32NumOutOfMemSignals;/*!< number of out of memory signals */
	IMG_UINT32				ui32NumSPMRenders;/*!< number of SPM (partial) renders */

	//FIXME: these 3 things are not double buffered and can be moved to SGXMKIF_HWRTDATASET
	// uncomment when asm mod's complete
	//IMG_DEV_VIRTADDR		sContextControlDevAddr;
	//IMG_DEV_VIRTADDR		sContextOTPMDevAddr;
	//IMG_DEV_VIRTADDR		sTailPtrDevAddr;

#if defined(FIX_HW_BRN_32044)
	IMG_DEV_VIRTADDR		s32044CtlStrmDevAddr; /* points to first element in control stream array */
	IMG_UINT32				ui32NumTiles; /* number of tiles in RT */
#endif
	IMG_UINT32				ui32NumRTData;		/*!< Number of RT data elements in the asHWRTData array */
	SGXMKIF_HWRTDATA		asHWRTData[1];		/*!< multibuffered RTData structures, array will be overallocated up to size ui32NumRTData */
	/* asHWRTData must be the last member of this structure */
} SGXMKIF_HWRTDATASET, *PSGXMKIF_HWRTDATASET;

/*****************************************************************************

 Host interface structures.
*****************************************************************************/

/*!
 *
 * HW specific structure defining which registers need to be loaded
 * before a render can be started. These are initialised at the start
 * of frame and then can be updated by sending changes via the TA cmd
 */
typedef struct _SGXMKIF_3DREGISTERS_
{
#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	IMG_UINT32	aui32VisRegBase[SGX_FEATURE_MP_CORE_COUNT_3D];/*!< Visibility register value array */
#endif
	IMG_UINT32	ui32BIF3DReqBase;/*!< 3d requestor base register value */
	IMG_UINT32	ui32BIFZLSReqBase;/*!< ZLS requestor base register value */
	IMG_UINT32	ui32PixelBE; /*!< EUR_CR_PIXELBE register value */
	IMG_UINT32	ui32ISPIPFMisc;/*!< ISP IPF Misc register value */
	IMG_UINT32	ui323DAAMode;/*!< 3D AA mode register value */
#if defined(SGX_FEATURE_DEPTH_BIAS_OBJECTS)
	IMG_UINT32	ui32ISPDBias[3];/*!< ISP depth bias register values */
#else
	IMG_UINT32	ui32ISPDBias[1];/*!< ISP depth bias register value */
#endif
#if defined(EUR_CR_4Kx4K_RENDER)
	IMG_UINT32	ui324KRender;/*!< 4k x 4k render control register value */
#endif
	IMG_UINT32	aui32ISPRgnBase[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< ISP region header(s) register value(s) */
#if defined(SGX_FEATURE_MP)
	IMG_UINT32	ui32ISPRgn;/*!<  region headers size in bytes */
#endif
#if defined(EUR_CR_ISP_MTILE)	
	IMG_UINT32	ui32ISPMTile;/*!< ISP macrotile control register value(s) */
	IMG_UINT32	ui32ISPMTile1;/*!< ISP macrotile control register value(s) */
	IMG_UINT32	ui32ISPMTile2;/*!< ISP macrotile control register value(s) */
#endif
#if defined(EUR_CR_DOUBLE_PIXEL_PARTITIONS)
	IMG_UINT32	ui32DoublePixelPartitions;/*!< double pixel partition register value */
#endif
#if defined(EUR_CR_ISP_OGL_MODE)
	IMG_UINT32	ui32ISPOGLMode;/*!<  OpenGL mode control register value */
	IMG_UINT32	ui32ISPPerpendicular;/*!< ISP perpendicular threshold register value */
	IMG_UINT32	ui32ISPCullValue;/*!< ISP Cull threshold register value */
#endif
#if defined(SGX_FEATURE_ZLS_EXTERNALZ)
	IMG_UINT32	aui32ZLSExtZRgnBase[SGX_FEATURE_MP_CORE_COUNT_3D];/*!< ZLS external Z control register value */
#endif
	IMG_UINT32	ui32ISPZLSCtl;/*!< ISP ZLS control register value */
	IMG_UINT32	ui32ISPZLoadBase;/*!< ISP ZLoad base address register value */
	IMG_UINT32	ui32ISPZStoreBase;/*!< ISP ZStore base address register value */
	IMG_UINT32	ui32ISPStencilLoadBase;/*!< ISP StencilLoad base address register value */
	IMG_UINT32	ui32ISPStencilStoreBase;/*!< ISP StencilStore base address register value */
	IMG_UINT32	ui32ISPBgObjDepth;/*!< ISP background object depth register value */
	IMG_UINT32	ui32ISPBgObj;/*!< ISP background object control register value */
	IMG_UINT32	ui32ISPBgObjTag;/*!< ISP background object tag control register value */
#if defined(EUR_CR_ISP_MULTISAMPLECTL2)
	IMG_UINT32	ui32ISPMultisampleCtl2;/*!< ISP multisampling control2 register value */
#endif
	IMG_UINT32	ui32ISPMultisampleCtl;/*!< ISP multisampling control register value */
	IMG_UINT32	ui32ISPTAGCtrl;/*!< ISP Tag cpntrol register value */
	IMG_UINT32	ui32TSPConfig;/*!< TSP Config register value */
	IMG_UINT32	ui32EDMPixelPDSExec;/*!< EDM Pixel PDS Exec register value */
	IMG_UINT32	ui32EDMPixelPDSData;/*!< EDM Pixel PDS Data register value */
	IMG_UINT32	ui32EDMPixelPDSInfo;/*!< EDM Pixel PDS Info register value */
#if defined(EUR_CR_ISP_FPUCTRL)
	IMG_UINT32	ui32ISPFPUCtrl;/*!< ISP FPU control register value */
#endif

	IMG_UINT32	ui32USEFilter0Left;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter0Right;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter0Extra;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter1Left;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter1Right;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter1Extra;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter2Left;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter2Right;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter2Extra;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilterTable;/*!< USSE filter table control register value */
#if defined(SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF)
	IMG_UINT32	ui32USEFilter0Centre;/*!< USSE FIRH Coefficient register value */
	IMG_UINT32	ui32USEFilter1Centre;/*!< USSE FIRH Coefficient register value */
#endif
#if defined(SGX_FEATURE_TAG_YUV_TO_RGB)
	IMG_UINT32	ui32CSC0Coeff01;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC0Coeff23;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC0Coeff45;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC0Coeff67;/*!< Colour Space Conversion Coefficient register value */

	IMG_UINT32	ui32CSC1Coeff01;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC1Coeff23;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC1Coeff45;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC1Coeff67;/*!< Colour Space Conversion Coefficient register value */

#if !defined(SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC)
	IMG_UINT32	ui32CSC0Coeff8;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC1Coeff8;/*!< Colour Space Conversion Coefficient register value */

	IMG_UINT32	ui32CSCScale;/*!< Colour Space Conversion Scale control register value */
#else
	IMG_UINT32	ui32CSC0Coeff89;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC1Coeff89;/*!< Colour Space Conversion Coefficient register value */

	IMG_UINT32	ui32CSC0Coeff1011;/*!< Colour Space Conversion Coefficient register value */
	IMG_UINT32	ui32CSC1Coeff1011;/*!< Colour Space Conversion Coefficient register value */
#endif
#endif /* SGX_FEATURE_TAG_YUV_TO_RGB */
#if defined(EUR_CR_TPU_LUMA0)
	IMG_UINT32	ui32TPULuma0;/*!< YUV Luma TPU register value */
	IMG_UINT32	ui32TPULuma1;/*!< YUV Luma TPU register value */
	IMG_UINT32	ui32TPULuma2;/*!< YUV Luma TPU register value */
#endif
#if defined(EUR_CR_PDS_PP_INDEPENDANT_STATE)
	IMG_UINT32  ui32PDSPPState;/*!< ISP PP independent state register value */
#endif
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
	IMG_UINT32	ui32BIFTile0Config;/*!< BIF MMU Tile0 config register value */
#endif
#if defined(SGX_FEATURE_ALPHATEST_COEFREORDER) && defined(EUR_CR_ISP_DEPTHSORT_FB_ABC_ORDER_MASK)
	IMG_UINT32	ui32ISPDepthsort;
#endif
} SGXMKIF_3DREGISTERS, *PSGXMKIF_3DREGISTERS;

/*!
	Render details. All the information required to kick off a render
	either normally at the end of a scene or mid-scene due to entering
	SPM mode.
*/
#if defined(__psp2__)
typedef struct _SGXMKIF_HWRENDERDETAILS_
{
	SGXMKIF_3DREGISTERS		s3DRegs;/*!< 3d registers */
	IMG_DEV_VIRTADDR		sAccessDevAddr;/*!< access lock device virtual address */
	IMG_UINT32				ui32RenderFlags;/*!< render flags */

	IMG_DEV_VIRTADDR		sHWRTDataSetDevAddr;/*!< HW RT data set device virtual address */
	IMG_DEV_VIRTADDR		sHWRTDataDevAddr;/*!< HW RT Data device virtual address */

	IMG_DEV_VIRTADDR		sHWDstSyncListDevAddr;/*!< HW Dst Sync List device virtual address */

	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32TQSyncWriteOpsPendingVal;/*!< TQ Sync write Ops Pending */
	IMG_DEV_VIRTADDR		sTQSyncWriteOpsCompleteDevVAddr;/*!< TQ Sync Write Ops Complete */
	IMG_UINT32				ui32TQSyncReadOpsPendingVal;/*!< TQ Sync Read Ops Pending */
	IMG_DEV_VIRTADDR		sTQSyncReadOpsCompleteDevVAddr;/*!< TQ Sync Read Ops Complete */
	/* TA/3D dependency sync criteria to be updated after render */
	PVRSRV_DEVICE_SYNC_OBJECT	sTA3DDependency;/*!< TA-3D dependency sync object */

#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	/* KEEP THESE 2 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32NumRTs;/*!< number of render targets */
	IMG_UINT32				ui32NextRTIdx;/*!< Next render target index */

	IMG_DEV_VIRTADDR		sPixEventUpdateDevAddr;/*!<  Pixel event update device virtuak address */
	IMG_DEV_VIRTADDR		sHWPixEventUpdateListDevAddr;/*!< HW Pixel Event update List base device virtual address */
	IMG_DEV_VIRTADDR		sHWBgObjPrimPDSUpdateListDevAddr;/*!< HW background object Primary PDS update List device virtual address */

	IMG_UINT32				ui32ZBufferStride;/*!< Stride of Depth buffer in bytes */
	IMG_UINT32				ui32SBufferStride;/*!< Stride of Stencil buffer in bytes */
#endif

#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH) && defined(SGX_FEATURE_COMPLEX_GEOMETRY_REV_2)
	/* VDM context switching variable */
	IMG_UINT32				ui32MTE1stPhaseComplexPtr;/*!< Complex Geometry MTE 1st Phase Ptr */
#endif

#if defined(SGX_FEATURE_SW_ISP_CONTEXT_SWITCH)
	IMG_UINT32				ui3CurrentMTIdx;/*!< Current MT Index */
#endif

#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	IMG_UINT32				ui32VisTestCount;/*!< Visibility Test Count */
#else
	IMG_DEV_VIRTADDR		sVisTestResultsDevAddr;/*!< Visibility Test Results Device Virtual Address */
#endif
#if defined(SGX_FEATURE_MP)
	IMG_UINT32				ui32VDMPIMStatus;/*!< VDM PIM status */
#endif
	IMG_UINT32				ui32TEState[SGX_FEATURE_MP_CORE_COUNT_TA];/*!<  */

	IMG_DEV_VIRTADDR		sPrevDevAddr;/*!< ptr to Previous SGXMKIF_HWRENDERDETAILS in the same render context */
	IMG_DEV_VIRTADDR		sNextDevAddr;/*!< ptr to Next SGXMKIF_HWRENDERDETAILS in the same render context */

	IMG_UINT32				aui32SpecObject[3];/*!< patch values for special object */
	IMG_UINT32				ui32BGObjDims;/*!< Dimensions for the BGObj */

	IMG_UINT32				ui32NumPixelPartitions;/*!< number of pixel partitions */

	IMG_UINT32				ui32FrameNum;/*!< associated frame number */
	IMG_UINT32				ui32SceneNum;/*!< associated scene number */

	IMG_UINT32				ui32Num3DStatusVals;/*!< number of 3D status values to write on 3d complete */
	CTL_STATUS				sCtl3DStatusInfo[SGX_MAX_3D_STATUS_VALS];/*!< 3D status value ctrl obj array */

	/* source dependency details */
#if defined(SUPPORT_SGX_GENERALISED_SYNCOBJECTS)
	IMG_UINT32					ui32NumTASrcSyncs;/*!< Number of TA SRC syncs objects */
	PVRSRV_DEVICE_SYNC_OBJECT	asTASrcSyncs[SGX_MAX_TA_SRC_SYNCS];/*!< TA Source sync object info array */
	IMG_UINT32					ui32NumTADstSyncs;/*!< Number of TA DST syncs objects */
	PVRSRV_DEVICE_SYNC_OBJECT	asTADstSyncs[SGX_MAX_TA_DST_SYNCS];/*!< TA DST sync object info array */
	IMG_UINT32					ui32Num3DSrcSyncs;/*!< Number of 3D DST syncs objects */
	PVRSRV_DEVICE_SYNC_OBJECT	as3DSrcSyncs[SGX_MAX_3D_SRC_SYNCS];/*!< 3D DST sync object info array */
#else
	IMG_UINT32				ui32NumSrcSyncs;/*!< Number of Src syncs */
	PVRSRV_DEVICE_SYNC_OBJECT	asSrcSyncs[SGX_MAX_SRC_SYNCS];/*!< TA Source sync object info array  */
#endif

} SGXMKIF_HWRENDERDETAILS, *PSGXMKIF_HWRENDERDETAILS;
#else
typedef struct _SGXMKIF_HWRENDERDETAILS_
{
	SGXMKIF_3DREGISTERS		s3DRegs;/*!< 3d registers */
	IMG_DEV_VIRTADDR		sAccessDevAddr;/*!< access lock device virtual address */
	IMG_UINT32				ui32RenderFlags;/*!< render flags */

	IMG_DEV_VIRTADDR		sHWRTDataSetDevAddr;/*!< HW RT data set device virtual address */
	IMG_DEV_VIRTADDR		sHWRTDataDevAddr;/*!< HW RT Data device virtual address */

	IMG_DEV_VIRTADDR		sHWDstSyncListDevAddr;/*!< HW Dst Sync List device virtual address */

	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32TQSyncWriteOpsPendingVal;/*!< TQ Sync write Ops Pending */
	IMG_DEV_VIRTADDR		sTQSyncWriteOpsCompleteDevVAddr;/*!< TQ Sync Write Ops Complete */
	IMG_UINT32				ui32TQSyncReadOpsPendingVal;/*!< TQ Sync Read Ops Pending */
	IMG_DEV_VIRTADDR		sTQSyncReadOpsCompleteDevVAddr;/*!< TQ Sync Read Ops Complete */
	/* TA/3D dependency sync criteria to be updated after render */
	PVRSRV_DEVICE_SYNC_OBJECT	sTA3DDependency;/*!< TA-3D dependency sync object */

#if defined(SGX_FEATURE_RENDER_TARGET_ARRAYS)
	/* KEEP THESE 2 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32NumRTs;/*!< number of render targets */
	IMG_UINT32				ui32NextRTIdx;/*!< Next render target index */

	IMG_DEV_VIRTADDR		sPixEventUpdateDevAddr;/*!<  Pixel event update device virtuak address */
	IMG_DEV_VIRTADDR		sHWPixEventUpdateListDevAddr;/*!< HW Pixel Event update List base device virtual address */
	IMG_DEV_VIRTADDR		sHWBgObjPrimPDSUpdateListDevAddr;/*!< HW background object Primary PDS update List device virtual address */

	IMG_UINT32				ui32ZBufferStride;/*!< Stride of Depth buffer in bytes */
	IMG_UINT32				ui32SBufferStride;/*!< Stride of Stencil buffer in bytes */
#endif

#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH) && defined(SGX_FEATURE_COMPLEX_GEOMETRY_REV_2)
	/* VDM context switching variable */
	IMG_UINT32				ui32MTE1stPhaseComplexPtr;/*!< Complex Geometry MTE 1st Phase Ptr */
#endif

#if defined(SGX_FEATURE_SW_ISP_CONTEXT_SWITCH)
	IMG_UINT32				ui3CurrentMTIdx;/*!< Current MT Index */
#endif

#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)
	IMG_UINT32				ui32VisTestCount;/*!< Visibility Test Count */
#else
	IMG_DEV_VIRTADDR		sVisTestResultsDevAddr;/*!< Visibility Test Results Device Virtual Address */
#endif
#if defined(SGX_FEATURE_MP)
	IMG_UINT32				ui32VDMPIMStatus;/*!< VDM PIM status */
#endif
	IMG_UINT32				ui32TEState[SGX_FEATURE_MP_CORE_COUNT_TA];/*!<  */

	IMG_DEV_VIRTADDR		sPrevDevAddr;/*!< ptr to Previous SGXMKIF_HWRENDERDETAILS in the same render context */
	IMG_DEV_VIRTADDR		sNextDevAddr;/*!< ptr to Next SGXMKIF_HWRENDERDETAILS in the same render context */

	IMG_UINT32				aui32SpecObject[3];/*!< patch values for special object */

	IMG_UINT32				ui32NumPixelPartitions;/*!< number of pixel partitions */

#if defined(DEBUG) || defined(PDUMP) || defined(SUPPORT_SGX_HWPERF)
	IMG_UINT32				ui32FrameNum;/*!< associated frame number */
#endif

	IMG_UINT32				ui32Num3DStatusVals;/*!< number of 3D status values to write on 3d complete */
	CTL_STATUS				sCtl3DStatusInfo[SGX_MAX_3D_STATUS_VALS];/*!< 3D status value ctrl obj array */

	/* source dependency details */
#if defined(SUPPORT_SGX_GENERALISED_SYNCOBJECTS)
	IMG_UINT32					ui32NumTASrcSyncs;/*!< Number of TA SRC syncs objects */
	PVRSRV_DEVICE_SYNC_OBJECT	asTASrcSyncs[SGX_MAX_TA_SRC_SYNCS];/*!< TA Source sync object info array */
	IMG_UINT32					ui32NumTADstSyncs;/*!< Number of TA DST syncs objects */
	PVRSRV_DEVICE_SYNC_OBJECT	asTADstSyncs[SGX_MAX_TA_DST_SYNCS];/*!< TA DST sync object info array */
	IMG_UINT32					ui32Num3DSrcSyncs;/*!< Number of 3D DST syncs objects */
	PVRSRV_DEVICE_SYNC_OBJECT	as3DSrcSyncs[SGX_MAX_3D_SRC_SYNCS];/*!< 3D DST sync object info array */
#else
	IMG_UINT32				ui32NumSrcSyncs;/*!< Number of Src syncs */
	PVRSRV_DEVICE_SYNC_OBJECT	asSrcSyncs[SGX_MAX_SRC_SYNCS];/*!< TA Source sync object info array  */
#endif

} SGXMKIF_HWRENDERDETAILS, *PSGXMKIF_HWRENDERDETAILS;
#endif


/*!
 *****************************************************************************
 * Common HW Context structures
 *****************************************************************************/
typedef struct _SGXMKIF_HWCONTEXT_
{
	IMG_UINT32				ui32Flags;		/*!< HW Context control flags */
	IMG_UINT32				ui32Priority;	/*!< scheduling priority */
	IMG_DEV_PHYADDR			sPDDevPAddr;	/*!< device physical address of context's page directory */
} SGXMKIF_HWCONTEXT;

/*!
 *****************************************************************************
 * Transfer queue structures
 *****************************************************************************/

#if defined(TRANSFER_QUEUE)
/*
 *****************************************************************************
 * Transfer queue structures
 *****************************************************************************/
#define SGXTQ_MAX_UPDATES						SGX_MAX_TRANSFER_UPDATES + 96

#if defined(SGX_FEATURE_2D_HARDWARE)

/*!
	Transfer Queue 2D HW context
*/
typedef struct _SGXMKIF_HW2DCONTEXT_
{
	SGXMKIF_HWCONTEXT		sCommon;/*!< common HW context structure */

	/* Transfer CCB details for this render context */
	IMG_DEV_VIRTADDR		sCCBBaseDevAddr;	/*!< Device virtual address of base of CCB */
	IMG_DEV_VIRTADDR		sCCBCtlDevAddr;		/*!< Device virtual address of CCB read offset */
	IMG_UINT32				ui32Count;			/*!< count of queued Transfer commmand in CCB */
	IMG_UINT32			ui32PID;/*!< process ID */

	IMG_DEV_VIRTADDR		sPrevDevAddr;/*!< ptr to previous HW 2DContext */
	IMG_DEV_VIRTADDR		sNextDevAddr;/*!< ptr to next HW 2DContext  */
} SGXMKIF_HW2DCONTEXT, *PSGXMKIF_HW2DCONTEXT;

/*!
	Transfer Queue 2D Command
*/
typedef struct _SGXMKIF_2DCMD_
{
	IMG_UINT32 	ui32Size;/*!< command size  */
	IMG_UINT32	ui32Flags;/*!< comamnd flags */
	IMG_UINT32	ui32AlphaRegValue;/*!< alpha register value */
	IMG_UINT32	ui32CtrlSizeInDwords;/*!< control stream size in DWORDs */
	IMG_UINT32	aui32CtrlStream[SGX_MAX_2D_BLIT_CMD_SIZE];/*!< 2DHW control stream */
	SGXMKIF_2DCMD_SHARED sShared;/*!< shared 2D command */
} SGXMKIF_2DCMD, *PSGXMKIF_2DCMD;
#endif


/*!
	Transfer Queue HW transfer context
*/
typedef struct _SGXMKIF_HWTRANSFERCONTEXT_
{
	SGXMKIF_HWCONTEXT		sCommon; /*!<  */

	/* Transfer CCB details for this render context */
	IMG_DEV_VIRTADDR		sCCBBaseDevAddr;	/*!< Device virtual address of base of CCB */
	IMG_DEV_VIRTADDR		sCCBCtlDevAddr;		/*!< Device virtual address of CCB read offset */
	IMG_UINT32				ui32Count;			/*!< count of queued Transfer commmand in CCB */

 	PVRSRV_DEVICE_SYNC_OBJECT	asSrcSyncObjectSnapshot[SGX_MAX_SRC_SYNCS];
 	PVRSRV_DEVICE_SYNC_OBJECT	asDstSyncObjectSnapshot[SGX_MAX_DST_SYNCS];
#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH) && defined(SGX_FEATURE_FAST_RENDER_CONTEXT_SWITCH)
	IMG_DEV_VIRTADDR		asPDSStateBaseDevAddr[SGX_FEATURE_MP_CORE_COUNT_3D][SGX_FEATURE_NUM_PDS_PIPES];
			/*!< ISP context switch PDS state device virtual address */
	#if defined(SGX_FEATURE_MP)
	IMG_UINT32				ui32ISPRestart[SGX_FEATURE_MP_CORE_COUNT_3D];/*!< per core ISP restart */
	IMG_UINT32				ui32ISP2CtxResume[SGX_FEATURE_MP_CORE_COUNT_3D][8];/*!< per core ISP Context Resume state */
	#else
	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32NextRgnBase;/*!< next region */
	IMG_UINT32				ui32ISPRestart;/*!< ISP restart */
	IMG_UINT32				ui32ISP2CtxResume2;/*!< ISP Context resume data */
	IMG_UINT32				ui32ISP2CtxResume3;/*!< ISP Context resume data */
	#endif
#endif
	IMG_UINT32			ui32PID;/*!< process ID */

	IMG_DEV_VIRTADDR		sPrevDevAddr;/*!< ptr to previous HW transfer context */
	IMG_DEV_VIRTADDR		sNextDevAddr;/*!< ptr to next HW transfer context */
} SGXMKIF_HWTRANSFERCONTEXT, *PSGXMKIF_HWTRANSFERCONTEXT;

typedef struct _SGXMKIF_MEMUPDATE_
{
	IMG_DEV_VIRTADDR		sUpdateAddr;	/*!< Update device virtuak Address */
	IMG_UINT32				ui32UpdateVal;			/*!< update Value */
} SGXMKIF_MEMUPDATE;

/*!
	Transfer Queue Transfer command
*/
typedef struct _SGXMKIF_TRANSFERCMD_
{
	/* Note: keep this aligned to at least 64 byte boundary */
	struct
	{
		IMG_UINT32			ui32ISPBgObjTag;/*!< ISP background Object tag register value */
		IMG_UINT32			ui32ISPBgObj;/*!< ISP background Object control value */
		IMG_UINT32			ui32ISPBgObjDepth;/*!< ISP background Object Depth register value */
		IMG_UINT32			ui32ISPRender;/*!< ISP render register value */
		IMG_UINT32			ui32ISPRgnBase;/*!< ISP region header register value */
		IMG_UINT32			ui32ISPIPFMisc;/*!< ISP IPF Misc register value */
		IMG_UINT32			ui32Bif3DReqBase;/*!< 3D request base register value */
		IMG_UINT32			ui323DAAMode;/*!< 3D AA mode register value */
		IMG_UINT32			ui32ISPMultiSampCtl;/*!< ISP multi-sampling control register value */
		IMG_UINT32			ui32EDMPixelPDSExec;/*!< EDM Pixel PDS Exec register value */
		IMG_UINT32			ui32EDMPixelPDSData;/*!< EDM Pixel PDS Data register value */
		IMG_UINT32			ui32EDMPixelPDSInfo;/*!< EDM Pixel PDS Info register value */
		IMG_UINT32			ui32ISPRenderBox1;/*!< ISP render box1 register value */
		IMG_UINT32			ui32ISPRenderBox2;/*!< ISP render box2 register value */
		IMG_UINT32			ui32PixelBE;/*!< Pixel BE register value */
#if defined(EUR_CR_4Kx4K_RENDER)
		IMG_UINT32			ui324KRender;/*!< 4k x 4k render control register value */
#endif
#if !defined(SGX_FEATURE_PIXEL_PDSADDR_FULL_RANGE)
		IMG_UINT32			ui32PDSExecBase;/*!< PDS Exec Base register value */
#endif
#if defined(SUPPORT_DISPLAYCONTROLLER_TILING)
		IMG_UINT32			ui32BIFTile0Config;/*!< BIF tiling config 0 register value */
#endif
#if defined(EUR_CR_DOUBLE_PIXEL_PARTITIONS)
		IMG_UINT32			ui32DoublePixelPartitions;/*!< double pixel partition register value */
#endif
#if defined(SGX_FEATURE_TAG_YUV_TO_RGB)
		/* YUV Coefficients */
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
		IMG_UINT32			ui32LumaKeyCoeff0;
		IMG_UINT32			ui32LumaKeyCoeff1;
		IMG_UINT32			ui32LumaKeyCoeff2;
#endif

		/* Aligned */
		IMG_UINT32			ui32FIRHFilterTable;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterLeft0;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterRight0;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterExtra0;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterLeft1;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterRight1;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterExtra1;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterLeft2;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterRight2;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterExtra2;/*!< FIRH coefficient register value */

#if defined(SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF)
		IMG_UINT32			ui32FIRHFilterCentre0;/*!< FIRH coefficient register value */
		IMG_UINT32			ui32FIRHFilterCentre1;/*!< FIRH coefficient register value */
#endif

	} sHWRegs;/*!< HW register values */

	IMG_UINT32 	ui32Size;/*!< command size */

	IMG_UINT32		ui32Flags;/*!< command flags */

	SGXMKIF_TRANSFERCMD_SHARED sShared;/*!< shared transfer command */

#if defined(SGX_FEATURE_TAG_YUV_TO_RGB)
	IMG_BOOL	bLoadYUVCoefficients;/*!< load CSC Coefficients boolean */
#endif

#if defined(SGX_FEATURE_TAG_LUMAKEY)
	IMG_BOOL	bLoadLumaKeyCoefficients;/*!< load Luma Key Coefficients boolean */
#endif

	IMG_BOOL	bLoadFIRCoefficients;/*!< load FIRH coefficients boolean */

	IMG_UINT32	ui32NumPixelPartitions;/*!< number of pixel partitions */

	IMG_UINT32	ui32FenceID;/*!< a unique number identifying the blit*/

	IMG_UINT32	ui32NumUpdates;/*!< number of updates to apply */

	/* THIS HAS TO BE THE LAST MEMBER OF THE STRUCTURE*/	
	SGXMKIF_MEMUPDATE		sUpdates[SGXTQ_MAX_UPDATES];/*!< the update or patch list, completed before kicking the cmd*/

} SGXMKIF_TRANSFERCMD, *PSGXMKIF_TRANSFERCMD;
#endif /* defined(TRANSFER_QUEUE) */

/*!
	HW render context. Gives access to all render related data for a given context to allow
	easy switching/scheduling
*/
typedef struct _SGXMKIF_HWRENDERCONTEXT_
{
	SGXMKIF_HWCONTEXT		sCommon;/*!< common HW context structure */

	/* TA CCB details for this render context */
	IMG_DEV_VIRTADDR		sTACCBBaseDevAddr;			/*!< Device virtual address of base of CCB */
	IMG_DEV_VIRTADDR		sTACCBCtlDevAddr;			/*!< Device virtual address of CCB read offset */
	IMG_UINT32				ui32TACount;				/*!< count of queued TA commands in CCB */

	IMG_DEV_VIRTADDR		sHWPBDescDevVAddr;/*!< Associated HW PB Descriptor */

#if defined(SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH)
	IMG_DEV_VIRTADDR		sMasterVDMSnapShotBufferDevAddr;/*!< Master VDM Snapshot Buffer device virtual address */
	#if defined(FIX_HW_BRN_30893) || defined(FIX_HW_BRN_30970)
	IMG_UINT32				ui32MasterVDMCtxStoreStatus;/*!< Master VDM Context store status */
	#endif
#endif
#if defined(SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH)
	IMG_DEV_VIRTADDR		sVDMSnapShotBufferDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< VDM snapshot buffer device virtual address */
	#if defined(FIX_HW_BRN_30893) || defined(FIX_HW_BRN_30970)
	IMG_UINT32				ui32VDMCtxStoreStatus[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< VDM context store status */
	#endif
#endif
#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#if defined(SGX_FEATURE_MTE_STATE_FLUSH)
		#if defined(SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH) && defined(SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH)
	IMG_DEV_VIRTADDR		sMTEStateFlushDevAddr[SGX_FEATURE_MP_CORE_COUNT_TA];/*!< MTE status flush device virtual address */
		#else
	IMG_DEV_VIRTADDR		sMTEStateFlushDevAddr[1];/*!< MTE status flush device virtual address */
		#endif
	#endif
	#if defined(SGX_FEATURE_USE_SA_COUNT_REGISTER)
	IMG_DEV_VIRTADDR		sSABufferDevAddr;/*!< SA buffer device virtual adddress */
		#if defined(SGX_FEATURE_MP)
	IMG_UINT32				ui32SABufferStride;/*!< SA buffer stride in bytes */
		#endif
	#endif
	#if defined(DEBUG)
	IMG_UINT32				ui32NumTAContextStores;
	IMG_UINT32				ui32NumTAContextResumes;
	#endif
#endif
#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH)
	/* KEEP THESE 2 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_DEV_VIRTADDR		asPDSStateBaseDevAddr[SGX_FEATURE_MP_CORE_COUNT_3D][SGX_FEATURE_NUM_PDS_PIPES];/*!< PDS state base device virtual address */
	IMG_DEV_VIRTADDR		sZLSCtxSwitchBaseDevAddr[SGX_FEATURE_MP_CORE_COUNT_3D];/*!< ZLS context switch base device virtual address */

	/* ISP context switching variables */
	#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH_REV_2)
	/* KEEP THIS VARIABLE TOGETHER WITH UI32ISPRESTART ETC FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32NextRgnBase;/*!< Next region base */
	/* KEEP THESE 3 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32				ui32ISPRestart;/*!< ISP restart */
	IMG_UINT32				ui32ISP2CtxResume2;/*!< ISP context resume state */
	IMG_UINT32				ui32ISP2CtxResume3;/*!< ISP context resume state */
	#else
	IMG_UINT32				ui32ISPRestart[SGX_FEATURE_MP_CORE_COUNT_3D];/*!< ISP restart */
	IMG_UINT32				ui32PDSStatus[SGX_FEATURE_MP_CORE_COUNT_3D][SGX_FEATURE_NUM_PDS_PIPES];/*!< PDS status */
		#if defined(SGX_FEATURE_MP)
	IMG_UINT32				ui32ISP2CtxResume[SGX_FEATURE_MP_CORE_COUNT_3D][8];/*!< ISP context Resume */
	IMG_UINT32				ui32DPMFreeStatus[SGX_FEATURE_MP_CORE_COUNT_3D];/*!< DPM Free status */
	IMG_UINT32				ui32DPMDeallocMask;/*!< DPM dealloc Mask */
		#else
	IMG_UINT32				ui32ISP2CtxResume[SGX_FEATURE_MP_CORE_COUNT_3D][2];/*!< ISP context Resume */	
		#endif
	#endif
	#if defined(DEBUG)
	IMG_UINT32				ui32Num3DContextStores;
	IMG_UINT32				ui32Num3DContextResumes;
	#endif
#else
	#if defined(SGX_SCRATCH_PRIM_BLOCK_ENABLE)
	IMG_DEV_VIRTADDR		sScratchPrimBlock;
	/*!<
		When interrupting a render it is possible we need to create a new primitive block header
		in order to restart on the correct triangle. This is due to having to insert an extra DWORD in the primitive block
		but there isn't enough space in the control stream block to just shuffle things around
	*/
	#endif
#endif

	/*
		Head and tail of a linked list of SGXMKIF_HWRENDERDETAILS structures relating to scenes not terminated by the TA,
		i.e. are not ready for full renders yet.
	*/
	IMG_DEV_VIRTADDR		sHWPartialRendersHead;/*!< Head of the list of 'TA in progress' renders for this context */
	IMG_DEV_VIRTADDR		sHWPartialRendersTail;/*!< Tail of the list of 'TA in progress' renders for this context */

	/*
		Head and tail of a linked list of SGXMKIF_HWRENDERDETAILS structures relating to scenes terminated by the TA,
		i.e. are queued and ready for full renders, depending on any synchronisation dependencies (last op values, etc.).
	*/
	IMG_DEV_VIRTADDR		sHWCompleteRendersHead;/*!< Start of the list of 'TA complete' renders for this context */
	IMG_DEV_VIRTADDR		sHWCompleteRendersTail;/*!< End of the list of 'TA complete' renders for this context */

	/*
		There are two next/prev pointers here so we can better maintain lists of contexts with things
		queued for TA and those with things queued for 3D
	*/
	/* KEEP THESE 2 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_DEV_VIRTADDR		sPrevPartialDevAddr;/*!< ptr to previous render context in partial list */
	IMG_DEV_VIRTADDR		sNextPartialDevAddr;/*!< ptr to next render context in partial list */

	IMG_DEV_VIRTADDR		sPrevCompleteDevAddr;/*!< ptr to previous render context in complete list */
	IMG_DEV_VIRTADDR		sNextCompleteDevAddr;/*!< ptr to next render context in complete list */
	IMG_UINT32			ui32PID;/*!< process ID */
} SGXMKIF_HWRENDERCONTEXT, *PSGXMKIF_HWRENDERCONTEXT;

#define		SGXMKIF_HWCFLAGS_NEWCONTEXT			0x00000001
#define 	SGXMKIF_HWCFLAGS_DUMMYTRANSFER		0x00000002
#define 	SGXMKIF_HWCFLAGS_DUMMY2D			0x00000004
#define		SGXMKIF_HWCFLAGS_SUSPEND			0x00000010
#define		SGXMKIF_HWCFLAGS_PERCONTEXTPB			0x00000020
#if defined(__psp2__)
#define		SGXMKIF_HWCFLAGS_PERCONTEXT_SYNC_INFO	0x00000040
#endif
/* Defines relating to the per-context CCBs */
#define SGX_CCB_SIZE		64*1024
#define SGX_CCB_ALLOCGRAN	64


/******************************************************************************
 kernel/client functions:
******************************************************************************/
/* add APIs as required */
#define 	PVRSRV_SGX_MAX_FLUSHED_TASKS	(3*256)		/*!< Maximum number of tasks is related to tile size */

#if defined(FIX_HW_BRN_23055)
	/* The amount required is based on (in pages):
		((MaxRTSize / 8960) + 2(DPM) + 2(MTE)) */
#define 	BRN23055_BUFFER_PAGE_SIZE 	(473)
#endif

#if 1 // SPM_PAGE_INJECTION
	#if defined(SGX_FEATURE_MP)
#define		SPM_DL_RESERVE_PAGES			(32)
	#else
		#if defined(SGX545)
#define 	SPM_DL_RESERVE_PAGES			(32)		
		#else
#define 	SPM_DL_RESERVE_PAGES			(2)
		#endif
	#endif
#define 	SPM_DL_RESERVE_SIZE				(SPM_DL_RESERVE_PAGES * EURASIA_PARAM_MANAGE_GRAN)
#endif

/* Minimum PB size supported by SGX and Services */

#define		SGX_MIN_PBSIZE					(64*EURASIA_PARAM_MANAGE_GRAN)

#if defined(FORCE_ENABLE_GROW_SHRINK) && defined(SUPPORT_PERCONTEXT_PB)
#define 	SGXPB_GROW_MIN_BLOCK_SIZE		(512 * 1024)
#define		SGXPB_GROW_SHRINK_NUM_BLOCKS	(100)
#define		SGXPB_SHRINK_TEST_MULTIPLIER	(1.5)
#define		SGXPB_SHRINK_MIN_FRAMES			(60)
#endif

#endif /*  __SGX_MKIF_CLIENT_H__ */

/******************************************************************************
 End of file (sgx_mkif_client.h)
******************************************************************************/


