/*!****************************************************************************
@File           sgx_bridge_u.h

@Title          SGX Bridge Functionality

@Author         Imagination Technologies

@Date           3/12/2007

@Copyright      Copyright 2007 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either material
                or conceptual may be copied or distributed, transmitted,
                transcribed, stored in a retrieval system or translated into
                any human or computer language in any form by any means,
                electronic, mechanical, manual or other-wise, or disclosed
                to third parties without the express written permission of
                Imagination Technologies Limited, Home Park Estate,
                Kings Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform       Generic

@Description    Header for the SGX Bridge code

Modifications :-
$Log: sgx_bridge_um.h $
******************************************************************************/

#ifndef __SGX_BRIDGE_UM_H__
#define __SGX_BRIDGE_UM_H__

#if defined (__cplusplus)
extern "C" {
#endif

/*!
 * *****************************************************************************
 * @brief Performs a kernel kick
 * 
 * @param psDevData  
 * @param psCCBKick  
 *
 * @return PVRSRV_ERROR
 ********************************************************************************/

IMG_IMPORT PVRSRV_ERROR SGXDoKick(PVRSRV_DEV_DATA *psDevData,
									SGX_CCB_KICK *psCCBKick);

#if defined(TRANSFER_QUEUE)
IMG_INTERNAL PVRSRV_ERROR SGXSubmitTransferBridge(const PVRSRV_DEV_DATA *psDevData, PVRSRV_TRANSFER_SGX_KICK *psKick);
#if defined(SGX_FEATURE_2D_HARDWARE)
IMG_INTERNAL PVRSRV_ERROR SGXSubmit2D(const PVRSRV_DEV_DATA *psDevData, PVRSRV_2D_SGX_KICK *psKick);
#endif
#endif

/*!
 * *****************************************************************************
 * @brief Looks for a parameter buffer description that corresponds to
 *        a buffer of size ui32TotalPBSize, optionally taking the lock
 *        needed for SharedPBCreation on failure.
 *
 *        Note if a PB Desc is found then its internal reference counter
 *        is automatically incremented. It is your responsability to call
 *        SGXUnrefSharedPBDesc to decrement this reference and free associated
 *        userspace resources when you are done.
 *		
 *	  This function returns an array of meminfo handles that are integral
 *	  to the shared PB desc (Those supplied via SGXAddSharedPBDesc). This
 *	  array is allocated via PVRSRVAllocUserModeMem and it is the callers
 *	  responsability to free this memory by calling PVRSRVFreeUserModeMem
 *	  when they have finished with the handles. (I.e. probably after
 *	  mapping them to userspace)
 * 
 * 	  If bLockOnFailure is set, and a suitable shared PB isn't found,
 * 	  an internal flag is set, allowing this process to create a
 * 	  shared PB.  Any other process calling this function with
 * 	  bLockOnFailure set, will receive the return code
 * 	  PVRSRV_ERROR_PROCESSING_BLOCKED, indicating that it needs
 * 	  to retry the function call.  The internal flag is cleared
 * 	  when this process creates a shared PB.
 *
 * @param[in] psDevData  
 * @param[in] bLockOnFailure
 * @param[in] ui32TotalPBSize  
 * @param[out] phSharedPBDesc
 * @param[out] phSharedPBDescKernelMemInfoHandle
 * @param[out] phHWPBDescKernelMemInfoHandle
 * @param[out] pphSharedPBDescSubKernelMemInfoHandles  
 * @param[out] pui32SharedPBDescSubKernelMemInfoHandlesCount
 *
 * @return PVRSRV_ERROR
 ********************************************************************************/
IMG_INTERNAL PVRSRV_ERROR
SGXFindSharedPBDesc(const PVRSRV_DEV_DATA *psDevData,
					IMG_BOOL bLockOnFailure,
					IMG_UINT32 ui32TotalPBSize,
#if defined (SUPPORT_SID_INTERFACE)
					IMG_SID    *phSharedPBDesc,
					IMG_SID    *phSharedPBDescKernelMemInfoHandle,
					IMG_SID    *phHWPBDescKernelMemInfoHandle,
					IMG_SID    *phBlockKernelMemInfoHandle,
					IMG_SID    *phHWBlockKernelMemInfoHandle,
					IMG_SID   **pphSharedPBDescSubKernelMemInfoHandles,
#else
					IMG_HANDLE *phSharedPBDesc,
					IMG_HANDLE *phSharedPBDescKernelMemInfoHandle,
					IMG_HANDLE *phHWPBDescKernelMemInfoHandle,
					IMG_HANDLE *phBlockKernelMemInfoHandle,
					IMG_HANDLE *phHWBlockKernelMemInfoHandle,
					IMG_HANDLE **pphSharedPBDescSubKernelMemInfoHandles,
#endif
					IMG_UINT32 *pui32SharedPBDescSubKernelMemInfoHandlesCount);

/*!
 * *****************************************************************************
 * @brief Decrements the reference counter and frees all kernel resources
 *        associated with a SharedPBDesc.
 *
 *        Note: It does not free userspace resources such as client meminfos
 *        associated with the PB Desc. It is your responsible to free any
 *        userspace resources  including mappings _before_ calling
 *        SGXUnrefSharedPBDesc.
 * 
 * @param psDevData  
 * @param hSharedPBDescKernelMemInfoHandle  
 *
 * @return PVRSRV_ERROR
 ********************************************************************************/
IMG_INTERNAL PVRSRV_ERROR
SGXUnrefSharedPBDesc(const PVRSRV_DEV_DATA *psDevData,
#if defined (SUPPORT_SID_INTERFACE)
					 IMG_SID hSharedPBDescKernelMemInfoHandle);
#else
					 IMG_HANDLE hSharedPBDescKernelMemInfoHandle);
#endif

/*!
 * *****************************************************************************
 * @brief Links a new SharedPBDesc into a kernel managed list that can
 *        then be queried by other clients.
 *
 *        As a side affect this function also dissociates the SharedPBDesc
 *        from the calling process so that the memory won't be freed if the
 *        process dies/exits. (The kernel assumes responsability over the
 *        memory at the same time)
 *
 *        As well as the psSharedPBDescKernelMemInfoHandle you must also pass
 *        a complete list of other meminfos that are integral to the
 *        shared PB description. (Although the kernel doesn't have direct
 *        access to the shared PB desc it still needs to be able to
 *        clean up all the associated resources when it is no longer
 *        in use.)
 *
 *        If the dissociation fails then all the memory associated with
 *	  the hSharedPBDescKernelMemInfoHandle and all entries in phSubKernelMemInfos
 *	  will be freed by kernel services! Because of this, you are
 *	  responsible for freeing the corresponding client meminfos _before_
 *	  calling SGXAddSharedPBDesc.
 * 
 * 	  This function will return an error unless a succesful call to
 * 	  SGXFindSharedPBDesc, with bLockOnFailure set, has been made.
 *
 * @param psDevData  
 * @param ui32TotalPBSize  The size of the associated parameter buffer
 * @param hSharedPBDescKernelMemInfoHandle  
 * @param hHWPBDescKernelMemInfoHandle  
 * @param hBlockKernelMemInfoHandle  
 * @param hSharedPBDesc  
 * @param phSubKernelMemInfos  A list of other meminfos integral to the shared
 *                             PB description.
 * @param ui32SubKernelMemInfosCount  The number of entires in phSubKernelMemInfos
 * @param sHWPBDescDevVAddr The device virtual address of the HWPBDesc
 *
 * @return PVRSRV_ERROR
 ********************************************************************************/
IMG_INTERNAL PVRSRV_ERROR
SGXAddSharedPBDesc(const PVRSRV_DEV_DATA *psDevData,
				   IMG_UINT32 ui32TotalPBSize,
#if defined (SUPPORT_SID_INTERFACE)
				   IMG_SID    hSharedPBDescKernelMemInfoHandle,
				   IMG_SID    hHWPBDescKernelMemInfoHandle,
				   IMG_SID    hBlockKernelMemInfoHandle,
				   IMG_SID    hHWBlockKernelMemInfoHandle,
				   IMG_SID    *phSharedPBDesc,
				   IMG_SID    *phSubKernelMemInfos,
#else
				   IMG_HANDLE hSharedPBDescKernelMemInfoHandle,
				   IMG_HANDLE hHWPBDescKernelMemInfoHandle,
				   IMG_HANDLE hBlockKernelMemInfoHandle,
				   IMG_HANDLE hHWBlockKernelMemInfoHandle,
				   IMG_HANDLE *phSharedPBDesc,
				   IMG_HANDLE *phSubKernelMemInfos,
#endif
				   IMG_UINT32 ui32SubKernelMemInfosCount,
				   IMG_DEV_VIRTADDR sHWPBDescDevVAddr);

#ifdef	PDUMP
IMG_IMPORT IMG_VOID	IMG_CALLCONV 
PVRSRVPDumpBufferArray(const PVRSRV_CONNECTION *psConnection,
		SGX_KICKTA_DUMP_BUFFER *psBufferArray,
		IMG_UINT32 ui32BufferArrayLength,
		IMG_BOOL bDumpPolls);

IMG_INTERNAL IMG_VOID PVRSRVPDump3DSignatureRegisters(const PVRSRV_DEV_DATA *psDevData,
#if defined (SUPPORT_SID_INTERFACE)
														IMG_SID    hDevMemContext,
#else
														IMG_HANDLE hDevMemContext,
#endif
														IMG_UINT32 ui32DumpFrameNum,
														IMG_BOOL   bLastFrame,
														IMG_UINT32 *pui32Registers,
														IMG_UINT32 ui32NumRegisters);

IMG_INTERNAL IMG_VOID PVRSRVPDumpPerformanceCounterRegisters(const PVRSRV_DEV_DATA *psDevData,
														IMG_UINT32 ui32DumpFrameNum,
														IMG_BOOL bLastFrame,
														IMG_UINT32 *pui32Registers,
														IMG_UINT32 ui32NumRegisters);

IMG_INTERNAL IMG_VOID PVRSRVPDumpTASignatureRegisters(const PVRSRV_DEV_DATA *psDevData,
														IMG_UINT32 ui32DumpFrameNum,
														IMG_UINT32 ui32TAKickCount,
														IMG_BOOL bLastFrame,
														IMG_UINT32 *pui32Registers,
														IMG_UINT32 ui32NumRegisters);

IMG_INTERNAL IMG_VOID PVRSRVPDumpHWPerfCB(const PVRSRV_DEV_DATA	*psDevData,
#if defined (SUPPORT_SID_INTERFACE)
										  IMG_SID			hDevMemContext,
#else
										  IMG_HANDLE hDevMemContext,
#endif
										  IMG_CHAR			*pszFileName,
										  IMG_UINT32		ui32FileOffset,
										  IMG_UINT32		ui32PDumpFlags);

IMG_INTERNAL IMG_VOID PVRSRVPDumpSaveMem(const PVRSRV_DEV_DATA	*psDevData,
										 IMG_CHAR			*pszFileName,
										 IMG_UINT32			ui32FileOffset,
										 IMG_DEV_VIRTADDR 	sDevVAddr,
										 IMG_UINT32			ui32Size,
#if defined (SUPPORT_SID_INTERFACE)
										 IMG_SID			hDevMemContext,
#else
										 IMG_HANDLE			hDevMemContext,
#endif
										 IMG_UINT32			ui32PDumpFlags);
#endif

#if defined (SUPPORT_SID_INTERFACE)
IMG_INTERNAL PVRSRV_ERROR SGXRegisterHWRenderContext(
        const PVRSRV_DEV_DATA *psDevData, IMG_SID *phHWRenderContext, 
        IMG_CPU_VIRTADDR *psHWRenderContextCpuVAddr, 
        IMG_UINT32 ui32HWRenderContextSize,
        IMG_UINT32 ui32OffsetToPDDevPAddr,
        IMG_HANDLE hDevMemContext,
        IMG_DEV_VIRTADDR *psHWRenderContextDevVAddrOut);
IMG_INTERNAL PVRSRV_ERROR SGXRegisterHWTransferContext(
        const PVRSRV_DEV_DATA *psDevData, IMG_SID *phHWTransferContext, 
        IMG_CPU_VIRTADDR *psHWRenderContextCpuVAddr, 
        IMG_UINT32 ui32HWRenderContextSize,
        IMG_UINT32 ui32OffsetToPDDevPAddr,
        IMG_HANDLE hDevMemContext,
        IMG_DEV_VIRTADDR *psHWTransferContextDevVAddrOut);
#else
IMG_INTERNAL PVRSRV_ERROR SGXRegisterHWRenderContext(
        const PVRSRV_DEV_DATA *psDevData, IMG_HANDLE *phHWRenderContext, 
        IMG_CPU_VIRTADDR *psHWRenderContextCpuVAddr,
        IMG_UINT32 ui32RenderContextSize,
        IMG_UINT32 ui32OffsetToPDDevPAddr,
        IMG_HANDLE hDevMemContext,
        IMG_DEV_VIRTADDR *psHWRenderContextDevVAddrOut);
IMG_INTERNAL PVRSRV_ERROR SGXRegisterHWTransferContext(
        const PVRSRV_DEV_DATA *psDevData, IMG_HANDLE *phHWTransferContext, 
        IMG_CPU_VIRTADDR *psHWRenderContextCpuVAddr,
        IMG_UINT32 ui32RenderContextSize,
        IMG_UINT32 ui32OffsetToPDDevPAddr,
        IMG_HANDLE hDevMemContext,
        IMG_DEV_VIRTADDR *psHWTransferContextDevVAddrOut);
#endif
#if defined(SGX_FEATURE_2D_HARDWARE)
#if defined (SUPPORT_SID_INTERFACE)
IMG_INTERNAL PVRSRV_ERROR SGXRegisterHW2DContext(
        const PVRSRV_DEV_DATA *psDevData, IMG_SID *phHW2DContext, 
        IMG_CPU_VIRTADDR *psHWRenderContextCpuVAddr,
        IMG_UINT32 ui32RenderContextSize,
        IMG_UINT32 ui32OffsetToPDDevPAddr,
        IMG_HANDLE hDevMemContext,
        IMG_DEV_VIRTADDR *psHW2DContextDevVAddrOut);
#else
IMG_INTERNAL PVRSRV_ERROR SGXRegisterHW2DContext(
        const PVRSRV_DEV_DATA *psDevData, IMG_HANDLE *phHW2DContext, 
        IMG_CPU_VIRTADDR *psHWRenderContextCpuVAddr, 
        IMG_UINT32 ui32RenderContextSize,
        IMG_UINT32 ui32OffsetToPDDevPAddr,
        IMG_HANDLE hDevMemContext,
        IMG_DEV_VIRTADDR *psHW2DContextDevVAddrOut);
#endif
#endif

IMG_INTERNAL PVRSRV_ERROR SGXFlushHWRenderTarget(const PVRSRV_DEV_DATA *psDevData, PVRSRV_CLIENT_MEM_INFO * psHWRTDataSetMemInfo);

#if defined (SUPPORT_SID_INTERFACE)
IMG_INTERNAL PVRSRV_ERROR SGXUnregisterHWRenderContext(const PVRSRV_DEV_DATA *psDevData, IMG_SID hHWRenderContext, IMG_BOOL bForceCleanup);
IMG_INTERNAL PVRSRV_ERROR SGXUnregisterHWTransferContext(const PVRSRV_DEV_DATA *psDevData, IMG_SID hHWTransferContext, IMG_BOOL bForceCleanup);
#else
IMG_INTERNAL PVRSRV_ERROR SGXUnregisterHWRenderContext(const PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hHWRenderContext, IMG_BOOL bForceCleanup);
IMG_INTERNAL PVRSRV_ERROR SGXUnregisterHWTransferContext(const PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hHWTransferContext, IMG_BOOL bForceCleanup);
#endif
#if defined(SGX_FEATURE_2D_HARDWARE)
#if defined (SUPPORT_SID_INTERFACE)
IMG_INTERNAL PVRSRV_ERROR SGXUnregisterHW2DContext(const PVRSRV_DEV_DATA *psDevData, IMG_SID hHW2DContext, IMG_BOOL bForceCleanup);
#else
IMG_INTERNAL PVRSRV_ERROR SGXUnregisterHW2DContext(const PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hHW2DContext, IMG_BOOL bForceCleanup);
#endif
#endif

#if defined (SUPPORT_SID_INTERFACE)
IMG_INTERNAL PVRSRV_ERROR SGXSetRenderContextPriority(const PVRSRV_DEV_DATA *psDevData, 
                                                 IMG_SID hHWRenderContext, 
                                                 IMG_UINT32 ui32Priority,
                                                 IMG_UINT32 ui32OffsetOfPriorityField);

IMG_INTERNAL PVRSRV_ERROR SGXSetTransferContextPriority(const PVRSRV_DEV_DATA *psDevData, 
                                                 IMG_SID hHWTransferContext, 
                                                 IMG_UINT32 ui32Priority,
                                                 IMG_UINT32 ui32OffsetOfPriorityField);
#else
IMG_INTERNAL PVRSRV_ERROR SGXSetRenderContextPriority(const PVRSRV_DEV_DATA *psDevData, 
                                                 IMG_HANDLE hHWRenderContext, 
                                                 IMG_UINT32 ui32Priority,
                                                 IMG_UINT32 ui32OffsetOfPriorityField);

IMG_INTERNAL PVRSRV_ERROR SGXSetTransferContextPriority(const PVRSRV_DEV_DATA *psDevData, 
                                                 IMG_HANDLE hHWTransferContext, 
                                                 IMG_UINT32 ui32Priority,
                                                 IMG_UINT32 ui32OffsetOfPriorityField);
#endif

#if defined (__cplusplus)
}
#endif

#endif /* __SGX_BRIDGE_UM_H__ */

