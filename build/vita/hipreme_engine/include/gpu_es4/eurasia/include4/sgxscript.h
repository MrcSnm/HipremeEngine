/*!****************************************************************************
@File		sgxscript.h

@Title		sgx kernel services structues/functions

@Author		Imagination Technologies

@date   	02 / 11 / 07
 
@Copyright     	Copyright 2007 by Imagination Technologies Limited.
                All rights reserved. No part of this software, either
                material or conceptual may be copied or distributed,
                transmitted, transcribed, stored in a retrieval system
                or translated into any human or computer language in any
                form by any means, electronic, mechanical, manual or
                other-wise, or disclosed to third parties without the
                express written permission of Imagination Technologies
                Limited, Unit 8, HomePark Industrial Estate,
                King's Langley, Hertfordshire, WD4 8LZ, U.K.

@Platform	Generic

@Description	SGX initialisation script definitions.

@DoxygenVer		

Modifications :-

$Log: sgxscript.h $
*****************************************************************************/
#ifndef __SGXSCRIPT_H__
#define __SGXSCRIPT_H__

#if defined (__cplusplus)
extern "C" {
#endif

#define	SGX_MAX_INIT_COMMANDS	64
#define	SGX_MAX_DEINIT_COMMANDS	16

typedef	enum _SGX_INIT_OPERATION
{
	SGX_INIT_OP_ILLEGAL = 0,
	SGX_INIT_OP_WRITE_HW_REG,
#if defined(PDUMP)
	SGX_INIT_OP_PDUMP_HW_REG,
#endif
	SGX_INIT_OP_HALT
} SGX_INIT_OPERATION;

typedef union _SGX_INIT_COMMAND
{
	SGX_INIT_OPERATION eOp;
	struct {
		SGX_INIT_OPERATION eOp;
		IMG_UINT32 ui32Offset;
		IMG_UINT32 ui32Value;
	} sWriteHWReg;
#if defined(PDUMP)
	struct {
		SGX_INIT_OPERATION eOp;
		IMG_UINT32 ui32Offset;
		IMG_UINT32 ui32Value;
	} sPDumpHWReg;
#endif
#if defined(FIX_HW_BRN_22997) && defined(FIX_HW_BRN_23030) && defined(SGX_FEATURE_HOST_PORT)			
	struct {
		SGX_INIT_OPERATION eOp;
	} sWorkaroundBRN22997;
#endif	
} SGX_INIT_COMMAND;

typedef struct _SGX_INIT_SCRIPTS_
{
	SGX_INIT_COMMAND asInitCommandsPart1[SGX_MAX_INIT_COMMANDS];
	SGX_INIT_COMMAND asInitCommandsPart2[SGX_MAX_INIT_COMMANDS];
	SGX_INIT_COMMAND asDeinitCommands[SGX_MAX_DEINIT_COMMANDS];
} SGX_INIT_SCRIPTS;

#if defined(__cplusplus)
}
#endif

#endif /* __SGXSCRIPT_H__ */

/*****************************************************************************
 End of file (sgxscript.h)
*****************************************************************************/
