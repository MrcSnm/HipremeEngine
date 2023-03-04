/****************************************************************************
 Name          : mnemedefs.h
 Author        : Autogenerated
 Copyright     : 2001-2009 by Imagination Technologies Limited. All rights
                 reserved. No part of this software, either material or
                 conceptual may be copied or distributed, transmitted,
                 transcribed, stored in a retrieval system or translated into
                 any human or computer language in any form by any means,
                 electronic, mechanical, manual or otherwise, or
                 disclosed to third parties without the express written
                 permission of Imagination Technologies Limited, Home Park
                 Estate, Kings Langley, Hertfordshire, WD4 8LZ, U.K.
 Description   : 

 Program Type  : Autogenerated C -- do not edit

 Version       : $Revision: 1.2 $


 Generated by regconv version 1.127, from files:
	mne_cache.def 
****************************************************************************/


#ifndef _MNEMEDEFS_H_
#define _MNEMEDEFS_H_

/* Register MNE_CR_CTRL */
#define MNE_CR_CTRL                         0x0D00
#define MNE_CR_CTRL_BYP_CC_N_MASK           0x00010000U
#define MNE_CR_CTRL_BYP_CC_N_SHIFT          16
#define MNE_CR_CTRL_BYP_CC_N_SIGNED         0

#define MNE_CR_CTRL_BYP_CC_MASK             0x00008000U
#define MNE_CR_CTRL_BYP_CC_SHIFT            15
#define MNE_CR_CTRL_BYP_CC_SIGNED           0

#define MNE_CR_CTRL_USE_INVAL_REQ_MASK      0x00007800U
#define MNE_CR_CTRL_USE_INVAL_REQ_SHIFT     11
#define MNE_CR_CTRL_USE_INVAL_REQ_SIGNED    0

#define MNE_CR_CTRL_BYPASS_ALL_MASK         0x00000400U
#define MNE_CR_CTRL_BYPASS_ALL_SHIFT        10
#define MNE_CR_CTRL_BYPASS_ALL_SIGNED       0

#define MNE_CR_CTRL_BYPASS_MASK             0x000003E0U
#define MNE_CR_CTRL_BYPASS_SHIFT            5
#define MNE_CR_CTRL_BYPASS_SIGNED           0

#define MNE_CR_CTRL_PAUSE_MASK              0x00000010U
#define MNE_CR_CTRL_PAUSE_SHIFT             4
#define MNE_CR_CTRL_PAUSE_SIGNED            0

/* Register MNE_CR_USE_INVAL */
#define MNE_CR_USE_INVAL                    0x0D04
#define MNE_CR_USE_INVAL_ADDR_MASK          0xFFFFFFFFU
#define MNE_CR_USE_INVAL_ADDR_SHIFT         0
#define MNE_CR_USE_INVAL_ADDR_SIGNED        0

/* Register MNE_CR_STAT */
#define MNE_CR_STAT                         0x0D08
#define MNE_CR_STAT_PAUSED_MASK             0x00000400U
#define MNE_CR_STAT_PAUSED_SHIFT            10
#define MNE_CR_STAT_PAUSED_SIGNED           0

#define MNE_CR_STAT_READS_MASK              0x000003FFU
#define MNE_CR_STAT_READS_SHIFT             0
#define MNE_CR_STAT_READS_SIGNED            0

/* Register MNE_CR_STAT_STATS */
#define MNE_CR_STAT_STATS                   0x0D0C
#define MNE_CR_STAT_STATS_RST_MASK          0x000FFFF0U
#define MNE_CR_STAT_STATS_RST_SHIFT         4
#define MNE_CR_STAT_STATS_RST_SIGNED        0

#define MNE_CR_STAT_STATS_SEL_MASK          0x0000000FU
#define MNE_CR_STAT_STATS_SEL_SHIFT         0
#define MNE_CR_STAT_STATS_SEL_SIGNED        0

/* Register MNE_CR_STAT_STATS_OUT */
#define MNE_CR_STAT_STATS_OUT               0x0D10
#define MNE_CR_STAT_STATS_OUT_VALUE_MASK    0xFFFFFFFFU
#define MNE_CR_STAT_STATS_OUT_VALUE_SHIFT   0
#define MNE_CR_STAT_STATS_OUT_VALUE_SIGNED  0

/* Register MNE_CR_EVENT_STATUS */
#define MNE_CR_EVENT_STATUS                 0x0D14
#define MNE_CR_EVENT_STATUS_INVAL_MASK      0x00000001U
#define MNE_CR_EVENT_STATUS_INVAL_SHIFT     0
#define MNE_CR_EVENT_STATUS_INVAL_SIGNED    0

/* Register MNE_CR_EVENT_CLEAR */
#define MNE_CR_EVENT_CLEAR                  0x0D18
#define MNE_CR_EVENT_CLEAR_INVAL_MASK       0x00000001U
#define MNE_CR_EVENT_CLEAR_INVAL_SHIFT      0
#define MNE_CR_EVENT_CLEAR_INVAL_SIGNED     0

/* Register MNE_CR_CTRL_INVAL */
#define MNE_CR_CTRL_INVAL                   0x0D20
#define MNE_CR_CTRL_INVAL_PREQ_PDS_MASK     0x00000008U
#define MNE_CR_CTRL_INVAL_PREQ_PDS_SHIFT    3
#define MNE_CR_CTRL_INVAL_PREQ_PDS_SIGNED   0

#define MNE_CR_CTRL_INVAL_PREQ_USEC_MASK    0x00000004U
#define MNE_CR_CTRL_INVAL_PREQ_USEC_SHIFT   2
#define MNE_CR_CTRL_INVAL_PREQ_USEC_SIGNED  0

#define MNE_CR_CTRL_INVAL_PREQ_CACHE_MASK   0x00000002U
#define MNE_CR_CTRL_INVAL_PREQ_CACHE_SHIFT  1
#define MNE_CR_CTRL_INVAL_PREQ_CACHE_SIGNED 0

#define MNE_CR_CTRL_INVAL_ALL_MASK          0x00000001U
#define MNE_CR_CTRL_INVAL_ALL_SHIFT         0
#define MNE_CR_CTRL_INVAL_ALL_SIGNED        0

/* Register MNE_CR_emu_mem_stall */
#define MNE_CR_emu_mem_stall                0x0D24
#define MNE_CR_EMU_MEM_STALL_COUNT_MASK     0xFFFFFFFFU
#define MNE_CR_EMU_MEM_STALL_COUNT_SHIFT    0
#define MNE_CR_EMU_MEM_STALL_COUNT_SIGNED   0

/* Register MNE_CR_mem_byte */
#define MNE_CR_mem_byte                     0x0D28
#define MNE_CR_MEM_BYTE_WRITE_MASK          0xFFFFFFFFU
#define MNE_CR_MEM_BYTE_WRITE_SHIFT         0
#define MNE_CR_MEM_BYTE_WRITE_SIGNED        0

/* Register MNE_CR_mem_non_masked */
#define MNE_CR_mem_non_masked               0x0D2C
#define MNE_CR_MEM_NON_MASKED_WRITE_MASK    0xFFFFFFFFU
#define MNE_CR_MEM_NON_MASKED_WRITE_SHIFT   0
#define MNE_CR_MEM_NON_MASKED_WRITE_SIGNED  0

/* Register MNE_CR_mem_CYCLE_COUNTER */
#define MNE_CR_mem_CYCLE_COUNTER            0x0D30
#define MNE_CR_MEM_CYCLE_COUNTER_RESET_MASK 0x00000001U
#define MNE_CR_MEM_CYCLE_COUNTER_RESET_SHIFT 0
#define MNE_CR_MEM_CYCLE_COUNTER_RESET_SIGNED 0

/* Register MNE_CR_mem */
#define MNE_CR_mem                          0x0D34
#define MNE_CR_MEM_READ_MASK                0xFFFFFFFFU
#define MNE_CR_MEM_READ_SHIFT               0
#define MNE_CR_MEM_READ_SIGNED              0

/* Register MNE_CR_mem_any */
#define MNE_CR_mem_any                      0x0D38
#define MNE_CR_MEM_ANY_WRITE_MASK           0xFFFFFFFFU
#define MNE_CR_MEM_ANY_WRITE_SHIFT          0
#define MNE_CR_MEM_ANY_WRITE_SIGNED         0

/* Register MNE_CR_mem_masked */
#define MNE_CR_mem_masked                   0x0D3C
#define MNE_CR_MEM_MASKED_WRITE_MASK        0xFFFFFFFFU
#define MNE_CR_MEM_MASKED_WRITE_SHIFT       0
#define MNE_CR_MEM_MASKED_WRITE_SIGNED      0

#endif /* _MNEMEDEFS_H_ */

/*****************************************************************************
 End of file (mnemedefs.h)
*****************************************************************************/
