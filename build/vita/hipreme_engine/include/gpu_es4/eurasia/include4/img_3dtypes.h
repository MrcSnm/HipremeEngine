/******************************************************************************
* Name         : img_3dtypes.h
* Title        : Global 3D types for use by IMG APIs
* Author(s)    : Imagination Technologies
* Created      : 8th April 2009
*
* Copyright    : 2003-2006 by Imagination Technologies Limited.
*                All rights reserved. No part of this software, either material
*                or conceptual may be copied or distributed, transmitted,
*                transcribed, stored in a retrieval system or translated into
*                any human or computer language in any form by any means,
*                electronic, mechanical, manual or otherwise, or disclosed
*                to third parties without the express written permission of
*                Imagination Technologies Limited, Home Park Estate,
*                Kings Langley, Hertfordshire, WD4 8LZ, U.K.
*
* Description  : Defines 3D types for use by IMG APIs
*
* Platform     : Generic
*
* Modifications:-
* $Log: img_3dtypes.h $
******************************************************************************/

#ifndef __IMG_3DTYPES_H__
#define __IMG_3DTYPES_H__

/**
 * Comparison functions
 * This comparison function is defined as:
 * A {CmpFunc} B
 * A is a reference value, e.g., incoming depth etc.
 * B is the sample value, e.g., value in depth buffer. 
 */
typedef enum _IMG_COMPFUNC_
{
	IMG_COMPFUNC_NEVER,			/**< The comparison never succeeds */
	IMG_COMPFUNC_LESS,			/**< The comparison is a less-than operation */
	IMG_COMPFUNC_EQUAL,			/**< The comparison is an equal-to operation */
	IMG_COMPFUNC_LESS_EQUAL,	/**< The comparison is a less-than or equal-to 
									 operation */
	IMG_COMPFUNC_GREATER,		/**< The comparison is a greater-than operation 
								*/
	IMG_COMPFUNC_NOT_EQUAL,		/**< The comparison is a no-equal-to operation
								*/
	IMG_COMPFUNC_GREATER_EQUAL,	/**< The comparison is a greater-than or 
									 equal-to operation */
	IMG_COMPFUNC_ALWAYS,		/**< The comparison always succeeds */
} IMG_COMPFUNC;

/**
 * Stencil op functions
 */
typedef enum _IMG_STENCILOP_
{
	IMG_STENCILOP_KEEP,		/**< Keep original value */
	IMG_STENCILOP_ZERO,		/**< Set stencil to 0 */
	IMG_STENCILOP_REPLACE,	/**< Replace stencil entry */
	IMG_STENCILOP_INCR_SAT,	/**< Increment stencil entry, clamping to max */
	IMG_STENCILOP_DECR_SAT,	/**< Decrement stencil entry, clamping to zero */
	IMG_STENCILOP_INVERT,	/**< Invert bits in stencil entry */
	IMG_STENCILOP_INCR,		/**< Increment stencil entry, 
								 wrapping if necessary */
	IMG_STENCILOP_DECR,		/**< Decrement stencil entry, 
								 wrapping if necessary */
} IMG_STENCILOP;

/**
 * Memory layout enumeration.
 * Defines how pixels are layed out within a surface.
 */
typedef enum _IMG_MEMLAYOUT_
{
	IMG_MEMLAYOUT_STRIDED,			/**< Resource is strided, one row at a time */
	IMG_MEMLAYOUT_HYBRIDTWIDDLED,	/**< Resource is hybrid twiddled */
	IMG_MEMLAYOUT_TWIDDLED,			/**< Resource is twiddled, classic style */
	IMG_MEMLAYOUT_TILED,			/**< Resource is tiled, 32x32 */
} IMG_MEMLAYOUT;

typedef enum _IMG_SCALING_
{
	IMG_SCALING_NONE,			/**< Apply no scaling */
	IMG_SCALING_AA,				/**< Apply Bartlett 4 sample downscaling */
	IMG_SCALING_UPSCALE,		/**< Apply 2x2 replicated upscaling */
	IMG_SCALING_UPAA,			/**< Apply Bartlett downscaling, followed by 2x2 upscaling */
} IMG_SCALING;


/**
 * Alpha blending allows colours and textures on one surface
 * to be blended with transparancy onto another surface.
 * These definitions apply to both source and destination blending
 * states
 */
typedef enum _IMG_BLEND_
{
	IMG_BLEND_ZERO = 0,        /**< Blend factor is (0,0,0,0) */
	IMG_BLEND_ONE,             /**< Blend factor is (1,1,1,1) */
	IMG_BLEND_SRC_COLOUR,      /**< Blend factor is the source colour */
	IMG_BLEND_INV_SRC_COLOUR,  /**< Blend factor is the inverted source colour
									(i.e. 1-src_col) */
	IMG_BLEND_SRC_ALPHA,       /**< Blend factor is the source alpha */
	IMG_BLEND_INV_SRC_ALPHA,   /**< Blend factor is the inverted source alpha
									(i.e. 1-src_alpha) */
	IMG_BLEND_DEST_ALPHA,      /**< Blend factor is the destination alpha */
	IMG_BLEND_INV_DEST_ALPHA,  /**< Blend factor is the inverted destination 
									alpha */
	IMG_BLEND_DEST_COLOUR,     /**< Blend factor is the destination colour */
	IMG_BLEND_INV_DEST_COLOUR, /**< Blend factor is the inverted destination 
									colour */
	IMG_BLEND_SRC_ALPHASAT,    /**< Blend factor is the alpha saturation (the 
									minimum of (Src alpha, 
									1 - destination alpha)) */
	IMG_BLEND_BLEND_FACTOR,    /**< Blend factor is a constant */
	IMG_BLEND_INVBLEND_FACTOR, /**< Blend factor is a constant (inverted)*/
	IMG_BLEND_SRC1_COLOUR,     /**< Blend factor is the colour outputted from 
									the pixel shader */
	IMG_BLEND_INV_SRC1_COLOUR, /**< Blend factor is the inverted colour 
									outputted from the pixel shader */
	IMG_BLEND_SRC1_ALPHA,      /**< Blend factor is the alpha outputted from 
									the pixel shader */
	IMG_BLEND_INV_SRC1_ALPHA   /**< Blend factor is the inverted alpha
									outputted from the pixel shader */
} IMG_BLEND;

/**
 * The arithmetic operation to perform when blending
 */
typedef enum _IMG_BLENDOP_
{
	IMG_BLENDOP_ADD = 0,          /**< Result = (Source + Destination)*/
	IMG_BLENDOP_SUBTRACT,     /**< Result = (Source - Destination) */
	IMG_BLENDOP_REV_SUBTRACT, /**< Result = (Destination - Source) */
	IMG_BLENDOP_MIN,          /**< Result = min (Source, Destination) */
	IMG_BLENDOP_MAX           /**< Result = max (Source, Destination) */
} IMG_BLENDOP;

/**
 * Type of fog blending supported
 */
typedef enum _IMG_FOGMODE_
{
	IMG_FOGMODE_NONE, /**< No fog blending - fog calculations are
					   *   based on the value output from the vertex phase */
	IMG_FOGMODE_LINEAR, /**< Linear interpolation */
	IMG_FOGMODE_EXP, /**< Exponential */
	IMG_FOGMODE_EXP2, /**< Exponential squaring */
} IMG_FOGMODE;

/**
 * Culling based on winding order of triangle.
 */
typedef enum _IMG_CULLMODE_
{
	IMG_CULLMODE_NONE,			/**< Don't cull */
	IMG_CULLMODE_CLOCKWISE,		/**< Cull clockwise triangles */
	IMG_CULLMODE_ANTICLOCKWISE,	/**< Cull anti-clockwise triangles */
} IMG_CULLMODE;

/**
 * Rotation counter-clockwise
 */
typedef enum _IMG_ROTATION_
{
	IMG_ROTATION_0DEG,
	IMG_ROTATION_90DEG,
	IMG_ROTATION_180DEG,
	IMG_ROTATION_270DEG
} IMG_ROTATION;

#endif /* __IMG_3DTYPES_H__ */
/******************************************************************************
 End of file (img_3dtypes.h)
******************************************************************************/
