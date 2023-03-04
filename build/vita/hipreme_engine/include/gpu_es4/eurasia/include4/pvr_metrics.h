/******************************************************************************
* Name         : pvr_metrics.h
*
* Copyright    : 2003-2007 by Imagination Technologies Limited.
*              : All rights reserved. No part of this software, either material
*              : or conceptual may be copied or distributed, transmitted,
*              : transcribed, stored in a retrieval system or translated into
*              : any human or computer language in any form by any means,
*              : electronic, mechanical, manual or otherwise, or disclosed
*              : to third parties without the express written permission of
*              : Imagination Technologies Limited, Home Park Estate,
*              : Kings Langley, Hertfordshire, WD4 8LZ, U.K.
*
* Platform     : ANSI
*
* $Log: pvr_metrics.h $
******************************************************************************/
#ifndef _PVRMETRICS_
#define _PVRMETRICS_

#if defined (__cplusplus)
extern "C" {
#endif

#if defined(TIMING) || defined(DEBUG)

#if defined(__linux__)
	IMG_EXPORT IMG_VOID   PVRSRVGetTimerRegister(IMG_VOID	*pvSOCTimerRegisterUM);
	IMG_EXPORT IMG_VOID   PVRSRVReleaseTimerRegister(IMG_VOID);
#endif
IMG_IMPORT IMG_UINT32 PVRSRVMetricsTimeNow(IMG_VOID);
IMG_IMPORT IMG_FLOAT  PVRSRVMetricsGetCPUFreq(IMG_VOID);

IMG_IMPORT IMG_VOID PVRSRVInitProfileOutput(IMG_VOID **ppvFileInfo);
IMG_IMPORT IMG_VOID PVRSRVDeInitProfileOutput(IMG_VOID **ppvFileInfo);
IMG_IMPORT IMG_VOID PVRSRVProfileOutput(IMG_VOID *pvFileInfo, const IMG_CHAR *psString);

typedef struct 
{
	IMG_UINT32 ui32Start, ui32Stop, ui32Count, ui32Max, ui32Total, ui32Sum;
	IMG_FLOAT fStack;

} PVR_Temporal_Data;


/*
  Parameter explanation:

  X       : a Temporal_Data instance
  SWAP    : a *_TIMES_SWAP_BUFFERS Temporal_Data instance
  H       : an application hint
  CPU     : float for CPU speed
  TAG     : a define
  Y       : numerical parameter
*/

#define PVR_MTR_CALLS(X)				X.ui32Count

#define PVR_MTR_TIME_PER_CALL(X, CPU)	( (X.ui32Count) ? \
										(X.ui32Total*CPU/X.ui32Count) : 0.0f )

#define PVR_MTR_MAX_TIME(X, CPU)		( X.ui32Max*CPU )

#define PVR_MTR_PIXELS_PER_CALL(X)		( (X.ui32Count) ? \
										(X.fStack*1000.0f/X.ui32Count) : 0.0f )

/* generic per frame metrics - an integer is passed as second parameter */

#define PVR_MTR_TIME_PER_FRAME_GENERIC(X, Y, CPU)  ((X.ui32Total*CPU)/(Y))

#define PVR_MTR_PIXELS_PER_FRAME_GENERIC(X, Y)	   ((X.fStack*1000.0f)/(Y))

#define PVR_MTR_METRIC_PER_FRAME_GENERIC(X, Y)	   (X.ui32Count/(Y))

#define PVR_MTR_PARAM_PER_FRAME_GENERIC(X, Y)	   ((X)/(Y))


/* 
   per frame metrics - a timer is passed as second parameter, 
   typically a *_TIMER_SWAP_HW_TIME timer 
*/

#define PVR_MTR_TIME_PER_FRAME(SWAP, X, CPU)	( (SWAP.ui32Count) ? \
										        (X.ui32Total*CPU/SWAP.ui32Count) : 0.0f )

#define PVR_MTR_PIXELS_PER_FRAME(SWAP, X)       ( (SWAP.ui32Count) ? \
										        (X.fStack*1000.0f/SWAP.ui32Count) : 0.0f )

#define PVR_MTR_METRIC_PER_FRAME(SWAP, X)       ( (SWAP.ui32Count) ? \
										        (X.ui32Count/SWAP.ui32Count) : 0 )

#define PVR_MTR_PARAM_PER_FRAME(SWAP, X)	    X/SWAP.ui32Count


#define PVR_MTR_CHECK_BETWEEN_START_END_FRAME(H, SWAP)	((H.ui32ProfileStartFrame <= SWAP.ui32Count) && \
												        (H.ui32ProfileEndFrame >= SWAP.ui32Count))


#define PVR_MTR_TIME_RESET(X)      {                    \
									X.ui32Count = 0;	\
									X.ui32Total = 0;	\
									X.ui32Sum   = 0;	\
									X.ui32Start = 0; 	\
									X.ui32Stop  = 0;    \
									X.fStack    = 0.0f;	\
								   }

#define PVR_MTR_TIME_START(X, H, SWAP)            {                                                              \
									               if(PVR_MTR_CHECK_BETWEEN_START_END_FRAME(H, SWAP))            \
									               {                                                             \
										            X.ui32Count += 1;			                                 \
										            X.ui32Count |= 0x80000000L;                                  \
										            X.ui32Start = PVRSRVMetricsTimeNow(); X.ui32Stop = 0;        \
									               }                                                             \
								                  }

#define PVR_MTR_SWAP_TIME_START(X)                {                                                              \
									               {                                                             \
										            X.ui32Count += 1;			                                 \
										            X.ui32Count |= 0x80000000L;                                  \
										            X.ui32Start = PVRSRVMetricsTimeNow(); X.ui32Stop = 0;        \
									               }                                                             \
								                  }

#define PVR_MTR_TIME_SUSPEND(X)             { X.ui32Stop += PVRSRVMetricsTimeNow() - X.ui32Start; }

#define PVR_MTR_TIME_RESUME(X)              { X.ui32Start = PVRSRVMetricsTimeNow(); }

#define PVR_MTR_TIME_STOP(X, H, SWAP)             {                                                                         \
									               if(PVR_MTR_CHECK_BETWEEN_START_END_FRAME(H, SWAP))                       \
									               {                                                                        \
										            IMG_UINT32 ui32TimeLapse = PVRSRVMetricsTimeNow() - X.ui32Start;        \
										            if(ui32TimeLapse > X.ui32Max)                                           \
                                                    {                                                                       \
											           X.ui32Max = ui32TimeLapse;                                           \
										            }                                                                       \
										            X.ui32Stop +=  ui32TimeLapse;                                           \
										            X.ui32Sum += X.ui32Stop;                                                \
										            X.ui32Total += X.ui32Stop; X.ui32Count &= 0x7FFFFFFFL;                  \
									               }                                                                        \
								                  }

#define PVR_MTR_SWAP_TIME_STOP(X)            {                                                            \
									          {                                                           \
										       X.ui32Stop += PVRSRVMetricsTimeNow() - X.ui32Start;        \
										       X.ui32Sum += X.ui32Stop;                                   \
										       X.ui32Total += X.ui32Stop; X.ui32Count &= 0x7FFFFFFFL;     \
									          }                                                           \
								             }

#define PVR_MTR_TIME_RESET_SUM(X)   { X.Sum = 0; }
								 								
#define PVR_MTR_INC_PERFRAME_COUNT(X)	{                       \
										 if (X.fStack == 0.0f)  \
										 {                      \
											X.ui32Count++;		\
											X.fStack = 1.0f;	\
										 }                      \
									    }

#define PVR_MTR_RESET_PERFRAME_COUNT(X) { X.fStack = 0.0f;} 

#define PVR_MTR_DECR_COUNT(X)   	   	{ X.ui32Count -= 1; }

#define PVR_MTR_INC_PIXEL_COUNT(X, Y)   { X.fStack  += 0.001f*(IMG_FLOAT)(Y); }
	 

#define PVR_MTR_INC_COUNT(TIMER, X, Y, H, SWAP, TAG) {                                                                         \
                                                      IMG_INT tempTimer = TIMER;                                                   \
									                  if((tempTimer == TAG) || PVR_MTR_CHECK_BETWEEN_START_END_FRAME(H, SWAP)) \
									                  {                                                                        \
										               X.ui32Count += 1;		                                               \
		                                               X.ui32Stop  += (Y);	                                                   \
										               X.ui32Total += (Y); 	                                                   \
									                  }                                                                        \
								                     }


#else /* !(defined (TIMING) || defined (DEBUG)) */

#define PVR_MTR_TIME_RESET(X)
#define PVR_MTR_TIME_START(X, H, SWAP)
#define PVR_MTR_TIME_SUSPEND(X)
#define PVR_MTR_TIME_RESUME(X)
#define PVR_MTR_TIME_STOP(X, H, SWAP)
#define PVR_MTR_SWAP_TIME_START(X)
#define PVR_MTR_SWAP_TIME_STOP(X)
#define PVR_MTR_INC_COUNT(X, Y, H, SWAP, TAG)
#define PVR_MTR_DECR_COUNT(X)
#define PVR_MTR_INC_PIXEL_COUNT(X, Y)
#define PVR_MTR_INC_PERFRAME_COUNT(X)
#define PVR_MTR_RESET_PERFRAME_COUNT(X)
#define PVR_MTR_TIME_RESET_SUM(X)

  /* these macros are never used, so far */
#define PVR_MTR_RESET_FRAME()
#define PVR_MTR_INC_POLY_COUNT(X)

#endif /* defined (TIMING) || defined (DEBUG) */

#if defined(__cplusplus)
}
#endif

#endif /* _PVRMETRICS_ */

/******************************************************************************
 End of file (pvr_metrics.h)
******************************************************************************/
