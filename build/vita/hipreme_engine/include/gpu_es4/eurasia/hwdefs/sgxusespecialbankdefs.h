/*************************************************************************
 * Name         : sgxusespecialbankdefs.h
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
 * $Log: sgxusespecialbankdefs.h $
 **************************************************************************/

#ifndef _SGXUSESPECIALBANKDEFS_H
#define _SGXUSESPECIALBANKDEFS_H

#define EURASIA_USE_SPECIAL_BANK_G0					(0)
#define EURASIA_USE_SPECIAL_BANK_G1					(1)
#define EURASIA_USE_SPECIAL_BANK_G2					(2)
#define EURASIA_USE_SPECIAL_BANK_G3					(3)
#define EURASIA_USE_SPECIAL_BANK_G4					(4)
#define EURASIA_USE_SPECIAL_BANK_G5					(5)
#define EURASIA_USE_SPECIAL_BANK_G6					(6)
#define EURASIA_USE_SPECIAL_BANK_G7					(7)
#define EURASIA_USE_SPECIAL_BANK_G8					(8)
#define EURASIA_USE_SPECIAL_BANK_G9					(9)
#define EURASIA_USE_SPECIAL_BANK_G10				(10)
#define EURASIA_USE_SPECIAL_BANK_G11				(11)
#define EURASIA_USE_SPECIAL_BANK_G12				(12)
#define EURASIA_USE_SPECIAL_BANK_G13				(13)
#define EURASIA_USE_SPECIAL_BANK_G14				(14)
#define EURASIA_USE_SPECIAL_BANK_G15				(15)
#define EURASIA_USE_SPECIAL_BANK_BFCONTROL			(16)
#define EURASIA_USE_SPECIAL_BANK_PIPENUMBER			(17)
#define EURASIA_USE_SPECIAL_BANK_OUTPUTBASE			(18)
#define EURASIA_USE_SPECIAL_BANK_SEQUENCENUMBER		(19)
#define EURASIA_USE_SPECIAL_BANK_INSTANCEVALIDMASK	(20)
#define EURASIA_USE_SPECIAL_BANK_TASKID				(21)
#define EURASIA_USE_SPECIAL_BANK_SLOTNUMBER			(22)
#define EURASIA_USE_SPECIAL_BANK_QUADRANTX			(23)
#define EURASIA_USE_SPECIAL_BANK_TILEY				(24)
#define EURASIA_USE_SPECIAL_BANK_INSTNRINSLOT		(25)
#define EURASIA_USE_SPECIAL_BANK_MOEITERATIONNR		(26)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA0		(27)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA1		(28)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA2		(29)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA3		(30)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA4		(31)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA5		(32)
#define EURASIA_USE_SPECIAL_BANK_TASKQUEUEDATA6		(33)
#define EURASIA_USE_SPECIAL_BANK_TASKTYPE			(34)

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASK0			(36)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASK1			(37)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASK2			(38)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASK3			(39)
#define EURASIA_USE_SPECIAL_BANK_INSTNRINTASK		(40)
#define EURASIA_USE_SPECIAL_BANK_SECCATTRSIZE		(41)
#define EURASIA_USE_SPECIAL_BANK_BATCHNUMBER		(42)
#define EURASIA_USE_SPECIAL_BANK_TILEXY				(43)
#else /* !defined(SGX543) && !defined(SGX544) */
#define EURASIA_USE_SPECIAL_BANK_RESERVED0			(35)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASK0			(36)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASK1			(37)
#define EURASIA_USE_SPECIAL_BANK_EDGEMASKSELECT		(38)
#define EURASIA_USE_SPECIAL_BANK_INSTNRINTASK		(39)
#endif /* !defined(SGX543) && !defined(SGX544) */

#if defined(SGX545)
#define EURASIA_USE_SPECIAL_BANK_SECCATTRSIZE		(40)
#define EURASIA_USE_SPECIAL_BANK_INPUTCOVERAGEMSK	(41)
#define EURASIA_USE_SPECIAL_BANK_INPUTCOVERAGEVAL	(42)
#define EURASIA_USE_SPECIAL_BANK_PIXELINTENSITY		(43)
#endif /* !defined(SGX545) */

#if defined(SGX545) || defined(SUPPORT_SGX545)
#define EURASIA_USE_SPECIAL_BANK_SAMPLENUMBER		(44)
#endif /* !defined(SGX545) || defined(SUPPORT_SGX545) */

/*
	Only available for chip versions with multiple cores.
*/
#define EURASIA_USE_SPECIAL_BANK_CORENUMBER			(45)

#endif /* _SGXUSESPECIALBANKDEFS_H */
