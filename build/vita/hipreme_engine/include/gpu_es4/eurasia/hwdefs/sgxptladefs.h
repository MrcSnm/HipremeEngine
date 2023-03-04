/******************************************************************************
 * Name         : sgxptladefs.h
 * Title        : SGX PTLA (Present and Texture Load Accelerator) HW definitions
 *
 * Copyright    : 2009 by Imagination Technologies Limited.
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
 * $Log: sgxptladefs.h $
 *****************************************************************************/

#ifndef _SGXPTLADEFS_H_
#define _SGXPTLADEFS_H_

/*****************************************************************************
 PTLA pixel formats
*****************************************************************************/
#define EURASIA_PTLA_FORMAT_U8					0x00U // monochrome unsigned 8 bit
#define EURASIA_PTLA_FORMAT_4444ARGB			0x01U // 16 bit 4444
#define EURASIA_PTLA_FORMAT_1555ARGB			0x02U // 16 bit 1555
#define EURASIA_PTLA_FORMAT_565RGB				0x03U // 16 bit 565
#define EURASIA_PTLA_FORMAT_U88					0x04U // unsigned 8 bit 2 channels
#define EURASIA_PTLA_FORMAT_888RGB				0x05U // 24 bit RGB
#define EURASIA_PTLA_FORMAT_8888ARGB			0x06U // 32 bit ARGB
#define EURASIA_PTLA_FORMAT_YUV422_YUYV			0x07U // YUV 422 low-high byte order Y0UY1V
#define EURASIA_PTLA_FORMAT_YUV422_UYVY			0x08U // YUV 422 low-high byte order UY0VY1
#define EURASIA_PTLA_FORMAT_YUV422_YVYU			0x09U // YUV 422 low-high byte order Y0VY1U
#define EURASIA_PTLA_FORMAT_YUV422_VYUY			0x0AU // YUV 422 low-high byte order VY0UY1
#define EURASIA_PTLA_FORMAT_YUV420_2PLANE		0x0BU // YUV420 2 Plane
#define EURASIA_PTLA_FORMAT_YUV420_3PLANE		0x0CU // YUV420 3 Plane
#define EURASIA_PTLA_FORMAT_2101010ARGB			0x0DU // 32 bit 2 10 10 10
#define EURASIA_PTLA_FORMAT_S8					0x0EU // signed 8 bit
#define EURASIA_PTLA_FORMAT_16BPP_RAW			0x0FU // 16 bit raw (no format conversion)
#define EURASIA_PTLA_FORMAT_888RSGSBS			0x10U // signed 24 bit rgb
#define EURASIA_PTLA_FORMAT_32BPP_RAW			0x11U // 32 bit raw
#define EURASIA_PTLA_FORMAT_64BPP_RAW			0x12U // 64 bit raw
#define EURASIA_PTLA_FORMAT_128BPP_RAW			0x13U // 128 bit raw

#define EURASIA_PTLA_FORMAT_MAX					0x13U


/*****************************************************************************
 PTLA Command Stream Block Headers
*****************************************************************************/
#define EURASIA_PTLA_CTRL_BH					0x00000000U			// 0000 - control for upscale and colour key
#define EURASIA_PTLA_SRCOFF_BH					0x10000000U			// 0001 - source offset
#define EURASIA_PTLA_SRCOFF_YUV2_BH				0x20000000U			// 0010 - two planer yuv source offset
#define EURASIA_PTLA_SRCOFF_YUV3_BH				0x30000000U			// 0011 - three planer yuv source offset
#define EURASIA_PTLA_SRC_SURF_BH				0x40000000U			// 0100 - source surface
#define EURASIA_PTLA_DST_SURF_BH				0x50000000U			// 0101 - destination surface
#define EURASIA_PTLA_BLIT_BH					0x60000000U			// 0110 - blt rectangle and kicker
#define EURASIA_PTLA_FENCE_BH					0x70000000U			// 0111 - fence
#define EURASIA_PTLA_FLUSH_BH					0x80000000U			// 1111 - flush (fence with interrupt)

#define EURASIA_PTLA_HEADER_MASK				0xF0000000U

/*****************************************************************************
 PTLA Control block for upscale and colour key commands (EURASIA_PTLA_CTRL_BH)
*****************************************************************************/
// Control Data Present Flags
#define EURASIA_PTLA_CTRL_UPSCALE				0x00000001U
#define EURASIA_PTLA_CTRL_SRC_CKEY				0x00000002U
// Source Colour Key Colour
#define EURASIA_PTLA_CTRL_SRC_CKEY_MASK			0xFFFFFFFFU			// Colour Key colour (8888 format)
#define EURASIA_PTLA_CTRL_SRC_CKEY_SHIFT		0
// Source Colour Key Mask
#define EURASIA_PTLA_CTRL_SRC_KEYMASK_MASK		0xFFFFFFFFU			// Colour Key mask (8888 format)
#define EURASIA_PTLA_CTRL_SRC_KEYMASK_SHIFT		0
// Upscale
#define EURASIA_PTLA_CTRL_UPSCALE_ALPHA_X_MASK	0x000FFC00U			// X upscale factor (4.6 format)
#define EURASIA_PTLA_CTRL_UPSCALE_ALPHA_X_SHIFT	10
#define EURASIA_PTLA_CTRL_UPSCALE_ALPHA_Y_MASK	0x000003FFU			// Y upscale factor (4.6 format)
#define EURASIA_PTLA_CTRL_UPSCALE_ALPHA_Y_SHIFT	0

/*****************************************************************************
 Source Offset command EURASIA_PTLA_SRC_OFF_BH
 Also for EURASIA_PTLA_SRCOFF_YUV2_BH and EURASIA_PTLA_SRCOFF_YUV3_BH
*****************************************************************************/
// Source offset
#define EURASIA_PTLA_SRCOFF_XSTART_MASK			(0x1FFFU << 13)	// Source X Start (pixels)
#define EURASIA_PTLA_SRCOFF_XSTART_SHIFT		13
#define EURASIA_PTLA_SRCOFF_YSTART_MASK			0x1FFFU			// Source Y Start (pixels)
#define EURASIA_PTLA_SRCOFF_YSTART_SHIFT		0
// Source size
#define EURASIA_PTLA_SRCOFF_XSIZE_MASK			(0x1FFFU << 13)	// Source X Size (pixels)
#define EURASIA_PTLA_SRCOFF_XSIZE_SHIFT			13
#define EURASIA_PTLA_SRCOFF_YSIZE_MASK			0x1FFFU			// Source Y Size (pixels)
#define EURASIA_PTLA_SRCOFF_YSIZE_SHIFT			0

/*****************************************************************************
 PTLA Surface defs for EURASIA_PTLA_SRC_SURF_BH and EURASIA_PTLA_DST_SURF_BH
*****************************************************************************/
// Surface layout
#define EURASIA_PTLA_SURF_LAYOUT_STRIDED		0x00U
#define EURASIA_PTLA_SURF_LAYOUT_TILED			0x01U
#define EURASIA_PTLA_SURF_LAYOUT_TWIDDLED		0x02U
#define EURASIA_PTLA_SURF_LAYOUT_SHIFT			22
#define EURASIA_PTLA_SURF_LAYOUT_MASK			0x00C00000U
#define EURASIA_PTLA_SURF_LAYOUT_CLRMASK		(~EURASIA_PTLA_SURF_TYPE_MASK)
// Surface pixel format
#define EURASIA_PTLA_SURF_FORMAT_SHIFT			16
#define EURASIA_PTLA_SURF_FORMAT_MASK			0x003F0000U
// Surface stride
#define EURASIA_PTLA_SURF_STRIDE_MASK			0x0000FFFFU
#define EURASIA_PTLA_SURF_STRIDE_CLRMASK		(~EURASIA_PTLA_SURF_STRIDE_MASK)
#define EURASIA_PTLA_SURF_STRIDE_SHIFT			0

/*****************************************************************************
 Blit rectangle command EURASIA_PTLA_BLIT_BH    (this also kicks the blt)
*****************************************************************************/
// Copy order (backwards blt)
#define EURASIA_PTLA_COPYORDER_MASK				3U
#define EURASIA_PTLA_COPYORDER_CLRMASK			(~EURASIA_PTLA_COPYORDER_MASK)
#define EURASIA_PTLA_COPYORDER_TL2BR			0U
#define EURASIA_PTLA_COPYORDER_BR2TL			1U
#define EURASIA_PTLA_COPYORDER_TR2BL			2U
#define EURASIA_PTLA_COPYORDER_BL2TR			3U
// Rotation
#define EURASIA_PTLA_ROT_SHIFT					2
#define EURASIA_PTLA_ROT_MASK					(3U<<EURASIA_PTLA_ROT_SHIFT)
#define EURASIA_PTLA_ROT_CLRMASK				(~EURASIA_PTLA_ROT_MASK)
#define EURASIA_PTLA_ROT_NONE					(0U<<EURASIA_PTLA_ROT_SHIFT)
#define EURASIA_PTLA_ROT_90DEGS					(1U<<EURASIA_PTLA_ROT_SHIFT)
#define EURASIA_PTLA_ROT_180DEGS				(2U<<EURASIA_PTLA_ROT_SHIFT)
#define EURASIA_PTLA_ROT_270DEGS				(3U<<EURASIA_PTLA_ROT_SHIFT)
// Fill control
#define EURASIA_PTLA_FILL_MASK					(1U<<4)
#define EURASIA_PTLA_FILL_CLRMASK				(~EURASIA_PTLA_FILL_MASK)
#define EURASIA_PTLA_FILL_ENABLE				(1U<<4)
// Enable SRC colour key
#define EURASIA_PTLA_SRCCK_MASK					(1U<<5)
#define EURASIA_PTLA_SRCCK_CLRMASK				(~EURASIA_PTLA_SRCCK_MASK)
#define EURASIA_PTLA_SRCCK_ENABLE				(1U<<5)
// Upscale control
#define EURASIA_PTLA_UPSCALE_MASK				(1U<<6)
#define EURASIA_PTLA_UPSCALE_CLRMASK			(~EURASIA_PTLA_UPSCALE_MASK)
#define EURASIA_PTLA_UPSCALE_ENABLE				(1U<<6)
// Downscale control
#define EURASIA_PTLA_DOWNSCALE_MASK				(1U<<7)
#define EURASIA_PTLA_DOWNSCALE_CLRMASK			(~EURASIA_PTLA_DOWNSCALE_MASK)
#define EURASIA_PTLA_DOWNSCALE_ENABLE			(1U<<7)
// Colour key pass/reject op
#define EURASIA_PTLA_SRCCK_PASS_MASK			(1U<<8)
#define EURASIA_PTLA_SRCCK_PASS_CLRMASK			(~EURASIA_PTLA_SRCCK_PASS_MASK)
#define EURASIA_PTLA_SRCCK_PASS_ENABLE			(1U<<8)
// Fill colour RGBA8888 (only required if EURASIA_PTLA_FILL_ENABLE is set)
#define EURASIA_PTLA_FILLCOLOUR_MASK			0xFFFFFFFFU
#define EURASIA_PTLA_FILLCOLOUR_SHIFT			0
//	Dest X start (also required for YUV multi plane formats)
#define EURASIA_PTLA_DST_XSTART_MASK			(0x1FFFU<<13)
#define EURASIA_PTLA_DST_XSTART_CLRMASK			(~EURASIA_PTLA_DST_XSTART_MASK)
#define EURASIA_PTLA_DST_XSTART_SHIFT			13
//	Dest Y start (also required for YUV multi plane formats)
#define EURASIA_PTLA_DST_YSTART_MASK			(0x1FFFU)
#define EURASIA_PTLA_DST_YSTART_CLRMASK			(~EURASIA_PTLA_DST_YSTART_MASK)
#define EURASIA_PTLA_DST_YSTART_SHIFT			0
//	Dest X size
#define EURASIA_PTLA_DST_XSIZE_MASK				(0x1FFFU<<13)
#define EURASIA_PTLA_DST_XSIZE_CLRMASK			(~EURASIA_PTLA_DST_XSIZE_MASK)
#define EURASIA_PTLA_DST_XSIZE_SHIFT			13
//	Dest Y size
#define EURASIA_PTLA_DST_YSIZE_MASK				(0x1FFFU)
#define EURASIA_PTLA_DST_YSIZE_CLRMASK			(~EURASIA_PTLA_DST_YSIZE_MASK)
#define EURASIA_PTLA_DST_YSIZE_SHIFT			0

#endif // _SGXPTLADEFS_H_

/******************************************************************************
 End of file (sgxptlsdefs.h)
******************************************************************************/
