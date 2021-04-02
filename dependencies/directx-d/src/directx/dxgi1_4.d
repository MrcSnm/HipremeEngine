module directx.dxgi1_4;

version(Windows):

public import directx.dxgi1_3;

alias DWORD DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG;
enum : DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG {
    DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG_PRESENT	     = 0x1,
    DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG_OVERLAY_PRESENT = 0x2
}

mixin(uuid!(IDXGISwapChain3, "94d99bdb-f1f8-4ab0-b236-7da0170edab1"));
extern (C++) interface IDXGISwapChain3 : IDXGISwapChain2 {
    UINT GetCurrentBackBufferIndex();

    HRESULT CheckColorSpaceSupport(DXGI_COLOR_SPACE_TYPE ColorSpace,
                                   UINT* pColorSpaceSupport);

    HRESULT SetColorSpace1(DXGI_COLOR_SPACE_TYPE ColorSpace);

    HRESULT ResizeBuffers1(UINT BufferCount,
                           UINT Width,
                           UINT Height,
                           DXGI_FORMAT Format,
                           UINT SwapChainFlags,
                           const(UINT)* pCreationNodeMask,
                           const(IUnknown)* ppPresentQueue);
}

alias DWORD DXGI_OVERLAY_COLOR_SPACE_SUPPORT_FLAG;
enum : DXGI_OVERLAY_COLOR_SPACE_SUPPORT_FLAG {
    DXGI_OVERLAY_COLOR_SPACE_SUPPORT_FLAG_PRESENT = 0x1
}

mixin(uuid!(IDXGIOutput4, "dc7dca35-2196-414d-9F53-617884032a60"));
extern (C++) interface IDXGIOutput4 : IDXGIOutput3 {
    HRESULT CheckOverlayColorSpaceSupport(DXGI_FORMAT Format,
                                          DXGI_COLOR_SPACE_TYPE ColorSpace,
                                          IUnknown pConcernedDevice,
                                          UINT* pFlags);
}

mixin(uuid!(IDXGIFactory4, "1bc6ea02-ef36-464f-bf0c-21ca39e5168a"));
extern (C++) interface IDXGIFactory4 : IDXGIFactory3 {
    HRESULT EnumAdapterByLuid(LUID AdapterLuid,
                              REFIID riid,
                              IDXGIAdapter* ppvAdapter);

    HRESULT EnumWarpAdapter(REFIID riid, IDXGIAdapter* ppvAdapter);
}

alias DWORD DXGI_MEMORY_SEGMENT_GROUP;
enum : DXGI_MEMORY_SEGMENT_GROUP {
    DXGI_MEMORY_SEGMENT_GROUP_LOCAL	    = 0,
    DXGI_MEMORY_SEGMENT_GROUP_NON_LOCAL	= 1
}

struct DXGI_QUERY_VIDEO_MEMORY_INFO {
    UINT64 Budget;
    UINT64 CurrentUsage;
    UINT64 AvailableForReservation;
    UINT64 CurrentReservation;
}

mixin(uuid!(IDXGIAdapter3, "645967a4-1392-4310-a798-8053ce3e93fd"));
extern (C++) interface IDXGIAdapter3 : IDXGIAdapter2 {
    HRESULT RegisterHardwareContentProtectionTeardownStatusEvent(HANDLE hEvent,
                                                                 DWORD* pdwCookie);

    void UnregisterHardwareContentProtectionTeardownStatus(DWORD dwCookie);

    HRESULT QueryVideoMemoryInfo(UINT NodeIndex,
                                 DXGI_MEMORY_SEGMENT_GROUP MemorySegmentGroup,
                                 DXGI_QUERY_VIDEO_MEMORY_INFO* pVideoMemoryInfo);

    HRESULT SetVideoMemoryReservation(UINT NodeIndex,
                                      DXGI_MEMORY_SEGMENT_GROUP MemorySegmentGroup,
                                      UINT64 Reservation);

    HRESULT RegisterVideoMemoryBudgetChangeNotificationEvent(HANDLE hEvent,
                                                             DWORD* pdwCookie);

    void UnregisterVideoMemoryBudgetChangeNotification(DWORD dwCookie);
}
