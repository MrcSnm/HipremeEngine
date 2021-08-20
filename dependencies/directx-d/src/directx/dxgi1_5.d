module directx.dxgi1_5;

version(Windows):

public import directx.dxgi1_4;

mixin(uuid!(IDXGIOutput5, "80a07424-ab52-42eb-833c-0c42fd282d98"));
extern (C++) interface IDXGIOutput5 : IDXGIOutput4 {
    HRESULT DuplicateOutput1( 
        IUnknown pDevice,
        UINT Flags,
        UINT SupportedFormatsCount,
        const(DXGI_FORMAT)* pSupportedFormats,
        IDXGIOutputDuplication* ppOutputDuplication);
}
