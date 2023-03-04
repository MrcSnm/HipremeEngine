/******************************************************************************
 * Name         : sgxpdsdefs.h
 * Title        : SGX PDS definitions
 * Author       : Paul Burgess
 * Created      : August 2005
 *
 * Copyright    : 2005-2007 by Imagination Technologies Limited.
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
 * Modifications:-
 * $Log: sgxpdsdefs.h $
 *****************************************************************************/

#ifndef _SGXPDSDEFS_H_
#define _SGXPDSDEFS_H_

/*****************************************************************************
 PDS inline function definitions
*****************************************************************************/

/*****************************************************************************
 Function Name	: PDSEncodeMOVS
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOVS instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMOVS)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeMOVS	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2,
										IMG_UINT32	ui32Swiz0,
										IMG_UINT32	ui32Swiz1,
										IMG_UINT32	ui32Swiz2,
										IMG_UINT32	ui32Swiz3)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOVS		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32Dest					<< EURASIA_PDS_MOVS_DEST_SHIFT)		|
			(ui32Src1Sel				<< EURASIA_PDS_MOVS_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_MOVS_SRC1_SHIFT)		|
			(ui32Src2Sel				<< EURASIA_PDS_MOVS_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_MOVS_SRC2_SHIFT)		|
			(ui32Swiz0					<< EURASIA_PDS_MOVS_SWIZ0_SHIFT)	|
			(ui32Swiz1					<< EURASIA_PDS_MOVS_SWIZ1_SHIFT)	|
			(ui32Swiz2					<< EURASIA_PDS_MOVS_SWIZ2_SHIFT)	|
			(ui32Swiz3					<< EURASIA_PDS_MOVS_SWIZ3_SHIFT);
}


#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)

/*****************************************************************************
 Function Name	: PDSEncodeDOUTT
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOVS instruction for DOUTT
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeDOUTT)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeDOUTT	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2,
										IMG_BOOL	bSwiz,
										IMG_BOOL	bMinPack,
										IMG_UINT32	ui32FormatConv)
{
	return	(EURASIA_PDS_INST_MOV			<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOVS			<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)															|
			(EURASIA_PDS_MOVS_DEST_DOUTT	<< EURASIA_PDS_MOVS_DEST_SHIFT)		|
			(ui32Src1Sel					<< EURASIA_PDS_MOVS_SRC1SEL_SHIFT)	|
			(ui32Src1						<< EURASIA_PDS_MOVS_SRC1_SHIFT)		|
			(ui32Src2Sel					<< EURASIA_PDS_MOVS_SRC2SEL_SHIFT)	|
			(ui32Src2						<< EURASIA_PDS_MOVS_SRC2_SHIFT)		|
			(bSwiz ? EURASIA_PDS_MOVS_DOUTT_SWIZ : 0)							|
			(bMinPack ? EURASIA_PDS_MOVS_DOUTT_MINPACK : 0)						|
			(ui32FormatConv					<< EURASIA_PDS_MOVS_DOUTT_FCONV_SHIFT);
}


/*****************************************************************************
 Function Name	: PDSEncodeDOUTI
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOVS instruction for DOUTI
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeDOUTI)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeDOUTI	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2,
										IMG_UINT32	ui32Swiz0,
										IMG_UINT32	ui32Swiz1,
										IMG_UINT32	ui32TagSize,
										IMG_UINT32	ui32ItrSize)
{
	return	(EURASIA_PDS_INST_MOV			<< EURASIA_PDS_INST_SHIFT)					|
			(EURASIA_PDS_TYPE_MOVS			<< EURASIA_PDS_TYPE_SHIFT)					|
			(ui32CC)																	|
			(EURASIA_PDS_MOVS_DEST_DOUTI	<< EURASIA_PDS_MOVS_DEST_SHIFT)				|
			(ui32Src1Sel					<< EURASIA_PDS_MOVS_SRC1SEL_SHIFT)			|
			(ui32Src1						<< EURASIA_PDS_MOVS_SRC1_SHIFT)				|
			(ui32Src2Sel					<< EURASIA_PDS_MOVS_SRC2SEL_SHIFT)			|
			(ui32Src2						<< EURASIA_PDS_MOVS_SRC2_SHIFT)				|
			(ui32Swiz0						<< EURASIA_PDS_MOVS_SWIZ0_SHIFT)			|
			(ui32Swiz1						<< EURASIA_PDS_MOVS_SWIZ1_SHIFT)			|
			(ui32TagSize					<< EURASIA_PDS_MOVS_DOUTI_TAGSIZE_SHIFT)	|
			(ui32ItrSize					<< EURASIA_PDS_MOVS_DOUTI_ITRSIZE_SHIFT);
}

#else

/*****************************************************************************
 Function Name	: PDSEncodeDOUTT
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOVS instruction for DOUTT
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeDOUTT)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeDOUTT	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2,
										IMG_UINT32	ui32Swiz0,
										IMG_UINT32	ui32Swiz1,
										IMG_UINT32	ui32Swiz2,
										IMG_UINT32	ui32Swiz3)
{
	return	(EURASIA_PDS_INST_MOV			<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOVS			<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)															|
			(EURASIA_PDS_MOVS_DEST_DOUTT	<< EURASIA_PDS_MOVS_DEST_SHIFT)		|
			(ui32Src1Sel					<< EURASIA_PDS_MOVS_SRC1SEL_SHIFT)	|
			(ui32Src1						<< EURASIA_PDS_MOVS_SRC1_SHIFT)		|
			(ui32Src2Sel					<< EURASIA_PDS_MOVS_SRC2SEL_SHIFT)	|
			(ui32Src2						<< EURASIA_PDS_MOVS_SRC2_SHIFT)		|
			(ui32Swiz0						<< EURASIA_PDS_MOVS_SWIZ0_SHIFT)	|
			(ui32Swiz1						<< EURASIA_PDS_MOVS_SWIZ1_SHIFT)	|
			(ui32Swiz2						<< EURASIA_PDS_MOVS_SWIZ2_SHIFT)	|
			(ui32Swiz3						<< EURASIA_PDS_MOVS_SWIZ3_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeDOUTI
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOVS instruction for DOUTI
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeDOUTI)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeDOUTI	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2,
										IMG_UINT32	ui32Swiz0,
										IMG_UINT32	ui32Swiz1,
										IMG_UINT32	ui32Swiz2,
										IMG_UINT32	ui32Swiz3)
{
	return	(EURASIA_PDS_INST_MOV			<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOVS			<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)															|
			(EURASIA_PDS_MOVS_DEST_DOUTI	<< EURASIA_PDS_MOVS_DEST_SHIFT)		|
			(ui32Src1Sel					<< EURASIA_PDS_MOVS_SRC1SEL_SHIFT)	|
			(ui32Src1						<< EURASIA_PDS_MOVS_SRC1_SHIFT)		|
			(ui32Src2Sel					<< EURASIA_PDS_MOVS_SRC2SEL_SHIFT)	|
			(ui32Src2						<< EURASIA_PDS_MOVS_SRC2_SHIFT)		|
			(ui32Swiz0						<< EURASIA_PDS_MOVS_SWIZ0_SHIFT)	|
			(ui32Swiz1						<< EURASIA_PDS_MOVS_SWIZ1_SHIFT)	|
			(ui32Swiz2						<< EURASIA_PDS_MOVS_SWIZ2_SHIFT)	|
			(ui32Swiz3						<< EURASIA_PDS_MOVS_SWIZ3_SHIFT);
}

#endif /* SGX_FEATURE_PDS_EXTENDED_SOURCES */

/*****************************************************************************
 Function Name	: PDSEncodeMOV16
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOV16 instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMOV16)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeMOV16	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32SrcSel,
										IMG_UINT32	ui32Src)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOV16		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_MOV16_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_MOV16_DEST_SHIFT)	|
			(ui32SrcSel					<< EURASIA_PDS_MOV16_SRCSEL_SHIFT)	|
			(ui32Src					<< EURASIA_PDS_MOV16_SRC_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeMOV32
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOV32 instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMOV32)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeMOV32	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32SrcSel,
										IMG_UINT32	ui32Src)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOV32		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_MOV32_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_MOV32_DEST_SHIFT)	|
			(ui32SrcSel					<< EURASIA_PDS_MOV32_SRCSEL_SHIFT)	|
			(ui32Src					<< EURASIA_PDS_MOV32_SRC_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeMOV64
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOV64 instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMOV64)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeMOV64	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32DestSel,
										 IMG_UINT32	ui32Dest,
										 IMG_UINT32	ui32SrcSel,
										 IMG_UINT32	ui32Src)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOV64		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_MOV64_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_MOV64_DEST_SHIFT)	|
			(ui32SrcSel					<< EURASIA_PDS_MOV64_SRCSEL_SHIFT)	|
			(ui32Src					<< EURASIA_PDS_MOV64_SRC_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeMOV128
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOV128 instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMOV128)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeMOV128	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32SrcSel,
										IMG_UINT32	ui32Src,
										IMG_UINT32	ui32Swap)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)				|
			(EURASIA_PDS_TYPE_MOV128	<< EURASIA_PDS_TYPE_SHIFT)				|
			(ui32CC)															|
			(ui32Dest					<< EURASIA_PDS_MOV128_DEST_SHIFT)		|
			(ui32SrcSel					<< EURASIA_PDS_MOV128_SRCSEL_SHIFT)		|
			(ui32Src					<< EURASIA_PDS_MOV128_SRC_SHIFT)		|
			(ui32Swap					<< EURASIA_PDS_MOV128_SWAP_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeMOVSA
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MOVSA instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMOVSA)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeMOVSA	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2,
										IMG_UINT32	ui32Swiz0,
										IMG_UINT32	ui32Swiz1,
										IMG_UINT32	ui32Swiz2,
										IMG_UINT32	ui32Swiz3)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MOVSA		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32Dest					<< EURASIA_PDS_MOVS_DEST_SHIFT)		|
			(ui32Src1Sel				<< EURASIA_PDS_MOVS_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_MOVS_SRC1_SHIFT)		|
			(ui32Src2Sel				<< EURASIA_PDS_MOVS_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_MOVS_SRC2_SHIFT)		|
			(ui32Swiz0					<< EURASIA_PDS_MOVS_SWIZ0_SHIFT)	|
			(ui32Swiz1					<< EURASIA_PDS_MOVS_SWIZ1_SHIFT)	|
			(ui32Swiz2					<< EURASIA_PDS_MOVS_SWIZ2_SHIFT)	|
			(ui32Swiz3					<< EURASIA_PDS_MOVS_SWIZ3_SHIFT);
}

#if defined(SGX_FEATURE_PDS_LOAD_STORE)
/*****************************************************************************
 Function Name	: PDSEncodeLOAD
 Inputs			: the instruction fields:
				: ui32Size - number of 32 bit words of data to load into the temporaries
				: ui32Dest - Destination for the load
				: ui32DestSel - DS0 or DS1 Temporary register, use EURASIA_PDS_LOADSTORE_REGADDRSEL_DS0/1
				: ui32Src - 32 bit Source Address in Memory, offset from EUR_CR_PDS_MICRO_DATA_BASE_ADDRESS
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the LOAD instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeLOAD)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeLOAD	(	IMG_UINT32 ui32Size,
											IMG_UINT32	ui32Dest,
											IMG_UINT32	ui32DestSel,
											IMG_UINT32	ui32Src)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)					|
			(EURASIA_PDS_TYPE_LOAD		<< EURASIA_PDS_TYPE_SHIFT)					|
			(ui32Size					<< EURASIA_PDS_LOADSTORE_SIZE_SHIFT)		|
			(ui32DestSel				<< EURASIA_PDS_LOADSTORE_REGADDRSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOADSTORE_REGADDR_SHIFT)		|
			(ui32Src					<< EURASIA_PDS_LOADSTORE_MEMADDR_SHIFT);

}


/*****************************************************************************
 Function Name	: PDSEncodeSTORE
 Inputs			: the instruction fields:
				: ui32Size - number of 32 bit words of data to store from the temporaries
				: ui32Src - Source for the store
				: ui32SrcSel - DS0 or DS1 Temporary register, use EURASIA_PDS_LOADSTORE_REGADDRSEL_DS0/1
				: ui32Dest - 32 bit Destination Address in Memory, offset from EUR_CR_PDS_MICRO_DATA_BASE_ADDRESS
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the STORE instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeSTORE)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeSTORE	(	IMG_UINT32 ui32Size,
											IMG_UINT32	ui32Src,
											IMG_UINT32	ui32SrcSel,
											IMG_UINT32	ui32Dest)
{
	return	(EURASIA_PDS_INST_MOV		<< EURASIA_PDS_INST_SHIFT)					|
			(EURASIA_PDS_TYPE_STORE		<< EURASIA_PDS_TYPE_SHIFT)					|
			(ui32Size					<< EURASIA_PDS_LOADSTORE_SIZE_SHIFT)		|
			(ui32SrcSel					<< EURASIA_PDS_LOADSTORE_REGADDRSEL_SHIFT)	|
			(ui32Src					<< EURASIA_PDS_LOADSTORE_REGADDR_SHIFT)		|
			(ui32Dest					<< EURASIA_PDS_LOADSTORE_MEMADDR_SHIFT);

}

/*****************************************************************************
 Function Name	: PDSEncodeFENCE
 Inputs			: the instruction fields:
				: ui32ModeSel - Fence wither reads and writes or reads only.
				: Use EURASIA_PDS_DATAFENCE_MODE_READ or EURASIA_PDS_DATAFENCE_MODE_READWRITE
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the Data FENCE instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeFENCE)
#endif

FORCE_INLINE IMG_UINT32 PDSEncodeFENCE	(IMG_UINT32 ui32ModeSel)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)					|
			(EURASIA_PDS_TYPE_DATAFENCE	<< EURASIA_PDS_TYPE_SHIFT)					|
			(ui32ModeSel				<< EURASIA_PDS_DATAFENCE_MODE_SHIFT);

}

#endif /* SGX_FEATURE_PDS_LOAD_STORE*/

/*****************************************************************************
 Function Name	: PDSEncodeADD
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the ADD instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeADD)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeADD	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_ADD		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_ARITH_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_ARITH_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_ARITH_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_ARITH_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_ARITH_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_ARITH_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeSUB
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the SUB instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeSUB)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeSUB	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_SUB		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_ARITH_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_ARITH_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_ARITH_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_ARITH_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_ARITH_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_ARITH_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeADC
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the ADC instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeADC)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeADC	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_ADC		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_ARITH_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_ARITH_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_ARITH_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_ARITH_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_ARITH_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_ARITH_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeSBC
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the SBC instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeSBC)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeSBC	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_SBC		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_ARITH_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_ARITH_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_ARITH_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_ARITH_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_ARITH_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_ARITH_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeMUL
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the MUL instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeMUL)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeMUL	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_MUL		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_MUL_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_MUL_DEST_SHIFT)		|
			(ui32Src1Sel				<< EURASIA_PDS_MUL_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_MUL_SRC1_SHIFT)		|
			(ui32Src2Sel				<< EURASIA_PDS_MUL_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_MUL_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeABS
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the ABS instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeABS)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeABS	(IMG_UINT32	ui32CC,
									 IMG_UINT32	ui32DestSel,
									 IMG_UINT32	ui32Dest,
									 IMG_UINT32	ui32SrcSel,
									 IMG_UINT32	ui32Src1Sel,
									 IMG_UINT32	ui32Src1,
									 IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_ARITH		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_ABS		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_ABS_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_ABS_DEST_SHIFT)		|
			(ui32SrcSel					<< EURASIA_PDS_ABS_SRCSEL_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_ABS_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_ABS_SRC1_SHIFT)		|
			(ui32Src2					<< EURASIA_PDS_ABS_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSBaseEncodeTest
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the test instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSBaseEncodeTest)
#endif
FORCE_INLINE IMG_UINT32 PDSBaseEncodeTest(IMG_UINT32	ui32CC,
										  IMG_UINT32	ui32Type,
										  IMG_UINT32	ui32Mod,
										  IMG_UINT32	ui32Dest,
										  IMG_UINT32	ui32SrcSel,
										  IMG_UINT32	ui32Src1Sel,
										  IMG_UINT32	ui32Src1,
										  IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_FLOW		<< EURASIA_PDS_INST_SHIFT)			|
			(ui32Type					<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32Mod)														|
			(ui32Dest					<< EURASIA_PDS_TST_DEST_SHIFT)		|
			(ui32SrcSel					<< EURASIA_PDS_TST_SRCSEL_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_TST_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_TST_SRC1_SHIFT)		|
			(ui32Src2					<< EURASIA_PDS_TST_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeTSTZ
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the TSTZ instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeTSTZ)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeTSTZ	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32Dest,
										 IMG_UINT32	ui32SrcSel,
										 IMG_UINT32	ui32Src1Sel,
										 IMG_UINT32	ui32Src1,
										 IMG_UINT32	ui32Src2)
{
	return PDSBaseEncodeTest(ui32CC,
							 EURASIA_PDS_TYPE_TSTZ,
							 0 /* ui32Mod */,
							 ui32Dest,
							 ui32SrcSel,
							 ui32Src1Sel,
							 ui32Src1,
							 ui32Src2);
}

/*****************************************************************************
 Function Name	: PDSEncodeTSTN
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the TSTN instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeTSTN)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeTSTN	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32Dest,
										 IMG_UINT32	ui32SrcSel,
										 IMG_UINT32	ui32Src1Sel,
										 IMG_UINT32	ui32Src1,
										 IMG_UINT32	ui32Src2)
{
	return PDSBaseEncodeTest(ui32CC,
							 EURASIA_PDS_TYPE_TSTN,
							 0 /* ui32Mod */,
							 ui32Dest,
							 ui32SrcSel,
							 ui32Src1Sel,
							 ui32Src1,
							 ui32Src2);
}

#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)
/*****************************************************************************
 Function Name	: PDSEncodeTSTNZ
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the TSTNZ instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeTSTNZ)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeTSTNZ	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32Dest,
										 IMG_UINT32	ui32SrcSel,
										 IMG_UINT32	ui32Src1Sel,
										 IMG_UINT32	ui32Src1,
										 IMG_UINT32	ui32Src2)
{
	return PDSBaseEncodeTest(ui32CC,
							 EURASIA_PDS_TYPE_TSTZ,
							 EURASIA_PDS_TST_NEGATE,
							 ui32Dest,
							 ui32SrcSel,
							 ui32Src1Sel,
							 ui32Src1,
							 ui32Src2);
}

/*****************************************************************************
 Function Name	: PDSEncodeTSTP
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the TSTP instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeTSTP)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeTSTP	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32Dest,
										 IMG_UINT32	ui32SrcSel,
										 IMG_UINT32	ui32Src1Sel,
										 IMG_UINT32	ui32Src1,
										 IMG_UINT32	ui32Src2)
{
	return PDSBaseEncodeTest(ui32CC,
							 EURASIA_PDS_TYPE_TSTN,
							 EURASIA_PDS_TST_NEGATE,
							 ui32Dest,
							 ui32SrcSel,
							 ui32Src1Sel,
							 ui32Src1,
							 ui32Src2);
}
#endif /* defined(SGX_FEATURE_PDS_EXTENDED_SOURCES) */

/*****************************************************************************
 Function Name	: PDSEncodeALUM
 Inputs			: ui32CC, ui32Mode
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the ALUM instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeALUM)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeALUM	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32Mode)
{
	return	(EURASIA_PDS_INST_FLOW		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_ALUM		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32Mode					<< EURASIA_PDS_FLOW_ALUM_MODE_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeBRA
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the BRA instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeBRA)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeBRA	(IMG_UINT32	ui32CC,
									 IMG_UINT32	ui32Dest)
{
	return	(EURASIA_PDS_INST_FLOW							<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_BRA							<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)																			|
			((ui32Dest >> EURASIA_PDS_FLOW_DEST_ALIGNSHIFT)	<< EURASIA_PDS_FLOW_DEST_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeCALL
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the CALL instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeCALL)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeCALL	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32Dest)
{
	return	(EURASIA_PDS_INST_FLOW							<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_CALL							<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)																			|
			((ui32Dest >> EURASIA_PDS_FLOW_DEST_ALIGNSHIFT)	<< EURASIA_PDS_FLOW_DEST_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeRTN
 Inputs			: ui32CC, ...				- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the RTN instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeRTN)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeRTN	(IMG_UINT32	ui32CC)
{
	return	(EURASIA_PDS_INST_FLOW		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_RTN		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC);
}

/*****************************************************************************
 Function Name	: PDSEncodeHALT
 Inputs			: ui32CC, ...				- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the HALT instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeHALT)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeHALT	(IMG_UINT32	ui32CC)
{
	return	(EURASIA_PDS_INST_FLOW		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_HALT		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC);
}

/*****************************************************************************
 Function Name	: PDSEncodeNOP
 Inputs			: none
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the NOP instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeNOP)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeNOP	(IMG_VOID)
{
	return	(EURASIA_PDS_INST_FLOW		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_NOP		<< EURASIA_PDS_TYPE_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeOR
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the OR instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeOR)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeOR	(IMG_UINT32	ui32CC,
									 IMG_UINT32	ui32DestSel,
									 IMG_UINT32	ui32Dest,
									 IMG_UINT32	ui32Src1Sel,
									 IMG_UINT32	ui32Src1,
									 IMG_UINT32	ui32Src2Sel,
									 IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_OR		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_LOGIC_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOGIC_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_LOGIC_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_LOGIC_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_LOGIC_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_LOGIC_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeAND
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the AND instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeAND)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeAND	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_AND		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_LOGIC_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOGIC_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_LOGIC_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_LOGIC_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_LOGIC_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_LOGIC_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeXOR
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the XOR instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeXOR)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeXOR	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_XOR		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_LOGIC_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOGIC_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_LOGIC_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_LOGIC_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_LOGIC_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_LOGIC_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeNOT
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the NOT instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeNOT)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeNOT	(IMG_UINT32	ui32CC,
									 IMG_UINT32	ui32DestSel,
									 IMG_UINT32	ui32Dest,
									 IMG_UINT32	ui32SrcSel,
									 IMG_UINT32	ui32Src1Sel,
									 IMG_UINT32	ui32Src1,
									 IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_NOT		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_LOGIC_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOGIC_DEST_SHIFT)	|
			(ui32SrcSel					<< EURASIA_PDS_LOGIC_SRCSEL_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_LOGIC_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_LOGIC_SRC1_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_LOGIC_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeNOR
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the NOR instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeNOR)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeNOR	(IMG_UINT32	ui32CC,
										IMG_UINT32	ui32DestSel,
										IMG_UINT32	ui32Dest,
										IMG_UINT32	ui32Src1Sel,
										IMG_UINT32	ui32Src1,
										IMG_UINT32	ui32Src2Sel,
										IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_NOR		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_LOGIC_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOGIC_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_LOGIC_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_LOGIC_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_LOGIC_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_LOGIC_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeNAND
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the NAND instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeNAND)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeNAND	(IMG_UINT32	ui32CC,
										 IMG_UINT32	ui32DestSel,
										 IMG_UINT32	ui32Dest,
										 IMG_UINT32	ui32Src1Sel,
										 IMG_UINT32	ui32Src1,
										 IMG_UINT32	ui32Src2Sel,
										 IMG_UINT32	ui32Src2)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_NAND		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_LOGIC_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_LOGIC_DEST_SHIFT)	|
			(ui32Src1Sel				<< EURASIA_PDS_LOGIC_SRC1SEL_SHIFT)	|
			(ui32Src1					<< EURASIA_PDS_LOGIC_SRC1_SHIFT)	|
			(ui32Src2Sel				<< EURASIA_PDS_LOGIC_SRC2SEL_SHIFT)	|
			(ui32Src2					<< EURASIA_PDS_LOGIC_SRC2_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeSHL
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the SHL instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeSHL)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeSHL	(IMG_UINT32	ui32CC,
									 IMG_UINT32	ui32DestSel,
									 IMG_UINT32	ui32Dest,
									 IMG_UINT32	ui32SrcSel,
									 IMG_UINT32	ui32Src,
									 IMG_UINT32	ui32Shift)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_SHL		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_SHIFT_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_SHIFT_DEST_SHIFT)	|
			(ui32SrcSel					<< EURASIA_PDS_SHIFT_SRCSEL_SHIFT)	|
			(ui32Src					<< EURASIA_PDS_SHIFT_SRC_SHIFT)		|
			(ui32Shift					<< EURASIA_PDS_SHIFT_SHIFT_SHIFT);
}

/*****************************************************************************
 Function Name	: PDSEncodeSHR
 Inputs			: ui32CC, ui32Dest, ...		- the instruction fields
 Outputs		: none
 Returns		: ui32Inst				- the encoded instruction
 Description	: Encodes the SHR instruction
*****************************************************************************/
#ifdef INLINE_IS_PRAGMA
#pragma inline(PDSEncodeSHR)
#endif
FORCE_INLINE IMG_UINT32 PDSEncodeSHR	(IMG_UINT32	ui32CC,
									 IMG_UINT32	ui32DestSel,
									 IMG_UINT32	ui32Dest,
									 IMG_UINT32	ui32SrcSel,
									 IMG_UINT32	ui32Src,
									 IMG_UINT32	ui32Shift)
{
	return	(EURASIA_PDS_INST_LOGIC		<< EURASIA_PDS_INST_SHIFT)			|
			(EURASIA_PDS_TYPE_SHR		<< EURASIA_PDS_TYPE_SHIFT)			|
			(ui32CC)														|
			(ui32DestSel				<< EURASIA_PDS_SHIFT_DESTSEL_SHIFT)	|
			(ui32Dest					<< EURASIA_PDS_SHIFT_DEST_SHIFT)	|
			(ui32SrcSel					<< EURASIA_PDS_SHIFT_SRCSEL_SHIFT)	|
			(ui32Src					<< EURASIA_PDS_SHIFT_SRC_SHIFT)		|
			(ui32Shift					<< EURASIA_PDS_SHIFT_SHIFT_SHIFT);
}

#endif /* _SGXPDSDEFS_H_ */

/******************************************************************************
 End of file (sgxpdsdefs.h)
******************************************************************************/
