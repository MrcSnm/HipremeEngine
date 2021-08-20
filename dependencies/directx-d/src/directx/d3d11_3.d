module directx.d3d11_3;
/*-------------------------------------------------------------------------------------
*
* Copyright (c) Microsoft Corporation
*
*-------------------------------------------------------------------------------------*/

version(Windows):

public import directx.dxgi1_3;
public import directx.d3d11_2;

alias DWORD D3D11_CONTEXT_TYPE;
enum : D3D11_CONTEXT_TYPE
{
    D3D11_CONTEXT_TYPE_ALL      = 0,
    D3D11_CONTEXT_TYPE_3D       = 1,
    D3D11_CONTEXT_TYPE_COMPUTE  = 2,
    D3D11_CONTEXT_TYPE_COPY     = 3,
    D3D11_CONTEXT_TYPE_VIDEO    = 4
}

alias DWORD D3D11_TEXTURE_LAYOUT;
enum : D3D11_TEXTURE_LAYOUT
{
    D3D11_TEXTURE_LAYOUT_UNDEFINED      = 0,
    D3D11_TEXTURE_LAYOUT_ROW_MAJOR      = 1,
    D3D11_TEXTURE_LAYOUT_64K_STANDARD_SWIZZLE   = 2
}

struct D3D11_TEXTURE2D_DESC1
{
    UINT Width;
    UINT Height;
    UINT MipLevels;
    UINT ArraySize;
    DXGI_FORMAT Format;
    DXGI_SAMPLE_DESC SampleDesc;
    D3D11_USAGE Usage;
    UINT BindFlags;
    UINT CPUAccessFlags;
    UINT MiscFlags;
    D3D11_TEXTURE_LAYOUT TextureLayout;
}

mixin(uuid!(ID3D11Texture2D1, "51218251-1E33-4617-9CCB-4D3A4367E7BB"));
extern (C++) interface ID3D11Texture2D1 : ID3D11Texture2D {
    void GetDesc1(D3D11_TEXTURE2D_DESC1* pDesc);
}

struct D3D11_TEXTURE3D_DESC1
{
    UINT Width;
    UINT Height;
    UINT Depth;
    UINT MipLevels;
    DXGI_FORMAT Format;
    D3D11_USAGE Usage;
    UINT BindFlags;
    UINT CPUAccessFlags;
    UINT MiscFlags;
    D3D11_TEXTURE_LAYOUT TextureLayout;
}

mixin(uuid!(ID3D11Texture3D1, "0C711683-2853-4846-9BB0-F3E60639E46A"));
extern (C++) interface ID3D11Texture3D1 : ID3D11Texture3D {
    void GetDesc1(D3D11_TEXTURE3D_DESC1* pDesc);

}

alias DWORD D3D11_CONSERVATIVE_RASTERIZATION_MODE;
enum : D3D11_CONSERVATIVE_RASTERIZATION_MODE
{
    D3D11_CONSERVATIVE_RASTERIZATION_MODE_OFF   = 0,
    D3D11_CONSERVATIVE_RASTERIZATION_MODE_ON    = 1
}

struct D3D11_RASTERIZER_DESC2
{
    D3D11_FILL_MODE FillMode;
    D3D11_CULL_MODE CullMode;
    BOOL FrontCounterClockwise;
    INT DepthBias;
    FLOAT DepthBiasClamp;
    FLOAT SlopeScaledDepthBias;
    BOOL DepthClipEnable;
    BOOL ScissorEnable;
    BOOL MultisampleEnable;
    BOOL AntialiasedLineEnable;
    UINT ForcedSampleCount;
    D3D11_CONSERVATIVE_RASTERIZATION_MODE ConservativeRaster;
}

mixin(uuid!(ID3D11RasterizerState2, "6fbd02fb-209f-46c4-b059-2ed15586a6ac"));
extern (C++) interface ID3D11RasterizerState2 : ID3D11RasterizerState1 {
    void GetDesc2(D3D11_RASTERIZER_DESC2* pDesc);
}

struct D3D11_TEX2D_SRV1
{
    UINT MostDetailedMip;
    UINT MipLevels;
    UINT PlaneSlice;
}

struct D3D11_TEX2D_ARRAY_SRV1
{
    UINT MostDetailedMip;
    UINT MipLevels;
    UINT FirstArraySlice;
    UINT ArraySize;
    UINT PlaneSlice;
}

struct D3D11_SHADER_RESOURCE_VIEW_DESC1
{
    DXGI_FORMAT Format;
    D3D11_SRV_DIMENSION ViewDimension;
    union
    {
        D3D11_BUFFER_SRV Buffer;
        D3D11_TEX1D_SRV Texture1D;
        D3D11_TEX1D_ARRAY_SRV Texture1DArray;
        D3D11_TEX2D_SRV1 Texture2D;
        D3D11_TEX2D_ARRAY_SRV1 Texture2DArray;
        D3D11_TEX2DMS_SRV Texture2DMS;
        D3D11_TEX2DMS_ARRAY_SRV Texture2DMSArray;
        D3D11_TEX3D_SRV Texture3D;
        D3D11_TEXCUBE_SRV TextureCube;
        D3D11_TEXCUBE_ARRAY_SRV TextureCubeArray;
        D3D11_BUFFEREX_SRV BufferEx;
    }
}

mixin(uuid!(ID3D11ShaderResourceView1, "91308b87-9040-411d-8c67-c39253ce3802"));
extern (C++) interface ID3D11ShaderResourceView1 : ID3D11ShaderResourceView {
    void GetDesc1(D3D11_SHADER_RESOURCE_VIEW_DESC1* pDesc1);
}

struct D3D11_TEX2D_RTV1
{
    UINT MipSlice;
    UINT PlaneSlice;
}

struct D3D11_TEX2D_ARRAY_RTV1
{
    UINT MipSlice;
    UINT FirstArraySlice;
    UINT ArraySize;
    UINT PlaneSlice;
}

struct D3D11_RENDER_TARGET_VIEW_DESC1
{
    DXGI_FORMAT Format;
    D3D11_RTV_DIMENSION ViewDimension;
    union
    {
        D3D11_BUFFER_RTV Buffer;
        D3D11_TEX1D_RTV Texture1D;
        D3D11_TEX1D_ARRAY_RTV Texture1DArray;
        D3D11_TEX2D_RTV1 Texture2D;
        D3D11_TEX2D_ARRAY_RTV1 Texture2DArray;
        D3D11_TEX2DMS_RTV Texture2DMS;
        D3D11_TEX2DMS_ARRAY_RTV Texture2DMSArray;
        D3D11_TEX3D_RTV Texture3D;
    }
}

mixin(uuid!(ID3D11RenderTargetView1, "ffbe2e23-f011-418a-ac56-5ceed7c5b94b"));
extern (C++) interface ID3D11RenderTargetView1 : ID3D11RenderTargetView {
    void GetDesc1(D3D11_RENDER_TARGET_VIEW_DESC1* pDesc1);
}

struct D3D11_TEX2D_UAV1
{
    UINT MipSlice;
    UINT PlaneSlice;
}

struct D3D11_TEX2D_ARRAY_UAV1
{
    UINT MipSlice;
    UINT FirstArraySlice;
    UINT ArraySize;
    UINT PlaneSlice;
}

struct D3D11_UNORDERED_ACCESS_VIEW_DESC1
{
    DXGI_FORMAT Format;
    D3D11_UAV_DIMENSION ViewDimension;
    union
    {
        D3D11_BUFFER_UAV Buffer;
        D3D11_TEX1D_UAV Texture1D;
        D3D11_TEX1D_ARRAY_UAV Texture1DArray;
        D3D11_TEX2D_UAV1 Texture2D;
        D3D11_TEX2D_ARRAY_UAV1 Texture2DArray;
        D3D11_TEX3D_UAV Texture3D;
    }
}

mixin(uuid!(ID3D11UnorderedAccessView1, "7b3b6153-a886-4544-ab37-6537c8500403"));
extern (C++) interface ID3D11UnorderedAccessView1 : ID3D11UnorderedAccessView {
    void GetDesc1(D3D11_UNORDERED_ACCESS_VIEW_DESC1* pDesc1);
}

struct D3D11_QUERY_DESC1
{
    D3D11_QUERY Query;
    UINT MiscFlags;
    D3D11_CONTEXT_TYPE ContextType;
}

mixin(uuid!(ID3D11Query1, "631b4766-36dc-461d-8db6-c47e13e60916"));
extern (C++) interface ID3D11Query1 : ID3D11Query {
    void GetDesc1(D3D11_QUERY_DESC1* pDesc1);

}

mixin(uuid!(ID3D11DeviceContext3, "b4e3c01d-e79e-4637-91b2-510e9f4c9b8f"));
extern (C++) interface ID3D11DeviceContext3 : ID3D11DeviceContext2 {
    void Flush1(D3D11_CONTEXT_TYPE ContextType, HANDLE hEvent);
    void SetHardwareProtectionState(BOOL HwProtectionEnable);
    void GetHardwareProtectionState(BOOL* pHwProtectionEnable);
}

mixin(uuid!(ID3D11Device3, "A05C8C37-D2C6-4732-B3A0-9CE0B0DC9AE6"));
extern (C++) interface ID3D11Device3 : ID3D11Device2 {
    HRESULT CreateTexture2D1(
        const(D3D11_TEXTURE2D_DESC1)* pDesc1,
        const(D3D11_SUBRESOURCE_DATA)* pInitialData,
        ID3D11Texture2D1* ppTexture2D);

    HRESULT CreateTexture3D1(
        const(D3D11_TEXTURE3D_DESC1)* pDesc1,
        const(D3D11_SUBRESOURCE_DATA)* pInitialData,
        ID3D11Texture3D1* ppTexture3D);

    HRESULT CreateRasterizerState2(
        const(D3D11_RASTERIZER_DESC2)* pRasterizerDesc,
        ID3D11RasterizerState2* ppRasterizerState);

    HRESULT CreateShaderResourceView1(
        ID3D11Resource pResource,
        const(D3D11_SHADER_RESOURCE_VIEW_DESC1)* pDesc1,
        ID3D11ShaderResourceView1* ppSRView1);

    HRESULT CreateUnorderedAccessView1(
        ID3D11Resource pResource,
        const(D3D11_UNORDERED_ACCESS_VIEW_DESC1)* pDesc1,
        ID3D11UnorderedAccessView1* ppUAView1);

    HRESULT CreateRenderTargetView1(
        ID3D11Resource* pResource,
        const(D3D11_RENDER_TARGET_VIEW_DESC1)* pDesc1,
        ID3D11RenderTargetView1* ppRTView1);

    HRESULT CreateQuery1(
        const(D3D11_QUERY_DESC1)* pQueryDesc1,
        ID3D11Query1* ppQuery1);

    void GetImmediateContext3(
        ID3D11DeviceContext3* ppImmediateContext);

    HRESULT CreateDeferredContext3(
        UINT ContextFlags,
        ID3D11DeviceContext3* ppDeferredContext);

    void WriteToSubresource(
        ID3D11Resource pDstResource,
        UINT DstSubresource,
        const(D3D11_BOX)* pDstBox,
        const(void)* pSrcData,
        UINT SrcRowPitch,
        UINT SrcDepthPitch);

    void ReadFromSubresource(
        void* pDstData,
        UINT DstRowPitch,
        UINT DstDepthPitch,
        ID3D11Resource pSrcResource,
        UINT SrcSubresource,
        const(D3D11_BOX)* pSrcBox);
}
