module directx.d3d9;
/*==========================================================================;
 *
 *  Copyright (C) Microsoft Corporation.  All Rights Reserved.
 *
 *  File:   d3d9.h
 *  Content:    Direct3D include file
 *
 ****************************************************************************/

version(Windows):

import directx.win32;
import directx.d3dcommon;

struct D3DVIEWPORT9 {
    DWORD       X;
    DWORD       Y;            /* Viewport Top left */
    DWORD       Width;
    DWORD       Height;       /* Viewport Dimensions */
    float       MinZ;         /* Min/max of clip Volume */
    float       MaxZ;
}

struct D3DCLIPSTATUS9 {
    DWORD ClipUnion;
    DWORD ClipIntersection;
}

struct D3DMATERIAL9 {
    D3DCOLORVALUE   Diffuse;        /* Diffuse color RGBA */
    D3DCOLORVALUE   Ambient;        /* Ambient color RGB */
    D3DCOLORVALUE   Specular;       /* Specular 'shininess' */
    D3DCOLORVALUE   Emissive;       /* Emissive color RGB */
    float           Power;          /* Sharpness if specular highlight */
}

struct D3DLIGHT9 {
    D3DLIGHTTYPE    Type;            /* Type of light source */
    D3DCOLORVALUE   Diffuse;         /* Diffuse color of light */
    D3DCOLORVALUE   Specular;        /* Specular color of light */
    D3DCOLORVALUE   Ambient;         /* Ambient color of light */
    D3DVECTOR       Position;         /* Position in world space */
    D3DVECTOR       Direction;        /* Direction in world space */
    float           Range;            /* Cutoff range */
    float           Falloff;          /* Falloff */
    float           Attenuation0;     /* Constant attenuation */
    float           Attenuation1;     /* Linear attenuation */
    float           Attenuation2;     /* Quadratic attenuation */
    float           Theta;            /* Inner angle of spotlight cone */
    float           Phi;              /* Outer angle of spotlight cone */
}

struct D3DPRESENTSTATS {
    UINT PresentCount;
    UINT PresentRefreshCount;
    UINT SyncRefreshCount;
    LARGE_INTEGER SyncQPCTime;
    LARGE_INTEGER SyncGPUTime;
}

alias DWORD D3DSCANLINEORDERING;
enum : D3DSCANLINEORDERING {
    D3DSCANLINEORDERING_UNKNOWN                    = 0,
    D3DSCANLINEORDERING_PROGRESSIVE                = 1,
    D3DSCANLINEORDERING_INTERLACED                 = 2,
}

struct D3DDISPLAYMODEEX {
    UINT                    Size;
    UINT                    Width;
    UINT                    Height;
    UINT                    RefreshRate;
    D3DFORMAT               Format;
    D3DSCANLINEORDERING     ScanLineOrdering;
}

struct D3DDISPLAYMODEFILTER {
    UINT                    Size;
    D3DFORMAT               Format;
    D3DSCANLINEORDERING     ScanLineOrdering;
}

alias DWORD D3DDISPLAYROTATION;
enum : D3DDISPLAYROTATION {
    D3DDISPLAYROTATION_IDENTITY = 1, // No rotation.
    D3DDISPLAYROTATION_90       = 2, // Rotated 90 degrees.
    D3DDISPLAYROTATION_180      = 3, // Rotated 180 degrees.
    D3DDISPLAYROTATION_270      = 4  // Rotated 270 degrees.
}

alias D3DTEXTUREFILTERTYPE = DWORD;
enum : D3DTEXTUREFILTERTYPE {
    D3DTEXF_NONE            = 0,    // filtering disabled (valid for mip filter only)
    D3DTEXF_POINT           = 1,    // nearest
    D3DTEXF_LINEAR          = 2,    // linear interpolation
    D3DTEXF_ANISOTROPIC     = 3,    // anisotropic
    D3DTEXF_PYRAMIDALQUAD   = 6,    // 4-sample tent
    D3DTEXF_GAUSSIANQUAD    = 7,    // 4-sample gaussian
    /* D3D9Ex only -- */
    D3DTEXF_CONVOLUTIONMONO = 8,    // Convolution filter for monochrome textures
    /* -- D3D9Ex only */
}

/*
* State enumerants for per-sampler texture processing.
*/
alias D3DSAMPLERSTATETYPE = DWORD;
enum : D3DSAMPLERSTATETYPE {
    D3DSAMP_ADDRESSU       = 1,  /* D3DTEXTUREADDRESS for U coordinate */
    D3DSAMP_ADDRESSV       = 2,  /* D3DTEXTUREADDRESS for V coordinate */
    D3DSAMP_ADDRESSW       = 3,  /* D3DTEXTUREADDRESS for W coordinate */
    D3DSAMP_BORDERCOLOR    = 4,  /* D3DCOLOR */
    D3DSAMP_MAGFILTER      = 5,  /* D3DTEXTUREFILTER filter to use for magnification */
    D3DSAMP_MINFILTER      = 6,  /* D3DTEXTUREFILTER filter to use for minification */
    D3DSAMP_MIPFILTER      = 7,  /* D3DTEXTUREFILTER filter to use between mipmaps during minification */
    D3DSAMP_MIPMAPLODBIAS  = 8,  /* float Mipmap LOD bias */
    D3DSAMP_MAXMIPLEVEL    = 9,  /* DWORD 0..(n-1) LOD index of largest map to use (0 == largest) */
    D3DSAMP_MAXANISOTROPY  = 10, /* DWORD maximum anisotropy */
    D3DSAMP_SRGBTEXTURE    = 11, /* Default = 0 (which means Gamma 1.0,
    no correction required.) else correct for
    Gamma = 2.2 */
    D3DSAMP_ELEMENTINDEX   = 12, /* When multi-element texture is assigned to sampler, this
    indicates which element index to use.  Default = 0.  */
    D3DSAMP_DMAPOFFSET     = 13, /* Offset in vertices in the pre-sampled displacement map.
    Only valid for D3DDMAPSAMPLER sampler  */
}

alias DWORD D3DQUERYTYPE;
enum : D3DQUERYTYPE {
    D3DQUERYTYPE_VCACHE                 = 4, /* D3DISSUE_END */
    D3DQUERYTYPE_RESOURCEMANAGER        = 5, /* D3DISSUE_END */
    D3DQUERYTYPE_VERTEXSTATS            = 6, /* D3DISSUE_END */
    D3DQUERYTYPE_EVENT                  = 8, /* D3DISSUE_END */
    D3DQUERYTYPE_OCCLUSION              = 9, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_TIMESTAMP              = 10, /* D3DISSUE_END */
    D3DQUERYTYPE_TIMESTAMPDISJOINT      = 11, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_TIMESTAMPFREQ          = 12, /* D3DISSUE_END */
    D3DQUERYTYPE_PIPELINETIMINGS        = 13, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_INTERFACETIMINGS       = 14, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_VERTEXTIMINGS          = 15, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_PIXELTIMINGS           = 16, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_BANDWIDTHTIMINGS       = 17, /* D3DISSUE_BEGIN, D3DISSUE_END */
    D3DQUERYTYPE_CACHEUTILIZATION       = 18, /* D3DISSUE_BEGIN, D3DISSUE_END */
    /* D3D9Ex only -- */
    D3DQUERYTYPE_MEMORYPRESSURE         = 19, /* D3DISSUE_BEGIN, D3DISSUE_END */
}

alias D3DCOMPOSERECTSOP = DWORD;
enum : D3DCOMPOSERECTSOP {
    D3DCOMPOSERECTS_COPY     = 1,
    D3DCOMPOSERECTS_OR       = 2,
    D3DCOMPOSERECTS_AND      = 3,
    D3DCOMPOSERECTS_NEG      = 4
}

struct D3DVERTEXELEMENT9 {
    WORD    Stream;     // Stream index
    WORD    Offset;     // Offset in the stream in bytes
    BYTE    Type;       // Data type
    BYTE    Method;     // Processing method
    BYTE    Usage;      // Semantics
    BYTE    UsageIndex; // Semantic index
}

extern (C++) interface IDirect3D9 : IUnknown {
    HRESULT RegisterSoftwareDevice(void* pInitializeFunction);
    UINT GetAdapterCount();
    HRESULT GetAdapterIdentifier(UINT Adapter,DWORD Flags,D3DADAPTER_IDENTIFIER9* pIdentifier);
    UINT GetAdapterModeCount(UINT Adapter,D3DFORMAT Format);
    HRESULT EnumAdapterModes(UINT Adapter,D3DFORMAT Format,UINT Mode,D3DDISPLAYMODE* pMode);
    HRESULT GetAdapterDisplayMode(UINT Adapter,D3DDISPLAYMODE* pMode);
    HRESULT CheckDeviceType(UINT Adapter,D3DDEVTYPE DevType,D3DFORMAT AdapterFormat,D3DFORMAT BackBufferFormat,BOOL bWindowed);
    HRESULT CheckDeviceFormat(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,DWORD Usage,D3DRESOURCETYPE RType,D3DFORMAT CheckFormat);
    HRESULT CheckDeviceMultiSampleType(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SurfaceFormat,BOOL Windowed,D3DMULTISAMPLE_TYPE MultiSampleType,DWORD* pQualityLevels);
    HRESULT CheckDepthStencilMatch(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,D3DFORMAT RenderTargetFormat,D3DFORMAT DepthStencilFormat);
    HRESULT CheckDeviceFormatConversion(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SourceFormat,D3DFORMAT TargetFormat);
    HRESULT GetDeviceCaps(UINT Adapter,D3DDEVTYPE DeviceType,D3DCAPS9* pCaps);
    HMONITOR GetAdapterMonitor(UINT Adapter);
    HRESULT CreateDevice(UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,IDirect3DDevice9* ppReturnedDeviceInterface);
}

extern (C++) interface IDirect3DDevice9 : IUnknown {
    HRESULT TestCooperativeLevel();
    UINT GetAvailableTextureMem();
    HRESULT EvictManagedResources();
    HRESULT GetDirect3D(IDirect3D9* ppD3D9);
    HRESULT GetDeviceCaps(D3DCAPS9* pCaps);
    HRESULT GetDisplayMode(UINT iSwapChain,D3DDISPLAYMODE* pMode);
    HRESULT GetCreationParameters(D3DDEVICE_CREATION_PARAMETERS *pParameters);
    HRESULT SetCursorProperties(UINT XHotSpot,UINT YHotSpot,IDirect3DSurface9 pCursorBitmap);
    void SetCursorPosition(int X,int Y,DWORD Flags);
    BOOL ShowCursor(BOOL bShow);
    HRESULT CreateAdditionalSwapChain(D3DPRESENT_PARAMETERS* pPresentationParameters,IDirect3DSwapChain9* pSwapChain);
    HRESULT GetSwapChain(UINT iSwapChain,IDirect3DSwapChain9* pSwapChain);
    UINT GetNumberOfSwapChains();
    HRESULT Reset(D3DPRESENT_PARAMETERS* pPresentationParameters);
    HRESULT Present(const(RECT)* pSourceRect,const(RECT)* pDestRect,HWND hDestWindowOverride,const(RGNDATA)* pDirtyRegion);
    HRESULT GetBackBuffer(UINT iSwapChain,UINT iBackBuffer,D3DBACKBUFFER_TYPE Type,IDirect3DSurface9* ppBackBuffer);
    HRESULT GetRasterStatus(UINT iSwapChain,D3DRASTER_STATUS* pRasterStatus);
    HRESULT SetDialogBoxMode(BOOL bEnableDialogs);
    void SetGammaRamp(UINT iSwapChain,DWORD Flags,const(D3DGAMMARAMP)* pRamp);
    void GetGammaRamp(UINT iSwapChain,D3DGAMMARAMP* pRamp);
    HRESULT CreateTexture(UINT Width,UINT Height,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DTexture9* ppTexture,HANDLE* pSharedHandle);
    HRESULT CreateVolumeTexture(UINT Width,UINT Height,UINT Depth,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DVolumeTexture9* ppVolumeTexture,HANDLE* pSharedHandle);
    HRESULT CreateCubeTexture(UINT EdgeLength,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DCubeTexture9* ppCubeTexture,HANDLE* pSharedHandle);
    HRESULT CreateVertexBuffer(UINT Length,DWORD Usage,DWORD FVF,D3DPOOL Pool,IDirect3DVertexBuffer9* ppVertexBuffer,HANDLE* pSharedHandle);
    HRESULT CreateIndexBuffer(UINT Length,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DIndexBuffer9* ppIndexBuffer,HANDLE* pSharedHandle);
    HRESULT CreateRenderTarget(UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Lockable,IDirect3DSurface9* ppSurface,HANDLE* pSharedHandle);
    HRESULT CreateDepthStencilSurface(UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Discard,IDirect3DSurface9* ppSurface,HANDLE* pSharedHandle);
    HRESULT UpdateSurface(IDirect3DSurface9 pSourceSurface,const(RECT)* pSourceRect,IDirect3DSurface9 pDestinationSurface,const(POINT)* pDestPoint);
    HRESULT UpdateTexture(IDirect3DBaseTexture9 pSourceTexture,IDirect3DBaseTexture9 pDestinationTexture);
    HRESULT GetRenderTargetData(IDirect3DSurface9 pRenderTarget,IDirect3DSurface9 pDestSurface);
    HRESULT GetFrontBufferData(UINT iSwapChain,IDirect3DSurface9 pDestSurface);
    HRESULT StretchRect(IDirect3DSurface9 pSourceSurface,const(RECT)* pSourceRect,IDirect3DSurface9 pDestSurface,const(RECT)* pDestRect,D3DTEXTUREFILTERTYPE Filter);
    HRESULT ColorFill(IDirect3DSurface9 pSurface,const(RECT)* pRect,D3DCOLOR color);
    HRESULT CreateOffscreenPlainSurface(UINT Width,UINT Height,D3DFORMAT Format,D3DPOOL Pool,IDirect3DSurface9* ppSurface,HANDLE* pSharedHandle);
    HRESULT SetRenderTarget(DWORD RenderTargetIndex,IDirect3DSurface9 pRenderTarget);
    HRESULT GetRenderTarget(DWORD RenderTargetIndex,IDirect3DSurface9* ppRenderTarget);
    HRESULT SetDepthStencilSurface(IDirect3DSurface9 pNewZStencil);
    HRESULT GetDepthStencilSurface(IDirect3DSurface9* ppZStencilSurface);
    HRESULT BeginScene();
    HRESULT EndScene();
    HRESULT Clear(DWORD Count,const(D3DRECT)* pRects,DWORD Flags,D3DCOLOR Color,float Z,DWORD Stencil);
    HRESULT SetTransform(D3DTRANSFORMSTATETYPE State,const(D3DMATRIX)* pMatrix);
    HRESULT GetTransform(D3DTRANSFORMSTATETYPE State,D3DMATRIX* pMatrix);
    HRESULT MultiplyTransform(D3DTRANSFORMSTATETYPE,const(D3DMATRIX)*);
    HRESULT SetViewport(const(D3DVIEWPORT9)* pViewport);
    HRESULT GetViewport(D3DVIEWPORT9* pViewport);
    HRESULT SetMaterial(const(D3DMATERIAL9)* pMaterial);
    HRESULT GetMaterial(D3DMATERIAL9* pMaterial);
    HRESULT SetLight(DWORD Index,const(D3DLIGHT9)*);
    HRESULT GetLight(DWORD Index,D3DLIGHT9*);
    HRESULT LightEnable(DWORD Index,BOOL Enable);
    HRESULT GetLightEnable(DWORD Index,BOOL* pEnable);
    HRESULT SetClipPlane(DWORD Index,const(float)* pPlane);
    HRESULT GetClipPlane(DWORD Index,float* pPlane);
    HRESULT SetRenderState(D3DRENDERSTATETYPE State,DWORD Value);
    HRESULT GetRenderState(D3DRENDERSTATETYPE State,DWORD* pValue);
    HRESULT CreateStateBlock(D3DSTATEBLOCKTYPE Type,IDirect3DStateBlock9* ppSB);
    HRESULT BeginStateBlock();
    HRESULT EndStateBlock(IDirect3DStateBlock9* ppSB);
    HRESULT SetClipStatus(const(D3DCLIPSTATUS9)* pClipStatus);
    HRESULT GetClipStatus(D3DCLIPSTATUS9* pClipStatus);
    HRESULT GetTexture(DWORD Stage,IDirect3DBaseTexture9* ppTexture);
    HRESULT SetTexture(DWORD Stage,IDirect3DBaseTexture9 pTexture);
    HRESULT GetTextureStageState(DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD* pValue);
    HRESULT SetTextureStageState(DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD Value);
    HRESULT GetSamplerState(DWORD Sampler,D3DSAMPLERSTATETYPE Type,DWORD* pValue);
    HRESULT SetSamplerState(DWORD Sampler,D3DSAMPLERSTATETYPE Type,DWORD Value);
    HRESULT ValidateDevice(DWORD* pNumPasses);
    HRESULT SetPaletteEntries(UINT PaletteNumber,const(PALETTEENTRY)* pEntries);
    HRESULT GetPaletteEntries(UINT PaletteNumber,PALETTEENTRY* pEntries);
    HRESULT SetCurrentTexturePalette(UINT PaletteNumber);
    HRESULT GetCurrentTexturePalette(UINT *PaletteNumber);
    HRESULT SetScissorRect(const(RECT)* pRect);
    HRESULT GetScissorRect(RECT* pRect);
    HRESULT SetSoftwareVertexProcessing(BOOL bSoftware);
    BOOL GetSoftwareVertexProcessing();
    HRESULT SetNPatchMode(float nSegments);
    float GetNPatchMode();
    HRESULT DrawPrimitive(D3DPRIMITIVETYPE PrimitiveType,UINT StartVertex,UINT PrimitiveCount);
    HRESULT DrawIndexedPrimitive(D3DPRIMITIVETYPE,INT BaseVertexIndex,UINT MinVertexIndex,UINT NumVertices,UINT startIndex,UINT primCount);
    HRESULT DrawPrimitiveUP(D3DPRIMITIVETYPE PrimitiveType,UINT PrimitiveCount,const(void)* pVertexStreamZeroData,UINT VertexStreamZeroStride);
    HRESULT DrawIndexedPrimitiveUP(D3DPRIMITIVETYPE PrimitiveType,UINT MinVertexIndex,UINT NumVertices,UINT PrimitiveCount,const(void)* pIndexData,D3DFORMAT IndexDataFormat,const(void)* pVertexStreamZeroData,UINT VertexStreamZeroStride);
    HRESULT ProcessVertices(UINT SrcStartIndex,UINT DestIndex,UINT VertexCount,IDirect3DVertexBuffer9 pDestBuffer,IDirect3DVertexDeclaration9 pVertexDecl,DWORD Flags);
    HRESULT CreateVertexDeclaration(const(D3DVERTEXELEMENT9)* pVertexElements,IDirect3DVertexDeclaration9* ppDecl);
    HRESULT SetVertexDeclaration(IDirect3DVertexDeclaration9 pDecl);
    HRESULT GetVertexDeclaration(IDirect3DVertexDeclaration9* ppDecl);
    HRESULT SetFVF(DWORD FVF);
    HRESULT GetFVF(DWORD* pFVF);
    HRESULT CreateVertexShader(const(DWORD)* pFunction,IDirect3DVertexShader9* ppShader);
    HRESULT SetVertexShader(IDirect3DVertexShader9 pShader);
    HRESULT GetVertexShader(IDirect3DVertexShader9* ppShader);
    HRESULT SetVertexShaderConstantF(UINT StartRegister,const(float)* pConstantData,UINT Vector4fCount);
    HRESULT GetVertexShaderConstantF(UINT StartRegister,float* pConstantData,UINT Vector4fCount);
    HRESULT SetVertexShaderConstantI(UINT StartRegister,const(int)* pConstantData,UINT Vector4iCount);
    HRESULT GetVertexShaderConstantI(UINT StartRegister,int* pConstantData,UINT Vector4iCount);
    HRESULT SetVertexShaderConstantB(UINT StartRegister,const(BOOL)* pConstantData,UINT  BoolCount);
    HRESULT GetVertexShaderConstantB(UINT StartRegister,BOOL* pConstantData,UINT BoolCount);
    HRESULT SetStreamSource(UINT StreamNumber,IDirect3DVertexBuffer9 pStreamData,UINT OffsetInBytes,UINT Stride);
    HRESULT GetStreamSource(UINT StreamNumber,IDirect3DVertexBuffer9* ppStreamData,UINT* pOffsetInBytes,UINT* pStride);
    HRESULT SetStreamSourceFreq(UINT StreamNumber,UINT Setting);
    HRESULT GetStreamSourceFreq(UINT StreamNumber,UINT* pSetting);
    HRESULT SetIndices(IDirect3DIndexBuffer9 pIndexData);
    HRESULT GetIndices(IDirect3DIndexBuffer9* ppIndexData);
    HRESULT CreatePixelShader(const(DWORD)* pFunction,IDirect3DPixelShader9* ppShader);
    HRESULT SetPixelShader(IDirect3DPixelShader9 pShader);
    HRESULT GetPixelShader(IDirect3DPixelShader9* ppShader);
    HRESULT SetPixelShaderConstantF(UINT StartRegister,const(float)* pConstantData,UINT Vector4fCount);
    HRESULT GetPixelShaderConstantF(UINT StartRegister,float* pConstantData,UINT Vector4fCount);
    HRESULT SetPixelShaderConstantI(UINT StartRegister,const(int)* pConstantData,UINT Vector4iCount);
    HRESULT GetPixelShaderConstantI(UINT StartRegister,int* pConstantData,UINT Vector4iCount);
    HRESULT SetPixelShaderConstantB(UINT StartRegister,const(BOOL)* pConstantData,UINT  BoolCount);
    HRESULT GetPixelShaderConstantB(UINT StartRegister,BOOL* pConstantData,UINT BoolCount);
    HRESULT DrawRectPatch(UINT Handle,const(float)* pNumSegs,const(D3DRECTPATCH_INFO)* pRectPatchInfo);
    HRESULT DrawTriPatch(UINT Handle,const(float)* pNumSegs,const(D3DTRIPATCH_INFO)* pTriPatchInfo);
    HRESULT DeletePatch(UINT Handle);
    HRESULT CreateQuery(D3DQUERYTYPE Type,IDirect3DQuery9* ppQuery);
    HRESULT SetConvolutionMonoKernel(UINT width,UINT height,float* rows,float* columns);
    HRESULT ComposeRects(IDirect3DSurface9 pSrc,IDirect3DSurface9 pDst,IDirect3DVertexBuffer9 pSrcRectDescs,UINT NumRects,IDirect3DVertexBuffer9 pDstRectDescs,D3DCOMPOSERECTSOP Operation,int Xoffset,int Yoffset);
    HRESULT PresentEx(const(RECT)* pSourceRect,const(RECT)* pDestRect,HWND hDestWindowOverride,const(RGNDATA)* pDirtyRegion,DWORD dwFlags);
    HRESULT GetGPUThreadPriority(INT* pPriority);
    HRESULT SetGPUThreadPriority(INT Priority);
    HRESULT WaitForVBlank(UINT iSwapChain);
    HRESULT CheckResourceResidency(IDirect3DResource9* pResourceArray,UINT32 NumResources);
    HRESULT SetMaximumFrameLatency(UINT MaxLatency);
    HRESULT GetMaximumFrameLatency(UINT* pMaxLatency);
    HRESULT CheckDeviceState(HWND hDestinationWindow);
}

extern (C++) interface IDirect3DStateBlock9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT Capture();
    HRESULT Apply();
}

mixin(uuid!(IDirect3DSwapChain9, "794950f2-adfc-458a-905e-10a10b0b503b"));
extern (C++) interface IDirect3DSwapChain9 : IUnknown {
    HRESULT Present(const(RECT)* pSourceRect,const(RECT)* pDestRect,HWND hDestWindowOverride,const(RGNDATA)* pDirtyRegion,DWORD dwFlags);
    HRESULT GetFrontBufferData(IDirect3DSurface9 pDestSurface);
    HRESULT GetBackBuffer(UINT iBackBuffer,D3DBACKBUFFER_TYPE Type,IDirect3DSurface9* ppBackBuffer);
    HRESULT GetRasterStatus(D3DRASTER_STATUS* pRasterStatus);
    HRESULT GetDisplayMode(D3DDISPLAYMODE* pMode);
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT GetPresentParameters(D3DPRESENT_PARAMETERS* pPresentationParameters);
}

extern (C++) interface IDirect3DResource9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT SetPrivateData(REFGUID refguid,const(void)* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData(REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData(REFGUID refguid);
    DWORD SetPriority(DWORD PriorityNew);
    DWORD GetPriority();
    void PreLoad();
    D3DRESOURCETYPE GetType();
}

extern (C++) interface IDirect3DVertexDeclaration9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT GetDeclaration(D3DVERTEXELEMENT9* pElement,UINT* pNumElements);
}

extern (C++) interface IDirect3DVertexShader9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT GetFunction(void*,UINT* pSizeOfData);
}

extern (C++) interface IDirect3DPixelShader9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT GetFunction(void*,UINT* pSizeOfData);
}

extern (C++) interface IDirect3DBaseTexture9 : IDirect3DResource9 {
    DWORD SetLOD(DWORD LODNew);
    DWORD GetLOD();
    DWORD GetLevelCount();
    HRESULT SetAutoGenFilterType(D3DTEXTUREFILTERTYPE FilterType);
    D3DTEXTUREFILTERTYPE GetAutoGenFilterType();
    void GenerateMipSubLevels();
}

extern (C++) interface IDirect3DTexture9 : IDirect3DBaseTexture9 {
    HRESULT GetLevelDesc(UINT Level,D3DSURFACE_DESC *pDesc);
    HRESULT GetSurfaceLevel(UINT Level,IDirect3DSurface9* ppSurfaceLevel);
    HRESULT LockRect(UINT Level,D3DLOCKED_RECT* pLockedRect,const(RECT)* pRect,DWORD Flags);
    HRESULT UnlockRect(UINT Level);
    HRESULT AddDirtyRect(const(RECT)* pDirtyRect);
}

extern (C++) interface IDirect3DVolumeTexture9 : IDirect3DBaseTexture9 {
    HRESULT GetLevelDesc(UINT Level,D3DVOLUME_DESC *pDesc);
    HRESULT GetVolumeLevel(UINT Level,IDirect3DVolume9* ppVolumeLevel);
    HRESULT LockBox(UINT Level,D3DLOCKED_BOX* pLockedVolume,const(D3DBOX)* pBox,DWORD Flags);
    HRESULT UnlockBox(UINT Level);
    HRESULT AddDirtyBox(const(D3DBOX)* pDirtyBox);
}

extern (C++) interface IDirect3DCubeTexture9 : IDirect3DBaseTexture9 {
    HRESULT GetLevelDesc(UINT Level,D3DSURFACE_DESC *pDesc);
    HRESULT GetCubeMapSurface(D3DCUBEMAP_FACES FaceType,UINT Level,IDirect3DSurface9* ppCubeMapSurface);
    HRESULT LockRect(D3DCUBEMAP_FACES FaceType,UINT Level,D3DLOCKED_RECT* pLockedRect,const(RECT)* pRect,DWORD Flags);
    HRESULT UnlockRect(D3DCUBEMAP_FACES FaceType,UINT Level);
    HRESULT AddDirtyRect(D3DCUBEMAP_FACES FaceType,const(RECT)* pDirtyRect);
}

struct D3DVERTEXBUFFER_DESC {
    D3DFORMAT           Format;
    D3DRESOURCETYPE     Type;
    DWORD               Usage;
    D3DPOOL             Pool;
    UINT                Size;
    DWORD               FVF;
}

struct D3DINDEXBUFFER_DESC {
    D3DFORMAT           Format;
    D3DRESOURCETYPE     Type;
    DWORD               Usage;
    D3DPOOL             Pool;
    UINT                Size;
}

extern (C++) interface IDirect3DVertexBuffer9 : IDirect3DResource9 {
    HRESULT Lock(UINT OffsetToLock,UINT SizeToLock,void** ppbData,DWORD Flags);
    HRESULT Unlock();
    HRESULT GetDesc(D3DVERTEXBUFFER_DESC *pDesc);
}

extern (C++) interface IDirect3DIndexBuffer9 : IDirect3DResource9 {
    HRESULT Lock(UINT OffsetToLock,UINT SizeToLock,void** ppbData,DWORD Flags);
    HRESULT Unlock();
    HRESULT GetDesc(D3DINDEXBUFFER_DESC *pDesc);
}

extern (C++) interface IDirect3DSurface9 : IDirect3DResource9 {
    HRESULT GetContainer(REFIID riid,void** ppContainer);
    HRESULT GetDesc(D3DSURFACE_DESC *pDesc);
    HRESULT LockRect(D3DLOCKED_RECT* pLockedRect,const(RECT)* pRect,DWORD Flags);
    HRESULT UnlockRect();
    HRESULT GetDC(HDC *phdc);
    HRESULT ReleaseDC(HDC hdc);
}

extern (C++) interface IDirect3DVolume9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    HRESULT SetPrivateData(REFGUID refguid,const(void)* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData(REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData(REFGUID refguid);
    HRESULT GetContainer(REFIID riid,void** ppContainer);
    HRESULT GetDesc(D3DVOLUME_DESC *pDesc);
    HRESULT LockBox(D3DLOCKED_BOX * pLockedVolume,const(D3DBOX)* pBox,DWORD Flags);
    HRESULT UnlockBox();
}

extern (C++) interface IDirect3DQuery9 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice9* ppDevice);
    D3DQUERYTYPE GetType();
    DWORD GetDataSize();
    HRESULT Issue(DWORD dwIssueFlags);
    HRESULT GetData(void* pData,DWORD dwSize,DWORD dwGetDataFlags);
}

extern (C++) interface IDirect3D9Ex : IDirect3D9 {
    UINT GetAdapterModeCountEx(UINT Adapter,const(D3DDISPLAYMODEFILTER)* pFilter );
    HRESULT EnumAdapterModesEx(UINT Adapter,const(D3DDISPLAYMODEFILTER)* pFilter,UINT Mode,D3DDISPLAYMODEEX* pMode);
    HRESULT GetAdapterDisplayModeEx(UINT Adapter,D3DDISPLAYMODEEX* pMode,D3DDISPLAYROTATION* pRotation);
    HRESULT CreateDeviceEx(UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,D3DDISPLAYMODEEX* pFullscreenDisplayMode,IDirect3DDevice9Ex* ppReturnedDeviceInterface);
    HRESULT GetAdapterLUID(UINT Adapter,LUID * pLUID);
}

extern (C++) interface IDirect3DDevice9Ex : IDirect3DDevice9 {
    HRESULT CreateRenderTargetEx(UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Lockable,IDirect3DSurface9* ppSurface,HANDLE* pSharedHandle,DWORD Usage);
    HRESULT CreateOffscreenPlainSurfaceEx(UINT Width,UINT Height,D3DFORMAT Format,D3DPOOL Pool,IDirect3DSurface9* ppSurface,HANDLE* pSharedHandle,DWORD Usage);
    HRESULT CreateDepthStencilSurfaceEx(UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Discard,IDirect3DSurface9* ppSurface,HANDLE* pSharedHandle,DWORD Usage);
    HRESULT ResetEx(D3DPRESENT_PARAMETERS* pPresentationParameters,D3DDISPLAYMODEEX *pFullscreenDisplayMode);
    HRESULT GetDisplayModeEx(UINT iSwapChain,D3DDISPLAYMODEEX* pMode,D3DDISPLAYROTATION* pRotation);
}

extern (C++) interface IDirect3DSwapChain9Ex : IDirect3DSwapChain9 {
    HRESULT GetLastPresentCount(UINT* pLastPresentCount);
    HRESULT GetPresentStats(D3DPRESENTSTATS* pPresentationStatistics);
    HRESULT GetDisplayModeEx(D3DDISPLAYMODEEX* pMode,D3DDISPLAYROTATION* pRotation);
}

extern (C++) interface IDirect3D9ExOverlayExtension : IUnknown {
    HRESULT CheckDeviceOverlayType(UINT Adapter,D3DDEVTYPE DevType,UINT OverlayWidth,UINT OverlayHeight,D3DFORMAT OverlayFormat,D3DDISPLAYMODEEX* pDisplayMode,D3DDISPLAYROTATION DisplayRotation,D3DOVERLAYCAPS* pOverlayCaps);
}

extern (C++) interface IDirect3DDevice9Video : IUnknown {
    HRESULT GetContentProtectionCaps(const(GUID)* pCryptoType,const(GUID)* pDecodeProfile,D3DCONTENTPROTECTIONCAPS* pCaps);
    HRESULT CreateAuthenticatedChannel(D3DAUTHENTICATEDCHANNELTYPE ChannelType,IDirect3DAuthenticatedChannel9* ppAuthenticatedChannel,HANDLE* pChannelHandle);
    HRESULT CreateCryptoSession(const(GUID)* pCryptoType,const(GUID)* pDecodeProfile,IDirect3DCryptoSession9* ppCryptoSession,HANDLE* pCryptoHandle);
}

extern (C++) interface IDirect3DAuthenticatedChannel9 : IUnknown {
    HRESULT GetCertificateSize(UINT* pCertificateSize);
    HRESULT GetCertificate(UINT CertifacteSize,BYTE* ppCertificate);
    HRESULT NegotiateKeyExchange(UINT DataSize,VOID* pData);
    HRESULT Query(UINT InputSize,const(VOID)* pInput,UINT OutputSize,VOID* pOutput);
    HRESULT Configure(UINT InputSize,const(VOID)* pInput,D3DAUTHENTICATEDCHANNEL_CONFIGURE_OUTPUT* pOutput);
}

extern (C++) interface IDirect3DCryptoSession9 : IUnknown {
    HRESULT GetCertificateSize(UINT* pCertificateSize);
    HRESULT GetCertificate(UINT CertifacteSize,BYTE* ppCertificate);
    HRESULT NegotiateKeyExchange(UINT DataSize,VOID* pData);
    HRESULT EncryptionBlt(IDirect3DSurface9 pSrcSurface,IDirect3DSurface9 pDstSurface,UINT DstSurfaceSize,VOID* pIV);
    HRESULT DecryptionBlt(IDirect3DSurface9 pSrcSurface,IDirect3DSurface9 pDstSurface,UINT SrcSurfaceSize,D3DENCRYPTED_BLOCK_INFO* pEncryptedBlockInfo,VOID* pContentKey,VOID* pIV);
    HRESULT GetSurfacePitch(IDirect3DSurface9 pSrcSurface,UINT* pSurfacePitch);
    HRESULT StartSessionKeyRefresh(VOID* pRandomNumber,UINT RandomNumberSize);
    HRESULT FinishSessionKeyRefresh();
    HRESULT GetEncryptionBltKey(VOID* pReadbackKey,UINT KeySize);
}

struct D3DOVERLAYCAPS {
    UINT   Caps;
    UINT   MaxOverlayDisplayWidth;
    UINT   MaxOverlayDisplayHeight;
}

struct D3DCONTENTPROTECTIONCAPS {
    DWORD     Caps;
    GUID      KeyExchangeType;
    UINT      BufferAlignmentStart;
    UINT      BlockAlignmentSize;
    ULONGLONG ProtectedMemorySize;
}

enum D3D_OMAC_SIZE = 16;

struct D3D_OMAC {
    BYTE[D3D_OMAC_SIZE] Omac;
}

alias D3DAUTHENTICATEDCHANNELTYPE = DWORD;
enum : D3DAUTHENTICATEDCHANNELTYPE {
    D3DAUTHENTICATEDCHANNEL_D3D9            = 1,
    D3DAUTHENTICATEDCHANNEL_DRIVER_SOFTWARE = 2,
    D3DAUTHENTICATEDCHANNEL_DRIVER_HARDWARE = 3,
}

struct D3DAUTHENTICATEDCHANNEL_CONFIGURE_OUTPUT {
    D3D_OMAC                            omac;
    GUID                                ConfigureType;
    HANDLE                              hChannel;
    UINT                                SequenceNumber;
    HRESULT                             ReturnCode;
}

struct D3DENCRYPTED_BLOCK_INFO {
    UINT NumEncryptedBytesAtBeginning;
    UINT NumBytesInSkipPattern;
    UINT NumBytesInEncryptPattern;
}

__gshared LPDIRECT3DCREATE9   Direct3DCreate9;
__gshared LPDIRECT3DCREATE9EX Direct3DCreate9Ex;

extern (Windows) {
    alias LPDIRECT3DCREATE9 = IDirect3D9 function(UINT SDKVersion);

    alias LPDIRECT3DCREATE9EX = HRESULT function(UINT SDKVersion,
                                                 IDirect3D9Ex* ppD3D);
}

enum D3D_SDK_VERSION = 32;
