module directx.d3d11on12;
/*-------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation
 *
 *-------------------------------------------------------------------------------------*/

version(Windows):

public import directx.d3d11;
public import directx.d3d12;

///////////////////////////////////////////////////////////////////////////
// D3D11On12CreateDevice
// ------------------
//
// pDevice
//      Specifies a pre-existing D3D12 device to use for D3D11 interop.
//      May not be NULL.
// Flags
//      Any of those documented for D3D11CreateDeviceAndSwapChain.
// pFeatureLevels
//      Array of any of the following:
//          D3D_FEATURE_LEVEL_12_1
//          D3D_FEATURE_LEVEL_12_0
//          D3D_FEATURE_LEVEL_11_1
//          D3D_FEATURE_LEVEL_11_0
//          D3D_FEATURE_LEVEL_10_1
//          D3D_FEATURE_LEVEL_10_0
//          D3D_FEATURE_LEVEL_9_3
//          D3D_FEATURE_LEVEL_9_2
//          D3D_FEATURE_LEVEL_9_1
//       The first feature level which is less than or equal to the
//       D3D12 device's feature level will be used to perform D3D11 validation.
//       Creation will fail if no acceptable feature levels are provided.
//       Providing NULL will default to the D3D12 device's feature level.
// FeatureLevels
//      Size of feature levels array.
// ppCommandQueues
//      Array of unique queues for D3D11On12 to use. Valid queue types:
//          3D command queue.
//      Flags must be compatible with device flags, and its NodeMask must
//      be a subset of the NodeMask provided to this API.
// NumQueues
//      Size of command queue array.
// NodeMask
//      Which node of the D3D12 device to use.  Only 1 bit may be set.
// ppDevice
//      Pointer to returned interface. May be NULL.
// ppImmediateContext
//      Pointer to returned interface. May be NULL.
// pChosenFeatureLevel
//      Pointer to returned feature level. May be NULL.
//
// Return Values
//  Any of those documented for
//          D3D11CreateDevice
//
///////////////////////////////////////////////////////////////////////////

__gshared PFN_D3D11ON12_CREATE_DEVICE D3D11On12CreateDevice;

extern(Windows)
alias PFN_D3D11ON12_CREATE_DEVICE = HRESULT function(
    IUnknown pDevice,
    UINT Flags,
    const(D3D_FEATURE_LEVEL)* pFeatureLevels,
    UINT FeatureLevels,
    const(IUnknown)* ppCommandQueues,
    UINT NumQueues,
    UINT NodeMask,
    ID3D11Device* ppDevice,
    ID3D11DeviceContext* ppImmediateContext,
    D3D_FEATURE_LEVEL* pChosenFeatureLevel);

struct D3D11_RESOURCE_FLAGS
{
    UINT BindFlags;
    UINT MiscFlags;
    UINT CPUAccessFlags;
    UINT StructureByteStride;
}

mixin(uuid!(ID3D11On12Device, "85611e73-70a9-490e-9614-a9e302777904"));
extern (C++) interface ID3D11On12Device : IUnknown {
    HRESULT CreateWrappedResource(
        IUnknown pResource12,
        const(D3D11_RESOURCE_FLAGS)* pFlags11,
        D3D12_RESOURCE_STATES InState,
        D3D12_RESOURCE_STATES OutState,
        REFIID riid,
        void** ppResource11);

    void ReleaseWrappedResources(
        const(ID3D11Resource)* ppResources,
        UINT NumResources);

    void AcquireWrappedResources(
        const(ID3D11Resource)* ppResources,
        UINT NumResources);
}
