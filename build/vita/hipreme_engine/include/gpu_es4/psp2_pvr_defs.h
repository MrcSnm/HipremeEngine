#ifndef PSP2_PVR_DEFS_H
#define PSP2_PVR_DEFS_H

// Contains platform-specific definitions for PSP2

#include <kernel.h>

#include "eurasia/include4/services.h"
#include "eurasia/include4/sgxapi.h"

#define PSP2_SWAPCHAIN_MAX_PENDING_COUNT 1
#define PSP2_SWAPCHAIN_MAX_BUFFER_NUM 4
#define PSP2_SWAPCHAIN_MIN_INTERVAL 0
#define PSP2_SWAPCHAIN_MAX_INTERVAL 6

#define PVRSRV_PSP2_GENERIC_MEMORY_ATTRIB (PVRSRV_MEM_READ \
										  | PVRSRV_MEM_WRITE \
										  | PVRSRV_HAP_NO_GPU_VIRTUAL_ON_ALLOC \
										  | PVRSRV_MEM_CACHE_CONSISTENT \
										  | PVRSRV_MEM_NO_SYNCOBJ)

#define PVRSRV_PSP2_GENERIC_MEMORY_ATTRIB_NC (PVRSRV_MEM_READ \
										  | PVRSRV_MEM_WRITE \
										  | PVRSRV_HAP_NO_GPU_VIRTUAL_ON_ALLOC \
										  | PVRSRV_MEM_NO_SYNCOBJ)

#define PVRSRV_PSP2_GENERIC_MEMORY_ATTRIB_RDONLY_NC (PVRSRV_MEM_READ \
										  | PVRSRV_HAP_NO_GPU_VIRTUAL_ON_ALLOC \
										  | PVRSRV_MEM_NO_SYNCOBJ)

#define PVRSRV_PSP2_COMPULSORY_ALLOC_FLAGS (PVRSRV_MEM_NO_SYNCOBJ | PVRSRV_HAP_NO_GPU_VIRTUAL_ON_ALLOC)

typedef struct _PVRSRV_OP_CLIENT_SYNC_INFO_
{
	PVRSRV_CLIENT_SYNC_INFO *psInfoOld;
	PVRSRV_CLIENT_SYNC_INFO *psInfoNew;
} PVRSRV_OP_CLIENT_SYNC_INFO;

typedef struct _PVRSRV_MEM_INFO_
{
	IMG_PVOID pBase;
	IMG_UINT32 ui32Size;
	IMG_UINT32 ui32Flags;
} PVRSRV_MEM_INFO;

typedef struct _SGX_RTINFO_
{
	IMG_UINT32 ui32NumPixelsX;
	IMG_UINT32 ui32NumPixelsY;
	IMG_UINT16 ui16MSAASamplesInX;
	IMG_UINT16 ui16MSAASamplesInY;

	IMG_BOOL   bMacrotileSync;
} SGX_RTINFO;

typedef struct _SGX_RTINFO_EXT_
{
	IMG_UINT32       ui32NumPixelsInX;
	IMG_UINT32       ui32NumPixelsInY;
	IMG_UINT16       ui16MSAASamplesInX;
	IMG_UINT16       ui16MSAASamplesInY;

	IMG_UINT32       ui32BGObjUCoord;

	IMG_DEV_VIRTADDR sSpecialObjDevVAddr;
	IMG_UINT32       ui32Unknown;

	IMG_UINT32       ui32BGObjTag;
	IMG_UINT32       ui32NumRTData;
	IMG_UINT32       ui32MTEMultiSampleCtl;
	IMG_PVOID        pvRTDataSet;

	IMG_UINT32       ui32MTileNumber;
	IMG_UINT32       ui32MTileX1;
	IMG_UINT32       ui32MTileX2;
	IMG_UINT32       ui32MTileX3;
	IMG_UINT32       ui32MTileY1;
	IMG_UINT32       ui32MTileY2;
	IMG_UINT32       ui32MTileY3;
	IMG_UINT32       ui32MTileStride;

	IMG_UINT32       ui32Flags;
} SGX_RTINFO_EXT;

IMG_INT PVRSRVWaitSyncOp(IMG_SID hKernelSyncInfoModObj, IMG_UINT32 *pui32Timeout);

IMG_INT PVRSRV_BridgeDispatchKM(IMG_UINT32 cmd, IMG_PVOID psBridgePackageKM);

PVRSRV_ERROR PVRSRVRegisterMemBlock(PVRSRV_DEV_DATA *psDevData, SceUID memblockUid, IMG_SID *phMemBlockProcRef, IMG_BOOL bUnmapFromCPU);

PVRSRV_ERROR PVRSRVUnregisterMemBlock(PVRSRV_DEV_DATA *psDevData, SceUID memblockUid);

PVRSRV_ERROR PVRSRVMapMemoryToGpu(
	PVRSRV_DEV_DATA *psDevData,
	IMG_SID hDevMemContext,
	IMG_SID hHeapHandle,
	IMG_UINT32 ui32Size,
	IMG_UINT32 ui32HeapSegmentSize,
	IMG_PVOID pMemBase,
	IMG_UINT32 ui32Flags,
	IMG_DEV_VIRTADDR *psMappedDevVAddr);

PVRSRV_ERROR PVRSRVUnmapMemoryFromGpu(
	PVRSRV_DEV_DATA *psDevData,
	IMG_PVOID pMemBase,
	IMG_SID hHeapHandle,
	IMG_BOOL bSync);

PVRSRV_ERROR PVRSRVCheckMappedMemory(
	PVRSRV_DEV_DATA *psDevData,
	IMG_SID hDevMemContext,
	IMG_PVOID pMemBase,
	IMG_UINT32 ui32Size,
	IMG_UINT32 ui32Flags);

PVRSRV_ERROR PVRSRVGetMemInfo(PVRSRV_DEV_DATA *psDevData, IMG_PVOID pMemBase, PVRSRV_MEM_INFO *psMemInfo);

PVRSRV_ERROR IMG_CALLCONV SGXTransferControlStream(
	IMG_UINT32 *pui32CtrlStream,
	IMG_UINT32 ui32CtrlSizeInDwords,
	PVRSRV_DEV_DATA *psDevData, 
	IMG_HANDLE hTransferContext, 
	PVRSRV_CLIENT_SYNC_INFO *psSyncInfo,
	IMG_BOOL bTASync, 
	IMG_BOOL b3DSync, 
	SGX_STATUS_UPDATE *psStatusUpdate);

PVRSRV_ERROR IMG_CALLCONV SGXGetRenderTargetInfo(PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hRTDataSet, SGX_RTINFO *psRTInfo);

PVRSRV_ERROR IMG_CALLCONV SGXGetRenderTargetInfoExt(PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hRTDataSet, SGX_RTINFO_EXT *psRTInfoExt);

PVRSRV_ERROR IMG_CALLCONV SGXGetRenderTargetDriverMemBlock(PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hRTDataSet, IMG_INT32 *pi32DriverMemBlockUID, IMG_BOOL *pbInternalUID);

PVRSRV_ERROR IMG_CALLCONV SGXGetRenderTargetMemSize(SGX_ADDRENDTARG *psAddRTInfo, IMG_UINT32 *pui32MemSize);

PVRSRV_ERROR IMG_CALLCONV SGXWaitTransfer(PVRSRV_DEV_DATA *psDevData, IMG_HANDLE hTransferContext);

int sceGpuSignalWait(void *unkTLS, unsigned int timeout);


#endif