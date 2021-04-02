module directx.dxgi;

version(Windows):

public import directx.com;
public import directx.dxgitype;

enum DXGI_CPU_ACCESS_NONE              = ( 0 );
enum DXGI_CPU_ACCESS_DYNAMIC           = ( 1 );
enum DXGI_CPU_ACCESS_READ_WRITE        = ( 2 );
enum DXGI_CPU_ACCESS_SCRATCH           = ( 3 );
enum DXGI_CPU_ACCESS_FIELD             = 15;
enum DXGI_USAGE_SHADER_INPUT           = ( 1L << (0 + 4) );
enum DXGI_USAGE_RENDER_TARGET_OUTPUT   = ( 1L << (1 + 4) );
enum DXGI_USAGE_BACK_BUFFER            = ( 1L << (2 + 4) );
enum DXGI_USAGE_SHARED                 = ( 1L << (3 + 4) );
enum DXGI_USAGE_READ_ONLY              = ( 1L << (4 + 4) );
enum DXGI_USAGE_DISCARD_ON_PRESENT     = ( 1L << (5 + 4) );
enum DXGI_USAGE_UNORDERED_ACCESS       = ( 1L << (6 + 4) );
alias UINT DXGI_USAGE;

struct DXGI_FRAME_STATISTICS
{
	UINT PresentCount;
	UINT PresentRefreshCount;
	UINT SyncRefreshCount;
	LARGE_INTEGER SyncQPCTime;
	LARGE_INTEGER SyncGPUTime;
}

struct DXGI_MAPPED_RECT
{
	INT Pitch;
	BYTE *pBits;
}

struct DXGI_ADAPTER_DESC
{
	WCHAR[ 128 ] Description;
	UINT VendorId;
	UINT DeviceId;
	UINT SubSysId;
	UINT Revision;
	SIZE_T DedicatedVideoMemory;
	SIZE_T DedicatedSystemMemory;
	SIZE_T SharedSystemMemory;
	LUID AdapterLuid;
}

alias HANDLE HMONITOR;

struct DXGI_OUTPUT_DESC
{
	WCHAR[32] DeviceName;
	RECT DesktopCoordinates;
	BOOL AttachedToDesktop;
	DXGI_MODE_ROTATION Rotation;
	HMONITOR Monitor;
}

struct DXGI_SHARED_RESOURCE
{
	HANDLE Handle;
}

enum DXGI_RESOURCE_PRIORITY_MINIMUM = ( 0x28000000 );
enum DXGI_RESOURCE_PRIORITY_LOW     = ( 0x50000000 );
enum DXGI_RESOURCE_PRIORITY_NORMAL  = ( 0x78000000 );
enum DXGI_RESOURCE_PRIORITY_HIGH    = ( 0xa0000000 );
enum DXGI_RESOURCE_PRIORITY_MAXIMUM = ( 0xc8000000 );

alias DXGI_RESIDENCY = int;
enum : DXGI_RESIDENCY
{
	DXGI_RESIDENCY_FULLY_RESIDENT                = 1,
	DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY     = 2,
	DXGI_RESIDENCY_EVICTED_TO_DISK               = 3
}

struct DXGI_SURFACE_DESC
{
	UINT Width;
	UINT Height;
	DXGI_FORMAT Format;
	DXGI_SAMPLE_DESC SampleDesc;
}

alias DXGI_SWAP_EFFECT = int;
enum : DXGI_SWAP_EFFECT
{
	DXGI_SWAP_EFFECT_DISCARD         = 0,
	DXGI_SWAP_EFFECT_SEQUENTIAL      = 1,
    DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = 3,
    DXGI_SWAP_EFFECT_FLIP_DISCARD    = 4
}

alias DXGI_SWAP_CHAIN_FLAG = int;
enum : DXGI_SWAP_CHAIN_FLAG
{
	DXGI_SWAP_CHAIN_FLAG_NONPREROTATED      = 1,
	DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH  = 2,
	DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE     = 4
}

struct DXGI_SWAP_CHAIN_DESC
{
	DXGI_MODE_DESC BufferDesc;
	DXGI_SAMPLE_DESC SampleDesc;
	DXGI_USAGE BufferUsage;
	UINT BufferCount;
	HWND OutputWindow;
	BOOL Windowed;
	DXGI_SWAP_EFFECT SwapEffect;
	UINT Flags;
}

mixin( uuid!(IDXGIObject, "aec22fb8-76f3-4639-9be0-28eb43a67a2e") );
extern (C++) interface IDXGIObject : IUnknown
{
	HRESULT SetPrivateData( 
				REFGUID Name,
				UINT DataSize,
				const void* pData);

	HRESULT SetPrivateDataInterface( 
				REFGUID Name,
				const(IUnknown) pUnknown);

	HRESULT GetPrivateData(
				REFGUID Name,
				UINT* pDataSize,
				void* pData);

	HRESULT GetParent( 
				REFIID riid,
				void** ppParent);
}

mixin( uuid!(IDXGIDeviceSubObject, "3d3e0379-f9de-4d58-bb6c-18d62992f1a6") );
extern (C++) interface IDXGIDeviceSubObject : IDXGIObject
{
    HRESULT GetDevice( 
				REFIID riid,
				void** ppDevice);
}
 
mixin( uuid!(IDXGIResource, "035f3ab4-482e-4e50-b41f-8a7f8bd8960b") );
extern (C++) interface IDXGIResource : IDXGIDeviceSubObject
{
	HRESULT GetSharedHandle( 
				HANDLE* pSharedHandle);

	HRESULT GetUsage( 
				DXGI_USAGE* pUsage);

	HRESULT SetEvictionPriority( 
				UINT EvictionPriority);

	HRESULT GetEvictionPriority( 
				UINT* pEvictionPriority);
}

mixin( uuid!(IDXGIKeyedMutex, "9d8e1289-d7b3-465f-8126-250e349af85d") );
extern (C++) interface IDXGIKeyedMutex : IDXGIDeviceSubObject
{
	HRESULT AcquireSync( 
				UINT64 Key,
				DWORD dwMilliseconds);

	HRESULT ReleaseSync( 
				UINT64 Key);
}

enum DXGI_MAP_READ    = ( 1UL );
enum DXGI_MAP_WRITE   = ( 2UL );
enum DXGI_MAP_DISCARD = ( 4UL );

mixin( uuid!(IDXGISurface, "cafcb56c-6ac3-4889-bf47-9e23bbd260ec") );
extern (C++) interface IDXGISurface : IDXGIDeviceSubObject
{
	HRESULT GetDesc( 
				DXGI_SURFACE_DESC* pDesc);

	HRESULT Map( 
				DXGI_MAPPED_RECT* pLockedRect,
				UINT MapFlags);

	HRESULT Unmap();
}
 
mixin( uuid!(IDXGISurface1, "4AE63092-6327-4c1b-80AE-BFE12EA32B86") );
extern (C++) interface IDXGISurface1 : IDXGISurface
{
	HRESULT GetDC( 
				BOOL Discard,
				HDC* phdc);

	HRESULT ReleaseDC( 
				RECT* pDirtyRect);
}

mixin( uuid!(IDXGIAdapter, "2411e7e1-12ac-4ccf-bd14-9798e8534dc0") );
extern (C++) interface IDXGIAdapter : IDXGIObject
{
	HRESULT EnumOutputs( 
				UINT Output,
				IDXGIOutput* ppOutput);

	HRESULT GetDesc( 
				DXGI_ADAPTER_DESC* pDesc);

	HRESULT CheckInterfaceSupport( 
				REFGUID InterfaceName,
				LARGE_INTEGER* pUMDVersion);
}

mixin( uuid!(IDXGIOutput, "ae02eedb-c735-4690-8d52-5a8dc20213aa") );
extern (C++) interface IDXGIOutput : IDXGIObject
{
	HRESULT GetDesc( 
				DXGI_OUTPUT_DESC* pDesc);

	HRESULT GetDisplayModeList( 
				DXGI_FORMAT EnumFormat,
				UINT Flags,
				UINT* pNumModes,
				DXGI_MODE_DESC* pDesc);

	HRESULT FindClosestMatchingMode( 
				const (DXGI_MODE_DESC)* pModeToMatch,
				DXGI_MODE_DESC* pClosestMatch,
				IUnknown pConcernedDevice);

	HRESULT WaitForVBlank();

	HRESULT TakeOwnership( 
				IUnknown pDevice,
				BOOL Exclusive);

	void ReleaseOwnership();

	HRESULT GetGammaControlCapabilities( 
				DXGI_GAMMA_CONTROL_CAPABILITIES* pGammaCaps);

	HRESULT SetGammaControl( 
				const(DXGI_GAMMA_CONTROL)* pArray);

	HRESULT GetGammaControl( 
				DXGI_GAMMA_CONTROL* pArray);

	HRESULT SetDisplaySurface( 
				IDXGISurface pScanoutSurface);

	HRESULT  GetDisplaySurfaceData( 
				IDXGISurface pDestination);

	HRESULT  GetFrameStatistics( 
				DXGI_FRAME_STATISTICS* pStats);
}

enum DXGI_MAX_SWAP_CHAIN_BUFFERS          = ( 16 );
enum DXGI_PRESENT_TEST                    = 0x00000001UL;
enum DXGI_PRESENT_DO_NOT_SEQUENCE         = 0x00000002UL;
enum DXGI_PRESENT_RESTART                 = 0x00000004UL;
enum DXGI_PRESENT_DO_NOT_WAIT             = 0x00000008UL;
enum DXGI_PRESENT_STEREO_PREFER_RIGHT     = 0x00000010UL;
enum DXGI_PRESENT_STEREO_TEMPORARY_MONO   = 0x00000020UL;
enum DXGI_PRESENT_RESTRICT_TO_OUTPUT      = 0x00000040UL;
enum DXGI_PRESENT_USE_DURATION            = 0x00000100UL;

mixin( uuid!(IDXGISwapChain, "310d36a0-d2e7-4c0a-aa04-6a9d23b8886a") );
extern (C++) interface IDXGISwapChain : IDXGIDeviceSubObject
{
	HRESULT Present( 
				UINT SyncInterval,
				UINT Flags);

	HRESULT GetBuffer( 
				UINT Buffer,
				REFIID riid,
				void **ppSurface);

	HRESULT SetFullscreenState( 
				BOOL Fullscreen,
				IDXGIOutput pTarget);

	HRESULT GetFullscreenState( 
				BOOL* pFullscreen,
				IDXGIOutput* ppTarget);

	HRESULT GetDesc( 
				DXGI_SWAP_CHAIN_DESC* pDesc);

	HRESULT ResizeBuffers( 
				UINT BufferCount,
				UINT Width,
				UINT Height,
				DXGI_FORMAT NewFormat,
				UINT SwapChainFlags);

	HRESULT ResizeTarget( 
				const(DXGI_MODE_DESC)* pNewTargetParameters);

	HRESULT GetContainingOutput( 
				IDXGIOutput* ppOutput);

	HRESULT GetFrameStatistics( 
				DXGI_FRAME_STATISTICS* pStats);

	HRESULT GetLastPresentCount( 
				UINT* pLastPresentCount);
}
    
enum DXGI_MWA_NO_WINDOW_CHANGES      = ( 1 << 0 );
enum DXGI_MWA_NO_ALT_ENTER           = ( 1 << 1 );
enum DXGI_MWA_NO_PRINT_SCREEN        = ( 1 << 2 );
enum DXGI_MWA_VALID                  = ( 0x7 );

mixin( uuid!(IDXGIFactory, "7b7166ec-21c7-44ae-b21a-c9ae321ae369") );
extern (C++) interface IDXGIFactory : IDXGIObject
{
	HRESULT EnumAdapters( 
				UINT Adapter,
				IDXGIAdapter* ppAdapter);

	HRESULT MakeWindowAssociation( 
				HWND WindowHandle,
				UINT Flags);

	HRESULT GetWindowAssociation( 
				HWND *pWindowHandle);

	HRESULT CreateSwapChain( 
				IUnknown pDevice,
				DXGI_SWAP_CHAIN_DESC* pDesc,
				IDXGISwapChain* ppSwapChain);

	HRESULT CreateSoftwareAdapter( 
				HMODULE Module, 
				IDXGIAdapter* ppAdapter);
}


extern(Windows) nothrow 
HRESULT CreateDXGIFactory(REFIID riid, IDXGIFactory* ppFactory);

extern(Windows) nothrow 
HRESULT CreateDXGIFactory1(REFIID riid, void** ppFactory);


alias _CreateDXGIFactory = extern(Windows) nothrow HRESULT function(REFIID riid,
                                                void** ppFactory);

alias _CreateDXGIFactory1 = extern(Windows) nothrow HRESULT function(REFIID riid,
                                                 void** ppFactory);


mixin( uuid!(IDXGIDevice, "54ec77fa-1377-44e6-8c32-88fd5f44c84c") );
extern (C++) interface IDXGIDevice : IDXGIObject
{
	HRESULT GetAdapter( 
				IDXGIAdapter* pAdapter);

	HRESULT CreateSurface( 
				const(DXGI_SURFACE_DESC)* pDesc,
				UINT NumSurfaces,
				DXGI_USAGE Usage,
				const(DXGI_SHARED_RESOURCE)* pSharedResource,
				IDXGISurface* ppSurface);

	HRESULT QueryResourceResidency( 
				const(IUnknown)* ppResources,
				DXGI_RESIDENCY* pResidencyStatus,
				UINT NumResources);

	HRESULT SetGPUThreadPriority( 
				INT Priority);

	HRESULT GetGPUThreadPriority( 
				INT* pPriority);
}

alias DXGI_ADAPTER_FLAG = int;
enum : DXGI_ADAPTER_FLAG
{
	DXGI_ADAPTER_FLAG_NONE          = 0,
	DXGI_ADAPTER_FLAG_REMOTE        = 1,
	DXGI_ADAPTER_FLAG_SOFTWARE      = 2,
	DXGI_ADAPTER_FLAG_FORCE_DWORD   = 0xffffffff
}

struct DXGI_ADAPTER_DESC1
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
}

struct DXGI_DISPLAY_COLOR_SPACE
{
	FLOAT[8 ][2] PrimaryCoordinates;
	FLOAT[16][2] WhitePoints;
}

mixin( uuid!(IDXGIFactory1, "770aae78-f26f-4dba-a829-253c83d1b387") );
extern (C++) interface IDXGIFactory1 : IDXGIFactory
{
	HRESULT EnumAdapters1( 
				UINT Adapter,
				IDXGIAdapter1* ppAdapter);

	BOOL IsCurrent();
}
   
mixin( uuid!(IDXGIAdapter1, "29038f61-3839-4626-91fd-086879011a05") );
extern (C++) interface IDXGIAdapter1 : IDXGIAdapter
{
	HRESULT GetDesc1( 
				DXGI_ADAPTER_DESC1* pDesc);
}

mixin( uuid!(IDXGIDevice1, "77db970f-6276-48ba-ba28-070143b4392c") );
extern (C++) interface IDXGIDevice1 : IDXGIDevice
{
	HRESULT SetMaximumFrameLatency( 
				UINT MaxLatency);

    HRESULT GetMaximumFrameLatency( 
				UINT *pMaxLatency);
}
