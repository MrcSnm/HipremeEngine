/*!****************************************************************************
@File			sgxmmu.h

@Title			SGX MMU defines

@Author			Imagination Technologies

@date   		11/10/2005

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

@Platform

@Description	Provides SGX MMU declarations and macros

@DoxygenVer

******************************************************************************/

/******************************************************************************
Modifications :-

$Log: sgxmmu.h $
*****************************************************************************/

#if !defined(__SGXMMU_H__)
#define __SGXMMU_H__

#include "sgxdefs.h"

/* to be implemented */

/* SGX MMU maps 4Kb pages */
#define SGX_MMU_PAGE_SHIFT					(12)
#define SGX_MMU_PAGE_SIZE					(1UL<<SGX_MMU_PAGE_SHIFT)
#define SGX_MMU_PAGE_MASK					(SGX_MMU_PAGE_SIZE - 1UL)

/* PD details */
#define SGX_MMU_PD_SHIFT					(10)
#define SGX_MMU_PD_SIZE						(1<<SGX_MMU_PD_SHIFT)
#define SGX_MMU_PD_MASK						(0xFFC00000UL)

/* PD Entry details */
#if defined(SGX_FEATURE_36BIT_MMU)
	#define SGX_MMU_PDE_ADDR_MASK			(0xFFFFFF00UL)
	#define SGX_MMU_PDE_ADDR_ALIGNSHIFT		(4)
#else
	#define SGX_MMU_PDE_ADDR_MASK			(0xFFFFF000UL)
	#define SGX_MMU_PDE_ADDR_ALIGNSHIFT		(0)
#endif
#define SGX_MMU_PDE_VALID					(0x00000001UL)
/* variable page size control field */
#define SGX_MMU_PDE_PAGE_SIZE_4K			(0x00000000UL)
#define SGX_MMU_PDE_PAGE_SIZE_16K			(0x00000002UL)
#define SGX_MMU_PDE_PAGE_SIZE_64K			(0x00000004UL)
#define SGX_MMU_PDE_PAGE_SIZE_256K			(0x00000006UL)
#define SGX_MMU_PDE_PAGE_SIZE_1M			(0x00000008UL)
#define SGX_MMU_PDE_PAGE_SIZE_4M			(0x0000000AUL)
#define SGX_MMU_PDE_PAGE_SIZE_MASK			(0x0000000EUL)

/* PT details */
#define SGX_MMU_PT_SHIFT					(10)
#define SGX_MMU_PT_SIZE						(1UL<<SGX_MMU_PT_SHIFT)
#define SGX_MMU_PT_MASK						(0x003FF000UL)

/* PT Entry details */
#if defined(SGX_FEATURE_36BIT_MMU)
	#define SGX_MMU_PTE_ADDR_MASK			(0xFFFFFF00UL)
	#define SGX_MMU_PTE_ADDR_ALIGNSHIFT		(4)
#else
	#define SGX_MMU_PTE_ADDR_MASK			(0xFFFFF000UL)
	#define SGX_MMU_PTE_ADDR_ALIGNSHIFT		(0)
#endif
#define SGX_MMU_PTE_VALID					(0x00000001U)
#define SGX_MMU_PTE_WRITEONLY				(0x00000002U)
#define SGX_MMU_PTE_READONLY				(0x00000004U)
#define SGX_MMU_PTE_CACHECONSISTENT			(0x00000008U)
#define SGX_MMU_PTE_EDMPROTECT				(0x00000010U)

/* A BIF tiling range (Min DevVAddr and Max DevVAddr) is given in terms of
 * address LSBs and MSBs. For example, when defining a range on EUR_CR_BIF_TILE0
 * bits 31:20 of the range is given. The following definitions describe the bits
 * involved in providing these addresses.
 */

	/* LSB and MSB which can be provided for the Min DevVAddr and Max DevVAddr
	 * in a BIF tiling range.
	 */
	#define SGX_BIF_TILING_ADDR_LSB 20
	#define SGX_BIF_TILING_ADDR_MSB 31
#if defined(SGX_FEATURE_BIF_WIDE_TILING_AND_4K_ADDRESS)
	/* Extended addressing allows for a more fine-grained address
	 * by also defining lower bits of the DevVAddr
	 */
	#define SGX_BIF_TILING_EXT_ADDR_LSB 12
	#define SGX_BIF_TILING_EXT_ADDR_MSB 19
#endif

/* Mask which defines the bits which can be given in the tiling range.
 * If extended addressing is available the mask is wider.
 */
#if defined(SGX_FEATURE_BIF_WIDE_TILING_AND_4K_ADDRESS)
	#define SGX_BIF_TILING_ADDR_MASK 0xFFFFF000U
	/* inverse of SGX_BIF_TILING_ADDR_MASK */
	#define SGX_BIF_TILING_ADDR_INV_MASK 0x00000FFFU
#else
	#define SGX_BIF_TILING_ADDR_MASK 0xFFF00000U
	#define SGX_BIF_TILING_ADDR_INV_MASK 0x000FFFFFU
#endif


#endif	/* __SGXMMU_H__ */

/*****************************************************************************
 End of file (sgxmmu.h)
*****************************************************************************/
