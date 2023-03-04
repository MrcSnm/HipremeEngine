/******************************************************************************
 * Name         : bitops.h
 * Title        : Utility funtions/macros for bitwise operations
 * Created		: April 2005
 *
 * Copyright	: 2002-2007 by Imagination Technologies Ltd.
 *                All rights reserved. No part of this software, either
 *                material or conceptual may be copied or distributed,
 *                transmitted, transcribed, stored in a retrieval system or
 *                translated into any human or computer language in any form
 *                by any means, electronic, mechanical, manual or otherwise,
 *                or disclosed to third parties without the express written
 *                permission of Imagination Technologies Ltd,
 *                Home Park Estate, Kings Langley, Hertfordshire,
 *                WD4 8LZ, U.K.
 *
 * Modifications :-
 * $Log: bitops.h $
 *****************************************************************************/

#if !defined (__BITOPS_H__)
#define __BITOPS_H__


FORCE_INLINE IMG_UINT32 GetRange(IMG_UINT32 auArr[], 
								 const IMG_UINT32 uTop, 
								 const IMG_UINT32 uBottom)
{
	IMG_UINT32 uBitData;
	const IMG_UINT32 uTopLong	= uTop >> 5;
	const IMG_UINT32 uBottomLong	= uBottom >> 5;
	const IMG_UINT32 uBottomShift = (IMG_UINT32)uBottom & 0x1FL;
	const IMG_UINT32 uRange = (uTop - uBottom) + 1;
	const IMG_UINT32 uDataMask = ((uRange == 32) ?
								  0xFFFFFFFFL :
								  ((IMG_UINT32)((1L << uRange) - 1L)));

	if (uTopLong == uBottomLong)
	{
		/* data fits within one of our 32-bit chunks */
		uBitData = ((auArr[uBottomLong] >> uBottomShift) & uDataMask);
	}
	else
	{
		uBitData = (((auArr[uBottomLong] >> uBottomShift) | 
					  (auArr[uTopLong] << (32L - uBottomShift))) &
				   uDataMask);
	}

	return uBitData;
}

#define BITS_PER_NIBBLE		(4)
#define NIBBLE_MASK			((1 << BITS_PER_NIBBLE) - 1)
#define NIBBLES_PER_UINT	(32 / BITS_PER_NIBBLE)

FORCE_INLINE IMG_UINT32 GetNibble(const IMG_UINT32 auArr[], const IMG_UINT32 uPos)
{
	const IMG_UINT32 uElem = uPos / NIBBLES_PER_UINT;
	const IMG_UINT32 uShift = (uPos % NIBBLES_PER_UINT) * BITS_PER_NIBBLE;

	return (auArr[uElem] >> uShift) & NIBBLE_MASK;
}

FORCE_INLINE IMG_VOID SetNibble(IMG_UINT32 auArr[], const IMG_UINT32 uPos, const IMG_UINT32 uValue)
{
	const IMG_UINT32 uElem = uPos / NIBBLES_PER_UINT;
	const IMG_UINT32 uShift = (uPos % NIBBLES_PER_UINT) * BITS_PER_NIBBLE;

	auArr[uElem] &= ~(NIBBLE_MASK << uShift);
	auArr[uElem] |= ((uValue & NIBBLE_MASK) << uShift);
}

FORCE_INLINE IMG_UINT32 GetBit( const IMG_UINT32 auArr[], const IMG_UINT32 uPos )
{
	return auArr[uPos >> 5] & (1U << (uPos % 32)) ? 1 : 0;
}

/*
	Write the given bits into the given index locations of auArr
*/
FORCE_INLINE IMG_VOID SetRange(IMG_UINT32 auArr[], 
							   const IMG_UINT32 uTop, 
							   const IMG_UINT32 uBottom, 
							   const IMG_UINT32 uBitData)
{
	const IMG_UINT32 uTopLong = uTop >> 5;
	const IMG_UINT32 uBottomLong	= uBottom >> 5;
	const IMG_UINT32 uBottomShift = (IMG_UINT32)uBottom & 0x1FL;
	const IMG_UINT32 uRange = (uTop - uBottom) + 1;
	const IMG_UINT32 uDataMask = ((uRange == 32) ?
								  0xFFFFFFFFL :
								  ((IMG_UINT32)((1L << uRange) - 1L)));

	if (uTopLong == uBottomLong)
	{
		/*
			data fits within one of our 32-bit chunks
		*/
		auArr[uBottomLong] = (auArr[uBottomLong] &
								 (~(uDataMask << uBottomShift))) |
							 ((uBitData & uDataMask) << uBottomShift);
	}
	else
	{	
		const IMG_UINT32 uTopShift = 32L - uBottomShift;

		/*
			data is split across two of our 32-bit chunks
		*/
		auArr[uTopLong] = (auArr[uTopLong] & (~(uDataMask >> uTopShift))) |
						  ((uBitData & uDataMask) >> uTopShift);
		auArr[uBottomLong] = (auArr[uBottomLong] & 
							  (~(uDataMask << uBottomShift))) |
							 ((uBitData & uDataMask) << uBottomShift);
	}
}

FORCE_INLINE IMG_VOID SetBit( IMG_UINT32 auArr[], IMG_UINT32 uBit, IMG_UINT32 uBitData )
{
	if (uBitData)
	{
		auArr[uBit >> 5] |= (1U << (uBit % 32));
	}
	else
	{
		auArr[uBit >> 5] &= ~(1U << (uBit % 32));
	}
}

FORCE_INLINE IMG_UINT32 CountBits(IMG_UINT32 auArr[], IMG_UINT32 uEnd, IMG_UINT32 uStart)
{
	IMG_UINT32 uCount, i;

	uCount = 0;
	for (i = uStart; i <= uEnd; i++)
	{
		uCount += GetBit(auArr, i);
	}
	return uCount;
}

#endif /* if !defined (__BITOPS_H__) */
