/*!****************************************************************************
@File		sysinfo.h

@Title		System Description Header

@Author		Imagination Technologies

@date   	9/10/2007
 
@Copyright     	Copyright 2003-2009 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either
                material or conceptual may be copied or distributed,
                transmitted, transcribed, stored in a retrieval system
                or translated into any human or computer language in any
                form by any means, electronic, mechanical, manual or
                other-wise, or disclosed to third parties without the
                express written permission of Imagination Technologies
                Limited, Unit 8, HomePark Industrial Estate,
                King's Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform	generic

@Description	This header provides system-specific declarations and macros

@DoxygenVer		

******************************************************************************/

/******************************************************************************
Modifications :-
$Log: sysinfo.h $
*****************************************************************************/

#if !defined(__SYSINFO_H__)
#define __SYSINFO_H__

/*!< System specific poll/timeout details */
#if defined(PVR_LINUX_USING_WORKQUEUES)
/*
 * The workqueue based 3rd party display driver may be blocked for up
 * to 500ms waiting for a vsync when the screen goes blank, so we
 * need to wait longer for the hardware if a flush of the swap chain is
 * required.
 */
#define MAX_HW_TIME_US				(1000000)
#define WAIT_TRY_COUNT				(20000)
#else
#define MAX_HW_TIME_US				(500000)
#define WAIT_TRY_COUNT				(10000)
#endif


#define SYS_DEVICE_COUNT 15 /* SGX, DISPLAYCLASS (external), BUFFERCLASS (external) */

#endif	/* __SYSINFO_H__ */
