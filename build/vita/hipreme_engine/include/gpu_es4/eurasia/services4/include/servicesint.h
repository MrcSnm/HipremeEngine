/*!****************************************************************************
@File			servicesint.h

@Title			Services Internal Header

@Author			Imagination Technologies

@date   		01/11/2004

@Copyright     	Copyright 2003-2004 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either
                material or conceptual may be copied or distributed,
                transmitted, transcribed, stored in a retrieval system
                or translated into any human or computer language in any
                form by any means, electronic, mechanical, manual or
                other-wise, or disclosed to third parties without the
                express written permission of Imagination Technologies
                Limited, Unit 8, HomePark Industrial Estate,
                King's Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform		cross platform / environment

@Description	services internal details

@DoxygenVer

******************************************************************************/

/******************************************************************************
Modifications :-

$Log: servicesint.h $
*****************************************************************************/

#if !defined (__SERVICESINT_H__)
#define __SERVICESINT_H__

#if defined (__cplusplus)
extern "C" {
#endif

#include "services.h"
#include "sysinfo.h"

#define HWREC_DEFAULT_TIMEOUT	(500)

#define DRIVERNAME_MAXLENGTH	(100)

/*
	helper macros:
*/
#define	ALIGNSIZE(size, alignshift)	(((size) + ((1UL << (alignshift))-1)) & ~((1UL << (alignshift))-1))

#ifndef MAX
#define MAX(a,b) 					(((a) > (b)) ? (a) : (b))
#endif
#ifndef MIN
#define MIN(a,b) 					(((a) < (b)) ? (a) : (b))
#endif

typedef enum _PVRSRV_MEMTYPE_
{
	PVRSRV_MEMTYPE_UNKNOWN		= 0,
	PVRSRV_MEMTYPE_DEVICE		= 1,
	PVRSRV_MEMTYPE_DEVICECLASS	= 2,
	PVRSRV_MEMTYPE_WRAPPED		= 3,
	PVRSRV_MEMTYPE_MAPPED		= 4,
} PVRSRV_MEMTYPE;

/*
	Kernel Memory Information structure
*/
typedef struct _PVRSRV_KERNEL_MEM_INFO_
{
	/* Kernel Mode CPU Virtual address */
	IMG_PVOID				pvLinAddrKM;

	/* Device Virtual Address */
	IMG_DEV_VIRTADDR		sDevVAddr;

	/* allocation flags */
	IMG_UINT32				ui32Flags;

	/* Size of the allocated buffer in bytes */
	IMG_SIZE_T				uAllocSize;

	/* Internal implementation details. Do not use outside services code. */
	PVRSRV_MEMBLK			sMemBlk;

	/* Address of the backup buffer used in a save/restore of the surface */
	IMG_PVOID				pvSysBackupBuffer;

	/* refcount for allocation, wrapping and mapping */
	IMG_UINT32				ui32RefCount;

	/* Set when free call ocured and a mapping was still open */
	IMG_BOOL				bPendingFree;


#if defined(SUPPORT_MEMINFO_IDS)
	#if !defined(USE_CODE)
	/* Globally unique "stamp" for allocation (not re-used until wrap) */
	IMG_UINT64				ui64Stamp;
	#else /* !defined(USE_CODE) */
	IMG_UINT32				dummy1;
	IMG_UINT32				dummy2;
	#endif /* !defined(USE_CODE) */
#endif /* defined(SUPPORT_MEMINFO_IDS) */

	/* ptr to associated kernel sync info - NULL if no sync */
	struct _PVRSRV_KERNEL_SYNC_INFO_	*psKernelSyncInfo;

	PVRSRV_MEMTYPE				memType;

    /* Device Virtual Address Offsets for the YUV MM planes */
	IMG_UINT32 planeOffsets[PVRSRV_MAX_NUMBER_OF_MM_BUFFER_PLANES];

    /*
      To activate the "share mem workaround", add PVRSRV_MEM_XPROC to
      the flags for the allocation.  This will cause the "map" API to
      call use Alloc Device Mem but will share the underlying memory
      block and sync data.  Note that this is a workaround for a bug
      exposed by a specific use-case on a particular platform.  Do not
      use this functionality generally.
    */
	struct {
        /* Record whether the workaround is active for this
           allocation.  The rest of the fields in this struct are
           undefined unless this is true */
		IMG_BOOL bInUse;

        /* Store the device cookie handle from the original
           allocation, as it is not present on the "Map" API. */
		IMG_HANDLE hDevCookieInt;

        /* This is an index into a static array which store
           information about the underlying allocation */
		IMG_UINT32 ui32ShareIndex;

        /* Original arguments as supplied to original
           "PVRSRVAllocDeviceMem" call, such that a new call to this
           function can be later constructed */
		IMG_UINT32 ui32OrigReqAttribs;
		IMG_UINT32 ui32OrigReqSize;
		IMG_UINT32 ui32OrigReqAlignment;
	} sShareMemWorkaround;
} PVRSRV_KERNEL_MEM_INFO;


/*
	Kernel Sync Info structure
*/
typedef struct _PVRSRV_KERNEL_SYNC_INFO_
{
	/* kernel sync data */
	PVRSRV_SYNC_DATA		*psSyncData;

	/* Device accessible WriteOp Info */
	IMG_DEV_VIRTADDR		sWriteOpsCompleteDevVAddr;

	/* Device accessible ReadOp Info */
	IMG_DEV_VIRTADDR		sReadOpsCompleteDevVAddr;

	/* Device accessible ReadOp Info */
	IMG_DEV_VIRTADDR		sReadOps2CompleteDevVAddr;

	/* meminfo for sync data */
	PVRSRV_KERNEL_MEM_INFO	*psSyncDataMemInfoKM;

	/* Reference count for deferring destruction of syncinfo when it is shared */
	/* NB: This is only done for devicemem.c (alloc/map/wrap etc), and
	   not (presently) for deviceclass memory */
	IMG_PVOID              pvRefCount;

	/* Resman cleanup, for those created with explicit API */
	IMG_HANDLE hResItem;

	/* Unique ID of the sync object */
	IMG_UINT32		ui32UID;
} PVRSRV_KERNEL_SYNC_INFO;

/*!
 *****************************************************************************
 *	This is a device addressable version of a pvrsrv_sync_oject
 *	- any hw cmd may have an unlimited number of these
 ****************************************************************************/
#if defined(__psp2__)
typedef struct _PVRSRV_DEVICE_SYNC_OBJECT_
{
	/* KEEP THESE 4 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32			ui32ReadOpsPendingVal;
	IMG_DEV_VIRTADDR	sReadOpsCompleteDevVAddr;
	IMG_UINT32			ui32WriteOpsPendingVal;
	IMG_DEV_VIRTADDR	sWriteOpsCompleteDevVAddr;
} PVRSRV_DEVICE_SYNC_OBJECT;
#else
typedef struct _PVRSRV_DEVICE_SYNC_OBJECT_
{
	/* KEEP THESE 6 VARIABLES TOGETHER FOR UKERNEL BLOCK LOAD */
	IMG_UINT32			ui32ReadOpsPendingVal;
	IMG_DEV_VIRTADDR	sReadOpsCompleteDevVAddr;
	IMG_UINT32			ui32WriteOpsPendingVal;
	IMG_DEV_VIRTADDR	sWriteOpsCompleteDevVAddr;
	IMG_UINT32			ui32ReadOps2PendingVal;
	IMG_DEV_VIRTADDR	sReadOps2CompleteDevVAddr;
} PVRSRV_DEVICE_SYNC_OBJECT;
#endif

/*!
 *****************************************************************************
 *	encapsulates a single sync object
 *	- any cmd may have an unlimited number of these
 ****************************************************************************/
typedef struct _PVRSRV_SYNC_OBJECT
{
	PVRSRV_KERNEL_SYNC_INFO *psKernelSyncInfoKM;
	IMG_UINT32				ui32WriteOpsPending;
	IMG_UINT32				ui32ReadOpsPending;
	IMG_UINT32				ui32ReadOps2Pending;

}PVRSRV_SYNC_OBJECT, *PPVRSRV_SYNC_OBJECT;

/*!
 *****************************************************************************
 * The `one size fits all' generic command.
 ****************************************************************************/
typedef struct _PVRSRV_COMMAND
{
	IMG_SIZE_T			uCmdSize;		/*!< total size of command */
	IMG_UINT32			ui32DevIndex;		/*!< device type - 16bit enum (exported by system) */
	IMG_UINT32			CommandType;		/*!< command type */
	IMG_UINT32			ui32DstSyncCount;	/*!< number of dst sync objects */
	IMG_UINT32			ui32SrcSyncCount;	/*!< number of src sync objects */
	PVRSRV_SYNC_OBJECT	*psDstSync;			/*!< dst sync ptr list, allocated on
                                       			back of this structure, i.e. is resident in Q */
	PVRSRV_SYNC_OBJECT	*psSrcSync;			/*!< src sync ptr list, allocated on
                                         		back of this structure, i.e. is resident in Q */
	IMG_SIZE_T			uDataSize;		/*!< Size of Cmd Data Packet
                                      			- only required in terms of allocating Q space */
	IMG_UINT32			ui32ProcessID;		/*!< Process ID for debugging */
	IMG_VOID			*pvData;			/*!< data to be passed to Cmd Handler function,
                                         		allocated on back of this structure, i.e. is resident in Q */
	PFN_QUEUE_COMMAND_COMPLETE  pfnCommandComplete;	/*!< Command complete callback */
	IMG_HANDLE					hCallbackData;		/*!< Command complete callback data */
}PVRSRV_COMMAND, *PPVRSRV_COMMAND;


/*!
 *****************************************************************************
 * Circular command buffer structure forming the queue of pending commands.
 *
 * Queues are implemented as circular comamnd buffers (CCBs).
 * The buffer is allocated as a specified size, plus the size of the largest supported command.
 * The extra size allows commands to be added without worrying about wrapping around at the end.
 *
 * Commands are added to the CCB by client processes and consumed within
 * kernel mode code running from within  an L/MISR typically.
 *
 * The process of adding a command to a queue is as follows:-
 * 	- A `lock' is acquired to prevent other processes from adding commands to a queue
 * 	- Data representing the command to be executed, along with it's PVRSRV_SYNC_INFO
 * 	  dependencies is written to the buffer representing the queue at the queues
 * 	  current WriteOffset.
 * 	- The PVRSRV_SYNC_INFO that the command depends on are updated to reflect
 * 	  the addition of the new command.
 * 	- The WriteOffset is incremented by the size of the command added.
 * 	- If the WriteOffset now lies beyound the declared buffer size, it is
 * 	  reset to zero.
 * 	- The semaphore is released.
 *
 *****************************************************************************/
typedef struct _PVRSRV_QUEUE_INFO_
{
	IMG_VOID			*pvLinQueueKM;			/*!< Pointer to the command buffer in the kernel's
												 address space */

	IMG_VOID			*pvLinQueueUM;			/*!< Pointer to the command buffer in the user's
												 address space */

	volatile IMG_SIZE_T	ui32ReadOffset;			/*!< Index into the buffer at which commands are being
													 consumed */

	volatile IMG_SIZE_T	ui32WriteOffset;		/*!< Index into the buffer at which commands are being
													 added */

	IMG_UINT32			*pui32KickerAddrKM;		/*!< kicker address in the kernel's
												 address space*/

	IMG_UINT32			*pui32KickerAddrUM;		/*!< kicker address in the user's
												 address space */

	IMG_SIZE_T			ui32QueueSize;			/*!< Size in bytes of the buffer - excluding the safety allocation */

	IMG_UINT32			ui32ProcessID;			/*!< Process ID required by resource locking */

	IMG_HANDLE			hMemBlock[2];

	struct _PVRSRV_QUEUE_INFO_ *psNextKM;		/*!< The next queue in the system */
}PVRSRV_QUEUE_INFO;


typedef struct _PVRSRV_HEAP_INFO_KM_
{
	IMG_UINT32			ui32HeapID;
	IMG_DEV_VIRTADDR	sDevVAddrBase;

	IMG_HANDLE 			hDevMemHeap;
	IMG_UINT32			ui32HeapByteSize;
	IMG_UINT32			ui32Attribs;
	IMG_UINT32			ui32XTileStride;
}PVRSRV_HEAP_INFO_KM;


/*
	Event Object information structure
*/
typedef struct _PVRSRV_EVENTOBJECT_KM_
{
	/* globally unique name of the event object */
	IMG_CHAR	szName[EVENTOBJNAME_MAXLENGTH];
	/* kernel specific handle for the event object */
	IMG_HANDLE	hOSEventKM;

} PVRSRV_EVENTOBJECT_KM;


/*!
 ******************************************************************************
 * Structure to retrieve misc. information from services
 *****************************************************************************/
typedef struct _PVRSRV_MISC_INFO_KM_
{
	IMG_UINT32	ui32StateRequest;		/*!< requested State Flags */
	IMG_UINT32	ui32StatePresent;		/*!< Present/Valid State Flags */

	/*!< SOC Timer register */
	IMG_VOID	*pvSOCTimerRegisterKM;
	IMG_VOID	*pvSOCTimerRegisterUM;
	IMG_HANDLE	hSOCTimerRegisterOSMemHandle;
	IMG_HANDLE	hSOCTimerRegisterMappingInfo;

	/*!< SOC Clock Gating registers */
	IMG_VOID	*pvSOCClockGateRegs;
	IMG_UINT32	ui32SOCClockGateRegsSize;

	/* Memory Stats/DDK version string depending on ui32StateRequest flags */
	IMG_CHAR	*pszMemoryStr;
	IMG_UINT32	ui32MemoryStrLen;

	/* global event object */
	PVRSRV_EVENTOBJECT_KM	sGlobalEventObject;//FIXME: should be private to services
	IMG_HANDLE				hOSGlobalEvent;

	/* Note: add misc. items as required */
	IMG_UINT32	aui32DDKVersion[4];

	/*!< CPU cache flush controls: */
	struct
	{
		/*!< Defer the CPU cache op to the next HW op to be submitted (else flush now) */
		IMG_BOOL bDeferOp;

		/*!< Type of cache operation to perform */
		PVRSRV_MISC_INFO_CPUCACHEOP_TYPE eCacheOpType;

		/*!< Meminfo (or meminfo handle) to flush */
		PVRSRV_KERNEL_MEM_INFO *psKernelMemInfo;

		/*!< Offset in MemInfo to start cache op */
		IMG_VOID *pvBaseVAddr;

		/*!< Length of range to perform cache op  */
		IMG_UINT32	ui32Length;
	} sCacheOpCtl;

	/*!< Meminfo refcount controls: */
	struct
	{
		/*!< Meminfo (or meminfo handle) to get refcount for */
		PVRSRV_KERNEL_MEM_INFO *psKernelMemInfo;

		/*!< Resulting refcount */
		IMG_UINT32 ui32RefCount;
	} sGetRefCountCtl;
} PVRSRV_MISC_INFO_KM;


/* insert command function pointer */
typedef PVRSRV_ERROR (*PFN_INSERT_CMD) (PVRSRV_QUEUE_INFO*,
										PVRSRV_COMMAND**,
										IMG_UINT32,
										IMG_UINT16,
										IMG_UINT32,
										PVRSRV_KERNEL_SYNC_INFO*[],
										IMG_UINT32,
										PVRSRV_KERNEL_SYNC_INFO*[],
										IMG_UINT32);
/* submit command function pointer */
typedef PVRSRV_ERROR (*PFN_SUBMIT_CMD) (PVRSRV_QUEUE_INFO*, PVRSRV_COMMAND*, IMG_BOOL);


/***********************************************************************
	Device Class Structures
***********************************************************************/

/*
	Generic Device Class Buffer
	- details common between DC and BC
*/
typedef struct PVRSRV_DEVICECLASS_BUFFER_TAG
{
	PFN_GET_BUFFER_ADDR		pfnGetBufferAddr;
	IMG_HANDLE				hDevMemContext;
	IMG_HANDLE				hExtDevice;
	IMG_HANDLE				hExtBuffer;
	PVRSRV_KERNEL_SYNC_INFO	*psKernelSyncInfo;
	IMG_UINT32				ui32MemMapRefCount;
} PVRSRV_DEVICECLASS_BUFFER;


/*
	Common Device Class client services information structure
*/
typedef struct PVRSRV_CLIENT_DEVICECLASS_INFO_TAG
{
#if defined (SUPPORT_SID_INTERFACE)
	IMG_SID     hDeviceKM;
#else
	IMG_HANDLE hDeviceKM;
#endif
	IMG_HANDLE	hServices;
} PVRSRV_CLIENT_DEVICECLASS_INFO;


typedef enum
{
	PVRSRV_FREE_CALLBACK_ORIGIN_ALLOCATOR,
	PVRSRV_FREE_CALLBACK_ORIGIN_IMPORTER,
	PVRSRV_FREE_CALLBACK_ORIGIN_EXTERNAL,
}
PVRSRV_FREE_CALLBACK_ORIGIN;


IMG_IMPORT
PVRSRV_ERROR FreeMemCallBackCommon(PVRSRV_KERNEL_MEM_INFO *psMemInfo,
                                   IMG_UINT32 ui32Param,
                                   PVRSRV_FREE_CALLBACK_ORIGIN eCallbackOrigin);


IMG_IMPORT
PVRSRV_ERROR PVRSRVQueueCommand(IMG_HANDLE hQueueInfo,
								PVRSRV_COMMAND *psCommand);


/*!
 * *****************************************************************************
 * @brief Allocates system memory on behalf of a userspace process that is
 * 		  addressable by the kernel; suitable for mapping into the current
 *        user space process; suitable for mapping into other userspace
 *        processes and it is possible to entirely disassociate the system
 *        memory from the current userspace process via a call to
 *        PVRSRVDissociateSharedSysMemoryKM.
 *
 * @param psConnection
 * @param ui32Flags
 * @param ui32Size
 * @param ppsClientMemInfo
 *
 * @return PVRSRV_ERROR
 ********************************************************************************/
IMG_IMPORT PVRSRV_ERROR IMG_CALLCONV
PVRSRVAllocSharedSysMem(const PVRSRV_CONNECTION *psConnection,
						IMG_UINT32 ui32Flags,
						IMG_SIZE_T ui32Size,
						PVRSRV_CLIENT_MEM_INFO **ppsClientMemInfo);

/*!
 * *****************************************************************************
 * @brief Frees memory allocated via PVRSRVAllocSharedMemory (Note you must
 *        be sure any additional kernel references you created have been
 *        removed before freeing the memory)
 *
 * @param psConnection
 * @param psClientMemInfo
 *
 * @return PVRSRV_ERROR
 ********************************************************************************/
IMG_IMPORT PVRSRV_ERROR IMG_CALLCONV
PVRSRVFreeSharedSysMem(const PVRSRV_CONNECTION *psConnection,
					   PVRSRV_CLIENT_MEM_INFO *psClientMemInfo);

/*!
 * *****************************************************************************
 * @brief Removes any userspace reference to the shared system memory, except
 *        that the memory will remain registered with the services resource
 *        manager so if the process dies/exits the actuall shared memory will
 *        still be freed.
 *        If you need to move ownership of shared memory from userspace
 *        to kernel space then before unrefing a shared piece of memory you can
 *        take a copy of psClientMemInfo->hKernelMemInfo; call
 *        PVRSRVUnrefSharedSysMem; then use some mechanism (specialised bridge
 *        function) to request that the kernel remove any resource manager
 *        reference to the shared memory and assume responsaility for the meminfo
 *        in one atomic operation. (Note to aid with such a kernel space bridge
 *        function see PVRSRVDissociateSharedSysMemoryKM)
 *
 * @param psConnection
 * @param psClientMemInfo
 *
 * @return
 ********************************************************************************/
IMG_IMPORT PVRSRV_ERROR
PVRSRVUnrefSharedSysMem(const PVRSRV_CONNECTION *psConnection,
                        PVRSRV_CLIENT_MEM_INFO *psClientMemInfo);

/*!
 * *****************************************************************************
 * @brief For shared system or device memory that is owned by the kernel, you can
 * 		  use this function to map the underlying memory into a client using a
 * 		  handle for the KernelMemInfo.
 *
 * @param[in] psConnection
 * @param[in] hKernelMemInfo
 * @param[out] ppsClientMemInfo
 *
 * @return
 ********************************************************************************/
IMG_IMPORT PVRSRV_ERROR IMG_CALLCONV
PVRSRVMapMemInfoMem(const PVRSRV_CONNECTION *psConnection,
#if defined (SUPPORT_SID_INTERFACE)
                    IMG_SID hKernelMemInfo,
#else
                    IMG_HANDLE hKernelMemInfo,
#endif
                    PVRSRV_CLIENT_MEM_INFO **ppsClientMemInfo);


#if defined (__cplusplus)
}
#endif
#endif /* __SERVICESINT_H__ */

/*****************************************************************************
 End of file (servicesint.h)
*****************************************************************************/
