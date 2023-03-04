/*************************************************************************
 * Name         : sgx545usedefs.h
 * Title        : SGX hw definitions
 *
 * Copyright    : 2005-2010 by Imagination Technologies Limited. All rights reserved.
 *              : No part of this software, either material or conceptual 
 *              : may be copied or distributed, transmitted, transcribed,
 *              : stored in a retrieval system or translated into any 
 *              : human or computer language in any form by any means,
 *              : electronic, mechanical, manual or other-wise, or 
 *              : disclosed to third parties without the express written
 *              : permission of Imagination Technologies Limited, Unit 8, HomePark
 *              : Industrial Estate, King's Langley, Hertfordshire,
 *              : WD4 8LZ, U.K.
 *
 * Platform     : ANSI
 *
 * Modifications:-
 * $Log: sgxphasusedefs.h $
 **************************************************************************/

#ifndef _SGXPHASUSEDEFS_H_
#define	_SGXPHASUSEDEFS_H_

/* Uses OPCAT=OTHER2 with EURASIA_USE1_SPECIAL_OPCAT_EXTRA */
#define EURASIA_USE1_OTHER2_OP2_PHAS					(2)

/* PHAS instruction. */
#define EURASIA_USE1_OTHER2_PHAS_END					(0x00080000)
#define EURASIA_USE1_OTHER2_PHAS_IMM					(0x00040000)

#define EURASIA_USE1_OTHER2_PHAS_NONIMM_NOSCHED			(0x00000800)

#define EURASIA_USE1_OTHER2_PHAS_IMM_MODE_CLRMSK		(0xFFFFDFFF)
#define EURASIA_USE1_OTHER2_PHAS_IMM_MODE_SHIFT			(13)

#define EURASIA_USE1_OTHER2_PHAS_IMM_RATE_CLRMSK		(0xFFFFE7FF)
#define EURASIA_USE1_OTHER2_PHAS_IMM_RATE_SHIFT			(11)

#define EURASIA_USE1_OTHER2_PHAS_IMM_WAITCOND_CLRMSK	(0xFFFFF8FF)
#define EURASIA_USE1_OTHER2_PHAS_IMM_WAITCOND_SHIFT		(8)

#define EURASIA_USE1_OTHER2_PHAS_IMM_TCOUNT_CLRMSK		(0xFFFFFF00)
#define EURASIA_USE1_OTHER2_PHAS_IMM_TCOUNT_SHIFT		(0)

#define EURASIA_USE0_OTHER2_PHAS_IMM_EXEADDR_CLRMSK		(~(((1UL << SGX_FEATURE_USE_NUMBER_PC_BITS) - 1) << EURASIA_USE0_OTHER2_PHAS_IMM_EXEADDR_SHIFT))
#define EURASIA_USE0_OTHER2_PHAS_IMM_EXEADDR_SHIFT		(0)

#define EURASIA_USE_OTHER2_PHAS_SRC1_MODE_CLRMSK		(0xFFFFFFDF)
#define EURASIA_USE_OTHER2_PHAS_SRC1_MODE_SHIFT			(5)

#define EURASIA_USE_OTHER2_PHAS_SRC1_WAITCOND_CLRMSK	(0xFFFFFFE3)
#define EURASIA_USE_OTHER2_PHAS_SRC1_WAITCOND_SHIFT		(2)

#define EURASIA_USE_OTHER2_PHAS_SRC1_RATE_CLRMSK		(0xFFFFFFFC)
#define EURASIA_USE_OTHER2_PHAS_SRC1_RATE_SHIFT			(0)

#define EURASIA_USE_OTHER2_PHAS_SRC2_TCOUNT_CLRMSK		(0x00FFFFFF)
#define EURASIA_USE_OTHER2_PHAS_SRC2_TCOUNT_SHIFT		(24) 

#define EURASIA_USE_OTHER2_PHAS_SRC2_EXEADDR_CLRMSK		(~(((1UL << SGX_FEATURE_USE_NUMBER_PC_BITS) - 1) << EURASIA_USE0_OTHER2_PHAS_IMM_EXEADDR_SHIFT))
#define EURASIA_USE_OTHER2_PHAS_SRC2_EXEADDR_SHIFT		(0)

#define EURASIA_USE_OTHER2_PHAS_TCOUNT_ALIGN			(4)
#define EURASIA_USE_OTHER2_PHAS_TCOUNT_ALIGNSHIFT		(2)
#define EURASIA_USE_OTHER2_PHAS_TCOUNT_MAX				(1020)

#define EURASIA_USE_OTHER2_PHAS_MODE_PARALLEL			(0)
#define EURASIA_USE_OTHER2_PHAS_MODE_PERINSTANCE		(1)

#define EURASIA_USE_OTHER2_PHAS_RATE_PIXEL				(0)
#define EURASIA_USE_OTHER2_PHAS_RATE_SELECTIVE			(1)
#define EURASIA_USE_OTHER2_PHAS_RATE_SAMPLE				(2)
#define EURASIA_USE_OTHER2_PHAS_RATE_RESERVED			(3)

#define EURASIA_USE_OTHER2_PHAS_WAITCOND_NONE			(0)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_PT				(1)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_VCULL			(2)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_RESERVED0		(3)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_RESERVED1		(4)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_RESERVED2		(5)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_RESERVED3		(6)
#define EURASIA_USE_OTHER2_PHAS_WAITCOND_END			(7)

#if defined(SGX_FEATURE_USE_SPRVV) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX554)
#define EURASIA_USE_OTHER2_PHAS_TYPEEXT_SPRVV			(0x00800000)
#endif /* defined(SGX_FEATURE_USE_SPRVV) || defined(SUPPORT_SGX543) */

#endif	/* _SGXPHASUSEDEFS_H_ */

