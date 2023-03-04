/*************************************************************************
 * Name         : sgxformatconvert.h
 * Title        : SGX hw definitions
 *
 * Copyright    : 2005-2009 by Imagination Technologies Limited. All rights reserved.
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
 * $Log: sgxformatconvert.h $
 **************************************************************************/

#ifndef _SGXFORMATCONVERT_H_
#define	_SGXFORMATCONVERT_H_

#ifdef INLINE_IS_PRAGMA
#pragma inline(ConvertF16ToF32)
#endif

FORCE_INLINE 
IMG_FLOAT ConvertF16ToF32(IMG_UINT32 ui32T1)
/*****************************************************************************
 FUNCTION	: ConvertF32ToF16
    
 PURPOSE	: Convert from FLOAT16 to FLOAT32.

 PARAMETERS	: ui32T1		- F16 value to convert.
			  
 RETURNS	: Equivalent F32 value.
*****************************************************************************/
{
	IMG_UINT32 ui32Sign, ui32Exp, ui32Man;
	IMG_UINT32 ui32T2;

	ui32Sign = (ui32T1 & 0x8000) >> 15;
	ui32Man = ((ui32T1 & 0x03FF) >> 0);
	ui32Exp = ((ui32T1 & 0x7C00) >> 10) + 127 - 15;

	if (ui32Exp == 112)
	{
		if (ui32Man != 0)
		{
			ui32Exp++;
			while ((ui32Man & (1 << 10)) == 0)
			{
				ui32Exp--;
				ui32Man <<= 1;
			}
			ui32Man &= ~(1UL << 10);
		}
		else
		{
			ui32Exp = 0;
		}
	}
	ui32T2 = (ui32Sign << 31) | ((ui32Exp & 0xFF) << 23) | (ui32Man << 13);
	return *(IMG_FLOAT *)&ui32T2;
}

#ifdef INLINE_IS_PRAGMA
#pragma inline(ConvertF32ToF16)
#endif

FORCE_INLINE 
IMG_UINT16 ConvertF32ToF16(IMG_FLOAT fV)
/*****************************************************************************
 FUNCTION	: ConvertF32ToF16
    
 PURPOSE	: Convert from FLOAT32 to FLOAT16.

 PARAMETERS	: fV		- F32 value to convert.
			  
 RETURNS	: Equivalent F16 value.
*****************************************************************************/
{
	IMG_UINT16 ui16V;
	IMG_UINT32 ui32Exp;
	IMG_UINT32 ui32Man;

	/* PRQA S 3341 1 */ /* test for exactly zero shortcut */
	if (fV == 0.0f)
	{
		return 0;
	}

	/* Set up the F16 sign bit. */
	if (fV < 0)
	{
		ui16V = 0x8000;
	}
	else
	{
		ui16V = 0;
	}

	/*
		Get the absolute value of the input.
	*/
	if (fV < 0)
	{
		fV = -fV;
	}

	/*
		Clamp to the maximum representable F16 value.
	*/
	/* 2^15 * (2 - 1/1024) = maximum f16 value. */
	if (fV > 131008)
	{
		fV = 131008;
	}

	ui32Exp = ((*((IMG_PUINT32)&fV)) >> 23) - 127 + 15;
	ui32Man = (*((IMG_PUINT32)&fV)) & ((1 << 23) - 1);
	/* Check for making an F16 denorm. */
	if ((IMG_INT32)ui32Exp <= 0)
	{
		IMG_UINT32 ui32Shift;

		ui32Man |= (1 << 23);

		ui32Exp = ((*((IMG_UINT32 *)&fV)) >> 23);

		ui32Shift = -14 + 127 - ui32Exp;

		if (ui32Shift < 24)
		{
			ui32Man >>= ui32Shift;
		}
		else
		{
			ui32Man = 0;
		}
	}
	else
	{
		ui16V |= (IMG_UINT16)((ui32Exp << 10) & 0x7C00);
	}
	ui16V |= (IMG_UINT16)(((ui32Man >> 13) << 0) & 0x03FF);
	/* Round to nearest. */
	if (ui32Man & (1 << 12))
	{
		ui16V++;
	}
	return ui16V;
}

#endif	/* _SGXFORMATCONVERT_H_ */

/* EOF */
