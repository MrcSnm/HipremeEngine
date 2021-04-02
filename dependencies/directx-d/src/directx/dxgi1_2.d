module directx.dxgi1_2;

version(Windows):

public import directx.dxgi;
	
mixin( uuid!(IDXGIDisplayControl, "ea9dbf1a-c88e-4486-854a-98aa0138f30c") );
extern (C++) interface IDXGIDisplayControl : IUnknown
{
    BOOL IsStereoEnabled();

	void SetStereoEnabled( 
            BOOL enabled);
}

struct DXGI_OUTDUPL_MOVE_RECT
{
	POINT SourcePoint;
	RECT DestinationRect;
}

struct DXGI_OUTDUPL_DESC
{
	DXGI_MODE_DESC ModeDesc;
	DXGI_MODE_ROTATION Rotation;
	BOOL DesktopImageInSystemMemory;
}

struct DXGI_OUTDUPL_POINTER_POSITION
{
	POINT Position;
	BOOL Visible;
}

alias DXGI_OUTDUPL_POINTER_SHAPE_TYPE = int;
enum : DXGI_OUTDUPL_POINTER_SHAPE_TYPE
{
	DXGI_OUTDUPL_POINTER_SHAPE_TYPE_MONOCHROME	= 0x1,
	DXGI_OUTDUPL_POINTER_SHAPE_TYPE_COLOR	= 0x2,
	DXGI_OUTDUPL_POINTER_SHAPE_TYPE_MASKED_COLOR	= 0x4
}

struct DXGI_OUTDUPL_POINTER_SHAPE_INFO
{
	UINT Type;
	UINT Width;
	UINT Height;
	UINT Pitch;
	POINT HotSpot;
}

struct DXGI_OUTDUPL_FRAME_INFO
{
	LARGE_INTEGER LastPresentTime;
	LARGE_INTEGER LastMouseUpdateTime;
	UINT AccumulatedFrames;
	BOOL RectsCoalesced;
	BOOL ProtectedContentMaskedOut;
	DXGI_OUTDUPL_POINTER_POSITION PointerPosition;
	UINT TotalMetadataBufferSize;
	UINT PointerShapeBufferSize;
}

mixin( uuid!(IDXGIOutputDuplication, "191cfac3-a341-470d-b26e-a864f428319c") );
extern (C++) interface IDXGIOutputDuplication : IDXGIObject
{
	void GetDesc( 
            /*out*/ DXGI_OUTDUPL_DESC* pDesc);

	HRESULT AcquireNextFrame( 
            UINT TimeoutInMilliseconds,
            /*out*/ DXGI_OUTDUPL_FRAME_INFO* pFrameInfo,
            /*out*/IDXGIResource* ppDesktopResource);

	HRESULT GetFrameDirtyRects( 
            UINT DirtyRectsBufferSize,
            /*out*/ RECT* pDirtyRectsBuffer,
            /*out*/ UINT* pDirtyRectsBufferSizeRequired);

	HRESULT GetFrameMoveRects( 
            UINT MoveRectsBufferSize,
            /*out*/ DXGI_OUTDUPL_MOVE_RECT* pMoveRectBuffer,
            /*out*/ UINT* pMoveRectsBufferSizeRequired);

	HRESULT GetFramePointerShape( 
            UINT PointerShapeBufferSize,
            /*out*/ void* pPointerShapeBuffer,
            /*out*/ UINT* pPointerShapeBufferSizeRequired,
            /*out*/ DXGI_OUTDUPL_POINTER_SHAPE_INFO* pPointerShapeInfo);

	HRESULT MapDesktopSurface( 
            /*out*/ DXGI_MAPPED_RECT* pLockedRect);

	HRESULT UnMapDesktopSurface();

	HRESULT ReleaseFrame();
}

alias DXGI_ALPHA_MODE = int;
enum : DXGI_ALPHA_MODE
{
	DXGI_ALPHA_MODE_UNSPECIFIED	= 0,
	DXGI_ALPHA_MODE_PREMULTIPLIED	= 1,
	DXGI_ALPHA_MODE_STRAIGHT	= 2,
	DXGI_ALPHA_MODE_IGNORE	= 3,
	DXGI_ALPHA_MODE_FORCE_DWORD	= 0xffffffff
}

mixin( uuid!(IDXGISurface2, "aba496dd-b617-4cb8-a866-bc44d7eb1fa2") );
extern (C++) interface IDXGISurface2 : IDXGISurface1
{
	HRESULT GetResource( 
            REFIID riid,
            /*out*/ void** ppParentResource,
            /*out*/ UINT* pSubresourceIndex);
}

mixin( uuid!(IDXGIResource1, "30961379-4609-4a41-998e-54fe567ee0c1") );
extern (C++) interface IDXGIResource1 : IDXGIResource
{
	HRESULT CreateSubresourceSurface( 
            UINT index,
            /*out*/ IDXGISurface2* ppSurface);

	HRESULT CreateSharedHandle( 
            const(SECURITY_ATTRIBUTES)* pAttributes,
            DWORD dwAccess,
            LPCWSTR lpName,
            /*out*/ HANDLE* pHandle);
}

alias DXGI_OFFER_RESOURCE_PRIORITY = int;
enum : DXGI_OFFER_RESOURCE_PRIORITY
{
	DXGI_OFFER_RESOURCE_PRIORITY_LOW	= 1,
	DXGI_OFFER_RESOURCE_PRIORITY_NORMAL	= ( DXGI_OFFER_RESOURCE_PRIORITY_LOW + 1 ) ,
	DXGI_OFFER_RESOURCE_PRIORITY_HIGH	= ( DXGI_OFFER_RESOURCE_PRIORITY_NORMAL + 1 ) 
}

mixin( uuid!(IDXGIDevice2, "05008617-fbfd-4051-a790-144884b4f6a9") );
extern (C++) interface IDXGIDevice2 : IDXGIDevice1
{
	HRESULT OfferResources( 
            UINT NumResources,
            const(IDXGIResource)* ppResources,
            DXGI_OFFER_RESOURCE_PRIORITY Priority);

	HRESULT ReclaimResources( 
            UINT NumResources,
            const(IDXGIResource)* ppResources,
            /*out*/ BOOL* pDiscarded);

	HRESULT EnqueueSetEvent( 
            HANDLE hEvent);
}

enum DXGI_ENUM_MODES_STEREO	= ( 4UL );
enum DXGI_ENUM_MODES_DISABLED_STEREO =	( 8UL );
enum DXGI_SHARED_RESOURCE_READ = ( 0x80000000L );
enum DXGI_SHARED_RESOURCE_WRITE	= ( 1 );

struct DXGI_MODE_DESC1
{
	UINT Width;
	UINT Height;
	DXGI_RATIONAL RefreshRate;
	DXGI_FORMAT Format;
	DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
	DXGI_MODE_SCALING Scaling;
	BOOL Stereo;
}

alias DXGI_SCALING = int; 
enum : DXGI_SCALING
{
	DXGI_SCALING_STRETCH	= 0,
	DXGI_SCALING_NONE	= 1,
	DXGI_SCALING_ASPECT_RATIO_STRETCH	= 2
}

struct DXGI_SWAP_CHAIN_DESC1
{
	UINT Width;
	UINT Height;
	DXGI_FORMAT Format;
	BOOL Stereo;
	DXGI_SAMPLE_DESC SampleDesc;
	DXGI_USAGE BufferUsage;
	UINT BufferCount;
	DXGI_SCALING Scaling;
	DXGI_SWAP_EFFECT SwapEffect;
	DXGI_ALPHA_MODE AlphaMode;
	UINT Flags;
}

struct DXGI_SWAP_CHAIN_FULLSCREEN_DESC
{
	DXGI_RATIONAL RefreshRate;
	DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
	DXGI_MODE_SCALING Scaling;
	BOOL Windowed;
}

struct DXGI_PRESENT_PARAMETERS
{
	UINT DirtyRectsCount;
	RECT *pDirtyRects;
	RECT *pScrollRect;
	POINT *pScrollOffset;
}

mixin( uuid!(IDXGISwapChain1, "790a45f7-0d42-4876-983a-0a55cfe6f4aa") );
extern (C++) interface IDXGISwapChain1 : IDXGISwapChain
{
	HRESULT GetDesc1( 
            /*out*/ DXGI_SWAP_CHAIN_DESC1* pDesc);

	HRESULT GetFullscreenDesc( 
            /*out*/ DXGI_SWAP_CHAIN_FULLSCREEN_DESC* pDesc);

	HRESULT GetHwnd( 
            /*out*/ HWND* pHwnd);

	HRESULT GetCoreWindow( 
            REFIID refiid,
            /*out*/ void** ppUnk);

	HRESULT Present1( 
            UINT SyncInterval,
            UINT PresentFlags,
            const(DXGI_PRESENT_PARAMETERS)* pPresentParameters);

	BOOL IsTemporaryMonoSupported();

	HRESULT GetRestrictToOutput( 
            /*out*/ IDXGIOutput* ppRestrictToOutput);

	HRESULT SetBackgroundColor( 
            const(DXGI_RGBA)* pColor);

	HRESULT GetBackgroundColor( 
            /*out*/ DXGI_RGBA* pColor);

	HRESULT SetRotation( 
            DXGI_MODE_ROTATION Rotation);

	HRESULT GetRotation( 
            /*out*/ DXGI_MODE_ROTATION* pRotation);
}

mixin( uuid!(IDXGIFactory2, "50c83a1c-e072-4c48-87b0-3630fa36a6d0") );
extern (C++) interface IDXGIFactory2 : IDXGIFactory1
{
	BOOL IsWindowedStereoEnabled();
        
	HRESULT CreateSwapChainForHwnd( 
            IUnknown pDevice,
            HWND hWnd,
            const(DXGI_SWAP_CHAIN_DESC1)* pDesc,
            const(DXGI_SWAP_CHAIN_FULLSCREEN_DESC)* pFullscreenDesc,
            IDXGIOutput pRestrictToOutput,
            /*out*/ IDXGISwapChain1* ppSwapChain);

	HRESULT CreateSwapChainForCoreWindow( 
            IUnknown pDevice,
            IUnknown pWindow,
            const(DXGI_SWAP_CHAIN_DESC1)* pDesc,
            IDXGIOutput pRestrictToOutput,
            /*out*/ IDXGISwapChain1* ppSwapChain);
        
	HRESULT GetSharedResourceAdapterLuid( 
            HANDLE hResource,
            /*out*/ LUID* pLuid);

	HRESULT RegisterStereoStatusWindow( 
            HWND WindowHandle,
            UINT wMsg,
            /*out*/ DWORD* pdwCookie);

	HRESULT RegisterStereoStatusEvent( 
            HANDLE hEvent,
            /*out*/ DWORD* pdwCookie);

	void UnregisterStereoStatus( 
            DWORD dwCookie);

	HRESULT RegisterOcclusionStatusWindow( 
            HWND WindowHandle,
            UINT wMsg,
            DWORD* pdwCookie);

	HRESULT RegisterOcclusionStatusEvent( 
            HANDLE hEvent,
            /*out*/ DWORD* pdwCookie);

	void UnregisterOcclusionStatus( 
            DWORD dwCookie);

	HRESULT CreateSwapChainForComposition( 
            IUnknown pDevice,
            const(DXGI_SWAP_CHAIN_DESC1)* pDesc,
            IDXGIOutput pRestrictToOutput,
            /*out*/ IDXGISwapChain1* ppSwapChain);
}
    
alias DXGI_GRAPHICS_PREEMPTION_GRANULARITY = int;
enum : DXGI_GRAPHICS_PREEMPTION_GRANULARITY
{
	DXGI_GRAPHICS_PREEMPTION_DMA_BUFFER_BOUNDARY	= 0,
	DXGI_GRAPHICS_PREEMPTION_PRIMITIVE_BOUNDARY	= 1,
	DXGI_GRAPHICS_PREEMPTION_TRIANGLE_BOUNDARY	= 2,
	DXGI_GRAPHICS_PREEMPTION_PIXEL_BOUNDARY	= 3,
	DXGI_GRAPHICS_PREEMPTION_INSTRUCTION_BOUNDARY	= 4
}

alias DXGI_COMPUTE_PREEMPTION_GRANULARITY = int;
enum : DXGI_COMPUTE_PREEMPTION_GRANULARITY
{
	DXGI_COMPUTE_PREEMPTION_DMA_BUFFER_BOUNDARY	= 0,
	DXGI_COMPUTE_PREEMPTION_DISPATCH_BOUNDARY	= 1,
	DXGI_COMPUTE_PREEMPTION_THREAD_GROUP_BOUNDARY	= 2,
	DXGI_COMPUTE_PREEMPTION_THREAD_BOUNDARY	= 3,
	DXGI_COMPUTE_PREEMPTION_INSTRUCTION_BOUNDARY	= 4
}

struct DXGI_ADAPTER_DESC2
{
	WCHAR[128] Description;
	UINT VendorId;
	UINT DeviceId;
	UINT SubSysId;
	UINT Revision;
	SIZE_T DedicatedVideoMemory;
	SIZE_T DedicatedSystemMemory;
	SIZE_T SharedSystemMemory;
	LUID AdapterLuid;
	UINT Flags;
	DXGI_GRAPHICS_PREEMPTION_GRANULARITY GraphicsPreemptionGranularity;
	DXGI_COMPUTE_PREEMPTION_GRANULARITY ComputePreemptionGranularity;
}

mixin( uuid!(IDXGIAdapter2, "0AA1AE0A-FA0E-4B84-8644-E05FF8E5ACB5") );
extern (C++) interface IDXGIAdapter2 : IDXGIAdapter1
{
	HRESULT GetDesc2( 
            /*out*/ DXGI_ADAPTER_DESC2* pDesc);
}

mixin( uuid!(IDXGIOutput1, "00cddea8-939b-4b83-a340-a685226666cc") );
extern (C++) interface IDXGIOutput1 : IDXGIOutput
{
	HRESULT GetDisplayModeList1( 
            DXGI_FORMAT EnumFormat,
            UINT Flags,
            /*inout*/ UINT* pNumModes,
            /*out*/ DXGI_MODE_DESC1* pDesc);

	HRESULT FindClosestMatchingMode1( 
            const(DXGI_MODE_DESC1)* pModeToMatch,
            /*out*/ DXGI_MODE_DESC1* pClosestMatch,
            IUnknown pConcernedDevice);

	HRESULT GetDisplaySurfaceData1( 
            IDXGIResource pDestination);

	HRESULT DuplicateOutput( 
            IUnknown pDevice,
            /*out*/ IDXGIOutputDuplication* ppOutputDuplication);
}
