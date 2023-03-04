/*************************************************************************
 * Name         : sgx540usedefs.h
 * Title        : SGX hw definitions
 *
 * Copyright    : 2005-2006 by Imagination Technologies Limited. All rights reserved.
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
 * $Log: sgx540usedefs.h $
 **************************************************************************/

#ifndef _SGX540USEDEFS_H_
#define	_SGX540USEDEFS_H_

#define SGX540_USE1_OP_FNRM					(27)

#define SGX540_USE1_FNRM_DRCSEL_SHIFT		(21)
#define SGX540_USE1_FNRM_DRCSEL_CLRMSK		(0xFFDFFFFF)

#define SGX540_USE1_FNRM_F16DP				(0x00080000)

#define SGX540_USE1_FNRM_F16C0SWIZ_SHIFT	(8)
#define SGX540_USE1_FNRM_F16C0SWIZ_CLRMSK	(0xFFFFF8FF)

#define SGX540_USE1_FNRM_F16C1SWIZ_SHIFT	(5)
#define SGX540_USE1_FNRM_F16C1SWIZ_CLRMSK	(0xFFFFFF1F)

#define SGX540_USE1_FNRM_SRCMOD_SHIFT		(3)
#define SGX540_USE1_FNRM_SRCMOD_CLRMSK		(0xFFFFFFE7)

#define SGX540_USE0_FNRM_F16C2SWIZ_SHIFT	(17)
#define SGX540_USE0_FNRM_F16C2SWIZ_CLRMSK	(0xFFF1FFFF)

#define SGX540_USE0_FNRM_F16C3SWIZ_SHIFT	(14)
#define SGX540_USE0_FNRM_F16C3SWIZ_CLRMSK	(0xFFFE3FFF)

#define SGX540_USE_FNRM_F16CHANSEL_SRC0L	(0)
#define SGX540_USE_FNRM_F16CHANSEL_SRC0H	(1)
#define SGX540_USE_FNRM_F16CHANSEL_SRC1L	(2)
#define SGX540_USE_FNRM_F16CHANSEL_SRC1H	(3)
#define SGX540_USE_FNRM_F16CHANSEL_ZERO		(4)
#define SGX540_USE_FNRM_F16CHANSEL_ONE		(5)
#define SGX540_USE_FNRM_F16CHANSEL_RESERVED0	(6)
#define SGX540_USE_FNRM_F16CHANSEL_RESERVED1	(7)

#endif	/* _SGX540USEDEFS_H_ */

/* EOF */

