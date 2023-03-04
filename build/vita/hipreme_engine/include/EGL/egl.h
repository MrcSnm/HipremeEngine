/**************************************************************************
 * Name         : drvegl.h
 *
 * Copyright    : 2004-2006 by Imagination Technologies Limited. All rights reserved.
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
 * $Log: drvegl.h $
 **************************************************************************/

#ifndef __drvegl_h_
#define __drvegl_h_

/* May need to export on some platforms */
#if !defined(GLAPI_EXT)
	#define GLAPI_EXT
#endif

#ifndef APIENTRY
#define APIENTRY
#endif

#include "egl1_4.h"

#endif /* ___drvegl_h_ */
