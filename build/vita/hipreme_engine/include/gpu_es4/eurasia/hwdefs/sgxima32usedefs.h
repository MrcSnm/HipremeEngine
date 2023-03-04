/*************************************************************************
 * Name         : sgxima32usedefs.h
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
 * $Log: sgxima32usedefs.h $
 **************************************************************************/

#ifndef _SGXIMA32USEDEFS_H_
#define	_SGXIMA32USEDEFS_H_

/* Extensions of the OP field. */
#define EURASIA_USE1_OP_32BITINT					(26UL)

/*
	Subopcode field for OP=EURASIA_USE1_OP_32BITINT
*/
#define EURASIA_USE1_32BITINT_OP2_SHIFT				(20)
#define EURASIA_USE1_32BITINT_OP2_CLRMSK			(0xFFCFFFFFU)
#define EURASIA_USE1_32BITINT_OP2_IMA32				(0)

/*
	IMA32
*/
#define EURASIA_USE1_IMA32_CIEN_SHIFT				(10)
#define EURASIA_USE1_IMA32_CIEN_CLRMSK				(0xFFFFF3FFU)
#define EURASIA_USE1_IMA32_CIEN_DISABLED			(0)
#define EURASIA_USE1_IMA32_CIEN_I0_BIT0				(1)
#define EURASIA_USE1_IMA32_CIEN_I1_BIT0				(2)
#define EURASIA_USE1_IMA32_CIEN_I2_BIT0				(3)

#define EURASIA_USE1_IMA32_SGN						(0x00000200U)

#define EURASIA_USE1_IMA32_NEGS1					(0x00000100U)

#define EURASIA_USE1_IMA32_NEGS2					(0x00000080U)

#define EURASIA_USE1_IMA32_GPIWEN					(0x00000040U)

#define EURASIA_USE1_IMA32_GPISRC_CLRMSK			(0xFFFFFFCFU)
#define EURASIA_USE1_IMA32_GPISRC_SHIFT				(4)
#define EURASIA_USE1_IMA32_GPISRC_MAX				(2)

#define EURASIA_USE1_IMA32_S0BEXT					(0x00008000U)

#endif /* _SGXIMA32USEDEFS_H_ */
