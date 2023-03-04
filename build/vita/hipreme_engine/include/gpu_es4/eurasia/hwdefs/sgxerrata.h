/******************************************************************************
 * Name         : sgxerrata.h
 * Title        : SGX HW errata definitions
 *
 * Copyright    : 2005-2010 by Imagination Technologies Limited.
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
 * Description  : Specifies associations between SGX core revisions
 *                and SW workarounds required to fix HW errata that exist
 *                in specific core revisions
 *
 * Modifications:-
 * $Log: sgxerrata.h $
 * ./
 *  --- Revision Logs Removed --- 
 * 
 *  --- Revision Logs Removed --- 
 *
 *  --- Revision Logs Removed --- 
 *
 *  --- Revision Logs Removed --- 
 *****************************************************************************/
#ifndef _SGXERRATA_H_
#define _SGXERRATA_H_

#if defined(__psp2__)
#include "psp2_pvr_desc.h"
#endif

/*
	For each SGX core revision specify which HW BRNs required SW workarounds
*/
#if defined(SGX520) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX520 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 100
		#define FIX_HW_BRN_20195/* Implicit Workaround in code */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23378/* Workaround in ucode */
		#define FIX_HW_BRN_23461/* Workaround in USC */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25892 /*Workaround in OpenVG*/
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 111
		#define FIX_HW_BRN_20195/* Implicit Workaround in code */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		/* RTL head - no BRNs to apply */
		#define FIX_HW_BRN_25892 /*Workaround in OpenVG*/
	#else
		#error "sgxerrata.h: SGX520 Core Revision unspecified"
	#endif
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif


#if defined(SGX530) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX530 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 110
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23062/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23070/* Workaround in services*/
		#define FIX_HW_BRN_23164/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23194/* Workaround in code */
		#define FIX_HW_BRN_23228/* Implicit Workaround in ukernel, ogles1/2, ovg (dont use) */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23331/* Implicit Workaround in ogles1/2, ovg (never set loadmask) */
		#define FIX_HW_BRN_23378/* Workaround in ucode */
		#define FIX_HW_BRN_23461/* Workaround in useasm */
		#define FIX_HW_BRN_23533/* Implicit Workaround in ukernel (SPM Mode 0 specific) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23677/* Workaround in ucode */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23765/* Workaround in code (services) */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23862/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23870/* Workaround in ucode */
		#define FIX_HW_BRN_23896/* Implicit Workaround in code (ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23946/* Workaround in code (ogl, ogles1/2) */
		#define FIX_HW_BRN_23960/* Workaround in useasm */
		#define FIX_HW_BRN_23971/* Workaround in code(dx only), MTE boundingbox and ISP vistest related */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24549/* Workaround in ucode */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_26922/* Workaround in code */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 111
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23062/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23070/* Workaround in services*/
		#define FIX_HW_BRN_23164/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23194/* Workaround in code */
		#define FIX_HW_BRN_23228/* Implicit Workaround in ukernel, ogles1/2, ovg (dont use) */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23331/* Implicit Workaround in ogles1/2, ovg (never set loadmask) */
		#define FIX_HW_BRN_23378/* Workaround in ucode */
		#define FIX_HW_BRN_23461/* Workaround in useasm */
		#define FIX_HW_BRN_23533/* Implicit Workaround in ukernel (SPM Mode 0 specific) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23677/* Workaround in ucode */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23862/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23870/* Workaround in ucode */
		#define FIX_HW_BRN_23896/* Implicit Workaround in code (ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23946/* Workaround in code (ogl, ogles1/2) */
		#define FIX_HW_BRN_23960/* Workaround in useasm */
		#define FIX_HW_BRN_23971/* Workaround in code(dx only), MTE boundingbox and ISP vistest related */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24549/* Workaround in ucode */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_26922/* Workaround in code */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 1111
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23062/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23070/* Workaround in services*/
		#define FIX_HW_BRN_23164/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23194/* Workaround in code */
		#define FIX_HW_BRN_23228/* Implicit Workaround in ukernel, ogles1/2, ovg (dont use) */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23331/* Implicit Workaround in ogles1/2, ovg (never set loadmask) */
		#define FIX_HW_BRN_23378/* Workaround in ucode */
		#define FIX_HW_BRN_23461/* Workaround in useasm */
		#define FIX_HW_BRN_23533/* Implicit Workaround in ukernel (SPM Mode 0 specific) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23677/* Workaround in ucode */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23862/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23870/* Workaround in ucode */
		#define FIX_HW_BRN_23896/* Implicit Workaround in code (ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23946/* Workaround in code (ogl, ogles1/2) */
		#define FIX_HW_BRN_23960/* Workaround in useasm */
		#define FIX_HW_BRN_23971/* Workaround in code(dx only), MTE boundingbox and ISP vistest related */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24549/* Workaround in ucode */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_26922/* Workaround in code */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 120
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23690/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24549/* Workaround in ucode */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27006/* Workaround in ucode */
		#define FIX_HW_BRN_26922/* Workaround in code */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29703/* NOWA: too expensive to work around */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30313/* Workaround in client drivers */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30842/* Workaround in services*/ 
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 121
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24549/* Workaround in ucode */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_26922/* Workaround in code */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30842/* Workaround in services*/ 
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 125
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24549/* Workaround in ucode */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_26922/* Workaround in code */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30842/* Workaround in services*/ 
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 130
		#define FIX_HW_BRN_21590/* Implicit Workaround in ukernel, driver ensures load/store TAAC and LSS serialised */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28889/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29707
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
 		#define FIX_HW_BRN_30313/* Workaround in client drivers */
		#define FIX_HW_BRN_30842/* Workaround in services*/ 
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		/* RTL head */
		#define FIX_HW_BRN_23080/* Workaround in code (codegen, dx) */
	#else
		#error "sgxerrata.h: SGX530 Core Revision unspecified"
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif


#if defined(SGX531) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX531 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 101
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		/* Temporarily disabled due to BRN35441 */
		/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26361/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26518/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26620/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27330 /* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27738/* Workaround in ucode */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28011/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28493/* Workaround in client drivers */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_32302 /*Workaround in uKernel */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 110
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_27006/* Workaround in ucode */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28493/* Workaround in client drivers */
		#define FIX_HW_BRN_29684
		#define FIX_HW_BRN_29703/* NOWA: too expensive to work around */
		#define FIX_HW_BRN_29707
		#define FIX_HW_BRN_29773
		#define FIX_HW_BRN_29967/* Workaround in services*/
		#define FIX_HW_BRN_31077/* Implicit workaround in uKernel */
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_32302 /* workaround in uKernel */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		/* RTL head */
	#else
		#error "sgxerrata.h: SGX531 Core Revision unspecified"
	#endif
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif


#if (defined(SGX535) || defined(SGX535_V1_1)) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX535 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 112
		#define FIX_HW_BRN_20195/* Implicit Workaround in code */
		#define FIX_HW_BRN_22111/* Workaround in code(dx only) */
		#define FIX_HW_BRN_22141/* Implicit Workaround in services (srvkm) written in SGXInitialise */
		#define FIX_HW_BRN_22419/* Workaround in code */
		#define FIX_HW_BRN_22563/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_22610/* Workaround in code (services) */
		#define FIX_HW_BRN_22634/* Workaround controls multithreaded ukernel feature */
		#define FIX_HW_BRN_22648/* Workaround in code (clockgating) */
		#define FIX_HW_BRN_22656/* Workaround in code (services) */
		#define FIX_HW_BRN_22666/* Workaround in DX only (RHW must be present) */
		#define FIX_HW_BRN_22693/* Workaround in code (featuredefs) */
		#define FIX_HW_BRN_22694/* Workaround in code (pvr2d) */
		#define FIX_HW_BRN_22837/* Implicit Workaround in services (srvclient) - commment added */
		#define FIX_HW_BRN_22849/* Workaround in code (services) */
		#define FIX_HW_BRN_22852/* Implicit Workaround in code */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_22997/* Workaround in code and ucode */
		#define FIX_HW_BRN_23020/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23030/* Workaround in code */
		#define FIX_HW_BRN_23054/* Workaround in code (featuredefs) */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23062/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23080/* Workaround in code (codegen, dx) */
		#define FIX_HW_BRN_23137/* Implicit Workaround in code (dx) */
		#define FIX_HW_BRN_23141/* Workaround in code(services) */
		#define FIX_HW_BRN_23155/* Implicit Workaround in code */
		#define FIX_HW_BRN_23164/* Workaround in USC/useasm */
		#define FIX_HW_BRN_23194/* Workaround in code */
		#define FIX_HW_BRN_23228/* Implicit Workaround in ukernel, ogles1/2, ovg (dont use) */
		#define FIX_HW_BRN_23258/* Workaround in code(services) + ucode */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23281/* Workaround in services code, note: not in 530 */
		#define FIX_HW_BRN_23331/* Implicit Workaround in code (microkernel, ogles1,2, ogl2) */
		#define FIX_HW_BRN_23353/* Implicit Workaround (services) */
		#define FIX_HW_BRN_23378/* Workaround in ucode */
		#define FIX_HW_BRN_23410/* Workaround in code (services) and ucode */
		#define FIX_HW_BRN_23460/* Workaround in code(codegen, ogles1/2, ovg, dx, services) */
		#define FIX_HW_BRN_23461/* Workaround in useasm */
		#define FIX_HW_BRN_23533/* Implicit Workaround in ukernel (SPM Mode 0 specific) */
		#define FIX_HW_BRN_23615/* Implicit Workaround in code (microkernel, ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23677/* Workaround in ucode */
		#define FIX_HW_BRN_23687/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23690/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23765/* Workaround in code (services) */
		#define FIX_HW_BRN_23775/* Implicit Workaround in code */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23862/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23870/* Workaround in ucode */
		#define FIX_HW_BRN_23896/* Implicit Workaround in code (ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23949/* Workaround in code(codegen, ogles1/2, ovg, dx, services) */
		#define FIX_HW_BRN_23960/* Workaround in useasm */
		#define FIX_HW_BRN_23971/* Workaround in code(dx only), MTE boundingbox and ISP vistest related */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24435/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25355/* Check in useasm */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25910/* Workaround in ucode */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26711/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28026/* Workaround in ucode */
		#define FIX_HW_BRN_31412/* Workaround in client drivers */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 113
		#define FIX_HW_BRN_20195/* Implicit Workaround in code */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23070/* Workaround in services*/
		#define FIX_HW_BRN_23080/* Workaround in code (codegen, dx) */
		#define FIX_HW_BRN_23194/* Workaround in code */
		#define FIX_HW_BRN_23228/* Implicit Workaround in ukernel, ogles1/2, ovg (dont use) */
		#define FIX_HW_BRN_23258/* Workaround in code(services) + ucode */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23281/* Workaround in services code, note: not in 530 */
		#define FIX_HW_BRN_23331/* Implicit Workaround in code (microkernel, ogles1,2, ogl2) */
		#define FIX_HW_BRN_23353/* Implicit Workaround (services) */
		#define FIX_HW_BRN_23378/* Workaround in ucode */
		#define FIX_HW_BRN_23410/* Workaround in code (services) and ucode */
		#define FIX_HW_BRN_23460/* Workaround in code(codegen, ogles1/2, ovg, dx, services) */
		#define FIX_HW_BRN_23461/* Workaround in useasm */
		#define FIX_HW_BRN_23533/* Implicit Workaround in ukernel (SPM Mode 0 specific) */
		#define FIX_HW_BRN_23615/* Implicit Workaround in code (microkernel, ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define	FIX_HW_BRN_23677/* Workaround in ucode */
		#define FIX_HW_BRN_23687/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23690/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23765/* Workaround in code (services) */
		#define FIX_HW_BRN_23775/* Implicit Workaround in code */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23862/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23870/* Workaround in ucode */
		#define FIX_HW_BRN_23896/* Implicit Workaround in code (ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23944/* Workaround in code (services) */
		#define FIX_HW_BRN_23949/* Workaround in code(codegen, ogles1/2, ovg, dx, services) */
		#define FIX_HW_BRN_23960/* Workaround in useasm */
		#define FIX_HW_BRN_23971/* Workaround in code(dx only), MTE boundingbox and ISP vistest related */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24435/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25355/* Check in useasm */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25910/* Workaround in ucode */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26711/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28026/* Workaround in ucode */
		#define FIX_HW_BRN_28825/* Workaround in services */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 121
		#define FIX_HW_BRN_20195/* Implicit Workaround in code */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23080/* Workaround in code (codegen, dx) */
		#define FIX_HW_BRN_23259/* Workaround in code (dx9) */
		#define FIX_HW_BRN_23353/* Implicit Workaround (services) */
		#define FIX_HW_BRN_23410/* Workaround in code (services) and ucode */
		#define FIX_HW_BRN_23533/* Implicit Workaround in ukernel (SPM Mode 0 specific) */
		#define FIX_HW_BRN_23615/* Implicit Workaround in code (microkernel, ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23620/* Implicit Workaround in ogles1/2, ovg (send accum object or clear), need patching in ukernel. */
		#define FIX_HW_BRN_23632/* Workaround in code(services) */
		#define FIX_HW_BRN_23677/* Workaround in ucode */
		#define FIX_HW_BRN_23687/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23690/* Workaround in code(ogles1, ogles2, ovg, dx) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23775/* Implicit Workaround in code */
		#define FIX_HW_BRN_23815/* Workaround in code (dx, occlusion query specific) */
		#define FIX_HW_BRN_23861/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23862/* Workaround in code (services) + ucode */
		#define FIX_HW_BRN_23870/* Workaround in ucode */
		#define FIX_HW_BRN_23896/* Implicit Workaround in code (ogles1,2, ovg, ogl2) */
		#define FIX_HW_BRN_23944/* Workaround in code (services) */
		#define FIX_HW_BRN_23960/* Workaround in useasm */
		#define FIX_HW_BRN_23971/* Workaround in code(dx only), MTE boundingbox and ISP vistest related */
		#define FIX_HW_BRN_24181/* Workaround in code(ogles1/2) */
		#define FIX_HW_BRN_24281/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_24435/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_24637/* Workaround in OGL */
		#define FIX_HW_BRN_24895/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25060/* Workaround in useasm */
		#define FIX_HW_BRN_25077/* Workaround in code(ogles1/2). Not needed in ovg. */
		#define FIX_HW_BRN_25089/* Workaround in featuredefs and services */
		#define FIX_HW_BRN_25211/* Workaround in code */
		#define FIX_HW_BRN_25355/* Check in useasm */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25910/* Workaround in ucode */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26711/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28026/* Workaround in ucode */
		#define FIX_HW_BRN_28825/* Workaround in services */
		#define FIX_HW_BRN_29900/* Workaround in ucode */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == 126
		#define FIX_HW_BRN_20195/* Implicit Workaround in code */
		#define FIX_HW_BRN_22934/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23259/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_23353/* Implicit Workaround (services) */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		#define FIX_HW_BRN_23761/* Workaround in code (dx, ogl, services) and ucode */
		#define FIX_HW_BRN_23775/* Implicit Workaround in code */
		#define FIX_HW_BRN_24304/* Workaround in ucode */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28026/* Workaround in ucode */
		#define FIX_HW_BRN_28825/* Workaround in services */
		#define FIX_HW_BRN_29900/* Workaround in ucode */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		/* RTL head */
		#define FIX_HW_BRN_23080/* Workaround in code (codegen, dx) */
	#else
		#error "sgxerrata.h: SGX535 Core Revision unspecified"
	#endif
	#endif
	#endif
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif


#if defined(SGX540) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX540 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 101
		#define FIX_HW_BRN_25499/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		/* Temporarily disabled due to BRN35441 */
		/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
		#define FIX_HW_BRN_25339/* Workaround in all pds code */
		#define FIX_HW_BRN_25503/* Workaround in code (services) */
		#define FIX_HW_BRN_25580/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25582/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25615/* Workaround in ucode */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26361/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26518/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26620/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27311/* Workaround in services */
		#define FIX_HW_BRN_27330/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27738/* Workaround in ucode */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_28011/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 110
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		/* Temporarily disabled due to BRN35441 */
		/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
		#define FIX_HW_BRN_25339/* Workaround in all pds code */
		#define FIX_HW_BRN_25503/* Workaround in code (services) */
		#define FIX_HW_BRN_25804/* Workaround in USC/useasm */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_26246/* NOWA: ISP context switch not supported */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26361/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26518/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26620/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27311/* Workaround in services */
		#define FIX_HW_BRN_27330 /* workaround in client driver */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27738/* Workaround in ucode */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28011/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 120
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		/* Temporarily disabled due to BRN35441 */
		/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26620/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27006/* Workaround in ucode */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27311/* Workaround in services */
		#define FIX_HW_BRN_27330/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27738/* Workaround in ucode */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28011/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29684
		#define FIX_HW_BRN_29773
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30313/* Workaround in client drivers */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 121
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		/* Temporarily disabled due to BRN35441 */
		/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26681/* Workaround in USC */
		#define FIX_HW_BRN_26704/* Workaround in code (ogles1/2, ovg, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define FIX_HW_BRN_27006/* Workaround in ucode */
		#define FIX_HW_BRN_27235/* Workaround in USC */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27311/* Workaround in services */
		#define FIX_HW_BRN_27330/* Workaround in client drivers */
		#define FIX_HW_BRN_27408/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_27738/* Workaround in ucode */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_27984/* Workaround in USC */
		#define FIX_HW_BRN_28011/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_28922/* Workaround in services*/ 
		#define FIX_HW_BRN_29684
		#define FIX_HW_BRN_29773
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30313/* Workaround in client drivers */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 130
		#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
		#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
		/* Temporarily disabled due to BRN35441 */
		/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26202/* Workaround in code (services) */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_27006/* Workaround in ucode */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27311/* Workaround in services */
		#define FIX_HW_BRN_27723/* Workaround in usc */
		#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_30313/* Workaround in client drivers */
		#define FIX_HW_BRN_31077/* Implicit workaround in uKernel */
		#define FIX_HW_BRN_31938/* Workaround in ucode */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_33181/* workaround in uKernel */
		#define FIX_HW_BRN_33631/* */
		#define FIX_HW_BRN_34028/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		/* RTL head */
	#else
		#error "sgxerrata.h: SGX540 Core Revision unspecified"
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif


#if defined(SGX541) && !defined(SGX_CORE_DEFINED)
	#if defined(SGX_FEATURE_MP)
		/* define the _current_ SGX541 MP RTL head revision */
		#define SGX_CORE_REV_HEAD	0
		#if defined(USE_SGX_CORE_REV_HEAD)
			/* build config selects Core Revision to be the Head */
			#define SGX_CORE_REV	SGX_CORE_REV_HEAD
		#endif

		#if SGX_CORE_REV == 100
			#define FIX_HW_BRN_23055/* Workaround in services (srvclient) and uKernel. */
			#define FIX_HW_BRN_23720/* Workaround in code (dx only) */
			/* Temporarily disabled due to BRN35441 */
			/*#define FIX_HW_BRN_25161*//* Workaround in client drivers */
			#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
			#define FIX_HW_BRN_26998/* Workaround in client drivers */
			#define FIX_HW_BRN_27002
			#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
			#define FIX_HW_BRN_27270/* Workaround in services */
			#define FIX_HW_BRN_27272/* Workaround in client drivers */
			#define FIX_HW_BRN_27298/* Workaround in services (srvclient)*/
			#define FIX_HW_BRN_27330/* Workaround in all pds code */
			#define FIX_HW_BRN_27510/* Workaround in uKernel */
			#define FIX_HW_BRN_27511/* Workaround in uKernel */
			#define FIX_HW_BRN_27738/* Workaround in ucode */
			#define FIX_HW_BRN_27723/* Workaround in usc */
			#define FIX_HW_BRN_27919/* Workaround in sgxdefs */
			#define FIX_HW_BRN_27984/* Workaround in USC */
			#define FIX_HW_BRN_28011/* Workaround in services (srvkm) */
			#define FIX_HW_BRN_28033/* Workaround in uKernel */
			#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
			#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
			#define FIX_HW_BRN_28705/* Workaround in uKernel */
			#define	FIX_HW_BRN_29574/* workaround in uKernel */
			//#define FIX_HW_BRN_29997/* workaround in uKernel */
			#define FIX_HW_BRN_30089/* workaround in services */
			//#define FIX_HW_BRN_30182/* workaround in uKernel */
			#define FIX_HW_BRN_30764 /* workaround in uKernel */
			#define FIX_HW_BRN_34043 /* workaround in services */
			#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
		#else
			#if SGX_CORE_REV == SGX_CORE_REV_HEAD
				/* RTL head */
			#else
				#error "sgxerrata.h: SGX541 MP Core Revision unspecified"
			#endif
		#endif
		/* signal that the Core Version has a valid definition */
		#define SGX_CORE_DEFINED
	#else /* SGX_FEATURE_MP */
		#error "sgxerrata.h: SGX541 only supports MP configs (SGX_FEATURE_MP)"
	#endif /* SGX_FEATURE_MP */
#endif


#if defined(SGX543) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX543 MP RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 113
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define	FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29461/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29513/* workaround in client drivers/compiler */
		#define FIX_HW_BRN_29519/* usc */
		#define	FIX_HW_BRN_29557/* workaround in uKernel */
		#define	FIX_HW_BRN_29574/* workaround in uKernel */
		#define FIX_HW_BRN_29602/* workaround in hwdefs*/
		#define FIX_HW_BRN_29643/* workaround in usc*/
#if !defined(__psp2__)
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
#endif
		#define FIX_HW_BRN_29960/* workaround in services */
		#define FIX_HW_BRN_29997/* workaround in uKernel */
		#define FIX_HW_BRN_30089/* workaround in services */
		#define FIX_HW_BRN_30182/* workaround in uKernel */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc*/
		#define FIX_HW_BRN_30893/* workaround in uKernel */
		#define FIX_HW_BRN_30954/* workaround in services */
		#define FIX_HW_BRN_31054/* workaround in services */
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31093/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 122
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29461/* workaround in uKernel */
		#define FIX_HW_BRN_29490/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29513/* workaround in client drivers/compiler */
		#define FIX_HW_BRN_29519/* usc */
		#define	FIX_HW_BRN_29557/* workaround in uKernel */
		#define	FIX_HW_BRN_29574/* workaround in uKernel */
		#define FIX_HW_BRN_29602/* workaround in hwdefs*/
		#define FIX_HW_BRN_29643/* workaround in usc*/
		#define FIX_HW_BRN_29703/* NOWA: too expensive to work around */
		#define FIX_HW_BRN_29773
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_29960/* workaround in services */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_29997/* workaround in uKernel */
		#define FIX_HW_BRN_30089/* workaround in services */
		#define FIX_HW_BRN_30182/* workaround in uKernel */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
		#define FIX_HW_BRN_30954/* workaround in services */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_30970 /* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31054/* workaround in services */
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31093/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 1221
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29490/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29513/* workaround in client drivers/compiler */
		#define FIX_HW_BRN_29519/* usc */
		#define	FIX_HW_BRN_29557/* workaround in uKernel */
		#define	FIX_HW_BRN_29574/* workaround in uKernel */
		#define FIX_HW_BRN_29602/* workaround in hwdefs*/
		#define FIX_HW_BRN_29643/* workaround in usc*/
		#define FIX_HW_BRN_29703/* NOWA: too expensive to work around */
		#define FIX_HW_BRN_29773
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_29960/* workaround in services */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30182/* workaround in uKernel */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_30970 /* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31195/* workaround in services */
//ok up to here
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_32052/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		// #define FIX_HW_BRN_32348 /* MLWA: workaround in Services */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_32958/* */
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 140
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30089/* workaround in services */
		#define FIX_HW_BRN_30182/* workaround in uKernel */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
		#define FIX_HW_BRN_30954/* workaround in services */
		#define FIX_HW_BRN_31054/* workaround in services */
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31093/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 1401
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30089/* workaround in services */
		#define FIX_HW_BRN_30182/* workaround in uKernel */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
		#define FIX_HW_BRN_30954/* workaround in services */
		#define FIX_HW_BRN_31054/* workaround in services */
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 141
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_30970 /* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 142
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30201/* turns off msaa 5th position feature */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define	FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_30970 /* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 211
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_30970 /* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */	
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 2111
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_30505/* workaround in uKernel */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30710/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_30893/* workaround in uKernel */       
 		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_30970 /* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31076/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31109/* workaround in uKernel */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */	
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663 /* workaround in client drivers */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 213
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31167/* NOWA: we never do internal-Z */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */	
		#define FIX_HW_BRN_31251/* NOWA: don't use mode "CEM and 888" */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31310/* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 216
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel (no intention to fix hw) */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
		#endif
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_32303/* workaround in uKernel */	
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
#if !defined(__psp2__)
		#define FIX_HW_BRN_33753/* workaround in ukernel */
#endif
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 302
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_32303/* workaround in uKernel */	
		// #define FIX_HW_BRN_32348 /* MLWA: workaround in Services */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_32958/* */
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_34043/* workaround in services */
		#define FIX_HW_BRN_34264/* workaround in uKernel */
		#define FIX_HW_BRN_34293/* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
	#else
	#if SGX_CORE_REV == 303
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29519/* usc */
		#define FIX_HW_BRN_30700/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		// #define FIX_HW_BRN_32348 /* MLWA: workaround in Services */
		#define FIX_HW_BRN_32958/* */
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33774/* workaround in DX driver */
		#define FIX_HW_BRN_34043/* workaround in services */
		#define FIX_HW_BRN_34264/* workaround in uKernel */
		#define FIX_HW_BRN_34293/* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		#define FIX_HW_BRN_29424/* workaround in uKernel (no intention to fix hw) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
        #define FIX_HW_BRN_31562/* workaround in uKernel (no intention to fix hw) */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34293 /* workaround in usc */
	#else
		#error "sgxerrata.h: SGX543 Core Revision unspecified"
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
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif

#if defined(SGX544) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX544 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 100
		/* add BRNs here */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29602/* workaround in hwdefs */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc*/
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33774/* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34939 /* workaround in services */
	#else
	#if SGX_CORE_REV == 102
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29602/* workaround in hwdefs */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc*/
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
			#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME	BRN_36513  incomplete for CS and MP1 */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
		#endif
	#else
	#if SGX_CORE_REV == 103
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30573/* workaround in services */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30764 /* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc*/
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 104
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29954/* turns off regbank split feature */
		#define FIX_HW_BRN_30893/* workaround in uKernel */
		#define FIX_HW_BRN_31079/* workaround in services */
		#define FIX_HW_BRN_31093/* workaround in services */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31195/* workaround in services */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
		#define FIX_HW_BRN_31542 /* workaround in uKernel and Services */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31620/* workaround in services */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 		#endif
  		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32085 /* workaround in services: prefetch fix applied, investigating PT based fix */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 105
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel */
 		#endif
  		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
 		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_32052/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
	#if SGX_CORE_REV == 106
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29513/* workaround in client drivers/compiler */
		#define FIX_HW_BRN_29602/* workaround in hwdefs*/
		#define FIX_HW_BRN_29643/* workaround in usc*/
		#define FIX_HW_BRN_29960/* workaround in services */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30089/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_31054/* workaround in services */
		#define FIX_HW_BRN_31093/* workaround in services */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31251/* NOWA: don't use mode "CEM and 888" */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
 		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
	#else
	#if SGX_CORE_REV == 110
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_29504/* workaround in services */
		#define FIX_HW_BRN_29513/* workaround in client drivers/compiler */
		#define FIX_HW_BRN_29602/* workaround in hwdefs*/
		#define FIX_HW_BRN_29643/* workaround in usc*/
		#define FIX_HW_BRN_29960/* workaround in services */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30089/* workaround in services */
		#define FIX_HW_BRN_30656/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_30795/* workaround in usc */
		#define FIX_HW_BRN_30852/* turns off PDS auto clock gating */
		#define FIX_HW_BRN_30853/* workaround in usc */
		#define FIX_HW_BRN_30871/* workaround in usc */
		#define FIX_HW_BRN_31054/* workaround in services */
		#define FIX_HW_BRN_31093/* workaround in services */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31251/* NOWA: don't use mode "CEM and 888" */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
		#define FIX_HW_BRN_31278/* disabled prefetching in MMU */
		#define FIX_HW_BRN_31310 /* TODO: new, needs workaround */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31474/* workaround in uKernel */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31559/* workaround in uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#define FIX_HW_BRN_31663/* Client drivers. No Intention to fix */
		#define FIX_HW_BRN_31671 /* workaround in uKernel */
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#define FIX_HW_BRN_31982/* workaround in codegen */
 		#define FIX_HW_BRN_32044 /* workaround in uKernel, services and client drivers */
		#define FIX_HW_BRN_32303/* workaround in uKernel */
		#define FIX_HW_BRN_32845/* workaround in ukernel*/
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
	#else
	#if SGX_CORE_REV == 112
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31272/* workaround in services (srvclient) and uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#define FIX_HW_BRN_32958/* */
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
		#define FIX_HW_BRN_33668/* workaround in client drivers */
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33920/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
	#else
	#if SGX_CORE_REV == 114
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31964/* workaround in uKernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31989/* workaround in uKernel (no intention to fix hw) */
			#define FIX_HW_BRN_32052/* workaround in uKernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
	#else
	#if SGX_CORE_REV == 115
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31769/* workaround in uKernel */
 		#endif
 		#define FIX_HW_BRN_31780/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31964/* workaround in uKernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31989/* workaround in uKernel (no intention to fix hw) */
			#define FIX_HW_BRN_32052/* workaround in uKernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
//	FIXME	BRN_36513  incomplete for CS and MP1 */
		#if defined(SGX_FEATURE_MP)
			#if SGX_FEATURE_MP_CORE_COUNT > 1
				#define FIX_HW_BRN_36513 /* workaround in uKernel and Services : incomplete for CS and MP1 */
			#endif
		#endif
	#else
	#if SGX_CORE_REV == 116
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31425/* workaround in services and uKernel */
 		#endif
		#define FIX_HW_BRN_31562/* workaround in uKernel */
 		#define FIX_HW_BRN_31930/* workaround in uKernel */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31964/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31989/* workaround in uKernel */
			#define FIX_HW_BRN_32052/* workaround in uKernel */
		#endif
		#define FIX_HW_BRN_33309/* workaround in ukernel*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_33809/* workaround in kernel (enable burst combiner) */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264
		#define FIX_HW_BRN_34293
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else
		#if SGX_CORE_REV == SGX_CORE_REV_HEAD
			#define FIX_HW_BRN_29424/* workaround in uKernel */
			#define FIX_HW_BRN_30701/* workaround in uKernel */
			#define FIX_HW_BRN_30749/* workaround in uKernel */
			#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
			#define FIX_HW_BRN_31562/* workaround in uKernel (no intention to fix hw) */
			#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
				#define FIX_HW_BRN_33657/* workaround in Services (no intention to fix hw) */
			#endif
			#define FIX_HW_BRN_34293 /* workaround in usc */
		#else
			#error "sgxerrata.h: SGX544 Core Revision unspecified"
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
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif

#if defined(SGX545) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX545 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 100
		/* N.B. This corresponds to 1.0.7 in the bug tracker and tags */
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26336/* Workaround vertex DM pixel emits */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_26361/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_26570/* Workaround in usc*/
		#define FIX_HW_BRN_26573/* Workaround in sgxdefs */
		#define FIX_HW_BRN_26620/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_26656/* Workaround in sgx featuredefs */
		#define FIX_HW_BRN_26915/* Workaround in code (services, dx) */
		#define FIX_HW_BRN_26998/* Workaround in client drivers */
		#define FIX_HW_BRN_27002
		#define	FIX_HW_BRN_27005/* Workaround in usc/useasm */
		#define FIX_HW_BRN_27116/* Workaround in client drivers (np2 twiddled textures) */
		#define FIX_HW_BRN_27212/* Workaround in client drivers (CG lines and points) */
		#define FIX_HW_BRN_27251/* Workaround in services. Use INVALDC instead of FLUSH */
		#define FIX_HW_BRN_27266/* Workaround in services (srvkm) */
		#define FIX_HW_BRN_27272/* Workaround in client drivers */
		#define FIX_HW_BRN_27330/* Workaround in all pds code */
		#define FIX_HW_BRN_27456/* Workaround in services (srvkm) */
 		#define FIX_HW_BRN_27501/* Workaround in client drivers (CG points need point size) */
 		#define FIX_HW_BRN_27534/* Workaround in services */
		#define FIX_HW_BRN_27652/* Workaround in pdsasm */
		#define FIX_HW_BRN_27792/* Workaround in umd */
		#define FIX_HW_BRN_27904/* Workaround in USC */
		#define FIX_HW_BRN_27906/* Workaround in umd */
		#define FIX_HW_BRN_27907/* Workaround in umd */
		#define FIX_HW_BRN_27984/* Workaround in USC */
 		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_28474/* Workaround in services */
		#define FIX_HW_BRN_28475/* Workaround in services (srvclient) */
		#define FIX_HW_BRN_29019/* Workaround in client drivers */
		#define FIX_HW_BRN_29104/* Workaround in ucode */
		#define FIX_HW_BRN_29373/* Workaround in client drivers */
		#define FIX_HW_BRN_29546/* Workaround in client drivers */
		#define FIX_HW_BRN_29625/* Workaround in client drivers */
		#define FIX_HW_BRN_29702/* Workaround in services */
		#define FIX_HW_BRN_29798/* Workaround in ucode */
		#define FIX_HW_BRN_29823/* Workaround in services */
		#define FIX_HW_BRN_29838/* Workaround in client drivers */
		#define FIX_HW_BRN_30005/* Workaround in client drivers */
 		#define FIX_HW_BRN_30379/* Workaround in client drivers (complex geometry) */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31915/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU)*/
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 109
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
 		#define FIX_HW_BRN_28474/* Workaround in services */
		#define FIX_HW_BRN_28546/* Workaround in services */
		#define FIX_HW_BRN_29019/* Workaround in client drivers */
		#define FIX_HW_BRN_29104/* Workaround in ucode */
		#define FIX_HW_BRN_29373/* Workaround in client drivers */
		#define FIX_HW_BRN_29546/* Workaround in client drivers */
 		#define FIX_HW_BRN_29594/* Workaround in client drivers (complex geometry) */
		#define FIX_HW_BRN_29614/* Workaround in client drivers (default point size) */
		#define FIX_HW_BRN_29625/* Workaround in client drivers */
 		#define FIX_HW_BRN_29290/* Workaround in client drivers */
 		#define FIX_HW_BRN_29702/* Workaround in services */
 		#define FIX_HW_BRN_29798/* Workaround in ucode */
 		#define FIX_HW_BRN_29823/* Workaround in services */
 		#define FIX_HW_BRN_29838/* Workaround in client drivers */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30005/* Workaround in client drivers */
 		#define FIX_HW_BRN_30379/* Workaround in client drivers (complex geometry) */
 		#define FIX_HW_BRN_30313/* Workaround in client drivers */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31915/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31939/* workaround in uKernel */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 1011
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_29019/* Workaround in client drivers */
		#define FIX_HW_BRN_29104/* Workaround in ucode */
		#define FIX_HW_BRN_29546/* Workaround in client drivers */
 		#define FIX_HW_BRN_29594/* Workaround in client drivers (complex geometry) */
		#define FIX_HW_BRN_29614/* Workaround in client drivers (default point size) */
		#define FIX_HW_BRN_29625/* Workaround in client drivers */
 		#define FIX_HW_BRN_29702/* Workaround in services */
 		#define FIX_HW_BRN_29798/* Workaround in ucode */
 		#define FIX_HW_BRN_29823/* Workaround in services */
 		#define FIX_HW_BRN_29838/* Workaround in client drivers */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30005/* Workaround in client drivers */
 		#define FIX_HW_BRN_30313/* Workaround in client drivers */
 		#define FIX_HW_BRN_30379/* Workaround in client drivers (complex geometry) */
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31915/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31939/* workaround in uKernel */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 1012
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29019/* Workaround in client drivers */
		#define FIX_HW_BRN_29104/* Workaround in ucode */
		#define FIX_HW_BRN_29546/* Workaround in client drivers */
 		#define FIX_HW_BRN_29798/* Workaround in ucode */
 		#define FIX_HW_BRN_29838/* Workaround in client drivers */
		#define FIX_HW_BRN_29967/* Workaround in services*/ 
		#define FIX_HW_BRN_30427/* workaround in client drivers */
		#define FIX_HW_BRN_30005/* Workaround in client drivers */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31915/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31939/* workaround in uKernel */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 1013
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_29104/* Workaround in ucode */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
		#define FIX_HW_BRN_31140 /* workaround in client driver (no intention to fix) */
		#define FIX_HW_BRN_31256/* NOWA: No intention to fix */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
//	FIXME	#define FIX_HW_BRN_31542 /* workaround in uKernel and Services: incomplete for Muse */ 
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31915/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31921/* workaround in client drivers */
		#define FIX_HW_BRN_31939/* workaround in uKernel */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 10131
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
//	FIXME	#define FIX_HW_BRN_31542 /* workaround in uKernel and Services : incomplete for Muse */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31915/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31921/* workaround in client drivers */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 1014
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
//	FIXME	#define FIX_HW_BRN_31542 /* workaround in uKernel and Services : incomplete for Muse */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31921/* workaround in client drivers */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == 10141
		#define FIX_HW_BRN_25941/* Workaround double pixel emit multi-dm bug */
		#define FIX_HW_BRN_26352/* Workaround in code (ogles1/2/ovg) */
		#define FIX_HW_BRN_28249/* Workaround in client drivers (dmscalc) */
		#define FIX_HW_BRN_30898/* workaround in USC/useasm */
		#define FIX_HW_BRN_30903/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31053/* Workaround in client drivers */
//	FIXME	#define FIX_HW_BRN_31474/* workaround in uKernel : incomplete for Muse */
//	FIXME	#define FIX_HW_BRN_31542 /* workaround in uKernel and Services : incomplete for Muse */
 		#define FIX_HW_BRN_31543/* workaround in uKernel */
		#define FIX_HW_BRN_31547/* workaround in client drivers (msaa) */
		#define FIX_HW_BRN_31728/* Workaround in client drivers */
		#define FIX_HW_BRN_31921/* workaround in client drivers */
		#define FIX_HW_BRN_31988/* workaround in usc and Services */
		#define FIX_HW_BRN_32005/* Workaround in client drivers */
		#define FIX_HW_BRN_32413/* Workaround in client drivers (hybrid twiddling connection ZLS/TPU) */
		#define FIX_HW_BRN_32774/* TODO: */
		#define FIX_HW_BRN_32951/* Workaround in featuredefs and client drivers */
		#define FIX_HW_BRN_33442/* Workaround in usc/useasm */
		#define FIX_HW_BRN_33029/* Workaround in services (srvclient) */				   
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_35239 /* workaround in uKernel */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
	#else
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		/* RTL head */
	#else
		#error "sgxerrata.h: SGX545 Core Revision unspecified"
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif

#if defined(SGX554) && !defined(SGX_CORE_DEFINED)
	/* define the _current_ SGX554 RTL head revision */
	#define SGX_CORE_REV_HEAD	0
	#if defined(USE_SGX_CORE_REV_HEAD)
		/* build config selects Core Revision to be the Head */
		#define SGX_CORE_REV	SGX_CORE_REV_HEAD
	#endif

	#if SGX_CORE_REV == 1251
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31562/* workaround in uKernel (no intention to fix hw) */
		#define FIX_HW_BRN_31930/* workaround in uKernel (no intention to fix hw) */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31964/* workaround in uKernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
		#if defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_31989/* workaround in uKernel (no intention to fix hw) */
			#define FIX_HW_BRN_32052/* workaround in uKernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_33309/* workaround in ukernel (no intention to fix hw)*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel*/
		#endif
		#define FIX_HW_BRN_33753/* workaround in ukernel */
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34264 /* workaround in uKernel */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
		#define FIX_HW_BRN_34811 /* workaround in uKernel */
		#define FIX_HW_BRN_34939 /* workaround in services */
		#define FIX_HW_BRN_35498 /* Workaround in client drivers */
		#define FIX_HW_BRN_36513 /* workaround in uKernel and Services */
	#else	
	#if SGX_CORE_REV == SGX_CORE_REV_HEAD
		#define FIX_HW_BRN_29424/* workaround in uKernel */
		#define FIX_HW_BRN_30701/* workaround in uKernel */
		#define FIX_HW_BRN_30749/* workaround in uKernel */
		#define FIX_HW_BRN_31175/* workaround in client drivers (no intention to fix hw) */
		#define FIX_HW_BRN_31562/* workaround in uKernel (no intention to fix hw) */
 		#define FIX_HW_BRN_31930/* workaround in uKernel (no intention to fix hw) */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31964/* workaround in uKernel (no intention to fix hw) */
 		#endif
		#define FIX_HW_BRN_31982/* workaround in codegen */
 		#if defined(SGX_FEATURE_MP)
 			#define FIX_HW_BRN_31989/* workaround in uKernel (no intention to fix hw) */
 			#define FIX_HW_BRN_32052/* workaround in uKernel (no intention to fix hw) */
 		#endif
 		#define FIX_HW_BRN_33309/* workaround in ukernel (no intention to fix hw)*/
 		#if defined(SUPPORT_SGX_LOW_LATENCY_SCHEDULING) && defined(SGX_FEATURE_MP)
			#define FIX_HW_BRN_33657/* workaround in ukernel (no intention to fix hw) */
		#endif
		#define FIX_HW_BRN_34043 /* workaround in services */
		#define FIX_HW_BRN_34293 /* workaround in usc */
		#define FIX_HW_BRN_34351 /* Implicit workaround in client drivers */
	#else
		#error "sgxerrata.h: SGX554 Core Revision unspecified"
	#endif
	#endif
	/* signal that the Core Version has a valid definition */
	#define SGX_CORE_DEFINED
#endif

#if !defined(SGX_CORE_DEFINED)
	#error "sgxerrata.h: SGX Core Version unspecified"
#endif

/*
	Code including this file can request a table mapping core IDs to
	the errata that affect them so they can support multiple
	cores in one binary.
*/
#if defined(INCLUDE_SGX_BUG_TABLE)

#include "img_types.h"

#include "sgxcoretypes.h"

#define SGX_BUG_FLAGS_FIX_HW_BRN_21697				(0x00000001)
#define SGX_BUG_FLAGS_FIX_HW_BRN_21713				(0x00000002)
#define SGX_BUG_FLAGS_FIX_HW_BRN_21784				(0x00000004)
#define SGX_BUG_FLAGS_FIX_HW_BRN_21752				(0x00000008)
#define SGX_BUG_FLAGS_FIX_HW_BRN_23062				(0x00000010)
#define SGX_BUG_FLAGS_FIX_HW_BRN_23164				(0x00000020)
#define SGX_BUG_FLAGS_FIX_HW_BRN_23461				(0x00000040)
#define SGX_BUG_FLAGS_FIX_HW_BRN_23960				(0x00000080)
#define SGX_BUG_FLAGS_FIX_HW_BRN_24895				(0x00000100)
#define SGX_BUG_FLAGS_FIX_HW_BRN_25060				(0x00000200)
#define SGX_BUG_FLAGS_FIX_HW_BRN_25355				(0x00000400)
#define SGX_BUG_FLAGS_FIX_HW_BRN_25804				(0x00000800)
#define SGX_BUG_FLAGS_FIX_HW_BRN_25580				(0x00001000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_25582				(0x00002000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_26570				(0x00004000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_26681				(0x00008000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_27005				(0x00010000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_27235				(0x00020000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_27723				(0x00040000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_27904				(0x00080000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_27984				(0x00100000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_28033				(0x00200000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_29643				(0x00400000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_30795				(0x00800000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_30853				(0x01000000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_30871				(0x02000000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_30898				(0x04000000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_31988				(0x08000000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_33134				(0x10000000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_33442				(0x20000000)
#define SGX_BUG_FLAGS_FIX_HW_BRN_34293				(0x40000000)

#endif /* defined(INCLUDE_SGX_BUG_TABLE) */

#endif /* _SGXERRATA_H_ */

/******************************************************************************
 End of file (sgxerrata.h)
******************************************************************************/
