#ifndef PSP2_PVR_HINT_H
#define PSP2_PVR_HINT_H

// Universal header for PVRSRV apphint. Use this instead of services.h

typedef unsigned int IMG_UINT32;
typedef int IMG_BOOL;
typedef char IMG_CHAR;
typedef float IMG_FLOAT;

typedef struct _PVRSRV_PSP2_APPHINT_
{
	/* Common hints */

	IMG_UINT32 ui32PDSFragBufferSize;
	IMG_UINT32 ui32ParamBufferSize;
	IMG_UINT32 ui32DriverMemorySize;
	IMG_UINT32 ui32ExternalZBufferMode;
	IMG_UINT32 ui32ExternalZBufferXSize;
	IMG_UINT32 ui32ExternalZBufferYSize;
	IMG_BOOL bDumpProfileData;
	IMG_UINT32 ui32ProfileStartFrame;
	IMG_UINT32 ui32ProfileEndFrame;
	IMG_BOOL bDisableMetricsOutput;
	IMG_CHAR szWindowSystem[256]; //path to libpvrPSP2_WSEGL module
	IMG_CHAR szGLES1[256]; //path to libGLESv1_CM module
	IMG_CHAR szGLES2[256]; //path to libGLESv2 module

	/* common OGLES hints */

	IMG_BOOL bFBODepthDiscard;
	IMG_BOOL bOptimisedValidation;
	IMG_BOOL bDisableHWTQTextureUpload;
	IMG_BOOL bDisableHWTQNormalBlit;
	IMG_BOOL bDisableHWTQBufferBlit;
	IMG_BOOL bDisableHWTQMipGen;
	IMG_BOOL bDisableHWTextureUpload;
	IMG_UINT32 ui32FlushBehaviour;
	IMG_BOOL bEnableStaticPDSVertex;
	IMG_BOOL bEnableStaticMTECopy;
	IMG_BOOL bDisableStaticPDSPixelSAProgram;
	IMG_BOOL bDisableUSEASMOPT;
	IMG_BOOL bDumpShaders;
	IMG_UINT32 ui32DefaultVertexBufferSize;
	IMG_UINT32 ui32MaxVertexBufferSize;
	IMG_UINT32 ui32DefaultIndexBufferSize;
	IMG_UINT32 ui32DefaultPDSVertBufferSize;
	IMG_UINT32 ui32DefaultPregenPDSVertBufferSize;
	IMG_UINT32 ui32DefaultPregenMTECopyBufferSize;
	IMG_UINT32 ui32DefaultVDMBufferSize;
	IMG_BOOL bEnableMemorySpeedTest;
	IMG_BOOL bEnableAppTextureDependency;
	IMG_UINT32 ui32UNCTexHeapSize;
	IMG_UINT32 ui32CDRAMTexHeapSize;
	IMG_BOOL bEnableUNCAutoExtend;
	IMG_BOOL bEnableCDRAMAutoExtend;
	IMG_UINT32 ui32SwTexOpThreadNum;
	IMG_UINT32 ui32SwTexOpThreadPriority;
	IMG_UINT32 ui32SwTexOpThreadAffinity;
	IMG_UINT32 ui32SwTexOpMaxUltNum;
	IMG_UINT32 ui32SwTexOpCleanupDelay;
	IMG_UINT32 ui32PrimitiveSplitThreshold;
	IMG_UINT32 ui32MaxDrawCallsPerCore;

	/* OGLES2 hints */

	IMG_UINT32 ui32AdjustShaderPrecision;
	IMG_BOOL bDumpCompilerLogFiles;
	IMG_BOOL bStrictBinaryVersionComparison;
	IMG_FLOAT fPolygonUnitsMultiplier;
	IMG_FLOAT fPolygonFactorMultiplier;
	IMG_BOOL bDumpUSPOutput;
	IMG_BOOL bDumpShaderAnalysis;
	IMG_BOOL bTrackUSCMemory;
	IMG_UINT32 ui32OverloadTexLayout;
	IMG_BOOL bInitialiseVSOutputs;
	IMG_UINT32 ui32TriangleSplitPixelThreshold;
	IMG_BOOL bDynamicSplitCalc;
	IMG_BOOL bAllowTrilinearNPOT;
	IMG_BOOL bEnableVaryingPrecisionOpt;
	IMG_BOOL bDisableAsyncTextureOp;
	IMG_UINT32 ui32GLSLEnabledWarnings;

} PVRSRV_PSP2_APPHINT;

unsigned int PVRSRVInitializeAppHint(PVRSRV_PSP2_APPHINT *psAppHint);
unsigned int PVRSRVCreateVirtualAppHint(PVRSRV_PSP2_APPHINT *psAppHint);

#endif