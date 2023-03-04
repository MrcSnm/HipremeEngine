/******************************************************************************
 * Name         : sgxcoretypes.h
 * Title        : SGX HW errata definitions
 *
 * Copyright    : 2005-2010 by Imagination Technologies Limited.
 *              : All rights reserved. No part of this software, either
 *              : material or conceptual may be copied or distributed,
 *              : transmitted, transcribed, stored in a retrieval system or
 *              : translated into any human or computer language in any form
 *              : by any means, electronic, mechanical, manual or otherwise,
 *              : or disclosed to third parties without the express written
 *              : permission of Imagination Technologies Limited,
 *              : Home Park Estate, Kings Langley, Hertfordshire,
 *              : WD4 8LZ, U.K.
 *
 * Platform     : ANSI
 *
 * Description  : Specifies associations between SGX core revisions
 *                and SW workarounds required to fix HW errata that exist
 *                in specific core revisions
 *
 * Modifications:-
 * $Log: sgxcoretypes.h $
 *****************************************************************************/
#ifndef _SGXCORETYPES_H_
#define _SGXCORETYPES_H_

/*
	Numeric identifiers for different cores.
*/
typedef enum
{
	SGX_CORE_ID_INVALID = 0,
	SGX_CORE_ID_520	= 1,
	SGX_CORE_ID_530	= 2,
	SGX_CORE_ID_531	= 3,
	SGX_CORE_ID_535 = 4,
	SGX_CORE_ID_540	= 5,
	SGX_CORE_ID_541	= 6,
	SGX_CORE_ID_543	= 7,
	SGX_CORE_ID_544	= 8,
	SGX_CORE_ID_545	= 9,
	SGX_CORE_ID_554	= 10
} SGX_CORE_ID_TYPE;

typedef struct _SGX_CORE_INFO
{
	SGX_CORE_ID_TYPE	eID;
	IMG_UINT32			uiRev;
} SGX_CORE_INFO, *PSGX_CORE_INFO;

typedef struct _SGX_CORE_BUGS
{
	/*
		Mask of the bugs present in the this core. Flags are
			SGX_BUG_FLAGS_FIX_HW_BRN_xxxx
		defined in sgxerrata.h.
	*/
	IMG_UINT32			ui32Flags;
} SGX_CORE_BUGS, *PSGX_CORE_BUGS;

typedef struct _SGX_CORE_FEATURES
{
	/*
		Mask of the on-off features present in the this core. Flags are
			SGX_FEATURE_FLAGS_xxxx
		in sgxfeaturedefs.h.
	*/
	IMG_UINT32				ui32Flags;
	IMG_UINT32				ui32Flags2;
	/*
		Count of USE mutuxes available in this core.
	*/
	IMG_UINT32				ui32NumMutexes;
	/*
		Count of USE monitors available in this core.
	*/
	IMG_UINT32				ui32NumMonitors;
	/*
		Size (in dwords) of TAG texture state in this core.
	*/
	IMG_UINT32				ui32TextureStateSize;
	/*
		Count of the PDS constants required for an iteration on this core.
	*/
	IMG_UINT32				ui32IterationStateSize;
	/*
		Number of USE pipelines on this core.
	*/
	IMG_UINT32				ui32NumUSEPipes;
	/*
		Number of valid bits in the USE program counter on
		this core.
	*/
	IMG_UINT32				ui32NumProgramCounterBits;
	/*
		Number of internal registers available.
	*/
	IMG_UINT32				ui32NumInternalRegisters;
	/*
		Points to a count of the special registers on this core which are invalid as sources to
		non-bitwise instructions.
	*/
	IMG_UINT32 const*		puInvalidSpecialRegistersForNonBitwiseCount;
	/*
		Points to a list of the special registers on this core which are invalid
		as sources to non-bitwise instructions.
	*/
	IMG_UINT32 const*		auInvalidSpecialRegistersForNonBitwise;
	/*
		User-visible name of the core.
	*/
	IMG_CHAR const*			pszCoreName;
} SGX_CORE_FEATURES, *PSGX_CORE_FEATURES;

typedef struct _SGX_CORE_DESC
{
	/*
		ID of the core described by this structure.
	*/
	SGX_CORE_ID_TYPE	eCoreType;
	/*
		Latest revision described by this structure or 0
		if it describes the head revision.
	*/
	IMG_UINT32			ui32CoreRevision;
	/*
		Structure describing the bugs present in this core.
	*/
	SGX_CORE_BUGS		sBugs;
	/*
		Structure describing the features of this core.
	*/
	const SGX_CORE_FEATURES*	psFeatures;
} SGX_CORE_DESC, *PSGX_CORE_DESC;
typedef SGX_CORE_DESC const* PCSGX_CORE_DESC;

#endif /* _SGXCORETYPES_H_ */

/******************************************************************************
 End of file (sgxcoretypes.h)
******************************************************************************/

