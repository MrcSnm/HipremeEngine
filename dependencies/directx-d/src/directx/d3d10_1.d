module directx.d3d10_1;
/*-------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation
 *
 *-------------------------------------------------------------------------------------*/

version(Windows):

public import directx.d3d10;
public import directx.d3d10misc;
public import directx.d3d10_1shader;

enum D3D10_1_DEFAULT_SAMPLE_MASK    = ( 0xffffffff );
enum D3D10_1_FLOAT16_FUSED_TOLERANCE_IN_ULP = ( 0.6 );
enum D3D10_1_FLOAT32_TO_INTEGER_TOLERANCE_IN_ULP    = ( 0.6f );
enum D3D10_1_GS_INPUT_REGISTER_COUNT= ( 32 );
enum D3D10_1_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT    = ( 32 );
enum D3D10_1_IA_VERTEX_INPUT_STRUCTURE_ELEMENTS_COMPONENTS  = ( 128 );
enum D3D10_1_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT= ( 32 );
enum D3D10_1_PS_OUTPUT_MASK_REGISTER_COMPONENTS     = ( 1 );
enum D3D10_1_PS_OUTPUT_MASK_REGISTER_COMPONENT_BIT_COUNT    = ( 32 );
enum D3D10_1_PS_OUTPUT_MASK_REGISTER_COUNT  = ( 1 );
enum D3D10_1_SHADER_MAJOR_VERSION   = ( 4 );
enum D3D10_1_SHADER_MINOR_VERSION   = ( 1 );
enum D3D10_1_SO_BUFFER_MAX_STRIDE_IN_BYTES  = ( 2048 );
enum D3D10_1_SO_BUFFER_MAX_WRITE_WINDOW_IN_BYTES    = ( 256 );
enum D3D10_1_SO_BUFFER_SLOT_COUNT   = ( 4 );
enum D3D10_1_SO_MULTIPLE_BUFFER_ELEMENTS_PER_BUFFER = ( 1 );
enum D3D10_1_SO_SINGLE_BUFFER_COMPONENT_LIMIT       = ( 64 );
enum D3D10_1_STANDARD_VERTEX_ELEMENT_COUNT  = ( 32 );
enum D3D10_1_SUBPIXEL_FRACTIONAL_BIT_COUNT  = ( 8 );
enum D3D10_1_VS_INPUT_REGISTER_COUNT= ( 32 );
enum D3D10_1_VS_OUTPUT_REGISTER_COUNT       = ( 32 );

alias DWORD D3D10_FEATURE_LEVEL1;
enum : D3D10_FEATURE_LEVEL1
{
    D3D10_FEATURE_LEVEL_10_0    = 0xa000,
    D3D10_FEATURE_LEVEL_10_1    = 0xa100,
    D3D10_FEATURE_LEVEL_9_1     = 0x9100,
    D3D10_FEATURE_LEVEL_9_2     = 0x9200,
    D3D10_FEATURE_LEVEL_9_3     = 0x9300
}

struct D3D10_RENDER_TARGET_BLEND_DESC1
{
    BOOL BlendEnable;
    D3D10_BLEND SrcBlend;
    D3D10_BLEND DestBlend;
    D3D10_BLEND_OP BlendOp;
    D3D10_BLEND SrcBlendAlpha;
    D3D10_BLEND DestBlendAlpha;
    D3D10_BLEND_OP BlendOpAlpha;
    UINT8 RenderTargetWriteMask;
}

struct D3D10_BLEND_DESC1
{
    BOOL AlphaToCoverageEnable;
    BOOL IndependentBlendEnable;
    D3D10_RENDER_TARGET_BLEND_DESC1[8] RenderTarget;
}

mixin(uuid!(ID3D10BlendState1, "EDAD8D99-8A35-4d6d-8566-2EA276CDE161"));
extern (C++) interface ID3D10BlendState1 : ID3D10BlendState {
    void GetDesc1(D3D10_BLEND_DESC1* pDesc);

}

struct D3D10_TEXCUBE_ARRAY_SRV1
{
    UINT MostDetailedMip;
    UINT MipLevels;
    UINT First2DArrayFace;
    UINT NumCubes;
}

alias D3D_SRV_DIMENSION D3D10_SRV_DIMENSION1;

struct D3D10_SHADER_RESOURCE_VIEW_DESC1
{
    DXGI_FORMAT Format;
    D3D10_SRV_DIMENSION1 ViewDimension;
    union
    {
        D3D10_BUFFER_SRV Buffer;
        D3D10_TEX1D_SRV Texture1D;
        D3D10_TEX1D_ARRAY_SRV Texture1DArray;
        D3D10_TEX2D_SRV Texture2D;
        D3D10_TEX2D_ARRAY_SRV Texture2DArray;
        D3D10_TEX2DMS_SRV Texture2DMS;
        D3D10_TEX2DMS_ARRAY_SRV Texture2DMSArray;
        D3D10_TEX3D_SRV Texture3D;
        D3D10_TEXCUBE_SRV TextureCube;
        D3D10_TEXCUBE_ARRAY_SRV1 TextureCubeArray;
    }
}

mixin(uuid!(ID3D10ShaderResourceView1, "9B7E4C87-342C-4106-A19F-4F2704F689F0"));
extern (C++) interface ID3D10ShaderResourceView1 : ID3D10ShaderResourceView {
    void GetDesc1(D3D10_SHADER_RESOURCE_VIEW_DESC1* pDesc);
}

enum D3D10_STANDARD_MULTISAMPLE_QUALITY_LEVELS
{
    D3D10_STANDARD_MULTISAMPLE_PATTERN  = 0xffffffff,
    D3D10_CENTER_MULTISAMPLE_PATTERN    = 0xfffffffe
}

mixin(uuid!(ID3D10Device1, "9B7E4C8F-342C-4106-A19F-4F2704F689F0"));
extern (C++) interface ID3D10Device1 : ID3D10Device {
    HRESULT CreateShaderResourceView1(
        ID3D10Resource pResource,
        const(D3D10_SHADER_RESOURCE_VIEW_DESC1)* pDesc,
        ID3D10ShaderResourceView1* ppSRView);

    HRESULT CreateBlendState1(
        const(D3D10_BLEND_DESC1)* pBlendStateDesc,
        ID3D10BlendState1* ppBlendState);

    D3D10_FEATURE_LEVEL1 GetFeatureLevel();
}

enum D3D10_1_SDK_VERSION = 0x20;

///////////////////////////////////////////////////////////////////////////
// D3D10CreateDevice1
// ------------------
//
// pAdapter
//      If NULL, D3D10CreateDevice1 will choose the primary adapter and
//      create a new instance from a temporarily created IDXGIFactory.
//      If non-NULL, D3D10CreateDevice1 will register the appropriate
//      device, if necessary (via IDXGIAdapter::RegisterDrver), before
//      creating the device.
// DriverType
//      Specifies the driver type to be created: hardware, reference or
//      null.
// Software
//      HMODULE of a DLL implementing a software rasterizer. Must be NULL for
//      non-Software driver types.
// Flags
//      Any of those documented for D3D10CreateDeviceAndSwapChain1.
// HardwareLevel
//      Any of those documented for D3D10CreateDeviceAndSwapChain1.
// SDKVersion
//      SDK version. Use the D3D10_1_SDK_VERSION macro.
// ppDevice
//      Pointer to returned interface.
//
// Return Values
//  Any of those documented for
//          CreateDXGIFactory
//          IDXGIFactory::EnumAdapters
//          IDXGIAdapter::RegisterDriver
//          D3D10CreateDevice1
//
///////////////////////////////////////////////////////////////////////////

__gshared PFN_D3D10_CREATE_DEVICE1 D3D10CreateDevice1;

extern (Windows) {
    alias PFN_D3D10_CREATE_DEVICE1 = HRESULT function(
        IDXGIAdapter         pAdapter,
        D3D10_DRIVER_TYPE    DriverType,
        HMODULE              Software,
        UINT                 Flags,
        D3D10_FEATURE_LEVEL1 HardwareLevel,
        UINT                 SDKVersion,
        ID3D10Device1        *ppDevice);
}

///////////////////////////////////////////////////////////////////////////
// D3D10CreateDeviceAndSwapChain1
// ------------------------------
//
// ppAdapter
//      If NULL, D3D10CreateDevice1 will choose the primary adapter and
//      create a new instance from a temporarily created IDXGIFactory.
//      If non-NULL, D3D10CreateDevice1 will register the appropriate
//      device, if necessary (via IDXGIAdapter::RegisterDrver), before
//      creating the device.
// DriverType
//      Specifies the driver type to be created: hardware, reference or
//      null.
// Software
//      HMODULE of a DLL implementing a software rasterizer. Must be NULL for
//      non-Software driver types.
// Flags
//      Any of those documented for D3D10CreateDevice1.
// HardwareLevel
//      Any of:
//          D3D10_CREATE_LEVEL_10_0
//          D3D10_CREATE_LEVEL_10_1
// SDKVersion
//      SDK version. Use the D3D10_1_SDK_VERSION macro.
// pSwapChainDesc
//      Swap chain description, may be NULL.
// ppSwapChain
//      Pointer to returned interface. May be NULL.
// ppDevice
//      Pointer to returned interface.
//
// Return Values
//  Any of those documented for
//          CreateDXGIFactory
//          IDXGIFactory::EnumAdapters
//          IDXGIAdapter::RegisterDriver
//          D3D10CreateDevice1
//          IDXGIFactory::CreateSwapChain
//
///////////////////////////////////////////////////////////////////////////

__gshared PFN_D3D10_CREATE_DEVICE_AND_SWAP_CHAIN1 D3D10CreateDeviceAndSwapChain1;

extern (Windows) {
    alias PFN_D3D10_CREATE_DEVICE_AND_SWAP_CHAIN1 = HRESULT function(
            IDXGIAdapter pAdapter,
            D3D10_DRIVER_TYPE DriverType,
            HMODULE Software,
            UINT Flags,
            D3D10_FEATURE_LEVEL1 HardwareLevel,
            UINT SDKVersion,
            DXGI_SWAP_CHAIN_DESC* pSwapChainDesc,
            IDXGISwapChain* ppSwapChain,
            ID3D10Device1* ppDevice);
}
