/*************************************************************************/ /*!
@File
@Title          SGX hw definitions
@Copyright      Copyright (c) Imagination Technologies Ltd. All Rights Reserved
@Description    Version numbers and strings for PVR Consumer services
                components.
@License        Strictly Confidential.
*/ /**************************************************************************/

#ifndef _SGXDEFS_H_
#define _SGXDEFS_H_

/*****************************************************************************
 * Include errata first to ensure correct defines within sgx*defs.h
 *****************************************************************************/
#include "sgxerrata.h"
#include "sgxfeaturedefs.h"

#if defined(SGX520)
#include "sgx520defs.h"
#else
#if defined(SGX530)
#include "sgx530defs.h"
#else
#if defined(SGX535)
#include "sgx535defs.h"
#else
#if defined(SGX535_V1_1)
#include "sgx535defs.h"
#else
#if defined(SGX540)
#include "sgx540defs.h"
#else
#if defined(SGX543)
#if defined(FIX_HW_BRN_29954)
/* We need to include an older version of the .h file (generated from
   r1.164 of ares2.def in the RTL repo) for these core revisions */
#include "sgx543_v1.164defs.h"
#else
#include "sgx543defs.h"
#endif /* SGX_CORE_REV == 113 || SGX_CORE_REV == 122 || SGX_CORE_REV == 1221 */
#include "sgx543_debug_defs.h"
#else
#if defined(SGX544)
#include "sgx544defs.h"
#include "sgx544_debug_defs.h"
#else
#if defined(SGX545)
#if SGX_CORE_REV == 100
#include "sgx545_100defs.h"
#else
#include "sgx545defs.h"
#endif
#else
#if defined(SGX531)
#include "sgx531defs.h"
#else
#if defined(SGX554)
#include "sgx554defs.h"
#include "sgx554_debug_defs.h"
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif

#if defined(SGX_FEATURE_MP)
#if defined(SGX554)
#include "sgxmpplusdefs.h"
#else
#include "sgxmpdefs.h"
#endif /* SGX554 */
#if !defined(SGX_FEATURE_SYSTEM_CACHE)
#error "Multiprocessor build with no System Level Cache is not supported"
#endif
#else /* SGX_FEATURE_MP */
#if defined(SGX543)
#error "SGX543 non-multiprocessor build is not supported"
#endif /* SGX543 */
#if defined(SGX_FEATURE_SYSTEM_CACHE)
#include "mnemedefs.h"
#endif
#endif /* SGX_FEATURE_MP */


/*****************************************************************************
 SGX Hardware Builds
 ****************************************************************************/
#if (SGX_CORE_REV == SGX_CORE_REV_HEAD) && !defined(USE_SGX_CORE_REV_HEAD)
	#error "sgxdefs.h: define USE_SGX_CORE_REV_HEAD to use the head core revision"
#endif
#if defined(USE_SGX_CORE_REV_HEAD) && !defined(NO_HARDWARE) && !defined(EMULATOR)
	#error "sgxdefs.h: The SGX_CORE_REV_HEAD revision option is only valid for 'Emulator' or 'No Hardware' builds."
#endif


/*****************************************************************************
 SGX core identifier
 ****************************************************************************/
#if !defined(SGX_MULTI_CORE_BUILD)
#if defined(SGX520)
	#define SGX_CORE_NUM_ID									520
#else
#if defined(SGX530)
	#define SGX_CORE_NUM_ID									530
#else
#if defined(SGX531)
	#define SGX_CORE_NUM_ID									531
#else
#if defined(SGX535)
	#define SGX_CORE_NUM_ID									535
#else
#if defined(SGX540)
	#define SGX_CORE_NUM_ID									540
#else
#if defined(SGX543)
	#define SGX_CORE_NUM_ID									543
#else
#if defined(SGX544)
	#define SGX_CORE_NUM_ID									544
#else
#if defined(SGX545)
	#define SGX_CORE_NUM_ID									545
#else
#if defined(SGX554)
	#define SGX_CORE_NUM_ID									554
#else
	#error "sgxdefs.h: Unknown core type defined."
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif

/*****************************************************************************
 Core rev details
 	Converts SW core revision to internal format
	(as used in the EUR_CR_CORE_REVISION register)
 ****************************************************************************/
#if (SGX_CORE_REV == 100)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	0
#else
#if (SGX_CORE_REV == 101)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	1
#else
#if (SGX_CORE_REV == 102)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	2
#else
#if (SGX_CORE_REV == 103)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	3
#else
#if (SGX_CORE_REV == 105)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	5
#else
#if (SGX_CORE_REV == 106)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	6
#else
#if (SGX_CORE_REV == 109)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	9
#else
#if (SGX_CORE_REV == 1011)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	11
#else
#if (SGX_CORE_REV == 1012)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	12
#else
#if (SGX_CORE_REV == 1013) || (SGX_CORE_REV == 10131)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	13
#else
#if (SGX_CORE_REV == 1014) || (SGX_CORE_REV == 10141)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	14
#else
#if (SGX_CORE_REV == 110)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	0
#else
#if (SGX_CORE_REV == 111) || (SGX_CORE_REV == 1111)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	1
#else
#if (SGX_CORE_REV == 112)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	2
#else
#if (SGX_CORE_REV == 113)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	3
#else
#if (SGX_CORE_REV == 115)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	5
#else
#if (SGX_CORE_REV == 116)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	6
#else
#if (SGX_CORE_REV == 120)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		2
	#define SGX_SW_CORE_REV_MAINT	0
#else
#if (SGX_CORE_REV == 121)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		2
	#define SGX_SW_CORE_REV_MAINT	1
#else
#if (SGX_CORE_REV == 122) || (SGX_CORE_REV == 1221)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		2
	#define SGX_SW_CORE_REV_MAINT	2
#else
#if (SGX_CORE_REV == 125) || (SGX_CORE_REV == 1251)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		2
	#define SGX_SW_CORE_REV_MAINT	5
#else
#if (SGX_CORE_REV == 126)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		2
	#define SGX_SW_CORE_REV_MAINT	6
#else
#if (SGX_CORE_REV == 130)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		3
	#define SGX_SW_CORE_REV_MAINT	0
#else
#if (SGX_CORE_REV == 140) || (SGX_CORE_REV == 1401)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		4
	#define SGX_SW_CORE_REV_MAINT	0
#else
#if (SGX_CORE_REV == 141)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		4
	#define SGX_SW_CORE_REV_MAINT	1
#else
#if (SGX_CORE_REV == 142)
	#define SGX_SW_CORE_REV_MAJ		1
	#define SGX_SW_CORE_REV_MIN		4
	#define SGX_SW_CORE_REV_MAINT	2
#else
#if (SGX_CORE_REV == 211) || (SGX_CORE_REV == 2111)
	#define SGX_SW_CORE_REV_MAJ		2
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	1
#else
#if (SGX_CORE_REV == 213)
	#define SGX_SW_CORE_REV_MAJ		2
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	3
#else
#if (SGX_CORE_REV == 216)
	#define SGX_SW_CORE_REV_MAJ		2
	#define SGX_SW_CORE_REV_MIN		1
	#define SGX_SW_CORE_REV_MAINT	6
#else
#if (SGX_CORE_REV == 302)
	#define SGX_SW_CORE_REV_MAJ		3
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	2
#else
#if (SGX_CORE_REV == 303)
	#define SGX_SW_CORE_REV_MAJ		3
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	3
#else
/* define the _current_ RTL head revision */
#if defined(SGX_CORE_REV_HEAD)
	#define SGX_SW_CORE_REV_MAJ		0
	#define SGX_SW_CORE_REV_MIN		0
	#define SGX_SW_CORE_REV_MAINT	0
#else

#error "sgxdefs.h: SGX_CORE_REV unspecified or not recognised"

#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif /* !defined(SGX_MULTI_CORE_BUILD) */

/*****************************************************************************
 Core specific defines.
*****************************************************************************/

#if defined(SGX545) || defined(SUPPORT_SGX545)
/*****************************************************************************
 545 specific USE defines
*****************************************************************************/
#include "sgx545usedefs.h"

#endif /* defined(SGX545) || defined(SUPPORT_SGX545) */

#if defined(SGX540) || defined(SUPPORT_SGX540) || defined(SGX541) || defined(SUPPORT_SGX541)|| defined(SGX531) || defined(SUPPORT_SGX531)
/*****************************************************************************
 540 specific USE defines
*****************************************************************************/
#include "sgx540usedefs.h"
#endif /* defined(SGX540) || defined(SUPPORT_SGX540) || defined(SGX541) || defined(SUPPORT_SGX541) || defined(SGX531) || defined(SUPPORT_SGX531) */

#if defined(SGX_FEATURE_USE_VEC34) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX554)
/*****************************************************************************
 USE defines for the vector instruction set
*****************************************************************************/
#include "sgxvec34usedefs.h"
#endif /* defined(SGX_FEATURE_USE_VEC34) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX554) */


/*****************************************************************************
 General hardware parameters
*****************************************************************************/

/* MP register control macros */
#if defined(SGX_FEATURE_MP)
	#define SGX_REG_BANK_SHIFT 			(14)
	#define SGX_REG_BANK_SIZE 			(1 << SGX_REG_BANK_SHIFT)
	#define SGX_REG_BANK_BASE_INDEX		(2)
	#define	SGX_REG_BANK_MASTER_INDEX	(1)
	#define SGX_MP_CORE_SELECT(x,i) 	(x + ((i + SGX_REG_BANK_BASE_INDEX) * SGX_REG_BANK_SIZE))
	#define SGX_MP_MASTER_SELECT(x) 	(x + (SGX_REG_BANK_MASTER_INDEX * SGX_REG_BANK_SIZE))
#else
	#define SGX_MP_CORE_SELECT(x,i) 	(x)
#endif /* SGX_FEATURE_MP */

#if defined(SGX545)
	/*
		Maximum render dimensions.
	*/
	#define EURASIA_RENDERSIZE_MAXX						(8192)
	#define EURASIA_RENDERSIZE_MAXY						(8192)

	/*
		Maximum texture dimensions.
	*/
	#define EURASIA_TEXTURESIZE_MAX						(8192)
#else /* SGX545 */
	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
		/*
			Maximum render dimensions.
		*/
		#define EURASIA_RENDERSIZE_MAXX						(4096)
		#define EURASIA_RENDERSIZE_MAXY						(4096)

		/*
			Maximum texture dimensions.
		*/
		#define EURASIA_TEXTURESIZE_MAX						(4096)
	#else /* SGX543 || SGX544 || SGX554 */
		/*
			Maximum render dimensions.
		*/
		#define EURASIA_RENDERSIZE_MAXX						(2048)
		#define EURASIA_RENDERSIZE_MAXY						(2048)

		/*
			Maximum texture dimensions.
		*/
		#define EURASIA_TEXTURESIZE_MAX						(2048)
	#endif /* SGX543 || SGX544 || SGX554 */
#endif /* #if !defined(SGX545) */


/* TAG maximum stride in pixel ( beside the dword interface )*/
#if defined(SGX520)
#define EURASIA_TAG_MAX_PIXEL_STRIDE						(2048)
#else /* SGX520 */
#if defined(SGX530)
#define EURASIA_TAG_MAX_PIXEL_STRIDE						(4096)
#else
#if defined(SGX540) || defined(SGX535)
#define EURASIA_TAG_MAX_PIXEL_STRIDE						(8192)
#else
#if defined(SGX531) || defined(SGX543) || defined(SGX544) || defined(SGX554)
#define EURASIA_TAG_MAX_PIXEL_STRIDE						(32768)
#else
#if defined(SGX545)
#define EURASIA_TAG_MAX_PIXEL_STRIDE						(16384)
#endif /* SGX545 */ 
#endif /* SGX531 || SGX543 */
#endif /* SGX540 || SGX535 */
#endif /* SGX530 */
#endif /* SGX520 */


/*
	Maximum point size supported when converting triangles to points.
*/
#define EURASIA_MAX_POINTFILL_DIAMETER				16.0f

/*
	Output partition size.
*/
#if defined(SGX_FEATURE_UNIFIED_STORE_64BITS)

#define EURASIA_OUTPUT_PARTITION_SIZE				128
#define EURASIA_OUTPUT_PARTITION_SIZE_LOG2			7

#else

#define EURASIA_OUTPUT_PARTITION_SIZE				64
#define EURASIA_OUTPUT_PARTITION_SIZE_LOG2			6

#endif

#if defined(SGX_FEATURE_SYSTEM_CACHE)

/*
	Size of a line in the system level cache (in bytes)
*/
#define EURASIA_CACHE_LINE_SIZE						64U
#define EURASIA_CACHE_LINE_SIZE_LOG2				6

#else

/*
	Size of a line in the main data cache (in bytes)
*/
#define EURASIA_CACHE_LINE_SIZE						32U
#define EURASIA_CACHE_LINE_SIZE_LOG2				5

#endif


/*
	Maximum point size.
*/
#define EURASIA_MAX_POINT_SIZE						511.0f

/*
	Maximum vertex index (reduced by one to reserve 0x00FFFFFF for use by the hardware)
*/
#define EURASIA_MAX_VERTEX_INDEX					0x00FFFFFE

#if defined(SGX545)
/*
	Amount of attribute space (in chunks) to reserve for pixels
	(set in EUR_CR_PDS_VCB_PERF_CTRL_REDUCE_TA_MEM)...
*/
#define EURASIA_PDS_RESERVED_PIXEL_CHUNKS 			12
#endif

/*
	Number of registers in a PDS attribute chunk.
*/
#if defined(SGX545)
	#define EURASIA_PDS_CHUNK_SIZE						64
	#define EURASIA_PDS_CHUNK_SIZE_SHIFT				6
#else
	#define EURASIA_PDS_CHUNK_SIZE						32
	#define EURASIA_PDS_CHUNK_SIZE_SHIFT				5
#endif
/*
	Number of registers reserved for output registers.
*/
#if defined(SGX545)
	/*
	 * This should be 10 - 4, however this causes issues when used
	 */
	#define EURASIA_USSE_NUM_OUTPUT_PARTITIONS			14		
	#define EURASIA_USSE_MAX_EXTRA_OUTPUT_PARTITIONS	0		
#else
	#if defined(SGX543) || defined(SGX544)
		#define EURASIA_USSE_NUM_OUTPUT_PARTITIONS			8		
		#define EURASIA_USSE_MAX_EXTRA_OUTPUT_PARTITIONS	4
	#else
		#if defined(SGX554)
			#define EURASIA_USSE_NUM_OUTPUT_PARTITIONS			7	
			#define EURASIA_USSE_MAX_EXTRA_OUTPUT_PARTITIONS	3
		#else
			#define EURASIA_USSE_NUM_OUTPUT_PARTITIONS			6		
			#define EURASIA_USSE_MAX_EXTRA_OUTPUT_PARTITIONS	0
		#endif
	#endif
#endif

#define EURASIA_USSE_NUM_OUTPUT_REGISTERS			(EURASIA_OUTPUT_PARTITION_SIZE*EURASIA_USSE_NUM_OUTPUT_PARTITIONS)

/*
	Total number of USE registers.
*/
#if defined(SGX545) || defined(SGX554)
	#define EURASIA_USE_NUM_UNIFIED_REGISTERS			4096
#else
#if defined(SGX543) || defined(SGX544)
	#define EURASIA_USE_NUM_UNIFIED_REGISTERS			3328
#else
	#define EURASIA_USE_NUM_UNIFIED_REGISTERS			2048
#endif
#endif

/*
	Total number of temporary registers..
*/
#if defined(SGX545) && !defined(FIX_HW_BRN_26573)
	#define EURASIA_USE_GLOBAL_TEMP_REG_LIMIT		768
	#define EURASIA_USE_GLOBAL_TEMP_REG_GRAN		5
#else
	#define EURASIA_USE_GLOBAL_TEMP_REG_LIMIT		384
	#define EURASIA_USE_GLOBAL_TEMP_REG_GRAN		4
#endif

/*
	Maximum number of USE instances
*/
#define EURASIA_MAX_USE_INSTANCES					64

/*
	Maximum number of clipplanes
*/
#define EURASIA_MAX_MTE_CLIP_PLANES					8

/*
	Maximum number of Bytes per pixel required for compressed z buffer.
*/
#if defined(SGX545) || defined(SGX540) || defined(SGX541) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_MAX_COMPRESSED_Z_BPP				5
#else
	#define EURASIA_MAX_COMPRESSED_Z_BPP				6
#endif

/*
	Defines related to SPM
*/
#define SGX_MAXRT_SPM_REQUIREMENT_4MT 				2
#define SGX_MAXRT_SPM_REQUIREMENT_16MT 				8

/*
	Size of the region covered by a single ISP
*/
#if defined(SGX545)
/*
	Two ISP pipelines striped in Y
*/
#define EURASIA_PERISP_TILE_SIZEX					(EURASIA_ISPREGION_SIZEX / 2)
#define EURASIA_PERISP_TILE_SHIFTX					(EURASIA_ISPREGION_SHIFTX - 1)
#define EURASIA_PERISP_TILE_SIZEY					EURASIA_ISPREGION_SIZEY
#define EURASIA_PERISP_TILE_SHIFTY					EURASIA_ISPREGION_SHIFTY
#else /* defined(SGX545) */
/*
	One ISP pipeline.
*/
#define EURASIA_PERISP_TILE_SIZEX					EURASIA_ISPREGION_SIZEX
#define EURASIA_PERISP_TILE_SHIFTX					EURASIA_ISPREGION_SHIFTX
#define EURASIA_PERISP_TILE_SIZEY					EURASIA_ISPREGION_SIZEY
#define EURASIA_PERISP_TILE_SHIFTY					EURASIA_ISPREGION_SHIFTY
#endif /* defined(SGX545) */

/*
	Arrangement of USE pipelines per ISP.
*/
#if defined(SGX520)
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X			1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X_LOG2		0
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y			1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y_LOG2		0
#else /* defined(SGX520) */
#if defined(SGX545)
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X			1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X_LOG2		0
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y			2
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y_LOG2		1
#else /* defined(SGX545) */
#if defined(SGX540) || defined(SGX541) || defined(SGX543) || defined(SGX544)
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X			2
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y			2
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y_LOG2		1
#else /* defined(SGX554) */
#if defined(SGX554)
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X			2
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y			4
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y_LOG2		2
#else /* defined(SGX530) || defined(SGX535) || defined(SGX531) */
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X			2
#define EURASIA_PERISP_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y			1
#define EURASIA_PERISP_NUM_USE_PIPES_IN_Y_LOG2		0
#endif /* defined(SGX554) */
#endif /* defined(SGX540) || defined(SGX541) */
#endif /* defined(SGX545) */
#endif /* defined(SGX520) */

/*
	Arrangement of USE pipelines
*/
#if defined(SGX520)
#define EURASIA_NUM_USE_PIPES_IN_X			1
#define EURASIA_NUM_USE_PIPES_IN_X_LOG2		0
#define EURASIA_NUM_USE_PIPES_IN_Y			1
#define EURASIA_NUM_USE_PIPES_IN_Y_LOG2		0
#define EURASIA_USE_PIPES_ORIENTATION_XY
#else /* defined(SGX520) */
#if defined(SGX545)
#define EURASIA_NUM_USE_PIPES_IN_X			2
#define EURASIA_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_NUM_USE_PIPES_IN_Y			2
#define EURASIA_NUM_USE_PIPES_IN_Y_LOG2		1
#define EURASIA_USE_PIPES_ORIENTATION_YX
#else /* defined(SGX545) */
#if defined(SGX540) || defined(SGX541) || defined(SGX543) || defined(SGX544)
#define EURASIA_NUM_USE_PIPES_IN_X			2
#define EURASIA_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_NUM_USE_PIPES_IN_Y			2
#define EURASIA_NUM_USE_PIPES_IN_Y_LOG2		1
#define EURASIA_USE_PIPES_ORIENTATION_XY
#else /* defined(SGX554) */
#if defined(SGX554)
#define EURASIA_NUM_USE_PIPES_IN_X			2
#define EURASIA_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_NUM_USE_PIPES_IN_Y			4
#define EURASIA_NUM_USE_PIPES_IN_Y_LOG2		2
#define EURASIA_USE_PIPES_ORIENTATION_YX
#else /* defined(SGX530) || defined(SGX535) || defined(SGX531) */
#define EURASIA_NUM_USE_PIPES_IN_X			2
#define EURASIA_NUM_USE_PIPES_IN_X_LOG2		1
#define EURASIA_NUM_USE_PIPES_IN_Y			1
#define EURASIA_NUM_USE_PIPES_IN_Y_LOG2		0
#define EURASIA_USE_PIPES_ORIENTATION_XY
#endif /* defined(SGX554) */
#endif /* defined(SGX540) || defined(SGX541) */
#endif /* defined(SGX545) */
#endif /* defined(SGX520) */

/*
	Size of the region covered by a single USE pipeline
*/
#define EURASIA_PERUSE_REGION_SIZEX			(EURASIA_PERISP_TILE_SIZEX / EURASIA_PERISP_NUM_USE_PIPES_IN_X)
#define EURASIA_PERUSE_REGION_SIZEY			(EURASIA_PERISP_TILE_SIZEY / EURASIA_PERISP_NUM_USE_PIPES_IN_Y)

#if defined(SGX554)
#define EURASIA_DEFAULT_TAG_TRIANGLE_SPLIT	64
#else
#define EURASIA_DEFAULT_TAG_TRIANGLE_SPLIT	32
#endif

/*****************************************************************************
 3D Input Parameter Format
*****************************************************************************/

/* Block Header */
#define EURASIA_TAOBJTYPE_CLRMSK					0x3FFFFFFFU
#define EURASIA_TAOBJTYPE_SHIFT						30
#define EURASIA_TAOBJTYPE_LINK						(0UL	<< EURASIA_TAOBJTYPE_SHIFT)
#define EURASIA_TAOBJTYPE_STATE						(1UL	<< EURASIA_TAOBJTYPE_SHIFT)
#define EURASIA_TAOBJTYPE_INDEXLIST					(2UL	<< EURASIA_TAOBJTYPE_SHIFT)
#define EURASIA_TAOBJTYPE_TERMINATE					(3UL	<< EURASIA_TAOBJTYPE_SHIFT)

/*****************************************************************************
 Stream Link
*****************************************************************************/

/* Stream Link Word 1 */
#define EURASIA_TASTRMLINK_ADDR_CLRMSK				0xC0000000U
#define EURASIA_TASTRMLINK_ADDR_SHIFT				0
#define EURASIA_TASTRMLINK_ADDR_ALIGNSHIFT			2

/*****************************************************************************
 State
*****************************************************************************/

/* State Word 1 - Complex Geometry */
#if defined(SGX545)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_ITP					(1UL << 31)

	// When EURASIA_TAPDSSTATE_COMPLEXGEOM1_ITP is set...
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_CTX_SWITCH			(1UL << 30)

	// When EURASIA_TAPDSSTATE_COMPLEXGEOM1_ITP is set and we're doing a state update...
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_RENDER_TGT_PRES		(1UL << 30)

#if !defined(FIX_HW_BRN_27945)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_PHASE2VTXSTRIDE_CLRMSK 	0xC1FFFFFFU
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_PHASE2VTXSTRIDE_SHIFT 	25
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_PHASE2VTXSTRIDE_ALIGNSHIFT 2U
#else
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_VERTEXSIZE_CLRMSK 	0xC1FFFFFFU
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_VERTEXSIZE_SHIFT 	25
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_VERTEXSIZE_ALIGNSHIFT 2U
#endif

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_DATASIZE_CLRMSK 	0xFE07FFFFU
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_DATASIZE_SHIFT 		19
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_DATASIZE_ALIGNSHIFT	4U

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_VTXDMA_DATASIZE_CLRMSK 	0xFFF87FFFU
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_VTXDMA_DATASIZE_SHIFT 	15
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_VTXDMA_DATASIZE_ALIGNSHIFT 4U

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_CLRMSK 		0xFFFF8FFFU
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_SHIFT 		12
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_PIPE0    	(1UL << EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_SHIFT)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_PIPE1    	(2UL << EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_SHIFT)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_PIPE2    	(3UL << EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_SHIFT)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_PIPE3    	(4UL << EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_SHIFT)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_PIPEALL    	(7UL << EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEPIPE_SHIFT)

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_PARTITIONS_CLRMSK 	0xFFFFF1FFU
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_PARTITIONS_SHIFT 	9

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_SECONDARY			(1UL << 8)

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEATTRIBUTESIZE_CLRMSK 	0xFFFFFF00U
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEATTRIBUTESIZE_SHIFT 	0
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM1_USEATTRIBUTESIZE_ALIGNSHIFT 	4U
#endif

/* State Word 2 - Complex Geometry */
#if defined(SGX545)
	// When EURASIA_TAPDSSTATE_COMPLEXGEOM1_ITP is set and we're doing a state update...
#if !defined(FIX_HW_BRN_27707)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_STPRES				(1UL << 31)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_RESETSOID			(1UL << 28)
#endif
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_CTX_SWITCH			(1UL << 31)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_PARTIAL				(1UL << 30)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_VPT_TGT				(1UL << 29)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_LEADVTX				(1UL << 28)

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_BASEADDR_CLRMSK 	0xF0000000U
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_BASEADDR_SHIFT 	0
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM2_BASEADDR_ALIGNSHIFT	4U
#endif

/* State Word 3 - Complex Geometry */
#if defined(SGX545)
	// When EURASIA_TAPDSSTATE_COMPLEXGEOM1_ITP is set and we're doing a state update...
	#if !defined(FIX_HW_BRN_27212)
		#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_PRIMTYPE_STRIP		(0UL << 30)
		#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_PRIMTYPE_LINESTRIP	(1UL << 30)
		#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_PRIMTYPE_POINT		(2UL << 30)
	#endif

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_SD					(1UL << 29)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_MTE_EMIT			(1UL << 28)

	#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_VTXDMAADDR_CLRMSK 	0xF0000000U
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_VTXDMAADDR_SHIFT 	0
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM3_VTXDMAADDR_ALIGNSHIFT 4U
#endif

#if !defined(FIX_HW_BRN_27945)
/* State Word 4 - Complex Geometry */
#if defined(SGX545)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM4_VERTEXSIZE_CLRMSK	(0xFFFFFFC0U)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM4_VERTEXSIZE_SHIFT	(0)
	#define EURASIA_TAPDSSTATE_COMPLEXGEOM4_CTX_RESTORE			(1UL << 31)
#endif
#endif /* Fix HW BRN 27945 */

/* State Word 1 */
#define EURASIA_TAPDSSTATE_LASTTASK					(1UL << 29)

#define	EURASIA_TAPDSSTATE_CMPLX					(1UL << 28)

#define	EURASIA_TAPDSSTATE_BASEADDR_CLRMSK			0xF0000000U
#define	EURASIA_TAPDSSTATE_BASEADDR_SHIFT			0
#define	EURASIA_TAPDSSTATE_BASEADDR_ALIGNSHIFT		4U

/* State Word 2 */
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EURASIA_TAPDSSTATE_DATASIZE_CLRMSK			0x07FFFFFFU
	#define	EURASIA_TAPDSSTATE_DATASIZE_SHIFT			27
#else
	#define	EURASIA_TAPDSSTATE_DATASIZE_CLRMSK			0x03FFFFFFU
	#define	EURASIA_TAPDSSTATE_DATASIZE_SHIFT			26
#endif
#define	EURASIA_TAPDSSTATE_DATASIZE_ALIGNSHIFT		4U

#define	EURASIA_TAPDSSTATE_DEBUG					(1UL << 24)

#if defined(SGX543) || defined(SGX544) || defined(SGX554) || (defined(SGX545) && !defined(FIX_HW_BRN_27707))
#define EURASIA_TAPDSSTATE_FENCE_ENABLE				(1UL << 18)
#endif

#define EURASIA_TAPDSSTATE_MTE_EMIT					(1UL << 17)


#if defined(SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK)
	/* This bit has been removed (hw infers it) on some cores, but to make the drivers more consistent
	 * just make it 0
	 */
	#define EURASIA_TAPDSSTATE_SEC_EXEC					0
#else
	#define EURASIA_TAPDSSTATE_SEC_EXEC					(1UL << 16)
#endif

#if defined(SGX545) || defined(SGX540) || defined(SGX541) || defined(SGX531) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EURASIA_TAPDSSTATE_SD						(1UL << 25)
#else
	#define	EURASIA_TAPDSSTATE_SD						(1UL << 15)
#endif

#if defined(SGX545) || defined(SGX540) || defined(SGX541) || defined(SGX543) || defined(SGX544)
		#define	EURASIA_TAPDSSTATE_PIPECOUNT				(4)
		#define	EURASIA_TAPDSSTATE_USEPIPE_CLRMSK			0xFFFF1FFFU
		#define	EURASIA_TAPDSSTATE_USEPIPE_SHIFT			13
		#define	EURASIA_TAPDSSTATE_USEPIPE_1				(1UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_2				(2UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_3				(3UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_4				(4UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_ALL				(7UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
#else
	#if defined(SGX554)
		#define	EURASIA_TAPDSSTATE_PIPECOUNT				(8)
		#define	EURASIA_TAPDSSTATE_USEPIPE_CLRMSK			0xFFFE1FFFU
		#define	EURASIA_TAPDSSTATE_USEPIPE_SHIFT			13
		#define	EURASIA_TAPDSSTATE_USEPIPE_1				(1UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_2				(2UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_3				(3UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_4				(4UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_5				(5UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_6				(6UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_7				(7UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_8				(8UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
		#define	EURASIA_TAPDSSTATE_USEPIPE_ALL				(15UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
	#else
		#if defined(SGX520)
			#define	EURASIA_TAPDSSTATE_PIPECOUNT				(1)
			#define	EURASIA_TAPDSSTATE_USEPIPE_CLRMSK			0xFFFF9FFFU
			#define	EURASIA_TAPDSSTATE_USEPIPE_SHIFT			13
			#define	EURASIA_TAPDSSTATE_USEPIPE_1				(1UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
			#define	EURASIA_TAPDSSTATE_USEPIPE_BOTH				EURASIA_TAPDSSTATE_USEPIPE_1
			#define	EURASIA_TAPDSSTATE_USEPIPE_ALL				EURASIA_TAPDSSTATE_USEPIPE_BOTH
		#else
			#if defined(SGX531)
				#define	EURASIA_TAPDSSTATE_PIPECOUNT				(2)
				#define	EURASIA_TAPDSSTATE_USEPIPE_CLRMSK			0xFFFF1FFFU
				#define	EURASIA_TAPDSSTATE_USEPIPE_SHIFT			13
				#define	EURASIA_TAPDSSTATE_USEPIPE_1				(1UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
				#define	EURASIA_TAPDSSTATE_USEPIPE_2				(2UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
				#define	EURASIA_TAPDSSTATE_USEPIPE_BOTH				(7UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
				#define	EURASIA_TAPDSSTATE_USEPIPE_ALL				EURASIA_TAPDSSTATE_USEPIPE_BOTH
			#else
				#define	EURASIA_TAPDSSTATE_PIPECOUNT				(2)
				#define	EURASIA_TAPDSSTATE_USEPIPE_CLRMSK			0xFFFF9FFFU
				#define	EURASIA_TAPDSSTATE_USEPIPE_SHIFT			13
				#define	EURASIA_TAPDSSTATE_USEPIPE_1				(1UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
				#define	EURASIA_TAPDSSTATE_USEPIPE_2				(2UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
				#define	EURASIA_TAPDSSTATE_USEPIPE_BOTH				(3UL	<< EURASIA_TAPDSSTATE_USEPIPE_SHIFT)
				#define	EURASIA_TAPDSSTATE_USEPIPE_ALL				EURASIA_TAPDSSTATE_USEPIPE_BOTH
			#endif
		#endif
	#endif
#endif

#define	EURASIA_TAPDSSTATE_PARTIAL					(1UL << 12)

#define	EURASIA_TAPDSSTATE_PARTITIONS_CLRMSK		0xFFFFF1FFU
#define	EURASIA_TAPDSSTATE_PARTITIONS_SHIFT			9

#define	EURASIA_TAPDSSTATE_SECONDARY				(1UL << 8)

#define	EURASIA_TAPDSSTATE_USEATTRIBUTESIZE_CLRMSK	0xFFFFFF00U
#define	EURASIA_TAPDSSTATE_USEATTRIBUTESIZE_SHIFT	0
#define EURASIA_TAPDSSTATE_USEATTRIBUTESIZE_ALIGNSHIFT 4U

#if defined(SGX_FEATURE_VDM_CONTEXT_SWITCH)
	#define EURASIA_VDM_SNAPSHOT_BUFFER_SIZE			(124 * sizeof(IMG_UINT32))
	#define EURASIA_VDM_SNAPSHOT_BUFFER_ALIGNSHIFT 		(4U)
	#if defined(FIX_HW_BRN_31425) || \
		(defined(FIX_HW_BRN_33657) && defined(SUPPORT_SECURE_33657_FIX))
		/* Needs to be large enough to store master VDM state */
		#define EURASIA_DUMMY_VDM_SNAPSHOT_BUFFER_SIZE			(32 * sizeof(IMG_UINT32))
		#define EURASIA_DUMMY_VDM_CTRL_STREAM_BUFFER_SIZE		(129 * sizeof(IMG_UINT32))
	#endif
#endif


#if defined(SGX_FEATURE_MP)

/*
 * This is 16*128 bit words. The HW "reads ahead" by this amount. This value should be 
 * big enough to guard against page overrun in all cases.
 */

#define EURASIA_VDM_CTRL_STREAM_BURST_SIZE			(16 * 16U)

#else

/* This is 4*128 bit words. The HW "reads ahead" by this amount. It is actually less
 * on cores where the internal memory bus is < 128 bits, but this value should be big enough to guard against
 * page overrun in all cases.
 */
#define EURASIA_VDM_CTRL_STREAM_BURST_SIZE			(4 * 16U)

#endif


/* This is a FIFO of 2 with a burst size of 2*128 bit words. It is actually different on cores other than
 * 535 (when the internal memory bus is < 128 bits) but this value should be big enough to guard against
 * page overrun in all cases
 */
#define EURASIA_VDM_INDEX_FETCH_BURST_SIZE			(2 * 2 * 16U)

/*****************************************************************************
 Index List
*****************************************************************************/

/* Index List Word 0 */
#define EURASIA_VDM_TYPE_CLRMSK					0xC3FFFFFFU
#define EURASIA_VDM_TYPE_SHIFT						(26)
#define EURASIA_VDM_TRIS							(0UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_LINES							(1UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_POINTS							(2UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_STRIP							(3UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_FAN								(4UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_EDGETRIS						(5UL	<< EURASIA_VDM_TYPE_SHIFT)
#if defined(SGX545)
	#define EURASIA_VDM_LINESTRIP						(6UL	<< EURASIA_VDM_TYPE_SHIFT)
#endif
#define EURASIA_VDM_COMPLEXTRI						(8UL	<< EURASIA_VDM_TYPE_SHIFT)
#if defined(SGX545)
	#define EURASIA_VDM_COMPLEXLINE						(9UL	<< EURASIA_VDM_TYPE_SHIFT)
#endif
#define EURASIA_VDM_COMPLEXPOINT					(10UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_COMPLEXSTRIP					(11UL	<< EURASIA_VDM_TYPE_SHIFT)
#define EURASIA_VDM_COMPLEXFAN						(12UL	<< EURASIA_VDM_TYPE_SHIFT)
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EURASIA_VDM_COMPLEXNGENERIC				(13UL	<< EURASIA_VDM_TYPE_SHIFT)
#endif
#if defined(SGX545)
	#define	EURASIA_VDM_COMPLEXLINESTRIP				(14UL	<< EURASIA_VDM_TYPE_SHIFT)
#endif

#define EURASIA_VDM_COMPLEXMASK					(8UL	<< EURASIA_VDM_TYPE_SHIFT)

#define EURASIA_VDM_IDXPRES2						(1UL << 22)
#define EURASIA_VDM_IDXPRES3						(1UL << 23)

#if defined(SGX545)
	#define EURASIA_VDM_ADJACENCY_PRESENT				(1UL << 24)
	#define EURASIA_VDM_IDXPRESCOMPLEXSTAT				(1UL << 25)
#else
	#define EURASIA_VDM_IDXPRES45						(1UL << 24)
	#define EURASIA_VDM_IDXPRES67						(1UL << 25)
#endif

#define EURASIA_VDM_IDXCOUNT_CLRMSK				0xFFC00000U
#define EURASIA_VDM_IDXCOUNT_SHIFT					0

/* Index List Word 1 */
#define EURASIA_VDM_IDXBASE16_CLRMSK				0x00000001U
#define EURASIA_VDM_IDXBASE16_SHIFT				1
#define EURASIA_VDM_IDXBASE16_ALIGNSHIFT			1U

#define EURASIA_VDM_IDXBASE32_CLRMSK				0x00000003U
#define EURASIA_VDM_IDXBASE32_SHIFT					2
#define EURASIA_VDM_IDXBASE32_ALIGNSHIFT			2U

#if defined(SGX545)
	#define EURASIA_VDM_PRIMID_PRESENT				0x00000001
#else

#endif

/* Index List Word 2 */
#define EURASIA_VDMPDS_MAXINPUTINSTANCES_CLRMSK		0x0FFFFFFFU
#define EURASIA_VDMPDS_MAXINPUTINSTANCES_SHIFT		28
#if !defined(SGX_FEATURE_UNIFIED_TEMPS_AND_PAS)
	#define EURASIA_VDMPDS_MAXINPUTINSTANCES_MAX		16U
#else /* #if defined(SGX535) */
	#define EURASIA_VDMPDS_MAXINPUTINSTANCES_MAX		8U

	/*
		For complex geometry on 530 EURASIA_VDMPDS_MAXINPUTINSTANCES
		is overwritten with the following...
	*/
	#define EURASIA_VDMPDS_CMPLX_VTXLOADINGTEMPS_CLRMSK		0x0FFFFFFFU
	#define EURASIA_VDMPDS_CMPLX_VTXLOADINGTEMPS_SHIFT			28
	#define EURASIA_VDMPDS_CMPLX_VTXLOADINGTEMPS_ALIGNSHIFT	2U
#endif /* #if defined(SGX535) */

// Note: For Muse this should always be set.
#define EURASIA_VDMPDS_CMPLX_INORDER				(1UL	<< 27)

#define EURASIA_VDM_FLATSHADE_CLRMSK				0xF9FFFFFFU
#define EURASIA_VDM_FLATSHADE_SHIFT					25
#define EURASIA_VDM_FLATSHADE_VERTEX0				(0UL	<< EURASIA_VDM_FLATSHADE_SHIFT)
#define EURASIA_VDM_FLATSHADE_VERTEX1				(1UL	<< EURASIA_VDM_FLATSHADE_SHIFT)
#define EURASIA_VDM_FLATSHADE_VERTEX2				(2UL	<< EURASIA_VDM_FLATSHADE_SHIFT)
#define EURASIA_VDM_FLATSHADE_RESERVED				(3UL	<< EURASIA_VDM_FLATSHADE_SHIFT)

#define EURASIA_VDM_IDXSIZE_CLRMSK					0xFEFFFFFFU
#define EURASIA_VDM_IDXSIZE_SHIFT					24
#define EURASIA_VDM_IDXSIZE_16BIT					(0UL	<< EURASIA_VDM_IDXSIZE_SHIFT)
#define EURASIA_VDM_IDXSIZE_32BIT					(1UL	<< EURASIA_VDM_IDXSIZE_SHIFT)

#define EURASIA_VDM_IDXOFF_CLRMSK					0xFF000000U
#define EURASIA_VDM_IDXOFF_SHIFT					0

#define EURASIA_VDM_WORD2_DEFAULT					((0 << EURASIA_VDM_IDXOFF_SHIFT) | \
													 EURASIA_VDM_FLATSHADE_VERTEX0 | \
													 EURASIA_VDM_IDXSIZE_16BIT | \
													 (0 << EURASIA_VDMPDS_MAXINPUTINSTANCES_SHIFT))

/* Index List Word 3 */

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_VDMPDS_TEMPSIZECMPLX_CLRMSK			0x03FFFFFFU
	#define EURASIA_VDMPDS_TEMPSIZECMPLX_SHIFT			26
	#define EURASIA_VDMPDS_TEMPSIZECMPLX_ALIGNSHIFT		3U

	#define EURASIA_VDMPDS_CMPLXGENERICSIZE_CLRMSK		0xFC3FFFFFU
	#define EURASIA_VDMPDS_CMPLXGENERICSIZE_SHIFT		22

#else

#if defined(SGX520) || defined(SGX530) || defined(SGX540) || defined(SGX541) || defined(SGX531)
	#define EURASIA_VDMPDS_TEMPSIZECMPLX_CLRMSK			0x01FFFFFFU
	#define EURASIA_VDMPDS_TEMPSIZECMPLX_SHIFT			25
	#define EURASIA_VDMPDS_TEMPSIZECMPLX_ALIGNSHIFT		2U
#endif

	#define EURASIA_VDMPDS_PARTITIONSCMPLX_CLRMSK		0xFE3FFFFFU
	#define EURASIA_VDMPDS_PARTITIONSCMPLX_SHIFT		22

#endif

#define EURASIA_VDM_WRAPCOUNT_CLRMSK				0xFFC00000U
#define EURASIA_VDM_WRAPCOUNT_SHIFT					0

/* Index List Word 4 */
#define	EURASIA_VDMPDS_PARTSIZE_CLRMSK				0x0FFFFFFFU
#define	EURASIA_VDMPDS_PARTSIZE_SHIFT				28
#if defined(SGX520) || defined(SGX530) || defined(SGX540) || defined(SGX541) || defined(SGX531)
	#define	EURASIA_VDMPDS_PARTSIZE_MAX					12
#else
	#define	EURASIA_VDMPDS_PARTSIZE_MAX					16
#endif

#define EURASIA_VDMPDS_BASEADDR_CLRMSK				0xF0000000U
#define EURASIA_VDMPDS_BASEADDR_SHIFT				0
#define EURASIA_VDMPDS_BASEADDR_ALIGNSHIFT			4U
#define EURASIA_VDMPDS_BASEADDR_CACHEALIGN			32U

/* Index List Word 5 */
#if defined(SGX545)
	#define EURASIA_VDMPDS_VERTEXSIZE_CLRMSK			0x00FFFFFFU
	#define EURASIA_VDMPDS_VERTEXSIZE_SHIFT				24
	#define EURASIA_VDMPDS_VERTEXSIZE_ALIGNSHIFT		2U
	#define EURASIA_VDMPDS_VERTEXSIZE_ALIGN				4U

	#define EURASIA_VDMPDS_VTXADVANCE_CLRMSK			0xFF3FFFFF
	#define EURASIA_VDMPDS_VTXADVANCE_SHIFT				22
	#define EURASIA_VDMPDS_VTXADVANCE_1VTX				(0UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)
	#define EURASIA_VDMPDS_VTXADVANCE_2VTX				(1UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)
	#define EURASIA_VDMPDS_VTXADVANCE_3VTX				(2UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)
	#define EURASIA_VDMPDS_VTXADVANCE_4VTX				(3UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)

	#define EURASIA_VDMPDS_DATASIZECMPLX_CLRMSK		0xFFC0FFFFU
	#define EURASIA_VDMPDS_DATASIZECMPLX_SHIFT			16
	#define EURASIA_VDMPDS_DATASIZECMPLX_ALIGNSHIFT	4U

	#define	EURASIA_VDMPDS_USEATTRIBUTESIZE_CLRMSK		0xFFFF807FU
	#define	EURASIA_VDMPDS_USEATTRIBUTESIZE_SHIFT		7
	#define	EURASIA_VDMPDS_USEATTRIBUTESIZE_ALIGNSHIFT	4U
#else
	#define EURASIA_VDMPDS_VERTEXSIZE_CLRMSK			0x01FFFFFFU
	#define EURASIA_VDMPDS_VERTEXSIZE_SHIFT				25
	#define EURASIA_VDMPDS_VERTEXSIZE_ALIGNSHIFT		2U
	#define EURASIA_VDMPDS_VERTEXSIZE_ALIGN				4U

	#define EURASIA_VDMPDS_VTXADVANCE_CLRMSK			0xFE7FFFFFU
	#define EURASIA_VDMPDS_VTXADVANCE_SHIFT				23
	#define EURASIA_VDMPDS_VTXADVANCE_1VTX				(0UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)
	#define EURASIA_VDMPDS_VTXADVANCE_2VTX				(1UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)
	#define EURASIA_VDMPDS_VTXADVANCE_3VTX				(2UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)
	#define EURASIA_VDMPDS_VTXADVANCE_4VTX				(3UL	<< EURASIA_VDMPDS_VTXADVANCE_SHIFT)

	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
		#define EURASIA_VDMPDS_DATASIZECMPLX_CLRMSK			0xFF83FFFFU
		#define EURASIA_VDMPDS_DATASIZECMPLX_SHIFT			18
		#define EURASIA_VDMPDS_DATASIZECMPLX_ALIGNSHIFT		4U

		#define EURASIA_VDMPDS_CMPLXMULTI					(1UL << 17)

		#define EURASIA_VDMPDS_USEATTRIBUTESIZE_CLRMSK		0xFFFE01FFU
		#define EURASIA_VDMPDS_USEATTRIBUTESIZE_SHIFT		9
		#define EURASIA_VDMPDS_USEATTRIBUTESIZE_ALIGNSHIFT	4U

	#else
		#define EURASIA_VDMPDS_DATASIZECMPLX_CLRMSK			0xFF81FFFFU
		#define EURASIA_VDMPDS_DATASIZECMPLX_SHIFT			17
		#define EURASIA_VDMPDS_DATASIZECMPLX_ALIGNSHIFT		4U

		#define EURASIA_VDMPDS_USEATTRIBUTESIZE_CLRMSK		0xFFFE00FFU
		#define EURASIA_VDMPDS_USEATTRIBUTESIZE_SHIFT		8
		#define EURASIA_VDMPDS_USEATTRIBUTESIZE_ALIGNSHIFT	4U
	#endif

#endif

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_VDM_BATCH_INCREMENT					(1UL << 8)

	#if defined(SGX_FEATURE_MP)
		#define EURASIA_VDMM_CORE_LOCK_CLRMASK			0xFFFFFF1FU
		#define EURASIA_VDMM_CORE_LOCK_SHIFT			5

		#define EURASIA_VDMM_CORE_LOCK_HW_CHOICE		0
		#define EURASIA_VDMM_CORE_LOCK_CORE1			1
		#define EURASIA_VDMM_CORE_LOCK_CORE2			2
		#define EURASIA_VDMM_CORE_LOCK_CORE3			3
		#define EURASIA_VDMM_CORE_LOCK_CORE4			4
	#endif

	#define EURASIA_VDMPDS_DATASIZE_CLRMSK				0xFFFFFFE0U
	#define EURASIA_VDMPDS_DATASIZE_SHIFT				0
	#define EURASIA_VDMPDS_DATASIZE_ALIGNSHIFT			4U

#else
	#define EURASIA_VDMPDS_CMPLXMULTI					(1UL << 6)

	#define EURASIA_VDMPDS_DATASIZE_CLRMSK				0xFFFFFFC0U
	#define EURASIA_VDMPDS_DATASIZE_SHIFT				0
	#define EURASIA_VDMPDS_DATASIZE_ALIGNSHIFT			4U
#endif

/* Index List Word 6 */
#if defined(SGX545)
	#define	EURASIA_VDMPDS_CMPLXINSTSIZE_CLRMSK		0x07FFFFFFU
	#define	EURASIA_VDMPDS_CMPLXINSTSIZE_SHIFT			27
	#define	EURASIA_VDMPDS_CMPLXINSTSIZE_MAX			32

	#define EURASIA_VDMPDS_CMPLXBASEADDR_CLRMSK		0xF8000000U
	#define EURASIA_VDMPDS_CMPLXBASEADDR_SHIFT			0
	#define EURASIA_VDMPDS_CMPLXBASEADDR_ALIGNSHIFT	5U
#else
	#define	EURASIA_VDMPDS_CMPLXINSTSIZE_CLRMSK		0x0FFFFFFFU
	#define	EURASIA_VDMPDS_CMPLXINSTSIZE_SHIFT			28
	#define	EURASIA_VDMPDS_CMPLXINSTSIZE_MAX			16

	#define EURASIA_VDMPDS_CMPLXBASEADDR_CLRMSK		0xF0000000U
	#define EURASIA_VDMPDS_CMPLXBASEADDR_SHIFT			0
	#define EURASIA_VDMPDS_CMPLXBASEADDR_ALIGNSHIFT	4U
#endif

/* Index List Word 7 */
#define EURASIA_VDMPDS_CMPLXGSDATASIZE_CLRMSK		0x0FFFFFFFU
#define EURASIA_VDMPDS_CMPLXGSDATASIZE_SHIFT		28
#define EURASIA_VDMPDS_CMPLXGSDATASIZE_ALIGNSHIFT	4U

#define EURASIA_VDMPDS_CMPLXGSBASEADDR_CLRMSK		0xF0000000U
#define EURASIA_VDMPDS_CMPLXGSBASEADDR_SHIFT		0
#define EURASIA_VDMPDS_CMPLXGSBASEADDR_ALIGNSHIFT	4U

#if defined(SGX545)
	/* Index List Word 9 */
	#define EURASIA_VDMPDS_GS_INTERLEAVE_COUNT_CLRMSK	0xFFFFF000U
	#define EURASIA_VDMPDS_GS_INTERLEAVE_COUNT_SHIFT	0
#endif


/*****************************************************************************
 USE State Output Format
*****************************************************************************/

#if defined(SGX545)
	#define EURASIA_TACTLPRES_OUTSELECTS2					(1UL << 27)
	#define EURASIA_TACTLPRES_WR_PTR						(1UL << 26)

	#define EURASIA_TACTLPRES_VPT_TGT_COUNT_CLRMSK			(0xFC3FFFFFU)
	#define EURASIA_TACTLPRES_VPT_TGT_COUNT_SHIFT			(22)

	#define EURASIA_TACTLPRES_NOT_FINAL_TERM				(1UL << 21)
	#define EURASIA_TACTLPRES_RENDERTGT						(1UL << 20)
	#define EURASIA_TACTLPRES_SAMPLEPOSITION				(1UL << 19)

	#define EURASIA_TACTLPRES_NUMTEXWORDS_CLRMSK			0xFFF9FFFFU
	#define EURASIA_TACTLPRES_NUMTEXWORDS_SHIFT				(17)
#endif

#define EURASIA_TACTLPRES_CONTEXTSWITCH					(1UL << 16)
#define EURASIA_TACTLPRES_TEXFLOAT						(1UL << 15)
#define EURASIA_TACTLPRES_TEXSIZE						(1UL << 14)
#define EURASIA_TACTLPRES_TERMINATE						(1UL << 13)
#define EURASIA_TACTLPRES_MTECTRL						(1UL << 12)
#define EURASIA_TACTLPRES_WCLAMP						(1UL << 11)
#define EURASIA_TACTLPRES_OUTSELECTS					(1UL << 10)
#define EURASIA_TACTLPRES_WRAP							(1UL << 9)
#define EURASIA_TACTLPRES_VIEWPORT						(1UL << 8)
#define EURASIA_TACTLPRES_RGNCLIP						(1UL << 7)
#define EURASIA_TACTLPRES_PDSSTATEPTR					(1UL << 6)
#define EURASIA_TACTLPRES_ISPCTLBF2						(1UL << 5)
#define EURASIA_TACTLPRES_ISPCTLBF1						(1UL << 4)
#define EURASIA_TACTLPRES_ISPCTLBF0						(1UL << 3)
#define EURASIA_TACTLPRES_ISPCTLFF2						(1UL << 2)
#define EURASIA_TACTLPRES_ISPCTLFF1						(1UL << 1)
#define EURASIA_TACTLPRES_ISPCTLFF0						(1UL << 0)

#if defined(SGX545)
	#define EURASIA_TACTLPRES_ALL						(0x080EFFFFU | ~EURASIA_TACTLPRES_VPT_TGT_COUNT_CLRMSK)
	#define EURASIA_TACTLPRES_ALL_NOTERMINATE			(EURASIA_TACTLPRES_ALL & ~EURASIA_TACTLPRES_TERMINATE)
	#define EURASIA_TACTL_ALL_SIZEINDWORDS 				(123)
	#define EURASIA_TACTL_CMPLX_ALL_SIZEINDWORDS 		(4)
#else
	#define EURASIA_TACTLPRES_ALL						0x0000FFFFU
	#define EURASIA_TACTLPRES_ALL_NOTERMINATE			(EURASIA_TACTLPRES_ALL & ~EURASIA_TACTLPRES_TERMINATE)
	#define EURASIA_TACTL_ALL_SIZEINDWORDS 				(23)
#endif

#define EURASIA_NUM_USE_OUTPUT_STATE_DWORDS			(1 + EURASIA_TACTL_ALL_SIZEINDWORDS)





#if defined(SGX_FEATURE_MTE_STATE_FLUSH)
	#if defined(SGX_FEATURE_COMPLEX_GEOMETRY_REV_2)
		#define EURASIA_MTE_STATE_BUFFER_SIZE				((1 + EURASIA_TACTL_ALL_SIZEINDWORDS + EURASIA_TACTL_CMPLX_ALL_SIZEINDWORDS) \
															* sizeof(IMG_UINT32))
		#define EURASIA_MTE_STATE_BUFFER_CMPLX_OFFSET		((1 + EURASIA_TACTL_ALL_SIZEINDWORDS) * sizeof(IMG_UINT32))
	#else
		#if defined(SGX543) || defined(SGX544) || defined(SGX554)
		/* 1 more DWORD for PDS_BATCH_NUM */
		#define EURASIA_MTE_STATE_BUFFER_SIZE				((2 + EURASIA_TACTL_ALL_SIZEINDWORDS) * sizeof(IMG_UINT32))
		#else
		#define EURASIA_MTE_STATE_BUFFER_SIZE				((1 + EURASIA_TACTL_ALL_SIZEINDWORDS) * sizeof(IMG_UINT32))
		#endif
	#endif
	#define EURASIA_MTE_STATE_BUFFER_ALIGN_SHIFT		(4)
#endif

/*****************************************************************************
 ISP Control Words
*****************************************************************************/

/* ISP State Word A */
#if !defined(SGX545)
	#define	EURASIA_ISPA_PLWIDTH_CLRMSK					0x0FFFFFFFU
	#define	EURASIA_ISPA_PLWIDTH_SHIFT					28
#else
	#define EURASIA_ISPA_ORDERDEPAA						(1UL << 28)
#endif

#define EURASIA_ISPA_PASSTYPE_CLRMSK				0xF1FFFFFFU
#define EURASIA_ISPA_PASSTYPE_SHIFT					25
#define EURASIA_ISPA_PASSTYPE_OPAQUE				(0UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#define EURASIA_ISPA_PASSTYPE_TRANS					(1UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#define EURASIA_ISPA_PASSTYPE_TRANSPT				(2UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#define EURASIA_ISPA_PASSTYPE_VIEWPORT				(3UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#define EURASIA_ISPA_PASSTYPE_FASTPT				(4UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#define EURASIA_ISPA_PASSTYPE_DEPTHFEEDBACK			(5UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#if defined(SGX545) && !defined(FIX_HW_BRN_27792)
#define EURASIA_ISPA_PASSTYPE_DEPTHBIAS				(7UL	<< EURASIA_ISPA_PASSTYPE_SHIFT)
#endif

#if defined(SGX545) && !defined(FIX_HW_BRN_27792)
#define EURASIA_ISPA_DEPTHBIAS_CLRMSK				0xFF000000U
#define EURASIA_ISPA_DEPTHBIAS_SHIFT				0
#endif

#define EURASIA_ISPA_DCMPMODE_CLRMSK				0xFE3FFFFFU
#define EURASIA_ISPA_DCMPMODE_SHIFT					22
#define EURASIA_ISPA_DCMPMODE_NEVER					(0UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_LT					(1UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_EQ					(2UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_LE					(3UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_GT					(4UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_NE					(5UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_GE					(6UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)
#define EURASIA_ISPA_DCMPMODE_ALWAYS				(7UL	<< EURASIA_ISPA_DCMPMODE_SHIFT)

#define EURASIA_ISPA_TAGWRITEDIS					(1UL << 21)
#define EURASIA_ISPA_DWRITEDIS						(1UL << 20)
#define EURASIA_ISPA_LINEFILLLASTPIXEL				(1UL << 19)

#define EURASIA_ISPA_OBJTYPE_SHIFT					15
#define EURASIA_ISPA_OBJTYPE_TRI					(0UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_LINE					(1UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_SPRITE10UV				(2UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_SPRITEUV				(3UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_SPRITE01UV				(4UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_LINETRI				(5UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_POINTTRI				(6UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_RESERVED0				(7UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)

#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)
#define EURASIA_ISPA_VISBOOL						(1UL << 18)
#define EURASIA_ISPA_OBJTYPE_CLRMSK					0xFFFC7FFFU
#else
#define EURASIA_ISPA_OBJTYPE_CLRMSK					0xFFF87FFFU
#define EURASIA_ISPA_OBJTYPE_BREAKALWAYS			(8UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_BREAKEQUAL				(9UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_BREAKNOTEQUAL			(10UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_BREAKVALIDFAIL			(11UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_RESERVED1				(12UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_RESERVED2				(13UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_RESERVED3				(14UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#define EURASIA_ISPA_OBJTYPE_RESERVED4				(15UL	<< EURASIA_ISPA_OBJTYPE_SHIFT)
#endif


#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)

#define EURASIA_ISPA_VISTEST						(1UL << 14)

#define EURASIA_ISPA_VISREGHI_CLRMSK				0xFFFFCFFFU
#define EURASIA_ISPA_VISREGHI_SHIFT					12
#define EURASIA_ISPA_VISREGHI_VISREG_SHIFT			12

#else

#define EURASIA_ISPA_VISBPREG_CLRMSK				0xFFFF8FFFU
#define EURASIA_ISPA_VISBPREG_SHIFT					12

#endif

#define EURASIA_ISPA_2SIDED							(1UL << 11)
#define EURASIA_ISPA_BFNFF_HWONLY					(1UL << 10)
#define EURASIA_ISPA_BPRES							(1UL << 9)
#define EURASIA_ISPA_CPRES							(1UL << 8)

#define EURASIA_ISPA_SREF_CLRMSK					0xFFFFFF00U
#define EURASIA_ISPA_SREF_SHIFT						0

/* ISP State Word B */
#define EURASIA_ISPB_VALIDID_CLRMSK					0x03FFFFFFU
#define EURASIA_ISPB_VALIDID_SHIFT					26

#if defined(SGX_FEATURE_VISTEST_IN_MEMORY)

	#define EURASIA_ISPB_DBIASFACTOR_CLRMSK				0xFC1FFFFFU
	#define EURASIA_ISPB_DBIASFACTOR_SHIFT				21

	#define EURASIA_ISPB_DBIASUNITS_CLRMSK				0xFFE0FFFFU
	#define EURASIA_ISPB_DBIASUNITS_SHIFT				16

	#define EURASIA_ISPB_UPASSCTL_CLRMSK				0xFFFF0FFFU
	#define EURASIA_ISPB_UPASSCTL_SHIFT					12
	#define EURASIA_ISPB_UPASSCTL_MAX					15

	#define EURASIA_ISPB_VISREGLO_CLRMSK				0xFFFFF000U
	#define EURASIA_ISPB_VISREGLO_SHIFT					0

#else /* SGX_FEATURE_VISTEST_IN_MEMORY */


#if defined(SGX545)
#if defined(FIX_HW_BRN_27792)
	#define EURASIA_ISPB_DBIASFACTOR_CLRMSK				0xFC1FFFFFU
	#define EURASIA_ISPB_DBIASFACTOR_SHIFT				21

	#define EURASIA_ISPB_DBIASUNITS_CLRMSK				0xFFE0FFFFU
	#define EURASIA_ISPB_DBIASUNITS_SHIFT				16
#else
 	#define EURASIA_ISPB_DBIAS_ENABLE					0x00800000U
#endif /* #if defined(SGX545) */

	#define EURASIA_ISPB_PLWIDTH_CLRMSK					0xFFFF00FFU
	#define EURASIA_ISPB_PLWIDTH_SHIFT					8
	#define EURASIA_ISPB_PLWIDTH_MAX					0xFF
	#define EURASIA_ISPB_PLWIDTH_FRAC					4
	#define EURASIA_ISPB_PLWIDTH_ONE					(1UL << EURASIA_ISPB_PLWIDTH_FRAC)
#else /* SGX545 */

	#define EURASIA_ISPB_DBIASFACTOR_CLRMSK				0xFE0FFFFFU
	#define EURASIA_ISPB_DBIASFACTOR_SHIFT				20

	#define EURASIA_ISPB_DBIASUNITS_CLRMSK				0xFFF07FFFU
	#define EURASIA_ISPB_DBIASUNITS_SHIFT				15

#endif /* SGX545 */

#define EURASIA_ISPB_UPASSCTL_CLRMSK				0xFFFFFF0FU
#define EURASIA_ISPB_UPASSCTL_SHIFT					4
#define EURASIA_ISPB_UPASSCTL_MAX					15

#define EURASIA_ISPB_VISTEST						(1UL << 3)

#define EURASIA_ISPB_VISREG_CLRMSK					0xFFFFFFF8U
#define EURASIA_ISPB_VISREG_SHIFT					0

#endif /* SGX_FEATURE_VISTEST_IN_MEMORY */

/* ISP State Word C */
#define EURASIA_ISPC_SCMP_CLRMSK					0xF1FFFFFFU
#define EURASIA_ISPC_SCMP_SHIFT						25
#define EURASIA_ISPC_SCMP_NEVER						(0UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_LT						(1UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_EQ						(2UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_LE						(3UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_GT						(4UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_NE						(5UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_GE						(6UL	<< EURASIA_ISPC_SCMP_SHIFT)
#define EURASIA_ISPC_SCMP_ALWAYS					(7UL	<< EURASIA_ISPC_SCMP_SHIFT)

#define EURASIA_ISPC_SCMP_ISPMASKSET				(1UL << 25)
#define EURASIA_ISPC_SCMP_ISPMASKCLEAR				(0UL << 25)

#define EURASIA_ISPC_SOPALL_CLRMSK					0xFE00FFFFU

#define EURASIA_ISPC_SOP_KEEP						0U
#define EURASIA_ISPC_SOP_ZERO						1U
#define EURASIA_ISPC_SOP_REPLACE					2U
#define EURASIA_ISPC_SOP_INCSAT						3U
#define EURASIA_ISPC_SOP_DECSAT						4U
#define EURASIA_ISPC_SOP_INVERT						5U
#define EURASIA_ISPC_SOP_INC						6U
#define EURASIA_ISPC_SOP_DEC						7U

#define	EURASIA_ISPC_SOP1_CLRMSK					0xFE3FFFFFU
#define	EURASIA_ISPC_SOP1_SHIFT						22

#define	EURASIA_ISPC_SOP1_KEEP						(EURASIA_ISPC_SOP_KEEP		<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_ZERO						(EURASIA_ISPC_SOP_ZERO		<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_REPLACE					(EURASIA_ISPC_SOP_REPLACE	<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_INCSAT					(EURASIA_ISPC_SOP_INCSAT	<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_DECSAT					(EURASIA_ISPC_SOP_DECSAT	<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_INVERT					(EURASIA_ISPC_SOP_INVERT	<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_INC						(EURASIA_ISPC_SOP_INC		<< EURASIA_ISPC_SOP1_SHIFT)
#define	EURASIA_ISPC_SOP1_DEC						(EURASIA_ISPC_SOP_DEC		<< EURASIA_ISPC_SOP1_SHIFT)

#define	EURASIA_ISPC_SOP2_CLRMSK					0xFFC7FFFFU
#define	EURASIA_ISPC_SOP2_SHIFT						19

#define	EURASIA_ISPC_SOP2_KEEP						(EURASIA_ISPC_SOP_KEEP		<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_ZERO						(EURASIA_ISPC_SOP_ZERO		<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_REPLACE					(EURASIA_ISPC_SOP_REPLACE	<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_INCSAT					(EURASIA_ISPC_SOP_INCSAT	<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_DECSAT					(EURASIA_ISPC_SOP_DECSAT	<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_INVERT					(EURASIA_ISPC_SOP_INVERT	<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_INC						(EURASIA_ISPC_SOP_INC		<< EURASIA_ISPC_SOP2_SHIFT)
#define	EURASIA_ISPC_SOP2_DEC						(EURASIA_ISPC_SOP_DEC		<< EURASIA_ISPC_SOP2_SHIFT)

#define	EURASIA_ISPC_SOP3_CLRMSK					0xFFF8FFFFU
#define	EURASIA_ISPC_SOP3_SHIFT						16

#define	EURASIA_ISPC_SOP3_KEEP						(EURASIA_ISPC_SOP_KEEP		<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_ZERO						(EURASIA_ISPC_SOP_ZERO		<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_REPLACE					(EURASIA_ISPC_SOP_REPLACE	<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_INCSAT					(EURASIA_ISPC_SOP_INCSAT	<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_DECSAT					(EURASIA_ISPC_SOP_DECSAT	<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_INVERT					(EURASIA_ISPC_SOP_INVERT	<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_INC						(EURASIA_ISPC_SOP_INC		<< EURASIA_ISPC_SOP3_SHIFT)
#define	EURASIA_ISPC_SOP3_DEC						(EURASIA_ISPC_SOP_DEC		<< EURASIA_ISPC_SOP3_SHIFT)

#define	EURASIA_ISPC_SCMPMASK_CLRMSK				0xFFFF00FFU
#define	EURASIA_ISPC_SCMPMASK_SHIFT					8

#define	EURASIA_ISPC_SWMASK_CLRMSK					0xFFFFFF00U
#define	EURASIA_ISPC_SWMASK_SHIFT					0

/*****************************************************************************
 PDS pixel state
*****************************************************************************/

#if defined(SGX_FEATURE_PIXEL_PDSADDR_FULL_RANGE)
	/* PDS State Pointer Word */
	#define	EURASIA_PDS_DATASIZE_CLRMSK					0x07FFFFFFU
	#define	EURASIA_PDS_DATASIZE_SHIFT					27
	#define	EURASIA_PDS_DATASIZE_ALIGNSHIFT				4U

	#define	EURASIA_PDS_BASEADD_CLRMSK					0xF8000000U
	#define	EURASIA_PDS_BASEADD_SHIFT					0
	#define	EURASIA_PDS_BASEADD_ALIGNSHIFT				4U

	/* PDS State Size Word */
	#define EURASIA_PDS_PIXELSIZE_CLRMSK				0x07FFFFFFU
	#define EURASIA_PDS_PIXELSIZE_SHIFT					27

	#define EURASIA_PDS_PDSPARTIAL						(1UL << 26)

	#define EURASIA_PDS_PDSTASKSIZE_CLRMSK				0xFC3FFFFFU
	#define EURASIA_PDS_PDSTASKSIZE_SHIFT				22

	#define EURASIA_PDS_SECATTRSIZE_CLRMSK				0xFFC1FFFFU
	#define EURASIA_PDS_SECATTRSIZE_SHIFT				17

	#define EURASIA_PDS_USETASKSIZE_CLRMSK				0xFFFE7FFFU
	#define EURASIA_PDS_USETASKSIZE_SHIFT				15

	#define EURASIA_PDS_BASEADD_SEC_MSB					(1UL << 14)
	#define EURASIA_PDS_BASEADD_PRIM_MSB				(1UL << 13)

	#define EURASIA_PDS_BASEADD_MSB						(1UL << 31)


	/* This bit has been removed (hw infers it) on some cores, but to make the drivers more consistent
	 * just make it 0
	 */
	#define EURASIA_PDS_USE_SEC_EXEC					0x00000000U


#else

	/* PDS State Pointer Word */
	#define	EURASIA_PDS_DATASIZE_CLRMSK					0x03FFFFFFU
	#define	EURASIA_PDS_DATASIZE_SHIFT					26
	#define	EURASIA_PDS_DATASIZE_ALIGNSHIFT				4U

	#define	EURASIA_PDS_DEBUG							(1UL << 25)

	#define	EURASIA_PDS_BASEADD_CLRMSK					0xFF000000U
	#define	EURASIA_PDS_BASEADD_SHIFT					0
	#define	EURASIA_PDS_BASEADD_ALIGNSHIFT				4U

	/* PDS State Size Word */
#if defined(SGX_FEATURE_ALPHATEST_SECONDARY) && defined(SGX_FEATURE_ALPHATEST_SECONDARY_PERPRIMITIVE)
	#define EURASIA_PDS_PT_SECONDARY					(1UL << 30)
#endif

	#define EURASIA_PDS_PDSTASKSIZE_CLRMSK				0xC1FFFFFFU
	#define EURASIA_PDS_PDSTASKSIZE_SHIFT				25

	#define EURASIA_PDS_SECATTRSIZE_CLRMSK				0xFE03FFFFU
	#define EURASIA_PDS_SECATTRSIZE_SHIFT				18

	#define EURASIA_PDS_USETASKSIZE_CLRMSK				0xFFFCFFFFU
	#define EURASIA_PDS_USETASKSIZE_SHIFT				16

#if defined(SGX_FEATURE_SECONDARY_REQUIRES_USE_KICK)
	/* This bit has been removed (hw infers it) on some cores, but to make the drivers more consistent
	 * just make it 0
	 */
	#define EURASIA_PDS_USE_SEC_EXEC					0x00000000U
#else
	#define EURASIA_PDS_USE_SEC_EXEC					0x00008000U
	#endif

#if defined(SGX545)
	#define EURASIA_PDS_RESERVED_SHIFT					7
	#define EURASIA_PDS_RESERVED_CLRMSK					0xFFFF807FU
#endif

	#define EURASIA_PDS_PIXELSIZE_CLRMSK				0xFFFFFF80U
	#define EURASIA_PDS_PIXELSIZE_SHIFT					0

#endif /* 543 */

#if defined(SGX545)
	#define EURASIA_PDS_SECATTRSIZE_ALIGNSHIFT			4U
#else
    #define EURASIA_PDS_SECATTRSIZE_ALIGNSHIFT		    7U
#endif

#if defined(SGX520) || defined(SGX535) || defined(SGX535_V1_1) || defined(SGX545)
	#define EURASIA_PDS_PDSTASKSIZE_MAX				32
#else
	#if defined(SGX530) || defined(SGX540) || defined(SGX541) || defined(SGX531) || defined(SGX543) || defined(SGX544) || defined(SGX554)
		#define EURASIA_PDS_PDSTASKSIZE_MAX				16
	#endif
#endif

#if defined(SGX520)
	#define EURASIA_PDS_USETASKSIZE_MAXSIZE			1
#else
	#define EURASIA_PDS_USETASKSIZE_MAXSIZE			3
#endif

#if defined(SGX535) || defined(SGX535_V1_1) || defined(SGX545)
	#define EURASIA_PDS_USESIZETOPDSSIZE_MAX_RATIO		8
#else
	#if defined(SGX530) || defined(SGX520) || defined(SGX540) || defined(SGX541) || defined(SGX531) || defined(SGX543) || defined(SGX544) || defined(SGX554)
		#define EURASIA_PDS_USESIZETOPDSSIZE_MAX_RATIO		4
	#endif
#endif

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
#define EURASIA_PDS_PIXELSIZE_ALIGNSIZE				4
#define EURASIA_PDS_PIXELSIZE_ALIGNSHIFT			2U
#else
#define EURASIA_PDS_PIXELSIZE_ALIGNSIZE				1
#define EURASIA_PDS_PIXELSIZE_ALIGNSHIFT			0U
#endif

/*****************************************************************************
 Region Clip
*****************************************************************************/

/* Region Clip Word 0 */
#define	EURASIA_TARGNCLIP_MODE_CLRMSK				0x3FFFFFFFU
#define	EURASIA_TARGNCLIP_MODE_SHIFT				30
#define	EURASIA_TARGNCLIP_MODE_NONE					(0UL << EURASIA_TARGNCLIP_MODE_SHIFT)
#define	EURASIA_TARGNCLIP_MODE_OUTSIDE				(2UL << EURASIA_TARGNCLIP_MODE_SHIFT)

#define	EURASIA_TARGNCLIP_LEFT_SHIFT				16
#if defined(SGX520)
	#define	EURASIA_TARGNCLIP_LEFT_CLRMSK			0xFE00FFFFU
#else
	#define	EURASIA_TARGNCLIP_LEFT_CLRMSK			0xFF00FFFFU
#endif

#define	EURASIA_TARGNCLIP_RIGHT_SHIFT				0
#if defined(SGX520)
	#define	EURASIA_TARGNCLIP_RIGHT_CLRMSK			0xFFFFFE00U
#else
	#define	EURASIA_TARGNCLIP_RIGHT_CLRMSK			0xFFFFFF00U
#endif

/* Region Clip Word 1 */
#if defined(SGX545)
	#define	EURASIA_TARGNCLIP_TOP_CLRMSK				0xFE00FFFFU
	#define	EURASIA_TARGNCLIP_TOP_SHIFT					16

	#define	EURASIA_TARGNCLIP_BOTTOM_CLRMSK				0xFFFFFE00U
	#define	EURASIA_TARGNCLIP_BOTTOM_SHIFT				0
#else
	#define	EURASIA_TARGNCLIP_TOP_CLRMSK				0xFF00FFFFU
	#define	EURASIA_TARGNCLIP_TOP_SHIFT					16

	#define	EURASIA_TARGNCLIP_BOTTOM_CLRMSK				0xFFFFFF00U
	#define	EURASIA_TARGNCLIP_BOTTOM_SHIFT				0
#endif

/* Alignments based on the ISP tile size.. */
#if defined(SGX520)
	#define	EURASIA_TARGNCLIP_LEFT_ALIGNSIZE			16
	#define	EURASIA_TARGNCLIP_LEFT_ALIGNSHIFT			4U

	#define	EURASIA_TARGNCLIP_RIGHT_ALIGNSIZE			16
	#define	EURASIA_TARGNCLIP_RIGHT_ALIGNSHIFT			4U
#else
	#define	EURASIA_TARGNCLIP_LEFT_ALIGNSIZE			EURASIA_ISPREGION_SIZEX
	#define	EURASIA_TARGNCLIP_LEFT_ALIGNSHIFT			EURASIA_ISPREGION_SHIFTX

	#define	EURASIA_TARGNCLIP_RIGHT_ALIGNSIZE			EURASIA_ISPREGION_SIZEX
	#define	EURASIA_TARGNCLIP_RIGHT_ALIGNSHIFT			EURASIA_ISPREGION_SHIFTX
#endif

#define	EURASIA_TARGNCLIP_TOP_ALIGNSIZE				EURASIA_ISPREGION_SIZEY
#define	EURASIA_TARGNCLIP_TOP_ALIGNSHIFT			EURASIA_ISPREGION_SHIFTY

#define	EURASIA_TARGNCLIP_BOTTOM_ALIGNSIZE			EURASIA_ISPREGION_SIZEY
#define	EURASIA_TARGNCLIP_BOTTOM_ALIGNSHIFT			EURASIA_ISPREGION_SHIFTY

/*****************************************************************************
 Viewport
*****************************************************************************/

#define	EURASIA_VIEWPORT_A0							0 /* ???? */
#define	EURASIA_VIEWPORT_M0							0 /* ???? */
#define	EURASIA_VIEWPORT_A1							0 /* ???? */
#define	EURASIA_VIEWPORT_M1							0 /* ???? */
#define	EURASIA_VIEWPORT_A2							0 /* ???? */
#define	EURASIA_VIEWPORT_M2							0 /* ???? */

/*****************************************************************************
 Wrapping Control
*****************************************************************************/

#define	EURASIA_TAWRAP_WRAP9_CLRMSK					0xC7FFFFFFU
#define	EURASIA_TAWRAP_WRAP9_SHIFT					27
#define	EURASIA_TAWRAP_WRAP8_CLRMSK					0xF8FFFFFFU
#define	EURASIA_TAWRAP_WRAP8_SHIFT					24
#define	EURASIA_TAWRAP_WRAP7_CLRMSK					0xFF1FFFFFU
#define	EURASIA_TAWRAP_WRAP7_SHIFT					21
#define	EURASIA_TAWRAP_WRAP6_CLRMSK					0xFFE3FFFFU
#define	EURASIA_TAWRAP_WRAP6_SHIFT					18
#define	EURASIA_TAWRAP_WRAP5_CLRMSK					0xFFFC7FFFU
#define	EURASIA_TAWRAP_WRAP5_SHIFT					15
#define	EURASIA_TAWRAP_WRAP4_CLRMSK					0xFFFF8FFFU
#define	EURASIA_TAWRAP_WRAP4_SHIFT					12
#define	EURASIA_TAWRAP_WRAP3_CLRMSK					0xFFFFF1FFU
#define	EURASIA_TAWRAP_WRAP3_SHIFT					9
#define	EURASIA_TAWRAP_WRAP2_CLRMSK					0xFFFFFE3FU
#define	EURASIA_TAWRAP_WRAP2_SHIFT					6
#define	EURASIA_TAWRAP_WRAP1_CLRMSK					0xFFFFFFC7U
#define	EURASIA_TAWRAP_WRAP1_SHIFT					3
#define	EURASIA_TAWRAP_WRAP0_CLRMSK					0xFFFFFFF8U
#define	EURASIA_TAWRAP_WRAP0_SHIFT					0

#define	EURASIA_TAWRAP_WRAPS9						(1UL << 29)
#define	EURASIA_TAWRAP_WRAPV9						(1UL << 28)
#define	EURASIA_TAWRAP_WRAPU9						(1UL << 27)
#define	EURASIA_TAWRAP_WRAPS8						(1UL << 26)
#define	EURASIA_TAWRAP_WRAPV8						(1UL << 25)
#define	EURASIA_TAWRAP_WRAPU8						(1UL << 24)
#define	EURASIA_TAWRAP_WRAPS7						(1UL << 23)
#define	EURASIA_TAWRAP_WRAPV7						(1UL << 22)
#define	EURASIA_TAWRAP_WRAPU7						(1UL << 21)
#define	EURASIA_TAWRAP_WRAPS6						(1UL << 20)
#define	EURASIA_TAWRAP_WRAPV6						(1UL << 19)
#define	EURASIA_TAWRAP_WRAPU6						(1UL << 18)
#define	EURASIA_TAWRAP_WRAPS5						(1UL << 17)
#define	EURASIA_TAWRAP_WRAPV5						(1UL << 16)
#define	EURASIA_TAWRAP_WRAPU5						(1UL << 15)
#define	EURASIA_TAWRAP_WRAPS4						(1UL << 14)
#define	EURASIA_TAWRAP_WRAPV4						(1UL << 13)
#define	EURASIA_TAWRAP_WRAPU4						(1UL << 12)
#define	EURASIA_TAWRAP_WRAPS3						(1UL << 11)
#define	EURASIA_TAWRAP_WRAPV3						(1UL << 10)
#define	EURASIA_TAWRAP_WRAPU3						(1UL << 9)
#define	EURASIA_TAWRAP_WRAPS2						(1UL << 8)
#define	EURASIA_TAWRAP_WRAPV2						(1UL << 7)
#define	EURASIA_TAWRAP_WRAPU2						(1UL << 6)
#define	EURASIA_TAWRAP_WRAPS1						(1UL << 5)
#define	EURASIA_TAWRAP_WRAPV1						(1UL << 4)
#define	EURASIA_TAWRAP_WRAPU1						(1UL << 3)
#define	EURASIA_TAWRAP_WRAPS0						(1UL << 2)
#define	EURASIA_TAWRAP_WRAPV0						(1UL << 1)
#define	EURASIA_TAWRAP_WRAPU0						(1UL << 0)

// Generics...
#define	EURASIA_TAWRAP_WRAPS						(1UL << 2)
#define	EURASIA_TAWRAP_WRAPV						(1UL << 1)
#define	EURASIA_TAWRAP_WRAPU						(1UL << 0)
#define	EURASIA_TAWRAP_WRAP_MASK					(EURASIA_TAWRAP_WRAPS | EURASIA_TAWRAP_WRAPV | EURASIA_TAWRAP_WRAPU)

#if defined(SGX545)
	#define	EURASIA_TAWRAP_WRAP19_CLRMSK					0xC7FFFFFFU
	#define	EURASIA_TAWRAP_WRAP19_SHIFT					27
	#define	EURASIA_TAWRAP_WRAP18_CLRMSK					0xF8FFFFFFU
	#define	EURASIA_TAWRAP_WRAP18_SHIFT					24
	#define	EURASIA_TAWRAP_WRAP17_CLRMSK					0xFF1FFFFFU
	#define	EURASIA_TAWRAP_WRAP17_SHIFT					21
	#define	EURASIA_TAWRAP_WRAP16_CLRMSK					0xFFE3FFFFU
	#define	EURASIA_TAWRAP_WRAP16_SHIFT					18
	#define	EURASIA_TAWRAP_WRAP15_CLRMSK					0xFFFC7FFFU
	#define	EURASIA_TAWRAP_WRAP15_SHIFT					15
	#define	EURASIA_TAWRAP_WRAP14_CLRMSK					0xFFFF8FFFU
	#define	EURASIA_TAWRAP_WRAP14_SHIFT					12
	#define	EURASIA_TAWRAP_WRAP13_CLRMSK					0xFFFFF1FFU
	#define	EURASIA_TAWRAP_WRAP13_SHIFT					9
	#define	EURASIA_TAWRAP_WRAP12_CLRMSK					0xFFFFFE3FU
	#define	EURASIA_TAWRAP_WRAP12_SHIFT					6
	#define	EURASIA_TAWRAP_WRAP11_CLRMSK					0xFFFFFFC7U
	#define	EURASIA_TAWRAP_WRAP11_SHIFT					3
	#define	EURASIA_TAWRAP_WRAP10_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_TAWRAP_WRAP10_SHIFT					0

	#define	EURASIA_TAWRAP_WRAPS19						(1UL << 29)
	#define	EURASIA_TAWRAP_WRAPV19						(1UL << 28)
	#define	EURASIA_TAWRAP_WRAPU19						(1UL << 27)
	#define	EURASIA_TAWRAP_WRAPS18						(1UL << 26)
	#define	EURASIA_TAWRAP_WRAPV18						(1UL << 25)
	#define	EURASIA_TAWRAP_WRAPU18						(1UL << 24)
	#define	EURASIA_TAWRAP_WRAPS17						(1UL << 23)
	#define	EURASIA_TAWRAP_WRAPV17						(1UL << 22)
	#define	EURASIA_TAWRAP_WRAPU17						(1UL << 21)
	#define	EURASIA_TAWRAP_WRAPS16						(1UL << 20)
	#define	EURASIA_TAWRAP_WRAPV16						(1UL << 19)
	#define	EURASIA_TAWRAP_WRAPU16						(1UL << 18)
	#define	EURASIA_TAWRAP_WRAPS15						(1UL << 17)
	#define	EURASIA_TAWRAP_WRAPV15						(1UL << 16)
	#define	EURASIA_TAWRAP_WRAPU15						(1UL << 15)
	#define	EURASIA_TAWRAP_WRAPS14						(1UL << 14)
	#define	EURASIA_TAWRAP_WRAPV14						(1UL << 13)
	#define	EURASIA_TAWRAP_WRAPU14						(1UL << 12)
	#define	EURASIA_TAWRAP_WRAPS13						(1UL << 11)
	#define	EURASIA_TAWRAP_WRAPV13						(1UL << 10)
	#define	EURASIA_TAWRAP_WRAPU13						(1UL << 9)
	#define	EURASIA_TAWRAP_WRAPS12						(1UL << 8)
	#define	EURASIA_TAWRAP_WRAPV12						(1UL << 7)
	#define	EURASIA_TAWRAP_WRAPU12						(1UL << 6)
	#define	EURASIA_TAWRAP_WRAPS11						(1UL << 5)
	#define	EURASIA_TAWRAP_WRAPV11						(1UL << 4)
	#define	EURASIA_TAWRAP_WRAPU11						(1UL << 3)
	#define	EURASIA_TAWRAP_WRAPS10						(1UL << 2)
	#define	EURASIA_TAWRAP_WRAPV10						(1UL << 1)
	#define	EURASIA_TAWRAP_WRAPU10						(1UL << 0)

	#define	EURASIA_TAWRAP_WRAP29_CLRMSK					0xC7FFFFFFU
	#define	EURASIA_TAWRAP_WRAP29_SHIFT					27
	#define	EURASIA_TAWRAP_WRAP28_CLRMSK					0xF8FFFFFFU
	#define	EURASIA_TAWRAP_WRAP28_SHIFT					24
	#define	EURASIA_TAWRAP_WRAP27_CLRMSK					0xFF1FFFFFU
	#define	EURASIA_TAWRAP_WRAP27_SHIFT					21
	#define	EURASIA_TAWRAP_WRAP26_CLRMSK					0xFFE3FFFFU
	#define	EURASIA_TAWRAP_WRAP26_SHIFT					18
	#define	EURASIA_TAWRAP_WRAP25_CLRMSK					0xFFFC7FFFU
	#define	EURASIA_TAWRAP_WRAP25_SHIFT					15
	#define	EURASIA_TAWRAP_WRAP24_CLRMSK					0xFFFF8FFFU
	#define	EURASIA_TAWRAP_WRAP24_SHIFT					12
	#define	EURASIA_TAWRAP_WRAP23_CLRMSK					0xFFFFF1FFU
	#define	EURASIA_TAWRAP_WRAP23_SHIFT					9
	#define	EURASIA_TAWRAP_WRAP22_CLRMSK					0xFFFFFE3FU
	#define	EURASIA_TAWRAP_WRAP22_SHIFT					6
	#define	EURASIA_TAWRAP_WRAP21_CLRMSK					0xFFFFFFC7U
	#define	EURASIA_TAWRAP_WRAP21_SHIFT					3
	#define	EURASIA_TAWRAP_WRAP20_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_TAWRAP_WRAP20_SHIFT					0

	#define	EURASIA_TAWRAP_WRAPS29						(1UL << 29)
	#define	EURASIA_TAWRAP_WRAPV29						(1UL << 28)
	#define	EURASIA_TAWRAP_WRAPU29						(1UL << 27)
	#define	EURASIA_TAWRAP_WRAPS28						(1UL << 26)
	#define	EURASIA_TAWRAP_WRAPV28						(1UL << 25)
	#define	EURASIA_TAWRAP_WRAPU28						(1UL << 24)
	#define	EURASIA_TAWRAP_WRAPS27						(1UL << 23)
	#define	EURASIA_TAWRAP_WRAPV27						(1UL << 22)
	#define	EURASIA_TAWRAP_WRAPU27						(1UL << 21)
	#define	EURASIA_TAWRAP_WRAPS26						(1UL << 20)
	#define	EURASIA_TAWRAP_WRAPV26						(1UL << 19)
	#define	EURASIA_TAWRAP_WRAPU26						(1UL << 18)
	#define	EURASIA_TAWRAP_WRAPS25						(1UL << 17)
	#define	EURASIA_TAWRAP_WRAPV25						(1UL << 16)
	#define	EURASIA_TAWRAP_WRAPU25						(1UL << 15)
	#define	EURASIA_TAWRAP_WRAPS24						(1UL << 14)
	#define	EURASIA_TAWRAP_WRAPV24						(1UL << 13)
	#define	EURASIA_TAWRAP_WRAPU24						(1UL << 12)
	#define	EURASIA_TAWRAP_WRAPS23						(1UL << 11)
	#define	EURASIA_TAWRAP_WRAPV23						(1UL << 10)
	#define	EURASIA_TAWRAP_WRAPU23						(1UL << 9)
	#define	EURASIA_TAWRAP_WRAPS22						(1UL << 8)
	#define	EURASIA_TAWRAP_WRAPV22						(1UL << 7)
	#define	EURASIA_TAWRAP_WRAPU22						(1UL << 6)
	#define	EURASIA_TAWRAP_WRAPS21						(1UL << 5)
	#define	EURASIA_TAWRAP_WRAPV21						(1UL << 4)
	#define	EURASIA_TAWRAP_WRAPU21						(1UL << 3)
	#define	EURASIA_TAWRAP_WRAPS20						(1UL << 2)
	#define	EURASIA_TAWRAP_WRAPV20						(1UL << 1)
	#define	EURASIA_TAWRAP_WRAPU20						(1UL << 0)

	#define	EURASIA_TAWRAP_WRAP30_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_TAWRAP_WRAP30_SHIFT					0

	#define	EURASIA_TAWRAP_WRAPS30						(1UL << 2)
	#define	EURASIA_TAWRAP_WRAPV30						(1UL << 1)
	#define	EURASIA_TAWRAP_WRAPU30						(1UL << 0)
#endif

/*****************************************************************************
 Output Selects and Texture Coordinate Sizes
*****************************************************************************/

#if defined(SGX545)
	#define EURASIA_OUTPUTSELECT_WORDCOUNT 6
#else
	#define EURASIA_OUTPUTSELECT_WORDCOUNT 2
#endif

// TODO: Update these for 545...
#define	EURASIA_MTE_NUM_CLIPPLANES					8
#define	EURASIA_MTE_NUM_TEXCOORDS					10

/**
	MTE Output Selects.
*/
// word 0...
#if defined(SGX545)
	#define	EURASIA_MTE_CULLPLANE7						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+7))
	#define	EURASIA_MTE_CULLPLANE6						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+6))
	#define	EURASIA_MTE_CULLPLANE5						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+5))
	#define	EURASIA_MTE_CULLPLANE4						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+4))
	#define	EURASIA_MTE_CULLPLANE3						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+3))
	#define	EURASIA_MTE_CULLPLANE2						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+2))
	#define	EURASIA_MTE_CULLPLANE1						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+1))
	#define	EURASIA_MTE_CULLPLANE0						(1UL << (EURASIA_MTE_CULLPLANE_SHIFT+0))

	#define	EURASIA_MTE_CULLPLANE_CLRMSK				0xFFFFFF00U
	#define	EURASIA_MTE_CULLPLANE_SHIFT					24

	#define	EURASIA_MTE_VTXSIZE_CLRMSK					0xFF00FFFFU
	#define	EURASIA_MTE_VTXSIZE_SHIFT					16

	#define	EURASIA_MTE_VPT_TGT							(1UL << 15)

	#define	EURASIA_MTE_CLIPMODE_CLRMSK					0xFFFF9FFFU
	#define	EURASIA_MTE_CLIPMODE_SHIFT					13

	#define EURASIA_MTE_CLIPMODE_NONE					(0UL << EURASIA_MTE_CLIPMODE_SHIFT)
	#define EURASIA_MTE_CLIPMODE_FRONT_AND_REAR			(1UL << EURASIA_MTE_CLIPMODE_SHIFT)
	#define EURASIA_MTE_CLIPMODE_FRONT_AND_REAR_GEN		(2UL << EURASIA_MTE_CLIPMODE_SHIFT)
	#define EURASIA_MTE_CLIPMODE_RESERVED				(3UL << EURASIA_MTE_CLIPMODE_SHIFT)
#else
	#define	EURASIA_MTE_VTXSIZE_CLRMSK					0x80FFFFFFU
	#define	EURASIA_MTE_VTXSIZE_SHIFT					24
#endif

#define EURASIA_MTE_WPRESENT						(1UL << 12)
#define	EURASIA_MTE_BASE							(1UL << 11)
#define	EURASIA_MTE_OFFSET							(1UL << 10)
#if !defined(SGX545)
	#define	EURASIA_MTE_FOG							(1UL << 9)
#endif
#define	EURASIA_MTE_SIZE							(1UL << 8)

#define	EURASIA_MTE_PLANE7							(1UL << 7)
#define	EURASIA_MTE_PLANE6							(1UL << 6)
#define	EURASIA_MTE_PLANE5							(1UL << 5)
#define	EURASIA_MTE_PLANE4							(1UL << 4)
#define	EURASIA_MTE_PLANE3							(1UL << 3)
#define	EURASIA_MTE_PLANE2							(1UL << 2)
#define	EURASIA_MTE_PLANE1							(1UL << 1)
#define	EURASIA_MTE_PLANE0							(1UL << 0)

#define	EURASIA_MTE_PLANE_CLRMSK					0xFFFFFF00U
#define	EURASIA_MTE_PLANE_SHIFT						0

// word 1...
#if defined(SGX545)
	#define EURASIA_MTE_OUTPUTSIZE_CLRMSK				0xFFFFFF00U
	#define EURASIA_MTE_OUTPUTSIZE_SHIFT				0
#endif

/**
	MTE Output Selects Texture/Attribute Dimensions.

	[Note: On 545 these are called attribute layers
	and must be setup for all attributes (including
	offset, base, etc..)]
*/

#if defined(SGX545)
	#define	EURASIA_MTE_ATTRDIM9_CLRMSK					0xC7FFFFFFU
	#define	EURASIA_MTE_ATTRDIM9_SHIFT					27
	#define	EURASIA_MTE_ATTRDIM8_CLRMSK					0xF8FFFFFFU
	#define	EURASIA_MTE_ATTRDIM8_SHIFT					24
	#define	EURASIA_MTE_ATTRDIM7_CLRMSK					0xFF1FFFFFU
	#define	EURASIA_MTE_ATTRDIM7_SHIFT					21
	#define	EURASIA_MTE_ATTRDIM6_CLRMSK					0xFFE3FFFFU
	#define	EURASIA_MTE_ATTRDIM6_SHIFT					18
	#define	EURASIA_MTE_ATTRDIM5_CLRMSK					0xFFFC7FFFU
	#define	EURASIA_MTE_ATTRDIM5_SHIFT					15
	#define	EURASIA_MTE_ATTRDIM4_CLRMSK					0xFFFF8FFFU
	#define	EURASIA_MTE_ATTRDIM4_SHIFT					12
	#define	EURASIA_MTE_ATTRDIM3_CLRMSK					0xFFFFF1FFU
	#define	EURASIA_MTE_ATTRDIM3_SHIFT					9
	#define	EURASIA_MTE_ATTRDIM2_CLRMSK					0xFFFFFE3FU
	#define	EURASIA_MTE_ATTRDIM2_SHIFT					6
	#define	EURASIA_MTE_ATTRDIM1_CLRMSK					0xFFFFFFC7U
	#define	EURASIA_MTE_ATTRDIM1_SHIFT					3
	#define	EURASIA_MTE_ATTRDIM0_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_MTE_ATTRDIM0_SHIFT					0

	#define	EURASIA_MTE_ATTRDIM19_CLRMSK					0xC7FFFFFFU
	#define	EURASIA_MTE_ATTRDIM19_SHIFT					27
	#define	EURASIA_MTE_ATTRDIM18_CLRMSK					0xF8FFFFFFU
	#define	EURASIA_MTE_ATTRDIM18_SHIFT					24
	#define	EURASIA_MTE_ATTRDIM17_CLRMSK					0xFF1FFFFFU
	#define	EURASIA_MTE_ATTRDIM17_SHIFT					21
	#define	EURASIA_MTE_ATTRDIM16_CLRMSK					0xFFE3FFFFU
	#define	EURASIA_MTE_ATTRDIM16_SHIFT					18
	#define	EURASIA_MTE_ATTRDIM15_CLRMSK					0xFFFC7FFFU
	#define	EURASIA_MTE_ATTRDIM15_SHIFT					15
	#define	EURASIA_MTE_ATTRDIM14_CLRMSK					0xFFFF8FFFU
	#define	EURASIA_MTE_ATTRDIM14_SHIFT					12
	#define	EURASIA_MTE_ATTRDIM13_CLRMSK					0xFFFFF1FFU
	#define	EURASIA_MTE_ATTRDIM13_SHIFT					9
	#define	EURASIA_MTE_ATTRDIM12_CLRMSK					0xFFFFFE3FU
	#define	EURASIA_MTE_ATTRDIM12_SHIFT					6
	#define	EURASIA_MTE_ATTRDIM11_CLRMSK					0xFFFFFFC7U
	#define	EURASIA_MTE_ATTRDIM11_SHIFT					3
	#define	EURASIA_MTE_ATTRDIM10_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_MTE_ATTRDIM10_SHIFT					0

	#define	EURASIA_MTE_ATTRDIM29_CLRMSK					0xC7FFFFFFU
	#define	EURASIA_MTE_ATTRDIM29_SHIFT					27
	#define	EURASIA_MTE_ATTRDIM28_CLRMSK					0xF8FFFFFFU
	#define	EURASIA_MTE_ATTRDIM28_SHIFT					24
	#define	EURASIA_MTE_ATTRDIM27_CLRMSK					0xFF1FFFFFU
	#define	EURASIA_MTE_ATTRDIM27_SHIFT					21
	#define	EURASIA_MTE_ATTRDIM26_CLRMSK					0xFFE3FFFFU
	#define	EURASIA_MTE_ATTRDIM26_SHIFT					18
	#define	EURASIA_MTE_ATTRDIM25_CLRMSK					0xFFFC7FFFU
	#define	EURASIA_MTE_ATTRDIM25_SHIFT					15
	#define	EURASIA_MTE_ATTRDIM24_CLRMSK					0xFFFF8FFFU
	#define	EURASIA_MTE_ATTRDIM24_SHIFT					12
	#define	EURASIA_MTE_ATTRDIM23_CLRMSK					0xFFFFF1FFU
	#define	EURASIA_MTE_ATTRDIM23_SHIFT					9
	#define	EURASIA_MTE_ATTRDIM22_CLRMSK					0xFFFFFE3FU
	#define	EURASIA_MTE_ATTRDIM22_SHIFT					6
	#define	EURASIA_MTE_ATTRDIM21_CLRMSK					0xFFFFFFC7U
	#define	EURASIA_MTE_ATTRDIM21_SHIFT					3
	#define	EURASIA_MTE_ATTRDIM20_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_MTE_ATTRDIM20_SHIFT					0

	#define	EURASIA_MTE_ATTRDIM30_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_MTE_ATTRDIM30_SHIFT					0

	#define EURASIA_MTE_ATTRDIM_NOTPRESENT				0U
	#define EURASIA_MTE_ATTRDIM_U						1U
	#define EURASIA_MTE_ATTRDIM_UV						2U
	#define EURASIA_MTE_ATTRDIM_UVS						3U
	#define EURASIA_MTE_ATTRDIM_UVT						4U
	#define EURASIA_MTE_ATTRDIM_UVST					5U
#else
	#define	EURASIA_MTE_TEXDIM9_CLRMSK					0xC7FFFFFFU
	#define	EURASIA_MTE_TEXDIM9_SHIFT					27
	#define	EURASIA_MTE_TEXDIM8_CLRMSK					0xF8FFFFFFU
	#define	EURASIA_MTE_TEXDIM8_SHIFT					24
	#define	EURASIA_MTE_TEXDIM7_CLRMSK					0xFF1FFFFFU
	#define	EURASIA_MTE_TEXDIM7_SHIFT					21
	#define	EURASIA_MTE_TEXDIM6_CLRMSK					0xFFE3FFFFU
	#define	EURASIA_MTE_TEXDIM6_SHIFT					18
	#define	EURASIA_MTE_TEXDIM5_CLRMSK					0xFFFC7FFFU
	#define	EURASIA_MTE_TEXDIM5_SHIFT					15
	#define	EURASIA_MTE_TEXDIM4_CLRMSK					0xFFFF8FFFU
	#define	EURASIA_MTE_TEXDIM4_SHIFT					12
	#define	EURASIA_MTE_TEXDIM3_CLRMSK					0xFFFFF1FFU
	#define	EURASIA_MTE_TEXDIM3_SHIFT					9
	#define	EURASIA_MTE_TEXDIM2_CLRMSK					0xFFFFFE3FU
	#define	EURASIA_MTE_TEXDIM2_SHIFT					6
	#define	EURASIA_MTE_TEXDIM1_CLRMSK					0xFFFFFFC7U
	#define	EURASIA_MTE_TEXDIM1_SHIFT					3
	#define	EURASIA_MTE_TEXDIM0_CLRMSK					0xFFFFFFF8U
	#define	EURASIA_MTE_TEXDIM0_SHIFT					0

	#define	EURASIA_MTE_TEXDIM_CLRMSK					0xC0000000U
	#define	EURASIA_MTE_TEXDIM_SHIFT					0

	#define EURASIA_MTE_TEXDIM_UVPRESENT				1U
	#define EURASIA_MTE_TEXDIM_SPRESENT					2U
	#define EURASIA_MTE_TEXDIM_TPRESENT					4U

	#define	EURASIA_MTE_TEXDIM_NOTPRESENT				0U
	#define EURASIA_MTE_TEXDIM_UV						EURASIA_MTE_TEXDIM_UVPRESENT
	#define EURASIA_MTE_TEXDIM_UVS						(EURASIA_MTE_TEXDIM_UVPRESENT | EURASIA_MTE_TEXDIM_SPRESENT)
	#define EURASIA_MTE_TEXDIM_UVT						(EURASIA_MTE_TEXDIM_UVPRESENT | EURASIA_MTE_TEXDIM_TPRESENT)
	#define EURASIA_MTE_TEXDIM_UVST						(EURASIA_MTE_TEXDIM_UVPRESENT | EURASIA_MTE_TEXDIM_SPRESENT | EURASIA_MTE_TEXDIM_TPRESENT)
#endif

/*****************************************************************************
 Format of the USE output buffer for a vertex
*****************************************************************************/

#define EURASIA_MTE_OUTPUT_OFFSET_POSITION_X		(0x00)
#define EURASIA_MTE_OUTPUT_OFFSET_POSITION_Y		(0x04)
#define EURASIA_MTE_OUTPUT_OFFSET_POSITION_Z		(0x08)
#define EURASIA_MTE_OUTPUT_OFFSET_POSITION_W		(0x0C)
#define EURASIA_MTE_OUTPUT_OFFSET_BASECOLOUR		(0x10)
#define EURASIA_MTE_OUTPUT_OFFSET_OFFSETCOLOUR		(0x20)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD0_X		(0x30)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD0_Y		(0x34)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD0_Z		(0x38)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD0_W		(0x3C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD1_X		(0x40)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD1_Y		(0x44)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD1_Z		(0x48)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD1_W		(0x4C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD2_X		(0x50)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD2_Y		(0x54)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD2_Z		(0x58)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD2_W		(0x5C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD3_X		(0x60)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD3_Y		(0x64)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD3_Z		(0x68)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD3_W		(0x6C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD4_X		(0x70)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD4_Y		(0x74)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD4_Z		(0x78)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD4_W		(0x7C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD5_X		(0x80)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD5_Y		(0x84)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD5_Z		(0x88)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD5_W		(0x8C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD6_X		(0x90)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD6_Y		(0x94)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD6_Z		(0x98)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD6_W		(0x9C)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD7_X		(0xA0)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD7_Y		(0xA4)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD7_Z		(0xA8)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD7_W		(0xAC)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD8_X		(0xB0)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD8_Y		(0xB4)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD8_Z		(0xB8)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD8_W		(0xBC)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD9_X		(0xC0)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD9_Y		(0xC4)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD9_Z		(0xC8)
#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD9_W		(0xCC)

#if defined(SGX545)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD10_X		(0xD0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD10_Y		(0xD4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD10_Z		(0xD8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD10_W		(0xDC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD11_X		(0xE0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD11_Y		(0xE4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD11_Z		(0xE8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD11_W		(0xEC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD12_X		(0xF0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD12_Y		(0xF4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD12_Z		(0xF8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD12_W		(0xFC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD13_X		(0x100)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD13_Y		(0x104)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD13_Z		(0x108)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD13_W		(0x10C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD14_X		(0x110)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD14_Y		(0x114)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD14_Z		(0x118)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD14_W		(0x11C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD15_X		(0x120)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD15_Y		(0x124)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD15_Z		(0x128)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD15_W		(0x12C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD16_X		(0x130)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD16_Y		(0x134)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD16_Z		(0x138)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD16_W		(0x13C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD17_X		(0x140)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD17_Y		(0x144)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD17_Z		(0x148)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD17_W		(0x14C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD18_X		(0x150)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD18_Y		(0x154)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD18_Z		(0x158)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD18_W		(0x15C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD19_X		(0x160)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD19_Y		(0x164)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD19_Z		(0x168)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD19_W		(0x16C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD20_X		(0x170)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD20_Y		(0x174)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD20_Z		(0x178)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD20_W		(0x17C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD21_X		(0x180)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD21_Y		(0x184)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD21_Z		(0x188)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD21_W		(0x18C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD22_X		(0x190)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD22_Y		(0x194)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD22_Z		(0x198)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD22_W		(0x19C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD23_X		(0x1A0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD23_Y		(0x1A4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD23_Z		(0x1A8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD23_W		(0x1AC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD24_X		(0x1B0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD24_Y		(0x1B4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD24_Z		(0x1B8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD24_W		(0x1BC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD25_X		(0x1C0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD25_Y		(0x1C4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD25_Z		(0x1C8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD25_W		(0x1CC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD26_X		(0x1D0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD26_Y		(0x1D4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD26_Z		(0x1D8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD26_W		(0x1DC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD27_X		(0x1E0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD27_Y		(0x1E4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD27_Z		(0x1E8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD27_W		(0x1EC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD28_X		(0x1F0)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD28_Y		(0x1F4)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD28_Z		(0x1F8)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD28_W		(0x1FC)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD29_X		(0x200)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD29_Y		(0x204)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD29_Z		(0x208)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD29_W		(0x20C)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD30_X		(0x210)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD30_Y		(0x214)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD30_Z		(0x218)
	#define EURASIA_MTE_OUTPUT_OFFSET_TEXCOORD30_W		(0x21C)

	#define EURASIA_MTE_OUTPUT_OFFSET_POINTSIZE		(0x220)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT0		(0x224)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT1		(0x228)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT2		(0x23C)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT3		(0x230)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT4		(0x234)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT5		(0x238)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT6		(0x24C)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT7		(0x240)
#else
	#define EURASIA_MTE_OUTPUT_OFFSET_POINTSIZE		(0xD0)
	#define EURASIA_MTE_OUTPUT_OFFSET_FOGFACTOR		(0xD4)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT0		(0xD8)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT1		(0xDC)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT2		(0xE0)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT3		(0xE4)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT4		(0xE8)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT5		(0xEC)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT6		(0xF0)
	#define EURASIA_MTE_OUTPUT_OFFSET_CLIPRESULT7		(0xF4)
#endif

/*****************************************************************************
 Per Primitive Sample Position Word
*****************************************************************************/
#if defined(SGX545)
	#define EURASIA_MTE_VF_Y3_CLRMSK							(0x0FFFFFFFU)
	#define EURASIA_MTE_VF_Y3_SHIFT								(28)
	#define EURASIA_MTE_VF_X3_CLRMSK							(0xF0FFFFFFU)
	#define EURASIA_MTE_VF_X3_SHIFT								(24)
	#define EURASIA_MTE_VF_Y2_CLRMSK							(0xFF0FFFFFU)
	#define EURASIA_MTE_VF_Y2_SHIFT								(20)
	#define EURASIA_MTE_VF_X2_CLRMSK							(0xFFF0FFFFU)
	#define EURASIA_MTE_VF_X2_SHIFT								(16)
	#define EURASIA_MTE_VF_Y1_CLRMSK							(0xFFFF0FFFU)
	#define EURASIA_MTE_VF_Y1_SHIFT								(12)
	#define EURASIA_MTE_VF_X1_CLRMSK							(0xFFFFF0FFU)
	#define EURASIA_MTE_VF_X1_SHIFT								(8)
	#define EURASIA_MTE_VF_Y0_CLRMSK							(0xFFFFFF0FU)
	#define EURASIA_MTE_VF_Y0_SHIFT								(4)
	#define EURASIA_MTE_VF_X0_CLRMSK							(0xFFFFFFF0U)
	#define EURASIA_MTE_VF_X0_SHIFT								(0)
#endif

/*****************************************************************************
 Per Instance ID Word
*****************************************************************************/
#if defined(SGX545)
	#define EURASIA_MTE_INSTANCEID_CLRMSK						(0xFF000000U)
	#define EURASIA_MTE_INSTANCEID_SHIFT						(0)
#endif

/*****************************************************************************
 W Clamping
*****************************************************************************/

#define	EURASIA_WCLAMPING							0 /* ???? */

/*****************************************************************************
 MTE Control
*****************************************************************************/

#if defined(SGX545)
	#define	EURASIA_MTE_INTERPOLATIONMODE30_CLRMSK		0xFFCFFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE30_SHIFT		20
	#define	EURASIA_MTE_INTERPOLATIONMODE29_CLRMSK		0xFFF3FFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE29_SHIFT		18
	#define	EURASIA_MTE_INTERPOLATIONMODE28_CLRMSK		0xFFFCFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE28_SHIFT		16
	#define	EURASIA_MTE_INTERPOLATIONMODE27_CLRMSK		0xFFFF3FFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE27_SHIFT		14
	#define	EURASIA_MTE_INTERPOLATIONMODE26_CLRMSK		0xFFFFCFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE26_SHIFT		12
	#define	EURASIA_MTE_INTERPOLATIONMODE25_CLRMSK		0xFFFFF3FFU
	#define	EURASIA_MTE_INTERPOLATIONMODE25_SHIFT		10
	#define	EURASIA_MTE_INTERPOLATIONMODE24_CLRMSK		0xFFFFFCFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE24_SHIFT		8
	#define	EURASIA_MTE_INTERPOLATIONMODE23_CLRMSK		0xFFFFFF3FU
	#define	EURASIA_MTE_INTERPOLATIONMODE23_SHIFT		6
	#define	EURASIA_MTE_INTERPOLATIONMODE22_CLRMSK		0xFFFFFFCFU
	#define	EURASIA_MTE_INTERPOLATIONMODE22_SHIFT		4
	#define	EURASIA_MTE_INTERPOLATIONMODE21_CLRMSK		0xFFFFFFF3U
	#define	EURASIA_MTE_INTERPOLATIONMODE21_SHIFT		2
	#define	EURASIA_MTE_INTERPOLATIONMODE20_CLRMSK		0xFFFFFFFCU
	#define	EURASIA_MTE_INTERPOLATIONMODE20_SHIFT		0

	#define	EURASIA_MTE_INTERPOLATIONMODE19_CLRMSK		0xFFF3FFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE19_SHIFT		18
	#define	EURASIA_MTE_INTERPOLATIONMODE18_CLRMSK		0xFFFCFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE18_SHIFT		16
	#define	EURASIA_MTE_INTERPOLATIONMODE17_CLRMSK		0xFFFF3FFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE17_SHIFT		14
	#define	EURASIA_MTE_INTERPOLATIONMODE16_CLRMSK		0xFFFFCFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE16_SHIFT		12
	#define	EURASIA_MTE_INTERPOLATIONMODE15_CLRMSK		0xFFFFF3FFU
	#define	EURASIA_MTE_INTERPOLATIONMODE15_SHIFT		10
	#define	EURASIA_MTE_INTERPOLATIONMODE14_CLRMSK		0xFFFFFCFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE14_SHIFT		8
	#define	EURASIA_MTE_INTERPOLATIONMODE13_CLRMSK		0xFFFFFF3FU
	#define	EURASIA_MTE_INTERPOLATIONMODE13_SHIFT		6
	#define	EURASIA_MTE_INTERPOLATIONMODE12_CLRMSK		0xFFFFFFCFU
	#define	EURASIA_MTE_INTERPOLATIONMODE12_SHIFT		4
	#define	EURASIA_MTE_INTERPOLATIONMODE11_CLRMSK		0xFFFFFFF3U
	#define	EURASIA_MTE_INTERPOLATIONMODE11_SHIFT		2
	#define	EURASIA_MTE_INTERPOLATIONMODE10_CLRMSK		0xFFFFFFFCU
	#define	EURASIA_MTE_INTERPOLATIONMODE10_SHIFT		0

	#define	EURASIA_MTE_INTERPOLATIONMODE9_CLRMSK		0xCFFFFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE9_SHIFT		28
	#define	EURASIA_MTE_INTERPOLATIONMODE8_CLRMSK		0xF3FFFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE8_SHIFT		26
	#define	EURASIA_MTE_INTERPOLATIONMODE7_CLRMSK		0xFCFFFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE7_SHIFT		24
	#define	EURASIA_MTE_INTERPOLATIONMODE6_CLRMSK		0xFF3FFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE6_SHIFT		22
	#define	EURASIA_MTE_INTERPOLATIONMODE5_CLRMSK		0xFFCFFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE5_SHIFT		20
	#define	EURASIA_MTE_INTERPOLATIONMODE4_CLRMSK		0xFFF3FFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE4_SHIFT		18
	#define	EURASIA_MTE_INTERPOLATIONMODE3_CLRMSK		0xFFFCFFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE3_SHIFT		16
	#define	EURASIA_MTE_INTERPOLATIONMODE2_CLRMSK		0xFFFF3FFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE2_SHIFT		14
	#define	EURASIA_MTE_INTERPOLATIONMODE1_CLRMSK		0xFFFFCFFFU
	#define	EURASIA_MTE_INTERPOLATIONMODE1_SHIFT		12
	#define	EURASIA_MTE_INTERPOLATIONMODE0_CLRMSK		0xFFFFF3FFU
	#define	EURASIA_MTE_INTERPOLATIONMODE0_SHIFT		10

	#define EURASIA_MTE_INTERPOLATIONMODE0TO9_CLRMSK	0xC00003FFU

	#define	EURASIA_MTE_INTERPOLATIONMODE_FLATSHADE			0
	#define	EURASIA_MTE_INTERPOLATIONMODE_GOURAUD			1
	#define	EURASIA_MTE_INTERPOLATIONMODE_NONPERSPECTIVE	2
	#define	EURASIA_MTE_INTERPOLATIONMODE_RESERVED			3

	#define EURASIA_MTE_INTERPOLATIONMODE_MASK				0x3U

	#define EURASIA_MTE_DRAWCLIPPEDEDGES				(1UL << 9)

	#define EURASIA_MTE_SHADE_CLRMSK					0xFFFFFE7FU
	#define EURASIA_MTE_SHADE_SHIFT						7
	#define EURASIA_MTE_SHADE_RESERVED					(0UL << EURASIA_MTE_SHADE_SHIFT)
	#define EURASIA_MTE_SHADE_VERTEX0					(1UL << EURASIA_MTE_SHADE_SHIFT)
	#define EURASIA_MTE_SHADE_VERTEX1					(2UL << EURASIA_MTE_SHADE_SHIFT)
	#define EURASIA_MTE_SHADE_VERTEX2					(3UL << EURASIA_MTE_SHADE_SHIFT)

	#define EURASIA_MTE_PRETRANSFORM					(1UL << 6)

	#define	EURASIA_MTE_WCLAMPEN						(1UL << 5)

	#define	EURASIA_MTE_WBUFFEN							(1UL << 4)
#else
	#define EURASIA_MTE_DRAWCLIPPEDEDGES				(1UL << 19)

	#define EURASIA_MTE_SHADE_CLRMSK					0xFFF9FFFFU
	#define EURASIA_MTE_SHADE_SHIFT						17
	#define EURASIA_MTE_SHADE_GOURAUD					(0UL << EURASIA_MTE_SHADE_SHIFT)
	#define EURASIA_MTE_SHADE_VERTEX0					(1UL << EURASIA_MTE_SHADE_SHIFT)
	#define EURASIA_MTE_SHADE_VERTEX1					(2UL << EURASIA_MTE_SHADE_SHIFT)
	#define EURASIA_MTE_SHADE_VERTEX2					(3UL << EURASIA_MTE_SHADE_SHIFT)

	#define EURASIA_MTE_PRETRANSFORM					(1UL << 16)

	#define	EURASIA_MTE_WCLAMPEN						(1UL << 15)

	#define	EURASIA_MTE_WBUFFEN							(1UL << 14)

	#define	EURASIA_MTE_COORDISCOL_CLRMSK				0xFFFFC00FU
	#define	EURASIA_MTE_COORDISCOL_SHIFT				4
	#define	EURASIA_MTE_COORDISCOL0						(1UL << 13)
	#define	EURASIA_MTE_COORDISCOL1						(1UL << 12)
	#define	EURASIA_MTE_COORDISCOL2						(1UL << 11)
	#define	EURASIA_MTE_COORDISCOL3						(1UL << 10)
	#define	EURASIA_MTE_COORDISCOL4						(1UL << 9)
	#define	EURASIA_MTE_COORDISCOL5						(1UL << 8)
	#define	EURASIA_MTE_COORDISCOL6						(1UL << 7)
	#define	EURASIA_MTE_COORDISCOL7						(1UL << 6)
	#define	EURASIA_MTE_COORDISCOL8						(1UL << 5)
	#define	EURASIA_MTE_COORDISCOL9						(1UL << 4)
#endif

#define	EURASIA_MTE_RESETBBOX						(1UL << 3)

#define	EURASIA_MTE_UPDATEBBOX						(1UL << 2)

#define	EURASIA_MTE_CULLMODE_CLRMSK					0xFFFFFFFCU
#define	EURASIA_MTE_CULLMODE_SHIFT					0
#define	EURASIA_MTE_CULLMODE_NONE					(0UL	<< EURASIA_MTE_CULLMODE_SHIFT)
#define	EURASIA_MTE_CULLMODE_CW						(1UL	<< EURASIA_MTE_CULLMODE_SHIFT)
#define	EURASIA_MTE_CULLMODE_CCW					(2UL	<< EURASIA_MTE_CULLMODE_SHIFT)

/*****************************************************************************
 TE Bounding Box
*****************************************************************************/

#if defined(SGX545)
	#define EURASIA_TEBBOX_LR_ALIGNSIZE				32
	#define EURASIA_TEBBOX_LR_ALIGNSHIFT			5U
	#define EURASIA_TEBBOX_TB_ALIGNSIZE				16
	#define EURASIA_TEBBOX_TB_ALIGNSHIFT			4U
#else
	#if defined(SGX520)
		#define EURASIA_TEBBOX_LR_ALIGNSIZE			8
		#define EURASIA_TEBBOX_LR_ALIGNSHIFT		3U
		#define EURASIA_TEBBOX_TB_ALIGNSIZE			16
		#define EURASIA_TEBBOX_TB_ALIGNSHIFT		4U
	#else
		#define EURASIA_TEBBOX_LR_ALIGNSIZE			16
		#define EURASIA_TEBBOX_LR_ALIGNSHIFT		4U
		#define EURASIA_TEBBOX_TB_ALIGNSIZE			16
		#define EURASIA_TEBBOX_TB_ALIGNSHIFT		4U
	#endif
#endif

/*****************************************************************************
 Terminate
*****************************************************************************/

#define	EURASIA_TARNDCLIP_LEFT_CLRMSK				0x00FFFFFFU
#define	EURASIA_TARNDCLIP_LEFT_SHIFT				24
#define	EURASIA_TARNDCLIP_RIGHT_CLRMSK				0xFF00FFFFU
#define	EURASIA_TARNDCLIP_RIGHT_SHIFT				16
#define	EURASIA_TARNDCLIP_TOP_CLRMSK				0xFFFF00FFU
#define	EURASIA_TARNDCLIP_TOP_SHIFT					8
#define	EURASIA_TARNDCLIP_BOTTOM_CLRMSK				0xFFFFFF00U
#define	EURASIA_TARNDCLIP_BOTTOM_SHIFT				0

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_TARNDCLIP_LR_ALIGNSIZE			32U
	#define EURASIA_TARNDCLIP_LR_ALIGNSHIFT			5U
	#define EURASIA_TARNDCLIP_TB_ALIGNSIZE			32U
	#define EURASIA_TARNDCLIP_TB_ALIGNSHIFT			5U
#else
	#if defined(SGX520)
		#define EURASIA_TARNDCLIP_LR_ALIGNSIZE		16U
		#define EURASIA_TARNDCLIP_LR_ALIGNSHIFT		4U
		#define EURASIA_TARNDCLIP_TB_ALIGNSIZE		16U
		#define EURASIA_TARNDCLIP_TB_ALIGNSHIFT		4U
	#else
		#define EURASIA_TARNDCLIP_LR_ALIGNSIZE		16U
		#define EURASIA_TARNDCLIP_LR_ALIGNSHIFT		4U
		#define EURASIA_TARNDCLIP_TB_ALIGNSIZE		16U
		#define EURASIA_TARNDCLIP_TB_ALIGNSHIFT		4U
	#endif
#endif

/*****************************************************************************
 Texture coordinate formats
*****************************************************************************/
#define EURASIA_TATEXFLOAT_TC0_16B					(1UL << 0)
#define EURASIA_TATEXFLOAT_TC1_16B					(1UL << 1)
#define EURASIA_TATEXFLOAT_TC2_16B					(1UL << 2)
#define EURASIA_TATEXFLOAT_TC3_16B					(1UL << 3)
#define EURASIA_TATEXFLOAT_TC4_16B					(1UL << 4)
#define EURASIA_TATEXFLOAT_TC5_16B					(1UL << 5)
#define EURASIA_TATEXFLOAT_TC6_16B					(1UL << 6)
#define EURASIA_TATEXFLOAT_TC7_16B					(1UL << 7)
#define EURASIA_TATEXFLOAT_TC8_16B					(1UL << 8)
#define EURASIA_TATEXFLOAT_TC9_16B					(1UL << 9)

/*****************************************************************************
 PDS Caches (sizes in bytes)
*****************************************************************************/

#define EURASIA_PDS_DATA_CACHE_LINE_SIZE			32
#define EURASIA_PDS_CODE_CACHE_LINE_SIZE			64

#define EURASIA_PDS_DATA_CACHE_SIZE					(EURASIA_PDS_DATA_CACHE_LINE_SIZE * 2 * 8)
/*****************************************************************************
 Effective line size for PDS programs (since data and code are adjacent)
*****************************************************************************/

#define EURASIA_PDS_PROG_CACHE_LINE_SIZE			max(EURASIA_PDS_DATA_CACHE_LINE_SIZE, EURASIA_PDS_CODE_CACHE_LINE_SIZE)

/*****************************************************************************
 PDS Data Store
*****************************************************************************/

#define EURASIA_PDS_DATASTORE_TEMPSTART				48U

#define EURASIA_PDS_DATASTORE_CONSTANTCOUNT			EURASIA_PDS_DATASTORE_TEMPSTART

#define EURASIA_PDS_DATASTORE_PERBANKSIZE			64U

#define EURASIA_PDS_DATASTORE_TEMPCOUNT				(EURASIA_PDS_DATASTORE_PERBANKSIZE - EURASIA_PDS_DATASTORE_TEMPSTART)

#define EURASIA_PDS_DATASTORE_BANKCOUNT				2U

#if (SGX_FEATURE_NUM_PDS_PIPES == 2)

#define EURASIA_PDS_CACHE_VERTEX_STATUS_MASK		(EUR_CR_PDS_CACHE_STATUS_CSC0_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_CSC1_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC0_INV0_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC1_INV0_MASK)

#define EURASIA_PDS_CACHE_VERTEX_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC0_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_CSC1_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC0_INV0_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC1_INV0_MASK)

#define EURASIA_PDS_CACHE_PIXEL_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_CSC0_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_CSC1_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC0_INV1_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC1_INV1_MASK)

#define EURASIA_PDS_CACHE_PIXEL_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC0_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_CSC1_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC0_INV1_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC1_INV1_MASK)

#define EURASIA_PDS_CACHE_EVENT_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_CSC0_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_CSC1_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC0_INV3_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC1_INV3_MASK)

#define EURASIA_PDS_CACHE_EVENT_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC0_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_CSC1_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC0_INV3_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC1_INV3_MASK)

#else

	#if defined(EUR_CR_PDS_CACHE_STATUS_DSC1_INV1_MASK)

#define EURASIA_PDS_CACHE_VERTEX_STATUS_MASK		(EUR_CR_PDS_CACHE_STATUS_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC0_INV0_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC1_INV0_MASK)

#define EURASIA_PDS_CACHE_VERTEX_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC0_INV0_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC1_INV0_MASK)

#define EURASIA_PDS_CACHE_PIXEL_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC0_INV1_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC1_INV1_MASK)

#define EURASIA_PDS_CACHE_PIXEL_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC0_INV1_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC1_INV1_MASK)

#define EURASIA_PDS_CACHE_EVENT_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC0_INV3_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC1_INV3_MASK)

#define EURASIA_PDS_CACHE_EVENT_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC0_INV3_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC1_INV3_MASK)

	#else
		#if defined(FIX_HW_BRN_31474)
	
#define EURASIA_PDS_CACHE_VERTEX_STATUS_MASK		(EUR_CR_PDS_CACHE_STATUS_DSC_INV0_MASK)
#define EURASIA_PDS_CACHE_VERTEX_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_DSC_INV0_MASK)

#define EURASIA_PDS_CACHE_PIXEL_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_DSC_INV1_MASK)
#define EURASIA_PDS_CACHE_PIXEL_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_DSC_INV1_MASK)

#define EURASIA_PDS_CACHE_EVENT_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_DSC_INV3_MASK)
#define EURASIA_PDS_CACHE_EVENT_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_DSC_INV3_MASK)

		#else
	
#define EURASIA_PDS_CACHE_VERTEX_STATUS_MASK		(EUR_CR_PDS_CACHE_STATUS_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC_INV0_MASK)

#define EURASIA_PDS_CACHE_VERTEX_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC_INV0_MASK)

#define EURASIA_PDS_CACHE_PIXEL_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC_INV1_MASK)

#define EURASIA_PDS_CACHE_PIXEL_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC_INV1_MASK)

#define EURASIA_PDS_CACHE_EVENT_STATUS_MASK			(EUR_CR_PDS_CACHE_STATUS_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_STATUS_DSC_INV3_MASK)

#define EURASIA_PDS_CACHE_EVENT_CLEAR_MASK			(EUR_CR_PDS_CACHE_HOST_CLEAR_CSC_INV_MASK | \
													EUR_CR_PDS_CACHE_HOST_CLEAR_DSC_INV3_MASK)
		#endif
	#endif
#endif

/*****************************************************************************
 PDS Instruction Set
*****************************************************************************/

/* PDS Instruction size in bytes */
#define EURASIA_PDS_INSTRUCTION_SIZE               (4)

/* Instruction Groups */
#define	EURASIA_PDS_INST_CLRMSK						0x3FFFFFFFU
#define	EURASIA_PDS_INST_SHIFT						30
#define	EURASIA_PDS_INST_MOV						0U
#define	EURASIA_PDS_INST_ARITH						1U
#define	EURASIA_PDS_INST_FLOW						2U
#define	EURASIA_PDS_INST_LOGIC						3U

/* Instruction Types */
#define	EURASIA_PDS_TYPE_CLRMSK						0xC7FFFFFFU
#define	EURASIA_PDS_TYPE_SHIFT						27

/* Data Move Instruction Types */
#define	EURASIA_PDS_TYPE_MOVS						0U
#define	EURASIA_PDS_TYPE_MOV16						1U
#define	EURASIA_PDS_TYPE_MOV32						2U
#define	EURASIA_PDS_TYPE_MOV64						3U
#define	EURASIA_PDS_TYPE_MOV128						4U
#define	EURASIA_PDS_TYPE_MOVSA						5U
#if defined(SGX_FEATURE_PDS_LOAD_STORE)
#define EURASIA_PDS_TYPE_LOAD						6U
#define EURASIA_PDS_TYPE_STORE						7U
#endif /* defined(SGX545) */

/* Arithmetic Instruction Types */
#define	EURASIA_PDS_TYPE_ADD						0U
#define	EURASIA_PDS_TYPE_SUB						1U
#define	EURASIA_PDS_TYPE_ADC						2U
#define	EURASIA_PDS_TYPE_SBC						3U
#define	EURASIA_PDS_TYPE_MUL						4U
#define	EURASIA_PDS_TYPE_ABS						5U
#if defined(SGX_FEATURE_PDS_LOAD_STORE)
#define EURASIA_PDS_TYPE_DATAFENCE					7U
#endif /* defined(SGX545) */

/* Program Flow Instruction Types */
#define	EURASIA_PDS_TYPE_TSTZ						0U
#define	EURASIA_PDS_TYPE_TSTN						1U
#define	EURASIA_PDS_TYPE_BRA						2U
#define	EURASIA_PDS_TYPE_CALL						3U
#define	EURASIA_PDS_TYPE_RTN						4U
#define	EURASIA_PDS_TYPE_HALT						5U
#define	EURASIA_PDS_TYPE_NOP						6U
#define EURASIA_PDS_TYPE_ALUM						7U

/* Logical And Shift Instruction Types */
#define	EURASIA_PDS_TYPE_OR							0U
#define	EURASIA_PDS_TYPE_AND						1U
#define	EURASIA_PDS_TYPE_XOR						2U
#define	EURASIA_PDS_TYPE_NOT						3U
#define	EURASIA_PDS_TYPE_NOR						4U
#define	EURASIA_PDS_TYPE_NAND						5U
#define	EURASIA_PDS_TYPE_SHL						6U
#define	EURASIA_PDS_TYPE_SHR						7U

/* Condition Codes */
#define	EURASIA_PDS_CC_CLRMSK						0xF8FFFFFFU
#define	EURASIA_PDS_CC_SHIFT						24
#define	EURASIA_PDS_CC_P0							(0UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_P1							(1UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_P2							(2UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_IF0							(3UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_IF1							(4UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_ALUZ							(5UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_ALUN							(6UL << EURASIA_PDS_CC_SHIFT)
#define	EURASIA_PDS_CC_ALWAYS						(7UL << EURASIA_PDS_CC_SHIFT)

/* Special Register Data Move Instruction */
#define	EURASIA_PDS_MOVS_SRC1SEL_CLRMSK				0xFF7FFFFFU
#define	EURASIA_PDS_MOVS_SRC1SEL_SHIFT				23
#define	EURASIA_PDS_MOVS_SRC1SEL_DS0				0U
#define	EURASIA_PDS_MOVS_SRC1SEL_REG				1U

#define	EURASIA_PDS_MOVS_SRC1_CLRMSK				0xFF83FFFFU
#define	EURASIA_PDS_MOVS_SRC1_SHIFT					18
#define	EURASIA_PDS_MOVS_SRC1_DS0_BASE				0x00
#define	EURASIA_PDS_MOVS_SRC1_DS0_LIMIT				0x1F
#define	EURASIA_PDS_MOVS_SRC1_IR0					0x00
#define	EURASIA_PDS_MOVS_SRC1_IR1					0x01
#define	EURASIA_PDS_MOVS_SRC1_TIM					0x02
#if defined(SGX_FEATURE_PDS_EXTENDED_INPUT_REGISTERS)
#define	EURASIA_PDS_MOVS_SRC1_IR2					0x04
#endif

#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)

#define	EURASIA_PDS_MOVS_SRC2SEL_CLRMSK				0xFFFDFFFFU
#define	EURASIA_PDS_MOVS_SRC2SEL_SHIFT				17
#define	EURASIA_PDS_MOVS_SRC2SEL_DS1				0U
#define	EURASIA_PDS_MOVS_SRC2SEL_REG				1U

#define	EURASIA_PDS_MOVS_SRC2_CLRMSK				0xFFFE0FFFU
#define	EURASIA_PDS_MOVS_SRC2_SHIFT					12
#define	EURASIA_PDS_MOVS_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_MOVS_SRC2_DS1_LIMIT				0x1F
#define	EURASIA_PDS_MOVS_SRC2_IR0					0x00
#define	EURASIA_PDS_MOVS_SRC2_IR1					0x01
#define	EURASIA_PDS_MOVS_SRC2_TIM					0x02

#define	EURASIA_PDS_MOVS_DOUTT_MINPACK_CLRMSK		0xFFFFFFBFU
#define	EURASIA_PDS_MOVS_DOUTT_MINPACK				(1UL << 6)

#define	EURASIA_PDS_MOVS_DOUTT_FCONV_CLRMSK			0xFFFFFFCFU
#define	EURASIA_PDS_MOVS_DOUTT_FCONV_SHIFT			4

#define	EURASIA_PDS_MOVS_DOUTT_FCONV_UNCHANGED		0U
#define	EURASIA_PDS_MOVS_DOUTT_FCONV_F16			2U
#define	EURASIA_PDS_MOVS_DOUTT_FCONV_F32			3U

#define	EURASIA_PDS_MOVS_DOUTI_TAGSIZE_CLRMSK		0xFFFFFF3FU
#define	EURASIA_PDS_MOVS_DOUTI_TAGSIZE_SHIFT		6

#define	EURASIA_PDS_MOVS_DOUTI_ITRSIZE_CLRMSK		0xFFFFFFCFU
#define	EURASIA_PDS_MOVS_DOUTI_ITRSIZE_SHIFT		4

#define	EURASIA_PDS_MOVS_SWIZ0_CLRMSK				0xFFFFF3FFU
#define	EURASIA_PDS_MOVS_SWIZ0_SHIFT				10
#define	EURASIA_PDS_MOVS_SWIZ1_CLRMSK				0xFFFFFCFFU
#define	EURASIA_PDS_MOVS_SWIZ1_SHIFT				8
#define	EURASIA_PDS_MOVS_SWIZ2_CLRMSK				0xFFFFFF3FU
#define	EURASIA_PDS_MOVS_SWIZ2_SHIFT				6
#define	EURASIA_PDS_MOVS_SWIZ3_CLRMSK				0xFFFFFFCFU
#define	EURASIA_PDS_MOVS_SWIZ3_SHIFT				4

#define	EURASIA_PDS_MOVS_SWIZ_SRC1L					0U
#define	EURASIA_PDS_MOVS_SWIZ_SRC1H					1U
#define	EURASIA_PDS_MOVS_SWIZ_SRC2L					2U
#define	EURASIA_PDS_MOVS_SWIZ_SRC2H					3U

#define	EURASIA_PDS_MOVS_DOUTT_SWIZ					(1UL << 11)


#define	EURASIA_PDS_MOVS_DEST_CLRMSK				0xFFFFFFF0U
#define	EURASIA_PDS_MOVS_DEST_SHIFT					0
// 0 is reserved
#define	EURASIA_PDS_MOVS_DEST_SLC					1U
#define	EURASIA_PDS_MOVS_DEST_DOUTI					2U
#define	EURASIA_PDS_MOVS_DEST_DOUTD					3U
#define	EURASIA_PDS_MOVS_DEST_DOUTT					4U
#define	EURASIA_PDS_MOVS_DEST_DOUTU					5U
#define	EURASIA_PDS_MOVS_DEST_DOUTA					6U
#define	EURASIA_PDS_MOVS_DEST_TIM					7U
// 8, 9 and 10 are reserved
#define	EURASIA_PDS_MOVS_DEST_DOUTO					11U

#else

#define	EURASIA_PDS_MOVS_SRC2SEL_CLRMSK				0xFFFFFFFFU
#define	EURASIA_PDS_MOVS_SRC2SEL_SHIFT				0
#define	EURASIA_PDS_MOVS_SRC2SEL_DS1				0U

#define	EURASIA_PDS_MOVS_SRC2_CLRMSK				0xFFFC1FFFU
#define	EURASIA_PDS_MOVS_SRC2_SHIFT					13
#define	EURASIA_PDS_MOVS_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_MOVS_SRC2_DS1_LIMIT				0x1F

#define	EURASIA_PDS_MOVS_SWIZ0_CLRMSK				0xFFFFE7FFU
#define	EURASIA_PDS_MOVS_SWIZ0_SHIFT				11
#define	EURASIA_PDS_MOVS_SWIZ1_CLRMSK				0xFFFFF9FFU
#define	EURASIA_PDS_MOVS_SWIZ1_SHIFT				9
#define	EURASIA_PDS_MOVS_SWIZ2_CLRMSK				0xFFFFFE7FU
#define	EURASIA_PDS_MOVS_SWIZ2_SHIFT				7
#define	EURASIA_PDS_MOVS_SWIZ3_CLRMSK				0xFFFFFF9FU
#define	EURASIA_PDS_MOVS_SWIZ3_SHIFT				5

#define	EURASIA_PDS_MOVS_SWIZ_SRC1L					0U
#define	EURASIA_PDS_MOVS_SWIZ_SRC1H					1U
#define	EURASIA_PDS_MOVS_SWIZ_SRC2L					2U
#define	EURASIA_PDS_MOVS_SWIZ_SRC2H					3U

#define	EURASIA_PDS_MOVS_DEST_CLRMSK				0xFFFFFFF0U
#define	EURASIA_PDS_MOVS_DEST_SHIFT					0
#define	EURASIA_PDS_MOVS_DEST_MR					0U
#define	EURASIA_PDS_MOVS_DEST_SLC					1U
#define	EURASIA_PDS_MOVS_DEST_DOUTI					2U
#define	EURASIA_PDS_MOVS_DEST_DOUTD					3U
#define	EURASIA_PDS_MOVS_DEST_DOUTT					4U
#define	EURASIA_PDS_MOVS_DEST_DOUTU					5U
#define	EURASIA_PDS_MOVS_DEST_DOUTA					6U
#define	EURASIA_PDS_MOVS_DEST_TIM					7U
#if defined(SGX545)
#define	EURASIA_PDS_MOVS_DEST_DOUTC					8U
#define	EURASIA_PDS_MOVS_DEST_DOUTS					9U
#endif /* defined(SGX545) */

#endif

/* 16 Bit Data Move Instructions */
#define	EURASIA_PDS_MOV16_SRCSEL_CLRMSK				0xFFFE7FFFU
#define	EURASIA_PDS_MOV16_SRCSEL_SHIFT				15
#define	EURASIA_PDS_MOV16_SRCSEL_DS0				0U
#define	EURASIA_PDS_MOV16_SRCSEL_DS1				1U
#define	EURASIA_PDS_MOV16_SRCSEL_REG				2U

#define	EURASIA_PDS_MOV16_SRC_CLRMSK				0xFFFF80FFU
#define	EURASIA_PDS_MOV16_SRC_SHIFT					8
#define	EURASIA_PDS_MOV16_SRC_DS_BASE				0x00
#define	EURASIA_PDS_MOV16_SRC_DS_LIMIT				0x7F
#define	EURASIA_PDS_MOV16_SRC_IR0L					0x00U
#define	EURASIA_PDS_MOV16_SRC_IR0H					0x02U
#define	EURASIA_PDS_MOV16_SRC_IR1L					0x04U
#define	EURASIA_PDS_MOV16_SRC_IR1H					0x06U
#define	EURASIA_PDS_MOV16_SRC_PCL					0x08U
#define	EURASIA_PDS_MOV16_SRC_PCH					0x0AU
#define	EURASIA_PDS_MOV16_SRC_TIML					0x0CU
#define	EURASIA_PDS_MOV16_SRC_TIMH					0x0EU
#if defined(SGX_FEATURE_PDS_EXTENDED_INPUT_REGISTERS)
#define	EURASIA_PDS_MOV16_SRC_IR2L					0x10U
#define	EURASIA_PDS_MOV16_SRC_IR2H					0x12U
#endif

#define	EURASIA_PDS_MOV16_DESTSEL_CLRMSK			0xFFFFFF7FU
#define	EURASIA_PDS_MOV16_DESTSEL_SHIFT				7
#define	EURASIA_PDS_MOV16_DESTSEL_DS0				0U
#define	EURASIA_PDS_MOV16_DESTSEL_DS1				1U

#define	EURASIA_PDS_MOV16_DEST_CLRMSK				0xFFFFFF80U
#define	EURASIA_PDS_MOV16_DEST_SHIFT				0
#define	EURASIA_PDS_MOV16_DEST_DS_BASE				0x00
#define	EURASIA_PDS_MOV16_DEST_DS_LIMIT				0x7F

/* 32 Bit Data Move Instructions */
#define	EURASIA_PDS_MOV32_SRCSEL_CLRMSK				0xFFFE7FFFU
#define	EURASIA_PDS_MOV32_SRCSEL_SHIFT				15
#define	EURASIA_PDS_MOV32_SRCSEL_DS0				0U
#define	EURASIA_PDS_MOV32_SRCSEL_DS1				1U
#define	EURASIA_PDS_MOV32_SRCSEL_REG				2U

#define	EURASIA_PDS_MOV32_SRC_CLRMSK				0xFFFF81FFU
#define	EURASIA_PDS_MOV32_SRC_SHIFT					9
#define	EURASIA_PDS_MOV32_SRC_DS_BASE				0x00
#define	EURASIA_PDS_MOV32_SRC_DS_LIMIT				0x3F
#define	EURASIA_PDS_MOV32_SRC_IR0					0x00U
#define	EURASIA_PDS_MOV32_SRC_IR1					0x02U
#define	EURASIA_PDS_MOV32_SRC_PC					0x04U
#define	EURASIA_PDS_MOV32_SRC_TIM					0x06U
#if defined(SGX_FEATURE_PDS_EXTENDED_INPUT_REGISTERS)
#define	EURASIA_PDS_MOV32_SRC_IR2					0x08U
#endif

#define	EURASIA_PDS_MOV32_DESTSEL_CLRMSK			0xFFFFFF7FU
#define	EURASIA_PDS_MOV32_DESTSEL_SHIFT				7
#define	EURASIA_PDS_MOV32_DESTSEL_DS0				0U
#define	EURASIA_PDS_MOV32_DESTSEL_DS1				1U

#define	EURASIA_PDS_MOV32_DEST_CLRMSK				0xFFFFFF81U
#define	EURASIA_PDS_MOV32_DEST_SHIFT				1
#define	EURASIA_PDS_MOV32_DEST_DS_BASE				0x00
#define	EURASIA_PDS_MOV32_DEST_DS_LIMIT				0x3F

/* 64 Bit Data Move Instructions */
#define	EURASIA_PDS_MOV64_SRCSEL_CLRMSK				0xFFFE7FFFU
#define	EURASIA_PDS_MOV64_SRCSEL_SHIFT				15
#define	EURASIA_PDS_MOV64_SRCSEL_DS0				0U
#define	EURASIA_PDS_MOV64_SRCSEL_DS1				1U
#define	EURASIA_PDS_MOV64_SRCSEL_REG				2U

#define	EURASIA_PDS_MOV64_SRC_CLRMSK				0xFFFF83FFU
#define	EURASIA_PDS_MOV64_SRC_SHIFT					10
#define	EURASIA_PDS_MOV64_SRC_DS_BASE				0x00
#define	EURASIA_PDS_MOV64_SRC_DS_LIMIT				0x1F
#define	EURASIA_PDS_MOV64_SRC_MR01					0x00
#define	EURASIA_PDS_MOV64_SRC_MR23					0x01

#define	EURASIA_PDS_MOV64_DESTSEL_CLRMSK			0xFFFFFF7FU
#define	EURASIA_PDS_MOV64_DESTSEL_SHIFT				7
#define	EURASIA_PDS_MOV64_DESTSEL_DS0				0U
#define	EURASIA_PDS_MOV64_DESTSEL_DS1				1U

#define	EURASIA_PDS_MOV64_DEST_CLRMSK				0xFFFFFF83U
#define	EURASIA_PDS_MOV64_DEST_SHIFT				2
#define	EURASIA_PDS_MOV64_DEST_DS_BASE				0x00
#define	EURASIA_PDS_MOV64_DEST_DS_LIMIT				0x1F

/* 128 Bit Data Move Instructions */
#define	EURASIA_PDS_MOV128_SRCSEL_CLRMSK			0xFFFFBFFFU
#define	EURASIA_PDS_MOV128_SRCSEL_SHIFT				14
#define	EURASIA_PDS_MOV128_SRCSEL_DS				0U
#define	EURASIA_PDS_MOV128_SRCSEL_REG				1U

#define	EURASIA_PDS_MOV128_SRC_CLRMSK				0xFFFF83FFU
#define	EURASIA_PDS_MOV128_SRC_SHIFT				10
#define	EURASIA_PDS_MOV128_SRC_DS_BASE				0x00
#define	EURASIA_PDS_MOV128_SRC_DS_LIMIT				0x1F
#define	EURASIA_PDS_MOV128_SRC_MR					0x00

#define	EURASIA_PDS_MOV128_SWAP_CLRMSK				0xFFFFFEFFU
#define	EURASIA_PDS_MOV128_SWAP_SHIFT				8
#define	EURASIA_PDS_MOV128_SWAP_OFF					0U
#define	EURASIA_PDS_MOV128_SWAP_ON					1U

#define	EURASIA_PDS_MOV128_DEST_CLRMSK				0xFFFFFF83U
#define	EURASIA_PDS_MOV128_DEST_SHIFT				2
#define	EURASIA_PDS_MOV128_DEST_DS_BASE				0x00
#define	EURASIA_PDS_MOV128_DEST_DS_LIMIT			0x1F

#if defined(SGX_FEATURE_PDS_LOAD_STORE)
/* Load/store/datafence instructions. */
#define EURASIA_PDS_LOADSTORE_SIZE_CLRMSK			0xF8FFFFFFU
#define EURASIA_PDS_LOADSTORE_SIZE_SHIFT			24
#define EURASIA_PDS_LOADSTORE_SIZE_MAX				(((~EURASIA_PDS_LOADSTORE_SIZE_CLRMSK) >> EURASIA_PDS_LOADSTORE_SIZE_SHIFT) + 1)

#define EURASIA_PDS_LOADSTORE_REGADDRSEL_CLRMSK		0xFFBFFFFFU
#define EURASIA_PDS_LOADSTORE_REGADDRSEL_SHIFT		22
#define EURASIA_PDS_LOADSTORE_REGADDRSEL_DS0		0U
#define EURASIA_PDS_LOADSTORE_REGADDRSEL_DS1		1U

#define EURASIA_PDS_LOADSTORE_REGADDR_CLRMSK		0xFFC3FFFFU
#define EURASIA_PDS_LOADSTORE_REGADDR_SHIFT			18

#define EURASIA_PDS_LOADSTORE_MEMADDR_CLRMSK		0xFFFC0000U
#define EURASIA_PDS_LOADSTORE_MEMADDR_SHIFT			0
#define EURASIA_PDS_LOADSTORE_MEMADDR_ALIGNSHIFT	2
#define EURASIA_PDS_LOADSTORE_MEMADDR_MAX			((~EURASIA_PDS_LOADSTORE_MEMADDR_CLRMSK) >> EURASIA_PDS_LOADSTORE_MEMADDR_SHIFT)

#define EURASIA_PDS_DATAFENCE_MODE_CLRMSK			0xFFFFFFFEU
#define EURASIA_PDS_DATAFENCE_MODE_SHIFT			0
#define EURASIA_PDS_DATAFENCE_MODE_READ				0U
#define EURASIA_PDS_DATAFENCE_MODE_READWRITE		1U

#endif /* defined(SGX_FEATURE_PDS_LOAD_STORE) */

/* Arithmetic Instructions */
#define	EURASIA_PDS_ARITH_SRC1SEL_CLRMSK			0xFF7FFFFFU
#define	EURASIA_PDS_ARITH_SRC1SEL_SHIFT				23
#define	EURASIA_PDS_ARITH_SRC1SEL_DS0				0U
#define	EURASIA_PDS_ARITH_SRC1SEL_REG				1U

#define	EURASIA_PDS_ARITH_SRC1_CLRMSK				0xFF81FFFFU
#define	EURASIA_PDS_ARITH_SRC1_SHIFT				17
#define	EURASIA_PDS_ARITH_SRC1_DS0_BASE				0x00
#define	EURASIA_PDS_ARITH_SRC1_DS0_LIMIT			0x3F
#define	EURASIA_PDS_ARITH_SRC1_IR0					0x00
#define	EURASIA_PDS_ARITH_SRC1_IR1					0x01
#define	EURASIA_PDS_ARITH_SRC1_TIM					0x02


#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)

#define	EURASIA_PDS_ARITH_SRC2SEL_CLRMSK			0xFFFF7FFFU
#define	EURASIA_PDS_ARITH_SRC2SEL_SHIFT				15
#define	EURASIA_PDS_ARITH_SRC2SEL_DS1				0U
#define	EURASIA_PDS_ARITH_SRC2SEL_REG				1U

#define	EURASIA_PDS_ARITH_SRC2_CLRMSK				0xFFFF81FFU
#define	EURASIA_PDS_ARITH_SRC2_SHIFT				9
#define	EURASIA_PDS_ARITH_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_ARITH_SRC2_DS1_LIMIT			0x3F

#define	EURASIA_PDS_ARITH_SRC2_IR0					0x00
#define	EURASIA_PDS_ARITH_SRC2_IR1					0x01
#define	EURASIA_PDS_ARITH_SRC2_TIM					0x02


#else

#define	EURASIA_PDS_ARITH_SRC2SEL_CLRMSK			0xFFFFFFFFU
#define	EURASIA_PDS_ARITH_SRC2SEL_SHIFT				0
#define	EURASIA_PDS_ARITH_SRC2SEL_DS1				0U

#define	EURASIA_PDS_ARITH_SRC2_CLRMSK				0xFFFF03FFU
#define	EURASIA_PDS_ARITH_SRC2_SHIFT				10
#define	EURASIA_PDS_ARITH_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_ARITH_SRC2_DS1_LIMIT			0x3F

#endif


#define	EURASIA_PDS_ARITH_DESTSEL_CLRMSK			0xFFFFFFBFU
#define	EURASIA_PDS_ARITH_DESTSEL_SHIFT				6
#define	EURASIA_PDS_ARITH_DESTSEL_DS0				0U
#define	EURASIA_PDS_ARITH_DESTSEL_DS1				1U

#define	EURASIA_PDS_ARITH_DEST_CLRMSK				0xFFFFFFC0U
#define	EURASIA_PDS_ARITH_DEST_SHIFT				0
#define	EURASIA_PDS_ARITH_DEST_DS_BASE				0x00
#define	EURASIA_PDS_ARITH_DEST_DS_LIMIT				0x3F

/* Arithmetic Multiply Instruction */
#define	EURASIA_PDS_MUL_SRC1SEL_CLRMSK				0xFF7FFFFFU
#define	EURASIA_PDS_MUL_SRC1SEL_SHIFT				23
#define	EURASIA_PDS_MUL_SRC1SEL_DS0					0U
#define	EURASIA_PDS_MUL_SRC1SEL_REG					1U

#define	EURASIA_PDS_MUL_SRC1_CLRMSK					0xFF80FFFFU
#define	EURASIA_PDS_MUL_SRC1_SHIFT					16
#define	EURASIA_PDS_MUL_SRC1_DS0_BASE				0x00
#define	EURASIA_PDS_MUL_SRC1_DS0_LIMIT				0x7F
#define	EURASIA_PDS_MUL_SRC1_IR0L					0x00U
#define	EURASIA_PDS_MUL_SRC1_IR0H					0x01U
#define	EURASIA_PDS_MUL_SRC1_IR1L					0x02U
#define	EURASIA_PDS_MUL_SRC1_IR1H					0x03U
#define	EURASIA_PDS_MUL_SRC1_TIML					0x04U
#define	EURASIA_PDS_MUL_SRC1_TIMH					0x05U

#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)

#define	EURASIA_PDS_MUL_SRC2SEL_CLRMSK				0xFFFF7FFFU
#define	EURASIA_PDS_MUL_SRC2SEL_SHIFT				15
#define	EURASIA_PDS_MUL_SRC2SEL_DS1					0U
#define	EURASIA_PDS_MUL_SRC2SEL_REG					1U

#define	EURASIA_PDS_MUL_SRC2_CLRMSK					0xFFFF80FFU
#define	EURASIA_PDS_MUL_SRC2_SHIFT					8
#define	EURASIA_PDS_MUL_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_MUL_SRC2_DS1_LIMIT				0x7F

#define	EURASIA_PDS_MUL_SRC2_IR0L					0x00U
#define	EURASIA_PDS_MUL_SRC2_IR0H					0x01U
#define	EURASIA_PDS_MUL_SRC2_IR1L					0x02U
#define	EURASIA_PDS_MUL_SRC2_IR1H					0x03U
#define	EURASIA_PDS_MUL_SRC2_TIML					0x04U
#define	EURASIA_PDS_MUL_SRC2_TIMH					0x05U

#else

#define	EURASIA_PDS_MUL_SRC2SEL_CLRMSK				0xFFFFFFFFU
#define	EURASIA_PDS_MUL_SRC2SEL_SHIFT				0
#define	EURASIA_PDS_MUL_SRC2SEL_DS1					0U

#define	EURASIA_PDS_MUL_SRC2_CLRMSK					0xFFFF01FFU
#define	EURASIA_PDS_MUL_SRC2_SHIFT					9
#define	EURASIA_PDS_MUL_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_MUL_SRC2_DS1_LIMIT				0x7F

#endif

#define	EURASIA_PDS_MUL_DESTSEL_CLRMSK				0xFFFFFFBFU
#define	EURASIA_PDS_MUL_DESTSEL_SHIFT				6
#define	EURASIA_PDS_MUL_DESTSEL_DS0					0U
#define	EURASIA_PDS_MUL_DESTSEL_DS1					1U

#define	EURASIA_PDS_MUL_DEST_CLRMSK					0xFFFFFFC0U
#define	EURASIA_PDS_MUL_DEST_SHIFT					0
#define	EURASIA_PDS_MUL_DEST_DS_BASE				0x00
#define	EURASIA_PDS_MUL_DEST_DS_LIMIT				0x3F

/* Arithmetic Absolute Instruction */
#define	EURASIA_PDS_ABS_SRC1SEL_CLRMSK				0xFF7FFFFFU
#define	EURASIA_PDS_ABS_SRC1SEL_SHIFT				23
#define	EURASIA_PDS_ABS_SRC1SEL_DS0					0U
#define	EURASIA_PDS_ABS_SRC1SEL_REG					1U

#define	EURASIA_PDS_ABS_SRC1_CLRMSK					0xFF81FFFFU
#define	EURASIA_PDS_ABS_SRC1_SHIFT					17
#define	EURASIA_PDS_ABS_SRC1_DS0_BASE				0x00
#define	EURASIA_PDS_ABS_SRC1_DS0_LIMIT				0x3F
#define	EURASIA_PDS_ABS_SRC1_IR0					0x00
#define	EURASIA_PDS_ABS_SRC1_IR1					0x01
#define	EURASIA_PDS_ABS_SRC1_TIM					0x02

#define	EURASIA_PDS_ABS_SRC2_CLRMSK					0xFFFF83FFU
#define	EURASIA_PDS_ABS_SRC2_SHIFT					10
#define	EURASIA_PDS_ABS_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_ABS_SRC2_DS1_LIMIT				0x3F

#define	EURASIA_PDS_ABS_SRCSEL_CLRMSK				0xFFFFFEFFU
#define	EURASIA_PDS_ABS_SRCSEL_SHIFT				8
#define	EURASIA_PDS_ABS_SRCSEL_SRC1					0U
#define	EURASIA_PDS_ABS_SRCSEL_SRC2					1U

#define	EURASIA_PDS_ABS_DESTSEL_CLRMSK				0xFFFFFFBFU
#define	EURASIA_PDS_ABS_DESTSEL_SHIFT				6
#define	EURASIA_PDS_ABS_DESTSEL_DS0					0U
#define	EURASIA_PDS_ABS_DESTSEL_DS1					1U

#define	EURASIA_PDS_ABS_DEST_CLRMSK					0xFFFFFFC0U
#define	EURASIA_PDS_ABS_DEST_SHIFT					0
#define	EURASIA_PDS_ABS_DEST_DS_BASE				0x00
#define	EURASIA_PDS_ABS_DEST_DS_LIMIT				0x3F

/* Program Flow Test Instructions */
#define	EURASIA_PDS_TST_SRC1SEL_CLRMSK				0xFF7FFFFFU
#define	EURASIA_PDS_TST_SRC1SEL_SHIFT				23
#define	EURASIA_PDS_TST_SRC1SEL_DS0					0U
#define	EURASIA_PDS_TST_SRC1SEL_REG					1U

#define	EURASIA_PDS_TST_SRC1_CLRMSK					0xFF81FFFFU
#define	EURASIA_PDS_TST_SRC1_SHIFT					17
#define	EURASIA_PDS_TST_SRC1_DS0_BASE				0x00
#define	EURASIA_PDS_TST_SRC1_DS0_LIMIT				0x3F
#define	EURASIA_PDS_TST_SRC1_IR0					0x00
#define	EURASIA_PDS_TST_SRC1_IR1					0x01
#define	EURASIA_PDS_TST_SRC1_TIM					0x02

#define	EURASIA_PDS_TST_SRC2_CLRMSK					0xFFFF03FFU
#define	EURASIA_PDS_TST_SRC2_SHIFT					10
#define	EURASIA_PDS_TST_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_TST_SRC2_DS1_LIMIT				0x3F

#define	EURASIA_PDS_TST_SRCSEL_CLRMSK				0xFFFFFEFFU
#define	EURASIA_PDS_TST_SRCSEL_SHIFT				8
#define	EURASIA_PDS_TST_SRCSEL_SRC1					0U
#define	EURASIA_PDS_TST_SRCSEL_SRC2					1U

#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)
#define	EURASIA_PDS_TST_NEGATE						8U
#endif

#define	EURASIA_PDS_TST_DEST_CLRMSK					0xFFFFFFF8U
#define	EURASIA_PDS_TST_DEST_SHIFT					0
#define	EURASIA_PDS_TST_DEST_P0						0U
#define	EURASIA_PDS_TST_DEST_P1						1U
#define	EURASIA_PDS_TST_DEST_P2						2U

/* Program Flow Branch and Call Instructions */
#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)
#define	EURASIA_PDS_FLOW_CC_NEGATE					(1UL << 23)
#endif

#define	EURASIA_PDS_FLOW_DEST_CLRMSK				0xFFF80000U
#define	EURASIA_PDS_FLOW_DEST_SHIFT					0
#define	EURASIA_PDS_FLOW_DEST_ALIGNSHIFT			2
#define	EURASIA_PDS_FLOW_DEST_MEM_BASE				0x00000000
#define	EURASIA_PDS_FLOW_DEST_MEM_LIMIT				0x001FFFFC

#define EURASIA_PDS_FLOW_ALUM_MODE_CLRMSK			0xFFFFFFFEU
#define EURASIA_PDS_FLOW_ALUM_MODE_SHIFT			0
#define EURASIA_PDS_FLOW_ALUM_MODE_UNSIGNED			0U
#define EURASIA_PDS_FLOW_ALUM_MODE_SIGNED			1U

/* Logic Operation Instructions */
#define	EURASIA_PDS_LOGIC_SRC1SEL_CLRMSK			0xFF7FFFFFU
#define	EURASIA_PDS_LOGIC_SRC1SEL_SHIFT				23
#define	EURASIA_PDS_LOGIC_SRC1SEL_DS0				0U
#define	EURASIA_PDS_LOGIC_SRC1SEL_REG				1U

#define	EURASIA_PDS_LOGIC_SRC1_CLRMSK				0xFF81FFFFU
#define	EURASIA_PDS_LOGIC_SRC1_SHIFT				17
#define	EURASIA_PDS_LOGIC_SRC1_DS0_BASE				0x00
#define	EURASIA_PDS_LOGIC_SRC1_DS0_LIMIT			0x3F
#define	EURASIA_PDS_LOGIC_SRC1_IR0					0x00
#define	EURASIA_PDS_LOGIC_SRC1_IR1					0x01
#define	EURASIA_PDS_LOGIC_SRC1_TIM					0x02


#if defined(SGX_FEATURE_PDS_EXTENDED_SOURCES)

#define	EURASIA_PDS_LOGIC_SRC2SEL_CLRMSK			0xFFFF7FFFU
#define	EURASIA_PDS_LOGIC_SRC2SEL_SHIFT				15
#define	EURASIA_PDS_LOGIC_SRC2SEL_DS1				0U
#define	EURASIA_PDS_LOGIC_SRC2SEL_REG				1U

#define	EURASIA_PDS_LOGIC_SRC2_CLRMSK				0xFFFF81FFU
#define	EURASIA_PDS_LOGIC_SRC2_SHIFT				9
#define	EURASIA_PDS_LOGIC_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_LOGIC_SRC2_DS1_LIMIT			0x3F

#define	EURASIA_PDS_LOGIC_SRC2_IR0					0x00
#define	EURASIA_PDS_LOGIC_SRC2_IR1					0x01
#define	EURASIA_PDS_LOGIC_SRC2_TIM					0x02

#else

#define	EURASIA_PDS_LOGIC_SRC2SEL_CLRMSK			0xFFFFFFFFU
#define	EURASIA_PDS_LOGIC_SRC2SEL_SHIFT				0
#define	EURASIA_PDS_LOGIC_SRC2SEL_DS1				0U

#define	EURASIA_PDS_LOGIC_SRC2_CLRMSK				0xFFFF03FFU
#define	EURASIA_PDS_LOGIC_SRC2_SHIFT				10
#define	EURASIA_PDS_LOGIC_SRC2_DS1_BASE				0x00
#define	EURASIA_PDS_LOGIC_SRC2_DS1_LIMIT			0x3F

#endif

#define	EURASIA_PDS_LOGIC_SRCSEL_CLRMSK				0xFFFFFEFFU
#define	EURASIA_PDS_LOGIC_SRCSEL_SHIFT				8
#define	EURASIA_PDS_LOGIC_SRCSEL_SRC1				0U
#define	EURASIA_PDS_LOGIC_SRCSEL_SRC2				1U

#define	EURASIA_PDS_LOGIC_DESTSEL_CLRMSK			0xFFFFFFBFU
#define	EURASIA_PDS_LOGIC_DESTSEL_SHIFT				6
#define	EURASIA_PDS_LOGIC_DESTSEL_DS0				0U
#define	EURASIA_PDS_LOGIC_DESTSEL_DS1				1U

#define	EURASIA_PDS_LOGIC_DEST_CLRMSK				0xFFFFFFC0U
#define	EURASIA_PDS_LOGIC_DEST_SHIFT				0
#define	EURASIA_PDS_LOGIC_DEST_DS_BASE				0x00
#define	EURASIA_PDS_LOGIC_DEST_DS_LIMIT				0x3F

/* Shift Operation Instructions */
#define	EURASIA_PDS_SHIFT_SRCSEL_CLRMSK				0xFF3FFFFFU
#define	EURASIA_PDS_SHIFT_SRCSEL_SHIFT				22
#define	EURASIA_PDS_SHIFT_SRCSEL_DS0				0U
#define	EURASIA_PDS_SHIFT_SRCSEL_DS1				1U
#define	EURASIA_PDS_SHIFT_SRCSEL_REG				2U

#define	EURASIA_PDS_SHIFT_SRC_CLRMSK				0xFFC0FFFFU
#define	EURASIA_PDS_SHIFT_SRC_SHIFT					16
#define	EURASIA_PDS_SHIFT_SRC_DS_BASE				0x00
#define	EURASIA_PDS_SHIFT_SRC_DS_LIMIT				0x3F
#define	EURASIA_PDS_SHIFT_SRC_IR0					0x00U
#define	EURASIA_PDS_SHIFT_SRC_IR1					0x01U
#define	EURASIA_PDS_SHIFT_SRC_TIM					0x02U

#define	EURASIA_PDS_SHIFT_SHIFT_CLRMSK				0xFFFF80FFU
#define	EURASIA_PDS_SHIFT_SHIFT_SHIFT				8
#define	EURASIA_PDS_SHIFT_SHIFT_MIN					0x40
#define	EURASIA_PDS_SHIFT_SHIFT_ZERO				0x00
#define	EURASIA_PDS_SHIFT_SHIFT_MAX					0x3F

#define	EURASIA_PDS_SHIFT_DESTSEL_CLRMSK			0xFFFFFFBFU
#define	EURASIA_PDS_SHIFT_DESTSEL_SHIFT				6
#define	EURASIA_PDS_SHIFT_DESTSEL_DS0				0U
#define	EURASIA_PDS_SHIFT_DESTSEL_DS1				1U

#define	EURASIA_PDS_SHIFT_DEST_CLRMSK				0xFFFFFFC0U
#define	EURASIA_PDS_SHIFT_DEST_SHIFT				0
#define	EURASIA_PDS_SHIFT_DEST_DS_BASE				0x00
#define	EURASIA_PDS_SHIFT_DEST_DS_LIMIT				0x3F

/*****************************************************************************
 PDS Registers
*****************************************************************************/
#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH)
	#if defined(SGX_FEATURE_MP)
/* FIXME: make this smaller again once testing has finished */
#define EURASIA_PDS_CONTEXT_SWITCH_BUFFER_SIZE		(16*4096)
	#else
#define EURASIA_PDS_CONTEXT_SWITCH_BUFFER_SIZE		(4096)
	#endif
#endif

/* Input Register 0 - Pixel DM & Event DM Synchonized Events */
#if defined(SGX545)
	#define	EURASIA_PDS_IR0_PDM_TILEX_CLRMSK				0xFFFFFE00U
	#define	EURASIA_PDS_IR0_PDM_TILEX_SHIFT					0
	#define	EURASIA_PDS_IR0_PDM_TILEX_MIN					0x000
	#define	EURASIA_PDS_IR0_PDM_TILEX_MAX					0x1FF

	#define	EURASIA_PDS_IR0_PDM_TILEY_CLRMSK				0xFFF801FFU
	#define	EURASIA_PDS_IR0_PDM_TILEY_SHIFT					9
	#define	EURASIA_PDS_IR0_PDM_TILEY_MIN					0x00
	#define	EURASIA_PDS_IR0_PDM_TILEY_MAX					0x3FF
#else
#if defined(SGX520)
	#define	EURASIA_PDS_IR0_PDM_TILEX_CLRMSK				0xFFFFFE00U
	#define	EURASIA_PDS_IR0_PDM_TILEX_SHIFT					0
	#define	EURASIA_PDS_IR0_PDM_TILEX_MIN					0x000
	#define	EURASIA_PDS_IR0_PDM_TILEX_MAX					0x1FF

	#define	EURASIA_PDS_IR0_PDM_TILEY_CLRMSK				0xFFFE01FFU
	#define	EURASIA_PDS_IR0_PDM_TILEY_SHIFT					9
	#define	EURASIA_PDS_IR0_PDM_TILEY_MIN					0x00
	#define	EURASIA_PDS_IR0_PDM_TILEY_MAX					0xFF
#else
	#define	EURASIA_PDS_IR0_PDM_TILEX_CLRMSK				0xFFFFFF00U
	#define	EURASIA_PDS_IR0_PDM_TILEX_SHIFT					0
	#define	EURASIA_PDS_IR0_PDM_TILEX_MIN					0x00
	#define	EURASIA_PDS_IR0_PDM_TILEX_MAX					0xFF

	#define	EURASIA_PDS_IR0_PDM_TILEY_CLRMSK				0xFFFF00FFU
	#define	EURASIA_PDS_IR0_PDM_TILEY_SHIFT					8
	#define	EURASIA_PDS_IR0_PDM_TILEY_MIN					0x00
	#define	EURASIA_PDS_IR0_PDM_TILEY_MAX					0xFF

	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_PDS_IR0_PDM_EOR							(1UL << 16)
	#define EURASIA_PDS_IR0_PDM_EOR_EOT						(1UL << 17)
	#endif
#endif
#endif

/* Input Register 0 - Vertex DM */
#define	EURASIA_PDS_IR0_VDM_INDEX_CLRMSK				0xFF000000U
#define	EURASIA_PDS_IR0_VDM_INDEX_SHIFT					0
#define	EURASIA_PDS_IR0_VDM_INDEX_MIN					0x000000
#define	EURASIA_PDS_IR0_VDM_INDEX_MAX					0xFFFFFF

/* Input Register 0 - Event DM Non-Synchronised Events */
#if defined(SGX540) || defined(SGX541) || defined(SGX531)
	#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT		0
	#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM			(1UL << EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT				1
	#define EURASIA_PDS_IR0_EDM_EVENT_TIMER					(1UL << EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_CSC_INV_BIT			2
	#define EURASIA_PDS_IR0_EDM_EVENT_CSC_INV				(1UL << EURASIA_PDS_IR0_EDM_EVENT_CSC_INV_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_DSC_INV0_BIT			3
	#define EURASIA_PDS_IR0_EDM_EVENT_DSC_INV0				(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC_INV0_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_DSC_INV1_BIT			4
	#define EURASIA_PDS_IR0_EDM_EVENT_DSC_INV1				(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC_INV1_BIT)
	#if defined(SGX_FEATURE_MP)
		#define EURASIA_PDS_IR0_EDM_EVENT_MP3DMEMFREE_BIT	5
		#define EURASIA_PDS_IR0_EDM_EVENT_MP3DMEMFREE	(1UL << EURASIA_PDS_IR0_EDM_EVENT_MP3DMEMFREE_BIT)
	#endif
	#define EURASIA_PDS_IR0_EDM_EVENT_DSC_INV3_BIT			6
	#define EURASIA_PDS_IR0_EDM_EVENT_DSC_INV3				(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC_INV3_BIT)
	#if defined(SGX_FEATURE_MP)
		#define EURASIA_PDS_IR0_EDM_EVENT_MPPIXENDRENDER_BIT 	7
		#define EURASIA_PDS_IR0_EDM_EVENT_MPPIXENDRENDER	 	(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPPIXENDRENDER_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_MPTAFINISHED_BIT	 	8
		#define EURASIA_PDS_IR0_EDM_EVENT_MPTAFINISHED		 	(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPTAFINISHED_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_MPTATERMINATE_BIT		9
		#define EURASIA_PDS_IR0_EDM_EVENT_MPTATERMINATE			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPTATERMINATE_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_MPMEMTHRESH_BIT		10
		#define EURASIA_PDS_IR0_EDM_EVENT_MPMEMTHRESH			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPMEMTHRESH_BIT)
	#endif
	#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT		11
	#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT)
	#if defined(SGX_FEATURE_MP)
		#define EURASIA_PDS_IR0_EDM_EVENT_MPGBLOUTOFMEM_BIT			12
		#define EURASIA_PDS_IR0_EDM_EVENT_MPGBLOUTOFMEM				(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPGBLOUTOFMEM_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_MPMTOUTOFMEM_BIT			13
		#define EURASIA_PDS_IR0_EDM_EVENT_MPMTOUTOFMEM				(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPMTOUTOFMEM_BIT)
	#endif
	#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT		14
	#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD			(1UL << EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT		15
	#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD			(1UL << EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE_BIT		16
	#define EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE			(1UL << EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT		17
	#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR			(1UL << EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK_BIT		18
	#define EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP_BIT			19
	#define EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP				(1UL << EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP_BIT			20
	#define EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1_BIT			21
	#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1				(1UL << EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1_BIT)
	#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2_BIT			22
	#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2				(1UL << EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2_BIT)
#else
	#if defined(SGX545)
		#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT			0
		#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM				(1UL << EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT					1
		#define EURASIA_PDS_IR0_EDM_EVENT_TIMER						(1UL << EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_CSC0_INV_BIT				2
		#define EURASIA_PDS_IR0_EDM_EVENT_CSC0_INV					(1UL << EURASIA_PDS_IR0_EDM_EVENT_CSC0_INV_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0_BIT				3
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0					(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1_BIT				4
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1					(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3_BIT				6
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3					(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_CSC1_INV_BIT				7
		#define EURASIA_PDS_IR0_EDM_EVENT_CSC1_INV					(1UL << EURASIA_PDS_IR0_EDM_EVENT_CSC1_INV_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0_BIT				8
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0					(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1_BIT				9
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1					(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3_BIT				11
		#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3					(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT			12
		#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV				(1UL << EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD_BIT			13
		#define EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD				(1UL << EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD_BIT			14
		#define EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD				(1UL << EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT			15
		#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD				(1UL << EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT			16
		#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT			17
		#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK_BIT			18
		#define EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK				(1UL << EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP_BIT				19
		#define EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP					(1UL << EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP_BIT				20
		#define EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP					(1UL << EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_GSG_FLUSHED_BIT			21
		#define EURASIA_PDS_IR0_EDM_EVENT_GSG_FLUSHED				(1UL << EURASIA_PDS_IR0_EDM_EVENT_GSG_FLUSHED_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_GSG_LOADED_BIT			22
		#define EURASIA_PDS_IR0_EDM_EVENT_GSG_LOADED				(1UL << EURASIA_PDS_IR0_EDM_EVENT_GSG_LOADED_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1_BIT				23
		#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1					(1UL << EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2_BIT				24
		#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2					(1UL << EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_OTPM_MEM_CLEARED_BIT		25
		#define EURASIA_PDS_IR0_EDM_EVENT_OTPM_MEM_CLEARED			(1UL << EURASIA_PDS_IR0_EDM_EVENT_OTPM_MEM_CLEARED_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_OTPM_FLUSHED_INV_BIT		26
		#define EURASIA_PDS_IR0_EDM_EVENT_OTPM_FLUSHED_INV			(1UL << EURASIA_PDS_IR0_EDM_EVENT_OTPM_FLUSHED_INV_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_ISP2_ZLS_CSW_FINISHED_BIT	27
		#define EURASIA_PDS_IR0_EDM_EVENT_ISP2_ZLS_CSW_FINISHED		(1UL << EURASIA_PDS_IR0_EDM_EVENT_ISP2_ZLS_CSW_FINISHED_BIT)
		#define EURASIA_PDS_IR0_EDM_EVENT_MTE_STATE_FLUSHED_BIT		30
		#define EURASIA_PDS_IR0_EDM_EVENT_MTE_STATE_FLUSHED			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MTE_STATE_FLUSHED_BIT)
	#else /* #if defined(SGX545) */
		#if defined(SGX520)
			#define EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE_BIT	15
			#define EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE		(1UL << EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT	16
			#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR		(1UL << EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT	17
			#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM		(1UL << EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT			18
			#define EURASIA_PDS_IR0_EDM_EVENT_TIMER				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_CSCINV_BIT		19
			#define EURASIA_PDS_IR0_EDM_EVENT_CSCINV			(1UL << EURASIA_PDS_IR0_EDM_EVENT_CSCINV_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0_BIT		20
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1_BIT		21
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV2_BIT		22
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV2			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV2_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3_BIT		23
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0_BIT		24
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1_BIT		25
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV2_BIT		26
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV2			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV2_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3_BIT		27
			#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT	28
			#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV		(1UL << EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD_BIT	29
			#define EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD_BIT	30
			#define EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD_BIT)
			#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT	31
			#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT)
		#else /* SGX520 */
			#if defined(SGX543) || defined(SGX544) || defined(SGX554)
				#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT		0
				#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM			(1UL << EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT				1
				#define EURASIA_PDS_IR0_EDM_EVENT_TIMER					(1UL << EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT)
#if defined(SGX_FEATURE_MP)
				#define EURASIA_PDS_IR0_EDM_EVENT_MP3DMEMFREE_BIT		2
				#define EURASIA_PDS_IR0_EDM_EVENT_MP3DMEMFREE			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MP3DMEMFREE_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MPPIXENDRENDER_BIT 	3
				#define EURASIA_PDS_IR0_EDM_EVENT_MPPIXENDRENDER	 	(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPPIXENDRENDER_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MPTAFINISHED_BIT	 	4
				#define EURASIA_PDS_IR0_EDM_EVENT_MPTAFINISHED		 	(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPTAFINISHED_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MPTATERMINATE_BIT		5
				#define EURASIA_PDS_IR0_EDM_EVENT_MPTATERMINATE			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPTATERMINATE_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MPMEMTHRESH_BIT		6
				#define EURASIA_PDS_IR0_EDM_EVENT_MPMEMTHRESH			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPMEMTHRESH_BIT)
#endif
				#define EURASIA_PDS_IR0_EDM_EVENT_TCU_INV_BIT			7
				#define EURASIA_PDS_IR0_EDM_EVENT_TCU_INV				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TCUINV_BIT)
#if defined(SGX_FEATURE_MP)
				#define EURASIA_PDS_IR0_EDM_EVENT_MPGBLOUTOFMEM_BIT		8
				#define EURASIA_PDS_IR0_EDM_EVENT_MPGBLOUTOFMEM			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPGBLOUTOFMEM_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MPMTOUTOFMEM_BIT		9
				#define EURASIA_PDS_IR0_EDM_EVENT_MPMTOUTOFMEM			(1UL << EURASIA_PDS_IR0_EDM_EVENT_MPMTOUTOFMEM_BIT)
#endif
				#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT		10
				#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD			(1UL << EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT		11
				#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD			(1UL << EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_PTLACOMPLETE_BIT		12
				#define EURASIA_PDS_IR0_EDM_EVENT_PTLACOMPLETE			(1UL << EURASIA_PDS_IR0_EDM_EVENT_PTLACOMPLETE_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK_BIT		13
				#define EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DPM_DEADLOCK_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP_BIT			14
				#define EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP				(1UL << EURASIA_PDS_IR0_EDM_EVENT_3D_LOCKUP_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP_BIT			15
				#define EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TA_LOCKUP_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1_BIT			16
				#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1				(1UL << EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT1_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2_BIT			17
				#define EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2				(1UL << EURASIA_PDS_IR0_EDM_EVENT_SW_EVENT2_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TE_RGNHDR_INIT_COMPLETE_BIT		18
				#define EURASIA_PDS_IR0_EDM_EVENT_TE_RGNHDR_INIT_COMPLETE	(1UL << EURASIA_PDS_IR0_EDM_EVENT_TE_RGNHDR_INIT_COMPLETE_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MTE_STATE_FLUSHED_BIT	19
				#define EURASIA_PDS_IR0_EDM_EVENT_MTE_STATE_FLUSHED		(1UL << EURASIA_PDS_IR0_EDM_EVENT_MTE_STATE_FLUSHED_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DCU_INV_BIT			20
				#define EURASIA_PDS_IR0_EDM_EVENT_DCU_INV				(1UL << EURASIA_PDS_IR0_EDM_EVENT_DCU_INV_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_ISP2_ZLS_CSW_FINISHED_BIT	21
				#define EURASIA_PDS_IR0_EDM_EVENT_ISP2_ZLS_CSW_FINISHED		(1UL << EURASIA_PDS_IR0_EDM_EVENT_ISP2_ZLS_CSW_FINISHED_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MTE_CONTEXT_DRAIN_BIT	22
				#define EURASIA_PDS_IR0_EDM_EVENT_MTE_CONTEXT_DRAIN		(1UL << EURASIA_PDS_IR0_EDM_EVENT_MTE_CONTEXT_DRAIN_BIT)
#if defined(SGX_FEATURE_MP)
				#define EURASIA_PDS_IR0_EDM_EVENT_MP_MTE_CONTEXT_DRAIN_BIT	27
				#define EURASIA_PDS_IR0_EDM_EVENT_MP_MTE_CONTEXT_DRAIN		(1UL << EURASIA_PDS_IR0_EDM_EVENT_MP_MTE_CONTEXT_DRAIN_BIT)
#endif
			#else /* SGX543 */
				#define EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE_BIT	14
				#define EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE		(1UL << EURASIA_PDS_IR0_EDM_EVENT_TWODCOMPLETE_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT	15
				#define EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR		(1UL << EURASIA_PDS_IR0_EDM_EVENT_TADPMERROR_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT	16
				#define EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM		(1UL << EURASIA_PDS_IR0_EDM_EVENT_ZLSOUTOFMEM_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT			17
				#define EURASIA_PDS_IR0_EDM_EVENT_TIMER				(1UL << EURASIA_PDS_IR0_EDM_EVENT_TIMER_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_CSCINV_BIT		18
				#define EURASIA_PDS_IR0_EDM_EVENT_CSCINV			(1UL << EURASIA_PDS_IR0_EDM_EVENT_CSCINV_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0_BIT		19
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV0_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1_BIT		20
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV1_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV2_BIT		21
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV2			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV2_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3_BIT		22
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC0_INV3_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0_BIT		23
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV0_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1_BIT		24
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV1_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV2_BIT		25
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV2			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV2_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3_BIT		26
				#define EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3			(1UL << EURASIA_PDS_IR0_EDM_EVENT_DSC1_INV3_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT	27
				#define EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV		(1UL << EURASIA_PDS_IR0_EDM_EVENT_MADDCACHEINV_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD_BIT	28
				#define EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_DHOSTFREELOAD_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD_BIT	29
				#define EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_HOSTFREELOAD_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT	30
				#define EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_3DFREELOAD_BIT)
				#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT	31
				#define EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD		(1UL << EURASIA_PDS_IR0_EDM_EVENT_TAFREELOAD_BIT)
			#endif /* #if defined(SGX543) || defined(SGX544) || defined(SGX554) */
		#endif /* #if defined(SGX520) */
	#endif /* #if defined(SGX545) */
#endif /* #if defined(SGX540) || defined(SGX541) || defined(SGX543) ||defined(SGX531) */


/* Input Register 1 - Vertex DM */
#define	EURASIA_PDS_IR1_VDM_WRAPCOUNT_CLRMSK			0xFF000000U
#define	EURASIA_PDS_IR1_VDM_WRAPCOUNT_SHIFT				0
#define	EURASIA_PDS_IR1_VDM_WRAPCOUNT_MIN				0x000000
#define	EURASIA_PDS_IR1_VDM_WRAPCOUNT_MAX				0xFFFFFF

/* Input Register 1 - Event DM (Non-Synchronised Events) */
#define EURASIA_PDS_IR1_EDM_EVENT_DPMINITEND_BIT	0
#define EURASIA_PDS_IR1_EDM_EVENT_DPMINITEND		(1UL << EURASIA_PDS_IR1_EDM_EVENT_DPMINITEND_BIT)
#if !defined(SGX545)
#define EURASIA_PDS_IR1_EDM_EVENT_OTPM_LOADED_BIT	1
#define EURASIA_PDS_IR1_EDM_EVENT_OTPM_LOADED		(1UL << EURASIA_PDS_IR1_EDM_EVENT_OTPM_LOADED_BIT)
#endif
#define EURASIA_PDS_IR1_EDM_EVENT_OTPM_INV_BIT		2
#define EURASIA_PDS_IR1_EDM_EVENT_OTPM_INV			(1UL << EURASIA_PDS_IR1_EDM_EVENT_OTPM_INV_BIT)
#define EURASIA_PDS_IR1_EDM_EVENT_OTPM_FLUSHED_BIT	3
#define EURASIA_PDS_IR1_EDM_EVENT_OTPM_FLUSHED		(1UL << EURASIA_PDS_IR1_EDM_EVENT_OTPM_FLUSHED_BIT)
#define EURASIA_PDS_IR1_EDM_EVENT_PIXENDRENDER_BIT	4
#define EURASIA_PDS_IR1_EDM_EVENT_PIXENDRENDER		(1UL << EURASIA_PDS_IR1_EDM_EVENT_PIXENDRENDER_BIT)

#if defined(SGX543) || defined(SGX544) || defined(SGX554)

	#define EURASIA_PDS_IR1_EDM_EVENT_ISPBREAKPOINT_BIT	5
	#define EURASIA_PDS_IR1_EDM_EVENT_ISPBREAKPOINT		(1UL << EURASIA_PDS_IR1_EDM_EVENT_ISPBREAKPOINT_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_SWEVENT_BIT		6
	#define EURASIA_PDS_IR1_EDM_EVENT_SWEVENT			(1UL << EURASIA_PDS_IR1_EDM_EVENT_SWEVENT_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TAFINISHED_BIT	7
	#define EURASIA_PDS_IR1_EDM_EVENT_TAFINISHED		(1UL << EURASIA_PDS_IR1_EDM_EVENT_TAFINISHED_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TATERMINATE_BIT	8
	#define EURASIA_PDS_IR1_EDM_EVENT_TATERMINATE		(1UL << EURASIA_PDS_IR1_EDM_EVENT_TATERMINATE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCRESET_BIT		9
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCRESET			(1UL << EURASIA_PDS_IR1_EDM_EVENT_TPCRESET_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCSTORE_BIT		10
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCSTORE			(1UL << EURASIA_PDS_IR1_EDM_EVENT_TPCSTORE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_MEMTHRESH_BIT		11
	#define EURASIA_PDS_IR1_EDM_EVENT_MEMTHRESH			(1UL << EURASIA_PDS_IR1_EDM_EVENT_MEMTHRESH_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_GBLOUTOFMEM_BIT	12
	#define EURASIA_PDS_IR1_EDM_EVENT_GBLOUTOFMEM		(1UL << EURASIA_PDS_IR1_EDM_EVENT_GBLOUTOFMEM_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_MTOUTOFMEM_BIT	13
	#define EURASIA_PDS_IR1_EDM_EVENT_MTOUTOFMEM		(1UL << EURASIA_PDS_IR1_EDM_EVENT_MTOUTOFMEM_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_3DMEMFREE_BIT		14
	#define EURASIA_PDS_IR1_EDM_EVENT_3DMEMFREE			(1UL << EURASIA_PDS_IR1_EDM_EVENT_3DMEMFREE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TAMEMFREE_BIT		15
	#define EURASIA_PDS_IR1_EDM_EVENT_TAMEMFREE			(1UL << EURASIA_PDS_IR1_EDM_EVENT_TAMEMFREE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_KICKPTR_CLRMSK	0xFF00FFFFU
	#define EURASIA_PDS_IR1_EDM_EVENT_KICKPTR_SHIFT		16

#else /* SGX543 || SGX544 || defined(SGX554) */

	#define EURASIA_PDS_IR1_EDM_EVENT_ISPHALT_BIT		5
	#define EURASIA_PDS_IR1_EDM_EVENT_ISPHALT			(1UL << EURASIA_PDS_IR1_EDM_EVENT_ISPHALT_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_ISPVISIBILITY_BIT	6
	#define EURASIA_PDS_IR1_EDM_EVENT_ISPVISIBILITY		(1UL << EURASIA_PDS_IR1_EDM_EVENT_ISPVISIBILITY_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_ISPBREAKPOINT_BIT	7
	#define EURASIA_PDS_IR1_EDM_EVENT_ISPBREAKPOINT		(1UL << EURASIA_PDS_IR1_EDM_EVENT_ISPBREAKPOINT_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_SWEVENT_BIT		8
	#define EURASIA_PDS_IR1_EDM_EVENT_SWEVENT			(1UL << EURASIA_PDS_IR1_EDM_EVENT_SWEVENT_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TAFINISHED_BIT	9
	#define EURASIA_PDS_IR1_EDM_EVENT_TAFINISHED		(1UL << EURASIA_PDS_IR1_EDM_EVENT_TAFINISHED_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TATERMINATE_BIT	10
	#define EURASIA_PDS_IR1_EDM_EVENT_TATERMINATE		(1UL << EURASIA_PDS_IR1_EDM_EVENT_TATERMINATE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCRESET_BIT		11
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCRESET			(1UL << EURASIA_PDS_IR1_EDM_EVENT_TPCRESET_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCSTORE_BIT		12
	#define EURASIA_PDS_IR1_EDM_EVENT_TPCSTORE			(1UL << EURASIA_PDS_IR1_EDM_EVENT_TPCSTORE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_CONTROLRESET_BIT	13
	#define EURASIA_PDS_IR1_EDM_EVENT_CONTROLRESET		(1UL << EURASIA_PDS_IR1_EDM_EVENT_SUBPRESET_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_CONTROLLOAD_BIT	14
	#define EURASIA_PDS_IR1_EDM_EVENT_CONTROLLOAD		(1UL << EURASIA_PDS_IR1_EDM_EVENT_SUBPLOAD_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_CONTROLSTORE_BIT	15
	#define EURASIA_PDS_IR1_EDM_EVENT_CONTROLSTORE		(1UL << EURASIA_PDS_IR1_EDM_EVENT_SUBPSTORE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_STATERESET_BIT	16
	#define EURASIA_PDS_IR1_EDM_EVENT_STATERESET		(1UL << EURASIA_PDS_IR1_EDM_EVENT_STATERESET_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_STATELOAD_BIT		17
	#define EURASIA_PDS_IR1_EDM_EVENT_STATELOAD			(1UL << EURASIA_PDS_IR1_EDM_EVENT_STATELOAD_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_STATESTORE_BIT	18
	#define EURASIA_PDS_IR1_EDM_EVENT_STATESTORE		(1UL << EURASIA_PDS_IR1_EDM_EVENT_STATESTORE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_MEMTHRESH_BIT		19
	#define EURASIA_PDS_IR1_EDM_EVENT_MEMTHRESH			(1UL << EURASIA_PDS_IR1_EDM_EVENT_MEMTHRESH_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_GBLOUTOFMEM_BIT	20
	#define EURASIA_PDS_IR1_EDM_EVENT_GBLOUTOFMEM		(1UL << EURASIA_PDS_IR1_EDM_EVENT_GBLOUTOFMEM_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_MTOUTOFMEM_BIT	21
	#define EURASIA_PDS_IR1_EDM_EVENT_MTOUTOFMEM		(1UL << EURASIA_PDS_IR1_EDM_EVENT_MTOUTOFMEM_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_3DMEMFREE_BIT		22
	#define EURASIA_PDS_IR1_EDM_EVENT_3DMEMFREE			(1UL << EURASIA_PDS_IR1_EDM_EVENT_3DMEMFREE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_TAMEMFREE_BIT		23
	#define EURASIA_PDS_IR1_EDM_EVENT_TAMEMFREE			(1UL << EURASIA_PDS_IR1_EDM_EVENT_TAMEMFREE_BIT)
	#define EURASIA_PDS_IR1_EDM_EVENT_KICKPTR_CLRMSK	0x00FFFFFFU
	#define EURASIA_PDS_IR1_EDM_EVENT_KICKPTR_SHIFT		24

#endif /* defined(SGX543) || defined(SGX544) || defined(SGX554) */

/* Input Register 1 - Event DM (Synchronised Events) */
#define EURASIA_PDS_IR1_PIX_EVENT_ENDPASS_BIT		0
#define EURASIA_PDS_IR1_PIX_EVENT_ENDPASS			(1UL << EURASIA_PDS_IR1_PIX_EVENT_ENDPASS_BIT)
#define EURASIA_PDS_IR1_PIX_EVENT_ENDTILE_BIT		1
#define EURASIA_PDS_IR1_PIX_EVENT_ENDTILE			(1UL << EURASIA_PDS_IR1_PIX_EVENT_ENDTILE_BIT)
#define EURASIA_PDS_IR1_PIX_EVENT_ENDRENDER_BIT		2
#define EURASIA_PDS_IR1_PIX_EVENT_ENDRENDER			(1UL << EURASIA_PDS_IR1_PIX_EVENT_ENDRENDER_BIT)
#define EURASIA_PDS_IR1_PIX_EVENT_SENDPTOFF_BIT		3
#define EURASIA_PDS_IR1_PIX_EVENT_SENDPTOFF			(1UL << EURASIA_PDS_IR1_PIX_EVENT_SENDPTOFF_BIT)

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
#define EURASIA_PDS_IR1_PIX_EVENT_ZEROCNT_BIT		8
#define EURASIA_PDS_IR1_PIX_EVENT_ZEROCNT			(1UL << EURASIA_PDS_IR1_PIX_EVENT_ZEROCNT_BIT)
#endif

#define EURASIA_PDS_IR1_PIX_EVENT_PASSTYPE_CLRMSK	0x8FFFFFFFU
#define EURASIA_PDS_IR1_PIX_EVENT_PASSTYPE_SHIFT	28

/* Program Counter */
#define	EURASIA_PDS_PCFETCHADDR_CLRMSK				0xFFF80000U
#define	EURASIA_PDS_PCFETCHADDR_SHIFT				0

/* Software Loop Counter */
#define	EURASIA_PDS_SLC_CODEADDR_CLRMSK				0xFFF80000U
#define	EURASIA_PDS_SLC_CODEADDR_SHIFT				0
#define	EURASIA_PDS_SLC_LOOPSIZE_CLRMSK				0xF807FFFFU
#define	EURASIA_PDS_SLC_LOOPSIZE_SHIFT				19
#define	EURASIA_PDS_SLC_LOOPCNT_CLRMSK				0x07FFFFFFU
#define	EURASIA_PDS_SLC_LOOPCNT_SHIFT				27

/* Status register definitions. */
#define EURASIA_PDS_STATUS_COND0					(1UL << 0)
#define EURASIA_PDS_STATUS_COND1					(1UL << 1)
#define EURASIA_PDS_STATUS_COND2					(1UL << 2)
#define EURASIA_PDS_STATUS_IF0						(1UL << 3)
#define EURASIA_PDS_STATUS_IF1						(1UL << 4)
#define EURASIA_PDS_STATUS_IF2						(1UL << 5)
#define EURASIA_PDS_STATUS_ZERO						(1UL << 6)
#define EURASIA_PDS_STATUS_NEGATIVE					(1UL << 7)
#define EURASIA_PDS_STATUS_COUNTERZERO				(1UL << 8)
#define EURASIA_PDS_STATUS_OVERFLOW					(1UL << 16)
#define EURASIA_PDS_STATUS_UNDERFLOW				(1UL << 17)
#define EURASIA_PDS_STATUS_DOUTIENABLE				(1UL << 18)
#define EURASIA_PDS_STATUS_DOUTTENABLE				(1UL << 19)
#define EURASIA_PDS_STATUS_DOUTDENABLE				(1UL << 20)
#define EURASIA_PDS_STATUS_DOUTUENABLE				(1UL << 21)
#define EURASIA_PDS_STATUS_ALUSIGNED				(1UL << 31)

/*****************************************************************************
 PDS Direct Attribute Write Interface
*****************************************************************************/
#define EURASIA_PDS_DOUTA0_DATA_CLRMSK				0x00000000U
#define EURASIA_PDS_DOUTA0_DATA_SHIFT				0

#if !defined(SGX545)
	#define EURASIA_PDS_DOUTA1_AO_CLRMSK				0xFFF000FFU
	#define EURASIA_PDS_DOUTA1_AO_SHIFT					8
#else
	#define EURASIA_PDS_DOUTA1_AO_CLRMSK				0xFFF800FFU
	#define EURASIA_PDS_DOUTA1_AO_SHIFT					8
#endif

/*****************************************************************************
 PDS FPU (Iterator) Interface
*****************************************************************************/

/* Iterator Output Register */
#if !defined(SGX545)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_CLRMSK			0xFFFFFFF0U
	#define	EURASIA_PDS_DOUTI_TEXISSUE_SHIFT			0
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC0				(0UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC1				(1UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC2				(2UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC3				(3UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC4				(4UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC5				(5UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC6				(6UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC7				(7UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC8				(8UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC9				(9UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_NONE				(15UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)

	#define	EURASIA_PDS_DOUTI_TEXCENTROID				(1UL << 4)

	#define EURASIA_PDS_DOUTI_TEXWRAP_CLRMSK			0xFFFFFF1FU
	#define EURASIA_PDS_DOUTI_TEXWRAP_SHIFT				5

	#define EURASIA_PDS_DOUTI_TEXPROJ_CLRMSK			0xFFFFFCFFU
	#define EURASIA_PDS_DOUTI_TEXPROJ_SHIFT				8
	#define EURASIA_PDS_DOUTI_TEXPROJ_NONE				(0UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#define EURASIA_PDS_DOUTI_TEXPROJ_RHW				(1UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#define EURASIA_PDS_DOUTI_TEXPROJ_T					(2UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#if defined(SGX_FEATURE_CEM_S_USES_PROJ)
	#define EURASIA_PDS_DOUTI_TEXPROJ_S					(3UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#else /* defined(SGX530) */
	#define EURASIA_PDS_DOUTI_TEXPROJ_RESERVED			(3UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#endif /* defined(SGX530) */

	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_PDS_DOUTI_TEX_POINTSPRITE_FORCED	(1UL << 10)
	#endif

	#define EURASIA_PDS_DOUTI_TEXLASTISSUE				(1UL << 11)

	#define	EURASIA_PDS_DOUTI_USEISSUE_CLRMSK			0xFFFF0FFFU
	#define	EURASIA_PDS_DOUTI_USEISSUE_SHIFT			12
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC0				(0UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC1				(1UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC2				(2UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC3				(3UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC4				(4UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC5				(5UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC6				(6UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC7				(7UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC8				(8UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC9				(9UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_V0				(10UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_V1				(11UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_FOG				(12UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_POSITION			(13UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#if !defined(SGX_FEATURE_ALPHATEST_AUTO_COEFF)
	#define EURASIA_PDS_DOUTI_USEISSUE_ZABS				(14UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#endif
	#define	EURASIA_PDS_DOUTI_USEISSUE_NONE				(15UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)

	#define	EURASIA_PDS_DOUTI_USECENTROID				(1UL << 16)

	#define EURASIA_PDS_DOUTI_USEWRAP_CLRMSK			0xFFF1FFFFU
	#define EURASIA_PDS_DOUTI_USEWRAP_SHIFT				17

	#define EURASIA_PDS_DOUTI_USECOLFLOAT				(1UL << 20)

	#if !defined(SGX543) && !defined(SGX544) && !defined(SGX554)
	#define EURASIA_PDS_DOUTI_USEPERTRIANGLE			(1UL << 21)
	#endif

	#define EURASIA_PDS_DOUTI_USEDIM_CLRMSK				0xFF3FFFFFU
	#define EURASIA_PDS_DOUTI_USEDIM_SHIFT				22
	#define EURASIA_PDS_DOUTI_USEDIM_1D					(0UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)
	#define EURASIA_PDS_DOUTI_USEDIM_2D					(1UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)
	#define EURASIA_PDS_DOUTI_USEDIM_3D					(2UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)
	#define EURASIA_PDS_DOUTI_USEDIM_4D					(3UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)

	#define EURASIA_PDS_DOUTI_USEPERSPECTIVE			(1UL << 24)

	#define EURASIA_PDS_DOUTI_USELASTISSUE				(1UL << 25)

	#define	EURASIA_PDS_DOUTI_FLATSHADE_CLRMSK			0xF3FFFFFFU
	#define	EURASIA_PDS_DOUTI_FLATSHADE_SHIFT			26
	#define	EURASIA_PDS_DOUTI_FLATSHADE_VTX0			(0UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)
	#define	EURASIA_PDS_DOUTI_FLATSHADE_VTX1			(1UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)
	#define	EURASIA_PDS_DOUTI_FLATSHADE_VTX2			(2UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)
	#define	EURASIA_PDS_DOUTI_FLATSHADE_GOURAUD			(3UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)

	#if defined(SGX_FEATURE_EXTENDED_USE_ALU)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_CLRMSK			0xCFFFFFFFU
	#define	EURASIA_PDS_DOUTI_USEFORMAT_SHIFT			28
	#define	EURASIA_PDS_DOUTI_USEFORMAT_INT8			(0UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_INT10			(1UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_F16				(2UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_RESERVED		(3UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#endif /* defined(SGX_FEATURE_EXTENDED_USE_ALU) */

	#if defined(SGX_FEATURE_PERLAYER_POINTCOORD)
	#define EURASIA_PDS_DOUTI_USE_POINTSPRITE_FORCED	(1UL << 30)
	#endif

	#define	EURASIA_PDS_DOUTI_STATE_SIZE				1
#else
	#define	EURASIA_PDS_DOUTI_TEXISSUE_CLRMSK			0xFFFFFFE0U
	#define	EURASIA_PDS_DOUTI_TEXISSUE_SHIFT			0
	#define	EURASIA_PDS_DOUTI_TEXISSUE_NONE				(0UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC0				(1UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC1				(2UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC2				(3UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC3				(4UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC4				(5UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC5				(6UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC6				(7UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC7				(8UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC8				(9UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC9				(10UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC10				(11UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC11				(12UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC12				(13UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC13				(14UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC14				(15UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC15				(16UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC16				(17UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC17				(18UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC18				(19UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC19				(20UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC20				(21UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC21				(22UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC22				(23UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC23				(24UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC24				(25UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC25				(26UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC26				(27UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC27				(28UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC28				(29UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC29				(30UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_TEXISSUE_TC30				(31UL	<< EURASIA_PDS_DOUTI_TEXISSUE_SHIFT)

	#define	EURASIA_PDS_DOUTI_TEXCENTROID				(1UL << 5)

	#define EURASIA_PDS_DOUTI_TEXWRAP_CLRMSK			0xFFFFFE2FU
	#define EURASIA_PDS_DOUTI_TEXWRAP_SHIFT				6

	#define EURASIA_PDS_DOUTI_TEXPROJ_CLRMSK			0xFFFFF9FFU
	#define EURASIA_PDS_DOUTI_TEXPROJ_SHIFT				9
	#define EURASIA_PDS_DOUTI_TEXPROJ_NONE				(0UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#define EURASIA_PDS_DOUTI_TEXPROJ_RHW				(1UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#define EURASIA_PDS_DOUTI_TEXPROJ_T					(2UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)
	#define EURASIA_PDS_DOUTI_TEXPROJ_RESERVED			(3UL	<< EURASIA_PDS_DOUTI_TEXPROJ_SHIFT)

	#define	EURASIA_PDS_DOUTI_USEISSUE_CLRMSK			0xFFFE07FFU
	#define	EURASIA_PDS_DOUTI_USEISSUE_SHIFT			11
	#define	EURASIA_PDS_DOUTI_USEISSUE_POSITION			(0UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC0				(1UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC1				(2UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC2				(3UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC3				(4UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC4				(5UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC5				(6UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC6				(7UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC7				(8UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC8				(9UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC9				(10UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC10				(11UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC11				(12UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC12				(13UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC13				(14UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC14				(15UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC15				(16UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC16				(17UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC17				(18UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC18				(19UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC19				(20UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC20				(21UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC21				(22UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC22				(23UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC23				(24UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC24				(25UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC25				(26UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC26				(27UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC27				(28UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC28				(29UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC29				(30UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_TC30				(31UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_V0				(32UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_V1				(33UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_ZABS				(34UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define EURASIA_PDS_DOUTI_USEISSUE_PRIMID			(35UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEISSUE_NONE				(36UL	<< EURASIA_PDS_DOUTI_USEISSUE_SHIFT)

	#define	EURASIA_PDS_DOUTI_USECENTROID				(1UL << 17)

	#define EURASIA_PDS_DOUTI_USEWRAP_CLRMSK			0xFFE3FFFFU
	#define EURASIA_PDS_DOUTI_USEWRAP_SHIFT				18

	#define EURASIA_PDS_DOUTI_USECOLFLOAT				(1UL << 21)

	#define EURASIA_PDS_DOUTI_USEDIM_CLRMSK				0xFF3FFFFFU
	#define EURASIA_PDS_DOUTI_USEDIM_SHIFT				22
	#define EURASIA_PDS_DOUTI_USEDIM_1D					(0UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)
	#define EURASIA_PDS_DOUTI_USEDIM_2D					(1UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)
	#define EURASIA_PDS_DOUTI_USEDIM_3D					(2UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)
	#define EURASIA_PDS_DOUTI_USEDIM_4D					(3UL	<< EURASIA_PDS_DOUTI_USEDIM_SHIFT)

	#define EURASIA_PDS_DOUTI_USEPERSPECTIVE			(1UL << 24)

	#define	EURASIA_PDS_DOUTI_FLATSHADE_CLRMSK			0xF9FFFFFFU
	#define	EURASIA_PDS_DOUTI_FLATSHADE_SHIFT			25
	#define	EURASIA_PDS_DOUTI_FLATSHADE_VTX0			(0UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)
	#define	EURASIA_PDS_DOUTI_FLATSHADE_VTX1			(1UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)
	#define	EURASIA_PDS_DOUTI_FLATSHADE_VTX2			(2UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)
	#define	EURASIA_PDS_DOUTI_FLATSHADE_GOURAUD			(3UL	<< EURASIA_PDS_DOUTI_FLATSHADE_SHIFT)

	#define	EURASIA_PDS_DOUTI_USEFORMAT_CLRMSK			0xE7FFFFFFU
	#define	EURASIA_PDS_DOUTI_USEFORMAT_SHIFT			27
	#define	EURASIA_PDS_DOUTI_USEFORMAT_INT8			(0UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_INT10			(1UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_F16				(2UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTI_USEFORMAT_RESERVED		(3UL	<< EURASIA_PDS_DOUTI_USEFORMAT_SHIFT)

	#define EURASIA_PDS_DOUTI_USELASTISSUE				(1UL << 29)
	#define EURASIA_PDS_DOUTI_TEXLASTISSUE				(1UL << 30)

	#define EURASIA_PDS_DOUTI1_USESAMPLE_RATE_CLRMSK		0xFFFFFFFCU
	#define EURASIA_PDS_DOUTI1_USESAMPLE_RATE_SHIFT		0

	#define EURASIA_PDS_DOUTI1_TEXSAMPLE_RATE_CLRMSK		0xFFFFFFF3U
	#define EURASIA_PDS_DOUTI1_TEXSAMPLE_RATE_SHIFT		2

	#define EURASIA_PDS_XXXSAMPLE_RATE_SINGLE			0
	#define EURASIA_PDS_XXXSAMPLE_RATE_MULTI			2
	#define EURASIA_PDS_XXXSAMPLE_RATE_DUPLICATION		3

	#define EURASIA_PDS_DOUTI1_UPOINTSPRITE_FORCE		(1UL << 4)
	#define EURASIA_PDS_DOUTI1_TPOINTSPRITE_FORCE		(1UL << 5)

	#define EURASIA_PDS_DOUTI1_UDONT_ITERATE			(1UL << 6)

	#define EURASIA_PDS_DOUTI1_ORDERDEPAA				(1UL << 7)

	#define	EURASIA_PDS_DOUTI_STATE_SIZE				2
#endif


/*****************************************************************************
 PDS USE Interface
*****************************************************************************/

/* USE Interface Word 0 */
	#define	EURASIA_PDS_DOUTU0_CBASE_CLRMSK				0xFFFFFFF0U
	#define	EURASIA_PDS_DOUTU0_CBASE_SHIFT				0
	#define	EURASIA_PDS_DOUTU0_CBASE_MIN				0x0
	#define	EURASIA_PDS_DOUTU0_CBASE_MAX				0xF

#if defined(SGX_FEATURE_USE_UNLIMITED_PHASES)

#if (SGX_FEATURE_USE_NUMBER_PC_BITS == 20)
	#define	EURASIA_PDS_DOUTU0_EXE_CLRMSK				0xFF00000FU
	#define	EURASIA_PDS_DOUTU0_EXE_SHIFT				4
	#define	EURASIA_PDS_DOUTU0_EXE_MIN					0x0
	#define	EURASIA_PDS_DOUTU0_EXE_MAX					0x000FFFFF
	#define EURASIA_PDS_DOUTU0_EXE_ALIGNSHIFT			3			/* Define to get from bytes to 64 bit instructions */

	#define EURASIA_PDS_DOUTU0_TRC_ALIGNSHIFT			2
	#define EURASIA_PDS_DOUTU_TRC_ALIGNSHIFT			EURASIA_PDS_DOUTU0_TRC_ALIGNSHIFT

	#define	EURASIA_PDS_DOUTU0_TRC_CLRMSK				0x00FFFFFFU
	#define	EURASIA_PDS_DOUTU0_TRC_SHIFT				24
	#define	EURASIA_PDS_DOUTU0_TRC_MIN					0x00
	#define	EURASIA_PDS_DOUTU0_TRC_MAX					0xFF

	/* USE Interface Word 1 */
	#define	EURASIA_PDS_DOUTU1_MODE_CLRMSK				(0xFFFFFFFEU)
	#define	EURASIA_PDS_DOUTU1_MODE_SHIFT				(0)
	#define	EURASIA_PDS_DOUTU1_MODE_PARALLEL			(0UL	<< EURASIA_PDS_DOUTU1_MODE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_MODE_PERINSTANCE			(1UL	<< EURASIA_PDS_DOUTU1_MODE_SHIFT)

	#define EURASIA_PDS_DOUTU1_SDSOFT					(1UL << 1)

	#define EURASIA_PDS_DOUTU1_ITERATORSDEPENDENCY		(1UL << 2)
	#define EURASIA_PDS_DOUTU1_TEXTUREDEPENDENCY		(1UL << 3)

	#define	EURASIA_PDS_DOUTU1_SAMPLE_RATE_CLRMSK		(0xFFFFFFCFU)
	#define	EURASIA_PDS_DOUTU1_SAMPLE_RATE_SHIFT		(4)
	#define	EURASIA_PDS_DOUTU1_SAMPLE_RATE_INSTANCE		(0UL	<< EURASIA_PDS_DOUTU1_SAMPLE_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_SAMPLE_RATE_SELECTIVE	(1UL	<< EURASIA_PDS_DOUTU1_SAMPLE_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_SAMPLE_RATE_FULL			(2UL	<< EURASIA_PDS_DOUTU1_SAMPLE_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_SAMPLE_RATE_RESERVED		(3UL	<< EURASIA_PDS_DOUTU1_SAMPLE_RATE_SHIFT)

	/* USE Interface Word 2 */
	#define EURASIA_PDS_DOUTU2_TILEX_SHIFT				0
	#define EURASIA_PDS_DOUTU2_TILEX_CLRMSK				0xFFFFFF00U

	#define EURASIA_PDS_DOUTU2_TILEY_SHIFT				8
	#define EURASIA_PDS_DOUTU2_TILEY_CLRMSK				0xFFFF00FFU

	#define	EURASIA_PDS_DOUTU2_ENDOFRENDER_SHIFT		16
	#define	EURASIA_PDS_DOUTU2_ENDOFRENDER_CLRMSK		0xFFFEFFFFU

	#define	EURASIA_PDS_DOUTU2_PBENABLE					(1UL << 17)

#else

	#define	EURASIA_PDS_DOUTU0_EXE_CLRMSK				0xFFC0000FU
	#define	EURASIA_PDS_DOUTU0_EXE_SHIFT				4
	#define	EURASIA_PDS_DOUTU0_EXE_MIN					0x0
	#define	EURASIA_PDS_DOUTU0_EXE_MAX					0x0003FFFFU
	#define EURASIA_PDS_DOUTU0_EXE_ALIGNSHIFT			3U			/* Define to get from bytes to 64 bit instructions */

	#define	EURASIA_PDS_DOUTU0_SAMPLE_RATE_CLRMSK		(0xFF3FFFFFU)
	#define	EURASIA_PDS_DOUTU0_SAMPLE_RATE_SHIFT		(22)
	#define	EURASIA_PDS_DOUTU0_SAMPLE_RATE_INSTANCE		(0UL	<< EURASIA_PDS_DOUTU0_SAMPLE_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU0_SAMPLE_RATE_SELECTIVE	(1UL	<< EURASIA_PDS_DOUTU0_SAMPLE_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU0_SAMPLE_RATE_FULL			(2UL	<< EURASIA_PDS_DOUTU0_SAMPLE_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU0_SAMPLE_RATE_RESERVED		(3UL	<< EURASIA_PDS_DOUTU0_SAMPLE_RATE_SHIFT)

	#define EURASIA_PDS_DOUTU0_TRC_ALIGNSHIFT			2UL
	#define EURASIA_PDS_DOUTU_TRC_ALIGNSHIFT			EURASIA_PDS_DOUTU0_TRC_ALIGNSHIFT

	#define	EURASIA_PDS_DOUTU0_TRC_CLRMSK				0x00FFFFFFU
	#define	EURASIA_PDS_DOUTU0_TRC_SHIFT				24
	#define	EURASIA_PDS_DOUTU0_TRC_MIN					0x00
	#define	EURASIA_PDS_DOUTU0_TRC_MAX					0xFF


	/* USE Interface Word 1 */
	#define EURASIA_PDS_DOUTU1_PA_RATE_CLRMSK			(0xFFFFFFFEU)
	#define EURASIA_PDS_DOUTU1_PA_RATE_SHIFT			(0)
	#define	EURASIA_PDS_DOUTU1_PA_RATE_INSTANCE			(0UL	<< EURASIA_PDS_DOUTU1_PA_RATE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_PA_RATE_SAMPLE			(1UL	<< EURASIA_PDS_DOUTU1_PA_RATE_SHIFT)

	#define	EURASIA_PDS_DOUTU1_MODE_CLRMSK				(0xFFFFFFFDU)
	#define	EURASIA_PDS_DOUTU1_MODE_SHIFT				(1)
	#define	EURASIA_PDS_DOUTU1_MODE_PARALLEL			(0UL	<< EURASIA_PDS_DOUTU1_MODE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_MODE_PERINSTANCE			(1UL	<< EURASIA_PDS_DOUTU1_MODE_SHIFT)

	#define EURASIA_PDS_DOUTU1_SDSOFT					(1UL << 2)

	#define EURASIA_PDS_DOUTU1_TILEX_SHIFT				3
	#define EURASIA_PDS_DOUTU1_TILEX_CLRMSK				0xFFFFF007U

	#define EURASIA_PDS_DOUTU1_TILEY_SHIFT				12
	#define EURASIA_PDS_DOUTU1_TILEY_CLRMSK				0xFFC00FFFU

	#define	EURASIA_PDS_DOUTU1_ENDOFRENDER_SHIFT		22
	#define	EURASIA_PDS_DOUTU1_ENDOFRENDER_CLRMSK		0xFFBFFFFFU

	#define	EURASIA_PDS_DOUTU1_PBENABLE					(1UL << 23)
	#define EURASIA_PDS_DOUTU1_ITERATORSDEPENDENCY		(1UL << 24)
	#define EURASIA_PDS_DOUTU1_TEXTUREDEPENDENCY		(1UL << 25)

#endif

	/*
		Number of dwords of state required by the DOUTU command by a non-loopback task.
	*/
	#define EURASIA_PDS_DOUTU_NONLOOPBACK_STATE_SIZE	(3)

#else /* SGX_FEATURE_USE_UNLIMITED_PHASES */

	#define	EURASIA_PDS_DOUTU0_COFF_CLRMSK				0xFFFFFF0FU
	#define	EURASIA_PDS_DOUTU0_COFF_SHIFT				4
	#define	EURASIA_PDS_DOUTU0_COFF_MIN					0x0
	#define	EURASIA_PDS_DOUTU0_COFF_MAX					0xF

	/* This is the byte align shift for the offset field */
	#define EURASIA_PDS_DOUTU0_COFF_ALIGNSHIFT			15

	#define	EURASIA_PDS_DOUTU0_EXE_CLRMSK				0xFFF800FFU
	#define	EURASIA_PDS_DOUTU0_EXE_SHIFT				8
	#define	EURASIA_PDS_DOUTU0_EXE_MIN					0x000
	#define	EURASIA_PDS_DOUTU0_EXE_MAX					0x7FF
	#define EURASIA_PDS_DOUTU0_EXE_ALIGNSHIFT			4			/* Define to get from bytes to 128 bit instruction pairs */

	#define EURASIA_PDS_DOUTU0_ITERATORSDEPENDENCY		(1UL << 19)
	#define EURASIA_PDS_DOUTU0_TEXTUREDEPENDENCY		(1UL << 20)
	#define EURASIA_PDS_DOUTU0_PDSDMADEPENDENCY			(1UL << 21)

/* USE Interface Word 1 */
	#define EURASIA_PDS_DOUTU1_EXE1VALID_SHIFT			0
	#define EURASIA_PDS_DOUTU1_EXE1VALID				(1UL << EURASIA_PDS_DOUTU1_EXE1VALID_SHIFT)

	#define	EURASIA_PDS_DOUTU1_EXE1_CLRMSK				0xFFFFF001U
	#define	EURASIA_PDS_DOUTU1_EXE1_SHIFT				1
	#define	EURASIA_PDS_DOUTU1_EXE1_MIN					0x000
	#define	EURASIA_PDS_DOUTU1_EXE1_MAX					0x7FF
	#define EURASIA_PDS_DOUTU1_EXE1_ALIGNSHIFT			4

	#define EURASIA_PDS_DOUTU1_EXE2VALID_SHIFT			12
	#define	EURASIA_PDS_DOUTU1_EXE2VALID				(1UL << EURASIA_PDS_DOUTU1_EXE2VALID_SHIFT)

	#define	EURASIA_PDS_DOUTU1_EXE2_CLRMSK				0xFF001FFFU
	#define	EURASIA_PDS_DOUTU1_EXE2_SHIFT				13
	#define	EURASIA_PDS_DOUTU1_EXE2_MIN					0x000
	#define	EURASIA_PDS_DOUTU1_EXE2_MAX					0x7FF
	#define EURASIA_PDS_DOUTU1_EXE2_ALIGNSHIFT			4

	#define EURASIA_PDS_DOUTU1_PUNCHTHROUGH_SHIFT		(24)
	#define EURASIA_PDS_DOUTU1_PUNCHTHROUGH_CLRMSK		0xFCFFFFFFU
	#define EURASIA_PDS_DOUTU1_PUNCHTHROUGH_DISABLED	(0UL	<< EURASIA_PDS_DOUTU1_PUNCHTHROUGH_SHIFT)
	#define EURASIA_PDS_DOUTU1_PUNCHTHROUGH_PHASE1		(1UL	<< EURASIA_PDS_DOUTU1_PUNCHTHROUGH_SHIFT)
	#define EURASIA_PDS_DOUTU1_PUNCHTHROUGH_PHASE2		(2UL	<< EURASIA_PDS_DOUTU1_PUNCHTHROUGH_SHIFT)
	#define EURASIA_PDS_DOUTU1_PUNCHTHROUGH_RESERVED	(3UL	<< EURASIA_PDS_DOUTU1_PUNCHTHROUGH_SHIFT)

	#define	EURASIA_PDS_DOUTU1_MODE_CLRMSK				0xFBFFFFFFU
	#define	EURASIA_PDS_DOUTU1_MODE_SHIFT				26
	#define	EURASIA_PDS_DOUTU1_MODE_PARALLEL			(0UL	<< EURASIA_PDS_DOUTU1_MODE_SHIFT)
	#define	EURASIA_PDS_DOUTU1_MODE_PERINSTANCE			(1UL	<< EURASIA_PDS_DOUTU1_MODE_SHIFT)

	// FIXME: clean this up when client drivers stop using EURASIA_PDS_DOUTU_TRC_ALIGNSHIFT
	#define EURASIA_PDS_DOUTU1_TRC_ALIGNSHIFT			0
	#define EURASIA_PDS_DOUTU_TRC_ALIGNSHIFT			EURASIA_PDS_DOUTU1_TRC_ALIGNSHIFT

	#define	EURASIA_PDS_DOUTU1_TRC_CLRMSK				0x07FFFFFFU
	#define	EURASIA_PDS_DOUTU1_TRC_SHIFT				27
	#define	EURASIA_PDS_DOUTU1_TRC_MIN					0x000
	#define	EURASIA_PDS_DOUTU1_TRC_MAX					0x1FF


/* USE Interface Word 2 */
	#define	EURASIA_PDS_DOUTU2_TRC_CLRMSK				0xFFFFFFF0U
	#define	EURASIA_PDS_DOUTU2_TRC_SHIFT				0
	#define EURASIA_PDS_DOUTU2_TRC_INTERNALSHIFT		5

	#define	EURASIA_PDS_DOUTU2_OBPSEUDO_SHIFT			4
	#define EURASIA_PDS_DOUTU2_OBPSEUDO					(1UL << EURASIA_PDS_DOUTU2_OBPSEUDO_SHIFT)

	#define EURASIA_PDS_DOUTU2_SDSOFT					(1UL << 5)

	#define EURASIA_PDS_DOUTU2_FORCEONEDGE				(1UL << 6)

	#ifndef SGX520
		#define EURASIA_PDS_DOUTU2_TILEX_SHIFT				11
		#define EURASIA_PDS_DOUTU2_TILEX_CLRMSK			0xFFF807FFU

		#define EURASIA_PDS_DOUTU2_TILEY_SHIFT				19
		#define EURASIA_PDS_DOUTU2_TILEY_CLRMSK			0xF807FFFFU

		#define	EURASIA_PDS_DOUTU2_ENDOFRENDER_SHIFT		27
		#define	EURASIA_PDS_DOUTU2_ENDOFRENDER_CLRMSK		0xF7FFFFFFU

		#define	EURASIA_PDS_DOUTU2_PBENABLE					(1UL << 28)
	#else /* SGX520 */
		#define EURASIA_PDS_DOUTU2_TILEX_SHIFT				11
		#define EURASIA_PDS_DOUTU2_TILEX_CLRMSK			0xFFF007FFU

		#define EURASIA_PDS_DOUTU2_TILEY_SHIFT				20
		#define EURASIA_PDS_DOUTU2_TILEY_CLRMSK			0xF00FFFFFU

		#define	EURASIA_PDS_DOUTU2_ENDOFRENDER_SHIFT		28
		#define	EURASIA_PDS_DOUTU2_ENDOFRENDER_CLRMSK		0xEFFFFFFFU

		#define	EURASIA_PDS_DOUTU2_PBENABLE					(1UL << 29)
	#endif /* SGX520 */

/* USE Interface Word 3 */
	#define EURASIA_PDS_DOUTU3_PIXELVALID_SHIFT			0
	#define EURASIA_PDS_DOUTU3_PIXELVALID_CLRMSK		0xFFFF0000U

	#define EURASIA_PDS_DOUTU3_SUBTILEX_SHIFT			16
	#define EURASIA_PDS_DOUTU3_SUBTILEX_CLRMSK			0xFFFEFFFFU

	#define EURASIA_PDS_DOUTU3_SUBTILEY_SHIFT			17
	#define EURASIA_PDS_DOUTU3_SUBTILEY_CLRMSK			0xFFF9FFFFU

	#define EURASIA_PDS_DOUTU3_BACKFACE_SHIFT			19
	#define EURASIA_PDS_DOUTU3_BACKFACE					(1UL << EURASIA_PDS_DOUTU3_BACKFACE_SHIFT)

	#define	EURASIA_PDS_DOUTU3_TRANSLUCENT_SHIFT		20
	#define EURASIA_PDS_DOUTU3_TRANSLUCENT				(1UL << EURASIA_PDS_DOUTU3_TRANSLUCENT_SHIFT)

	#define EURASIA_PDS_DOUTU3_TYPE_SHIFT				21
	#define EURASIA_PDS_DOUTU3_TYPE_CLRMSK				0xFF9FFFFFU

	#define	EURASIA_PDS_DOUTU3_SD_SHIFT					23
	#define	EURASIA_PDS_DOUTU3_SD						(1UL << EURASIA_PDS_DOUTU3_SD_SHIFT)

	#define EURASIA_PDS_DOUTU3_ENDTASK_SHIFT			24
	#define EURASIA_PDS_DOUTU3_ENDTASK					(1UL << EURASIA_PDS_DOUTU3_ENDTASK_SHIFT)

	/*
		Number of dwords of state required by the DOUTU command by a non-loopback task.
	*/
	#define EURASIA_PDS_DOUTU_NONLOOPBACK_STATE_SIZE	(3)

#endif /* SGX_FEATURE_USE_UNLIMITED_PHASES */


#define EURASIA_PDS_DOUTU_PHASE_START_ALIGN				(1UL << EURASIA_PDS_DOUTU0_EXE_ALIGNSHIFT)

/*****************************************************************************
 PDS DOUTS (Surface) Interface
*****************************************************************************/
#if defined(SGX545)
	/* Screen Interface Word 0 */
	#define EURASIA_PDS_DOUTS0_FRAMEWIDTH_SHIFT			0
	#define EURASIA_PDS_DOUTS0_FRAMEWIDTH_CLRMSK		0xFFFFF000U

	#define EURASIA_PDS_DOUTS0_FRAMEHEIGHT_SHIFT		12
	#define EURASIA_PDS_DOUTS0_FRAMEHEIGHT_CLRMSK		0xFF000FFFU

	#define EURASIA_PDS_DOUTS0_FRAMESTRIDE_SHIFT		24
	#define EURASIA_PDS_DOUTS0_FRAMESTRIDE_CLRMSK		0x00FFFFFFU

	/* Screen Interface Word 1 */
	#define EURASIA_PDS_DOUTS1_SBASE_SHIFT		0
	#define EURASIA_PDS_DOUTS1_SBASE_CLRMSK		0x00000000U
#endif

/*****************************************************************************
 PDS DOUTC (Clamped Block Copy) Interface
*****************************************************************************/
#if defined(SGX545)
	/* Copy Interface Word 0 */
	#define EURASIA_PDS_DOUTC0_STARTX_SHIFT			0
	#define EURASIA_PDS_DOUTC0_STARTX_CLRMSK		0xFFFF0000U

	#define EURASIA_PDS_DOUTC0_STARTY_SHIFT			16
	#define EURASIA_PDS_DOUTC0_STARTY_CLRMSK		0x0000FFFFU

	/* Copy Interface Word 1 */
	#define EURASIA_PDS_DOUTC1_BSIZE_SHIFT			0
	#define EURASIA_PDS_DOUTC1_BSIZE_CLRMSK			0xFFFFFFF0U

	#define EURASIA_PDS_DOUTC1_BLINES_SHIFT			4
	#define EURASIA_PDS_DOUTC1_BLINES_CLRMSK		0xFFFFFF0FU

	#define EURASIA_PDS_DOUTC1_A0_SHIFT				8
	#define EURASIA_PDS_DOUTC1_A0_CLRMSK			0xFFF000FFU

	#define EURASIA_PDS_DOUTC1_INSTR_SHIFT			20
	#define EURASIA_PDS_DOUTC1_INSTR_CLRMSK			0xFFC7FFFFU

	#define EURASIA_PDS_DOUTC1_INSTR_NORMAL			(0UL << EURASIA_PDS_DOUTC1_INSTR_SHIFT)
	#define EURASIA_PDS_DOUTC1_INSTR_BYPASS			(1UL << EURASIA_PDS_DOUTC1_INSTR_SHIFT)
	#define EURASIA_PDS_DOUTC1_INSTR_LINEFILL		(2UL << EURASIA_PDS_DOUTC1_INSTR_SHIFT)
#endif

/*****************************************************************************
 PDS DMA Interface
*****************************************************************************/

/* DMA Interface Word 0 */
#define	EURASIA_PDS_DOUTD0_SBASE_CLRMSK				0x00000000U
#define	EURASIA_PDS_DOUTD0_SBASE_SHIFT				0
#define	EURASIA_PDS_DOUTD0_SBASE_MIN				0x00000000
#define	EURASIA_PDS_DOUTD0_SBASE_MAX				0xFFFFFFFF

/* DMA Interface Word 1 */
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EURASIA_PDS_DOUTD1_BSIZE_CLRMSK				0xFFFFFF00U
	#define	EURASIA_PDS_DOUTD1_BSIZE_SHIFT				0

	#define	EURASIA_PDS_DOUTD1_BSIZE_MAX				(256)

	#define EURASIA_PDS_DOUTD1_MAXBURST					(256)
#else
	#define	EURASIA_PDS_DOUTD1_BSIZE_CLRMSK				0xFFFFFFF0U
	#define	EURASIA_PDS_DOUTD1_BSIZE_SHIFT				0

	#define	EURASIA_PDS_DOUTD1_BSIZE_MAX				(16)

	#define EURASIA_PDS_DOUTD1_BLINES_CLRMSK			0xFFFFFF0FU
	#define EURASIA_PDS_DOUTD1_BLINES_SHIFT				4

	#define EURASIA_PDS_DOUTD1_BLINES_MAX				(16)

	#define EURASIA_PDS_DOUTD1_MAXBURST					(256)
#endif

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EURASIA_PDS_DOUTD1_AO_CLRMSK				0xFFF000FFU
	#define	EURASIA_PDS_DOUTD1_AO_SHIFT					8
	#define	EURASIA_PDS_DOUTD1_AO_MIN					0x000
	#define	EURASIA_PDS_DOUTD1_AO_MAX					0xFFF

	#define EURASIA_PDS_DOUTD1_INSTR_CLRMSK				0xFFCFFFFFU
	#define EURASIA_PDS_DOUTD1_INSTR_SHIFT				20
	#define EURASIA_PDS_DOUTD1_INSTR_NORMAL				(0UL << EURASIA_PDS_DOUTD1_INSTR_SHIFT)
	#define EURASIA_PDS_DOUTD1_INSTR_BYPASS				(1UL << EURASIA_PDS_DOUTD1_INSTR_SHIFT)
	#define EURASIA_PDS_DOUTD1_INSTR_LINEFILL			(2UL << EURASIA_PDS_DOUTD1_INSTR_SHIFT)

	#if defined(SGX545)
		#define EURASIA_PDS_DOUTD1_STRIDE_CLRMSK			0x803FFFFFU
		#define EURASIA_PDS_DOUTD1_STRIDE_SHIFT				22

		#define	EURASIA_PDS_DOUTD1_STYPE					(1UL << 31)
	#endif
#else
	#define	EURASIA_PDS_DOUTD1_AO_CLRMSK				0xFFF800FFU
	#define	EURASIA_PDS_DOUTD1_AO_SHIFT					8
	#define	EURASIA_PDS_DOUTD1_AO_MIN					0x000
	#define	EURASIA_PDS_DOUTD1_AO_MAX					0x7FF

	#define EURASIA_PDS_DOUTD1_INSTR_CLRMSK				0xFFE7FFFFU
	#define EURASIA_PDS_DOUTD1_INSTR_SHIFT				19
	#define EURASIA_PDS_DOUTD1_INSTR_NORMAL				(0UL << EURASIA_PDS_DOUTD1_INSTR_SHIFT)
	#define EURASIA_PDS_DOUTD1_INSTR_BYPASS				(1UL << EURASIA_PDS_DOUTD1_INSTR_SHIFT)
	#define EURASIA_PDS_DOUTD1_INSTR_LINEFILL			(2UL << EURASIA_PDS_DOUTD1_INSTR_SHIFT)

	#define EURASIA_PDS_DOUTD1_STRIDE_CLRMSK			0xC01FFFFFU
	#define EURASIA_PDS_DOUTD1_STRIDE_SHIFT				21

	#define	EURASIA_PDS_DOUTD1_STYPE					(1UL << 30)
#endif

/*****************************************************************************
 PDS Output Buffer DMA Interface
*****************************************************************************/

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
/* Output buffer DMA Interface Word 0 */
#define	EURASIA_PDS_DOUTO0_SOFF_CLRMSK				0xFFFFFF80U
#define	EURASIA_PDS_DOUTO0_SOFF_SHIFT				0
#define	EURASIA_PDS_DOUTO0_SOFF_MIN					0x00000000
#define	EURASIA_PDS_DOUTO0_SOFF_MAX					0x0000007F

#define	EURASIA_PDS_DOUTO0_BSIZE_CLRMSK				0xFFFFC07FU
#define	EURASIA_PDS_DOUTO0_BSIZE_SHIFT				7

#define	EURASIA_PDS_DOUTO0_BSIZE_MAX				(128)

#define EURASIA_PDS_DOUTO0_MAXBURST					(128)

#define	EURASIA_PDS_DOUTO0_AO_CLRMSK				0xFFE03FFFU
#define	EURASIA_PDS_DOUTO0_AO_SHIFT					14
#define	EURASIA_PDS_DOUTO0_AO_MIN					0x00
#define	EURASIA_PDS_DOUTO0_AO_MAX					0x7F

#define EURASIA_PDS_DOUTO0_INSTR_CLRMSK				0xFF9FFFFFU
#define EURASIA_PDS_DOUTO0_INSTR_SHIFT				21
#define EURASIA_PDS_DOUTO0_INSTR_NORMAL				(0UL << EURASIA_PDS_DOUTO1_INSTR_SHIFT)
#define EURASIA_PDS_DOUTO0_INSTR_BYPASS				(1UL << EURASIA_PDS_DOUTO1_INSTR_SHIFT)
#define EURASIA_PDS_DOUTO0_INSTR_LINEFILL			(2UL << EURASIA_PDS_DOUTO1_INSTR_SHIFT)
#endif /* #if defined(SGX543) */

/*****************************************************************************
 PDS Texture Interface
*****************************************************************************/

/* Texture Control Block Word 0 */
#if defined(SGX543) || defined(SGX544) || defined(SGX554)

#define EURASIA_PDS_DOUTT0_TEXFEXT					(1UL << 31)

#define	EURASIA_PDS_DOUTT0_CACHECTL_CLRMSK			0x9FFFFFFFU
#define	EURASIA_PDS_DOUTT0_CACHECTL_SHIFT			29
#define	EURASIA_PDS_DOUTT0_CACHECTL_NORMAL			(0UL	<< EURASIA_PDS_DOUTT0_CACHECTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_CACHECTL_BYPASS			(1UL	<< EURASIA_PDS_DOUTT0_CACHECTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_CACHECTL_LINEFILL		(2UL	<< EURASIA_PDS_DOUTT0_CACHECTL_SHIFT)

#define EURASIA_PDS_DOUTT0_GAMMA					(1UL << 27)

#define	EURASIA_PDS_DOUTT0_GAMMA_CLRMSK				0xE7FFFFFFU
#define	EURASIA_PDS_DOUTT0_GAMMA_SHIFT				27
#define	EURASIA_PDS_DOUTT0_GAMMA_NONE				(0UL	<< EURASIA_PDS_DOUTT0_GAMMA_SHIFT)
#define	EURASIA_PDS_DOUTT0_GAMMA_R					(1UL	<< EURASIA_PDS_DOUTT0_GAMMA_SHIFT)
#define	EURASIA_PDS_DOUTT0_GAMMA_GR					(3UL	<< EURASIA_PDS_DOUTT0_GAMMA_SHIFT)

#else /* #if defined(SGX543) || defined(SGX544) || defined(SGX554) */

#if defined(SGX545)
	#define EURASIA_PDS_DOUTT0_LUMAKEY_ENABLE		(1UL << 31)
	#define EURASIA_PDS_DOUTT0_TEXFEXT				(1UL << 30)
#else
	#define EURASIA_PDS_DOUTT0_STRIDE				(1UL << 31)
	#define EURASIA_PDS_DOUTT0_CHANREPLICATE		(1UL << 30)
#endif

#define	EURASIA_PDS_DOUTT0_CACHECTL_CLRMSK			0xCFFFFFFFU
#define	EURASIA_PDS_DOUTT0_CACHECTL_SHIFT			28
#define	EURASIA_PDS_DOUTT0_CACHECTL_NORMAL			(0UL	<< EURASIA_PDS_DOUTT0_CACHECTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_CACHECTL_BYPASS			(1UL	<< EURASIA_PDS_DOUTT0_CACHECTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_CACHECTL_LINEFILL		(2UL	<< EURASIA_PDS_DOUTT0_CACHECTL_SHIFT)

#define EURASIA_PDS_DOUTT0_GAMMA					(1UL << 27)

#endif /* #if defined(SGX543) || defined(SGX544) || defined(SGX554) */

#define EURASIA_PDS_DOUTT0_DADJUST_CLRMSK			0xF81FFFFFU
#define EURASIA_PDS_DOUTT0_DADJUST_SHIFT			21

#if defined(SGX_FEATURE_8BIT_DADJUST)
	#define EURASIA_PDS_DOUTT_DADJUST_MIN				-15.875f
 	#define EURASIA_PDS_DOUTT_DADJUST_MAX				16
 	#define EURASIA_PDS_DOUTT_DADJUST_ZERO_UINT			127
 	#define EURASIA_PDS_DOUTT_DADJUST_MIN_UINT			0
 	#define EURASIA_PDS_DOUTT_DADJUST_MAX_UINT			255
#else
	#define EURASIA_PDS_DOUTT_DADJUST_MIN				-3.875f
	#define EURASIA_PDS_DOUTT_DADJUST_MAX				4
	#define EURASIA_PDS_DOUTT_DADJUST_ZERO_UINT			31
	#define EURASIA_PDS_DOUTT_DADJUST_MIN_UINT			0
 	#define EURASIA_PDS_DOUTT_DADJUST_MAX_UINT			63
#endif

// For compatability with old drivers, remove when ready..
#define EURASIA_PDS_DOUTT0_DADJUST_MIN				-3.875f
#define EURASIA_PDS_DOUTT0_DADJUST_MAX				4
#define EURASIA_PDS_DOUTT3_DADJUST_MIN				-15.875f
#define EURASIA_PDS_DOUTT3_DADJUST_MAX				16

#define	EURASIA_PDS_DOUTT0_MIPMAPCLAMP_CLRMSK		0xFFE1FFFFU
#define	EURASIA_PDS_DOUTT0_MIPMAPCLAMP_SHIFT		17
#define	EURASIA_PDS_DOUTT0_MIPMAPCLAMP_MIN			(0UL	<< EURASIA_PDS_DOUTT0_MIPMAPCLAMP_SHIFT)
#if defined(SGX545)
	// 8192x8192
	#define	EURASIA_PDS_DOUTT0_MIPMAPCLAMP_MAX			(13UL	<< EURASIA_PDS_DOUTT0_MIPMAPCLAMP_SHIFT)
#else
	// 4096x4096
	#define	EURASIA_PDS_DOUTT0_MIPMAPCLAMP_MAX		(12UL	<< EURASIA_PDS_DOUTT0_MIPMAPCLAMP_SHIFT)
#endif
#define	EURASIA_PDS_DOUTT0_NOTMIPMAP				(15UL	<< EURASIA_PDS_DOUTT0_MIPMAPCLAMP_SHIFT)

#define	EURASIA_PDS_DOUTT0_ANISOCTL_CLRMSK			0xFFFE3FFFU
#define	EURASIA_PDS_DOUTT0_ANISOCTL_SHIFT			14
#define	EURASIA_PDS_DOUTT0_ANISOCTL_NONE			(0UL	<< EURASIA_PDS_DOUTT0_ANISOCTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_ANISOCTL_2				(1UL	<< EURASIA_PDS_DOUTT0_ANISOCTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_ANISOCTL_4				(2UL	<< EURASIA_PDS_DOUTT0_ANISOCTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_ANISOCTL_8				(3UL	<< EURASIA_PDS_DOUTT0_ANISOCTL_SHIFT)
#define	EURASIA_PDS_DOUTT0_ANISOCTL_16				(4UL	<< EURASIA_PDS_DOUTT0_ANISOCTL_SHIFT)

#define	EURASIA_PDS_DOUTT0_MAGFILTER_CLRMSK			0xFFFFCFFFU
#define	EURASIA_PDS_DOUTT0_MAGFILTER_SHIFT			12
#define	EURASIA_PDS_DOUTT0_MAGFILTER_POINT			(0UL	<< EURASIA_PDS_DOUTT0_MAGFILTER_SHIFT)
#define	EURASIA_PDS_DOUTT0_MAGFILTER_LINEAR			(1UL	<< EURASIA_PDS_DOUTT0_MAGFILTER_SHIFT)
#define	EURASIA_PDS_DOUTT0_MAGFILTER_ANISO			(2UL	<< EURASIA_PDS_DOUTT0_MAGFILTER_SHIFT)
#define	EURASIA_PDS_DOUTT0_MAGFILTER_ANISOPOINT		(3UL	<< EURASIA_PDS_DOUTT0_MAGFILTER_SHIFT)

#define	EURASIA_PDS_DOUTT0_MINFILTER_CLRMSK			0xFFFFF3FFU
#define	EURASIA_PDS_DOUTT0_MINFILTER_SHIFT			10
#define	EURASIA_PDS_DOUTT0_MINFILTER_POINT			(0UL	<< EURASIA_PDS_DOUTT0_MINFILTER_SHIFT)
#define	EURASIA_PDS_DOUTT0_MINFILTER_LINEAR			(1UL	<< EURASIA_PDS_DOUTT0_MINFILTER_SHIFT)
#define	EURASIA_PDS_DOUTT0_MINFILTER_ANISO			(2UL	<< EURASIA_PDS_DOUTT0_MINFILTER_SHIFT)
#define	EURASIA_PDS_DOUTT0_MINFILTER_ANISOPOINT		(3UL	<< EURASIA_PDS_DOUTT0_MINFILTER_SHIFT)

#define	EURASIA_PDS_DOUTT0_MIPFILTER				(1UL << 9)

#define EURASIA_PDS_DOUTT0_ADDRMODE_REPEAT			0U
#define EURASIA_PDS_DOUTT0_ADDRMODE_FLIP			1U
#define EURASIA_PDS_DOUTT0_ADDRMODE_CLAMP			2U
#define EURASIA_PDS_DOUTT0_ADDRMODE_FLIPCLAMP		3U
#define EURASIA_PDS_DOUTT0_ADDRMODE_REPEATBDRMEM	4U
#define EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDR		5U
#define EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDRMEM		6U
#define EURASIA_PDS_DOUTT0_ADDRMODE_OGLCLAMP		7U

#define	EURASIA_PDS_DOUTT0_UADDRMODE_CLRMSK			0xFFFFFE3FU
#define	EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT			6
#define	EURASIA_PDS_DOUTT0_UADDRMODE_REPEAT			(EURASIA_PDS_DOUTT0_ADDRMODE_REPEAT	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_FLIP			(EURASIA_PDS_DOUTT0_ADDRMODE_FLIP	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_CLAMP			(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMP	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_FLIPCLAMP		(EURASIA_PDS_DOUTT0_ADDRMODE_FLIPCLAMP	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_REPEATBDRMEM	(EURASIA_PDS_DOUTT0_ADDRMODE_REPEATBDRMEM	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_CLAMPBDRMEM	(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDRMEM	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_CLAMPBDR		(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDR	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_UADDRMODE_OGLCLAMP		(EURASIA_PDS_DOUTT0_ADDRMODE_OGLCLAMP	<< EURASIA_PDS_DOUTT0_UADDRMODE_SHIFT)

#define	EURASIA_PDS_DOUTT0_VADDRMODE_CLRMSK			0xFFFFFFC7U
#define	EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT			3
#define	EURASIA_PDS_DOUTT0_VADDRMODE_REPEAT			(EURASIA_PDS_DOUTT0_ADDRMODE_REPEAT	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_FLIP			(EURASIA_PDS_DOUTT0_ADDRMODE_FLIP	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_CLAMP			(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMP	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_FLIPCLAMP		(EURASIA_PDS_DOUTT0_ADDRMODE_FLIPCLAMP	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_REPEATBDRMEM	(EURASIA_PDS_DOUTT0_ADDRMODE_REPEATBDRMEM	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_CLAMPBDRMEM	(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDRMEM	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_CLAMPBDR		(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDR	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_VADDRMODE_OGLCLAMP		(EURASIA_PDS_DOUTT0_ADDRMODE_OGLCLAMP	<< EURASIA_PDS_DOUTT0_VADDRMODE_SHIFT)

#if defined(SGX_FEATURE_VOLUME_TEXTURES)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_CLRMSK			0xFFFFFFF8U
#define	EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT			0
#define	EURASIA_PDS_DOUTT0_SADDRMODE_REPEAT			(EURASIA_PDS_DOUTT0_ADDRMODE_REPEAT	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_FLIP			(EURASIA_PDS_DOUTT0_ADDRMODE_FLIP	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_CLAMP			(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMP	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_FLIPCLAMP		(EURASIA_PDS_DOUTT0_ADDRMODE_FLIPCLAMP	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_REPEATBDRMEM	(EURASIA_PDS_DOUTT0_ADDRMODE_REPEATBDRMEM	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_CLAMPBDRMEM	(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDRMEM	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_CLAMPBDR		(EURASIA_PDS_DOUTT0_ADDRMODE_CLAMPBDR	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#define	EURASIA_PDS_DOUTT0_SADDRMODE_OGLCLAMP		(EURASIA_PDS_DOUTT0_ADDRMODE_OGLCLAMP	<< EURASIA_PDS_DOUTT0_SADDRMODE_SHIFT)
#endif /* #if defined(SGX535) || defined(SGX545) */

/*
	When EURASIA_PDS_DOUTT0_STRIDE is present...
*/

#if defined(SGX545)
	// 10 bits from EURASIA_PDS_DOUTT0_MIPMAPCLAMP and EURASIA_PDS_DOUTT0_DADJUST
	#define	EURASIA_PDS_DOUTT0_STRIDEHI_CLRMSK		0xF801FFFFU
	#define	EURASIA_PDS_DOUTT0_STRIDEHI_SHIFT		17
	#define	EURASIA_PDS_DOUTT0_STRIDEHI_STRIDE_SHIFT	3

	// 3 bits from EURASIA_PDS_DOUTT0_MINFILTER and EURASIA_PDS_DOUTT0_MIPFILTER
	#define	EURASIA_PDS_DOUTT0_STRIDELO_CLRMSK		0xFFFFF1FFU
	#define	EURASIA_PDS_DOUTT0_STRIDELO_SHIFT		9
	#define	EURASIA_PDS_DOUTT0_STRIDELO_STRIDE_SHIFT	0

	#define	EURASIA_PDS_DOUTT0_STRIDE_ALIGNSHIFT	2
#else /* #if defined(SGX545) */
	#if defined(SGX543) || defined(SGX544) || defined(SGX554)

		/* 10 bits from EURASIA_PDS_DOUTT0_MIPMAPCLAMP/DADJUST */
		#define	EURASIA_PDS_DOUTT0_STRIDEHI_CLRMSK				0xF801FFFFU
		#define	EURASIA_PDS_DOUTT0_STRIDEHI_SHIFT				17
		#define	EURASIA_PDS_DOUTT0_STRIDEHI_STRIDE_SHIFT		3

		/* 3 bits from EURASIA_PDS_DOUTT0_MINFILTER/MIPFILTER */
		#define	EURASIA_PDS_DOUTT0_STRIDELO_CLRMSK				0xFFFFF1FFU
		#define	EURASIA_PDS_DOUTT0_STRIDELO_SHIFT				9
		#define EURASIA_PDS_DOUTT0_STRIDELO_STRIDE_SHIFT		0

		/* 2 bits at the bottom */
		#define	EURASIA_PDS_DOUTT0_STRIDEEX_CLRMSK				0xFFFFFFF9U
		#define	EURASIA_PDS_DOUTT0_STRIDEEX_SHIFT				1
		#define EURASIA_PDS_DOUTT0_STRIDEEX_STRIDE_SHIFT		13

		#define	EURASIA_PDS_DOUTT0_STRIDE_ALIGNSHIFT	2

	#else /* #if defined(SGX543) || defined(SGX544) || defined(SGX554) */

		#if (defined(SGX520) || defined(SGX530)) && ! defined(SGX_FEATURE_TEXTURE_32K_STRIDE)
 			/* top 2 bits from EURASIA_PDS_DOUTT0_MIPMAPCLAMP */
			#define	EURASIA_PDS_DOUTT0_STRIDEHI_CLRMSK		0xFFF3FFFFU
			#define	EURASIA_PDS_DOUTT0_STRIDEHI_SHIFT		18
			#define	EURASIA_PDS_DOUTT0_STRIDEHI_STRIDE_SHIFT		9
		#else
 			/* top 3 bits from EURASIA_PDS_DOUTT0_MIPMAPCLAMP */
			#define	EURASIA_PDS_DOUTT0_STRIDEHI_CLRMSK		0xFFE3FFFFU
			#define	EURASIA_PDS_DOUTT0_STRIDEHI_SHIFT		18
			#define	EURASIA_PDS_DOUTT0_STRIDEHI_STRIDE_SHIFT		9
		#endif

	#if defined(SGX_FEATURE_VOLUME_TEXTURES)
		// 9 bits from EURASIA_PDS_DOUTT0_UADDRMODE, EURASIA_PDS_DOUTT0_VADDRMODE and EURASIA_PDS_DOUTT0_SADDRMODE
		#define	EURASIA_PDS_DOUTT0_STRIDELO_CLRMSK		0xFFFFFE00U
		#define	EURASIA_PDS_DOUTT0_STRIDELO_SHIFT		0
		#define	EURASIA_PDS_DOUTT0_STRIDELO_STRIDE_SHIFT	0
	#else
		#if defined(SGX_FEATURE_TEXTURE_32K_STRIDE)
			// An extra 3 bits for 32kb stride texture support..
			#define	EURASIA_PDS_DOUTT1_STRIDEEX1_CLRMSK		0xFF7FFFFFU
			#define	EURASIA_PDS_DOUTT1_STRIDEEX1_SHIFT		23
			#define EURASIA_PDS_DOUTT1_STRIDEEX1_STRIDE_SHIFT	14

			#define	EURASIA_PDS_DOUTT0_STRIDEEX0_CLRMSK		0xFFFFFFF9U
			#define	EURASIA_PDS_DOUTT0_STRIDEEX0_SHIFT		1
			#define EURASIA_PDS_DOUTT0_STRIDEEX0_STRIDE_SHIFT	12
		#endif

		// 6 bits from EURASIA_PDS_DOUTT0_UADDRMODE and EURASIA_PDS_DOUTT0_VADDRMODE
		#define	EURASIA_PDS_DOUTT0_STRIDELO2_CLRMSK		0xFFFFFE07U
		#define	EURASIA_PDS_DOUTT0_STRIDELO2_SHIFT		3
		#define EURASIA_PDS_DOUTT0_STRIDELO2_STRIDE_SHIFT	3

		// 3 bits from EURASIA_PDS_DOUTT1_TEXTYPE
		#define	EURASIA_PDS_DOUTT1_STRIDELO1_CLRMSK		0x1FFFFFFFU
		#define	EURASIA_PDS_DOUTT1_STRIDELO1_SHIFT		29
		#define EURASIA_PDS_DOUTT1_STRIDELO1_STRIDE_SHIFT	0
	#endif

	#define	EURASIA_PDS_DOUTT0_STRIDE_ALIGNSHIFT	2
	#endif /* #if defined(SGX543) || defined(SGX544) || defined(SGX554) */
#endif /* #if defined(SGX545) */

#define EURASIA_PDS_DOUTT0_STRIDE_ALIGNSIZE			(1UL << EURASIA_PDS_DOUTT0_STRIDE_ALIGNSHIFT)


/* Texture Control Block Word 1 */
#define	EURASIA_PDS_DOUTT1_TEXTYPE_CLRMSK			0x1FFFFFFFU
#define	EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT			29
#if defined(SGX_FEATURE_TAG_NPOT_TWIDDLE)
	/*
		Under 543 we have additional defines for arb 2D and CEM textures. For all
		other chips with SGX_FEATURE_TAG_NPOT_TWIDDLE the normal 2D and CEM modes
		are overriden.
	*/
	#if defined(SGX_FEATURE_TAG_POT_TWIDDLE) && defined(SGX_FEATURE_TAG_NPOT_TWIDDLE)
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_2D				(0UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_CEM				(2UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
		
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_ARB_2D			(5UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_ARB_CEM			(7UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
	#else /* defined(SGX_FEATURE_TAG_POT_TWIDDLE) && defined(SGX_FEATURE_TAG_NPOT_TWIDDLE) */
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_ARB_2D			(0UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
		#if defined(SGX_FEATURE_VOLUME_TEXTURES)
			#define	EURASIA_PDS_DOUTT1_TEXTYPE_ARB_3D		(1UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
		#endif
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_ARB_CEM			(2UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
	#endif /* defined(SGX_FEATURE_TAG_POT_TWIDDLE) && defined(SGX_FEATURE_TAG_NPOT_TWIDDLE) */
#else /* defined(SGX_FEATURE_TAG_NPOT_TWIDDLE) */
	#define	EURASIA_PDS_DOUTT1_TEXTYPE_2D				(0UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
	#if defined(SGX_FEATURE_VOLUME_TEXTURES)
		#define	EURASIA_PDS_DOUTT1_TEXTYPE_3D			(1UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
	#endif
	#define	EURASIA_PDS_DOUTT1_TEXTYPE_CEM				(2UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
#endif /* defined(SGX_FEATURE_TAG_NPOT_TWIDDLE) */

#define	EURASIA_PDS_DOUTT1_TEXTYPE_STRIDE			(3UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXTYPE_TILED			(4UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
#if defined(SGX545)
	#define	EURASIA_PDS_DOUTT1_TEXTYPE_CONVOLUTIONFILTER		(5UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
#endif
#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EURASIA_PDS_DOUTT1_TEXTYPE_NP2_STRIDE_EXT			(6UL	<< EURASIA_PDS_DOUTT1_TEXTYPE_SHIFT)
#endif

#define	EURASIA_PDS_DOUTT1_TEXFORMAT_CLRMSK			0xE0FFFFFFU
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT			24
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U8				(0UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S8				(1UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_A4R4G4B4		(2UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_A8R3G3B2		(3UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_A1R5G5B5		(4UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_R5G6B5			(5UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_R5SG5SB6		(6UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U88			(7UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S88			(8UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U16			(9UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S16			(10UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F16			(11UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U8888			(12UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S8888			(13UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#else
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_B8G8R8A8		(12UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_R8G8B8A8		(13UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#endif
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_A2R10G10B10	(14UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U1616			(15UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S1616			(16UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F1616			(17UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F32			(18UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#if defined(SGX543) || defined(SGX544) || defined(SGX554) || (defined(SGX545) && !defined(FIX_HW_BRN_27743))
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F32SIGNMASK	(19UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#else
#define	EURASIA_PDS_DOUTT1_TEXFORMAT_O8				(19UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#endif

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_X8U8S8S8		(20UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#else
	#if defined(FIX_HW_BRN_27903)
		#define EURASIA_PDS_DOUTT1_TEXFORMAT_RESERVED2		(20UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#else
		#define EURASIA_PDS_DOUTT1_TEXFORMAT_YUYV_NOCONV	(20UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#endif
#endif
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_X8U24			(21UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_U8U24			(22UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#endif

#if defined(SGX543) || defined(SGX544) || defined(SGX554)

	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U32			(23UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S32			(24UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_SE9995			(25UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F11F11F10		(26UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F16F16F16F16	(27UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U16U16U16U16	(28UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S16S16S16S16	(29UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F32F32			(30UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U32U32			(31UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)

#else

	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRT2BPP		(23UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRT4BPP		(24UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRTII2BPP		(25UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRTII4BPP		(26UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRTIII		(27UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)

#if defined (SGX545)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_C0_YUYV		(28UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_C0_UYVY		(29UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_X8U8S8S8		(30UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_S8888			(31UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#else
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_YUY2			(28UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_UYVY			(29UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_O88			(30UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_RESERVED2		(31UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#endif

#endif


#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	/* If EURASIA_PDS_DOUTT0_TEXFEXT is set then the following values apply */
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRT2BPP			(0UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRT4BPP			(1UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRTII2BPP			(2UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRTII4BPP			(3UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_PVRTIII			(4UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)

	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_YUV420_2P			(16UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_YUV420_3P			(17UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_YUV422				(18UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)

#if defined(SGX_FEATURE_4K_PLANAR_YUV)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_4KYUV420_2P		(19UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#endif

	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U888				(24UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S888				(25UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_2F10F10F10			(26UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)


#endif

#if defined (SGX545)
	/* If EURASIA_PDS_DOUTT0_TEXFEXT is set then the following values apply */
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U1					(0UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_U32				(1UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_S32				(2UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_SE9995				(3UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_F11F11F10			(4UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#if defined(FIX_HW_BRN_27903)
		#define	EURASIA_PDS_DOUTT1_TEXFORMAT_RESERVED3			(5UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#else
		#define	EURASIA_PDS_DOUTT1_TEXFORMAT_UYVY_NOCONV		(5UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#endif
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_C0_YVYU			(6UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define EURASIA_PDS_DOUTT1_TEXFORMAT_C0_VYUY			(7UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C0_YUV420_2P_UV	(15UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C0_YUV420_2P_VU	(16UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C0_YUV420_3P		(17UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_YUYV			(18UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_UYVY			(19UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_YUV420_2P_UV	(20UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_YUV420_2P_VU	(21UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_YUV420_3P		(22UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_YVYU			(23UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_C1_VYUY			(24UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_A8					(25UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_L8					(26UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_L8A8				(27UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_A_F16				(28UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_L_F16				(29UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_L_F16_REP			(30UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
	#define	EURASIA_PDS_DOUTT1_TEXFORMAT_L_F16_A_F16		(31UL	<< EURASIA_PDS_DOUTT1_TEXFORMAT_SHIFT)
#endif

#if defined(SGX_FEATURE_TAG_POT_TWIDDLE) 
	#define	EURASIA_PDS_DOUTT1_USIZE_CLRMSK				0xFFF0FFFFU
	#define	EURASIA_PDS_DOUTT1_USIZE_SHIFT				16
	#define	EURASIA_PDS_DOUTT1_USIZE1					(0UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE2					(1UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE4					(2UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE8					(3UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE16					(4UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE32					(5UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE64					(6UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE128					(7UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE256					(8UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE512					(9UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE1024				(10UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE2048				(11UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_USIZE4096				(12UL	<< EURASIA_PDS_DOUTT1_USIZE_SHIFT)

#if defined(SGX_FEATURE_VOLUME_TEXTURES) && !defined(SGX_FEATURE_TAG_NPOT_TWIDDLE)
	#define	EURASIA_PDS_DOUTT1_SSIZE_CLRMSK				0xFFFF0FFFU
	#define	EURASIA_PDS_DOUTT1_SSIZE_SHIFT				12
	#define	EURASIA_PDS_DOUTT1_SSIZE1					(0UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE2					(1UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE4					(2UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE8					(3UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE16					(4UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE32					(5UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE64					(6UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE128					(7UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE256					(8UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE512					(9UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE1024				(10UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE2048				(11UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_SSIZE4096				(12UL	<< EURASIA_PDS_DOUTT1_SSIZE_SHIFT)
#endif

	#define	EURASIA_PDS_DOUTT1_VSIZE_CLRMSK				0xFFFFFFF0U
	#define	EURASIA_PDS_DOUTT1_VSIZE_SHIFT				0
	#define	EURASIA_PDS_DOUTT1_VSIZE1					(0UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE2					(1UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE4					(2UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE8					(3UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE16					(4UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE32					(5UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE64					(6UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE128					(7UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE256					(8UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE512					(9UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE1024				(10UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE2048				(11UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)
	#define	EURASIA_PDS_DOUTT1_VSIZE4096				(12UL	<< EURASIA_PDS_DOUTT1_VSIZE_SHIFT)

	#define	EURASIA_PDS_DOUTT_TEXSIZE1					0U
	#define	EURASIA_PDS_DOUTT_TEXSIZE2					1U
	#define	EURASIA_PDS_DOUTT_TEXSIZE4					2U
	#define	EURASIA_PDS_DOUTT_TEXSIZE8					3U
	#define	EURASIA_PDS_DOUTT_TEXSIZE16					4U
	#define	EURASIA_PDS_DOUTT_TEXSIZE32					5U
	#define	EURASIA_PDS_DOUTT_TEXSIZE64					6U
	#define	EURASIA_PDS_DOUTT_TEXSIZE128				7U
	#define	EURASIA_PDS_DOUTT_TEXSIZE256				8U
	#define	EURASIA_PDS_DOUTT_TEXSIZE512				9U
	#define	EURASIA_PDS_DOUTT_TEXSIZE1024				10U
	#define	EURASIA_PDS_DOUTT_TEXSIZE2048				11U
	#define	EURASIA_PDS_DOUTT_TEXSIZE4096				12U
#endif

#if defined(SGX_FEATURE_TEXTURE_32K_STRIDE)

#if(EURASIA_TEXTURESIZE_MAX == 4096)
	#define	EURASIA_PDS_DOUTT1_WIDTH_CLRMSK				0xFF000FFFU
	#define	EURASIA_PDS_DOUTT1_HEIGHT_CLRMSK			0xFFFFF000U
#else
	#define	EURASIA_PDS_DOUTT1_WIDTH_CLRMSK				0xFF800FFFU
	#define	EURASIA_PDS_DOUTT1_HEIGHT_CLRMSK			0xFFFFF800U
#endif
#define	EURASIA_PDS_DOUTT1_WIDTH_SHIFT				12
#define	EURASIA_PDS_DOUTT1_HEIGHT_SHIFT				0

#else /* #if defined(SGX_FEATURE_TEXTURE_32K_STRIDE) */

#define	EURASIA_PDS_DOUTT1_WIDTH_CLRMSK				0xFF000FFFU
#define	EURASIA_PDS_DOUTT1_WIDTH_SHIFT				12

#define	EURASIA_PDS_DOUTT1_HEIGHT_CLRMSK			0xFFFFF000U
#define	EURASIA_PDS_DOUTT1_HEIGHT_SHIFT				0

#endif /* #if defined(SGX_FEATURE_TEXTURE_32K_STRIDE) */

#if defined(SGX_FEATURE_BUFFER_LOAD)
#define EURASIA_PDS_DOUTT1_BUFFER_SIZE_31_8_CLRMSK	(0xFF000000U)
#define EURASIA_PDS_DOUTT1_BUFFER_SIZE_31_8_SHIFT	(0)
#endif

/* Texture Control Block Word 2 */
#define	EURASIA_PDS_DOUTT2_TEXADDR_CLRMSK			0x00000003U
#define	EURASIA_PDS_DOUTT2_TEXADDR_SHIFT			2
#define	EURASIA_PDS_DOUTT2_TEXADDR_ALIGNSHIFT		2

#if defined(SGX_FEATURE_TAG_MINLOD)
#define EURASIA_PDS_DOUTT2_LODMINHI_CLRMSK			0xFFFFFFFCU
#define EURASIA_PDS_DOUTT2_LODMINHI_SHIFT			0
#define EURASIA_PDS_DOUTT2_LODMINHI_LODMIN_SHIFT	2
#endif

/* Index of the texture control block word which contains the texture base address. */
#define EURASIA_PDS_DOUTT_TEXADDR_WORD_INDEX		2
/* Index of the texture control block word which contains the texture extended data. */
#define EURASIA_PDS_DOUTT_EXTDDATA_WORD_INDEX		3

/* Texture Control Block Word 3 */
#if defined(SGX_FEATURE_TAG_SWIZZLE)
	#define EURASIA_PDS_DOUTT3_FCNORM					(1UL << 31)

	#define	EURASIA_PDS_DOUTT3_SWIZ_CLRMASK				0x8FFFFFFFU
	#define	EURASIA_PDS_DOUTT3_SWIZ_SHIFT				28

	/* For 4 channel ARGB formats, order stored in Memory: High to Low */
	#define	EURASIA_PDS_DOUTT3_SWIZ_ABGR				(0UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_ARGB				(1UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_RGBA				(2UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_BGRA				(3UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_1BGR				(4UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_1RGB				(5UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_RGB1				(6UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_BGR1				(7UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)

	/* For 3 channel formats, order stored in Memory: High to Low */
	#define	EURASIA_PDS_DOUTT3_SWIZ_BGR					(0UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_RGB					(1UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)

	/* For 2 channel formats: order as stored in USSE register */
	#define	EURASIA_PDS_DOUTT3_SWIZ_GR					(0UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_00GR				(1UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_GRRR				(2UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_RGGG				(3UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_GRGR				(4UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_RG					(5UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)

	/* For 1 channel formats: order as stored in USSE register */
	#define	EURASIA_PDS_DOUTT3_SWIZ_R					(0UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_000R				(1UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_111R				(2UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_RRRR				(3UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_0RRR				(4UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_1RRR				(5UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_R000				(6UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_R111				(7UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)

	/* For YUV422 format: order stored in Memory: High to Low */
	#define	EURASIA_PDS_DOUTT3_SWIZ_YUYV_CSC0			(0UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_YVYU_CSC0			(1UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_UYVY_CSC0			(2UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_VYUY_CSC0			(3UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_YUYV_CSC1			(4UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_YVYU_CSC1			(5UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_UYVY_CSC1			(6UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_VYUY_CSC1			(7UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)

	/* For YUV planar formats: order stored in Memory: High to Low */
	#define	EURASIA_PDS_DOUTT3_SWIZ_YUV_CSC0			(0UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_YVU_CSC0			(1UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_YUV_CSC1			(2UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)
	#define	EURASIA_PDS_DOUTT3_SWIZ_YVU_CSC1			(3UL << EURASIA_PDS_DOUTT3_SWIZ_SHIFT)

 	#define EURASIA_PDS_DOUTT3_LODMINLO_CLRMSK			0xF3FFFFFFU
 	#define EURASIA_PDS_DOUTT3_LODMINLO_SHIFT			26
  	#define EURASIA_PDS_DOUTT3_LODMINLO_LODMIN_SHIFT	0


#if defined(SGX_FEATURE_TAG_LUMAKEY)
	#define EURASIA_PDS_DOUTT3_LUMAKEY_ALPHA_MULTIPLY	(1UL << 26)
	#define EURASIA_PDS_DOUTT3_LUMAKEY_ENABLE			(1UL << 12)
#endif /* SGX_FEATURE_TAG_LUMAKEY */

#if defined(SGX_FEATURE_VOLUME_TEXTURES)
	#define	EURASIA_PDS_DOUTT3_DEPTH_CLRMSK				0xFC007FFFU
	#define	EURASIA_PDS_DOUTT3_DEPTH_SHIFT				15
#endif

#if defined(SGX_FEATURE_8BIT_DADJUST)
 	#define EURASIA_PDS_DOUTT3_DADJUST_CLRMSK			0xFFFF9FFFU
 	#define EURASIA_PDS_DOUTT3_DADJUST_SHIFT			13
 	#define EURASIA_PDS_DOUTT3_DADJUST_ALIGNSHIFT		6
 	#define EURASIA_PDS_DOUTT3_DADJUST_ALLMASK			0x000000FFU
#endif

#if defined(SGX_FEATURE_TAG_FRACTIONAL_LODCLAMP)

	#define EURASIA_PDS_DOUTT3_MIPMAPCLAMP_FRACT_CLRMSK	0xFFFFF0FFU
 	#define EURASIA_PDS_DOUTT3_MIPMAPCLAMP_FRACT_SHIFT	8

	#define EURASIA_PDS_DOUTT3_LODMIN_FRACT_CLRMSK		0xFFFFFF0FU
 	#define EURASIA_PDS_DOUTT3_LODMIN_FRACT_SHIFT		4

#endif

#endif /* SGX_FEATURE_TAG_SWIZZLE */

#if defined(SGX545)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_CLRMSK			0x1FFFFFFFU
	#define	EURASIA_PDS_DOUTT3_CMPMODE_SHIFT			29

	#define	EURASIA_PDS_DOUTT3_CMPMODE_NEVER			(0UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_LESS				(1UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_EQUAL			(2UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_LESSEQUAL		(3UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_GREATER			(4UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_GREATEREQUAL		(5UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_NOTEQUAL			(6UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)
	#define	EURASIA_PDS_DOUTT3_CMPMODE_ALWAYS			(7UL << EURASIA_PDS_DOUTT3_CMPMODE_SHIFT)

#if defined(SGX_FEATURE_TAG_MINLOD)
 	#define EURASIA_PDS_DOUTT3_LODMINLO_CLRMSK			0xE7FFFFFFU
 	#define EURASIA_PDS_DOUTT3_LODMINLO_SHIFT			27
 	#define EURASIA_PDS_DOUTT3_LODMINLO_LODMIN_SHIFT	0
#endif

	// When EURASIA_PDS_DOUTT0_LUMAKEY_ENABLE is set..
	#define EURASIA_PDS_DOUTT3_LUMAKEY_ALPHA_MULTIPLY	(1UL << 27)

	#define EURASIA_PDS_DOUTT3_TAGDATASIZE_SHIFT		23
	#define EURASIA_PDS_DOUTT3_TAGDATASIZE_CLRMSK		0xF87FFFFFU

	#define EURASIA_PDS_DOUTT3_SCALE					(1UL << 22)
#endif /* #if defined(SGX545) */
#if defined(SGX545) || defined (SUPPORT_SGX545)
	#define EURASIA_PDS_DOUTT3_SMPIDX_CLRMSK			0xFFCFFFFFU
	#define EURASIA_PDS_DOUTT3_SMPIDX_SHIFT				20
#endif /* #if defined(SGX545) || defined (SUPPORT_SGX545) */

#if defined(SGX545)
	#define EURASIA_PDS_DOUTT3_SMPCNT_CLRMSK			0xFFF3FFFFU
	#define EURASIA_PDS_DOUTT3_SMPCNT_SHIFT				18
	#define EURASIA_PDS_DOUTT3_SMPCNT_0					(0UL << EURASIA_PDS_DOUTT3_SMPCNT_SHIFT)
	#define EURASIA_PDS_DOUTT3_SMPCNT_2					(1UL << EURASIA_PDS_DOUTT3_SMPCNT_SHIFT)
	#define EURASIA_PDS_DOUTT3_SMPCNT_4					(2UL << EURASIA_PDS_DOUTT3_SMPCNT_SHIFT)
	#define EURASIA_PDS_DOUTT3_SMPCNT_RESERVED			(3UL << EURASIA_PDS_DOUTT3_SMPCNT_SHIFT)

	#define EURASIA_PDS_DOUTT3_FCONV_CLRMSK				0xFFFCFFFFU
	#define EURASIA_PDS_DOUTT3_FCONV_SHIFT				16

	#define EURASIA_PDS_DOUTT3_FCONV_NONE				(0UL << EURASIA_PDS_DOUTT3_FCONV_SHIFT)
	#define EURASIA_PDS_DOUTT3_FCONV_C10				(1UL << EURASIA_PDS_DOUTT3_FCONV_SHIFT)
	#define EURASIA_PDS_DOUTT3_FCONV_F16				(2UL << EURASIA_PDS_DOUTT3_FCONV_SHIFT)
	#define EURASIA_PDS_DOUTT3_FCONV_F32				(3UL << EURASIA_PDS_DOUTT3_FCONV_SHIFT)

	#define EURASIA_PDS_DOUTT3_FCNORM					(1UL << 15)

	#define EURASIA_PDS_DOUTT3_WIDTHEXT_CLRMSK			0xFFFFBFFFU
	#define EURASIA_PDS_DOUTT3_WIDTHEXT_SHIFT			14

	#define EURASIA_PDS_DOUTT3_HEIGHTEXT_CLRMSK			0xFFFFDFFFU
	#define EURASIA_PDS_DOUTT3_HEIGHTEXT_SHIFT			13

	#define EURASIA_PDS_DOUTT3_WIDTH_INTERNALSHIFT		12
	#define EURASIA_PDS_DOUTT3_HEIGHT_INTERNALSHIFT		12

#if defined(SGX_FEATURE_8BIT_DADJUST)
 	#define EURASIA_PDS_DOUTT3_DADJUST_CLRMSK			0xFFFFE7FFU
 	#define EURASIA_PDS_DOUTT3_DADJUST_SHIFT			11
 	#define EURASIA_PDS_DOUTT3_DADJUST_ALIGNSHIFT		6
 	#define EURASIA_PDS_DOUTT3_DADJUST_ALLMASK			0x000000FFU
#endif

#if defined(SGX_FEATURE_BUFFER_LOAD)
	#define EURASIA_PDS_DOUTT3_BUFFER_SIZE_7_0_CLRMSK	(0xFFFF807FU)
	#define EURASIA_PDS_DOUTT3_BUFFER_SIZE_7_0_SHIFT	(7)

	#define EURASIA_PDS_DOUTT1_BUFFER_INDEX_LOOKUP		(1UL << 10)
#endif

	// When EURASIA_PDS_DOUTT1_TEXTYPE_CONVOLUTIONFILTER...

	#define	EURASIA_PDS_DOUTT3_CFYSIZE_CLRMSK			0xFFFFFF8FU
	#define	EURASIA_PDS_DOUTT3_CFYSIZE_SHIFT			4

	#define	EURASIA_PDS_DOUTT3_CFXSIZE_CLRMSK			0xFFFFFFF8U
	#define	EURASIA_PDS_DOUTT3_CFXSIZE_SHIFT			0

	// When EURASIA_PDS_DOUTT1_TEXTYPE_3D...

	#define	EURASIA_PDS_DOUTT3_DEPTH_CLRMSK				0xFFFFF800U
	#define	EURASIA_PDS_DOUTT3_DEPTH_SHIFT				0
#endif /* #if defined(SGX545) */

#if defined(SGX545) || defined(SUPPORT_SGX545)
	// When != EURASIA_PDS_DOUTT1_TEXTYPE_CONVOLUTIONFILTER and != EURASIA_PDS_DOUTT1_TEXTYPE_3D

	#define	EURASIA_PDS_DOUTT3_UOFFSET_CLRMSK			0xFFFFFF0FU
	#define	EURASIA_PDS_DOUTT3_UOFFSET_SHIFT			4

	#define	EURASIA_PDS_DOUTT3_VOFFSET_CLRMSK			0xFFFFFFF0U
	#define	EURASIA_PDS_DOUTT3_VOFFSET_SHIFT			0

#endif /* #if defined(SGX545) || defined(SUPPORT_SGX545) */

/* Defines for the size of a tile in a tiled format texture. */
#define EURASIA_TAG_TILE_SIZEX						32U
#define EURASIA_TAG_TILE_SHIFTX						5
#define EURASIA_TAG_TILE_SIZEY						32U
#define EURASIA_TAG_TILE_SHIFTY						5

/* Defines for the texture stride granularity */
#if defined(SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8)
	#define EURASIA_TAG_STRIDE_ALIGN0					8U
	#define EURASIA_TAG_STRIDE_ALIGNSHIFT0				3U
	#define EURASIA_TAG_STRIDE_ALIGN1					8U
	#define EURASIA_TAG_STRIDE_ALIGNSHIFT1				3U
	#define EURASIA_TAG_STRIDE_THRESHOLD				0U
#else
	#if defined(SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_8_THEN_32)
		#define EURASIA_TAG_STRIDE_ALIGN0					8U
		#define EURASIA_TAG_STRIDE_ALIGNSHIFT0				3U
		#define EURASIA_TAG_STRIDE_ALIGN1					32U
		#define EURASIA_TAG_STRIDE_ALIGNSHIFT1				5U
		#define EURASIA_TAG_STRIDE_THRESHOLD				512U
	#else
		#if defined(SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_16_THEN_32)
			#define EURASIA_TAG_STRIDE_ALIGN0					16U
			#define EURASIA_TAG_STRIDE_ALIGNSHIFT0				4U
			#define EURASIA_TAG_STRIDE_ALIGN1					32U
			#define EURASIA_TAG_STRIDE_ALIGNSHIFT1				5U
			#define EURASIA_TAG_STRIDE_THRESHOLD				1024U
		#else
			#if defined(SGX_FEATURE_TEXTURE_STRIDE_GRANULARITY_32)
				#define EURASIA_TAG_STRIDE_ALIGN0					32U
				#define EURASIA_TAG_STRIDE_ALIGNSHIFT0				5U
				#define EURASIA_TAG_STRIDE_ALIGN1					32U
				#define EURASIA_TAG_STRIDE_ALIGNSHIFT1				5U
				#define EURASIA_TAG_STRIDE_THRESHOLD				0U
			#endif
		#endif
	#endif
#endif

/* Defines for the size of texture state. */
#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554) \
	|| defined(SUPPORT_SGX545) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX554)
#define EURASIA_TAG_TEXTURE_STATE_SIZE				4
#else /* defined(SGX545) */
#define EURASIA_TAG_TEXTURE_STATE_SIZE				3
#endif /* defined(SGX545) */

#define EURASIA_TAG_MAX_TEXTURE_CHUNKS	(8) // 32 * 8 = 256bits


/* Defines for border textures */
#if !defined(SGX545)
/* Offset to the end of the corner data in texels */
#define EURASIA_TAG_BORDERMAP_CORNERS_OFFSET		(52UL)

/* Offset to first map face, in texels */
#define EURASIA_TAG_BORDERMAP_OFFSET_1x1			(56UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_2x2			(64UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_4x4			(80UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_8x8			(112UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_16x16			(176UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_32x32			(304UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_64x64			(560UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_128x128		(1072UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_256x256		(2096UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_512x512		(4144UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_1024x1024		(8240UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_2048x2048		(16432UL)

#else /* !defined(SGX545) */

/* Offset to the end of the corner data in texels */
#define EURASIA_TAG_BORDERMAP_CORNERS_OFFSET		(56UL)

/* Offset to first map face, in texels */
#define EURASIA_TAG_BORDERMAP_OFFSET_1x1			(60UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_2x2			(68UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_4x4			(84UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_8x8			(116UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_16x16			(180UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_32x32			(308UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_64x64			(564UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_128x128		(1076UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_256x256		(2100UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_512x512		(4148UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_1024x1024		(8244UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_2048x2048		(16436UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_4096x4096		(32820UL)
#define EURASIA_TAG_BORDERMAP_OFFSET_8192x8192		(65588UL)

#endif /* defined(SGX545) */

/* Alignment between cubemap faces in bytes */
#define EURASIA_TAG_CUBEMAP_FACE_ALIGN				2048U

/* Top map size at which alignment between faces is no longer necessary */
#define EURASIA_TAG_CUBEMAP_NO_ALIGN_SIZE_8BPP		16			/* PVRTC/8bpp */
#define EURASIA_TAG_CUBEMAP_NO_ALIGN_SIZE_16_32BPP	8			/* 16bpp/32bpp/yuv */

#if defined(SGX_FEATURE_HYBRID_TWIDDLING)
/* Defines for non-power-of-two twiddling. */
#define EURASIA_PBE_NP2TWID_MINTILEDIM				16
#define EURASIA_PBE_NP2TWID_MINTILEDIM_LOG2			4
#define EURASIA_PBE_NP2TWID_MAXTILEDIM				16
#define EURASIA_PBE_NP2TWID_MAXTILEDIM_LOG2			4

#define EURASIA_TAG_NP2TWID_MINTILEDIM				1
#define EURASIA_TAG_NP2TWID_MINTILEDIM_LOG2			0
#define EURASIA_TAG_NP2TWID_MAXTILEDIM				16
#define EURASIA_TAG_NP2TWID_MAXTILEDIM_LOG2			4
#endif /* defined(SGX545) */

/*****************************************************************************
 USE Instruction Set
*****************************************************************************/

/* USE instruction size in bytes. */
#define EURASIA_USE_INSTRUCTION_SIZE				(8U)

/* USE maximum repeat. */
#define EURASIA_USE_MAXIMUM_REPEAT					(16U)

/* Opcode field - common to all instructions. */
#define EURASIA_USE1_OP_SHIFT						(27)
#define EURASIA_USE1_OP_CLRMSK						(0x07FFFFFFU)

#define EURASIA_USE1_OP_FARITH						(0U)
#define EURASIA_USE1_OP_FSCALAR						(1U)
#define EURASIA_USE1_OP_FDOTPRODUCT					(2U)
#define EURASIA_USE1_OP_FMINMAX						(3U)
#define EURASIA_USE1_OP_FGRADIENT					(4U)
#define EURASIA_USE1_OP_MOVC						(5U)
#define EURASIA_USE1_OP_FARITH16					(6U)
#define EURASIA_USE1_OP_EFO							(7U)
#define EURASIA_USE1_OP_PCKUNPCK					(8U)
#define EURASIA_USE1_OP_TEST						(9U)
#define EURASIA_USE1_OP_ANDOR						(10U)
#define EURASIA_USE1_OP_XOR							(11U)
#define EURASIA_USE1_OP_SHLROL						(12U)
#define EURASIA_USE1_OP_SHRASR						(13U)
#define EURASIA_USE1_OP_RLP							(14U)
#define EURASIA_USE1_OP_TESTMASK					(15U)
#define EURASIA_USE1_OP_SOP2						(16U)
#define EURASIA_USE1_OP_SOP3						(17U)
#define EURASIA_USE1_OP_SOPWM						(18U)
#define EURASIA_USE1_OP_IMA8						(19U)
#define EURASIA_USE1_OP_IMA16						(20U)
#define EURASIA_USE1_OP_IMAE						(21U)
#define EURASIA_USE1_OP_ADIFFIRVBILIN				(22U)
#define EURASIA_USE1_OP_FIRH						(23U)
#define EURASIA_USE1_OP_DOT3DOT4					(24U)
#define EURASIA_USE1_OP_FPMA						(25U)
#define EURASIA_USE1_OP_SMP							(28U)
#define EURASIA_USE1_OP_LD							(29U)
#define EURASIA_USE1_OP_ST							(30U)
#define EURASIA_USE1_OP_SPECIAL						(31U)

/* Extended predicate field - used for float ops, pack/unpack, test */
#define EURASIA_USE1_EPRED_SHIFT					(24)
#define EURASIA_USE1_EPRED_CLRMSK					(0xF8FFFFFFU)

#define EURASIA_USE1_EPRED_ALWAYS					(0)
#define EURASIA_USE1_EPRED_P0						(1)
#define EURASIA_USE1_EPRED_P1						(2)
#define EURASIA_USE1_EPRED_P2						(3)
#define EURASIA_USE1_EPRED_P3						(4)
#define EURASIA_USE1_EPRED_NOTP0					(5)
#define EURASIA_USE1_EPRED_NOTP1					(6)
#define EURASIA_USE1_EPRED_PNMOD4					(7)

/* Range of predicate registers available without the negate flag. */
#define EURASIA_USE_EPRED_NUM_PREDICATES			(4)
/* Range of predicate registers available with the negate flag. */
#define EURASIA_USE_EPRED_NUM_NEGATED_PREDICATES	(2)

/* Short predicate field - use for efo,  */
#define EURASIA_USE1_SPRED_SHIFT					(25)
#define EURASIA_USE1_SPRED_CLRMSK					(0xF9FFFFFFU)

#define EURASIA_USE1_SPRED_ALWAYS					(0)
#define EURASIA_USE1_SPRED_P0						(1)
#define EURASIA_USE1_SPRED_P1						(2)
#define EURASIA_USE1_SPRED_NOTP0					(3)

/* Range of predicate registers available without the negate flag. */
#define EURASIA_USE_SPRED_NUM_PREDICATES			(2)
/* Range of predicate registers available with the negate flag. */
#define EURASIA_USE_SPRED_NUM_NEGATED_PREDICATES	(1)

/* Skip invalid instances - use for float ops, efo. */
#define EURASIA_USE1_SKIPINV						(0x00800000U)
#define EURASIA_USE1_RCNTSEL						(0x00200000U)
#define EURASIA_USE1_SYNCSTART						(0x00100000U)
#define EURASIA_USE1_DBEXT							(0x00080000U)
#define EURASIA_USE1_END							(0x00040000U)
#define EURASIA_USE1_S0BEXT							(0x00040000U)
#define EURASIA_USE1_S1BEXT							(0x00020000U)
#define EURASIA_USE1_S2BEXT							(0x00010000U)

#define EURASIA_USE1_RMSKCNT_SHIFT					(12)
#define EURASIA_USE1_RMSKCNT_CLRMSK					(0xFFFF0FFFU)

#define EURASIA_USE1_RMSKCNT_FULLMASK				(15)

#define EURASIA_USE1_RCOUNT_MAX						(15)

#define EURASIA_USE1_NOSCHED						(0x00000800U)

#define EURASIA_USE1_SRC0MOD_SHIFT					(7)
#define EURASIA_USE1_SRC0MOD_CLRMSK					(0xFFFFFE7FU)

#define EURASIA_USE1_SRC1MOD_SHIFT					(5)
#define EURASIA_USE1_SRC1MOD_CLRMSK					(0xFFFFFF9FU)

#define EURASIA_USE1_SRC2MOD_SHIFT					(3)
#define EURASIA_USE1_SRC2MOD_CLRMSK					(0xFFFFFFE7U)

#define EURASIA_USE1_S0BANK_SHIFT					(2)
#define EURASIA_USE1_S0BANK_CLRMSK					(0xFFFFFFFBU)

#define EURASIA_USE_FMTSELECT						(0x40)

#define EURASIA_USE_FMTF16_SELECTLOW				(0x0)
#define EURASIA_USE_FMTF16_SELECTHIGH				(0x1)
#define EURASIA_USE_FMTF16_REGNUM_SHIFT				(1)

#define EURASIA_USE_REGISTER_NUMBER_BITS			(7)
#define EURASIA_USE_REGISTER_NUMBER_MAX				(1UL << EURASIA_USE_REGISTER_NUMBER_BITS)
#define EURASIA_USE_FCREGISTER_NUMBER_MAX			(1UL << (EURASIA_USE_REGISTER_NUMBER_BITS - 1))

#define EURASIA_USE_NUM_TEMPS_MAPPED_TO_FPI			(4)

/* Possible non-extended bank selections. */
#define EURASIA_USE1_S0STDBANK_TEMP					(0)
#define EURASIA_USE1_S0STDBANK_PRIMATTR				(1)

/* Possible extended bank selections. */
#define EURASIA_USE1_S0EXTBANK_OUTPUT				(0)
#define EURASIA_USE1_S0EXTBANK_SECATTR				(1)

#define EURASIA_USE1_D1BANK_SHIFT					(0)
#define EURASIA_USE1_D1BANK_CLRMSK					(0xFFFFFFFCU)

/* Possible non-extended bank selections. */
#define EURASIA_USE1_D1STDBANK_TEMP					(0)
#define EURASIA_USE1_D1STDBANK_OUTPUT				(1)
#define EURASIA_USE1_D1STDBANK_PRIMATTR				(2)
#define EURASIA_USE1_D1STDBANK_INDEXED				(3)

/* Possible extended bank selections. */
#define EURASIA_USE1_D1EXTBANK_SECATTR				(0)
#define EURASIA_USE1_D1EXTBANK_SPECIAL				(1)
#define EURASIA_USE1_D1EXTBANK_INDEX				(2)
#define EURASIA_USE1_D1EXTBANK_FPINTERNAL			(3)

#define EURASIA_USE0_S1BANK_SHIFT					(30)
#define EURASIA_USE0_S1BANK_CLRMSK					(0x3FFFFFFFU)

/* Possible non-extended bank selections. */
#define EURASIA_USE0_S1STDBANK_TEMP					(0U)
#define EURASIA_USE0_S1STDBANK_OUTPUT				(1U)
#define EURASIA_USE0_S1STDBANK_PRIMATTR				(2U)
#define EURASIA_USE0_S1STDBANK_SECATTR				(3U)

/* Possible extended bank selections. */
#define EURASIA_USE0_S1EXTBANK_INDEXED				(0U)
#define EURASIA_USE0_S1EXTBANK_SPECIAL				(1U)
#define EURASIA_USE0_S1EXTBANK_IMMEDIATE			(2U)
#define EURASIA_USE0_S1EXTBANK_FPINTERNAL			(3U)

#define EURASIA_USE0_S2BANK_SHIFT					(28)
#define EURASIA_USE0_S2BANK_CLRMSK					(0xCFFFFFFFU)

/* Possible non-extended bank selections. */
#define EURASIA_USE0_S2STDBANK_TEMP					(0)
#define EURASIA_USE0_S2STDBANK_OUTPUT				(1)
#define EURASIA_USE0_S2STDBANK_PRIMATTR				(2)
#define EURASIA_USE0_S2STDBANK_SECATTR				(3)

/* Possible extended bank selections. */
#define EURASIA_USE0_S2EXTBANK_INDEXED				(0)
#define EURASIA_USE0_S2EXTBANK_SPECIAL				(1)
#define EURASIA_USE0_S2EXTBANK_IMMEDIATE			(2)
#define EURASIA_USE0_S2EXTBANK_FPINTERNAL			(3)

#define EURASIA_USE_SPECIAL_INTERNALDATA			(0x40U)

#define EURASIA_USE0_DST_SHIFT						(21)
#define EURASIA_USE0_DST_CLRMSK						(0xF01FFFFFU)

#define EURASIA_USE0_SRC0_SHIFT						(14)
#define EURASIA_USE0_SRC0_CLRMSK					(0xFFE03FFFU)

#define EURASIA_USE0_SRC1_SHIFT						(7)
#define EURASIA_USE0_SRC1_CLRMSK					(0xFFFFC07FU)

#define EURASIA_USE0_SRC2_SHIFT						(0)
#define EURASIA_USE0_SRC2_CLRMSK					(0xFFFFFF80U)

/*
	Floating point instruction fields.
*/
#define EURASIA_USE1_FLOAT_SFASEL					(0x00400000U)

#define EURASIA_USE1_FLOAT_OP2_SHIFT				(9)
#define EURASIA_USE1_FLOAT_OP2_CLRMSK				(0xFFFFF9FFU)

#define EURASIA_USE1_FLOAT_OP2_MAD					(0)
#define EURASIA_USE1_FLOAT_OP2_ADM					(1)
#define EURASIA_USE1_FLOAT_OP2_MSA					(2)
#define EURASIA_USE1_FLOAT_OP2_FRC					(3)

#define EURASIA_USE1_FLOAT_OP2_RCP					(0)
#define EURASIA_USE1_FLOAT_OP2_RSQ					(1)
#define EURASIA_USE1_FLOAT_OP2_LOG					(2)
#define EURASIA_USE1_FLOAT_OP2_EXP					(3)

#define EURASIA_USE1_FLOAT_OP2_MIN					(0)
#define EURASIA_USE1_FLOAT_OP2_MAX					(1)

#define EURASIA_USE1_FLOAT_OP2_DP					(0)
#define EURASIA_USE1_FLOAT_OP2_DDP					(1)
#define EURASIA_USE1_FLOAT_OP2_DDPC					(2)

#define EURASIA_USE1_FLOAT_OP2_DSX					(0)
#define EURASIA_USE1_FLOAT_OP2_DSY					(1)

#define EURASIA_USE1_FLOAT_OP2_FMAD16				(0)

/*
	Scalar op instruction fields.
*/
#define EURASIA_USE1_FSCALAR_DTYPE_SHIFT			(7)
#define EURASIA_USE1_FSCALAR_DTYPE_CLRMSK			(0xFFFFFE7FU)
#define EURASIA_USE1_FSCALAR_DTYPE_F32				(0)
#define EURASIA_USE1_FSCALAR_DTYPE_F16				(1)
#define EURASIA_USE1_FSCALAR_DTYPE_C10				(2)
#define EURASIA_USE1_FSCALAR_DTYPE_RESERVED			(3)

#define EURASIA_USE1_FSCALAR_CHANSEL_SHIFT			(3)
#define EURASIA_USE1_FSCALAR_CHANSEL_CLRMSK			(0xFFFFFFE7U)
#define EURASIA_USE1_FSCALAR_CHANSEL_B				(0)
#define EURASIA_USE1_FSCALAR_CHANSEL_LOWWORD		(0)
#define EURASIA_USE1_FSCALAR_CHANSEL_G				(1)
#define EURASIA_USE1_FSCALAR_CHANSEL_HIGHWORD		(1)
#define EURASIA_USE1_FSCALAR_CHANSEL_R				(2)
#define EURASIA_USE1_FSCALAR_CHANSEL_A				(3)

#define EURASIA_USE1_FSCALAR_TYPEPRESERVE			(0x00000004U)

/*
	Dotproduct instruction fields.
*/
#define EURASIA_USE1_DOTPRODUCT_UPDATEI0			(0x00000000U)
#define EURASIA_USE1_DOTPRODUCT_UPDATEI1			(0x00080000U)

#define EURASIA_USE0_DP_CLIPENABLE					(0x00004000U)

#define EURASIA_USE0_DP_CLIPPLANEUPDATE_SHIFT		(15)
#define EURASIA_USE0_DP_CLIPPLANEUPDATE_CLRMSK		(0xFFFC7FFFU)

#define EURASIA_USE1_DDPC_CLIPPLANEUPDATE_SHIFT		(3)
#define EURASIA_USE1_DDPC_CLIPPLANEUPDATE_CLRMSK	(0xFFFFFE07U)

/*
	Conditional move instruction fields.
*/
#define EURASIA_USE1_MOVC_TESTCCEXT					(0x00400000U)

#define EURASIA_USE1_MOVC_TSTDTYPE_SHIFT			(8)
#define EURASIA_USE1_MOVC_TSTDTYPE_CLRMSK			(0xFFFFF8FFU)

#define EURASIA_USE1_MOVC_TSTDTYPE_UNCOND			(0)
#define EURASIA_USE1_MOVC_TSTDTYPE_INT8				(1)
#define EURASIA_USE1_MOVC_TSTDTYPE_INT16			(2)
#define EURASIA_USE1_MOVC_TSTDTYPE_INT32			(3)
#define EURASIA_USE1_MOVC_TSTDTYPE_FLOAT			(4)
#define EURASIA_USE1_MOVC_TSTDTYPE_INT10			(5)

#define EURASIA_USE1_MOVC_TESTCC_SHIFT				(7)
#define EURASIA_USE1_MOVC_TESTCC_CLRMSK				(0xFFFFFF7FU)

#define EURASIA_USE1_MOVC_TESTCC_STDZERO			(0)
#define EURASIA_USE1_MOVC_TESTCC_STDNONZERO			(1)
#define EURASIA_USE1_MOVC_TESTCC_EXTSIGNED			(0)
#define EURASIA_USE1_MOVC_TESTCC_EXTNONSIGNED		(1)

/*
	Extended float operation instruction fields.
*/

/* Negate left-hand source for A1 adder. */
#define EURASIA_USE1_EFO_A1LNEG						(0x00400000U)
/* Destination source select. */
#define EURASIA_USE1_EFO_DSRC_SHIFT					(20)
#define EURASIA_USE1_EFO_DSRC_CLRMSK				(0xFFCFFFFFU)

#define EURASIA_USE1_EFO_DSRC_I0					(0)
#define EURASIA_USE1_EFO_DSRC_I1					(1)
#define EURASIA_USE1_EFO_DSRC_A0					(2)
#define EURASIA_USE1_EFO_DSRC_A1					(3)
/* Intermediate storage source. */
#define EURASIA_USE1_EFO_ISRC_SHIFT					(18)
#define EURASIA_USE1_EFO_ISRC_CLRMSK				(0xFFF3FFFFU)

#define EURASIA_USE1_EFO_ISRC_I0A0_I1A1				(0)
#define EURASIA_USE1_EFO_ISRC_I0A1_I1A0				(1)
#define EURASIA_USE1_EFO_ISRC_I0M0_I1M1				(2)
#define EURASIA_USE1_EFO_ISRC_I0A0_I1M1				(3)
/* Addr source selection. */
#define EURASIA_USE1_EFO_ASRC_SHIFT					(16)
#define EURASIA_USE1_EFO_ASRC_CLRMSK				(0xFFFCFFFFU)

#define EURASIA_USE1_EFO_ASRC_M0M1_I1I0				(0)
#define EURASIA_USE1_EFO_ASRC_M0SRC2_I1I0			(1)
#define EURASIA_USE1_EFO_ASRC_M0I0_I1M1				(2)
#define EURASIA_USE1_EFO_ASRC_SRC0SRC1_SRC2SRC0		(3)

/* Multiplier source selection. */
#define EURASIA_USE1_EFO_MSRC_SHIFT					(14)
#define EURASIA_USE1_EFO_MSRC_CLRMSK				(0xFFFF3FFFU)

#define EURASIA_USE1_EFO_MSRC_SRC0SRC1_SRC0SRC2		(0)
#define EURASIA_USE1_EFO_MSRC_SRC0SRC1_SRC0SRC0		(1)
#define EURASIA_USE1_EFO_MSRC_SRC1SRC2_SRC0SRC0		(2)
#define EURASIA_USE1_EFO_MSRC_SRC1I0_SRC0I1			(3)

#define EURASIA_USE1_EFO_RCOUNT_SHIFT				(12)
#define EURASIA_USE1_EFO_RCOUNT_CLRMSK				(0xFFFFCFFFU)
#define EURASIA_USE1_EFO_RCOUNT_MAX					(4)

#define EURASIA_USE1_EFO_WI1EN_SHIFT				(9)

#define EURASIA_USE1_EFO_WI0EN						(0x00000400U)
#define EURASIA_USE1_EFO_WI1EN						(0x00000200U)

/*
	Pack/unpack instruction fields.
*/
#define EURASIA_USE1_PCK_NOSCHED					(0x00400000U)

#define EURASIA_USE1_PCK_SRCF_SHIFT					(9)
#define EURASIA_USE1_PCK_SRCF_CLRMSK				(0xFFFFF1FFU)

#define EURASIA_USE1_PCK_DSTF_SHIFT					(6)
#define EURASIA_USE1_PCK_DSTF_CLRMSK				(0xFFFFFE3FU)

#define EURASIA_USE1_PCK_FMT_U8						(0)
#define EURASIA_USE1_PCK_FMT_S8						(1)
#define EURASIA_USE1_PCK_FMT_O8						(2)
#define EURASIA_USE1_PCK_FMT_U16					(3)
#define EURASIA_USE1_PCK_FMT_S16					(4)
#define EURASIA_USE1_PCK_FMT_F16					(5)
#define EURASIA_USE1_PCK_FMT_F32					(6)
#define EURASIA_USE1_PCK_FMT_C10					(7)

#define EURASIA_USE1_PCK_DMASK_SHIFT				(2)
#define EURASIA_USE1_PCK_DMASK_CLRMSK				(0xFFFFFFC3U)

#define EURASIA_USE0_PCK_SCALE						(0x00040000U)

#define EURASIA_USE0_PCK_S1SCSEL_SHIFT				(16)
#define EURASIA_USE0_PCK_S1SCSEL_CLRMSK				(0xFFFCFFFFU)

#define EURASIA_USE0_PCK_S2SCSEL_SHIFT				(14)
#define EURASIA_USE0_PCK_S2SCSEL_CLRMSK				(0xFFFF3FFFU)

/*
	Test instruction fields.
*/
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_TEST_SAT						(0x00400000U)
#define EURASIA_USE1_TEST_NOPAIR_NOSCHED			(0x00400000U)

#define EURASIA_USE1_TEST_ONCEONLY					(0x00200000U)

#define EURASIA_USE1_TEST_PARTIAL					(0x00040000U)
#define EURASIA_USE1_TEST_SFASEL					(0x00040000U)
#define EURASIA_USE1_TEST_NOPAIR_SAT				(0x00040000U)

#define EURASIA_USE1_TEST_PREDMASK_SHIFT			(12)
#define EURASIA_USE1_TEST_PREDMASK_CLRMSK			(0xFFFF0FFFU)

#define EURASIA_USE1_TEST_MAX_REPEAT				(4)

#define EURASIA_USE1_TEST_STST_SHIFT				(10)
#define EURASIA_USE1_TEST_STST_CLRMSK				(0xFFFFF3FFU)

#define EURASIA_USE1_TEST_STST_NONE					(0)
#define EURASIA_USE1_TEST_STST_NEGATIVE				(1)
#define EURASIA_USE1_TEST_STST_POSITIVE				(2)
#define EURASIA_USE1_TEST_STST_RESERVED				(3)

#define EURASIA_USE1_TEST_ZTST_SHIFT				(8)
#define EURASIA_USE1_TEST_ZTST_CLRMSK				(0xFFFFFCFFU)

#define EURASIA_USE1_TEST_ZTST_NONE					(0)
#define EURASIA_USE1_TEST_ZTST_ZERO					(1)
#define EURASIA_USE1_TEST_ZTST_NOTZERO				(2)
#define EURASIA_USE1_TEST_ZTST_RESERVED				(3)

#define EURASIA_USE1_TEST_CRCOMB_AND				(0x00000080U)

#define EURASIA_USE1_TEST_CHANCC_SHIFT				(4)
#define EURASIA_USE1_TEST_CHANCC_CLRMSK				(0xFFFFFF8FU)

#define EURASIA_USE1_TEST_CHANCC_SELECT0			(0)
#define EURASIA_USE1_TEST_CHANCC_SELECT1			(1)
#define EURASIA_USE1_TEST_CHANCC_SELECT2			(2)
#define EURASIA_USE1_TEST_CHANCC_SELECT3			(3)
#define EURASIA_USE1_TEST_CHANCC_ANDALL				(4)
#define EURASIA_USE1_TEST_CHANCC_ORALL				(5)
#define EURASIA_USE1_TEST_CHANCC_AND02				(6)
#define EURASIA_USE1_TEST_CHANCC_OR02				(7)

#define EURASIA_USE1_TEST_PDST_SHIFT				(2)
#define EURASIA_USE1_TEST_PDST_CLRMSK				(0xFFFFFFF3U)

#define EURASIA_USE0_TEST_WBEN						(0x00100000U)

#define EURASIA_USE0_TEST_ALUSEL_SHIFT				(18)
#define EURASIA_USE0_TEST_ALUSEL_CLRMSK				(0xFFF3FFFFU)

#define EURASIA_USE0_TEST_ALUSEL_F32				(0)
#define EURASIA_USE0_TEST_ALUSEL_I16				(1)
#define EURASIA_USE0_TEST_ALUSEL_I8					(2)
#define EURASIA_USE0_TEST_ALUSEL_BITWISE			(3)

#define EURASIA_USE0_TEST_ALUOP_SHIFT				(14)
#define EURASIA_USE0_TEST_ALUOP_CLRMSK				(0xFFFC3FFFU)

#define EURASIA_USE0_TEST_ALUOP_F32_ADD				(0)
#define EURASIA_USE0_TEST_ALUOP_F32_RESERVED0		(1)
#define EURASIA_USE0_TEST_ALUOP_F32_RESERVED1		(2)
#define EURASIA_USE0_TEST_ALUOP_F32_FRC				(3)
#define EURASIA_USE0_TEST_ALUOP_F32_RCP				(4)
#define EURASIA_USE0_TEST_ALUOP_F32_RSQ				(5)
#define EURASIA_USE0_TEST_ALUOP_F32_LOG				(6)
#define EURASIA_USE0_TEST_ALUOP_F32_EXP				(7)
#define EURASIA_USE0_TEST_ALUOP_F32_DP				(8)
#define EURASIA_USE0_TEST_ALUOP_F32_MIN				(9)
#define EURASIA_USE0_TEST_ALUOP_F32_MAX				(10)
#define EURASIA_USE0_TEST_ALUOP_F32_DSX				(11)
#define EURASIA_USE0_TEST_ALUOP_F32_DSY				(12)
#define EURASIA_USE0_TEST_ALUOP_F32_MUL				(13)
#define EURASIA_USE0_TEST_ALUOP_F32_SUB				(14)
#define EURASIA_USE0_TEST_ALUOP_F32_RESERVED2		(15)

#define EURASIA_USE0_TEST_ALUOP_I16_RESERVED0		(0)
#define EURASIA_USE0_TEST_ALUOP_I16_RESERVED1		(1)
#define EURASIA_USE0_TEST_ALUOP_I16_RESERVED2		(2)
#define EURASIA_USE0_TEST_ALUOP_I16_RESERVED3		(3)
#define EURASIA_USE0_TEST_ALUOP_I16_RESERVED4		(4)
#define EURASIA_USE0_TEST_ALUOP_I16_RESERVED5		(5)
#define EURASIA_USE0_TEST_ALUOP_I16_IADD			(6)
#define EURASIA_USE0_TEST_ALUOP_I16_ISUB			(7)
#define EURASIA_USE0_TEST_ALUOP_I16_IMUL			(8)
#define EURASIA_USE0_TEST_ALUOP_I16_IADDU			(9)
#define EURASIA_USE0_TEST_ALUOP_I16_ISUBU			(10)
#define EURASIA_USE0_TEST_ALUOP_I16_IMULU			(11)
#define EURASIA_USE0_TEST_ALUOP_I16_IADD32			(12)
#define EURASIA_USE0_TEST_ALUOP_I16_IADDU32			(13)

#define EURASIA_USE0_TEST_ALUOP_I8_ADD				(0)
#define EURASIA_USE0_TEST_ALUOP_I8_SUB				(1)
#define EURASIA_USE0_TEST_ALUOP_I8_ADDU				(2)
#define EURASIA_USE0_TEST_ALUOP_I8_SUBU				(3)
#define EURASIA_USE0_TEST_ALUOP_I8_MUL				(4)
#define EURASIA_USE0_TEST_ALUOP_I8_FPMUL			(5)
#define EURASIA_USE0_TEST_ALUOP_I8_MULU				(6)
#define EURASIA_USE0_TEST_ALUOP_I8_FPADD			(7)
#define EURASIA_USE0_TEST_ALUOP_I8_FPSUB			(8)

#define EURASIA_USE0_TEST_ALUOP_BITWISE_AND			(0)
#define EURASIA_USE0_TEST_ALUOP_BITWISE_OR			(1)
#define EURASIA_USE0_TEST_ALUOP_BITWISE_XOR			(2)
#define EURASIA_USE0_TEST_ALUOP_BITWISE_SHL			(3)
#define EURASIA_USE0_TEST_ALUOP_BITWISE_SHR			(4)
#define EURASIA_USE0_TEST_ALUOP_BITWISE_ROL			(5)
#define EURASIA_USE0_TEST_ALUOP_BITWISE_ASR			(7)

/*
	Test with mask fields.
*/
#define EURASIA_USE1_TESTMASK_TSTTYPE_SHIFT			(4)
#define EURASIA_USE1_TESTMASK_TSTTYPE_CLRMSK		(0xFFFFFFCFU)

#define EURASIA_USE1_TESTMASK_TSTTYPE_4CHAN			(0)
#define EURASIA_USE1_TESTMASK_TSTTYPE_2CHAN			(1)
#define EURASIA_USE1_TESTMASK_TSTTYPE_1CHAN			(2)

/*
	Bitwise instruction fields.
*/
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_BITWISE_NOSCHED				(0x00400000U)

#define EURASIA_USE1_BITWISE_SRC2INV				(0x00000800U)

#define EURASIA_USE1_BITWISE_SRC2ROT_SHIFT			(6)
#define EURASIA_USE1_BITWISE_SRC2ROT_CLRMSK			(0xFFFFF83FU)
#define EURASIA_USE1_BITWISE_SRC2ROT_MAXIMUM		(31)

#define EURASIA_USE1_BITWISE_SRC2IEXTH_SHIFT		(4)
#define EURASIA_USE1_BITWISE_SRC2IEXTH_CLRMSK		(0xFFFFFFCFU)

#define EURASIA_USE1_BITWISE_OP2_SHIFT				(3)
#define EURASIA_USE1_BITWISE_OP2_CLRMSK				(0xFFFFFFF7U)

#define EURASIA_USE1_BITWISE_OP2_AND				(0)
#define EURASIA_USE1_BITWISE_OP2_OR					(1)

#define EURASIA_USE1_BITWISE_OP2_XOR				(0)

#define EURASIA_USE1_BITWISE_OP2_SHL				(0)
#define EURASIA_USE1_BITWISE_OP2_ROL				(1)

#define EURASIA_USE1_BITWISE_OP2_SHR				(0)
#define EURASIA_USE1_BITWISE_OP2_ASR				(1)

#define EURASIA_USE1_BITWISE_OP2_RLP				(0)

#define EURASIA_USE1_BITWISE_PARTIAL				(0x00000004U)

#define EURASIA_USE0_BITWISE_SRC2IEXTLPSEL_SHIFT	(14)
#define EURASIA_USE0_BITWISE_SRC2IEXTLPSEL_CLRMSK	(0xFFE03FFFU)

#define EURASIA_USE_BITWISE_MAXIMUM_UNROTATED_IMMEDIATE \
													(0x0000FFFFU)

/*
	Integer instruction fields.
*/
#define EURASIA_USE1_INT_RCOUNT_SHIFT				(12)
#define EURASIA_USE1_INT_RCOUNT_CLRMSK				(0xFFFF8FFFU)
#define EURASIA_USE1_INT_RCOUNT_MAXIMUM				(8)

#define EURASIA_USE1_INT_NOSCHED					(0x00400000U)

/*
	SOP2 instruction fields.
*/
#define EURASIA_USE1_SOP2_CMOD1_SHIFT				(24)
#define EURASIA_USE1_SOP2_CMOD1_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_SOP2_CMOD1_NONE				(0)
#define EURASIA_USE1_SOP2_CMOD1_COMPLEMENT			(1)

#define EURASIA_USE1_SOP2_ASEL1_SHIFT				(20)
#define EURASIA_USE1_SOP2_ASEL1_CLRMSK				(0xFFCFFFFFU)

#define EURASIA_USE1_SOP2_ASEL1_ZERO				(0)
#define EURASIA_USE1_SOP2_ASEL1_SRC1ALPHA			(1)
#define EURASIA_USE1_SOP2_ASEL1_SRC2ALPHA			(2)
#define EURASIA_USE1_SOP2_ASEL1_SRC2ALPHAX2			(3)

#define EURASIA_USE1_SOP2_CMOD2_SHIFT				(15)
#define EURASIA_USE1_SOP2_CMOD2_CLRMSK				(0xFFFF7FFFU)

#define EURASIA_USE1_SOP2_CMOD2_NONE				(0)
#define EURASIA_USE1_SOP2_CMOD2_COMPLEMENT			(1)

#define EURASIA_USE1_SOP2_AMOD1_SHIFT				(11)
#define EURASIA_USE1_SOP2_AMOD1_CLRMSK				(0xFFFFF7FFU)

#define EURASIA_USE1_SOP2_AMOD1_NONE				(0)
#define EURASIA_USE1_SOP2_AMOD1_COMPLEMENT			(1)

#define EURASIA_USE1_SOP2_ASEL2_SHIFT				(9)
#define EURASIA_USE1_SOP2_ASEL2_CLRMSK				(0xFFFFF9FFU)

#define EURASIA_USE1_SOP2_ASEL2_ZERO				(0)
#define EURASIA_USE1_SOP2_ASEL2_SRC1ALPHA			(1)
#define EURASIA_USE1_SOP2_ASEL2_SRC2ALPHA			(2)
#define EURASIA_USE1_SOP2_ASEL2_ZEROSRC2MINUSHALF	(3)

#define EURASIA_USE1_SOP2_CSEL1_SHIFT				(6)
#define EURASIA_USE1_SOP2_CSEL1_CLRMSK				(0xFFFFFE3FU)

#define EURASIA_USE1_SOP2_CSEL1_ZERO				(0)
#define EURASIA_USE1_SOP2_CSEL1_SRC1				(1)
#define EURASIA_USE1_SOP2_CSEL1_SRC2				(2)
#define EURASIA_USE1_SOP2_CSEL1_SRC1ALPHA			(3)
#define EURASIA_USE1_SOP2_CSEL1_SRC2ALPHA			(4)
#define EURASIA_USE1_SOP2_CSEL1_MINSRC1A1MSRC2A		(5)
#define EURASIA_USE1_SOP2_CSEL1_SRC2DESTX2			(6)
#define EURASIA_USE1_SOP2_CSEL1_RESERVED			(7)

#define EURASIA_USE1_SOP2_CSEL2_SHIFT				(3)
#define EURASIA_USE1_SOP2_CSEL2_CLRMSK				(0xFFFFFFC7U)

#define EURASIA_USE1_SOP2_CSEL2_ZERO				(0)
#define EURASIA_USE1_SOP2_CSEL2_SRC1				(1)
#define EURASIA_USE1_SOP2_CSEL2_SRC2				(2)
#define EURASIA_USE1_SOP2_CSEL2_SRC1ALPHA			(3)
#define EURASIA_USE1_SOP2_CSEL2_SRC2ALPHA			(4)
#define EURASIA_USE1_SOP2_CSEL2_MINSRC1A1MSRC2A		(5)
#define EURASIA_USE1_SOP2_CSEL2_ZEROSRC2MINUSHALF	(6)
#define EURASIA_USE1_SOP2_CSEL2_RESERVED			(7)

#define EURASIA_USE1_SOP2_AMOD2_SHIFT				(2)
#define EURASIA_USE1_SOP2_AMOD2_CLRMSK				(0xFFFFFFFBU)

#define EURASIA_USE1_SOP2_AMOD2_NONE				(0)
#define EURASIA_USE1_SOP2_AMOD2_COMPLEMENT			(1)

#define EURASIA_USE0_SOP2_SRC1MOD_SHIFT				(20)
#define EURASIA_USE0_SOP2_SRC1MOD_CLRMSK			(0xFFEFFFFFU)

#define EURASIA_USE0_SOP2_SRC1MOD_NONE				(0)
#define EURASIA_USE0_SOP2_SRC1MOD_COMPLEMENT		(1)

#define EURASIA_USE0_SOP2_COP_SHIFT					(18)
#define EURASIA_USE0_SOP2_COP_CLRMSK				(0xFFF3FFFFU)

#define EURASIA_USE0_SOP2_COP_ADD					(0)
#define EURASIA_USE0_SOP2_COP_SUB					(1)
#define EURASIA_USE0_SOP2_COP_MIN					(2)
#define EURASIA_USE0_SOP2_COP_MAX					(3)

#define EURASIA_USE0_SOP2_AOP_SHIFT					(16)
#define EURASIA_USE0_SOP2_AOP_CLRMSK				(0xFFFCFFFFU)

#define EURASIA_USE0_SOP2_AOP_ADD					(0)
#define EURASIA_USE0_SOP2_AOP_SUB					(1)
#define EURASIA_USE0_SOP2_AOP_MIN					(2)
#define EURASIA_USE0_SOP2_AOP_MAX					(3)

#define EURASIA_USE0_SOP2_ASRC1MOD_SHIFT			(15)
#define EURASIA_USE0_SOP2_ASRC1MOD_CLRMSK			(0xFFFF7FFFU)

#define EURASIA_USE0_SOP2_ASRC1MOD_NONE				(0)
#define EURASIA_USE0_SOP2_ASRC1MOD_COMPLEMENT		(1)

#define EURASIA_USE0_SOP2_ADSTMOD_SHIFT				(14)
#define EURASIA_USE0_SOP2_ADSTMOD_CLRMSK			(0xFFFFBFFFU)

#define EURASIA_USE0_SOP2_ADSTMOD_NONE				(0)
#define EURASIA_USE0_SOP2_ADSTMOD_NEGATE			(1)

/*
	SOPWM instruction fields.
*/
#define EURASIA_USE1_SOP2WM_MOD1_SHIFT				(24)
#define EURASIA_USE1_SOP2WM_MOD1_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_SOP2WM_MOD1_NONE				(0)
#define EURASIA_USE1_SOP2WM_MOD1_COMPLEMENT			(1)

#define EURASIA_USE1_SOP2WM_COP_SHIFT				(20)
#define EURASIA_USE1_SOP2WM_COP_CLRMSK				(0xFFCFFFFFU)

#define EURASIA_USE1_SOP2WM_COP_ADD					(0)
#define EURASIA_USE1_SOP2WM_COP_SUB					(1)
#define EURASIA_USE1_SOP2WM_COP_MIN					(2)
#define EURASIA_USE1_SOP2WM_COP_MAX					(3)

#define EURASIA_USE1_SOP2WM_MOD2_SHIFT				(15)
#define EURASIA_USE1_SOP2WM_MOD2_CLRMSK				(0xFFFF7FFFU)

#define EURASIA_USE1_SOP2WM_MOD2_NONE				(0)
#define EURASIA_USE1_SOP2WM_MOD2_COMPLEMENT			(1)

#define EURASIA_USE1_SOP2WM_WRITEMASK_SHIFT			(11)
#define EURASIA_USE1_SOP2WM_WRITEMASK_CLRMSK		(0xFFFF87FFU)
#define EURASIA_USE1_SOP2WM_WRITEMASK_W				1U
#define EURASIA_USE1_SOP2WM_WRITEMASK_X				2U
#define EURASIA_USE1_SOP2WM_WRITEMASK_Y				4U
#define EURASIA_USE1_SOP2WM_WRITEMASK_Z				8U
#define EURASIA_USE1_SOP2WM_WRITEMASK_XYZW			(EURASIA_USE1_SOP2WM_WRITEMASK_W | EURASIA_USE1_SOP2WM_WRITEMASK_X | EURASIA_USE1_SOP2WM_WRITEMASK_Y | EURASIA_USE1_SOP2WM_WRITEMASK_Z)

#define EURASIA_USE1_SOP2WM_WRITEMASK_A				EURASIA_USE1_SOP2WM_WRITEMASK_W
#if defined(SGX_FEATURE_USE_VEC34)
#define EURASIA_USE1_SOP2WM_WRITEMASK_B				EURASIA_USE1_SOP2WM_WRITEMASK_Z
#define EURASIA_USE1_SOP2WM_WRITEMASK_G				EURASIA_USE1_SOP2WM_WRITEMASK_Y
#define EURASIA_USE1_SOP2WM_WRITEMASK_R				EURASIA_USE1_SOP2WM_WRITEMASK_X
#else /* #if defined(SGX_FEATURE_USE_VEC34) */
#define EURASIA_USE1_SOP2WM_WRITEMASK_R				EURASIA_USE1_SOP2WM_WRITEMASK_Z
#define EURASIA_USE1_SOP2WM_WRITEMASK_G				EURASIA_USE1_SOP2WM_WRITEMASK_Y
#define EURASIA_USE1_SOP2WM_WRITEMASK_B				EURASIA_USE1_SOP2WM_WRITEMASK_X
#endif /* #if defined(SGX_FEATURE_USE_VEC34) */
#define EURASIA_USE1_SOP2WM_WRITEMASK_RGBA			(EURASIA_USE1_SOP2WM_WRITEMASK_A | EURASIA_USE1_SOP2WM_WRITEMASK_B | EURASIA_USE1_SOP2WM_WRITEMASK_G | EURASIA_USE1_SOP2WM_WRITEMASK_R)
#define EURASIA_USE1_SOP2WM_WRITEMASK_RGB			(EURASIA_USE1_SOP2WM_WRITEMASK_B | EURASIA_USE1_SOP2WM_WRITEMASK_G | EURASIA_USE1_SOP2WM_WRITEMASK_R)

#define EURASIA_USE1_SOP2WM_AOP_SHIFT				(9)
#define EURASIA_USE1_SOP2WM_AOP_CLRMSK				(0xFFFFF9FFU)

#define EURASIA_USE1_SOP2WM_AOP_ADD					(0)
#define EURASIA_USE1_SOP2WM_AOP_SUB					(1)
#define EURASIA_USE1_SOP2WM_AOP_MIN					(2)
#define EURASIA_USE1_SOP2WM_AOP_MAX					(3)

#define EURASIA_USE1_SOP2WM_SEL1_SHIFT				(6)
#define EURASIA_USE1_SOP2WM_SEL1_CLRMSK				(0xFFFFFE3FU)

#define EURASIA_USE1_SOP2WM_SEL1_ZERO				(0)
#define EURASIA_USE1_SOP2WM_SEL1_MINSRC1A1MSRC2A	(1)
#define EURASIA_USE1_SOP2WM_SEL1_SRC1				(2)
#define EURASIA_USE1_SOP2WM_SEL1_SRC1ALPHA			(3)
#define EURASIA_USE1_SOP2WM_SEL1_RESERVED0			(4)
#define EURASIA_USE1_SOP2WM_SEL1_RESERVED1			(5)
#define EURASIA_USE1_SOP2WM_SEL1_SRC2				(6)
#define EURASIA_USE1_SOP2WM_SEL1_SRC2ALPHA			(7)

#define EURASIA_USE1_SOP2WM_SEL2_SHIFT				(3)
#define EURASIA_USE1_SOP2WM_SEL2_CLRMSK				(0xFFFFFFC7U)

#define EURASIA_USE1_SOP2WM_SEL2_ZERO				(0)
#define EURASIA_USE1_SOP2WM_SEL2_MINSRC1A1MSRC2A	(1)
#define EURASIA_USE1_SOP2WM_SEL2_SRC1				(2)
#define EURASIA_USE1_SOP2WM_SEL2_SRC1ALPHA			(3)
#define EURASIA_USE1_SOP2WM_SEL2_RESERVED0			(4)
#define EURASIA_USE1_SOP2WM_SEL2_RESERVED1			(5)
#define EURASIA_USE1_SOP2WM_SEL2_SRC2				(6)
#define EURASIA_USE1_SOP2WM_SEL2_SRC2ALPHA			(7)

/*
	SOP3 instruction fields.
*/
#define EURASIA_USE1_SOP3_CMOD1_SHIFT				(24)
#define EURASIA_USE1_SOP3_CMOD1_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_SOP3_CMOD1_NONE				(0)
#define EURASIA_USE1_SOP3_CMOD1_COMPLEMENT			(1)

#define EURASIA_USE1_SOP3_COP_SHIFT					(20)
#define EURASIA_USE1_SOP3_COP_CLRMSK				(0xFFCFFFFFU)

#define EURASIA_USE1_SOP3_COP_ADD					(0)
#define EURASIA_USE1_SOP3_COP_SUB					(1)
#define EURASIA_USE1_SOP3_COP_INTERPOLATE1			(2)
#define EURASIA_USE1_SOP3_COP_INTERPOLATE2			(3)

#define EURASIA_USE1_SOP3_CMOD2_SHIFT				(15)
#define EURASIA_USE1_SOP3_CMOD2_CLRMSK				(0xFFFF7FFFU)

#define EURASIA_USE1_SOP3_CMOD2_NONE				(0)
#define EURASIA_USE1_SOP3_CMOD2_COMPLEMENT			(1)

#define EURASIA_USE1_SOP3_AMOD1_SHIFT				(14)
#define EURASIA_USE1_SOP3_AMOD1_CLRMSK				(0xFFFFBFFFU)

#define EURASIA_USE1_SOP3_AMOD1_NONE				(0)
#define EURASIA_USE1_SOP3_AMOD1_COMPLEMENT			(1)

#define EURASIA_USE1_SOP3_ASEL1_SHIFT				(12)
#define EURASIA_USE1_SOP3_ASEL1_CLRMSK				(0xFFFFCFFFU)

#define EURASIA_USE1_SOP3_ASEL1_ZERO				(0)
#define EURASIA_USE1_SOP3_ASEL1_SRC0ALPHA			(1)
#define EURASIA_USE1_SOP3_ASEL1_SRC1ALPHA			(2)
#define EURASIA_USE1_SOP3_ASEL1_SRC2ALPHA			(3)

#define EURASIA_USE1_SOP3_ASEL1_10ZERO				(0)
#define EURASIA_USE1_SOP3_ASEL1_10SRC1				(2)

#define EURASIA_USE1_SOP3_ASEL1_11ZERO				(0)
#define EURASIA_USE1_SOP3_ASEL1_11SRC2				(1)

#define EURASIA_USE1_SOP3_DESTMOD_SHIFT				(11)
#define EURASIA_USE1_SOP3_DESTMOD_CLRMSK			(0xFFFFF7FFU)

#define EURASIA_USE1_SOP3_DESTMOD_NONE				(0)
#define EURASIA_USE1_SOP3_DESTMOD_NEGATE			(1)

#define EURASIA_USE1_SOP3_DESTMOD_CS0SRC0			(0)
#define EURASIA_USE1_SOP3_DESTMOD_CS0SRC0ALPHA		(1)

#define EURASIA_USE1_SOP3_DESTMOD_COMPLEMENTSRC2	(1)

#define EURASIA_USE1_SOP3_DESTMOD_CS1ZERO			(0)
#define EURASIA_USE1_SOP3_DESTMOD_CS1SRC1			(1)

#define EURASIA_USE1_SOP3_AOP_SHIFT					(9)
#define EURASIA_USE1_SOP3_AOP_CLRMSK				(0xFFFFF9FFU)

#define EURASIA_USE1_SOP3_AOP_ADD					(0)
#define EURASIA_USE1_SOP3_AOP_SUB					(1)
#define EURASIA_USE1_SOP3_AOP_INTERPOLATE1			(2)
#define EURASIA_USE1_SOP3_AOP_INTERPOLATE2			(3)

#define EURASIA_USE1_SOP3_CSEL1_SHIFT				(6)
#define EURASIA_USE1_SOP3_CSEL1_CLRMSK				(0xFFFFFE3FU)

#define EURASIA_USE1_SOP3_CSEL1_ZERO				(0)
#define EURASIA_USE1_SOP3_CSEL1_MINSRC1A1MSRC2A		(1)
#define EURASIA_USE1_SOP3_CSEL1_SRC1				(2)
#define EURASIA_USE1_SOP3_CSEL1_SRC1ALPHA			(3)
#define EURASIA_USE1_SOP3_CSEL1_SRC0				(4)
#define EURASIA_USE1_SOP3_CSEL1_SRC0ALPHA			(5)
#define EURASIA_USE1_SOP3_CSEL1_SRC2				(6)
#define EURASIA_USE1_SOP3_CSEL1_SRC2ALPHA			(7)

#define EURASIA_USE1_SOP3_CSEL2_SHIFT				(3)
#define EURASIA_USE1_SOP3_CSEL2_CLRMSK				(0xFFFFFFC7U)

#define EURASIA_USE1_SOP3_CSEL2_ZERO				(0)
#define EURASIA_USE1_SOP3_CSEL2_MINSRC1A1MSRC2A		(1)
#define EURASIA_USE1_SOP3_CSEL2_SRC1				(2)
#define EURASIA_USE1_SOP3_CSEL2_SRC1ALPHA			(3)
#define EURASIA_USE1_SOP3_CSEL2_SRC0				(4)
#define EURASIA_USE1_SOP3_CSEL2_SRC0ALPHA			(5)
#define EURASIA_USE1_SOP3_CSEL2_SRC2				(6)
#define EURASIA_USE1_SOP3_CSEL2_SRC2ALPHA			(7)

/*
	IMA8 instruction fields.
*/
#define EURASIA_USE1_IMA8_CMOD1_SHIFT				(24)
#define EURASIA_USE1_IMA8_CMOD1_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_IMA8_CMOD1_NONE				(0)
#define EURASIA_USE1_IMA8_CMOD1_COMPLEMENT			(1)

#define EURASIA_USE1_IMA8_CSEL0_SHIFT				(20)
#define EURASIA_USE1_IMA8_CSEL0_CLRMSK				(0xFFCFFFFFU)

#define EURASIA_USE1_IMA8_CSEL0_SRC0				(0)
#define EURASIA_USE1_IMA8_CSEL0_SRC1				(1)
#define EURASIA_USE1_IMA8_CSEL0_SRC0ALPHA			(2)
#define EURASIA_USE1_IMA8_CSEL0_SRC1ALPHA			(3)

#define EURASIA_USE1_IMA8_CMOD2_SHIFT				(15)
#define EURASIA_USE1_IMA8_CMOD2_CLRMSK				(0xFFFF7FFFU)

#define EURASIA_USE1_IMA8_CMOD2_NONE				(0)
#define EURASIA_USE1_IMA8_CMOD2_COMPLEMENT			(1)

#define EURASIA_USE1_IMA8_SAT						(0x00000800U)

#define EURASIA_USE1_IMA8_CMOD0_SHIFT				(10)
#define EURASIA_USE1_IMA8_CMOD0_CLRMSK				(0xFFFFFBFFU)

#define EURASIA_USE1_IMA8_CMOD0_NONE				(0)
#define EURASIA_USE1_IMA8_CMOD0_COMPLEMENT			(1)

#define EURASIA_USE1_IMA8_ASEL0_SHIFT				(9)
#define EURASIA_USE1_IMA8_ASEL0_CLRMSK				(0xFFFFFDFFU)

#define EURASIA_USE1_IMA8_ASEL0_SRC0ALPHA			(0)
#define EURASIA_USE1_IMA8_ASEL0_SRC1ALPHA			(1)

#define EURASIA_USE1_IMA8_AMOD2_SHIFT				(8)
#define EURASIA_USE1_IMA8_AMOD2_CLRMSK				(0xFFFFFEFFU)

#define EURASIA_USE1_IMA8_AMOD2_NONE				(0)
#define EURASIA_USE1_IMA8_AMOD2_COMPLEMENT			(1)

#define EURASIA_USE1_IMA8_AMOD1_SHIFT				(7)
#define EURASIA_USE1_IMA8_AMOD1_CLRMSK				(0xFFFFFF7FU)

#define EURASIA_USE1_IMA8_AMOD1_NONE				(0)
#define EURASIA_USE1_IMA8_AMOD1_COMPLEMENT			(1)

#define EURASIA_USE1_IMA8_AMOD0_SHIFT				(6)
#define EURASIA_USE1_IMA8_AMOD0_CLRMSK				(0xFFFFFFBFU)

#define EURASIA_USE1_IMA8_AMOD0_NONE				(0)
#define EURASIA_USE1_IMA8_AMOD0_COMPLEMENT			(1)

#define EURASIA_USE1_IMA8_CSEL1_SHIFT				(5)
#define EURASIA_USE1_IMA8_CSEL1_CLRMSK				(0xFFFFFFDFU)

#define EURASIA_USE1_IMA8_CSEL1_SRC1				(0)
#define EURASIA_USE1_IMA8_CSEL1_SRC1ALPHA			(1)

#define EURASIA_USE1_IMA8_CSEL2_SHIFT				(4)
#define EURASIA_USE1_IMA8_CSEL2_CLRMSK				(0xFFFFFFEFU)

#define EURASIA_USE1_IMA8_CSEL2_SRC2				(0)
#define EURASIA_USE1_IMA8_CSEL2_SRC2ALPHA			(1)

#define EURASIA_USE1_IMA8_NEGS0						(0x00000008U)

/*
	IMA16 instruction fields.
*/
#define EURASIA_USE1_IMA16_ABS						(0x01000000U)

#define EURASIA_USE1_IMA16_S2NEG					(0x00200000U)

#define EURASIA_USE1_IMA16_SEL1H_LOWER8				(0x00000000U)
#define EURASIA_USE1_IMA16_SEL1H_UPPER8				(0x00100000U)

#define EURASIA_USE1_IMA16_MODE_SHIFT				(10)
#define EURASIA_USE1_IMA16_MODE_CLRMSK				(0xFFFFF3FFU)

#define EURASIA_USE1_IMA16_MODE_UNSGNNOSAT			(0)
#define EURASIA_USE1_IMA16_MODE_UNSGNSAT			(1)
#define EURASIA_USE1_IMA16_MODE_SGNNOSAT			(2)
#define EURASIA_USE1_IMA16_MODE_SGNSAT				(3)

#define EURASIA_USE1_IMA16_S2FORM_SHIFT				(8)
#define EURASIA_USE1_IMA16_S2FORM_CLRMSK			(0xFFFFFCFFU)

#define EURASIA_USE1_IMA16_S1FORM_SHIFT				(6)
#define EURASIA_USE1_IMA16_S1FORM_CLRMSK			(0xFFFFFF3FU)

#define EURASIA_USE1_IMA16_SFORM_16BIT				(0)
#define EURASIA_USE1_IMA16_SFORM_8BITZEROEXTEND		(1)
#define EURASIA_USE1_IMA16_SFORM_8BITSGNEXTEND		(2)
#define EURASIA_USE1_IMA16_SFORM_8BITOFFSET			(3)

#define EURASIA_USE1_IMA16_SEL2H_LOWER8				(0x00000000U)
#define EURASIA_USE1_IMA16_SEL2H_UPPER8				(0x00000020U)

#define EURASIA_USE1_IMA16_ORSHIFT_SHIFT			(3)
#define EURASIA_USE1_IMA16_ORSHIFT_CLRMSK			(0xFFFFFFE7U)
#define EURASIA_USE1_IMA16_ORSHIFT_MAX				(3)

/*
	Extended integer multiply-add instruction fields.
*/
#define EURASIA_USE1_IMAE_SRC0H_SELECTLOW			(0x00000000U)
#define EURASIA_USE1_IMAE_SRC0H_SELECTHIGH			(0x01000000U)

#define EURASIA_USE1_IMAE_SRC1H_SELECTLOW			(0x00000000U)
#define EURASIA_USE1_IMAE_SRC1H_SELECTHIGH			(0x00200000U)

#define EURASIA_USE1_IMAE_SRC2H_SELECTLOW			(0x00000000U)
#define EURASIA_USE1_IMAE_SRC2H_SELECTHIGH			(0x00100000U)

#define EURASIA_USE1_IMAE_CISRC_SHIFT				(15)
#define EURASIA_USE1_IMAE_CISRC_CLRMSK				(0xFFFF7FFFU)

#define EURASIA_USE1_IMAE_CISRC_I0					(0)
#define EURASIA_USE1_IMAE_CISRC_I1					(1)
#define EURASIA_USE1_IMAE_CISRC_MAX					1

#define EURASIA_USE1_IMAE_SIGNED					(0x00000800U)

#define EURASIA_USE1_IMAE_SATURATE					(0x00000400U)

#define EURASIA_USE1_IMAE_CARRYINENABLE				(0x00000200U)

#define EURASIA_USE1_IMAE_CARRYOUTENABLE			(0x00000100U)

#define EURASIA_USE1_IMAE_SRC2TYPE_SHIFT			(6)
#define EURASIA_USE1_IMAE_SRC2TYPE_CLRMSK			(0xFFFFFF3FU)

#define EURASIA_USE1_IMAE_SRC2TYPE_16BITZEXTEND		(0)
#define EURASIA_USE1_IMAE_SRC2TYPE_16BITSEXTEND		(1)
#define EURASIA_USE1_IMAE_SRC2TYPE_32BIT			(2)
#define EURASIA_USE1_IMAE_SRC2TYPE_RESERVED			(3)

#define EURASIA_USE1_IMAE_ORSHIFT_SHIFT				(3)
#define EURASIA_USE1_IMAE_ORSHIFT_CLRMSK			(0xFFFFFFC7U)
#define EURASIA_USE1_IMAE_ORSHIFT_MAX				(7)

/*
	dot3/dot4 instruction fields.
*/
#define EURASIA_USE1_DOT34_OPSEL_SHIFT				(24)
#define EURASIA_USE1_DOT34_OPSEL_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_DOT34_OPSEL_DOT3				(0)
#define EURASIA_USE1_DOT34_OPSEL_DOT4				(1)

#define EURASIA_USE1_DOT34_ASEL1_SHIFT				(20)
#define EURASIA_USE1_DOT34_ASEL1_CLRMSK				(0xFFCFFFFFU)

#define EURASIA_USE1_DOT34_ASEL1_ZERO				(0)
#define EURASIA_USE1_DOT34_ASEL1_SRC1ALPHA			(1)
#define EURASIA_USE1_DOT34_ASEL1_SRC2ALPHA			(2)
#define EURASIA_USE1_DOT34_ASEL1_ONEWAY				(3)

#define EURASIA_USE1_DOT34_SRC2MOD_SHIFT			(15)
#define EURASIA_USE1_DOT34_SRC2MOD_CLRMSK			(0xFFFF7FFFU)

#define EURASIA_USE1_DOT34_SRC2MOD_NONE				(0)
#define EURASIA_USE1_DOT34_SRC2MOD_COMPLEMENT		(1)

#define EURASIA_USE1_DOT34_SRC1MOD_SHIFT			(11)
#define EURASIA_USE1_DOT34_SRC1MOD_CLRMSK			(0xFFFFF7FFU)

#define EURASIA_USE1_DOT34_SRC1MOD_NONE				(0)
#define EURASIA_USE1_DOT34_SRC1MOD_COMPLEMENT		(1)

#define EURASIA_USE1_DOT34_ASEL2_SHIFT				(9)
#define EURASIA_USE1_DOT34_ASEL2_CLRMSK				(0xFFFFF9FFU)

#define EURASIA_USE1_DOT34_ASEL2_ZERO				(0)
#define EURASIA_USE1_DOT34_ASEL2_SRC1ALPHA			(1)
#define EURASIA_USE1_DOT34_ASEL2_SRC2ALPHA			(2)
#define EURASIA_USE1_DOT34_ASEL2_FOURWAY			(3)

#define EURASIA_USE1_DOT34_CSCALE_SHIFT				(7)
#define EURASIA_USE1_DOT34_CSCALE_CLRMSK			(0xFFFFFE7FU)

#define EURASIA_USE1_DOT34_CSCALE_X1				(0)
#define EURASIA_USE1_DOT34_CSCALE_X2				(1)
#define EURASIA_USE1_DOT34_CSCALE_X4				(2)
#define EURASIA_USE1_DOT34_CSCALE_X8				(3)

#define EURASIA_USE1_DOT34_OFF						(0x00000040U)

#define EURASIA_USE1_DOT34_AOP_SHIFT				(4)
#define EURASIA_USE1_DOT34_AOP_CLRMSK				(0xFFFFFFCFU)

#define EURASIA_USE1_DOT34_AOP_ADD					(0)
#define EURASIA_USE1_DOT34_AOP_SUBTRACT				(1)
#define EURASIA_USE1_DOT34_AOP_INTERPOLATE1			(2)
#define EURASIA_USE1_DOT34_AOP_INTERPOLATE2			(3)

#define EURASIA_USE1_DOT34_AMOD2_SHIFT				(3)
#define EURASIA_USE1_DOT34_AMOD2_CLRMSK				(0xFFFFFFF7U)

#define EURASIA_USE1_DOT34_AMOD2_NONE				(0)
#define EURASIA_USE1_DOT34_AMOD2_COMPLEMENT			(1)

#define EURASIA_USE1_DOT34_AMOD1_SHIFT				(2)
#define EURASIA_USE1_DOT34_AMOD1_CLRMSK				(0xFFFFFFFBU)

#define EURASIA_USE1_DOT34_AMOD1_NONE				(0)
#define EURASIA_USE1_DOT34_AMOD1_COMPLEMENT			(1)

#define EURASIA_USE0_DOT34_ASCALE_SHIFT				(16)
#define EURASIA_USE0_DOT34_ASCALE_CLRMSK			(0xFFFCFFFFU)

#define EURASIA_USE0_DOT34_ASCALE_X1				(0)
#define EURASIA_USE0_DOT34_ASCALE_X2				(1)
#define EURASIA_USE0_DOT34_ASCALE_X4				(2)
#define EURASIA_USE0_DOT34_ASCALE_X8				(3)

#define EURASIA_USE0_DOT34_ASRC1MOD_SHIFT			(15)
#define EURASIA_USE0_DOT34_ASRC1MOD_CLRMSK			(0xFFFF7FFFU)

#define EURASIA_USE0_DOT34_ASRC1MOD_NONE			(0)
#define EURASIA_USE0_DOT34_ASRC1MOD_COMPLEMENT		(1)

/*
	adif/firv/bilin instructions fields.
*/
#define EURASIA_USE1_ADIFFIRVBILIN_OPSEL_SHIFT		(20)
#define EURASIA_USE1_ADIFFIRVBILIN_OPSEL_CLRMSK		(0xFFCFFFFFU)

#define EURASIA_USE1_ADIFFIRVBILIN_OPSEL_ADIF		(0)
#define EURASIA_USE1_ADIFFIRVBILIN_OPSEL_SSUM16		(1)
#define EURASIA_USE1_ADIFFIRVBILIN_OPSEL_BILIN		(2)
#define EURASIA_USE1_ADIFFIRVBILIN_OPSEL_FIRV		(3)

/*
	adif instruction fields.
*/
#define EURASIA_USE1_ADIF_SRC0H_SELECTLOW			(0x00000000U)
#define EURASIA_USE1_ADIF_SRC0H_SELECTHIGH			(0x00008000U)

#define EURASIA_USE1_ADIF_SUM						(0x00000040U)

/*
	firv instruction fields.
*/
#define EURASIA_USE1_FIRV_COEFADD					(0x01000000U)

#define EURASIA_USE1_FIRV_WBENABLE					(0x00008000U)

#define EURASIA_USE1_FIRV_SHIFTEN					(0x00000400U)

#define EURASIA_USE1_FIRV_SRCFORMAT_SHIFT			(8)
#define EURASIA_USE1_FIRV_SRCFORMAT_CLRMSK			(0xFFFFFCFFU)

#define EURASIA_USE1_FIRV_SRCFORMAT_U8				(0)
#define EURASIA_USE1_FIRV_SRCFORMAT_S8				(1)
#define EURASIA_USE1_FIRV_SRCFORMAT_O8				(2)
#define EURASIA_USE1_FIRV_SRCFORMAT_FIRVH			(3)

#define EURASIA_USE1_IREGSRC						(0x00000080U)

/*
	bilin instruction fields.
*/
#define EURASIA_USE1_BILIN_INTERLEAVED				(0x01000000U)

#define EURASIA_USE1_BILIN_RND						(0x00008000U)

#define EURASIA_USE1_BILIN_SRCCHANSEL_SHIFT			(11)
#define EURASIA_USE1_BILIN_SRCCHANSEL_CLRMSK		(0xFFFFF7FFU)
#define EURASIA_USE1_BILIN_SRCCHANSEL_01			(0)
#define EURASIA_USE1_BILIN_SRCCHANSEL_23			(1)

#define EURASIA_USE1_BILIN_DESTCHANSEL_SHIFT		(10)
#define EURASIA_USE1_BILIN_DESTCHANSEL_CLRMSK		(0xFFFFFBFFU)
#define EURASIA_USE1_BILIN_DESTCHANSEL_01			(0)
#define EURASIA_USE1_BILIN_DESTCHANSEL_23			(1)

#define EURASIA_USE1_BILIN_SRCFORMAT_SHIFT			(8)
#define EURASIA_USE1_BILIN_SRCFORMAT_CLRMSK			(0xFFFFFCFFU)

#define EURASIA_USE1_BILIN_SRCFORMAT_U8				(0)
#define EURASIA_USE1_BILIN_SRCFORMAT_S8				(1)
#define EURASIA_USE1_BILIN_SRCFORMAT_O8				(2)
#define EURASIA_USE1_BILIN_SRCFORMAT_RESERVED		(3)

/*
	firh instruction fields.
*/
#define EURASIA_USE1_FIRH_SOFFS_SHIFT				(24)
#define EURASIA_USE1_FIRH_SOFFS_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_FIRH_POFF_SHIFT				(20)
#define EURASIA_USE1_FIRH_POFF_CLRMSK				(0xFFCFFFFFU)
#define EURASIA_USE1_FIRH_POFF_MAX					(3)

#define EURASIA_USE1_FIRH_SOFFH_SHIFT				(14)
#define EURASIA_USE1_FIRH_SOFFH_CLRMSK				(0xFFFF3FFFU)

#define EURASIA_USE1_FIRH_RCOUNT_SHIFT				(12)
#define EURASIA_USE1_FIRH_RCOUNT_CLRMSK				(0xFFFFCFFFU)
#define EURASIA_USE1_FIRH_RCOUNT_MAX				(4)

#define EURASIA_USE1_FIRH_SOFFL_SHIFT				(10)
#define EURASIA_USE1_FIRH_SOFFL_CLRMSK				(0xFFFFF3FFU)

#define EURASIA_USE1_FIRH_SOFF_MAX					(15)
#define EURASIA_USE1_FIRH_SOFF_MIN					(-16)

#define EURASIA_USE1_FIRH_SRCFORMAT_SHIFT			(8)
#define EURASIA_USE1_FIRH_SRCFORMAT_CLRMSK			(0xFFFFFCFFU)

#define EURASIA_USE1_FIRH_SRCFORMAT_U8				(0)
#define EURASIA_USE1_FIRH_SRCFORMAT_S8				(1)
#define EURASIA_USE1_FIRH_SRCFORMAT_O8				(2)
#define EURASIA_USE1_FIRH_SRCFORMAT_RESERVED		(3)

#define EURASIA_USE1_FIRH_EDGEMODE_SHIFT			(6)
#define EURASIA_USE1_FIRH_EDGEMODE_CLRMSK			(0xFFFFFF3FU)

#define EURASIA_USE1_FIRH_EDGEMODE_REPLICATE		(0)
#define EURASIA_USE1_FIRH_EDGEMODE_MIRRORSINGLE		(1)
#define EURASIA_USE1_FIRH_EDGEMODE_MIRRORDOUBLE		(2)
#define EURASIA_USE1_FIRH_EDGEMODE_RESERVED			(3)

#define EURASIA_USE1_FIRH_COEFSEL_SHIFT				(3)
#define EURASIA_USE1_FIRH_COEFSEL_CLRMSK			(0xFFFFFFC7U)
#define EURASIA_USE1_FIRH_COEFSEL_MAX				(7)

/*
	firhh instruction fields.
*/
#define EURASIA_USE1_FIRHH_SOFFS_SHIFT				(24)
#define EURASIA_USE1_FIRHH_SOFFS_CLRMSK				(0xFEFFFFFFU)

#define EURASIA_USE1_FIRHH_POFF_SHIFT				(20)
#define EURASIA_USE1_FIRHH_POFF_CLRMSK				(0xFFCFFFFFU)
#define EURASIA_USE1_FIRHH_POFF_MAX					(3)

#define EURASIA_USE1_FIRHH_MOEPOFF					(0x00080000U)

#define EURASIA_USE1_FIRHH_RCOUNT_SHIFT				(12)
#define EURASIA_USE1_FIRHH_RCOUNT_CLRMSK			(0xFFFF8FFFU)
#define EURASIA_USE1_FIRHH_RCOUNT_MAX				(6)

#define EURASIA_USE1_FIRHH_SOFFL_SHIFT				(10)
#define EURASIA_USE1_FIRHH_SOFFL_CLRMSK				(0xFFFFF3FFU)

#define EURASIA_USE1_FIRHH_SOFF_MAX					(15)
#define EURASIA_USE1_FIRHH_SOFF_MIN					(-16)

#define EURASIA_USE1_FIRHH_SRCFORMAT_SHIFT			(8)
#define EURASIA_USE1_FIRHH_SRCFORMAT_CLRMSK			(0xFFFFFCFFU)

#define EURASIA_USE1_FIRHH_SRCFORMAT_U8				(0)
#define EURASIA_USE1_FIRHH_SRCFORMAT_S8				(1)
#define EURASIA_USE1_FIRHH_SRCFORMAT_O8				(2)
#define EURASIA_USE1_FIRHH_SRCFORMAT_RESERVED		(3)

#define EURASIA_USE1_FIRHH_EDGEMODE_SHIFT			(6)
#define EURASIA_USE1_FIRHH_EDGEMODE_CLRMSK			(0xFFFFFF3FU)

#define EURASIA_USE1_FIRHH_EDGEMODE_REPLICATE		(0)
#define EURASIA_USE1_FIRHH_EDGEMODE_MIRRORSINGLE	(1)
#define EURASIA_USE1_FIRHH_EDGEMODE_MIRRORDOUBLE	(2)
#define EURASIA_USE1_FIRHH_EDGEMODE_RESERVED		(3)

#define EURASIA_USE1_FIRHH_COEFSEL_SHIFT			(3)
#define EURASIA_USE1_FIRHH_COEFSEL_CLRMSK			(0xFFFFFFC7U)
#define EURASIA_USE1_FIRHH_COEFSEL_MAX				(7)

#define EURASIA_USE1_FIRHH_HIPRECISION				(0x00000004U)

#define EURASIA_USE1_FIRHH_SOFFH_SHIFT				(0)
#define EURASIA_USE1_FIRHH_SOFFH_CLRMSK				(0xFFFFFFFCU)

/*
	SSUM16
*/
#define EURASIA_USE1_SSUM16_ISEL_I0					(0x00000000U)
#define EURASIA_USE1_SSUM16_ISEL_I1					(0x00008000U)

#define EURASIA_USE1_SSUM16_RCOUNT_MAX				(4)

#define EURASIA_USE1_SSUM16_RMODE_SHIFT				(10)
#define EURASIA_USE1_SSUM16_RMODE_CLRMSK			(0xFFFFF3FFU)
#define EURASIA_USE1_SSUM16_RMODE_DOWN				(0)
#define EURASIA_USE1_SSUM16_RMODE_NEAREST			(1)
#define EURASIA_USE1_SSUM16_RMODE_UP				(2)
#define EURASIA_USE1_SSUM16_RMODE_RESERVED			(3)

#define EURASIA_USE1_SSUM16_IADD					(0x00000200U)

#define EURASIA_USE1_SSUM16_IDST					(0x00000100U)

#define EURASIA_USE1_SSUM16_SRCFORMAT_SHIFT			(7)
#define EURASIA_USE1_SSUM16_SRCFORMAT_CLRMSK		(0xFFFFFF7FU)
#define EURASIA_USE1_SSUM16_SRCFORMAT_U8			(0)
#define EURASIA_USE1_SSUM16_SRCFORMAT_S8			(1)

#define EURASIA_USE1_SSUM16_RSHIFT_SHIFT			(3)
#define EURASIA_USE1_SSUM16_RSHIFT_CLRMSK			(0xFFFFFF87U)
#define EURASIA_USE1_SSUM16_RSHIFT_MAX				(15)

#if defined(SGX_FEATURE_USE_32BIT_INT_MAD) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) 
/*
	Definitions for the IMA32 instruction.
*/
#include "sgxima32usedefs.h"
#endif /* defined(SGX_FEATURE_USE_32BIT_INT_MAD) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) */

/*
	Texture sampling instruction fields.
*/
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_SMP_NOSCHED					(0x00400000U)

#define EURASIA_USE1_SMP_CDIM_SHIFT					(10)
#define EURASIA_USE1_SMP_CDIM_CLRMSK				(0xFFFFF3FFU)
#define EURASIA_USE1_SMP_CDIM_U						(0)
#define EURASIA_USE1_SMP_CDIM_UV					(1)
#define EURASIA_USE1_SMP_CDIM_UVS					(2)
#define EURASIA_USE1_SMP_CDIM_RESERVED				(3)

#define EURASIA_USE1_SMP_LODM_SHIFT					(8)
#define EURASIA_USE1_SMP_LODM_CLRMSK				(0xFFFFFCFFU)
#define EURASIA_USE1_SMP_LODM_NONE					(0)
#define EURASIA_USE1_SMP_LODM_BIAS					(1)
#define EURASIA_USE1_SMP_LODM_REPLACE				(2)
#define EURASIA_USE1_SMP_LODM_GRADIENTS				(3)

#define EURASIA_USE1_SMP_CTYPE_SHIFT				(3)
#define EURASIA_USE1_SMP_CTYPE_CLRMSK				(0xFFFFFFE7U)
#define EURASIA_USE1_SMP_CTYPE_F32					(0)
#define EURASIA_USE1_SMP_CTYPE_F16					(1)
#define EURASIA_USE1_SMP_CTYPE_C10					(2)
#define EURASIA_USE1_SMP_CTYPE_RESERVED				(3)

#define EURASIA_USE1_SMP_DBANK_TEMP					(0x00000000U)
#define EURASIA_USE1_SMP_DBANK_PRIMATTR				(0x00000080U)
#define EURASIA_USE1_SMP_DBANK_CLRMSK				(0xFFFFFF7FU)

#define EURASIA_USE1_SMP_DRCSEL_SHIFT				(0)
#define EURASIA_USE1_SMP_DRCSEL_CLRMSK				(0xFFFFFFFCU)

#if defined(SGX_FEATURE_USE_SMP_REDUCEDREPEATCOUNT) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554)
/*
	Different repeat mask/count fields on some cores.
*/
#define EURASIA_USE1_SMP_RMSKCNT_SHIFT				(12)
#define EURASIA_USE1_SMP_RMSKCNT_CLRMSK				(0xFFFFCFFFU)
#define EURASIA_USE1_SMP_RMSKCNT_MAXCOUNT			(4)
#define EURASIA_USE1_SMP_RMSKCNT_MAXMASK			(3)
#endif /* defined(SGX_FEATURE_USE_SMP_REDUCEDREPEATCOUNT) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) */

/*
	Load/store instruction fields.
*/
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_LDST_NOSCHED					(0x00400000U)

#define EURASIA_USE1_LDST_MOEEXPAND					(0x00200000U)

#define EURASIA_USE1_LDST_BPCACHE					(0x00080000U)


#define EURASIA_USE1_LDST_AMODE_SHIFT				(10)
#define EURASIA_USE1_LDST_AMODE_CLRMSK				(0xFFFFF3FFU)

#define EURASIA_USE1_LDST_AMODE_ABSOLUTE			(0)
#define EURASIA_USE1_LDST_AMODE_LOCAL				(1)
#define EURASIA_USE1_LDST_AMODE_TILED				(2)
#define EURASIA_USE1_LDST_AMODE_RESERVED			(3)

#define EURASIA_USE1_LDST_IMODE_SHIFT				(8)
#define EURASIA_USE1_LDST_IMODE_CLRMSK				(0xFFFFFCFFU)

#define EURASIA_USE1_LDST_IMODE_NONE				(0)
#define EURASIA_USE1_LDST_IMODE_PRE					(1)
#define EURASIA_USE1_LDST_IMODE_POST				(2)
#define EURASIA_USE1_LDST_IMODE_RESERVED			(3)

#define EURASIA_USE1_LDST_DBANK_TEMP				(0x00000000U)
#define EURASIA_USE1_LDST_DBANK_PRIMATTR			(0x00000080U)
#define EURASIA_USE1_LDST_DBANK_CLRMSK				(0xFFFFFF7FU)

#define EURASIA_USE1_LDST_RANGEENABLE				(0x00000040U)

#define EURASIA_USE1_LDST_DTYPE_SHIFT				(4)
#define EURASIA_USE1_LDST_DTYPE_CLRMSK				(0xFFFFFFCFU)

#define EURASIA_USE1_LDST_DTYPE_32BIT				(0)
#define EURASIA_USE1_LDST_DTYPE_16BIT				(1)
#define EURASIA_USE1_LDST_DTYPE_8BIT				(2)
#define EURASIA_USE1_LDST_DTYPE_RESERVED			(3)

#define EURASIA_USE1_LDST_INCSGN					(0x00000008U)

#define EURASIA_USE1_LDST_FCLFILL					(0x00000002U)

#define EURASIA_USE1_LDST_DRCSEL_SHIFT				(0)
#define EURASIA_USE1_LDST_DRCSEL_CLRMSK				(0xFFFFFFFEU)

#define EURASIA_USE_LDST_MAX_IMM_LOCAL_STRIDE		(14)
#define EURASIA_USE_LDST_MAX_IMM_LOCAL_OFFSET		(15)
#define EURASIA_USE_LDST_MAX_IMM_ABSOLUTE_OFFSET	(127)

#define EURASIA_USE_LDST_IMM_LOCAL_STRIDE_CLRMSK	(0xFFFFFF8FU)
#define EURASIA_USE_LDST_IMM_LOCAL_STRIDE_SHIFT		(4)
#define EURASIA_USE_LDST_IMM_LOCAL_STRIDE_GRAN		(2U)

#define EURASIA_USE_LDST_IMM_LOCAL_OFFSET_CLRMSK	(0xFFFFFFF0U)
#define EURASIA_USE_LDST_IMM_LOCAL_OFFSET_SHIFT		(0)

#define EURASIA_USE_LDST_NONIMM_LOCAL_OFFSET_CLRMSK	(0xFFFF0000U)
#define EURASIA_USE_LDST_NONIMM_LOCAL_OFFSET_SHIFT	(0)

#define EURASIA_USE_LDST_NONIMM_LOCAL_STRIDE_CLRMSK	(0x0000FFFFU)
#define EURASIA_USE_LDST_NONIMM_LOCAL_STRIDE_SHIFT	(16)

/* The maximum value for the range check parameter (in bytes) */
#define EURASIA_USE_LDST_MAXIMUM_RANGE				(0x7FFFFFFFU)

#if defined(SGX_FEATURE_USE_LDST_EXTENDED_CACHE_MODES) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) 
/*
	Extended cache modes for the LD/ST instruction.
*/
#define EURASIA_USE1_LDST_DCCTLEXT					(0x00080000)

#define EURASIA_USE1_LDST_DCCTL_STDNORMAL			(0x00000000)
#define EURASIA_USE1_LDST_DCCTL_STDBYPASSL1L2		(0x00000002)
#define EURASIA_USE1_LDST_DCCTL_EXTFCFILL			(0x00000000)
#define EURASIA_USE1_LDST_DCCTL_EXTBYPASSL1			(0x00000002)
#endif /* #if defined(SGX_FEATURE_USE_LDST_EXTENDED_CACHE_MODES) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) */

/*
	Special instruction fields.
*/
#define EURASIA_USE1_SPECIAL_OPCAT_SHIFT			(20)
#define EURASIA_USE1_SPECIAL_OPCAT_CLRMSK			(0xFFCFFFFFU)

#define EURASIA_USE1_SPECIAL_OPCAT_FLOWCTRL			(0)
#define EURASIA_USE1_SPECIAL_OPCAT_MOECTRL			(1)
#define EURASIA_USE1_SPECIAL_OPCAT_OTHER			(2)
#define EURASIA_USE1_SPECIAL_OPCAT_VISTEST			(3)

/*
	If OPCAT == EURASIA_USE1_SPECIAL_OPCAT_FLOWCTRL and this flag
	is set then use the OTHER2 opcodes.
*/
#define EURASIA_USE1_SPECIAL_OPCAT_EXTRA			(0x00400000)

/*
	New special OPCAT values.
*/
#define EURASIA_USE1_SPECIAL_OPCAT_OTHER2			(0)

#define EURASIA_USE1_OTHER2_OP2_CLRMSK				(0xF8FFFFFFU)
#define EURASIA_USE1_OTHER2_OP2_SHIFT				(24)

#if defined(SGX_FEATURE_USE_UNLIMITED_PHASES) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) 
/*
	Definitions for the PHAS instruction.
*/
#include "sgxphasusedefs.h"
#endif /* defined(SGX_FEATURE_USE_UNLIMITED_PHASES) || defined(SUPPORT_SGX543) || defined(SUPPORT_SGX544) || defined(SUPPORT_SGX545) || defined(SUPPORT_SGX554) */

/* Flow-control instruction fields */
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_FLOWCTRL_NOSCHED				(0x00000800U)

#define EURASIA_USE1_FLOWCTRL_SYNCEND				(0x00800000U)

#if defined(SUPPORT_SGX_FEATURE_USE_BRANCH_EXTSYNCEND) || defined(SGX_FEATURE_USE_BRANCH_EXTSYNCEND)
#define EURASIA_USE1_FLOWCTRL_SYNCEXT				(0x00001000)
#endif /* defined(SUPPORT_SGX_FEATURE_USE_BRANCH_EXTSYNCEND) || defined(SGX_FEATURE_USE_BRANCH_EXTSYNCEND) */

#if defined(SUPPORT_SGX_FEATURE_USE_BRANCH_EXCEPTION) || defined(SGX_FEATURE_USE_BRANCH_EXCEPTION)
#define EURASIA_USE1_FLOWCTRL_EXCEPTION				(0x00080000)
#endif /* defined(SUPPORT_SGX_FEATURE_USE_BRANCH_EXCEPTION) || defined(SGX_FEATURE_USE_BRANCH_EXCEPTION) */

#define EURASIA_USE1_FLOWCTRL_OP2_SHIFT				(6)
#define EURASIA_USE1_FLOWCTRL_OP2_CLRMSK			(0xFFFFFE3FU)

#define EURASIA_USE1_FLOWCTRL_OP2_BA				(0)
#define EURASIA_USE1_FLOWCTRL_OP2_BR				(1)
#define EURASIA_USE1_FLOWCTRL_OP2_LAPC				(2)
#define EURASIA_USE1_FLOWCTRL_OP2_SETL				(3)
#define EURASIA_USE1_FLOWCTRL_OP2_SAVL				(4)
#define EURASIA_USE1_FLOWCTRL_OP2_NOP				(5)
#define EURASIA_USE1_FLOWCTRL_OP2_RESERVED2			(6)
#define EURASIA_USE1_FLOWCTRL_OP2_RESERVED3			(7)

/* Nop instruction fields. */
#define EURASIA_USE1_FLOWCTRL_NOP_SYNCS				(0x00800000U)
#define EURASIA_USE0_FLOWCTRL_NOP_TOGGLEOUTFILES	(0x00000001U)

#if defined(SUPPORT_SGX_FEATURE_USE_NOPTRIGGER) || defined(SGX_FEATURE_USE_NOPTRIGGER)
#define EURASIA_USE0_FLOWCTRL_NOP_TRIGGER			(0x00000002)
#endif /* defined(SUPPORT_SGX_FEATURE_USE_NOPTRIGGER) || defined(SGX_FEATURE_USE_NOPTRIGGER) */

/* Branch absolute/relative instruction fields */
#define SGX545_USE1_BRANCH_MONITOR					(0x00000400U)
#define EURASIA_USE1_BRANCH_SAVELINK				(0x00000200U)

#define EURASIA_USE0_BRANCH_OFFSET_SHIFT			(0)
#define EURASIA_USE0_BRANCH_OFFSET_CLRMSK			(~((1UL << SGX_FEATURE_USE_NUMBER_PC_BITS) - 1))

/* Link register manipulation instruction fields. */

#define EURASIA_USE1_OTHER2_OP2_CFI					(0)
#define EURASIA_USE1_OTHER2_OP2_RESERVED			(1)

/* Cache flush instruction. */
#define EURASIA_USE1_OTHER2_CFI_GLOBAL				(0x00008000)
#define EURASIA_USE1_OTHER2_CFI_DM_NOMATCH			(0x00004000)
#define EURASIA_USE1_OTHER2_CFI_FLUSH				(0x00002000)
#define EURASIA_USE1_OTHER2_CFI_INVALIDATE			(0x00001000)

#define EURASIA_USE1_OTHER2_CFI_LEVEL_CLRMSK		(0xFFFFFCFFU)
#define EURASIA_USE1_OTHER2_CFI_LEVEL_SHIFT			(8)
#define EURASIA_USE1_OTHER2_CFI_LEVEL_RESERVED		(0)
#define EURASIA_USE1_OTHER2_CFI_LEVEL_L0L1			(1)
#define EURASIA_USE1_OTHER2_CFI_LEVEL_L2			(2)
#define EURASIA_USE1_OTHER2_CFI_LEVEL_L0L1L2		(3)
#define EURASIA_USE1_OTHER2_CFI_LEVEL_MAX			(3)

#define EURASIA_USE_OTHER2_CFI_DATAMASTER_VERTEX	(0)
#define EURASIA_USE_OTHER2_CFI_DATAMASTER_PIXEL		(1)
#define EURASIA_USE_OTHER2_CFI_DATAMASTER_RESERVED	(2)
#define EURASIA_USE_OTHER2_CFI_DATAMASTER_EVENT		(3)

/* MOE control instruction fields. */
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_MOECTRL_NOSCHED				(0x00040000U)

#define EURASIA_USE1_MOECTRL_REGDAT					(0x00080000U)

#define EURASIA_USE1_MOECTRL_OP2_SHIFT				(24)
#define EURASIA_USE1_MOECTRL_OP2_CLRMSK				(0xF8FFFFFFU)

#define EURASIA_USE1_MOECTRL_OP2_SMOA				(0)
#define EURASIA_USE1_MOECTRL_OP2_SMR				(1)
#define EURASIA_USE1_MOECTRL_OP2_SMLSI				(2)
#define EURASIA_USE1_MOECTRL_OP2_SMBO				(3)
#define EURASIA_USE1_MOECTRL_OP2_IMO				(4)
#define EURASIA_USE1_MOECTRL_OP2_SETFC				(5)

#define EURASIA_USE0_MOECTRL_SMOA_S2OFFSET_SHIFT	(0)
#define EURASIA_USE0_MOECTRL_SMOA_S2OFFSET_CLRMSK	(0xFFFFFC00U)

#define EURASIA_USE0_MOECTRL_SMOA_S1OFFSET_SHIFT	(10)
#define EURASIA_USE0_MOECTRL_SMOA_S1OFFSET_CLRMSK	(0xFFF003FFU)

#define EURASIA_USE0_MOECTRL_SMOA_S0OFFSET_SHIFT	(20)
#define EURASIA_USE0_MOECTRL_SMOA_S0OFFSET_CLRMSK	(0xC00FFFFFU)

#define EURASIA_USE0_MOECTRL_SMOA_DOFFSET_SHIFT		(30)
#define EURASIA_USE0_MOECTRL_SMOA_DOFFSET_CLRMSK	(0x3FFFFFFFU)

#define EURASIA_USE1_MOECTRL_SMOA_DOFFSET_SHIFT		(0)
#define EURASIA_USE1_MOECTRL_SMOA_DOFFSET_CLRMSK	(0xFFFFFF00U)

#define EURASIA_USE1_MOECTRL_SMOA_S2AM_SHIFT		(8)
#define EURASIA_USE1_MOECTRL_SMOA_S2AM_CLRMSK		(0xFFFFFCFFU)

#define EURASIA_USE1_MOECTRL_SMOA_S1AM_SHIFT		(10)
#define EURASIA_USE1_MOECTRL_SMOA_S1AM_CLRMSK		(0xFFFFF3FFU)

#define EURASIA_USE1_MOECTRL_SMOA_S0AM_SHIFT		(12)
#define EURASIA_USE1_MOECTRL_SMOA_S0AM_CLRMSK		(0xFFFFCFFFU)

#define EURASIA_USE1_MOECTRL_SMOA_DAM_SHIFT			(14)
#define EURASIA_USE1_MOECTRL_SMOA_DAM_CLRMSK		(0xFFFF3FFFU)

#define EURASIA_USE1_MOECTRL_ADDRESSMODE_NONE		(0)
#define EURASIA_USE1_MOECTRL_ADDRESSMODE_REPEAT		(1)
#define EURASIA_USE1_MOECTRL_ADDRESSMODE_CLAMP		(2)
#define EURASIA_USE1_MOECTRL_ADDRESSMODE_MIRROR		(3)

#define EURASIA_USE0_MOECTRL_SMLSI_S2INC_SHIFT		(0)
#define EURASIA_USE0_MOECTRL_SMLSI_S2INC_CLRMSK		(0xFFFFFF00U)

#define EURASIA_USE0_MOECTRL_SMLSI_S1INC_SHIFT		(8)
#define EURASIA_USE0_MOECTRL_SMLSI_S1INC_CLRMSK		(0xFFFF00FFU)

#define EURASIA_USE0_MOECTRL_SMLSI_S0INC_SHIFT		(16)
#define EURASIA_USE0_MOECTRL_SMLSI_S0INC_CLRMSK		(0xFF00FFFFU)

#define EURASIA_USE0_MOECTRL_SMLSI_DINC_SHIFT		(24)
#define EURASIA_USE0_MOECTRL_SMLSI_DINC_CLRMSK		(0x00FFFFFFU)

#define EURASIA_USE0_MOECTRL_SMLSI_INC_MIN			(-128)
#define EURASIA_USE0_MOECTRL_SMLSI_INC_MAX			(127)

#define EURASIA_USE0_MOECTRL_SMLSI_SWIZ_MAX			(255)

#define EURASIA_USE1_MOECTRL_SMLSI_S2USESWIZ		(0x00000001U)
#define EURASIA_USE1_MOECTRL_SMLSI_S1USESWIZ		(0x00000002U)
#define EURASIA_USE1_MOECTRL_SMLSI_S0USESWIZ		(0x00000004U)
#define EURASIA_USE1_MOECTRL_SMLSI_DUSESWIZ			(0x00000008U)

#define EURASIA_USE1_MOECTRL_SMLSI_SLIMIT_SHIFT		(4)
#define EURASIA_USE1_MOECTRL_SMLSI_SLIMIT_CLRMSK	(0xFFFFFF0FU)

#define EURASIA_USE1_MOECTRL_SMLSI_PLIMIT_SHIFT		(8)
#define EURASIA_USE1_MOECTRL_SMLSI_PLIMIT_CLRMSK	(0xFFFFF0FFU)

#define EURASIA_USE1_MOECTRL_SMLSI_TLIMIT_SHIFT		(12)
#define EURASIA_USE1_MOECTRL_SMLSI_TLIMIT_CLRMSK	(0xFFFF0FFFU)

#define EURASIA_USE1_MOECTRL_SMLSI_LIMIT_MAX		(60)
#define EURASIA_USE1_MOECTRL_SMLSI_LIMIT_GRAN		(4)

#define EURASIA_USE_MOESWIZZLE_FIELD_SIZE			(2)
#define EURASIA_USE_MOESWIZZLE_VALUE_MASK			(3)

#define EURASIA_USE0_MOECTRL_SMR_S2RANGE_SHIFT		(0)
#define EURASIA_USE0_MOECTRL_SMR_S2RANGE_CLRMSK		(0xFFFFF000U)

#define EURASIA_USE0_MOECTRL_SMR_S1RANGE_SHIFT		(12)
#define EURASIA_USE0_MOECTRL_SMR_S1RANGE_CLRMSK		(0xFF000FFFU)

#define EURASIA_USE0_MOECTRL_SMR_S0RANGE_SHIFT		(24)
#define EURASIA_USE0_MOECTRL_SMR_S0RANGE_CLRMSK		(0x00FFFFFFU)

#define EURASIA_USE1_MOECTRL_SMR_S0RANGE_SHIFT		(0)
#define EURASIA_USE1_MOECTRL_SMR_S0RANGE_CLRMSK		(0xFFFFFFF0U)

#define EURASIA_USE1_MOECTRL_SMR_DRANGE_SHIFT		(4)
#define EURASIA_USE1_MOECTRL_SMR_DRANGE_CLRMSK		(0xFFFF000FU)

#define EURASIA_USE1_MOECTRL_IMO_INC_MIN			(-32)
#define EURASIA_USE1_MOECTRL_IMO_INC_MAX			(31)

#define EURASIA_USE1_MOECTRL_OFFSETRANGE_MAX		(4095)

#define EURASIA_USE0_MOECTRL_SETFC_EFO_SELFMTCTL	(0x00000001U)
#define EURASIA_USE0_MOECTRL_SETFC_COL_SETFMTCTL	(0x00000100U)

/* Other special instruction fields */
#define EURASIA_USE1_OTHER_OP2_SHIFT				(24)
#define EURASIA_USE1_OTHER_OP2_CLRMSK				(0xF8FFFFFFU)

#define EURASIA_USE1_OTHER_OP2_IDF					(0)
#define EURASIA_USE1_OTHER_OP2_WDF					(1)
#define SGX545_USE1_OTHER_OP2_SETM					(2)
#define EURASIA_USE1_OTHER_OP2_EMIT					(3)
#define EURASIA_USE1_OTHER_OP2_LIMM					(4)
#define EURASIA_USE1_OTHER_OP2_LOCKRELEASE			(5)
#define EURASIA_USE1_OTHER_OP2_LDRSTR				(6)
#define EURASIA_USE1_OTHER_OP2_WOP					(7)

/* IDF/WDF instruction fields. */
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_IDFWDF_NOSCHED					(0x00000800U)

#define EURASIA_USE1_IDFWDF_DRCSEL_SHIFT			(0)
#define EURASIA_USE1_IDFWDF_DRCSEL_CLRMSK			(0xFFFFFFFCU)

#define EURASIA_USE1_IDF_PATH_SHIFT					(14)
#define EURASIA_USE1_IDF_PATH_CLRMSK				(0xFFFF3FFFU)

#define EURASIA_USE1_IDF_PATH_ST					(0)
#define EURASIA_USE1_IDF_PATH_PIXELBE				(1)
#define EURASIA_USE1_IDF_PATH_RESERVED0				(2)
#define EURASIA_USE1_IDF_PATH_RESERVED1				(3)

/* EMIT instruction fields. */
#define EURASIA_USE1_EMIT_SIDEBAND_109_108_SHIFT	(22)
#define EURASIA_USE1_EMIT_SIDEBAND_109_108_CLRMSK	(0xFF3FFFFFU)

#define EURASIA_USE1_EMIT_SIDEBAND_205_204_SHIFT	(22)
#define EURASIA_USE1_EMIT_SIDEBAND_205_204_CLRMSK	(0xFF3FFFFFU)


#define EURASIA_USE1_EMIT_S0BEXT					(0x00080000U)

#define EURASIA_USE1_EMIT_TARGET_SHIFT				(14)
#define EURASIA_USE1_EMIT_TARGET_CLRMSK				(0xFFFF3FFFU)
#define EURASIA_USE1_EMIT_TARGET_PIXELBE			(0)
#define EURASIA_USE1_EMIT_TARGET_MTE				(1)
#define EURASIA_USE1_EMIT_TARGET_PDS				(2)

#define EURASIA_USE1_EMIT_MTECTRL_SHIFT				(12)
#define EURASIA_USE1_EMIT_MTECTRL_CLRMSK			(0xFFFFCFFFU)
#define EURASIA_USE1_EMIT_MTECTRL_STATE				(0)
#define EURASIA_USE1_EMIT_MTECTRL_VERTEX			(1)
#define EURASIA_USE1_EMIT_MTECTRL_PRIMITIVE			(2)

#define EURASIA_USE1_EMIT_PDSCTRL_TASKS				(0x00002000U)
#define EURASIA_USE1_EMIT_PDSCTRL_TASKE				(0x00001000U)

/* Only valid for cores with the enhanced nosched feature. */
#define EURASIA_USE1_EMIT_NOSCHED					(0x00000800U)

#define EURASIA_USE1_EMIT_SIDEBAND_107_102_SHIFT	(3)
#define EURASIA_USE1_EMIT_SIDEBAND_107_102_CLRMSK	(0xFFFFFE07U)

#define EURASIA_USE1_EMIT_SIDEBAND_203_198_SHIFT	(3)
#define EURASIA_USE1_EMIT_SIDEBAND_203_198_CLRMSK	(0xFFFFFE07U)

#define EURASIA_USE1_EMIT_INCP_SHIFT				(0)
#define EURASIA_USE1_EMIT_INCP_CLRMSK				(0xFFFFFFFCU)
#define EURASIA_USE1_EMIT_INCP_MAX					(3)

#define EURASIA_USE0_EMIT_S1BANK_SHIFT				(30)
#define EURASIA_USE0_EMIT_S1BANK_CLRMSK				(0x3FFFFFFFU)

#define EURASIA_USE0_EMIT_S2BANK_SHIFT				(28)
#define EURASIA_USE0_EMIT_S2BANK_CLRMSK				(0xCFFFFFFFU)

#define EURASIA_USE0_EMIT_FREEP						(0x00200000U)

#define EURASIA_USE0_EMIT_SIDEBAND_101_96_SHIFT		(22)
#define EURASIA_USE0_EMIT_SIDEBAND_101_96_CLRMSK	(0xF03FFFFFU)

#define EURASIA_USE0_EMIT_SIDEBAND_197_192_SHIFT	(22)
#define EURASIA_USE0_EMIT_SIDEBAND_197_192_CLRMSK	(0xF03FFFFFU)

#define EURASIA_USE0_EMIT_SRC0_SHIFT				(14)
#define EURASIA_USE0_EMIT_SRC0_CLRMSK				(0xFFE03FFFU)

#define EURASIA_USE0_EMIT_SRC1_SHIFT				(7)
#define EURASIA_USE0_EMIT_SRC1_CLRMSK				(0xFFFFC07FU)

#define EURASIA_USE0_EMIT_SRC2_SHIFT				(0)
#define EURASIA_USE0_EMIT_SRC2_CLRMSK				(0xFFFFFF80U)

/*
	Pixel backend emit fields.
*/

#define EURASIA_PIXELBE_NUM_STATE_DWORDS 8

/*
	Placeholder for unknown formats, not a valid mode.
*/
#define EURASIA_PIXELBE_PACKMODE_NONE (0xFFFFFFFF)

#if defined(SGX_FEATURE_UNIFIED_STORE_64BITS)

	/*
	 * Emit Instruction Word Sideband Data
	 */
	#define EURASIA_PIXELBESB_GAMMACORRECT_SHIFT				(12)
	#define EURASIA_PIXELBESB_GAMMACORRECT						(1UL << EURASIA_PIXELBESB_GAMMACORRECT_SHIFT)

	#define EURASIA_PIXELBESB_GAMMACORRECT_CLRMSK				(0xFFFFCFFFU)

	#define EURASIA_PIXELBESB_GAMMACORRECT_NONE					(0UL << EURASIA_PIXELBESB_GAMMACORRECT_SHIFT)
	#define EURASIA_PIXELBESB_GAMMACORRECT_R					(1UL << EURASIA_PIXELBESB_GAMMACORRECT_SHIFT)
	#define EURASIA_PIXELBESB_GAMMACORRECT_GR					(3UL << EURASIA_PIXELBESB_GAMMACORRECT_SHIFT)

	#define EURASIA_PIXELBESB_SRCSEL_SHIFT						(6)
	#define EURASIA_PIXELBESB_SRCSEL_CLRMSK						(0xFFFFFE3FU)

	#define EURASIA_PIXELBESB_DITHER							(1UL << 3)

	#define EURASIA_PIXELBESB_TILERELATIVE						(1UL << 2)

	#define EURASIA_PIXELBESB_SCALE_SHIFT						(0)
	#define EURASIA_PIXELBESB_SCALE_CLRMSK						(0xFFFFFFFCU)

	#define EURASIA_PIXELBESB_SCALE_NONE						(0)
	#define EURASIA_PIXELBESB_SCALE_AA							(1)
	#define EURASIA_PIXELBESB_SCALE_UPSCALE						(2)
	#define EURASIA_PIXELBESB_SCALE_AAUPSCALE					(3)

	/*
	 * Emit Instruction Word Src0 Low 32 Bits
	 */
	#define EURASIA_PIXELBES0LO_OOFF_SHIFT						(0)
#if defined(FIX_HW_BRN_29602)
	#define EURASIA_PIXELBES0LO_OOFF_CLRMSK						(0xFFFFFF80U)
#else
	#define EURASIA_PIXELBES0LO_OOFF_CLRMSK						(0xFFFFFF00U)
#endif

	#define EURASIA_PIXELBES0LO_COUNT_SHIFT						(8)
	#define EURASIA_PIXELBES0LO_COUNT_CLRMSK					(0xFFFE00FFU)

	#define EURASIA_PIXELBES0LO_SWIZ_SHIFT						(20)
	#define EURASIA_PIXELBES0LO_SWIZ_CLRMSK						(0xFFCFFFFFU)

	/* Swizzle order for data passed from USSE to PBE, order is high to low */
	/* 4 channel pack mode */
	#define EURASIA_PIXELBES0LO_SWIZ_ABGR						(0UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_ARGB						(1UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_RGBA						(2UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_BGRA						(3UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)

	/* 3 channel pack mode */
	#define EURASIA_PIXELBES0LO_SWIZ_BGR						(0UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_RGB						(1UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)

	/* 2 channel pack mode */
	#define EURASIA_PIXELBES0LO_SWIZ_GR							(0UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_RG							(1UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_RA							(2UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_AR							(3UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)

	/* 1 channel pack mode */
	#define EURASIA_PIXELBES0LO_SWIZ_R							(0UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)
	#define EURASIA_PIXELBES0LO_SWIZ_A							(1UL << EURASIA_PIXELBES0LO_SWIZ_SHIFT)

	/* Pack mode extend control */
	#define EURASIA_PIXELBES0LO_PMODEEXT_SHIFT					(23)
	#define EURASIA_PIXELBES0LO_PMODEEXT_CLRMSK					(0xFE7FFFFFU)

	#define EURASIA_PIXELBES0LO_PMODEEXT_MODE0					(0UL << EURASIA_PIXELBES0LO_PMODEEXT_SHIFT)
	#define EURASIA_PIXELBES0LO_PMODEEXT_MODE1					(1UL << EURASIA_PIXELBES0LO_PMODEEXT_SHIFT)
	#define EURASIA_PIXELBES0LO_PMODEEXT_MODE2					(2UL << EURASIA_PIXELBES0LO_PMODEEXT_SHIFT)

	#define EURASIA_PIXELBES0LO_SRCFORM_F16						(1UL << 25)

	#define EURASIA_PIXELBES0LO_MEMLAYOUT_SHIFT					(26)
	#define EURASIA_PIXELBES0LO_MEMLAYOUT_CLRMSK				(0xF3FFFFFFU)

	#define EURASIA_PIXELBES0LO_MEMLAYOUT_LINEAR				(0)
	#define EURASIA_PIXELBES0LO_MEMLAYOUT_TILED					(1)
	#define EURASIA_PIXELBES0LO_MEMLAYOUT_TWIDDLED				(2)
	#define EURASIA_PIXELBES0LO_MEMLAYOUT_RESERVED				(3)

	#define EURASIA_PIXELBES0LO_PACKMODE_SHIFT					(28)
	#define EURASIA_PIXELBES0LO_PACKMODE_CLRMSK					(0x0FFFFFFFU)

	#define EURASIA_PIXELBES0LO_PACKMODE_U8888					(0UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_U888					(1UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_RESERVED				(2UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_R5G6B5					(3UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_A1R5G5B5				(4UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_A4R4G4B4				(5UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_A8R3G3B2				(6UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_MONO16					(7UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_MONO8					(8UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_PBYTE					(9UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_PWORD					(10UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_PT1					(11UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_PT2					(12UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_PT4					(13UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_PT8					(14UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)
	#define EURASIA_PIXELBES0LO_PACKMODE_F16					(15UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT)

	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_F16F16		((0UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_F32			((1UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_S16			((2UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_S16S16		((3UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_U16			((4UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_U16U16		((5UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_U2101010		((6UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_S2101010		((7UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_U8			((8UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_S8			((9UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_R5SG5SB6		((10UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_U88			((11UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_S88			((12UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_X8U8S8S8		((13UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE1_S8888			((14UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE1)

	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE2_F16F16F16F16	((0UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE2)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE2_F32F32		((1UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE2)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE2_F11F11F10		((2UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE2)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE2_SE5M9M9M9		((3UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE2)
	#define EURASIA_PIXELBES0LO_PACKMODE_EXTMODE2_A2F10F10F10	((4UL << EURASIA_PIXELBES0LO_PACKMODE_SHIFT) | EURASIA_PIXELBES0LO_PMODEEXT_MODE2)


	/*
	 * Emit Instruction Word Src0 High 32 Bits
	 */
	#define EURASIA_PIXELBES0HI_ROTATE_SHIFT					(0)
	#define EURASIA_PIXELBES0HI_ROTATE_CLRMSK					(0xFFFFFFFCU)

	#define EURASIA_PIXELBES0HI_ROTATE_0DEG						(0)
	#define EURASIA_PIXELBES0HI_ROTATE_90DEG					(1)
	#define EURASIA_PIXELBES0HI_ROTATE_180DEG					(2)
	#define EURASIA_PIXELBES0HI_ROTATE_270DEG					(3)

	#define EURASIA_PIXELBES0HI_FBADDR_SHIFT					(2)
	#define EURASIA_PIXELBES0HI_FBADDR_CLRMSK					(0x00000003U)
	#define EURASIA_PIXELBE_FBADDR_ALIGNSHIFT					(2)


	/*
	 * Emit Instruction Word Src1 Low 32 Bits
	 */
	#define EURASIA_PIXELBES1LO_LINESTRIDE_SHIFT				(0)
	#define EURASIA_PIXELBES1LO_LINESTRIDE_CLRMSK				(0xFFFFC000U)
	#define EURASIA_PIXELBE_LINESTRIDE_ALIGNSHIFT				(1)


	/*
	 * Emit Instruction Word Src1 High 32 Bits: Empty
	 */

	/*
	 * Emit Instruction Word Src2 Low 32 Bits
	 */
	#define EURASIA_PIXELBES2LO_XMIN_SHIFT						(0)
	#define EURASIA_PIXELBES2LO_XMIN_CLRMSK						(0xFFFFF000U)

	#define EURASIA_PIXELBES2LO_YMIN_SHIFT						(12)
	#define EURASIA_PIXELBES2LO_YMIN_CLRMSK						(0xFF000FFFU)

	#define EURASIA_PIXELBES2LO_XSIZE_SHIFT						(24)
	#define EURASIA_PIXELBES2LO_XSIZE_CLRMSK					(0xF0FFFFFFU)

	#define EURASIA_PIXELBES2LO_XSIZE_ALIGN						(16)
	#define EURASIA_PIXELBES2LO_XSIZE_ALIGNSHIFT				(4)

	#define EURASIA_PIXELBES2LO_YSIZE_SHIFT						(28)
	#define EURASIA_PIXELBES2LO_YSIZE_CLRMSK					(0x0FFFFFFFU)

	#define EURASIA_PIXELBES2LO_YSIZE_ALIGN						(16)
	#define EURASIA_PIXELBES2LO_YSIZE_ALIGNSHIFT				(4)

	/*
	 * Emit Instruction Word Src2 High 32 Bits
	 */
	#define EURASIA_PIXELBES2HI_XMAX_SHIFT						(0)
	#define EURASIA_PIXELBES2HI_XMAX_CLRMSK						(0xFFFFF000U)

	#define EURASIA_PIXELBES2HI_YMAX_SHIFT						(12)
	#define EURASIA_PIXELBES2HI_YMAX_CLRMSK						(0xFF000FFFU)

	#define EURASIA_PIXELBES2HI_NOADVANCE						(1UL << 31)
	#define EURASIA_PIXELBES2HI_NOADVANCE_MASK					(0x7FFFFFFFU)

	/* Dummy to help useasm */
	#define EURASIA_PIXELBE1SB_TWOEMITS							 0

#else /* SGX_FEATURE_UNIFIED_STORE_64BITS */

/** [Emit 2] Instruction Word Sideband Data */

#define EURASIA_PIXELBE2SB_SRCSEL_SHIFT				(6)
#define EURASIA_PIXELBE2SB_SRCSEL_CLRMSK			(0xFFFFFE3FU)

#if defined(SGX545)
	#define EURASIA_PIXELBE2SB_MEMLAYOUT_SHIFT		(13)
	#define EURASIA_PIXELBE2SB_MEMLAYOUT_CLRMSK		(0xFFFFDFFFU)

	#define EURASIA_PIXELBE2SB_MEMLAYOUT_LINEAR		(0)
	#define EURASIA_PIXELBE2SB_MEMLAYOUT_TWIDDLED	(1)

	#define EURASIA_PIXELBE2SB_GAMMACORRECT_SHIFT	(12)
	#define EURASIA_PIXELBE2SB_GAMMACORRECT			(1UL << EURASIA_PIXELBE2SB_GAMMACORRECT_SHIFT)

	#define EURASIA_PIXELBE2SB_DITHER				(1UL << 10)

	#define EURASIA_PIXELBE2SB_TILERELATIVE			(1UL << 9)

	#define EURASIA_PIXELBE2SB_PACKMODE_SHIFT		(0)
	#define EURASIA_PIXELBE2SB_PACKMODE_CLRMSK		(0xFFFFFFC0U)

	#define EURASIA_PIXELBE2SB_PACKMODE_A8R8G8B8	(0UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_A8B8G8R8	(1UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_B8G8R8A8	(2UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_R5G6B5		(3UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_A1R5G5B5	(4UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_A4R4G4B4	(5UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_A8R3G3B2	(6UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_MONO16		(7UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_MONO8		(8UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_PBYTE		(9UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_PWORD		(10UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_PT1			(11UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_PT2			(12UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_PT4			(13UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_PT8			(14UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)

	#define EURASIA_PIXELBE2SB_PACKMODE_F16			(15UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_F16F16		(16UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_F32			(17UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_S16			(18UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_S16S16		(19UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U16			(20UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U16U16		(21UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U2101010	(22UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_RESERVED	(23UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U8			(24UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_S8			(25UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_R5SG5SB6	(26UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U88			(27UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_S88			(28UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_X8U8S8S8	(29UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_S8888		(30UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U1			(31UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_U32			(32UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_S32			(33UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_F11F11F10	(34UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2SB_PACKMODE_O8			(35UL << EURASIA_PIXELBE2SB_PACKMODE_SHIFT)

#else
	#define EURASIA_PIXELBE2SB_SCALE_SHIFT			(0)
	#define EURASIA_PIXELBE2SB_SCALE_CLRMSK			(0xFFFFFFFCU)

	#define EURASIA_PIXELBE2SB_SCALE_NONE			(0)
	#define EURASIA_PIXELBE2SB_SCALE_AA				(1)
	#define EURASIA_PIXELBE2SB_SCALE_UPSCALE		(2)
	#define EURASIA_PIXELBE2SB_SCALE_AAUPSCALE		(3)

	#define EURASIA_PIXELBE2SB_TILERELATIVE			(0x00000004U)

	#define EURASIA_PIXELBE2SB_DITHER				(0x00000008U)

#endif

/** [Emitpix 2] Src0 Data */

#define EURASIA_PIXELBE2S0_OOFF_SHIFT				(0)
#define EURASIA_PIXELBE2S0_OOFF_CLRMSK				(0xFFFFFF80U)

#define EURASIA_PIXELBE2S0_COUNT_SHIFT				(8)
#define EURASIA_PIXELBE2S0_COUNT_CLRMSK				(0xFFFF00FFU)

#if defined(SGX545)
	#define EURASIA_PIXELBE2S0_SCALE_SHIFT				(30)
	#define EURASIA_PIXELBE2S0_SCALE_CLRMSK				(0x3FFFFFFFU)

	#define EURASIA_PIXELBE2S0_SCALE_NONE				(0)
	#define EURASIA_PIXELBE2S0_SCALE_AA					(1)
	#define EURASIA_PIXELBE2S0_SCALE_UPSCALE			(2)
	#define EURASIA_PIXELBE2S0_SCALE_AAUPSCALE			(3)

	#define EURASIA_PIXELBE2S0_ROTATE_SHIFT				(28)
	#define EURASIA_PIXELBE2S0_ROTATE_CLRMSK			(0xCFFFFFFFU)

	#define EURASIA_PIXELBE2S0_ROTATE_0DEG				(0)
	#define EURASIA_PIXELBE2S0_ROTATE_90DEG				(1)
	#define EURASIA_PIXELBE2S0_ROTATE_180DEG			(2)
	#define EURASIA_PIXELBE2S0_ROTATE_270DEG			(3)

	#define EURASIA_PIXELBE2S0_LINESTRIDE_SHIFT			(16)
	#define EURASIA_PIXELBE2S0_LINESTRIDE_CLRMSK		(0xF000FFFFU)
	#define EURASIA_PIXELBE_LINESTRIDE_ALIGNSHIFT		(1)

#else /* 545 */
	#if !defined(SGX_FEATURE_PIXELBE_32K_LINESTRIDE)
		#define EURASIA_PIXELBE2S0_LINESTRIDE_SHIFT			(16)
		#define EURASIA_PIXELBE2S0_LINESTRIDE_CLRMSK		(0xFC00FFFFU)
		#define EURASIA_PIXELBE_LINESTRIDE_ALIGNSHIFT		(1)
	#endif

	#define EURASIA_PIXELBE2S0_MEMLAYOUT_SHIFT					(26)
	#define EURASIA_PIXELBE2S0_MEMLAYOUT_CLRMSK					(0xF3FFFFFFU)

	#define EURASIA_PIXELBE2S0_MEMLAYOUT_LINEAR					(0)
	#define EURASIA_PIXELBE2S0_MEMLAYOUT_TILED					(1)
	#define EURASIA_PIXELBE2S0_MEMLAYOUT_TWIDDLED				(2)
	#define EURASIA_PIXELBE2S0_MEMLAYOUT_RESERVED				(3)

	#define EURASIA_PIXELBE2S0_PACKMODE_SHIFT					(28)
	#define EURASIA_PIXELBE2S0_PACKMODE_CLRMSK					(0x0FFFFFFFU)

	#define EURASIA_PIXELBE2S0_PACKMODE_A8R8G8B8				(0UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_R8G8B8A8				(1UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_B8G8R8A8				(2UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)

	#define EURASIA_PIXELBE2S0_PACKMODE_R5G6B5					(3UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_A1R5G5B5				(4UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_A4R4G4B4				(5UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_A8R3G3B2				(6UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_MONO16					(7UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_MONO8					(8UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_PBYTE					(9UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_PWORD					(10UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_PT1						(11UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_PT2						(12UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_PT4						(13UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)
	#define EURASIA_PIXELBE2S0_PACKMODE_PT8						(14UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)

	#define EURASIA_PIXELBE2S0_PACKMODE_RESERVED				(15UL << EURASIA_PIXELBE2S0_PACKMODE_SHIFT)


#endif /* 545 */

/** [Emitpix 2] Src1 Data */

#define EURASIA_PIXELBE2S1_FBADDR_SHIFT				(2)
#define EURASIA_PIXELBE2S1_FBADDR_CLRMSK			(0x00000003U)
#define EURASIA_PIXELBE_FBADDR_ALIGNSHIFT			(2)

#if !defined(SGX545)
	#define EURASIA_PIXELBE2S1_ROTATE_SHIFT				(0)
	#define EURASIA_PIXELBE2S1_ROTATE_CLRMSK			(0xFFFFFFFCU)

	#define EURASIA_PIXELBE2S1_ROTATE_0DEG				(0)
	#define EURASIA_PIXELBE2S1_ROTATE_90DEG				(1)
	#define EURASIA_PIXELBE2S1_ROTATE_180DEG			(2)
	#define EURASIA_PIXELBE2S1_ROTATE_270DEG			(3)

#endif

/** [Emitpix 2] Src2 Data */
#if defined(SGX_FEATURE_PIXELBE_32K_LINESTRIDE)
	#define EURASIA_PIXELBE2S2_LINESTRIDE_SHIFT			(0)
	#define EURASIA_PIXELBE2S2_LINESTRIDE_CLRMSK		(0xFFFFC000U)
	#define EURASIA_PIXELBE_LINESTRIDE_ALIGNSHIFT		(1)
#endif

/** [Emitpix 1] Instruction Word Sideband Data */
#if defined(SGX545)
	#define EURASIA_PIXELBE1SB_TWOEMITS					(1UL << 11)
#else
	#define EURASIA_PIXELBE1SB_TWOEMITS					(1UL << 4)
#endif

/** [Emitpix 1] Src0 Data */

#if defined(SGX545)
	#define EURASIA_PIXELBE1S0_XMIN_SHIFT				(0)
	#define EURASIA_PIXELBE1S0_XMIN_CLRMSK				(0xFFFFE000U)

	#define EURASIA_PIXELBE1S0_YMIN_SHIFT				(16)
	#define EURASIA_PIXELBE1S0_YMIN_CLRMSK				(0xE000FFFFU)
#else
	#define EURASIA_PIXELBE1S0_XMIN_SHIFT				(0)
	#define EURASIA_PIXELBE1S0_XMIN_CLRMSK				(0xFFFFF000U)

	#define EURASIA_PIXELBE1S0_YMIN_SHIFT				(12)
	#define EURASIA_PIXELBE1S0_YMIN_CLRMSK				(0xFF000FFFU)

	#define EURASIA_PIXELBE1S0_YSIZE_SHIFT				(24)
	#define EURASIA_PIXELBE1S0_YSIZE_CLRMSK				(0xF0FFFFFFU)

	#define EURASIA_PIXELBE1S0_YSIZE_ALIGN				(16)
	#define EURASIA_PIXELBE1S0_YSIZE_ALIGNSHIFT			(4)

	#define EURASIA_PIXELBE1S0_XSIZE_SHIFT				(28)
	#define EURASIA_PIXELBE1S0_XSIZE_CLRMSK				(0x0FFFFFFFU)

	#define EURASIA_PIXELBE1S0_XSIZE_ALIGN				(16)
	#define EURASIA_PIXELBE1S0_XSIZE_ALIGNSHIFT			(4)
#endif

/** [Emitpix 1] Src1 Data */

#if defined(SGX545)
	#define EURASIA_PIXELBE1S1_XMAX_SHIFT				(0)
	#define EURASIA_PIXELBE1S1_XMAX_CLRMSK				(0xFFFFE000U)

	#define EURASIA_PIXELBE1S1_YMAX_SHIFT				(16)
	#define EURASIA_PIXELBE1S1_YMAX_CLRMSK				(0xE000FFFFU)
#else
	#define EURASIA_PIXELBE1S1_XMAX_SHIFT				(0)
	#define EURASIA_PIXELBE1S1_XMAX_CLRMSK				(0xFFFFF000U)

	#define EURASIA_PIXELBE1S1_YMAX_SHIFT				(12)
	#define EURASIA_PIXELBE1S1_YMAX_CLRMSK				(0xFF000FFFU)
#endif

#if defined(FIX_HW_BRN_27919)
#define EURASIA_PIXELBE1S1_NOADVANCE				(1UL << 24)
#define EURASIA_PIXELBE1S1_NOADVANCE_MASK			(0xFEFFFFFFU)
#else
#define EURASIA_PIXELBE1S1_NOADVANCE				(1UL << 31)
#define EURASIA_PIXELBE1S1_NOADVANCE_MASK			(0x7FFFFFFFU)
#endif

#endif /* SGX_FEATURE_UNIFIED_STORE_64BITS */

/* Helpers to make code more portable */
#if defined(SGX_FEATURE_UNIFIED_STORE_64BITS)
	#define EURASIA_PIXELBE_DITHER								EURASIA_PIXELBESB_DITHER
	#define EURASIA_PIXELBE_TILERELATIVE						EURASIA_PIXELBESB_TILERELATIVE

	#define EURASIA_PIXELBE_SCALE_NONE							EURASIA_PIXELBESB_SCALE_NONE
	#define EURASIA_PIXELBE_SCALE_AA							EURASIA_PIXELBESB_SCALE_AA
	#define EURASIA_PIXELBE_SCALE_UPSCALE						EURASIA_PIXELBESB_SCALE_UPSCALE
	#define EURASIA_PIXELBE_SCALE_AAUPSCALE						EURASIA_PIXELBESB_SCALE_AAUPSCALE

	#define EURASIA_PIXELBE_MEMLAYOUT_LINEAR					EURASIA_PIXELBES0LO_MEMLAYOUT_LINEAR
	#define EURASIA_PIXELBE_MEMLAYOUT_TILED						EURASIA_PIXELBES0LO_MEMLAYOUT_TILED
	#define EURASIA_PIXELBE_MEMLAYOUT_TWIDDLED					EURASIA_PIXELBES0LO_MEMLAYOUT_TWIDDLED

	#define EURASIA_PIXELBE_ROTATE_0DEG							EURASIA_PIXELBES0HI_ROTATE_0DEG
	#define EURASIA_PIXELBE_ROTATE_90DEG						EURASIA_PIXELBES0HI_ROTATE_90DEG
	#define EURASIA_PIXELBE_ROTATE_180DEG						EURASIA_PIXELBES0HI_ROTATE_180DEG
	#define EURASIA_PIXELBE_ROTATE_270DEG						EURASIA_PIXELBES0HI_ROTATE_270DEG
#else
#if defined(SGX545)

	#define EURASIA_PIXELBE_DITHER								EURASIA_PIXELBE2SB_DITHER
	#define EURASIA_PIXELBE_TILERELATIVE						EURASIA_PIXELBE2SB_TILERELATIVE

	#define EURASIA_PIXELBE_SCALE_NONE							EURASIA_PIXELBE2S0_SCALE_NONE
	#define EURASIA_PIXELBE_SCALE_AA							EURASIA_PIXELBE2S0_SCALE_AA
	#define EURASIA_PIXELBE_SCALE_UPSCALE						EURASIA_PIXELBE2S0_SCALE_UPSCALE
	#define EURASIA_PIXELBE_SCALE_AAUPSCALE						EURASIA_PIXELBE2S0_SCALE_AAUPSCALE

	#define EURASIA_PIXELBE_MEMLAYOUT_LINEAR					EURASIA_PIXELBE2SB_MEMLAYOUT_LINEAR
	#define EURASIA_PIXELBE_MEMLAYOUT_TWIDDLED					EURASIA_PIXELBE2SB_MEMLAYOUT_TWIDDLED

	#define EURASIA_PIXELBE_ROTATE_0DEG							EURASIA_PIXELBE2S0_ROTATE_0DEG
	#define EURASIA_PIXELBE_ROTATE_90DEG						EURASIA_PIXELBE2S0_ROTATE_90DEG
	#define EURASIA_PIXELBE_ROTATE_180DEG						EURASIA_PIXELBE2S0_ROTATE_180DEG
	#define EURASIA_PIXELBE_ROTATE_270DEG						EURASIA_PIXELBE2S0_ROTATE_270DEG


#else
	#define EURASIA_PIXELBE_DITHER								EURASIA_PIXELBE2SB_DITHER
	#define EURASIA_PIXELBE_TILERELATIVE						EURASIA_PIXELBE2SB_TILERELATIVE

	#define EURASIA_PIXELBE_SCALE_NONE							EURASIA_PIXELBE2SB_SCALE_NONE
	#define EURASIA_PIXELBE_SCALE_AA							EURASIA_PIXELBE2SB_SCALE_AA
	#define EURASIA_PIXELBE_SCALE_UPSCALE						EURASIA_PIXELBE2SB_SCALE_UPSCALE
	#define EURASIA_PIXELBE_SCALE_AAUPSCALE						EURASIA_PIXELBE2SB_SCALE_AAUPSCALE

	#define EURASIA_PIXELBE_MEMLAYOUT_LINEAR					EURASIA_PIXELBE2S0_MEMLAYOUT_LINEAR
	#define EURASIA_PIXELBE_MEMLAYOUT_TILED						EURASIA_PIXELBE2S0_MEMLAYOUT_TILED
	#define EURASIA_PIXELBE_MEMLAYOUT_TWIDDLED					EURASIA_PIXELBE2S0_MEMLAYOUT_TWIDDLED

	#define EURASIA_PIXELBE_ROTATE_0DEG							EURASIA_PIXELBE2S1_ROTATE_0DEG
	#define EURASIA_PIXELBE_ROTATE_90DEG						EURASIA_PIXELBE2S1_ROTATE_90DEG
	#define EURASIA_PIXELBE_ROTATE_180DEG						EURASIA_PIXELBE2S1_ROTATE_180DEG
	#define EURASIA_PIXELBE_ROTATE_270DEG						EURASIA_PIXELBE2S1_ROTATE_270DEG

#endif
#endif



#if defined(SGX545)
	/*
		MTE emit sideband data.
	*/
	#define EURASIA_MTEEMIT2_NEWSYNCNUM_SHIFT			(8)
	#define EURASIA_MTEEMIT2_NEWSYNCNUM_CLRMSK			(0xFFFF00FFU)

	#define EURASIA_MTEEMIT2_OVERRIDESYNC				(1UL << 0)

	#define EURASIA_MTEEMIT1_COMPLEX_PHASE1				(0UL << 1)
	#define EURASIA_MTEEMIT1_COMPLEX_PHASE2				(1UL << 1)

	#define EURASIA_MTEEMIT1_COMPLEX				(1UL << 0)
#else
	/*
		MTE vertex emit sideband data.
	*/
	#define EURASIA_MTEVERT4_VERTICESIP_SHIFT			(0)
	#define EURASIA_MTEVERT4_VERTICESIP_CLRMSK			(0xFFFFFFF0U)

#if !defined(SGX543) && !defined(SGX544) && !defined(SGX554)

	/*
		MTE primitive emit sideband data.
	*/
	#define EURASIA_MTEPRIM4_FIFOD_SHIFT				(4)
	#define EURASIA_MTEPRIM4_FIFOD_CLRMSK				(0xFFFFFF0FU)

	#define EURASIA_MTEPRIM4_NEWVTXCNT_SHIFT			(8)
	#define EURASIA_MTEPRIM4_NEWVTXCNT_CLRMSK			(0xFFFFF0FFU)

	#define EURASIA_MTEPRIM3_ADVCNT_SHIFT				(25)
	#define EURASIA_MTEPRIM3_ADVCNT_CLRMSK				(0xF1FFFFFFU)

	#define EURASIA_MTEPRIM3_ADVCNT_MTEFLUSH			(6)
	#define EURASIA_MTEPRIM3_ADVCNT_MTESTATE			(7)

	#define EURASIA_MTEPRIM3_ID_SHIFT					(22)
	#define EURASIA_MTEPRIM3_ID_CLRMSK					(0xFFBFFFFFU)

	#define EURASIA_MTEPRIM3_ID_INDICES					(0)
	#define EURASIA_MTEPRIM3_ID_ADVANCE					(1)

	#define EURASIA_MTEPRIM1_EDGEFLAGS_SHIFT			(24)
	#define EURASIA_MTEPRIM1_EDGEFLAGS_CLRMSK			(0xF8FFFFFFU)

	#define EURASIA_MTEPRIM1_INDEX2_SHIFT				(16)
	#define EURASIA_MTEPRIM1_INDEX2_CLRMSK				(0xFF00FFFFU)

	#define EURASIA_MTEPRIM1_INDEX1_SHIFT				(8)
	#define EURASIA_MTEPRIM1_INDEX1_CLRMSK				(0xFFFF00FFU)

	#define EURASIA_MTEPRIM1_INDEX0_SHIFT				(0)
	#define EURASIA_MTEPRIM1_INDEX0_CLRMSK				(0xFFFFFF00U)
#endif /* !543 && !544 */
#endif /* !545 */

/*
	PDS emit sideband data.
*/
#define EURASIA_PDSSB0_USESYNCCOUNT_SHIFT			(0)
#define EURASIA_PDSSB0_USESYNCCOUNT_CLRMSK			(0xFFFFFF00U)

#define EURASIA_PDSSB0_USEATTRSIZE_SHIFT			(8)
#define EURASIA_PDSSB0_USEATTRSIZE_ALIGNSHIFT		(4)

#define EURASIA_PDSSB0_PDSDATASIZE_SHIFT			(23)
#define EURASIA_PDSSB0_PDSDATASIZE_CLRMSK			(0xF07FFFFFU)
#define EURASIA_PDSSB0_PDSDATASIZE_ALIGNSHIFT		(4)

#define EURASIA_PDSSB3_USEDATAMASTER_SHIFT			(0)
#define EURASIA_PDSSB3_USEDATAMASTER_CLRMSK			(0xFFFFFFFCU)
#define EURASIA_PDSSB3_USEDATAMASTER_VERTEX			(0)
#define EURASIA_PDSSB3_USEDATAMASTER_PIXEL			(1)
#define EURASIA_PDSSB3_USEDATAMASTER_RESERVED		(2)
#define EURASIA_PDSSB3_USEDATAMASTER_EVENT			(3)

#define EURASIA_PDSSB3_PDSOUTPUTPARCOUNT_SHIFT		(2)
#define EURASIA_PDSSB3_PDSOUTPUTPARCOUNT_CLRMSK		(0xFFFFFFE3U)

#define EURASIA_PDSSB3_USEINSTANCECOUNT_SHIFT		(6)
#define EURASIA_PDSSB3_USEINSTANCECOUNT_CLRMSK		(0xFFFFFC3FU)

#define EURASIA_PDSSB3_USEATTRIBUTEPERSISTENCE		(0x00000400U)
#define EURASIA_PDSSB3_PDSSEQDEPENDENCY				(0x00000800U)

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_PDSSB0_USEATTRSIZE_CLRMSK			(0xFFFF00FFU)

	#define EURASIA_PDSSB0_OUTPUTSTRIDE_SHIFT			(16)
	#define EURASIA_PDSSB0_OUTPUTSTRIDE_CLRMSK			(0xFF80FFFFU)

	#define EURASIA_PDSSB0_INHERITED_PARTITIONS			(0x10000000U)

	#define EURASIA_PDSSB1_PDSEXECADDR_SHIFT			(0)
	#define EURASIA_PDSSB1_PDSEXECADDR_CLRMSK			(0xF0000000U)
	#define EURASIA_PDSSB1_PDSEXECADDR_ALIGNSHIFT		(4)

	#define EURASIA_PDSSB1_VERTICESINPAR_SHIFT			(28)
	#define EURASIA_PDSSB1_VERTICESINPAR_CLRMSK			(0x0FFFFFFFU)

	#define EURASIA_PDSSB2_PDSINPUTREGISTER_SHIFT		(0)
	#define EURASIA_PDSSB2_PDSINPUTREGISTER_CLRMSK		(0x00000000U)

	#if defined(SGX554)
		#define EURASIA_PDSSB3_USEPIPE_SHIFT			(3)
		#define EURASIA_PDSSB3_USEPIPE_CLRMSK			(0xFFFFFFC7U)
		#define EURASIA_PDSSB3_USEPIPE_PIPE0			(0U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE1			(1U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE2			(2U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE3			(3U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE4			(4U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE5			(5U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE6			(6U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE7			(7U << EURASIA_PDSSB3_USEPIPE_SHIFT)
	
		#define EURASIA_PDSSB3_EMITCURRENTPIPE			(0x00001000U)
	#else
		#define EURASIA_PDSSB3_EMITCURRENTPIPE			(0x00000020U)

		#define EURASIA_PDSSB3_USEPIPE_SHIFT			(12)
		#define EURASIA_PDSSB3_USEPIPE_CLRMSK			(0xFFFFCFFFU)
		#define EURASIA_PDSSB3_USEPIPE_PIPE0			(0U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE1			(1U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE2			(2U << EURASIA_PDSSB3_USEPIPE_SHIFT)
		#define EURASIA_PDSSB3_USEPIPE_PIPE3			(3U << EURASIA_PDSSB3_USEPIPE_SHIFT)
	#endif /* defined(SGX554) */
#else /* #if defined(SGX545) */
	#define EURASIA_PDSSB0_USEATTRSIZE_CLRMSK			(0xFFFE00FFU)

	#define EURASIA_PDSSB0_OUTPUTSTRIDE_SHIFT			(16)
	#define EURASIA_PDSSB0_OUTPUTSTRIDE_CLRMSK			(0xFF81FFFFU)

	#define EURASIA_PDSSB0_INHERITED_PARTITIONS_SHIFT	(28)
	#define EURASIA_PDSSB0_INHERITED_PARTITIONS_CLRMSK	(0xCFFFFFFFU)
	#define EURASIA_PDSSB0_INHERITED_PARTITIONS_4		(0)
	#define EURASIA_PDSSB0_INHERITED_PARTITIONS_1		(1)
	#define EURASIA_PDSSB0_INHERITED_PARTITIONS_2		(2)
	#define EURASIA_PDSSB0_INHERITED_PARTITIONS_3		(3)

	#if defined(SGX520) || defined(SGX530) || defined(SGX535)
		#define EURASIA_PDSSB0_USEPIPE_SHIFT				(30)
		#define EURASIA_PDSSB0_USEPIPE_CLRMSK				(0x3FFFFFFFU)
		#define EURASIA_PDSSB0_USEPIPE_RESERVED				(0U)
		#define EURASIA_PDSSB0_USEPIPE_PIPE0				(1U)
		#define EURASIA_PDSSB0_USEPIPE_PIPE1				(2U)
		#define EURASIA_PDSSB0_USEPIPE_BOTH					(3U)

		#define EURASIA_PDSSB1_PDSEXECADDR_SHIFT			(0)
		#define EURASIA_PDSSB1_PDSEXECADDR_CLRMSK			(0xF0000000U)
		#define EURASIA_PDSSB1_PDSEXECADDR_ALIGNSHIFT		(4)
	#else /* 520 || 530 || 535 */
		#if defined(SGX540) || defined(SGX541) || defined(SGX531)
			#define EURASIA_PDSSB1_USEPIPE_SHIFT				(24)
			#define EURASIA_PDSSB1_USEPIPE_CLRMSK				(0xF8FFFFFFU)
			#define EURASIA_PDSSB1_USEPIPE_PIPE0				(1U)
			#define EURASIA_PDSSB1_USEPIPE_PIPE1				(2U)
			#define EURASIA_PDSSB1_USEPIPE_PIPE2				(3U)
			#define EURASIA_PDSSB1_USEPIPE_PIPE3				(4U)
			#define EURASIA_PDSSB1_USEPIPE_PIPEALL				(7U)

			#define EURASIA_PDSSB1_PDSEXECADDR_SHIFT			(0)
			#define EURASIA_PDSSB1_PDSEXECADDR_CLRMSK			(0xFFC00000U)
			#define EURASIA_PDSSB1_PDSEXECADDR_ALIGNSHIFT		(4)
		#endif
	#endif /* 520 || 530 || 535 */

	#define EURASIA_PDSSB1_VERTICESINPAR_SHIFT			(28)
	#define EURASIA_PDSSB1_VERTICESINPAR_CLRMSK			(0x0FFFFFFFU)

	#define EURASIA_PDSSB2_PDSINPUTREGISTER_SHIFT		(0)
	#define EURASIA_PDSSB2_PDSINPUTREGISTER_CLRMSK		(0x00000000U)

	#define EURASIA_PDSSB3_USEATTRIBUTEPARITIAL			(0x00000040U)

	#define EURASIA_PDSSB3_USEATTRIBUTEFREE				(0x00001000U)
	#define EURASIA_PDSSB3_USEATTRIBUTESTATIC			(0x00002000U)
#endif /* #if defined(SGX545) */

#if defined(SGX_FEATURE_VCB)
	/*
		VCB sideband data.
	*/
	#define EURASIA_VCBEMIT2_NEWSYNCNUM_SHIFT				(8)
	#define EURASIA_VCBEMIT2_NEWSYNCNUM_CLRMSK				(0xFFFF00FFU)

	#define EURASIA_VCBEMIT2_OVERRIDESYNC					(1UL << 0)

	#define EURASIA_VCBEMIT1_PARTITIONS_SHIFT				(16)
	#define EURASIA_VCBEMIT1_PARTITIONS_CLRMSK				(0xFFF8FFFFU)

	#define EURASIA_VCBEMIT1_DATAINFO_SHIFT					(0)
	#define EURASIA_VCBEMIT1_DATAINFO_CLRMSK				(0xFFFFFFF0U)
#endif


/* Load immediate instruction fields. */
#define EURASIA_USE1_LIMM_NOSCHED					(0x00400000U)

#define EURASIA_USE0_LIMM_IMML21_SHIFT				(0)
#define EURASIA_USE0_LIMM_IMML21_CLRMSK				(0xFFE00000U)

#define EURASIA_USE1_LIMM_IMM2521_SHIFT				(4)
#define EURASIA_USE1_LIMM_IMM2521_CLRMSK			(0xFFFFFE0FU)

#define EURASIA_USE1_LIMM_EPRED_SHIFT				(9)
#define EURASIA_USE1_LIMM_EPRED_CLRMSK				(0xFFFFF1FFU)

#define EURASIA_USE1_LIMM_IMM3126_SHIFT				(12)
#define EURASIA_USE1_LIMM_IMM3126_CLRMSK			(0xFFFC0FFFU)

/* Lock/release instruction fields. */
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_LOCKRELEASE_NOSCHED			(0x00000800U)

#define EURASIA_USE0_LOCKRELEASE_ACTION_LOCK		(0x00000000U)
#define EURASIA_USE0_LOCKRELEASE_ACTION_RELEASE		(0x00000001U)

#define SGX545_USE0_LOCKRELEASE_MUTEXNUM_SHIFT		(4)
#define SGX545_USE0_LOCKRELEASE_MUTEXNUM_CLRMSK		(0xFFFFFF0FU)

/* Ldr/str instruction fields. */
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_LDRSTR_NOSCHED					(0x00000800U)

#define EURASIA_USE1_LDRSTR_DSEL_LOAD				(0x00000000U)
#define EURASIA_USE1_LDRSTR_DSEL_STORE				(0x00080000U)

#define EURASIA_USE1_LDRSTR_DBANK_TEMP				(0x00000000U)
#define EURASIA_USE1_LDRSTR_DBANK_PRIMATTR			(0x00000080U)
#define EURASIA_USE1_LDRSTR_DBANK_CLRMSK			(0xFFFFFF7FU)

#define EURASIA_USE1_LDRSTR_DRCSEL_SHIFT			(0)
#define EURASIA_USE1_LDRSTR_DRCSEL_CLRMSK			(0xFFFFFFFCU)

#define EURASIA_USE0_LDRSTR_SRC2EXT_SHIFT			(14)
#define EURASIA_USE0_LDRSTR_SRC2EXT_CLRMSK			(0xFFE03FFFU)
#define EURASIA_USE0_LDRSTR_SRC2EXT_INTERNALSHIFT	(7)

#define EURASIA_USE_LDRSTR_GLOBREG_MAX_NUM			((1UL << 14) - 1)

/* Attach a monitor to a task */
#define SGX545_USE1_SETM_NOSCHED					(0x00000800U)

#define SGX545_USE0_SETM_MONITORNUM_CLRMSK			(0xFFFFFFF0U)
#define SGX545_USE0_SETM_MONITORNUM_SHIFT			(0)

/* Output partition synchronization. */
/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_WOP_NOSCHED					(0x00000800U)

#define EURASIA_USE0_WOP_PTNB_SHIFT					(0)
#define EURASIA_USE0_WOP_PTNB_CLRMSK				(0xFFFFFFFCU)
#define EURASIA_USE0_WOP_PTNB_MAX					(3)

/* Visibility test instruction fields. */
#define EURASIA_USE1_VISTEST_OP2_PTCTRL				(0)
#define EURASIA_USE1_VISTEST_OP2_ATST8				(1)
#define EURASIA_USE1_VISTEST_OP2_RESERVED			(2)
#define EURASIA_USE1_VISTEST_OP2_DEPTHF				(3)

/* Only available if instruction pairing feature is absent. */
#define EURASIA_USE1_VISTEST_PTCTRL_NOSCHED			(0x00000800U)

#define EURASIA_USE1_VISTEST_PTCTRL_TYPE_SHIFT		(15)
#define EURASIA_USE1_VISTEST_PTCTRL_TYPE_CLRMSK		(0xFFFF7FFFU)

#define EURASIA_USE1_VISTEST_PTCTRL_TYPE_PLANE		(0)
#define EURASIA_USE1_VISTEST_PTCTRL_TYPE_PTOFF		(1)

#define EURASIA_USE1_VISTEST_PTCTRL_S0BEXT			(0x00080000U)

#define EURASIA_USE1_VISTEST_ATST8_SYNCS			(0x00800000U)

#define EURASIA_USE1_VISTEST_ATST8_C10				(0x00400000U)

#define EURASIA_USE1_VISTEST_ATST8_S0BEXT			(0x00080000U)

#define EURASIA_USE1_VISTEST_ATST8_SPRED_SHIFT		(9)
#define EURASIA_USE1_VISTEST_ATST8_SPRED_CLRMSK		(0xFFFFF9FFU)

#define EURASIA_USE1_VISTEST_ATST8_PDST_SHIFT		(7)
#define EURASIA_USE1_VISTEST_ATST8_PDST_CLRMSK		(0xFFFFFE7FU)

#define EURASIA_USE1_VISTEST_ATST8_PDSTENABLE		(0x00000040U)

#define EURASIA_USE1_VISTEST_ATST8_TWOSIDED			(0x00000020U)

#define EURASIA_USE1_VISTEST_ATST8_OPTDWD			(0x00000010U)

#define EURASIA_USE1_VISTEST_ATST8_DISABLEFEEDBACK	(0x00000008U)

#define EURASIA_USE1_VISTEST_DEPTHF_S0BEXT			(0x00080000U)

#define EURASIA_USE1_VISTEST_DEPTHF_TWOSIDED		(0x00000020U)

#define EURASIA_USE1_VISTEST_DEPTHF_OPTDWD			(0x00000010U)

#define EURASIA_USE1_VISTEST_DEPTHF_SPRED_SHIFT		(9)
#define EURASIA_USE1_VISTEST_DEPTHF_SPRED_CLRMSK	(0xFFFFF9FFU)

#if defined(SGX_FEATURE_ALPHATEST_AUTO_COEFF)
/* ATST8/DEPTHF feedback word 0 */
#define EURASIA_USE_VISTEST_STATE0_AREF_CLRMSK		(0x00FFFFFFU)
#define EURASIA_USE_VISTEST_STATE0_AREF_SHIFT		(24)

#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_CLRMSK	(0xFFFF1FFFU)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_SHIFT	(13)

#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_NEVER	(0)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_LT		(1)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_EQ		(2)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_LE		(3)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_GT		(4)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_NE		(5)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_GE		(6)
#define EURASIA_USE_VISTEST_STATE0_ACMPMODE_ALWAYS	(7)

#define EURASIA_USE_VISTEST_STATE0_DWDISABLE		(1UL << 3)

#else /* #if defined(SGX543) */

/* ATST8/DEPTHF feedback word 0 */
#define EURASIA_USE_VISTEST_STATE0_SMASK_SHIFT		(24)
#define EURASIA_USE_VISTEST_STATE0_SMASK_CLRMSK		(0x00FFFFFFU)

#define EURASIA_USE_VISTEST_STATE0_SREF_SHIFT		(16)
#define EURASIA_USE_VISTEST_STATE0_SREF_CLRMSK		(0xFF00FFFFU)

#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_SHIFT	(13)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_CLRMSK	(0xFFFF1FFFU)

#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_NEVER	(0)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_LT		(1)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_EQ		(2)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_LE		(3)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_GT		(4)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_NE		(5)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_GE		(6)
#define EURASIA_USE_VISTEST_STATE0_SCMPMODE_ALWAYS	(7)

#define EURASIA_USE_VISTEST_STATE0_SOP1_SHIFT		(10)
#define EURASIA_USE_VISTEST_STATE0_SOP1_CLRMSK		(0xFFFFE3FFU)

#define EURASIA_USE_VISTEST_STATE0_SOP2_SHIFT		(7)
#define EURASIA_USE_VISTEST_STATE0_SOP2_CLRMSK		(0xFFFFFC7FU)

#define EURASIA_USE_VISTEST_STATE0_SOP3_SHIFT		(4)
#define EURASIA_USE_VISTEST_STATE0_SOP3_CLRMSK		(0xFFFFFF8FU)

#define EURASIA_USE_VISTEST_STATE0_SOP_KEEP			(0)
#define EURASIA_USE_VISTEST_STATE0_SOP_ZERO			(1)
#define EURASIA_USE_VISTEST_STATE0_SOP_REPLACE		(2)
#define EURASIA_USE_VISTEST_STATE0_SOP_INCRSAT		(3)
#define EURASIA_USE_VISTEST_STATE0_SOP_DECRSAT		(4)
#define EURASIA_USE_VISTEST_STATE0_SOP_INVERT		(5)
#define EURASIA_USE_VISTEST_STATE0_SOP_INCR			(6)
#define EURASIA_USE_VISTEST_STATE0_SOP_DECR			(7)

#define EURASIA_USE_VISTEST_STATE0_DWDISABLE		(0x00000008U)

#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_SHIFT	(0)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_CLRMSK	(0xFFFFFFF8U)

#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_NEVER	(0)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_LT		(1)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_EQ		(2)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_LE		(3)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_GT		(4)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_NE		(5)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_GE		(6)
#define EURASIA_USE_VISTEST_STATE0_DCMPMODE_ALWAYS	(7)

/* ATST8/DEPTHF feedback word 1 */
#define EURASIA_USE_VISTEST_STATE1_AREF_CLRMSK		(0x00FFFFFFU)
#define EURASIA_USE_VISTEST_STATE1_AREF_SHIFT		(24)

#define EURASIA_USE_VISTEST_STATE1_SWMASK_CLRMSK	(0xFF00FFFFU)
#define EURASIA_USE_VISTEST_STATE1_SWMASK_SHIFT		(16)

#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_CLRMSK	(0xFFFF1FFFU)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_SHIFT	(13)

#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_NEVER	(0)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_LT		(1)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_EQ		(2)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_LE		(3)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_GT		(4)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_NE		(5)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_GE		(6)
#define EURASIA_USE_VISTEST_STATE1_ACMPMODE_ALWAYS	(7)

#define EURASIA_USE_VISTEST_STATE1_CCWSCMP_CLRMSK	(0xFFFFF1FFU)
#define EURASIA_USE_VISTEST_STATE1_CCWSCMP_SHIFT	(9)

#define EURASIA_USE_VISTEST_STATE1_CCWSOP1_CLRMSK	(0xFFFFFE3FU)
#define EURASIA_USE_VISTEST_STATE1_CCWSOP1_SHIFT	(6)

#define EURASIA_USE_VISTEST_STATE1_CCWSOP2_CLRMSK	(0xFFFFFFC7U)
#define EURASIA_USE_VISTEST_STATE1_CCWSOP2_SHIFT	(3)

#define EURASIA_USE_VISTEST_STATE1_CCWSOP3_CLRMSK	(0xFFFFFFF8U)
#define EURASIA_USE_VISTEST_STATE1_CCWSOP3_SHIFT	(0)
#endif /* #if defined(SGX543) */

/* PCOEFF visibility register state. */
#define EURASIA_USE_VISTEST_VISREG_UPDATE			(0x00000001U)

#define EURASIA_USE_VISTEST_VISREG_REGNUM_CLRMSK	(0xFFFFFFF1U)
#define EURASIA_USE_VISTEST_VISREG_REGNUM_SHIFT		(1)

/* Possible indices into the special register bank. */
#include "sgxusespecialbankdefs.h"

/* Possible indices into the special constant bank. */
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO1			(0)
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO2			(1)
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO3			(2)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1_1		(3)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT2			(4)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT4			(5)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT8			(6)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT16		(7)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT32		(8)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT64		(9)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT128		(10)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT256		(11)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT512		(12)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1024		(13)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER2	(14)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER4	(15)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER8	(16)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER16	(17)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER32	(18)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER64	(19)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER128	(20)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER256	(21)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER512	(22)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER1024	(23)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER2048	(24)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER4096	(25)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER8192	(26)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER16384	(27)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATE			(28)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVERE	(29)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATSQR2		(30)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVERSQR2	(31)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATPIOVER4	(32)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATPIOVER2	(33)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATPI		(34)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVERPI	(35)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT2OVERPI	(36)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT4OVERPI	(37)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT2TIMESPI	(38)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1OVER65536	(39)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATTAYLOR2X	(40)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATTAYLOR2Y	(41)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATTAYLOR2W	(42)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATTAYLOR2Z	(43)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOATTAYLOR3X	(44)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT16ONE		(45)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT16ONE_1	(46)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT16ONE_2	(47)
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO			(48)
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO4			(49)
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO5			(50)
#define EURASIA_USE_SPECIAL_CONSTANT_ZERO6			(51)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1			(52)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1_2		(53)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1_3		(54)
#define EURASIA_USE_SPECIAL_CONSTANT_FLOAT1_4		(55)
#define EURASIA_USE_SPECIAL_CONSTANT_INT32ONE		(56)
#define EURASIA_USE_SPECIAL_CONSTANT_INT32ONE_1		(57)
#define EURASIA_USE_SPECIAL_CONSTANT_INT32ONE_2		(58)
#define EURASIA_USE_SPECIAL_CONSTANT_INT32ONE_3		(59)
#define EURASIA_USE_SPECIAL_CONSTANT_S16ONE			(60)
#define EURASIA_USE_SPECIAL_CONSTANT_S16ONE_1		(61)
#define EURASIA_USE_SPECIAL_CONSTANT_S16ONE_2		(62)
#define EURASIA_USE_SPECIAL_CONSTANT_S16ONE_3		(63)

/* Possible bank selections for an indexed lookup. */
#define EURASIA_USE_INDEX_BANK_SHIFT				(5)
#define EURASIA_USE_INDEX_BANK_CLRMSK				(0x1FU)

#define EURASIA_USE_INDEX_BANK_TEMP					(0)
#define EURASIA_USE_INDEX_BANK_OUTPUT				(1)
#define EURASIA_USE_INDEX_BANK_PRIMATTR				(2)
#define EURASIA_USE_INDEX_BANK_SECATTR				(3)

#define EURASIA_USE_INDEX_IDXSEL					(0x10U)

#define EURASIA_USE_INDEX_OFFSET_SHIFT				(0)
#define EURASIA_USE_INDEX_OFFSET_CLRMSK				(0xF0U)

#define EURASIA_USE_INDEX_MAXIMUM_OFFSET			15

#define EURASIA_USE_FCINDEX_BANK_SHIFT				(4)
#define EURASIA_USE_FCINDEX_BANK_CLRMSK				(0x4FU)

#define EURASIA_USE_FCINDEX_BANK_TEMP				(0)
#define EURASIA_USE_FCINDEX_BANK_OUTPUT				(1)
#define EURASIA_USE_FCINDEX_BANK_PRIMATTR			(2)
#define EURASIA_USE_FCINDEX_BANK_SECATTR			(3)

#define EURASIA_USE_FCINDEX_IDXSEL					(0x08U)

#define EURASIA_USE_FCINDEX_OFFSET_SHIFT			(0)
#define EURASIA_USE_FCINDEX_OFFSET_CLRMSK			(0xF8U)

#define EURASIA_USE_FCINDEX_MAXIMUM_OFFSET			7

#define EURASIA_USE_INDEX_NONOFFSET_NUM_BITS		3

#define EURASIA_USE_INDEX_NONOFFSET_BANK_SHIFT		(1)
#define EURASIA_USE_INDEX_NONOFFSET_BANK_CLRMSK		(0x1U)

#define EURASIA_USE_INDEX_NONOFFSET_IDXSEL			(0x1U)

/* Possible source modifiers. */
#define EURASIA_USE_SRCMOD_NONE						(0)
#define EURASIA_USE_SRCMOD_NEGATE					(1)
#define EURASIA_USE_SRCMOD_ABSOLUTE					(2)
#define EURASIA_USE_SRCMOD_NEGABS					(3)

/* Register limits. */
#define EURASIA_USE_TEMPORARY_BANK_SIZE				(128U)
#define EURASIA_USE_OUTPUT_BANK_SIZE				(128U)
#define EURASIA_USE_PRIMATTR_BANK_SIZE				(128U)
#define EURASIA_USE_SECATTR_BANK_SIZE				(128U)
#define EURASIA_USE_INDEX_BANK_SIZE					(2U)
#define EURASIA_USE_FPCONSTANT_BANK_SIZE			(64U)
#define EURASIA_USE_FPINTERNAL_BANK_SIZE			(8U)
#define EURASIA_USE_MAXIMUM_IMMEDIATE				(127U)
#define EURASIA_USE_PREDICATE_BANK_SIZE				(4U)
#define EURASIA_USE_DRC_BANK_SIZE					(2U)
#define EURASIA_USE_GLOBAL_BANK_SIZE				(46U)

#define EURASIA_USE_INTERNAL_NUM_BANKS				(4U)
#define EURASIA_USE_INTERNAL_PERBANK_SIZE			(4U)
#define EURASIA_USE_INTERNAL_PERBANK_VALID_SIZE		(3U)

/* Immediate ranges for instructions which interpret their arguments as signed. */
#define EURASIA_USE_MAXIMUM_SIGNED_IMMEDIATE		((IMG_INT32)(EURASIA_USE_MAXIMUM_IMMEDIATE >> 1))
#define EURASIA_USE_MINIMUM_SIGNED_IMMEDIATE		(-((IMG_INT32)(EURASIA_USE_MAXIMUM_IMMEDIATE >> 1) + 1))

/*
	Primary attribute data offset within secondary attruibutes.
*/
#if defined(SGX_FEATURE_UNIFIED_TEMPS_AND_PAS)
	#define EURASIA_USE_COMPLX_PADATAOFFSET (EURASIA_USE_SECATTR_BANK_SIZE)
#else
	#define EURASIA_USE_COMPLX_PADATAOFFSET (0)
#endif

/* Limit on the number of reads outstanding on a DRC register. */
#define EURASIA_USE_DRC_MAXCOUNT					(7)

/*
	Initial state of the USE MOE format control.
*/
#define EURASIA_USE_MOE_INITIAL_COLOUR_FORMAT_CONTROL	(1)
#define EURASIA_USE_MOE_INITIAL_EFO_FORMAT_CONTROL		(0)

/*****************************************************************************
 Internal 3D parameter format
*****************************************************************************/

/*
	Tail pointer size in bytes per tile.
*/
#if defined(SGX_FEATURE_MP)
#define EURASIA_TAILPOINTER_SIZE					(8)
#else
#define EURASIA_TAILPOINTER_SIZE					(4)
#endif /* SGX_FEATURE_MP */

/*
	Region Sizes.

	= INFORMATION =
	These are the true tile size values for TE output and ISP input. Despite
	their name they do not just apply to the ISP. The EURASIA_TARGNCLIP defines
	should always be a product of these values.
*/
#if defined(SGX520)
	#define	EURASIA_ISPREGION_SIZEX						(8U)
	#define	EURASIA_ISPREGION_SIZEY						(16U)
	#define EURASIA_ISPREGION_SHIFTX					(3)
	#define EURASIA_ISPREGION_SHIFTY					(4)
#else /* #if defined(SGX520) */
	#if defined(SGX545)
		#define	EURASIA_ISPREGION_SIZEX						(32U)
		#define	EURASIA_ISPREGION_SIZEY						(16U)
		#define EURASIA_ISPREGION_SHIFTX					(5)
		#define EURASIA_ISPREGION_SHIFTY					(4)
	#else /* #if defined(SGX545) */
		#if defined(SGX543) || defined(SGX544) || defined(SGX554)
			#define	EURASIA_ISPREGION_SIZEX						(32U)
			#define	EURASIA_ISPREGION_SIZEY						(32U)
			#define EURASIA_ISPREGION_SHIFTX					(5)
			#define EURASIA_ISPREGION_SHIFTY					(5)
		#else /* #if defined(SGX545) */
			#define	EURASIA_ISPREGION_SIZEX						(16U)
			#define	EURASIA_ISPREGION_SIZEY						(16U)
			#define EURASIA_ISPREGION_SHIFTX					(4)
			#define EURASIA_ISPREGION_SHIFTY					(4)
		#endif /* #if defined(SGX543) */
	#endif /* #if defined(SGX545) */
#endif /* #if defined(SGX520) */

#define EURASIA_REGIONHEADER_SIZE					(12)

/*
	Region headers.
*/
#define EURASIA_REGIONHEADER0_YPOS_SHIFT			(0)
#define EURASIA_REGIONHEADER0_YPOS_ALIGNSHIFT		(3)
#if defined(SGX530) || defined(SGX535) ||defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_REGIONHEADER0_YPOS_CLRMSK			(0xFFFFFF00U)
#else
	#if defined(SGX545)
		#define EURASIA_REGIONHEADER0_YPOS_CLRMSK			(0xFFFFFC00U)
	#else
		#define EURASIA_REGIONHEADER0_YPOS_CLRMSK			(0xFFFFFE00U)
	#endif
#endif

#define EURASIA_REGIONHEADER0_XPOS_SHIFT			(16)
#define EURASIA_REGIONHEADER0_XPOS_ALIGNSHIFT		(3)
#if defined(SGX530) || defined(SGX535) ||defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_REGIONHEADER0_XPOS_CLRMSK			(0xFF00FFFFU)
#else
	#define EURASIA_REGIONHEADER0_XPOS_CLRMSK			(0xFE00FFFFU)
#endif

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_REGIONHEADER0_EMPTY					(0x00000400)
	#define EURASIA_REGIONHEADER0_INVALID				(0x00000200)
#else
	#define EURASIA_REGIONHEADER0_EMPTY					(0x08000000)
	#define EURASIA_REGIONHEADER0_INVALID				(0x02000000)
#endif

#define EURASIA_REGIONHEADER0_MACROTILE_CLRMSK			(0xFFFF0FFFU)
#define EURASIA_REGIONHEADER0_MACROTILE_SHIFT			12

#define EURASIA_REGIONHEADER0_LASTINMACROTILE			(0x10000000)
#define EURASIA_REGIONHEADER0_ZLOADENABLE				(0x20000000)
#define EURASIA_REGIONHEADER0_ZSTOREENABLE				(0x40000000)
#define EURASIA_REGIONHEADER0_LASTREGION				(0x80000000)

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_REGIONHEADER0_RENDERCORE_CLRMSK 	(0xFCFFFFFF)
	#define EURASIA_REGIONHEADER0_RENDERCORE_SHIFT 		(24)
	#define EURASIA_REGIONHEADER0_FIRSTMACROTILE 		(0x04000000)
#endif


#define EURASIA_REGIONHEADER1_CONTROLBASE_SHIFT		(6)
#define EURASIA_REGIONHEADER1_CONTROLBASE_CLRMSK	(0xF000003FU)
#define EURASIA_REGIONHEADER1_CONTROLBASE_ALIGNSHIFT (6)

#define EURASIA_REGIONHEADER2_ZLSBASE_SHIFT			(0)
#define EURASIA_REGIONHEADER2_ZLSBASE_CLRMSK		(0xFF000000)
#define EURASIA_REGIONHEADER2_ZLSBASE_ALIGNSHIFT	(4)

#define EURASIA_REGIONHEADER2_LASTTILEINPAGE		(0x01000000)

#define EURASIA_REGIONHEADER2_ZBURSTSIZE_SHIFT		(25)
#define EURASIA_REGIONHEADER2_ZBURSTSIZE_CLRMSK		(0x01FFFFFFU)

/*
	3D control stream.
*/
#define EURASIA_PARAM_OBJTYPE_CLRMSK				0x3FFFFFFFU
#define EURASIA_PARAM_OBJTYPE_SHIFT					30
#define EURASIA_PARAM_OBJTYPE_STREAMLINK			(0UL << EURASIA_PARAM_OBJTYPE_SHIFT)
#if defined(SGX_FEATURE_MP)
#define EURASIA_PARAM_OBJTYPE_PIM					(2UL << EURASIA_PARAM_OBJTYPE_SHIFT)
#else
#define EURASIA_PARAM_OBJTYPE_DUMMY					(2UL << EURASIA_PARAM_OBJTYPE_SHIFT)
#endif
#define EURASIA_PARAM_OBJTYPE_PRIMBLOCK				(1UL << EURASIA_PARAM_OBJTYPE_SHIFT)
#define EURASIA_PARAM_OBJTYPE_STREAMTERM			(3UL << EURASIA_PARAM_OBJTYPE_SHIFT)

#define EURASIA_PARAM_STREAMLINK_CLRMSK				0xF000000FU
#define EURASIA_PARAM_STREAMLINK_SHIFT				4
#define EURASIA_PARAM_STREAMLINK_ALIGNSHIFT			4U

#define EURASIA_PARAM_PB0_PPWORDS					(1UL << 29)
#define EURASIA_PARAM_PB0_VERTEXCOUNT_CLRMSK		0xE1FFFFFFU
#define EURASIA_PARAM_PB0_VERTEXCOUNT_SHIFT			25
#define EURASIA_PARAM_PB0_ISPSTATESIZE_CLRMSK		0xFE3FFFFFU
#define EURASIA_PARAM_PB0_ISPSTATESIZE_SHIFT		22
#if defined(SGX545)
#define EURASIA_PARAM_PB0_LINKVERTPTR				(1UL << 21)
#define EURASIA_PARAM_PB0_MASKCTRL_CLRMSK			0xFFF3FFFFU
#define EURASIA_PARAM_PB0_MASKCTRL_SHIFT			19
#define EURASIA_PARAM_PB0_MASKCTRL_LEFT				0
#define EURASIA_PARAM_PB0_MASKCTRL_MASKPRES			1
#define EURASIA_PARAM_PB0_MASKCTRL_FULLMASK			2
#define EURASIA_PARAM_PB0_MASKCTRL_RIGHT			3
#else
#if defined(SGX543) || defined(SGX544) || defined(SGX554)
#define EURASIA_PARAM_PB0_LINKVERTPTR				(1UL << 21)
#else
#define EURASIA_PARAM_PB0_READISPSTATE				(1UL << 21)
#endif
#define EURASIA_PARAM_PB0_PRIMMASKPRES				(1UL << 20)
#define EURASIA_PARAM_PB0_FULLMASK					(1UL << 19)
#endif
#define EURASIA_PARAM_PB0_PRMSTART_CLRMSK			0xFFF9FFFFU
#define EURASIA_PARAM_PB0_PRMSTART_SHIFT			17
#define EURASIA_PARAM_PB0_VTMSTART					(1UL << 16)
#define EURASIA_PARAM_PB0_MASKBYTE1_CLRMSK			0xFFFF00FFU
#define EURASIA_PARAM_PB0_MASKBYTE1_SHIFT			8
#define EURASIA_PARAM_PB0_MASKBYTE0_CLRMSK			0xFFFFFF00U
#define EURASIA_PARAM_PB0_MASKBYTE0_SHIFT			0

#define EURASIA_PARAM_PB1_PRIMCOUNT_CLRMSK			0x07FFFFFFU
#define EURASIA_PARAM_PB1_PRIMCOUNT_SHIFT			27
#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
#define EURASIA_PARAM_PB1_READISPSTATE				(1UL << 26)
#define EURASIA_PARAM_PB1_VERTEXPTR_CLRMSK			0xFE000000U
#else
#define EURASIA_PARAM_PB1_VERTEXPTR_CLRMSK			0xFC000000U
#endif
#define EURASIA_PARAM_PB1_VERTEXPTR_SHIFT			0
#define EURASIA_PARAM_PB1_VERTEXPTR_ALIGNSHIFT		2

#if defined(SGX545) 
	#define EURASIA_PARAM_PB2_PRIMMASKL_CLRMSK		0xFFFF0000U
	#define EURASIA_PARAM_PB2_PRIMMASKL_SHIFT		0
	#define EURASIA_PARAM_PB2_PRIMMASKR_CLRMSK		0x0000FFFFU
	#define EURASIA_PARAM_PB2_PRIMMASKR_SHIFT		16
#else
	#define EURASIA_PARAM_PB2_PRIMMASK_CLRMSK		0x00000000U
	#define EURASIA_PARAM_PB2_PRIMMASK_SHIFT		0
#endif

#if defined(SGX545) || defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EURASIA_PARAM_PB3_LINKVERTPTR_CLRMSK 0xFC0003FF
	#define EURASIA_PARAM_PB3_LINKVERTPTR_SHIFT 10
	#define EURASIA_PARAM_PB3_LINKVERTPTR_ALIGNSHIFT 12
#endif

#define EURASIA_PARAM_INDEX0A_CLRMSK				0xFFFFFFF0U
#define EURASIA_PARAM_INDEX0A_SHIFT					0
#define EURASIA_PARAM_EDGEFLAG0AB					(1UL << 4)
#define EURASIA_PARAM_INDEX0B_CLRMSK				0xFFFFFE1FU
#define EURASIA_PARAM_INDEX0B_SHIFT					5
#define EURASIA_PARAM_EDGEFLAG0BC					(1UL << 9)
#define EURASIA_PARAM_INDEX0C_CLRMSK				0xFFFFC3FFU
#define EURASIA_PARAM_INDEX0C_SHIFT					10
#define EURASIA_PARAM_EDGEFLAG0CA					(1UL << 14)
#define EURASIA_PARAM_TRI0BACKFACE					(1UL << 15)
#define EURASIA_PARAM_INDEX1A_CLRMSK				0xFFF0FFFFU
#define EURASIA_PARAM_INDEX1A_SHIFT					16
#define EURASIA_PARAM_EDGEFLAG1AB					(1UL << 20)
#define EURASIA_PARAM_INDEX1B_CLRMSK				0xFE1FFFFFU
#define EURASIA_PARAM_INDEX1B_SHIFT					21
#define EURASIA_PARAM_EDGEFLAG1BC					(1UL << 25)
#define EURASIA_PARAM_INDEX1C_CLRMSK				0xC3FFFFFFU
#define EURASIA_PARAM_INDEX1C_SHIFT					26
#define EURASIA_PARAM_EDGEFLAG1CA					(1UL << 30)
#define EURASIA_PARAM_TRI1BACKFACE					(1UL << 31)

/*
	ISP vertex data
*/
#if defined(SGX545)

#define EURASIA_PARAM_VF_X_MAXIMUM					12287
#define	EURASIA_PARAM_VF_X_FRAC						8
#define	EURASIA_PARAM_VF_X_OFFSET					4096
#define EURASIA_PARAM_VF_Y_MAXIMUM					12287
#define	EURASIA_PARAM_VF_Y_FRAC						8
#define	EURASIA_PARAM_VF_Y_OFFSET					4096

#define	EURASIA_PARAM_VF_Y_EVEN0_SHIFT				0
#define	EURASIA_PARAM_VF_Y_EVEN0_CLRMSK				0xFF000000U
#define	EURASIA_PARAM_VF_X_EVEN0_SHIFT				24
#define	EURASIA_PARAM_VF_X_EVEN0_CLRMSK				0x00FFFFFFU
#define	EURASIA_PARAM_VF_X_EVEN1_SHIFT				0
#define	EURASIA_PARAM_VF_X_EVEN1_ALIGNSHIFT			8
#define	EURASIA_PARAM_VF_X_EVEN1_CLRMSK				0xFFFF0000U
#define	EURASIA_PARAM_VF_Z_EVEN1_SHIFT				16
#define	EURASIA_PARAM_VF_Z_EVEN1_CLRMSK				0x0000FFFFU
#define	EURASIA_PARAM_VF_Z_EVEN2_ALIGNSHIFT			16
#define	EURASIA_PARAM_VF_Z_EVEN2_SHIFT				0
#define	EURASIA_PARAM_VF_Z_EVEN2_CLRMSK				0xFFFF0000U

// Note: Odd vertices are half-dword aligned.
#define	EURASIA_PARAM_VF_Y_ODD0_SHIFT				16
#define	EURASIA_PARAM_VF_Y_ODD0_CLRMSK				0x0000FFFFU
#define	EURASIA_PARAM_VF_Y_ODD1_SHIFT				0
#define	EURASIA_PARAM_VF_Y_ODD1_ALIGNSHIFT			16
#define	EURASIA_PARAM_VF_Y_ODD1_CLRMSK				0xFFFFFF00U
#define	EURASIA_PARAM_VF_X_ODD1_SHIFT				8
#define	EURASIA_PARAM_VF_X_ODD1_CLRMSK				0x000000FFU
#define	EURASIA_PARAM_VF_Z_ODD2_SHIFT				0
#define	EURASIA_PARAM_VF_Z_ODD2_CLRMSK				0x00000000U

/*
	Vertex format word
*/
#define	EURASIA_PARAM_VF_CLIP_MASK_SHIFT			16
#define	EURASIA_PARAM_VF_CLIP_MASK_CLRMSK			0x0000FFFFU
#define	EURASIA_PARAM_VF_PITCHF_SHIFT				8
#define	EURASIA_PARAM_VF_PITCHF_CLRMSK				0xFFFF00FFU
#define	EURASIA_PARAM_VF_PITCHB_SHIFT				0
#define	EURASIA_PARAM_VF_PITCHB_CLRMSK				0xFFFFFF00U

#else /* #if defined(SGX545) */

#define	EURASIA_PARAM_VF_X_SHIFT					16
#define	EURASIA_PARAM_VF_X_CLRMSK					0x0000FFFFU
#define	EURASIA_PARAM_VF_X_FRAC						4
#define	EURASIA_PARAM_VF_X_OFFSET					1024
#define EURASIA_PARAM_VF_X_MAXIMUM					3071
#define	EURASIA_PARAM_VF_Y_SHIFT					0
#define	EURASIA_PARAM_VF_Y_CLRMSK					0xFFFF0000U
#define	EURASIA_PARAM_VF_Y_FRAC						4
#define	EURASIA_PARAM_VF_Y_OFFSET					1024
#define EURASIA_PARAM_VF_Y_MAXIMUM					3071

/*
	Vertex format word
*/
#define	EURASIA_PARAM_VF_CLIP_MASK_SHIFT			16
#define	EURASIA_PARAM_VF_CLIP_MASK_CLRMSK			0x0000FFFFU
#define	EURASIA_PARAM_VF_PITCHF_SHIFT				12
#define	EURASIA_PARAM_VF_PITCHF_CLRMSK				0xFFFF0FFFU
#define	EURASIA_PARAM_VF_PITCHB_SHIFT				8
#define	EURASIA_PARAM_VF_PITCHB_CLRMSK				0xFFFFF0FFU
#define	EURASIA_PARAM_VF_FOG_PRESENT				(1UL << 7)
#define	EURASIA_PARAM_VF_WPRESENT					(1UL << 6)
#define	EURASIA_PARAM_VF_TSP_SIZE_SHIFT				0
#define	EURASIA_PARAM_VF_TSP_SIZE_CLRMSK			0xFFFFFFC0U

#endif /* #if defined(SGX545) */

#if defined(SGX545)
/*
	Per-primitive sample position.
*/
#define	EURASIA_PARAM_VF_MSAA_Y3_SHIFT				28
#define	EURASIA_PARAM_VF_MSAA_Y3_CLRMSK				0x0FFFFFFFU
#define	EURASIA_PARAM_VF_MSAA_X3_SHIFT				24
#define	EURASIA_PARAM_VF_MSAA_X3_CLRMSK				0xF0FFFFFFU
#define	EURASIA_PARAM_VF_MSAA_Y2_SHIFT				20
#define	EURASIA_PARAM_VF_MSAA_Y2_CLRMSK				0xFF0FFFFFU
#define	EURASIA_PARAM_VF_MSAA_X2_SHIFT				16
#define	EURASIA_PARAM_VF_MSAA_X2_CLRMSK				0xFFF0FFFFU
#define	EURASIA_PARAM_VF_MSAA_Y1_SHIFT				12
#define	EURASIA_PARAM_VF_MSAA_Y1_CLRMSK				0xFFFF0FFFU
#define	EURASIA_PARAM_VF_MSAA_X1_SHIFT				8
#define	EURASIA_PARAM_VF_MSAA_X1_CLRMSK				0xFFFFF0FFU
#define	EURASIA_PARAM_VF_MSAA_Y0_SHIFT				4
#define	EURASIA_PARAM_VF_MSAA_Y0_CLRMSK				0xFFFFFF0FU
#define	EURASIA_PARAM_VF_MSAA_X0_SHIFT				0
#define	EURASIA_PARAM_VF_MSAA_X0_CLRMSK				0xFFFFFFF0U

/*
	TSP Data format word.
*/
#define	EURASIA_PARAM_VF_VERTEX_ID_PRESENT			(1UL<<21)
#define	EURASIA_PARAM_VF_OFFSET_PRESENT				(1UL<<20)
#define	EURASIA_PARAM_VF_BASE_PRESENT				(1UL<<19)
#define	EURASIA_PARAM_VF_RHW_PRESENT				(1UL<<18)

#define	EURASIA_PARAM_VF_PRIMITIVE_ID_PRESENT		(1UL<<16)

#define	EURASIA_PARAM_VF_TSP_CLIP_SIZE_SHIFT		8
#define	EURASIA_PARAM_VF_TSP_CLIP_SIZE_CLRMSK		0xFFFF80FFU
#define	EURASIA_PARAM_VF_TSP_COMPLEX				(1UL<<7)
#define	EURASIA_PARAM_VF_TSP_SIZE_SHIFT				0
#define	EURASIA_PARAM_VF_TSP_SIZE_CLRMSK			0xFFFFFF80U

/*
	16B Texture Coordinate flags.
*/
#define	EURASIA_PARAM_VF_TC31_16B					(1UL<<31)
#define	EURASIA_PARAM_VF_TC30_16B					(1UL<<30)
#define	EURASIA_PARAM_VF_TC29_16B					(1UL<<29)
#define	EURASIA_PARAM_VF_TC28_16B					(1UL<<28)
#define	EURASIA_PARAM_VF_TC27_16B					(1UL<<27)
#define	EURASIA_PARAM_VF_TC26_16B					(1UL<<26)
#define	EURASIA_PARAM_VF_TC25_16B					(1UL<<25)
#define	EURASIA_PARAM_VF_TC24_16B					(1UL<<24)
#define	EURASIA_PARAM_VF_TC23_16B					(1UL<<23)
#define	EURASIA_PARAM_VF_TC22_16B					(1UL<<22)
#define	EURASIA_PARAM_VF_TC21_16B					(1UL<<21)
#define	EURASIA_PARAM_VF_TC20_16B					(1UL<<20)
#define	EURASIA_PARAM_VF_TC19_16B					(1UL<<19)
#define	EURASIA_PARAM_VF_TC18_16B					(1UL<<18)
#define	EURASIA_PARAM_VF_TC17_16B					(1UL<<17)
#define	EURASIA_PARAM_VF_TC16_16B					(1UL<<16)
#define	EURASIA_PARAM_VF_TC15_16B					(1UL<<15)
#define	EURASIA_PARAM_VF_TC14_16B					(1UL<<14)
#define	EURASIA_PARAM_VF_TC13_16B					(1UL<<13)
#define	EURASIA_PARAM_VF_TC12_16B					(1UL<<12)
#define	EURASIA_PARAM_VF_TC11_16B					(1UL<<11)
#define	EURASIA_PARAM_VF_TC10_16B					(1UL<<10)
#define	EURASIA_PARAM_VF_TC9_16B					(1UL<<9)
#define	EURASIA_PARAM_VF_TC8_16B					(1UL<<8)
#define	EURASIA_PARAM_VF_TC7_16B					(1UL<<7)
#define	EURASIA_PARAM_VF_TC6_16B					(1UL<<6)
#define	EURASIA_PARAM_VF_TC5_16B					(1UL<<5)
#define	EURASIA_PARAM_VF_TC4_16B					(1UL<<4)
#define	EURASIA_PARAM_VF_TC3_16B					(1UL<<3)
#define	EURASIA_PARAM_VF_TC2_16B					(1UL<<2)
#define	EURASIA_PARAM_VF_TC1_16B					(1UL<<1)

/*
	1D Texture Coordinate flags.
*/
#define	EURASIA_PARAM_VF_TC31_1D					(1UL<<31)
#define	EURASIA_PARAM_VF_TC30_1D					(1UL<<30)
#define	EURASIA_PARAM_VF_TC29_1D					(1UL<<29)
#define	EURASIA_PARAM_VF_TC28_1D					(1UL<<28)
#define	EURASIA_PARAM_VF_TC27_1D					(1UL<<27)
#define	EURASIA_PARAM_VF_TC26_1D					(1UL<<26)
#define	EURASIA_PARAM_VF_TC25_1D					(1UL<<25)
#define	EURASIA_PARAM_VF_TC24_1D					(1UL<<24)
#define	EURASIA_PARAM_VF_TC23_1D					(1UL<<23)
#define	EURASIA_PARAM_VF_TC22_1D					(1UL<<22)
#define	EURASIA_PARAM_VF_TC21_1D					(1UL<<21)
#define	EURASIA_PARAM_VF_TC20_1D					(1UL<<20)
#define	EURASIA_PARAM_VF_TC19_1D					(1UL<<19)
#define	EURASIA_PARAM_VF_TC18_1D					(1UL<<18)
#define	EURASIA_PARAM_VF_TC17_1D					(1UL<<17)
#define	EURASIA_PARAM_VF_TC16_1D					(1UL<<16)
#define	EURASIA_PARAM_VF_TC15_1D					(1UL<<15)
#define	EURASIA_PARAM_VF_TC14_1D					(1UL<<14)
#define	EURASIA_PARAM_VF_TC13_1D					(1UL<<13)
#define	EURASIA_PARAM_VF_TC12_1D					(1UL<<12)
#define	EURASIA_PARAM_VF_TC11_1D					(1UL<<11)
#define	EURASIA_PARAM_VF_TC10_1D					(1UL<<10)
#define	EURASIA_PARAM_VF_TC9_1D						(1UL<<9)
#define	EURASIA_PARAM_VF_TC8_1D						(1UL<<8)
#define	EURASIA_PARAM_VF_TC7_1D						(1UL<<7)
#define	EURASIA_PARAM_VF_TC6_1D						(1UL<<6)
#define	EURASIA_PARAM_VF_TC5_1D						(1UL<<5)
#define	EURASIA_PARAM_VF_TC4_1D						(1UL<<4)
#define	EURASIA_PARAM_VF_TC3_1D						(1UL<<3)
#define	EURASIA_PARAM_VF_TC2_1D						(1UL<<2)
#define	EURASIA_PARAM_VF_TC1_1D						(1UL<<1)

/*
	S Present Texture Coordinate flags.
*/
#define	EURASIA_PARAM_VF_TC31_S_PRES					(1UL<<31)
#define	EURASIA_PARAM_VF_TC30_S_PRES					(1UL<<30)
#define	EURASIA_PARAM_VF_TC29_S_PRES					(1UL<<29)
#define	EURASIA_PARAM_VF_TC28_S_PRES					(1UL<<28)
#define	EURASIA_PARAM_VF_TC27_S_PRES					(1UL<<27)
#define	EURASIA_PARAM_VF_TC26_S_PRES					(1UL<<26)
#define	EURASIA_PARAM_VF_TC25_S_PRES					(1UL<<25)
#define	EURASIA_PARAM_VF_TC24_S_PRES					(1UL<<24)
#define	EURASIA_PARAM_VF_TC23_S_PRES					(1UL<<23)
#define	EURASIA_PARAM_VF_TC22_S_PRES					(1UL<<22)
#define	EURASIA_PARAM_VF_TC21_S_PRES					(1UL<<21)
#define	EURASIA_PARAM_VF_TC20_S_PRES					(1UL<<20)
#define	EURASIA_PARAM_VF_TC19_S_PRES					(1UL<<19)
#define	EURASIA_PARAM_VF_TC18_S_PRES					(1UL<<18)
#define	EURASIA_PARAM_VF_TC17_S_PRES					(1UL<<17)
#define	EURASIA_PARAM_VF_TC16_S_PRES					(1UL<<16)
#define	EURASIA_PARAM_VF_TC15_S_PRES					(1UL<<15)
#define	EURASIA_PARAM_VF_TC14_S_PRES					(1UL<<14)
#define	EURASIA_PARAM_VF_TC13_S_PRES					(1UL<<13)
#define	EURASIA_PARAM_VF_TC12_S_PRES					(1UL<<12)
#define	EURASIA_PARAM_VF_TC11_S_PRES					(1UL<<11)
#define	EURASIA_PARAM_VF_TC10_S_PRES					(1UL<<10)
#define	EURASIA_PARAM_VF_TC9_S_PRES						(1UL<<9)
#define	EURASIA_PARAM_VF_TC8_S_PRES						(1UL<<8)
#define	EURASIA_PARAM_VF_TC7_S_PRES						(1UL<<7)
#define	EURASIA_PARAM_VF_TC6_S_PRES						(1UL<<6)
#define	EURASIA_PARAM_VF_TC5_S_PRES						(1UL<<5)
#define	EURASIA_PARAM_VF_TC4_S_PRES						(1UL<<4)
#define	EURASIA_PARAM_VF_TC3_S_PRES						(1UL<<3)
#define	EURASIA_PARAM_VF_TC2_S_PRES						(1UL<<2)
#define	EURASIA_PARAM_VF_TC1_S_PRES						(1UL<<1)

/*
	T Present Texture Coordinate flags.
*/
#define	EURASIA_PARAM_VF_TC31_T_PRES					(1UL<<31)
#define	EURASIA_PARAM_VF_TC30_T_PRES					(1UL<<30)
#define	EURASIA_PARAM_VF_TC29_T_PRES					(1UL<<29)
#define	EURASIA_PARAM_VF_TC28_T_PRES					(1UL<<28)
#define	EURASIA_PARAM_VF_TC27_T_PRES					(1UL<<27)
#define	EURASIA_PARAM_VF_TC26_T_PRES					(1UL<<26)
#define	EURASIA_PARAM_VF_TC25_T_PRES					(1UL<<25)
#define	EURASIA_PARAM_VF_TC24_T_PRES					(1UL<<24)
#define	EURASIA_PARAM_VF_TC23_T_PRES					(1UL<<23)
#define	EURASIA_PARAM_VF_TC22_T_PRES					(1UL<<22)
#define	EURASIA_PARAM_VF_TC21_T_PRES					(1UL<<21)
#define	EURASIA_PARAM_VF_TC20_T_PRES					(1UL<<20)
#define	EURASIA_PARAM_VF_TC19_T_PRES					(1UL<<19)
#define	EURASIA_PARAM_VF_TC18_T_PRES					(1UL<<18)
#define	EURASIA_PARAM_VF_TC17_T_PRES					(1UL<<17)
#define	EURASIA_PARAM_VF_TC16_T_PRES					(1UL<<16)
#define	EURASIA_PARAM_VF_TC15_T_PRES					(1UL<<15)
#define	EURASIA_PARAM_VF_TC14_T_PRES					(1UL<<14)
#define	EURASIA_PARAM_VF_TC13_T_PRES					(1UL<<13)
#define	EURASIA_PARAM_VF_TC12_T_PRES					(1UL<<12)
#define	EURASIA_PARAM_VF_TC11_T_PRES					(1UL<<11)
#define	EURASIA_PARAM_VF_TC10_T_PRES					(1UL<<10)
#define	EURASIA_PARAM_VF_TC9_T_PRES						(1UL<<9)
#define	EURASIA_PARAM_VF_TC8_T_PRES						(1UL<<8)
#define	EURASIA_PARAM_VF_TC7_T_PRES						(1UL<<7)
#define	EURASIA_PARAM_VF_TC6_T_PRES						(1UL<<6)
#define	EURASIA_PARAM_VF_TC5_T_PRES						(1UL<<5)
#define	EURASIA_PARAM_VF_TC4_T_PRES						(1UL<<4)
#define	EURASIA_PARAM_VF_TC3_T_PRES						(1UL<<3)
#define	EURASIA_PARAM_VF_TC2_T_PRES						(1UL<<2)
#define	EURASIA_PARAM_VF_TC1_T_PRES						(1UL<<1)

#endif /* #if defined(SGX545) */

/*
	Point pitch words
*/
#define	EURASIA_PARAM_VF_PITCH7_SHIFT				28
#define	EURASIA_PARAM_VF_PITCH7_CLRMSK				0x0FFFFFFFU
#define	EURASIA_PARAM_VF_PITCH6_SHIFT				24
#define	EURASIA_PARAM_VF_PITCH6_CLRMSK				0xF0FFFFFFU
#define	EURASIA_PARAM_VF_PITCH5_SHIFT				20
#define	EURASIA_PARAM_VF_PITCH5_CLRMSK				0xFF0FFFFFU
#define	EURASIA_PARAM_VF_PITCH4_SHIFT				16
#define	EURASIA_PARAM_VF_PITCH4_CLRMSK				0xFFF0FFFFU
#define	EURASIA_PARAM_VF_PITCH3_SHIFT				12
#define	EURASIA_PARAM_VF_PITCH3_CLRMSK				0xFFFF0FFFU
#define	EURASIA_PARAM_VF_PITCH2_SHIFT				8
#define	EURASIA_PARAM_VF_PITCH2_CLRMSK				0xFFFFF0FFU
#define	EURASIA_PARAM_VF_PITCH1_SHIFT				4
#define	EURASIA_PARAM_VF_PITCH1_CLRMSK				0xFFFFFF0FU
#define	EURASIA_PARAM_VF_PITCH0_SHIFT				0
#define	EURASIA_PARAM_VF_PITCH0_CLRMSK				0xFFFFFFF0U

#define	EURASIA_PARAM_VF_PITCH15_SHIFT				28
#define	EURASIA_PARAM_VF_PITCH15_CLRMSK				0x0FFFFFFFU
#define	EURASIA_PARAM_VF_PITCH14_SHIFT				24
#define	EURASIA_PARAM_VF_PITCH14_CLRMSK				0xF0FFFFFFU
#define	EURASIA_PARAM_VF_PITCH13_SHIFT				20
#define	EURASIA_PARAM_VF_PITCH13_CLRMSK				0xFF0FFFFFU
#define	EURASIA_PARAM_VF_PITCH12_SHIFT				16
#define	EURASIA_PARAM_VF_PITCH12_CLRMSK				0xFFF0FFFFU
#define	EURASIA_PARAM_VF_PITCH11_SHIFT				12
#define	EURASIA_PARAM_VF_PITCH11_CLRMSK				0xFFFF0FFFU
#define	EURASIA_PARAM_VF_PITCH10_SHIFT				8
#define	EURASIA_PARAM_VF_PITCH10_CLRMSK				0xFFFFF0FFU
#define	EURASIA_PARAM_VF_PITCH9_SHIFT				4
#define	EURASIA_PARAM_VF_PITCH9_CLRMSK				0xFFFFFF0FU
#define	EURASIA_PARAM_VF_PITCH8_SHIFT				0
#define	EURASIA_PARAM_VF_PITCH8_CLRMSK				0xFFFFFFF0U

#if !defined(SGX545)
/*
	TSP data format word
*/
#define	EURASIA_PARAM_VF_OFFSET_PRESENT				(1UL << 31)
#define	EURASIA_PARAM_VF_BASE_PRESENT				(1UL << 30)
#define	EURASIA_PARAM_VF_TC9_16B					(1UL << 29)
#define	EURASIA_PARAM_VF_TC8_16B					(1UL << 28)
#define	EURASIA_PARAM_VF_TC7_16B					(1UL << 27)
#define	EURASIA_PARAM_VF_TC6_16B					(1UL << 26)
#define	EURASIA_PARAM_VF_TC5_16B					(1UL << 25)
#define	EURASIA_PARAM_VF_TC4_16B					(1UL << 24)
#define	EURASIA_PARAM_VF_TC3_16B					(1UL << 23)
#define	EURASIA_PARAM_VF_TC2_16B					(1UL << 22)
#define	EURASIA_PARAM_VF_TC1_16B					(1UL << 21)
#define	EURASIA_PARAM_VF_TC0_16B					(1UL << 20)
#define	EURASIA_PARAM_VF_TC9_T_PRES					(1UL << 19)
#define	EURASIA_PARAM_VF_TC9_S_PRES					(1UL << 18)
#define	EURASIA_PARAM_VF_TC8_T_PRES					(1UL << 17)
#define	EURASIA_PARAM_VF_TC8_S_PRES					(1UL << 16)
#define	EURASIA_PARAM_VF_TC7_T_PRES					(1UL << 15)
#define	EURASIA_PARAM_VF_TC7_S_PRES					(1UL << 14)
#define	EURASIA_PARAM_VF_TC6_T_PRES					(1UL << 13)
#define	EURASIA_PARAM_VF_TC6_S_PRES					(1UL << 12)
#define	EURASIA_PARAM_VF_TC5_T_PRES					(1UL << 11)
#define	EURASIA_PARAM_VF_TC5_S_PRES					(1UL << 10)
#define	EURASIA_PARAM_VF_TC4_T_PRES					(1UL << 9)
#define	EURASIA_PARAM_VF_TC4_S_PRES					(1UL << 8)
#define	EURASIA_PARAM_VF_TC3_T_PRES					(1UL << 7)
#define	EURASIA_PARAM_VF_TC3_S_PRES					(1UL << 6)
#define	EURASIA_PARAM_VF_TC2_T_PRES					(1UL << 5)
#define	EURASIA_PARAM_VF_TC2_S_PRES					(1UL << 4)
#define	EURASIA_PARAM_VF_TC1_T_PRES					(1UL << 3)
#define	EURASIA_PARAM_VF_TC1_S_PRES					(1UL << 2)
#define	EURASIA_PARAM_VF_TC0_T_PRES					(1UL << 1)
#define	EURASIA_PARAM_VF_TC0_S_PRES					(1UL << 0)
#endif /* #if !defined(SGX545) */

/*****************************************************************************
 Global Registers
*****************************************************************************/

/* USE code segment definitions */

/* Cache line size in bytes (SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS is in instructions) */
#if defined(SGX_FEATURE_SYSTEM_CACHE)

/* Check if the SLC line size should be used instead */
#if(EURASIA_CACHE_LINE_SIZE > (1UL << (SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS + 3)))
#define EURASIA_USE_INSTRUCTION_CACHE_LINE_SIZE					EURASIA_CACHE_LINE_SIZE
#else
#define EURASIA_USE_INSTRUCTION_CACHE_LINE_SIZE					(1UL << (SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS + 3))
#endif

#else

#define EURASIA_USE_INSTRUCTION_CACHE_LINE_SIZE					(1UL << (SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS + 3))

#endif

#define EURASIA_USECODEBASE_DATAMASTER_VERTEX					(0)
#define EURASIA_USECODEBASE_DATAMASTER_PIXEL					(1)
#define EURASIA_USECODEBASE_DATAMASTER_RESERVED					(2)
#define EURASIA_USECODEBASE_DATAMASTER_EDM						(3)

#define EUR_CR_DMS_CTRL_DISABLE_DM_VERTEX_MASK					0x00000001U
#define EUR_CR_DMS_CTRL_DISABLE_DM_PIXEL_MASK					0x00000002U
#define EUR_CR_DMS_CTRL_DISABLE_DM_EVENT_MASK					0x00000004U
#define EUR_CR_DMS_CTRL_DISABLE_DM_LOOPBACK_MASK				0x00000008U

/* USE code base register definitions */
#define EUR_CR_USE_CODE_BASE_ADDR_ALIGNSHIFT					(SGX_FEATURE_USE_INSTRUCTION_CACHE_LINE_BITS + 3)

/* Size of a usse code page (in bytes) */
#define EURASIA_USE_CODE_PAGE_ALIGN_SHIFT						(SGX_FEATURE_USE_NUMBER_PC_BITS + 3)
#define EURASIA_USE_CODE_PAGE_SIZE								(1UL << EURASIA_USE_CODE_PAGE_ALIGN_SHIFT)

/* EDM Pixel PDS Execution Address register definitions */
#define EUR_CR_EVENT_PIXEL_PDS_EXEC_ADDR_ALIGNSHIFT				4U

/* EDM Pixel PDS Data Size register definitions */
#define EUR_CR_EVENT_PIXEL_PDS_DATA_SIZE_ALIGNSHIFT				4U

/* EDM Pixel DMS Info register definitions */
#define EUR_CR_EVENT_PIXEL_PDS_INFO_ATTRIBUTE_SIZE_ALIGNSHIFT	4U

/* EDM Other PDS Execution Address register definitions */
#define EUR_CR_EVENT_OTHER_PDS_EXEC_ADDR_ALIGNSHIFT				4U

/* EDM Other PDS Data Size register definitions */
#define EUR_CR_EVENT_OTHER_PDS_DATA_SIZE_ALIGNSHIFT				4U

/* EDM Other DMS Info register definitions */
#define EUR_CR_EVENT_OTHER_PDS_INFO_ATTRIBUTE_SIZE_ALIGNSHIFT	4U

/* EUR_CR_ISP2_BGOBJTAG values */
#define	EUR_CR_ISP_BGOBJTAG_VERTEXPTR_ALIGNSHIFT				4U

/* EUR_CR_ISP_RGN_BASE_ADDR_ALIGNSHIFT*/
#define	EUR_CR_ISP_RGN_BASE_ADDR_ALIGNSHIFT						2U


/* EUR_CR_IPF_RENDERTYPE enumerated values */
#define	EUR_CR_ISP_RENDER_TYPE_NORMAL3D							0x00000000
#if defined(SGX_FEATURE_ISP_CONTEXT_SWITCH_REV_2) || defined(SGX_FEATURE_ISP_CONTEXT_SWITCH_REV_3)
#define EUR_CR_ISP_RENDER_TYPE_NORMAL3D_RESUME					0x00000001
#endif
#define	EUR_CR_ISP_RENDER_TYPE_FAST2D							0x00000002
#define	EUR_CR_ISP_RENDER_TYPE_FASTSCALE						0x00000003

/* EUR_CR_IFPU_DBIAS default values */
#if !defined(SGX545) || defined(FIX_HW_BRN_27792)
#define	EUR_CR_ISP_DBIAS_UNITSADJ_DEFAULT						0
#define	EUR_CR_ISP_DBIAS_FACTORADJ_DEFAULT						-23
#endif

#if defined(SGX545)
	/* EUR_CR_ISP_ZLSCTL enumerated values */
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_F32Z						(0UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_I24ZI8S					(1UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_I16ZI16Z					(2UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_F32ZI8S					(3UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_I8S1V						(4UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_CMPR_F32ZI8S1V			(5UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_CMPR_F32Z1V				(6UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_CMPR_I8S1V				(7UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)

	/* EUR_CR_ISP_ZLSCTL enumerated values */
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_F32Z						(0UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_I24ZI8S					(1UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_I16ZI16Z					(2UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_F32ZI8S					(3UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_I8S1V					(4UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_CMPR_F32ZI8S1V			(5UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_CMPR_F32Z1V				(6UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_CMPR_I8S1V				(7UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
#else /* #if defined(SGX545) */
	/* EUR_CR_ISP_ZLSCTL enumerated values */
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_F32Z						(0UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_I24ZI8S					(1UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_I16ZI16Z					(2UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_F32ZI8S1V					(3UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_CMPR_F32ZI8S1V			(4UL << EUR_CR_ISP_ZLSCTL_ZLOADFORMAT_SHIFT)
	#endif

	/* EUR_CR_ISP_ZLSCTL enumerated values */
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_F32Z						(0UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_I24ZI8S					(1UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_I16ZI16Z					(2UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_F32ZI8S1V				(3UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define	EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_CMPR_F32ZI8S1V			(4UL << EUR_CR_ISP_ZLSCTL_ZSTOREFORMAT_SHIFT)
	#endif
#endif /* #if defined(SGX545) */

/* EUR_CR_DPM values */
#define EURASIA_NUM_MACROTILES									(17U)
#define EURASIA_NUM_NONGLOBAL_MACROTILES						(16U)

#define	EURASIA_PARAM_MANAGE_GRAN								0x1000U
#define EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES					(SGX_FEATURE_PARAMETER_BUFFER_SIZE / EURASIA_PARAM_MANAGE_GRAN)
#if EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x10000
#define	EURASIA_PARAM_MANAGE_TABLE_SIZE							(0x10000 * 4)
#else /* EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x10000 */
#if EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x4000
#define	EURASIA_PARAM_MANAGE_TABLE_SIZE							(0x4000 * 4)
#endif /* EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x4000 */
#endif /* EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x10000 */
#define	EURASIA_PARAM_MANAGE_TABLE_GRAN							(1UL << EUR_CR_DPM_TA_ALLOC_PAGE_TABLE_BASE_ADDR_SHIFT)
#define EURASIA_PARAM_MANAGE_TABLE_PREV_MASK					(0xFFFF0000U)
#define EURASIA_PARAM_MANAGE_TABLE_PREV_SHIFT					(16)
#define EURASIA_PARAM_MANAGE_TABLE_NEXT_MASK					(0x0000FFFFU)
#define EURASIA_PARAM_MANAGE_TABLE_NEXT_SHIFT					(0)
#define	EURASIA_PARAM_MANAGE_REGION_GRAN						(1UL << EUR_CR_TE_PSGREGION_BASE_ADDR_SHIFT)
#define	EURASIA_PARAM_MANAGE_TPC_GRAN							(1UL << EUR_CR_TE_TPC_BASE_ADDR_SHIFT)
#if defined(SGX_FEATURE_MP)
#define EURASIA_PARAM_MANAGE_NUM_PENDING_PIM_GROUPS				(3)
#define	EURASIA_PARAM_MANAGE_STATE_SIZE							(EURASIA_NUM_MACROTILES * 2 * 4 * (1 + (EURASIA_PARAM_MANAGE_NUM_PENDING_PIM_GROUPS * 4)))
#else
#define	EURASIA_PARAM_MANAGE_STATE_SIZE							(EURASIA_NUM_MACROTILES * 2 * 4)
#endif
#if !defined(SGX545)
	#define	EURASIA_PARAM_MANAGE_STATE_GRAN						(1UL << EUR_CR_DPM_STATE_TABLE_BASE_ADDR_SHIFT)
#else
	#define	EURASIA_PARAM_MANAGE_STATE_GRAN						(1UL << EUR_CR_DPM_STATE_TABLE_CONTEXT0_BASE_ADDR_SHIFT)
#endif
#if defined(SGX_FEATURE_MP)
/* Each Macrotile requires 8 Bytes (4 for Page and 4 for PIM) */
#define	EURASIA_PARAM_MANAGE_CONTROL_SIZE						(EURASIA_NUM_NONGLOBAL_MACROTILES * 8)
#else
#define	EURASIA_PARAM_MANAGE_CONTROL_SIZE						(EURASIA_NUM_NONGLOBAL_MACROTILES * 4)
#endif
#define	EURASIA_PARAM_MANAGE_CONTROL_GRAN						(1UL << EUR_CR_DPM_CONTROL_TABLE_BASE_ADDR_SHIFT)
#define EURASIA_PARAM_MANAGE_OTPM_BURST_SIZE					(16U)
#if defined(SGX_FEATURE_MP)
#define EURASIA_PARAM_MANAGE_OTPM_SIZE							(((EURASIA_NUM_MACROTILES * 8) + EURASIA_PARAM_MANAGE_OTPM_BURST_SIZE - 1) & ~(EURASIA_PARAM_MANAGE_OTPM_BURST_SIZE - 1))
#else
#define EURASIA_PARAM_MANAGE_OTPM_SIZE							(((EURASIA_NUM_MACROTILES * 4) + EURASIA_PARAM_MANAGE_OTPM_BURST_SIZE - 1) & ~(EURASIA_PARAM_MANAGE_OTPM_BURST_SIZE - 1))
#endif

#if defined(FIX_HW_BRN_34043)
	/* 
		OTPM burst accesses must not straddle a 4KB boundary, max OTPM burst is N consecutive 128bit accesses
		so alignment must be the bounding power of 2 size to avoid the issue
	*/
	#if defined(SGX545)
		/*
			545 is a special case due to rendertarget arrays, each RT requiring a contiguously packed OTPM buffer
			N = 5 so each OTPM buffer is 80bytes => 51 RTAs before straddling a page
			base first OTPM buffer start at the base of a page (4096 alignment)
			Note: ASSERT(RTCount<52) required in RTA code or more complex omission of page boundary straddling RT's
		*/
		#define EURASIA_PARAM_MANAGE_OTPM_GRAN	 4096
	#else
		#if defined(SGX_FEATURE_MP)
			/* N = 9 so each bounding power of 2 is N=16. OTPM buffer is 256bytes */
			#define EURASIA_PARAM_MANAGE_OTPM_GRAN	 256
		#else
			/* N = 5 so each bounding power of 2 is N=8. OTPM buffer is 128bytes */
			#define EURASIA_PARAM_MANAGE_OTPM_GRAN	 128	
		#endif
	#endif
#else
	#if defined(SGX545)
		#define EURASIA_PARAM_MANAGE_OTPM_GRAN	 (1UL << EUR_CR_MTE_OTPM_CSM_BASE_ADDR_SHIFT)
	#else
		#define EURASIA_PARAM_MANAGE_OTPM_GRAN	 (1UL << EUR_CR_MTE_OTPM_CSM_FLUSH_BASE_ADDR_SHIFT)
	#endif
#endif

#if defined(SGX_FEATURE_MP)
#if defined(EUR_CR_MASTER_DPM_MTILE_PARTI_PIM_TABLE_BASE_ADDR)
/* FIXME: make the size below based on an equation */
#define	EURASIA_PARAM_MANAGE_PIM_SIZE							(64 * 4)
#define	EURASIA_PARAM_MANAGE_PIM_GRAN							(1UL << EUR_CR_MASTER_DPM_MTILE_PARTI_PIM_TABLE_BASE_ADDR_STATUS_SHIFT)
#endif
#endif

#if EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x10000
#define EURASIA_PARAM_PAGENUMBER_BITS							(16)
#else /* EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x10000 */
#if EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x4000
#define EURASIA_PARAM_PAGENUMBER_BITS							(14)
#endif /* EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x4000 */
#endif /* EURASIA_PARAMETER_BUFFER_SIZE_IN_PAGES == 0x10000 */
#define EURASIA_PARAM_PAGENUMBER_MASK							((1UL << EURASIA_PARAM_PAGENUMBER_BITS) - 1)
#define EURASIA_PARAM_FREE_LIST_RESERVE_PAGES					(2)
#define EURASIA_PARAM_FREE_LIST_RESERVE_SIZE					(EURASIA_PARAM_FREE_LIST_RESERVE_PAGES * EURASIA_PARAM_MANAGE_GRAN)

#if EURASIA_PARAM_PAGENUMBER_BITS == 14
#if defined(SGX_FEATURE_UNPACKED_DPM_STATE)
#define EURASIA_PARAM_DPM_STATE_MT_HEAD_SHIFT					(0)
#define EURASIA_PARAM_DPM_STATE_MT_HEAD_CLRMSK					(0xFFFFC000U)
#define EURASIA_PARAM_DPM_STATE_MT_COUNT_SHIFT					(16)
#define EURASIA_PARAM_DPM_STATE_MT_COUNT_CLRMSK					(0xC000FFFFU)

#define EURASIA_PARAM_DPM_STATE_MT_TAIL_SHIFT					(0)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_CLRMSK					(0xFFFFC000U)
#define EURASIA_PARAM_DPM_STATE_MT_ZLSCOUNT_SHIFT				(16)
#define EURASIA_PARAM_DPM_STATE_MT_ZLSCOUNT_CLRMSK				(0xC000FFFFU)
#else
#define EURASIA_PARAM_DPM_STATE_MT_HEAD_SHIFT					(0)
#define EURASIA_PARAM_DPM_STATE_MT_HEAD_CLRMSK					(0xFFFFC000U)
#define EURASIA_PARAM_DPM_STATE_MT_COUNT_SHIFT					(14)
#define EURASIA_PARAM_DPM_STATE_MT_COUNT_CLRMSK					(0xF0003FFFU)

#define EURASIA_PARAM_DPM_STATE_MT_TAIL_0_SHIFT					(28)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_0_MASK					(0xF0000000U)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_1_SHIFT					(0)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_1_ALIGNSHIFT			(4)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_1_MASK					(0x000003FFU)

#define EURASIA_PARAM_DPM_STATE_MT_ZLSCOUNT_SHIFT				(10)
#define EURASIA_PARAM_DPM_STATE_MT_ZLSCOUNT_CLRMSK				(0xFF0003FFU)
#endif
#define EURASIA_PARAM_DPM_PAGE_LIST_PREV_TERM_MSK				(0x3FFF0000U)
#define EURASIA_PARAM_DPM_PAGE_LIST_NEXT_TERM_MSK				(0x3FFFU)
#define EURASIA_PARAM_DPM_PAGE_LIST_PREV_CLRMSK					(0xC000FFFFU)
#define EURASIA_PARAM_DPM_PAGE_LIST_NEXT_CLRMSK					(0xFFFFC000U)
#else
#if EURASIA_PARAM_PAGENUMBER_BITS == 16
#define EURASIA_PARAM_DPM_STATE_MT_HEAD_SHIFT					(0)
#define EURASIA_PARAM_DPM_STATE_MT_HEAD_CLRMSK					(0xFFFF0000U)
#define EURASIA_PARAM_DPM_STATE_MT_COUNT_SHIFT					(16)
#define EURASIA_PARAM_DPM_STATE_MT_COUNT_CLRMSK					(0x0000FFFFU)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_SHIFT					(0)
#define EURASIA_PARAM_DPM_STATE_MT_TAIL_CLRMSK					(0xFFFF0000U)
#define EURASIA_PARAM_DPM_STATE_MT_ZLSCOUNT_SHIFT				(16)
#define EURASIA_PARAM_DPM_STATE_MT_ZLSCOUNT_CLRMSK				(0x0000FFFFU)

#define EURASIA_PARAM_DPM_PAGE_LIST_PREV_TERM_MSK				(0xFFFF0000U)
#define EURASIA_PARAM_DPM_PAGE_LIST_NEXT_TERM_MSK				(0xFFFFU)
#define EURASIA_PARAM_DPM_PAGE_LIST_PREV_CLRMSK					(0x0000FFFFU)
#define EURASIA_PARAM_DPM_PAGE_LIST_NEXT_CLRMSK					(0xFFFF0000U)
#endif
#endif

#define EURASIA_PARAM_DPM_PAGE_LIST_PREV_SHIFT					(16)
#define EURASIA_PARAM_DPM_PAGE_LIST_NEXT_SHIFT					(0)

#if EURASIA_PARAM_PAGENUMBER_BITS == 14
#define EURASIA_PARAM_OTPM_CSM_OFFSET_SHIFT						(0)
#define EURASIA_PARAM_OTPM_CSM_OFFSET_MASK						(0x000003FFU)
#define EURASIA_PARAM_OTPM_CSM_PAGE_SHIFT						(10)
#define EURASIA_PARAM_OTPM_CSM_PAGE_MASK						(0x00FFFC00U)
#define EURASIA_PARAM_OTPM_CSM_VALID_SHIFT						(24)
#define EURASIA_PARAM_OTPM_CSM_VALID_MASK						(0x01000000U)
#else
#if EURASIA_PARAM_PAGENUMBER_BITS == 16
#define EURASIA_PARAM_OTPM_CSM_OFFSET_SHIFT						(0)
#define EURASIA_PARAM_OTPM_CSM_OFFSET_MASK						(0x000003FFU)
#define EURASIA_PARAM_OTPM_CSM_PAGE_SHIFT						(10)
#define EURASIA_PARAM_OTPM_CSM_PAGE_MASK						(0x03FFFC00U)
#define EURASIA_PARAM_OTPM_CSM_VALID_SHIFT						(26)
#define EURASIA_PARAM_OTPM_CSM_VALID_MASK						(0x04000000U)
#endif
#endif

/* Register EUR_CR_TA_VDM_CTRL_STREAM_BASE */
#define EUR_CR_VDM_CTRL_STREAM_BASE_ALIGNSHIFT					2

/* Register EUR_CR_BIF_TWOD_REQ_BASE */
#define	EUR_CR_BIF_TWOD_REQ_BASE_ADDR_ALIGNSHIFT				20

/* Register EUR_CR_BIF_TA_REQ_BASE */
#define	EUR_CR_BIF_TA_REQ_BASE_ADDR_ALIGNSHIFT					20

/* Register EUR_CR_BIF_3D_REQ_BASE */
#define	EUR_CR_BIF_3D_REQ_BASE_ADDR_ALIGNSHIFT					20

/* Register EUR_CR_BIF_ZLS_REQ_BASE */
#define	EUR_CR_BIF_ZLS_REQ_BASE_ADDR_ALIGNSHIFT					20

/* Register EUR_CR_EVENT_KICKER */
#define EUR_CR_EVENT_KICKER_ADDRESS_ALIGNSHIFT					4

/*
	Minimum number of pages that need to be allocated to non-global macro tiles -
	based on requiring space for 17 macrotiles (HW max + 1) worth of depth/stencil data
*/
#define EURASIA_PARAM_MINIMUM_NONGLOBAL_SIZE	(((((EURASIA_RENDERSIZE_MAXX / 4) * (EURASIA_RENDERSIZE_MAXY / 4)) * 5) * 17) / EURASIA_PARAM_MANAGE_GRAN)

/*
	Margin needed by the PDS to reduce the number of partitions used by vertex tasks.
*/
#define EURASIA_PARAM_PDS_SAFETY_MARGIN			(256)

/* Register EUR_CR_CLKGATECTL */
#define EUR_CR_CLKGATECTL_OFF	0x00000000U
#define EUR_CR_CLKGATECTL_ON	0x00000001U
#define EUR_CR_CLKGATECTL_AUTO	0x00000002U

#if !defined(SGX545) && !defined(SGX540) && !defined(SGX541) && !defined(SGX543) && !defined(SGX531) && !defined(SGX544) && !defined(SGX554)
	#define EUR_CR_CLKGATECTL_2D_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_2D_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_2D_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_2D_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_2D_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_2D_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_ISP_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_ISP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_ISP_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_ISP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_ISP_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_ISP_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_TSP_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_TSP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TSP_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_TSP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TSP_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_TSP_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_TA_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_TA_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TA_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_TA_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TA_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_TA_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_DPM_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_DPM_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_DPM_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_DPM_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_DPM_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_DPM_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_USE_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_USE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_USE_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_USE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_USE_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_USE_CLKG_SHIFT)
#else /* #if !defined(SGX545) && !defined(SGX540) && !defined(SGX541) && !defined(SGX543) && !defined(SGX531) */
	#define EUR_CR_CLKGATECTL_ISP_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_ISP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_ISP_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_ISP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_ISP_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_ISP_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_ISP2_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_ISP2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_ISP2_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_ISP2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_ISP2_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_ISP2_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_TSP_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_TSP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TSP_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_TSP_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TSP_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_TSP_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_TE_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_TE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TE_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_TE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_TE_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_TE_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_MTE_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_MTE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_MTE_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_MTE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_MTE_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_MTE_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_DPM_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_DPM_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_DPM_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_DPM_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_DPM_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_DPM_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL_VDM_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_VDM_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_VDM_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_VDM_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL_VDM_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_VDM_CLKG_SHIFT)

	#if defined(SGX545)
		#define EUR_CR_CLKGATECTL_PDS0_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_PDS0_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_PDS0_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_PDS0_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_PDS0_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_PDS0_CLKG_SHIFT)
	#else
		#define EUR_CR_CLKGATECTL_PDS_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_PDS_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_PDS_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_PDS_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_PDS_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_PDS_CLKG_SHIFT)

		#define EUR_CR_CLKGATECTL_IDXFIFO_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_IDXFIFO_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_IDXFIFO_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_IDXFIFO_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_IDXFIFO_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_IDXFIFO_CLKG_SHIFT)
	#endif

	#if defined(SGX540) || defined(SGX541) || defined(SGX543) || defined(SGX531) || defined(SGX544) || defined(SGX554)
		#define EUR_CR_CLKGATECTL_SYSTEM_CLKG_ON		(1UL << EUR_CR_CLKGATECTL_SYSTEM_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_SYSTEM_CLKG_AUTO		(0UL << EUR_CR_CLKGATECTL_SYSTEM_CLKG_SHIFT)

		#define EUR_CR_CLKGATECTL_TA_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_TA_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_TA_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_TA_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_TA_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_TA_CLKG_SHIFT)
	#endif

	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
		#define EUR_CR_CLKGATECTL_BIF_CORE_CLKG_OFF			(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL_BIF_CORE_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_BIF_CORE_CLKG_ON			(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL_BIF_CORE_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL_BIF_CORE_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL_BIF_CORE_CLKG_SHIFT)
	#endif

	#define EUR_CR_CLKGATECTL2_PBE_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_PBE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_PBE_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_PBE_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_PBE_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_PBE_CLKG_SHIFT)

#if defined(SGX543) || defined(SGX544) || defined(SGX554)
	#define EUR_CR_CLKGATECTL2_TCU_L2_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_TCU_L2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_TCU_L2_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_TCU_L2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_TCU_L2_CLKG_AUTO		(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_TCU_L2_CLKG_SHIFT)
#else
	#define EUR_CR_CLKGATECTL2_CACHEL2_CLKG_OFF		(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_CACHEL2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_CACHEL2_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_CACHEL2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_CACHEL2_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_CACHEL2_CLKG_SHIFT)
#endif

	#define EUR_CR_CLKGATECTL2_UCACHEL2_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_UCACHEL2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_UCACHEL2_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_UCACHEL2_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_UCACHEL2_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_UCACHEL2_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL2_USE0_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_USE0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_USE0_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_USE0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_USE0_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_USE0_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL2_ITR0_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_ITR0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_ITR0_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_ITR0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_ITR0_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_ITR0_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL2_TEX0_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_TEX0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_TEX0_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_TEX0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_TEX0_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_TEX0_CLKG_SHIFT)

#if !defined(SGX543) && !defined(SGX544) && !defined(SGX554)
	#define EUR_CR_CLKGATECTL2_MADD0_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_MADD0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_MADD0_CLKG_ON	(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_MADD0_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_MADD0_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_MADD0_CLKG_SHIFT)
#endif

	#define EUR_CR_CLKGATECTL2_USE1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_USE1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_USE1_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_USE1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_USE1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_USE1_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL2_ITR1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_ITR1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_ITR1_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_ITR1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_ITR1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_ITR1_CLKG_SHIFT)

	#define EUR_CR_CLKGATECTL2_TEX1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_TEX1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_TEX1_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_TEX1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_TEX1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_TEX1_CLKG_SHIFT)

#if !defined(SGX543) && !defined(SGX544) && !defined(SGX554)
	#define EUR_CR_CLKGATECTL2_MADD1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_MADD1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_MADD1_CLKG_ON	(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_MADD1_CLKG_SHIFT)
	#define EUR_CR_CLKGATECTL2_MADD1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_MADD1_CLKG_SHIFT)
#endif

	#if defined(SGX545)
		#define EUR_CR_CLKGATECTL2_PDS1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_PDS1_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_PDS1_CLKG_ON		(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_PDS1_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_PDS1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_PDS1_CLKG_SHIFT)
	#endif

	#if defined(SGX543) || defined(SGX544) || defined(SGX554)
		#define EUR_CR_CLKGATECTL2_DCU_L2_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_DCU_L2_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_DCU_L2_CLKG_ON	(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_DCU_L2_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_DCU_L2_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_DCU_L2_CLKG_SHIFT)

		#define EUR_CR_CLKGATECTL2_DCU1_L0L1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_DCU1_L0L1_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_DCU1_L0L1_CLKG_ON	(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_DCU1_L0L1_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_DCU1_L0L1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_DCU1_L0L1_CLKG_SHIFT)

		#define EUR_CR_CLKGATECTL2_DCU0_L0L1_CLKG_OFF	(EUR_CR_CLKGATECTL_OFF << EUR_CR_CLKGATECTL2_DCU0_L0L1_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_DCU0_L0L1_CLKG_ON	(EUR_CR_CLKGATECTL_ON << EUR_CR_CLKGATECTL2_DCU0_L0L1_CLKG_SHIFT)
		#define EUR_CR_CLKGATECTL2_DCU0_L0L1_CLKG_AUTO	(EUR_CR_CLKGATECTL_AUTO << EUR_CR_CLKGATECTL2_DCU0_L0L1_CLKG_SHIFT)

	#endif
#endif /* #if !defined(SGX545) && !defined(SGX540) && !defined(SGX541) && !defined(SGX530) && !defined(SGX531) */

/* Register EUR_CR_BIF_CTRL */
#define EUR_CR_BIF_CTRL_MMU_BYPASS_MASK		0x0001FF00U
#if !defined(EUR_CR_BIF_CTRL_MMU_BYPASS_HOST_MASK)
#define EUR_CR_BIF_CTRL_MMU_BYPASS_HOST_MASK 0U
#endif

/* Register EUR_CR_DPM_REQUESTING */
#define EUR_CR_DPM_REQUESTING_SOURCE_TE		0x00000001
#define EUR_CR_DPM_REQUESTING_SOURCE_MTE	0x00000002

/* Register EUR_CR_FRAME_DELIMITER */
#define EUR_CR_FRAME_DELIMITER				0x1000
#define EUR_CR_FRAME_DELIMITER_MASK			0xFFFFFFFFU
#define EUR_CR_FRAME_DELIMITER_SHIFT		0

#if defined(SGX545)
/* Register EUR_CR_VDM_VTXBUF_WRPTR_PDSPROG */
#define EUR_CR_VDM_VTXBUF_WRPTR_PDSPROG_BASE_ADDR_ALIGNSHIFT 4
#define EUR_CR_VDM_VTXBUF_WRPTR_PDSPROG_DATASIZE_ALIGNSHIFT 4

/* Register EUR_CR_VDM_ITP_PDSPROG */
#define EUR_CR_VDM_ITP_PDSPROG_BASE_ADDR_ALIGNSHIFT 4
#define EUR_CR_VDM_ITP_PDSPROG_DATASIZE_ALIGNSHIFT 4

/* Register EUR_CR_MTE_1ST_PHASE_COMPLEX_BASE */
#define EUR_CR_MTE_1ST_PHASE_COMPLEX_BASE_ADDR_ALIGNSHIFT 0

/* Register EUR_CR_GSG */
#define EUR_CR_GSG_BASE_ADDR_ALIGNSHIFT     6
#define EUR_CR_GSG_STRIDE_ALIGNSHIFT        10

/* Register EUR_CR_GSG_STORE */
#define EUR_CR_GSG_WRAP_ADDR_ALIGNSHIFT     0
#define EUR_CR_GSG_STORE_BASE_ADDR_ALIGNSHIFT 6
#endif /* defined(SGX545) */

/*****************************************************************************
 Start of 2D Blt Module
*****************************************************************************/

/*****************************************************************************
 2D Slave Port Data : Block Header's Object Type
*****************************************************************************/
#define EURASIA2D_CLIP_BH		(0x00000000U) // 0000 - clip definition
#define EURASIA2D_PAT_BH		(0x10000000U) // 0001 - pattern control
#define EURASIA2D_CTRL_BH		(0x20000000U) // 0010 - 2d control (CK & Alpha state info)
#define EURASIA2D_SRC_OFF_BH	(0x30000000U) // 0011 - source offset
#define EURASIA2D_MASK_OFF_BH	(0x40000000U) // 0100 - mask offset
#define EURASIA2D_RESERVED1_BH	(0x50000000U) // 0101 - object type is reserved
#define EURASIA2D_RESERVED2_BH	(0x60000000U) // 0110 - object type is reserved
#define EURASIA2D_FENCE_BH		(0x70000000U) // 0111 - 2d fence
#define EURASIA2D_BLIT_BH		(0x80000000U) // 1000 - blit rectangle
#define EURASIA2D_SRC_SURF_BH	(0x90000000U) // 1001 - source  surface
#define EURASIA2D_DST_SURF_BH	(0xA0000000U) // 1010 - dest    surface
#define EURASIA2D_PAT_SURF_BH	(0xB0000000U) // 1011 - pattern surface
#define EURASIA2D_SRC_PAL_BH	(0xC0000000U) // 1100 - source  PALETTE
#define EURASIA2D_PAT_PAL_BH	(0xD0000000U) // 1101 - pattern PALETTE
#define EURASIA2D_MASK_SURF_BH	(0xE0000000U) // 1110 - mask    surface
#define EURASIA2D_FLUSH_BH		(0xF0000000U) // 1111 - flush 2d blits and generate interrupt


/*****************************************************************************
 Clip Definition block (EURASIA2D_CLIP_BH)
*****************************************************************************/
#define EURASIA2D_CLIPCOUNT_MAX			(1)          // only 1 clipping rectangle
#define EURASIA2D_CLIPCOUNT_MASK		(0x00000000U) // clip count mask has no effect
#define EURASIA2D_CLIPCOUNT_CLRMASK		(0xFFFFFFFFU) // clip count clear mask has no effect
#define EURASIA2D_CLIPCOUNT_SHIFT		(0)          // clip count shift has no effect
// clip rectangle min & max
#define EURASIA2D_CLIP_XMAX_MASK		(0x00FFF000U)
#define EURASIA2D_CLIP_XMAX_CLRMASK 	(0xFF000FFFU)
#define EURASIA2D_CLIP_XMAX_SHIFT		(12)
#define EURASIA2D_CLIP_XMIN_MASK		(0x00000FFFU)
#define EURASIA2D_CLIP_XMIN_CLRMASK 	(0x00FFF000U)
#define EURASIA2D_CLIP_XMIN_SHIFT		(0)
// clip rectangle offset
#define EURASIA2D_CLIP_YMAX_MASK		(0x00FFF000U)
#define EURASIA2D_CLIP_YMAX_CLRMASK 	(0xFF000FFFU)
#define EURASIA2D_CLIP_YMAX_SHIFT		(12)
#define EURASIA2D_CLIP_YMIN_MASK		(0x00000FFFU)
#define EURASIA2D_CLIP_YMIN_CLRMASK 	(0x00FFF000U)
#define EURASIA2D_CLIP_YMIN_SHIFT		(0)

/*****************************************************************************
 Pattern Control (EURASIA2D_PAT_BH)
*****************************************************************************/
#define EURASIA2D_PAT_HEIGHT_MASK	(0x0000001FU)
#define EURASIA2D_PAT_HEIGHT_SHIFT	(0)
#define EURASIA2D_PAT_WIDTH_MASK	(0x000003E0U)
#define EURASIA2D_PAT_WIDTH_SHIFT	(5)
#define EURASIA2D_PAT_YSTART_MASK	(0x00007C00U)
#define EURASIA2D_PAT_YSTART_SHIFT	(10)
#define EURASIA2D_PAT_XSTART_MASK	(0x000F8000U)
#define EURASIA2D_PAT_XSTART_SHIFT	(15)

/*****************************************************************************
 2D Control block (EURASIA2D_CTRL_BH)
*****************************************************************************/
// Present Flags
#define EURASIA2D_SRCCK_CTRL		(0x00000001U)
#define EURASIA2D_DSTCK_CTRL		(0x00000002U)
#define EURASIA2D_ALPHA_CTRL		(0x00000004U)
// Colour Key Colour (SRC/DST)
#define EURASIA2D_CK_COL_MASK		(0xFFFFFFFFU)
#define EURASIA2D_CK_COL_CLRMASK	(0x00000000U)
#define EURASIA2D_CK_COL_SHIFT		(0)
// Colour Key Mask (SRC/DST)
#define EURASIA2D_CK_MASK_MASK		(0xFFFFFFFFU)
#define EURASIA2D_CK_MASK_CLRMASK	(0x00000000U)
#define EURASIA2D_CK_MASK_SHIFT		(0)
// Alpha Control (Alpha/RGB)
#define EURASIA2D_GBLALPHA_MASK			(0x000FF000U)
#define EURASIA2D_GBLALPHA_CLRMASK		(0xFFF00FFFU)
#define EURASIA2D_GBLALPHA_SHIFT		(12)
#define EURASIA2D_SRCALPHA_OP_MASK		(0x00700000U)
#define EURASIA2D_SRCALPHA_OP_CLRMASK	(0xFF8FFFFFU)
#define EURASIA2D_SRCALPHA_OP_SHIFT		(20)
#define EURASIA2D_SRCALPHA_OP_ONE		(0x00000000U)
#define EURASIA2D_SRCALPHA_OP_SRC		(0x00100000U)
#define EURASIA2D_SRCALPHA_OP_DST		(0x00200000U)
#define EURASIA2D_SRCALPHA_OP_SG		(0x00300000U)
#define EURASIA2D_SRCALPHA_OP_DG		(0x00400000U)
#define EURASIA2D_SRCALPHA_OP_GBL		(0x00500000U)
#define EURASIA2D_SRCALPHA_OP_ZERO		(0x00600000U)
#define EURASIA2D_SRCALPHA_INVERT		(0x00800000U)
#define EURASIA2D_SRCALPHA_INVERT_CLR	(0xFF7FFFFFU)
#define EURASIA2D_DSTALPHA_OP_MASK		(0x07000000U)
#define EURASIA2D_DSTALPHA_OP_CLRMASK	(0xF8FFFFFFU)
#define EURASIA2D_DSTALPHA_OP_SHIFT		(24)
#define EURASIA2D_DSTALPHA_OP_ONE		(0x00000000U)
#define EURASIA2D_DSTALPHA_OP_SRC		(0x01000000U)
#define EURASIA2D_DSTALPHA_OP_DST		(0x02000000U)
#define EURASIA2D_DSTALPHA_OP_SG		(0x03000000U)
#define EURASIA2D_DSTALPHA_OP_DG		(0x04000000U)
#define EURASIA2D_DSTALPHA_OP_GBL		(0x05000000U)
#define EURASIA2D_DSTALPHA_OP_ZERO		(0x06000000U)
#define EURASIA2D_DSTALPHA_INVERT		(0x08000000U)
#define EURASIA2D_DSTALPHA_INVERT_CLR	(0xF7FFFFFFU)

#define EURASIA2D_PRE_MULTIPLICATION_ENABLE		(0x10000000U)
#define EURASIA2D_PRE_MULTIPLICATION_CLRMASK	(0xEFFFFFFFU)
#define EURASIA2D_ZERO_SOURCE_ALPHA_ENABLE		(0x20000000U)
#define EURASIA2D_ZERO_SOURCE_ALPHA_CLRMASK		(0xDFFFFFFFU)

/*****************************************************************************
 Source Offset (EURASIA2D_SRC_OFF_BH)
*****************************************************************************/
#define EURASIA2D_SRCOFF_XSTART_MASK	((0x00000FFFUL) << 12) // (0x00FFF000)
#define EURASIA2D_SRCOFF_XSTART_SHIFT	(12)
#define EURASIA2D_SRCOFF_YSTART_MASK	(0x00000FFFU)
#define EURASIA2D_SRCOFF_YSTART_SHIFT	(0)

/*****************************************************************************
 Mask Offset (EURASIA2D_MASK_OFF_BH)
*****************************************************************************/
#define EURASIA2D_MASKOFF_XSTART_MASK	((0x00000FFFUL) << 12) // (0x00FFF000)
#define EURASIA2D_MASKOFF_XSTART_SHIFT	(12)
#define EURASIA2D_MASKOFF_YSTART_MASK	(0x00000FFFU)
#define EURASIA2D_MASKOFF_YSTART_SHIFT	(0)

/*****************************************************************************
 Reserved1 - DO NOT USE (in MBX1 used to be called Mask Size)
*****************************************************************************/

/*****************************************************************************
 Reserved2 - DO NOT USE (in MBX1 used to be called Stretch)
*****************************************************************************/

/*****************************************************************************
 2D Fence (see EURASIA2D_FENCE_BH): bits 0:27 are ignored
*****************************************************************************/

/*****************************************************************************
 Blit Rectangle (EURASIA2D_BLIT_BH)
*****************************************************************************/
// Rotation
#define EURASIA2D_ROT_MASK			(3UL<<25)
#define EURASIA2D_ROT_CLRMASK		(~EURASIA2D_ROT_MASK)
#define EURASIA2D_ROT_NONE			(0UL<<25)
#define EURASIA2D_ROT_90DEGS		(1UL<<25)
#define EURASIA2D_ROT_180DEGS		(2UL<<25)
#define EURASIA2D_ROT_270DEGS		(3UL<<25)
// Copy order (backwards blt)
#define EURASIA2D_COPYORDER_MASK	(3UL<<23)
#define EURASIA2D_COPYORDER_CLRMASK	(~EURASIA2D_COPYORDER_MASK)
#define EURASIA2D_COPYORDER_TL2BR	(0UL<<23)
#define EURASIA2D_COPYORDER_BR2TL	(1UL<<23)
#define EURASIA2D_COPYORDER_TR2BL	(2UL<<23)
#define EURASIA2D_COPYORDER_BL2TR	(3UL<<23)
// DST colour key
#define EURASIA2D_DSTCK_CLRMASK		(0xFF9FFFFFU)
#define EURASIA2D_DSTCK_DISABLE		(0x00000000U)
#define EURASIA2D_DSTCK_PASS		(0x00200000U)
#define EURASIA2D_DSTCK_REJECT		(0x00400000U)
// SRC colour key
#define EURASIA2D_SRCCK_CLRMASK		(0xFFE7FFFFU)
#define EURASIA2D_SRCCK_DISABLE		(0x00000000U)
#define EURASIA2D_SRCCK_PASS		(0x00080000U)
#define EURASIA2D_SRCCK_REJECT		(0x00100000U)
// clipping control
#define EURASIA2D_CLIP_ENABLE		(0x00040000U)
// alpha control
#define EURASIA2D_ALPHA_ENABLE		(0x00020000U)
// pattern control
#define EURASIA2D_PAT_CLRMASK		(0xFFFEFFFFU)
#define EURASIA2D_PAT_MASK			(0x00010000U)
#define EURASIA2D_USE_PAT			(0x00010000U)
#define EURASIA2D_USE_FILL			(0x00000000U)
// rop code B
#define EURASIA2D_ROP3B_MASK		(0x0000FF00U)
#define EURASIA2D_ROP3B_CLRMASK		(0xFFFF00FFU)
#define EURASIA2D_ROP3B_SHIFT		(8)
// rop code A
#define EURASIA2D_ROP3A_MASK		(0x000000FFU)
#define EURASIA2D_ROP3A_CLRMASK		(0xFFFFFF00U)
#define EURASIA2D_ROP3A_SHIFT		(0)
// equivalent rop4 mask
#define EURASIA2D_ROP4_MASK			(0x0000FFFFU)

/*
	DWORD0:	(Only pass if Pattern control == Use Fill Colour)
  	Fill Colour RGBA8888
*/
#define EURASIA2D_FILLCOLOUR_MASK	(0xFFFFFFFFU)
#define EURASIA2D_FILLCOLOUR_SHIFT	(0)
/*
	DWORD1: (Always Present)
	X Start (Dest)
	Y Start (Dest)
*/
#define EURASIA2D_DST_XSTART_MASK		(0x00FFF000U)
#define EURASIA2D_DST_XSTART_CLRMASK	(0xFF000FFFU)
#define EURASIA2D_DST_XSTART_SHIFT		(12)
#define EURASIA2D_DST_YSTART_MASK		(0x00000FFFU)
#define EURASIA2D_DST_YSTART_CLRMASK	(0xFFFFF000U)
#define EURASIA2D_DST_YSTART_SHIFT		(0)
/*
	DWORD2: (Always Present)
	X Size (Dest)
	Y Size (Dest)
*/
#define EURASIA2D_DST_XSIZE_MASK		(0x00FFF000U)
#define EURASIA2D_DST_XSIZE_CLRMASK		(0xFF000FFFU)
#define EURASIA2D_DST_XSIZE_SHIFT		(12)
#define EURASIA2D_DST_YSIZE_MASK		(0x00000FFFU)
#define EURASIA2D_DST_YSIZE_CLRMASK		(0xFFFFF000U)
#define EURASIA2D_DST_YSIZE_SHIFT		(0)


/*****************************************************************************
 Source Surface (EURASIA2D_SRC_SURF_BH)
*****************************************************************************/
/* WORD 0 */
// source pixel format
#define EURASIA2D_SRC_FORMAT_MASK		(0x00078000U)
#define EURASIA2D_SRC_1_PAL				(0x00000000U)
#define EURASIA2D_SRC_2_PAL				(0x00008000U)
#define EURASIA2D_SRC_4_PAL				(0x00010000U)
#define EURASIA2D_SRC_8_PAL			    (0x00018000U)
#define EURASIA2D_SRC_8_ALPHA			(0x00020000U)
#define EURASIA2D_SRC_4_ALPHA			(0x00028000U)
#define EURASIA2D_SRC_332RGB			(0x00030000U)
#define EURASIA2D_SRC_4444ARGB			(0x00038000U)
#define EURASIA2D_SRC_555RGB			(0x00040000U)
#define EURASIA2D_SRC_1555ARGB			(0x00048000U)
#define EURASIA2D_SRC_565RGB			(0x00050000U)
#define EURASIA2D_SRC_0888ARGB			(0x00058000U)
#define EURASIA2D_SRC_8888ARGB			(0x00060000U)
#define EURASIA2D_SRC_8888UYVY			(0x00068000U)
#define EURASIA2D_SRC_RESERVED			(0x00070000U)
#define EURASIA2D_SRC_1555ARGB_LOOKUP	(0x00078000U)

// source stride
#define EURASIA2D_SRC_STRIDE_MASK		(0x00007FFFU)
#define EURASIA2D_SRC_STRIDE_CLRMASK	(0xFFFF8000U)
#define EURASIA2D_SRC_STRIDE_SHIFT		(0)

// source pixel unpack mode
#define EURASIA2D_SRC_UNPACK_MASK		(0x00100000U)
#define EURASIA2D_SRC_UNPACK_CLRMASK	(0xFFEFFFFFU)
#define EURASIA2D_SRC_UNPACK_SHIFT		(20)
#define EURASIA2D_SRC_UNPACK_NEAREST	(0x00000000U)
#define EURASIA2D_SRC_UNPACK_TRUNCATE	(0x00100000U)

/*
	WORD 1 - Base Address
*/
#define EURASIA2D_SRC_ADDR_MASK			(0x0FFFFFFCU)
#define EURASIA2D_SRC_ADDR_CLRMASK		(0x00000003U)
#define EURASIA2D_SRC_ADDR_SHIFT		(2)
#define EURASIA2D_SRC_ADDR_ALIGNSHIFT	(2)


/*****************************************************************************
Pattern Surface (EURASIA2D_PAT_SURF_BH)
*****************************************************************************/
/* WORD 0 */
// pattern pixel format
#define EURASIA2D_PAT_FORMAT_MASK		(0x00078000U)
#define EURASIA2D_PAT_1_PAL				(0x00000000U)
#define EURASIA2D_PAT_2_PAL				(0x00008000U)
#define EURASIA2D_PAT_4_PAL				(0x00010000U)
#define EURASIA2D_PAT_8_PAL				(0x00018000U)
#define EURASIA2D_PAT_8_ALPHA			(0x00020000U)
#define EURASIA2D_PAT_4_ALPHA			(0x00028000U)
#define EURASIA2D_PAT_332RGB			(0x00030000U)
#define EURASIA2D_PAT_4444ARGB			(0x00038000U)
#define EURASIA2D_PAT_555RGB			(0x00040000U)
#define EURASIA2D_PAT_1555ARGB			(0x00048000U)
#define EURASIA2D_PAT_565RGB			(0x00050000U)
#define EURASIA2D_PAT_0888ARGB			(0x00058000U)
// pattern stride
#define EURASIA2D_PAT_STRIDE_MASK		(0x00007FFFU)
#define EURASIA2D_PAT_STRIDE_CLRMASK	(0xFFFF8000U)
#define EURASIA2D_PAT_STRIDE_SHIFT		(0)
/*
	WORD 1 - Base Address
*/
#define EURASIA2D_PAT_ADDR_MASK			(0x0FFFFFFCU)
#define EURASIA2D_PAT_ADDR_CLRMASK		(0x00000003U)
#define EURASIA2D_PAT_ADDR_SHIFT		(2)
#define EURASIA2D_PAT_ADDR_ALIGNSHIFT	(2)


/*****************************************************************************
 Destination Surface (EURASIA2D_DST_SURF_BH)
*****************************************************************************/
/* WORD 0 */
// dest pixel format
#define EURASIA2D_DST_FORMAT_MASK		(0x00078000U)
#define EURASIA2D_DST_332RGB			(0x00030000U)
#define EURASIA2D_DST_4444ARGB			(0x00038000U)
#define EURASIA2D_DST_555RGB			(0x00040000U)
#define EURASIA2D_DST_1555ARGB			(0x00048000U)
#define EURASIA2D_DST_565RGB			(0x00050000U)
#define EURASIA2D_DST_0888ARGB			(0x00058000U)
#define EURASIA2D_DST_8888ARGB			(0x00060000U)
#define EURASIA2D_DST_8888AYUV			(0x00070000U)
// dest stride
#define EURASIA2D_DST_STRIDE_MASK		(0x00007FFFU)
#define EURASIA2D_DST_STRIDE_CLRMASK	(0xFFFF8000U)
#define EURASIA2D_DST_STRIDE_SHIFT		(0)
/*
	WORD 1 - Base Address
*/
#define EURASIA2D_DST_ADDR_MASK			(0x0FFFFFFCU)
#define EURASIA2D_DST_ADDR_CLRMASK		(0x00000003U)
#define EURASIA2D_DST_ADDR_SHIFT		(2)
#define EURASIA2D_DST_ADDR_ALIGNSHIFT	(2)


/*****************************************************************************
 Mask Surface (EURASIA2D_MASK_SURF_BH)
*****************************************************************************/
/* WORD 0 */
#define EURASIA2D_MASK_STRIDE_MASK		(0x00007FFFU)
#define EURASIA2D_MASK_STRIDE_CLRMASK	(0xFFFF8000U)
#define EURASIA2D_MASK_STRIDE_SHIFT		(0)
/*
	WORD 1 - Base Address
*/
#define EURASIA2D_MASK_ADDR_MASK		(0x0FFFFFFCU)
#define EURASIA2D_MASK_ADDR_CLRMASK		(0x00000003U)
#define EURASIA2D_MASK_ADDR_SHIFT		(2)
#define EURASIA2D_MASK_ADDR_ALIGNSHIFT	(2)


/*****************************************************************************
 Source Palette (EURASIA2D_SRC_PAL_BH)
*****************************************************************************/
// base address (byte address aligned to 1024 bytes i.e. 128-bit aligned address)
#define EURASIA2D_SRCPAL_ADDR_SHIFT			(0)
#define EURASIA2D_SRCPAL_ADDR_CLRMASK		(0xF0000007U)
#define EURASIA2D_SRCPAL_ADDR_MASK			(0x0FFFFFF8U)
#define EURASIA2D_SRCPAL_BYTEALIGN			(1024)

/*****************************************************************************
 Pattern Palette (EURASIA2D_PAT_PAL_BH)
*****************************************************************************/
// base address (byte address aligned to 1024 bytes i.e. 128-bit aligned address)
#define EURASIA2D_PATPAL_ADDR_SHIFT			(0)
#define EURASIA2D_PATPAL_ADDR_CLRMASK		(0xF0000007U)
#define EURASIA2D_PATPAL_ADDR_MASK			(0x0FFFFFF8U)
#define EURASIA2D_PATPAL_BYTEALIGN			(1024)


/*****************************************************************************
 Rop3 Codes (2 LS bytes)
*****************************************************************************/
#define EURASIA2D_ROP3_SRCCOPY				(0xCCCC)
#define EURASIA2D_ROP3_PATCOPY				(0xF0F0)
#define EURASIA2D_ROP3_WHITENESS			(0xFFFF)
#define EURASIA2D_ROP3_BLACKNESS			(0x0000)

/*****************************************************************************
 Register bit field defs
*****************************************************************************/

/* EUR_CR_2D_TEST_MODE bit field defs */
#define EUR_CR_2D_TEST_MODE_FB				0
#define EUR_CR_2D_TEST_MODE_SIGREG			1
#define EUR_CR_2D_TEST_MODE_FB_AND_SIGREG	2

/*****************************************************************************
 BIF Tiling
*****************************************************************************/
#if defined(EUR_CR_BIF_TILE0)
	#define EUR_CR_BIF_TILE0_ENABLE 0x8
	#define SGX_BIF_NUM_TILING_RANGES 10
#endif

#endif /* _SGXDEFS_H_ */

/******************************************************************************
 End of file (sgxdefs.h)
******************************************************************************/
