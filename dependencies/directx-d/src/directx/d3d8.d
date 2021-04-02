module directx.d3d8;

version(Windows):

import directx.win32;
import directx.com;
import directx.d3dcommon;

extern (C++) interface IDirect3D8 : IUnknown {
    HRESULT RegisterSoftwareDevice(void* pInitializeFunction);
    UINT GetAdapterCount();
    HRESULT GetAdapterIdentifier(UINT Adapter,DWORD Flags,D3DADAPTER_IDENTIFIER8* pIdentifier);
    UINT GetAdapterModeCount(UINT Adapter);
    HRESULT EnumAdapterModes(UINT Adapter,UINT Mode,D3DDISPLAYMODE* pMode);
    HRESULT GetAdapterDisplayMode(UINT Adapter,D3DDISPLAYMODE* pMode);
    HRESULT CheckDeviceType(UINT Adapter,D3DDEVTYPE CheckType,D3DFORMAT DisplayFormat,D3DFORMAT BackBufferFormat,BOOL Windowed);
    HRESULT CheckDeviceFormat(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,DWORD Usage,D3DRESOURCETYPE RType,D3DFORMAT CheckFormat);
    HRESULT CheckDeviceMultiSampleType(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SurfaceFormat,BOOL Windowed,D3DMULTISAMPLE_TYPE MultiSampleType);
    HRESULT CheckDepthStencilMatch(UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,D3DFORMAT RenderTargetFormat,D3DFORMAT DepthStencilFormat);
    HRESULT GetDeviceCaps(UINT Adapter,D3DDEVTYPE DeviceType,D3DCAPS8* pCaps);
    HMONITOR GetAdapterMonitor(UINT Adapter);
    HRESULT CreateDevice(UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,IDirect3DDevice8* ppReturnedDeviceInterface);
}

extern (C++) interface IDirect3DDevice8 : IUnknown {
    HRESULT TestCooperativeLevel();
    UINT GetAvailableTextureMem();
    HRESULT ResourceManagerDiscardBytes(DWORD Bytes);
    HRESULT GetDirect3D(IDirect3D8* ppD3D8);
    HRESULT GetDeviceCaps(D3DCAPS8* pCaps);
    HRESULT GetDisplayMode(D3DDISPLAYMODE* pMode);
    HRESULT GetCreationParameters(D3DDEVICE_CREATION_PARAMETERS *pParameters);
    HRESULT SetCursorProperties(UINT XHotSpot,UINT YHotSpot,IDirect3DSurface8 pCursorBitmap);
    void SetCursorPosition(int X,int Y,DWORD Flags);
    BOOL ShowCursor(BOOL bShow);
    HRESULT CreateAdditionalSwapChain(D3DPRESENT_PARAMETERS* pPresentationParameters,IDirect3DSwapChain8* pSwapChain);
    HRESULT Reset(D3DPRESENT_PARAMETERS* pPresentationParameters);
    HRESULT Present(const(RECT)* pSourceRect,const(RECT)* pDestRect,HWND hDestWindowOverride,const(RGNDATA)* pDirtyRegion);
    HRESULT GetBackBuffer(UINT BackBuffer,D3DBACKBUFFER_TYPE Type,IDirect3DSurface8* ppBackBuffer);
    HRESULT GetRasterStatus(D3DRASTER_STATUS* pRasterStatus);
    void SetGammaRamp(DWORD Flags,const(D3DGAMMARAMP)* pRamp);
    void GetGammaRamp(D3DGAMMARAMP* pRamp);
    HRESULT CreateTexture(UINT Width,UINT Height,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DTexture8* ppTexture);
    HRESULT CreateVolumeTexture(UINT Width,UINT Height,UINT Depth,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DVolumeTexture8* ppVolumeTexture);
    HRESULT CreateCubeTexture(UINT EdgeLength,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DCubeTexture8* ppCubeTexture);
    HRESULT CreateVertexBuffer(UINT Length,DWORD Usage,DWORD FVF,D3DPOOL Pool,IDirect3DVertexBuffer8* ppVertexBuffer);
    HRESULT CreateIndexBuffer(UINT Length,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DIndexBuffer8* ppIndexBuffer);
    HRESULT CreateRenderTarget(UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,BOOL Lockable,IDirect3DSurface8* ppSurface);
    HRESULT CreateDepthStencilSurface(UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,IDirect3DSurface8* ppSurface);
    HRESULT CreateImageSurface(UINT Width,UINT Height,D3DFORMAT Format,IDirect3DSurface8* ppSurface);
    HRESULT CopyRects(IDirect3DSurface8 pSourceSurface,const(RECT)* pSourceRectsArray,UINT cRects,IDirect3DSurface8 pDestinationSurface,const(POINT)* pDestPointsArray);
    HRESULT UpdateTexture(IDirect3DBaseTexture8 pSourceTexture,IDirect3DBaseTexture8 pDestinationTexture);
    HRESULT GetFrontBuffer(IDirect3DSurface8 pDestSurface);
    HRESULT SetRenderTarget(IDirect3DSurface8 pRenderTarget,IDirect3DSurface8 pNewZStencil);
    HRESULT GetRenderTarget(IDirect3DSurface8* ppRenderTarget);
    HRESULT GetDepthStencilSurface(IDirect3DSurface8* ppZStencilSurface);
    HRESULT BeginScene();
    HRESULT EndScene();
    HRESULT Clear(DWORD Count,const(D3DRECT)* pRects,DWORD Flags,D3DCOLOR Color,float Z,DWORD Stencil);
    HRESULT SetTransform(D3DTRANSFORMSTATETYPE State,const(D3DMATRIX)* pMatrix);
    HRESULT GetTransform(D3DTRANSFORMSTATETYPE State,D3DMATRIX* pMatrix);
    HRESULT MultiplyTransform(D3DTRANSFORMSTATETYPE,const(D3DMATRIX)*);
    HRESULT SetViewport(const(D3DVIEWPORT8)* pViewport);
    HRESULT GetViewport(D3DVIEWPORT8* pViewport);
    HRESULT SetMaterial(const(D3DMATERIAL8)* pMaterial);
    HRESULT GetMaterial(D3DMATERIAL8* pMaterial);
    HRESULT SetLight(DWORD Index,const(D3DLIGHT8)*);
    HRESULT GetLight(DWORD Index,D3DLIGHT8*);
    HRESULT LightEnable(DWORD Index,BOOL Enable);
    HRESULT GetLightEnable(DWORD Index,BOOL* pEnable);
    HRESULT SetClipPlane(DWORD Index,const(float)* pPlane);
    HRESULT GetClipPlane(DWORD Index,float* pPlane);
    HRESULT SetRenderState(D3DRENDERSTATETYPE State,DWORD Value);
    HRESULT GetRenderState(D3DRENDERSTATETYPE State,DWORD* pValue);
    HRESULT BeginStateBlock();
    HRESULT EndStateBlock(DWORD* pToken);
    HRESULT ApplyStateBlock(DWORD Token);
    HRESULT CaptureStateBlock(DWORD Token);
    HRESULT DeleteStateBlock(DWORD Token);
    HRESULT CreateStateBlock(D3DSTATEBLOCKTYPE Type,DWORD* pToken);
    HRESULT SetClipStatus(const(D3DCLIPSTATUS8)* pClipStatus);
    HRESULT GetClipStatus(D3DCLIPSTATUS8* pClipStatus);
    HRESULT GetTexture(DWORD Stage,IDirect3DBaseTexture8* ppTexture);
    HRESULT SetTexture(DWORD Stage,IDirect3DBaseTexture8 pTexture);
    HRESULT GetTextureStageState(DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD* pValue);
    HRESULT SetTextureStageState(DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD Value);
    HRESULT ValidateDevice(DWORD* pNumPasses);
    HRESULT GetInfo(DWORD DevInfoID,void* pDevInfoStruct,DWORD DevInfoStructSize);
    HRESULT SetPaletteEntries(UINT PaletteNumber,const(PALETTEENTRY)* pEntries);
    HRESULT GetPaletteEntries(UINT PaletteNumber,PALETTEENTRY* pEntries);
    HRESULT SetCurrentTexturePalette(UINT PaletteNumber);
    HRESULT GetCurrentTexturePalette(UINT *PaletteNumber);
    HRESULT DrawPrimitive(D3DPRIMITIVETYPE PrimitiveType,UINT StartVertex,UINT PrimitiveCount);
    HRESULT DrawIndexedPrimitive(D3DPRIMITIVETYPE,UINT minIndex,UINT NumVertices,UINT startIndex,UINT primCount);
    HRESULT DrawPrimitiveUP(D3DPRIMITIVETYPE PrimitiveType,UINT PrimitiveCount,const(void)* pVertexStreamZeroData,UINT VertexStreamZeroStride);
    HRESULT DrawIndexedPrimitiveUP(D3DPRIMITIVETYPE PrimitiveType,UINT MinVertexIndex,UINT NumVertexIndices,UINT PrimitiveCount,const(void)* pIndexData,D3DFORMAT IndexDataFormat,const(void)* pVertexStreamZeroData,UINT VertexStreamZeroStride);
    HRESULT ProcessVertices(UINT SrcStartIndex,UINT DestIndex,UINT VertexCount,IDirect3DVertexBuffer8 pDestBuffer,DWORD Flags);
    HRESULT CreateVertexShader(const(DWORD)* pDeclaration,const(DWORD)* pFunction,DWORD* pHandle,DWORD Usage);
    HRESULT SetVertexShader(DWORD Handle);
    HRESULT GetVertexShader(DWORD* pHandle);
    HRESULT DeleteVertexShader(DWORD Handle);
    HRESULT SetVertexShaderConstant(DWORD Register,const(void)* pConstantData,DWORD ConstantCount);
    HRESULT GetVertexShaderConstant(DWORD Register,void* pConstantData,DWORD ConstantCount);
    HRESULT GetVertexShaderDeclaration(DWORD Handle,void* pData,DWORD* pSizeOfData);
    HRESULT GetVertexShaderFunction(DWORD Handle,void* pData,DWORD* pSizeOfData);
    HRESULT SetStreamSource(UINT StreamNumber,IDirect3DVertexBuffer8 pStreamData,UINT Stride);
    HRESULT GetStreamSource(UINT StreamNumber,IDirect3DVertexBuffer8* ppStreamData,UINT* pStride);
    HRESULT SetIndices(IDirect3DIndexBuffer8 pIndexData,UINT BaseVertexIndex);
    HRESULT GetIndices(IDirect3DIndexBuffer8* ppIndexData,UINT* pBaseVertexIndex);
    HRESULT CreatePixelShader(const(DWORD)* pFunction,DWORD* pHandle);
    HRESULT SetPixelShader(DWORD Handle);
    HRESULT GetPixelShader(DWORD* pHandle);
    HRESULT DeletePixelShader(DWORD Handle);
    HRESULT SetPixelShaderConstant(DWORD Register,const(void)* pConstantData,DWORD ConstantCount);
    HRESULT GetPixelShaderConstant(DWORD Register,void* pConstantData,DWORD ConstantCount);
    HRESULT GetPixelShaderFunction(DWORD Handle,void* pData,DWORD* pSizeOfData);
    HRESULT DrawRectPatch(UINT Handle,const(float)* pNumSegs,const(D3DRECTPATCH_INFO)* pRectPatchInfo);
    HRESULT DrawTriPatch(UINT Handle,const(float)* pNumSegs,const(D3DTRIPATCH_INFO)* pTriPatchInfo);
    HRESULT DeletePatch(UINT Handle);
}

extern (C++) interface IDirect3DSwapChain8 : IUnknown {
    HRESULT Present(const(RECT)* pSourceRect,const(RECT)* pDestRect,HWND hDestWindowOverride,const(RGNDATA)* pDirtyRegion);
    HRESULT GetBackBuffer(UINT BackBuffer,D3DBACKBUFFER_TYPE Type,IDirect3DSurface8* ppBackBuffer);
}

extern (C++) interface IDirect3DResource8 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice8* ppDevice);
    HRESULT SetPrivateData(REFGUID refguid,const(void)* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData(REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData(REFGUID refguid);
    DWORD SetPriority(DWORD PriorityNew);
    DWORD GetPriority();
    void PreLoad();
    D3DRESOURCETYPE GetType();
}

extern (C++) interface IDirect3DBaseTexture8 : IDirect3DResource8 {
    DWORD SetLOD(DWORD LODNew);
    DWORD GetLOD();
    DWORD GetLevelCount();
}

extern (C++) interface IDirect3DTexture8 : IDirect3DBaseTexture8 {
    HRESULT GetLevelDesc(UINT Level,D3DSURFACE_DESC *pDesc);
    HRESULT GetSurfaceLevel(UINT Level,IDirect3DSurface8* ppSurfaceLevel);
    HRESULT LockRect(UINT Level,D3DLOCKED_RECT* pLockedRect,const(RECT)* pRect,DWORD Flags);
    HRESULT UnlockRect(UINT Level);
    HRESULT AddDirtyRect(const(RECT)* pDirtyRect);
}

extern (C++) interface IDirect3DVolumeTexture8 : IDirect3DBaseTexture8 {
    HRESULT GetLevelDesc(UINT Level,D3DVOLUME_DESC *pDesc);
    HRESULT GetVolumeLevel(UINT Level,IDirect3DVolume8* ppVolumeLevel);
    HRESULT LockBox(UINT Level,D3DLOCKED_BOX* pLockedVolume,const(D3DBOX)* pBox,DWORD Flags);
    HRESULT UnlockBox(UINT Level);
    HRESULT AddDirtyBox(const(D3DBOX)* pDirtyBox);
}

extern (C++) interface IDirect3DCubeTexture8 : IDirect3DBaseTexture8 {
    HRESULT GetLevelDesc(UINT Level,D3DSURFACE_DESC *pDesc);
    HRESULT GetCubeMapSurface(D3DCUBEMAP_FACES FaceType,UINT Level,IDirect3DSurface8* ppCubeMapSurface);
    HRESULT LockRect(D3DCUBEMAP_FACES FaceType,UINT Level,D3DLOCKED_RECT* pLockedRect,const(RECT)* pRect,DWORD Flags);
    HRESULT UnlockRect(D3DCUBEMAP_FACES FaceType,UINT Level);
    HRESULT AddDirtyRect(D3DCUBEMAP_FACES FaceType,const(RECT)* pDirtyRect);
}

extern (C++) interface IDirect3DVertexBuffer8 : IDirect3DResource8 {}
extern (C++) interface IDirect3DIndexBuffer8  : IDirect3DResource8 {}

extern (C++) interface IDirect3DSurface8 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice8* ppDevice);
    HRESULT SetPrivateData(REFGUID refguid,const(void)* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData(REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData(REFGUID refguid);
    HRESULT GetContainer(REFIID riid,void** ppContainer);
    HRESULT GetDesc(D3DSURFACE_DESC *pDesc);
    HRESULT LockRect(D3DLOCKED_RECT* pLockedRect,const(RECT)* pRect,DWORD Flags);
    HRESULT UnlockRect();
}

extern (C++) interface IDirect3DVolume8 : IUnknown {
    HRESULT GetDevice(IDirect3DDevice8* ppDevice);
    HRESULT SetPrivateData(REFGUID refguid,const(void)* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData(REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData(REFGUID refguid);
    HRESULT GetContainer(REFIID riid,void** ppContainer);
    HRESULT GetDesc(D3DVOLUME_DESC *pDesc);
    HRESULT LockBox(D3DLOCKED_BOX * pLockedVolume,const(D3DBOX)* pBox,DWORD Flags);
    HRESULT UnlockBox();
}

struct D3DVIEWPORT8 {
    DWORD       X;
    DWORD       Y;            /* Viewport Top left */
    DWORD       Width;
    DWORD       Height;       /* Viewport Dimensions */
    float       MinZ;         /* Min/max of clip Volume */
    float       MaxZ;
}

struct D3DCLIPSTATUS8 {
    DWORD ClipUnion;
    DWORD ClipIntersection;
}

struct D3DMATERIAL8 {
    D3DCOLORVALUE   Diffuse;        /* Diffuse color RGBA */
    D3DCOLORVALUE   Ambient;        /* Ambient color RGB */
    D3DCOLORVALUE   Specular;       /* Specular 'shininess' */
    D3DCOLORVALUE   Emissive;       /* Emissive color RGB */
    float           Power;          /* Sharpness if specular highlight */
}

struct D3DLIGHT8 {
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

__gshared LPDIRECT3DCREATE8 Direct3DCreate8;

extern (Windows) {
    alias LPDIRECT3DCREATE8 = IDirect3D8 function(UINT SDKVersion);
}

enum D3D_SDK_VERSION = 220;
