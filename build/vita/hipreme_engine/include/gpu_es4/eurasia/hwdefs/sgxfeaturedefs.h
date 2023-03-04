/******************************************************************************
 * Name         : sgxfeaturedefs.h
 * Title        : SGX fexture definitions
 *
 * Copyright    : 2006-2010 by Imagination Technologies Limited.
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
 * $Log: sgxfeaturedefs.h $
 *  .
 *  --- Revision Logs Removed --- 
 *****************************************************************************/

/*
	The following features are defined:-

	SGX_FEATURE_EXTENDED_USE_ALU

	Extended ALU with support for C10, F16 and for less bank restrictions on
	internal registers.

	SGX_FEATURE_UNIFIED_TEMPS_AND_PAS

	USE temporary and primary attributes are allocated as a single block.

	SGX_FEATURE_CEM_S_USES_PROJ

	For CEM textures S needs to be iterated as the projection cordinate.

	SGX_FEATURE_HOST_PORT

	A host port is supported.

	SGX_FEATURE_GAMMACORRECT_TEXTURES

	Gamma correction is supported on texture reads.

	SGX_FEATURE_VOLUME_TEXTURES

	Volume textures are supported.

	SGX_FEATURE_BARTLETTFILTER

	Barlett filtering is supported on PBE downscale.

	SGX_FEATURE_EDM_VERTEX_PDSADDR_FULL_RANGE

	EDM and vertex PDS program base addresses have full range.

	SGX_FEATURE_HOST_ALLOC_FROM_DPM

	The host can allocate memory from the DPM parameter buffer.

	SGX_FEATURE_MULTIPLE_MEM_CONTEXTS

	Multiple simultaneously address spaces are supported.
*/

#if defined(SGX520)
	#define SGX_CORE_FRIENDLY_NAME							"SGX520"
	#define SGX_CORE_ID										SGX_CORE_ID_520
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_USE_HIGH_PRECISION_FIR
	#define SGX_FEATURE_USE_LOAD_MOE_FROM_REGISTERS
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_USE_NO_INSTRUCTION_PAIRING
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(8)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(8)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(12)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(5)
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x04000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(28)
	#define SGX_FEATURE_NUM_USE_PIPES						(1)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(19)
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#if defined (USE_SGX_CORE_REV_HEAD)
		#define SGX_FEATURE_ALPHATEST_COEFREORDER
		#define SGX_FEATURE_ZLS_EXTERNALZ
	#endif
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#define SGX_FEATURE_SW_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_UNPACKED_DPM_STATE
	#define SGX_FEATURE_TAG_POT_TWIDDLE

	#if (SGX_CORE_REV == 111) || defined (USE_SGX_CORE_REV_HEAD)
		#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#endif

#else
#if defined(SGX530)
	#define SGX_CORE_FRIENDLY_NAME							"SGX530"
	#define SGX_CORE_ID										SGX_CORE_ID_530
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(12)
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x04000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(28)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(5)
	#define SGX_FEATURE_NUM_USE_PIPES						(2)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(19)
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#if (SGX_CORE_REV == 103) || (SGX_CORE_REV == 110)
		#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_32
	#else
		#if (SGX_CORE_REV == 111) || (SGX_CORE_REV == 1111)
			#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_16_THEN_32
		#else
			#if (SGX_CORE_REV == 120) || (SGX_CORE_REV == 121) || (SGX_CORE_REV == 125) || (SGX_CORE_REV == 130) || defined (USE_SGX_CORE_REV_HEAD)
				#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
				#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
			#endif
		#endif
	#endif
	#if (SGX_CORE_REV == 125)
		#define SGX_FEATURE_TEXTURE_32K_STRIDE
		#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
	#else
		#if (SGX_CORE_REV == 130) || defined (USE_SGX_CORE_REV_HEAD)
			#define SGX_FEATURE_TEXTURE_32K_STRIDE
			#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
			#define SGX_FEATURE_ALPHATEST_SECONDARY
			#define SGX_FEATURE_ALPHATEST_COEFREORDER
			#define SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE
		#endif
	#endif
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#define SGX_FEATURE_SW_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_TAG_POT_TWIDDLE
#else
#if defined(SGX531)
	#define SGX_CORE_FRIENDLY_NAME							"SGX531"
	#define SGX_CORE_ID										SGX_CORE_ID_531
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(12)
	#define SGX_FEATURE_USE_NORMALISE
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x04000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(28)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(5)
	#define SGX_FEATURE_NUM_USE_PIPES						(2)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#define SGX_FEATURE_PDS_DATA_INTERLEAVE_2DWORDS
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
	#define SGX_FEATURE_TEXTURE_32K_STRIDE
	#define SGX_FEATURE_TAG_POT_TWIDDLE
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(19)
    #define SGX_FEATURE_ALPHATEST_SECONDARY
	#define SGX_FEATURE_ALPHATEST_COEFREORDER
	#define SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE
	#define SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF
	#define SGX_FEATURE_ZLS_EXTERNALZ
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#define SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#define SGX_FEATURE_SW_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_MULTI_EVENT_KICK
#else
#if defined(SGX535)
	#define SGX_CORE_FRIENDLY_NAME							"SGX535"
	#define SGX_CORE_ID										SGX_CORE_ID_535
	#define SGX_FEATURE_GAMMACORRECT_TEXTURES
	#define SGX_FEATURE_VOLUME_TEXTURES
	#define SGX_FEATURE_BARTLETTFILTER
	#define SGX_FEATURE_EDM_VERTEX_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_HOST_ALLOC_FROM_DPM
	#define SGX_FEATURE_MULTIPLE_MEM_CONTEXTS
	#define SGX_FEATURE_BIF_NUM_DIRLISTS					(16)
	#define SGX_FEATURE_F16_TEXTURE_FILTERING
	#define SGX_FEATURE_2D_HARDWARE
	#if !defined(SUPPORT_SGX_GENERAL_MAPPING_HEAP)
	#define SUPPORT_SGX_GENERAL_MAPPING_HEAP
	#endif
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(12)
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x10000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(32)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(4)
	#define SGX_FEATURE_NUM_USE_PIPES						(2)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(23)
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#if defined (USE_SGX_CORE_REV_HEAD)
		#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
        #define SGX_FEATURE_ALPHATEST_SECONDARY
		#define SGX_FEATURE_ALPHATEST_COEFREORDER
		#define SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE
	#else
		#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_32
	#endif
	#if defined (USE_SGX_CORE_REV_HEAD) || (SGX_CORE_REV == 121)
		#define SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#endif
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#define SGX_FEATURE_SW_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_TAG_POT_TWIDDLE
	#define SGX_FEATURE_USE_NUMBER_PIXEL_OUTPUT_PARTITIONS	(6)
#else
#if defined(SGX540)
	#define SGX_CORE_FRIENDLY_NAME							"SGX540"
	#define SGX_CORE_ID										SGX_CORE_ID_540
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(12)
	#define SGX_FEATURE_USE_NORMALISE
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x04000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(28)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(5)
	#define SGX_FEATURE_NUM_USE_PIPES						(4)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#define SGX_FEATURE_PDS_DATA_INTERLEAVE_2DWORDS
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
	#define SGX_FEATURE_TEXTURE_32K_STRIDE
	#define SGX_FEATURE_TAG_POT_TWIDDLE
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(19)
    #define SGX_FEATURE_ALPHATEST_SECONDARY
	#define SGX_FEATURE_ALPHATEST_COEFREORDER
	#define SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE
	#define SGX_FEATURE_USE_HIGH_PRECISION_FIR_COEFF
	#define SGX_FEATURE_ZLS_EXTERNALZ
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#define SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#define SGX_FEATURE_SW_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_MULTI_EVENT_KICK
	#define SGX_FEATURE_USE_NUMBER_PIXEL_OUTPUT_PARTITIONS	(6)
#else
#if defined(SGX543)
	#define SGX_CORE_FRIENDLY_NAME							"SGX543"
	#define SGX_CORE_ID										SGX_CORE_ID_543
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NO_INSTRUCTION_PAIRING
	#define SGX_FEATURE_USE_UNLIMITED_PHASES
	#define SGX_FEATURE_USE_BITWISE_NO_REPEAT_MASK
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(20)
	#define SGX_FEATURE_USE_SA_COUNT_REGISTER
	#define SGX_FEATURE_MULTIPLE_MEM_CONTEXTS
	#define SGX_FEATURE_BIF_NUM_DIRLISTS					(8)
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x10000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(32)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(3)
	#define SGX_FEATURE_NUM_USE_PIPES						(4)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_MULTISAMPLE_2X
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#define SGX_FEATURE_PDS_DATA_INTERLEAVE_2DWORDS
	#define SGX_FEATURE_PDS_EXTENDED_SOURCES
	#define SGX_FEATURE_TAG_UNPACK_RESULT
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
	#define SGX_FEATURE_TEXTURE_32K_STRIDE
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(23)
	#define SGX_FEATURE_MONOLITHIC_UKERNEL
	#define SGX_FEATURE_ZLS_EXTERNALZ
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#define SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#if defined(SGX_FEATURE_MP)
		#define SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH
		#endif
		#define SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_MTE_STATE_FLUSH
	#define SGX_FEATURE_USE_LDST_EXTENDED_CACHE_MODES
	#define SGX_FEATURE_USE_SMP_REDUCEDREPEATCOUNT
	#define SGX_FEATURE_USE_32BIT_INT_MAD
	#define SGX_FEATURE_USE_IMA32_32X16_PLUS_32
	#define SGX_FEATURE_MULTI_EVENT_KICK
	#define SGX_FEATURE_UNIFIED_STORE_64BITS
	#define SGX_FEATURE_USE_VEC34
	#define SGX_FEATURE_EDM_VERTEX_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_PIXEL_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_PBE_GAMMACORRECTION
	#define SGX_FEATURE_GAMMACORRECT_TEXTURES
	#define SGX_FEATURE_TAG_GAMMA_UNPACK_TO_F16
	#define SGX_FEATURE_ALPHATEST_AUTO_COEFF
	#define SGX_FEATURE_PLANAR_YUV
	#define SGX_FEATURE_F16_TEXTURE_FILTERING
	#define SGX_FEATURE_TAG_YUV_TO_RGB
	#define SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC
	#define SGX_FEATURE_TAG_LUMINANCE_ALPHA
	#define SGX_FEATURE_MSAA_2X_IN_Y
	#define SGX_FEATURE_DATA_BREAKPOINTS
    #define SGX_FEATURE_PERPIPE_BKPT_REGS
    #define SGX_FEATURE_PERPIPE_BKPT_REGS_NUMPIPES          (2)
	#define SGX_FEATURE_PERLAYER_POINTCOORD
	#define SGX_FEATURE_TAG_MINLOD
	#define SGX_FEATURE_TAG_SWIZZLE
	#define SGX_FEATURE_TAG_NPOT_TWIDDLE
	#define SGX_FEATURE_TAG_POT_TWIDDLE
	#define	SGX_FEATURE_VISTEST_IN_MEMORY
	#define SGX_FEATURE_CEM_FACE_PACKING
	#define SGX_FEATURE_2D_HARDWARE
	#define SGX_FEATURE_PTLA
	#define SGX_FEATURE_MK_SUPERVISOR	
	#define SGX_FEATURE_USE_SPRVV
	#define SGX_FEATURE_GLOBAL_REGISTER_MONITORING
	#define SGX_FEATURE_EXTENDED_PERF_COUNTERS
	#define SGX_FEATURE_USE_BRANCH_EXTSYNCEND
	#define SGX_FEATURE_USE_BRANCH_EXCEPTION
	#define SGX_FEATURE_USE_SMP_RESULT_FORMAT_CONVERT
	#define SGX_FEATURE_USE_IDXSC
	#define SGX_FEATURE_MSAA_5POSITIONS
	#define SGX_FEATURE_DITHERING_RGB_INDEPENTLY
#else
#if defined(SGX544)
	#define SGX_CORE_FRIENDLY_NAME							"SGX544"
	#define SGX_CORE_ID										SGX_CORE_ID_544
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NO_INSTRUCTION_PAIRING
	#define SGX_FEATURE_USE_UNLIMITED_PHASES
	#define SGX_FEATURE_USE_BITWISE_NO_REPEAT_MASK
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(20)
	#define SGX_FEATURE_USE_SA_COUNT_REGISTER
	#define SGX_FEATURE_MULTIPLE_MEM_CONTEXTS
	#define SGX_FEATURE_BIF_NUM_DIRLISTS					(8)
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x10000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(32)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(3)
	#define SGX_FEATURE_NUM_USE_PIPES						(4)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_MULTISAMPLE_2X
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#define SGX_FEATURE_PDS_DATA_INTERLEAVE_2DWORDS
	#define SGX_FEATURE_PDS_EXTENDED_SOURCES
	#define SGX_FEATURE_TAG_UNPACK_RESULT
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
	#define SGX_FEATURE_TEXTURE_32K_STRIDE
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(23)
	#define SGX_FEATURE_MONOLITHIC_UKERNEL
	#define SGX_FEATURE_ZLS_EXTERNALZ
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#define SGX_FEATURE_USE_NUMBER_PIXEL_OUTPUT_PARTITIONS	(12)
	#define SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#if defined(SGX_FEATURE_MP)
		#define SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH		
		#define SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH
		#else
		#define SGX_FEATURE_SW_VDM_CONTEXT_SWITCH
		#endif
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_MTE_STATE_FLUSH
	#define SGX_FEATURE_USE_LDST_EXTENDED_CACHE_MODES
	#define SGX_FEATURE_USE_SMP_REDUCEDREPEATCOUNT
	#define SGX_FEATURE_USE_32BIT_INT_MAD
	#define SGX_FEATURE_USE_IMA32_32X16_PLUS_32
	#define SGX_FEATURE_MULTI_EVENT_KICK
	#define SGX_FEATURE_UNIFIED_STORE_64BITS
	#define SGX_FEATURE_USE_VEC34
	#define SGX_FEATURE_EDM_VERTEX_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_PIXEL_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_PBE_GAMMACORRECTION
	#define SGX_FEATURE_GAMMACORRECT_TEXTURES
	#define SGX_FEATURE_TAG_GAMMA_UNPACK_TO_F16
	#define SGX_FEATURE_ALPHATEST_AUTO_COEFF
	#define SGX_FEATURE_PLANAR_YUV
	#define SGX_FEATURE_4K_PLANAR_YUV
	#define SGX_FEATURE_F16_TEXTURE_FILTERING
	#define SGX_FEATURE_TAG_YUV_TO_RGB
	#define SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC
	#define SGX_FEATURE_TAG_LUMINANCE_ALPHA
	#define SGX_FEATURE_MSAA_2X_IN_Y
// FIXME: re-enable data breakpoints when tested	
//	#define SGX_FEATURE_DATA_BREAKPOINTS
//   #define SGX_FEATURE_PERPIPE_BKPT_REGS
//    #define SGX_FEATURE_PERPIPE_BKPT_REGS_NUMPIPES          (2)
	#define SGX_FEATURE_PERLAYER_POINTCOORD
	#define SGX_FEATURE_TAG_MINLOD
	#define SGX_FEATURE_TAG_SWIZZLE
	#define SGX_FEATURE_TAG_NPOT_TWIDDLE
	#define SGX_FEATURE_TAG_LUMAKEY
	#define SGX_FEATURE_TAG_FRACTIONAL_LODCLAMP
	#define SGX_FEATURE_8BIT_DADJUST
	#define SGX_FEATURE_VOLUME_TEXTURES
	#define	SGX_FEATURE_VISTEST_IN_MEMORY
	#define SGX_FEATURE_CEM_FACE_PACKING
//	#define SGX_FEATURE_2D_HARDWARE
//	#define SGX_FEATURE_PTLA
	#define SGX_FEATURE_MK_SUPERVISOR	
	#define SGX_FEATURE_USE_SPRVV
	#define SGX_FEATURE_GLOBAL_REGISTER_MONITORING
	#define SGX_FEATURE_EXTENDED_PERF_COUNTERS
	#define SGX_FEATURE_USE_BRANCH_EXTSYNCEND
	#define SGX_FEATURE_USE_BRANCH_EXCEPTION
	#define SGX_FEATURE_USE_SMP_RESULT_FORMAT_CONVERT
	#define SGX_FEATURE_USE_IDXSC
	#define SGX_FEATURE_MSAA_5POSITIONS
	#define SGX_FEATURE_DITHERING_RGB_INDEPENTLY
#else
#if defined(SGX545)
	#define SGX_CORE_FRIENDLY_NAME							"SGX545"
	#define SGX_CORE_ID										SGX_CORE_ID_545
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_USE_PER_INST_MOE_INCREMENTS
	#define SGX_FEATURE_USE_FCLAMP
	#define SGX_FEATURE_USE_SQRT_SIN_COS
	#define SGX_FEATURE_USE_32BIT_INT_MAD
	#define SGX_FEATURE_USE_INT_DIV
	#define SGX_FEATURE_USE_DUAL_ISSUE
	#define SGX_FEATURE_USE_EXTENDED_LOAD
	#define SGX_FEATURE_USE_NEW_EFO_OPTIONS
	#define SGX_FEATURE_USE_PACK_MULTIPLE_ROUNDING_MODES
	#define SGX_FEATURE_USE_NO_INSTRUCTION_PAIRING
	#define SGX_FEATURE_USE_UNLIMITED_PHASES
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(8)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(16)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(18)
	#define SGX_FEATURE_USE_ALPHATOCOVERAGE
	#define SGX_FEATURE_USE_FMAD16_SWIZZLES
	#define SGX_FEATURE_GAMMACORRECT_TEXTURES
	#define SGX_FEATURE_VOLUME_TEXTURES
	#define SGX_FEATURE_EDM_VERTEX_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_HOST_ALLOC_FROM_DPM
	#define SGX_FEATURE_F16_TEXTURE_FILTERING
	#define SGX_FEATURE_F32_TEXTURE_FILTERING
	#define SGX_FEATURE_MULTIPLE_MEM_CONTEXTS
	#define SGX_FEATURE_BIF_NUM_DIRLISTS					(16)
	#define SGX_FEATURE_TAG_UNPACK_RESULT
	#define SGX_FEATURE_TAG_PCF
	#define SGX_FEATURE_TAG_RAWSAMPLE
	#define SGX_FEATURE_TAG_YUV_TO_RGB
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x10000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(32)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(4)
	#define SGX_FEATURE_NUM_USE_PIPES						(4)
	#define SGX_FEATURE_USE_NUMBER_PIXEL_OUTPUT_PARTITIONS	(24)
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#define SGX_FEATURE_PDS_DATA_INTERLEAVE_2DWORDS
	#define SGX_FEATURE_PDS_LOAD_STORE
	#define SGX_FEATURE_VCB
	#define SGX_FEATURE_MULTISAMPLE_2X
	#define SGX_FEATURE_HYBRID_TWIDDLING
	#define SGX_FEATURE_MONOLITHIC_UKERNEL
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(23)
	#define SGX_FEATURE_ZLS_EXTERNALZ
	#define SGX_FEATURE_CONVOLUTION_FILTERING
	#define SGX_FEATURE_HW_LINESTRIPS
	#define SGX_FEATURE_MULTISAMPLE_TEXTURES
	#define	SGX_FEATURE_CULL_PLANES
	#define SGX_FEATURE_1D_TEXTURES
	#define SGX_FEATURE_PLANAR_YUV
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_ISP_BREAKPOINT_RESUME_REV_2
	#define SGX_FEATURE_NUM_PDS_PIPES						(2)
	#define SGX_FEATURE_NATIVE_BACKWARD_BLIT
	#define SGX_FEATURE_TAG_GAMMA_UNPACK_TO_F16
	#define SGX_FEATURE_RENDER_TARGET_ARRAYS
	#define SGX_FEATURE_MAX_TA_RENDER_TARGETS				(512)
	#define SGX_FEATURE_GAMMACORRECT_YUV_TEXTURES
	#define SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK
	#define SGX_FEATURE_WRITEBACK_DCU
	#define SGX_FEATURE_NONPERSPECTIVE_CLIPPING
	#define SGX_FEATURE_COMPLEX_GEOMETRY_REV_2
	#define SGX_FEATURE_MTE_STATE_FLUSH
	#define SGX_FEATURE_USE_LDST_EXTENDED_CACHE_MODES
	#define SGX_FEATURE_USE_SMP_REDUCEDREPEATCOUNT
	#define SGX_FEATURE_MULTI_EVENT_KICK
	#define SGX_FEATURE_PBE_GAMMACORRECTION
	#define SGX_FEATURE_PDS_EXTENDED_INPUT_REGISTERS
	//FIXME: this is defined in the build config for now
	//#define SGX_FEATURE_36BIT_MMU
	#define SGX_FEATURE_BIF_WIDE_TILING_AND_4K_ADDRESS
	#define SGX_FEATURE_SAMPLE_INFO_BYPASS_TPU_FILTER
	#define SGX_FEATURE_MSAA_2X_IN_X
	#define SGX_FEATURE_DEPTH_BIAS_OBJECTS
	#define SGX_FEATURE_STREAM_OUTPUT
	#define SGX_FEATURE_TAG_MINLOD
	#define SGX_FEATURE_8BIT_DADJUST
	#define SGX_FEATURE_BUFFER_LOAD
	#define SGX_FEATURE_CEM_FACE_PACKING
	#define SGX_FEATURE_PERLAYER_POINTCOORD
	#define SGX_FEATURE_U24_TEXTURE_FILTERING
	#define SGX_FEATURE_GLOBAL_REGISTER_MONITORING
	#define SGX_FEATURE_ALPHATEST_SECONDARY
	#define SGX_FEATURE_ALPHATEST_COEFREORDER
	#define	SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE
	#define SGX_FEATURE_TAG_LUMINANCE_ALPHA
	#define SGX_FEATURE_TAG_LUMAKEY
	#define SGX_FEATURE_USE_BRANCH_EXTSYNCEND
	#define SGX_FEATURE_USE_BRANCH_EXCEPTION
	#define SGX_FEATURE_8K_SURFACES
	#define SGX_FEATURE_USE_SAMPLE_NUMBER_SPECIAL_REGISTER
	#define SGX_FEATURE_DITHERING_RGB_INDEPENTLY
#else
#if defined(SGX554)
	#define SGX_CORE_FRIENDLY_NAME							"SGX554"
	#define SGX_CORE_ID										SGX_CORE_ID_554
	#define SGX_FEATURE_EXTENDED_USE_ALU
	#define SGX_FEATURE_UNIFIED_TEMPS_AND_PAS
	#define SGX_FEATURE_CEM_S_USES_PROJ
	#define SGX_FEATURE_USE_NO_INSTRUCTION_PAIRING
	#define SGX_FEATURE_USE_UNLIMITED_PHASES
	#define SGX_FEATURE_USE_BITWISE_NO_REPEAT_MASK
	#define SGX_FEATURE_USE_NUMBER_OF_MUTEXES				(1)
	#define SGX_FEATURE_USE_NUMBER_OF_MONITORS				(0)
	#define SGX_FEATURE_USE_NUMBER_PC_BITS					(20)
	#define SGX_FEATURE_USE_SA_COUNT_REGISTER
	#define SGX_FEATURE_MULTIPLE_MEM_CONTEXTS
	#define SGX_FEATURE_BIF_NUM_DIRLISTS					(8)
	#define SGX_FEATURE_PARAMETER_BUFFER_SIZE				(0x10000000)
	#define SGX_FEATURE_ADDRESS_SPACE_SIZE					(32)
	#define SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS		(3)
	#define SGX_FEATURE_NUM_USE_PIPES						(8)
	#define SGX_FEATURE_AUTOCLOCKGATING
	#define SGX_FEATURE_MULTISAMPLE_2X
	#define SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8
	#define	SGX_FEATURE_TEXTURESTRIDE_EXTENSION
	#define SGX_FEATURE_PDS_DATA_INTERLEAVE_2DWORDS
	#define SGX_FEATURE_PDS_EXTENDED_SOURCES
	#define SGX_FEATURE_TAG_UNPACK_RESULT
	#define SGX_FEATURE_VERTEXDM_PIXELEMITS
	#define SGX_FEATURE_PIXELBE_32K_LINESTRIDE
	#define SGX_FEATURE_TEXTURE_32K_STRIDE
	#define SGX_FEATURE_DEPTH_MANTISSA_BITS					(23)
	#define SGX_FEATURE_MONOLITHIC_UKERNEL
	#define SGX_FEATURE_ZLS_EXTERNALZ
	#define SGX_FEATURE_NUM_PDS_PIPES						(1)
	#define SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK
	#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING)
		#if defined(SGX_FEATURE_MP)
		#define SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH
		#endif
		#define SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH
		#define SGX_FEATURE_SW_ISP_CONTEXT_SWITCH
	#endif
	#define SGX_FEATURE_MTE_STATE_FLUSH
	#define SGX_FEATURE_USE_LDST_EXTENDED_CACHE_MODES
	#define SGX_FEATURE_USE_SMP_REDUCEDREPEATCOUNT
	#define SGX_FEATURE_USE_32BIT_INT_MAD
	#define SGX_FEATURE_USE_IMA32_32X16_PLUS_32
	#define SGX_FEATURE_MULTI_EVENT_KICK
	#define SGX_FEATURE_UNIFIED_STORE_64BITS
	#define SGX_FEATURE_USE_VEC34
	#define SGX_FEATURE_EDM_VERTEX_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_PIXEL_PDSADDR_FULL_RANGE
	#define SGX_FEATURE_PBE_GAMMACORRECTION
	#define SGX_FEATURE_GAMMACORRECT_TEXTURES
	#define SGX_FEATURE_TAG_GAMMA_UNPACK_TO_F16
	#define SGX_FEATURE_ALPHATEST_AUTO_COEFF
	#define SGX_FEATURE_PLANAR_YUV
	#define SGX_FEATURE_4K_PLANAR_YUV
	#define SGX_FEATURE_F16_TEXTURE_FILTERING
	#define SGX_FEATURE_TAG_YUV_TO_RGB
	#define SGX_FEATURE_TAG_YUV_TO_RGB_HIPREC
	#define SGX_FEATURE_TAG_LUMINANCE_ALPHA
	#define SGX_FEATURE_MSAA_2X_IN_Y
// FIXME: re-enable data breakpoints when tested	
//	#define SGX_FEATURE_DATA_BREAKPOINTS
//    #define SGX_FEATURE_PERPIPE_BKPT_REGS
//    #define SGX_FEATURE_PERPIPE_BKPT_REGS_NUMPIPES          (2)
	#define SGX_FEATURE_PERLAYER_POINTCOORD
	#define SGX_FEATURE_TAG_MINLOD
	#define SGX_FEATURE_TAG_SWIZZLE
	#define SGX_FEATURE_TAG_NPOT_TWIDDLE
	#define SGX_FEATURE_TAG_LUMAKEY
	#define SGX_FEATURE_TAG_FRACTIONAL_LODCLAMP
	#define SGX_FEATURE_8BIT_DADJUST
	#define SGX_FEATURE_VOLUME_TEXTURES
	#define	SGX_FEATURE_VISTEST_IN_MEMORY
	#define SGX_FEATURE_CEM_FACE_PACKING
	#define SGX_FEATURE_2D_HARDWARE
	#define SGX_FEATURE_PTLA
	#define SGX_FEATURE_MK_SUPERVISOR	
	#define SGX_FEATURE_USE_SPRVV
	#define SGX_FEATURE_GLOBAL_REGISTER_MONITORING
	#define SGX_FEATURE_EXTENDED_PERF_COUNTERS
	#define SGX_FEATURE_USE_BRANCH_EXTSYNCEND
	#define SGX_FEATURE_USE_BRANCH_EXCEPTION
	#define SGX_FEATURE_USE_SMP_RESULT_FORMAT_CONVERT
	#define SGX_FEATURE_USE_IDXSC
	#define SGX_FEATURE_DITHERING_RGB_INDEPENTLY
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif

#if defined(SGX_FEATURE_SLAVE_VDM_CONTEXT_SWITCH) \
	|| defined(SGX_FEATURE_MASTER_VDM_CONTEXT_SWITCH)
/* Enable the define so common code for HW VDMCS code is compiled */
#define SGX_FEATURE_VDM_CONTEXT_SWITCH
#endif


/*
	'switch-off' features if defined BRNs affect the feature
*/
#if defined(FIX_HW_BRN_22693)	\
	|| defined(FIX_HW_BRN_24435)	\
	|| defined(FIX_HW_BRN_26711)
#undef SGX_FEATURE_AUTOCLOCKGATING
#endif

#if defined(FIX_HW_BRN_26656)
#undef SGX_FEATURE_MTE_STATE_FLUSH
#endif

#if defined(FIX_HW_BRN_22997) || defined(FIX_HW_BRN_22634)
#undef SGX_FEATURE_MULTITHREADED_UKERNEL
#endif

#if defined(FIX_HW_BRN_23054) || defined(FIX_HW_BRN_25941) || defined(FIX_HW_BRN_26336)
#undef SGX_FEATURE_VERTEXDM_PIXELEMITS
#endif

#if defined(FIX_HW_BRN_24281)
#undef SGX_FEATURE_ALPHATEST_SECONDARY
#undef SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE
#endif

#if defined(FIX_HW_BRN_25089)
#undef SGX_FEATURE_ALPHATEST_COEFREORDER
#endif

#if defined(FIX_HW_BRN_27266)
#undef SGX_FEATURE_36BIT_MMU
#endif

#if defined(FIX_HW_BRN_27456)
#undef SGX_FEATURE_BIF_WIDE_TILING_AND_4K_ADDRESS
#endif

#if defined(FIX_HW_BRN_22934)	\
	|| defined(FIX_HW_BRN_25499)
#undef SGX_FEATURE_MULTI_EVENT_KICK
#endif

#if defined(SGX_FEATURE_SYSTEM_CACHE)
	#if defined(SGX_FEATURE_36BIT_MMU)
		#error SGX_FEATURE_SYSTEM_CACHE is incompatible with SGX_FEATURE_36BIT_MMU
	#endif
	#if !defined(SGX_BYPASS_SYSTEM_CACHE) && defined(FIX_HW_BRN_26620) && !defined(SGX_FEATURE_MULTI_EVENT_KICK)
		#define SGX_BYPASS_SYSTEM_CACHE
	#endif
#endif

#if defined(FIX_HW_BRN_27792)
#undef SGX_FEATURE_DEPTH_BIAS_OBJECTS
#endif

#if defined(FIX_HW_BRN_27707)
#undef SGX_FEATURE_STREAM_OUTPUT
#endif

#if defined(FIX_HW_BRN_27907)
#undef SGX_FEATURE_TAG_MINLOD
#endif

#if defined(FIX_HW_BRN_27906)
#undef SGX_FEATURE_8BIT_DADJUST
#endif

#if defined(FIX_HW_BRN_27904)
#undef SGX_FEATURE_BUFFER_LOAD
#endif

#if defined(FIX_HW_BRN_27986)
#undef SGX_FEATURE_CEM_FACE_PACKING
#endif

#if defined(FIX_HW_BRN_29954)
#undef SGX_FEATURE_PERPIPE_BKPT_REGS
#endif

#if defined(FIX_HW_BRN_30201)
#undef SGX_FEATURE_MSAA_5POSITIONS
#endif

#if defined(FIX_HW_BRN_31620)
#undef SGX_FEATURE_MULTIPLE_MEM_CONTEXTS
#undef SGX_FEATURE_BIF_NUM_DIRLISTS
#endif


/*
	Derive other definitions:
*/

/* define default MP core count */
#if defined(SGX_FEATURE_MP)
#if defined(SGX_FEATURE_MP_CORE_COUNT_TA) && defined(SGX_FEATURE_MP_CORE_COUNT_3D)
#if (SGX_FEATURE_MP_CORE_COUNT_TA > SGX_FEATURE_MP_CORE_COUNT_3D)
#error Number of TA cores larger than number of 3D cores not supported in current driver
#endif /* (SGX_FEATURE_MP_CORE_COUNT_TA > SGX_FEATURE_MP_CORE_COUNT_3D) */
#else
#if defined(SGX_FEATURE_MP_CORE_COUNT)
#define SGX_FEATURE_MP_CORE_COUNT_TA		(SGX_FEATURE_MP_CORE_COUNT)
#define SGX_FEATURE_MP_CORE_COUNT_3D		(SGX_FEATURE_MP_CORE_COUNT)
#else
#error Either SGX_FEATURE_MP_CORE_COUNT or \
both SGX_FEATURE_MP_CORE_COUNT_TA and SGX_FEATURE_MP_CORE_COUNT_3D \
must be defined when SGX_FEATURE_MP is defined
#endif /* SGX_FEATURE_MP_CORE_COUNT */
#endif /* defined(SGX_FEATURE_MP_CORE_COUNT_TA) && defined(SGX_FEATURE_MP_CORE_COUNT_3D) */
#else
#define SGX_FEATURE_MP_CORE_COUNT		(1)
#define SGX_FEATURE_MP_CORE_COUNT_TA	(1)
#define SGX_FEATURE_MP_CORE_COUNT_3D	(1)
#endif /* SGX_FEATURE_MP */

#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && !defined(SUPPORT_SGX_PRIORITY_SCHEDULING)
#define SUPPORT_SGX_PRIORITY_SCHEDULING
#endif

#include "img_types.h"

#include "sgxcoretypes.h"

/*
	Code including this file can request a table mapping core IDs to
	the features that are supported so they can support multiple
	cores in one binary.
*/
#if defined(INCLUDE_SGX_FEATURE_TABLE)

#define SGX_FEATURE_FLAGS_USE_NO_INSTRUCTION_PAIRING	(0x00000001)

/*
	Set if this core supports the FIRHH, FIRVH and SSUM16 instructions.
*/
#define SGX_FEATURE_FLAGS_USE_HIGH_PRECISION_FIR		(0x00000002)

/*
	Set if this core supports setting the MOE state from non-immediate
	data.
*/
#define SGX_FEATURE_FLAGS_USE_LOAD_MOE_FROM_REGISTERS	(0x00000004)

/*
	Set if this core supports encoding the MOE increments directly
	into the repeated instruction (rather than setting them using
	an earlier SMLSI instruction).
*/
#define SGX_FEATURE_FLAGS_USE_PER_INST_MOE_INCREMENTS	(0x00000008)

/*
	Set if this core supports the FMINMAX/FMAXMIN instruction.
*/
#define SGX_FEATURE_FLAGS_USE_FCLAMP					(0x00000010)

/*
	Set if this core supports the FSQRT, FSIN and FCOS instructions.
*/
#define SGX_FEATURE_FLAGS_USE_SQRT_SIN_COS				(0x00000020)

/*
	Set if this core supports the IMA32 instruction.
*/
#define SGX_FEATURE_FLAGS_USE_32BIT_INT_MAD				(0x00000040)

/*
	Set if this core supports the IDIV instruction.
*/
#define SGX_FEATURE_FLAGS_USE_INT_DIV					(0x00000080)

/*
	Set if this core supports the dual-issue instruction.
*/
#define SGX_FEATURE_FLAGS_USE_DUAL_ISSUE				(0x00000100)

/*
	Set if this core supports the ELDD/ELDQ instructions.
*/
#define SGX_FEATURE_FLAGS_USE_EXTENDED_LOAD				(0x00000200)

/*
	Set if this core supports a different encoding for the EFO
	instruction.
*/
#define SGX_FEATURE_FLAGS_USE_NEW_EFO_OPTIONS			(0x00000400)

/*
	Set if this core supports choosing different rounding modes
	when using the PCK instruction to convert between floating point
	formats.
*/
#define SGX_FEATURE_FLAGS_USE_PACK_MULTIPLE_ROUNDING_MODES \
														(0x00000800)

/*
	Set if this core supports the PHAS instruction.
*/
#define SGX_FEATURE_FLAGS_USE_UNLIMITED_PHASES			(0x00001000)

/*
	Set if this core supports the MOVMSK instruction.
*/
#define SGX_FEATURE_FLAGS_USE_ALPHATOCOVERAGE			(0x00002000)

/*
	Set if this core allocate temporary registers for an instance
	once. Otherwise temporary registers are reallocated before
	each phase.
*/
#define SGX_FEATURE_FLAGS_USE_UNIFIED_TEMPS_AND_PAS		(0x00004000)

/*
	Set if this core supports a swizzle on the sources to FMAD16.
*/
#define SGX_FEATURE_FLAGS_USE_FMAD16_SWIZZLES			(0x00008000)

/*
	Set if on this core the TAG/TF supports a data conversion on
	the result of a texture sample before the result is written back
	to the USE.
*/
#define SGX_FEATURE_FLAGS_TAG_UNPACK_RESULT				(0x00010000)

/*
	Set if this core supports the FNRM16/FNRM32 instructions.
*/
#define SGX_FEATURE_FLAGS_USE_FNORMALISE				(0x00020000)

/*
	Set if this core supports the .PCF and .PCFF16 flags on the
	SMP instruction.
*/
#define SGX_FEATURE_FLAGS_TAG_PCF						(0x00040000)

/*
	Set if this core supports the .RSD (return sample data) and
	.sinf (return sample information) flags on the SMP instruction.
*/
#define SGX_FEATURE_FLAGS_TAG_RAWSAMPLE					(0x00080000)

/*
	Set if this core supports the .TRIGGER flag on the NOP instruction.
*/
#define SGX_FEATURE_FLAGS_USE_NOPTRIGGER				(0x00100000)

/*
	Set if this core supports the BEXCEPTION instruction.
*/
#define SGX_FEATURE_FLAGS_USE_BRANCH_EXCEPTION			(0x00200000)

/*
	Set if this core supports the .SYNCENT (sync-end when not taken)
	flag on branch instructions.
*/
#define SGX_FEATURE_FLAGS_USE_BRANCH_EXTSYNCEND			(0x00400000)

/*
	Set if this core supports the MOEST instruction.
*/
#define SGX_FEATURE_FLAGS_USE_STORE_MOE_TO_REGISTERS	(0x00800000)

/*
	Set if this core supports the CFI instruction.
*/
#define SGX_FEATURE_FLAGS_USE_CFI						(0x01000000)
#define SGX_FEATURE_FLAGS_VCB							(0x02000000)

/*
	Set if this core reads some of the source argument to LD/ST/SMP
	instructions asynchronously to the USE pipeline.
*/
#define SGX_FEATURE_FLAGS_EXTERNAL_LDST_SMP_UNIT		(0x04000000)

/*
	Set if this core supports the vector floating point instructions.
*/
#define SGX_FEATURE_FLAGS_USE_VEC34						(0x08000000)

/*
	Set if when gamma correction is enabled on a texture sample the
	format of channels in the returned data changes from U8 to F16. Otherwise
	it changes from U8 to U16.
*/
#define SGX_FEATURE_FLAGS_TAG_GAMMA_UNPACK_TO_F16		(0x10000000)

/*
	Set if this core supports the .PWAIT flag on branch instructions.
*/
#define SGX_FEATURE_FLAGS_USE_BRANCH_PWAIT				(0x20000000)

/*
	Set if this core supports SMP/SMPBIAS instructions inside
	dynamic flow control.
*/
#define SGX_FEATURE_FLAGS_TAG_GRAD_SAMPLE_IN_DFC		(0x40000000)

/*
	Set if this core supports the .IRSD (return both sample data
	and sample information) flag on the SMP instruction.
*/
#define SGX_FEATURE_FLAGS_TAG_RAWSAMPLEBOTH				(0x80000000)

/*
	Set if this core only supports a limited repeat count on
	the SMP instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_SMP_REDUCEDREPEATCOUNT	(0x00000001)

/*
	Set if this core supports a QWORD data type for the LD/ST
	instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_LDST_QWORD				(0x00000002)

/*
	Set if this core supports the IDXSCR and IDXSCW instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_IDXSC					(0x00000004)

/*
	Set if this core supports SABLND ALUOP on the TEST instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_TEST_SABLND				(0x00000008)

/*
	Set if this core supports a repeat count on the LDR and STR
	instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_LDRSTR_REPEAT			(0x00000010)

/*
	Set if this core supports a predicate on the STR instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_STR_PREDICATE			(0x00000020)

/*
	Set if this core supports a larger range of immediate values for
	the global register address source to the LDR and STR instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_LDRSTR_EXTENDED_IMMEDIATE	\
														(0x00000040)

/*
	Set if this core encodes the index register select for indexed
	arguments as part of the register bank field.
*/
#define SGX_FEATURE_FLAGS2_USE_TWO_INDEX_BANKS			(0x00000080)

/*
	Set if this core supports the SPRVV instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_SPRVV					(0x00000100)

/*
	Set if this core supports the .bypassl1 flag on memory load and
	store instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_LDST_EXTENDED_CACHE_MODES	\
														(0x00000200)

/*
	Set if this core supports the .NOREAD flag on ST instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_ST_NO_READ_BEFORE_WRITE	\
														(0x00000400)

/*
	Set if this core encodes the TAG/TF output format conversion mode
	directly in the SMP instruction. Otherwise the format conversion mode
	is encoded in the texture sstate.
*/
#define SGX_FEATURE_FLAGS2_USE_SMP_RESULT_FORMAT_CONVERT	\
														(0x00000800)

/*
	Set if on this core the IMA32 does a multiply-add with bit-widths
	32x16+32.
*/
#define SGX_FEATURE_FLAGS2_USE_IMA32_32X16_PLUS_32		(0x00001000)

/*
	Set if on this core the channel order for U8/C10 data is RGBA;
	otherwise the order is BGRA.
*/
#define SGX_FEATURE_FLAGS2_USE_C10U8_CHAN_ORDER_RGBA	(0x00002000)

/*
	Set if this core supports a format conversion to C10 on the
	result of a texture sample.
*/
#define SGX_FEATURE_FLAGS2_TAG_UNPACK_RESULT_TO_C10		(0x00004000)

/*
	Set if this core supports a format conversion to F16 on the
	result of a texture sample.
*/
#define SGX_FEATURE_FLAGS2_TAG_UNPACK_RESULT_TO_F16		(0x00008000)

/*
	Set if this core supports a format conversion to F32 on the
	result of a texture sample.
*/
#define SGX_FEATURE_FLAGS2_TAG_UNPACK_RESULT_TO_F32		(0x00010000)

/*
	Set if this core supports a format conversion to unnormalised
	on the result of a texture sample.
*/
#define SGX_FEATURE_FLAGS2_TAG_UNPACK_RESULT_TO_UNORM	(0x00020000)

/*
	Set if this core supports a format conversion to a lower precision
	than the original format of the result of the texture sample.
*/
#define SGX_FEATURE_FLAGS2_TAG_UNPACK_RESULT_TO_LOWERPREC	\
														(0x00040000)

/*
	Set if this core supports the SUB32/SUBU32 ALUOPs on the TEST
	instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_TEST_SUB32				(0x00080000)

/*
	Set if this core doesn't support a repeat mask on the BITWISE
	instructions.
*/
#define SGX_FEATURE_FLAGS2_USE_BITWISE_NO_REPEAT_MASK	(0x00100000)

/*
	Set if this core doesn't support a repeat mask on the SMP
	instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_SMP_NO_REPEAT_MASK		(0x00200000)

/*	
	Set if this core supports the SKIPINVALID flag on the IDF instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_IDF_SUPPORTS_SKIPINVALID	(0x00400000)

/*
	Set if this core supports the load buffer instruction.
*/
#define SGX_FEATURE_FLAGS2_USE_BUFFER_LOAD				(0x00800000)

/*
	Set if this core supports applying extra, immediate offsets to
	texture coordinates in the TAG on 1D and 2D textures.
*/
#define SGX_FEATURE_FLAGS2_TAG_1D_2D_IMMEDIATE_COORDINATE_OFFSETS \
														(0x01000000)

/*
	Set if this core doesn't support the .IRSD (return both sample data
	and sample information) flag on the SMP instruction.
*/
#define SGX_FEATURE_FLAGS2_TAG_NOT_RAWSAMPLEBOTH		(0x02000000)

/*
	Set if this core supports the .ALLINST/.ANYINST flag on the branch instruction (branch
	if the predicate is true for all/any instances).
*/
#define SGX_FEATURE_FLAGS2_USE_BRANCH_ALL_ANY_INSTANCES	\
														(0x04000000)

/*
	Set if this core supports the integer conditional instructions (CNDST, CNDEF,
	CNDSM, CNDLT, CNDEND).
*/
#define SGX_FEATURE_FLAGS2_USE_INTEGER_CONDITIONALS		(0x08000000)

/*	
	Set if this core supports LD/ST instructions with atomic operations.
*/
#define SGX_FEATURE_FLAGS2_USE_LD_ST_ATOMIC_OPS			(0x10000000)

/*	
	Set if this core supports mixing memory loads and stores to overlapping
	addresses without either bypassing the cache on loads or flushing the
	cache after stores.
*/
#define SGX_FEATURE_FLAGS2_MEMORY_LD_ST_COHERENT		(0x20000000)

/*
	Set if this core supports volume (3D) textures.
*/
#define SGX_FEATURE_FLAGS2_TAG_VOLUME_TEXTURES			(0x40000000)

/*
	Set if this core has a USSE special register containing the MSAA sample
	index of the current instance.
*/
#define SGX_FEATURE_FLAGS2_USE_SAMPLE_NUMBER_SPECIAL_REGISTER	(0x80000000)

#endif /* defined(INCLUDE_SGX_FEATURE_TABLE) */

/******************************************************************************
 End of file (sgxfeaturedefs.h)
******************************************************************************/
