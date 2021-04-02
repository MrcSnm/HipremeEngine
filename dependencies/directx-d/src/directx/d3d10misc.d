module directx.d3d10misc;
//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) Microsoft Corporation.  All rights reserved.
//
//  File:       D3D10Misc.h
//  Content:    D3D10 Device Creation APIs
//
//////////////////////////////////////////////////////////////////////////////

version(Windows):

public import directx.d3d10;

alias DWORD D3D10_DRIVER_TYPE;
enum : D3D10_DRIVER_TYPE {
    D3D10_DRIVER_TYPE_HARDWARE   = 0,
    D3D10_DRIVER_TYPE_REFERENCE  = 1,
    D3D10_DRIVER_TYPE_NULL       = 2,
    D3D10_DRIVER_TYPE_SOFTWARE   = 3,
    D3D10_DRIVER_TYPE_WARP       = 5
}

///////////////////////////////////////////////////////////////////////////
// D3D10CreateDevice
// ------------------
//
// pAdapter
//      If NULL, D3D10CreateDevice will choose the primary adapter and
//      create a new instance from a temporarily created IDXGIFactory.
//      If non-NULL, D3D10CreateDevice will register the appropriate
//      device, if necessary (via IDXGIAdapter::RegisterDrver), before
//      creating the device.
// DriverType
//      Specifies the driver type to be created: hardware, reference or
//      null.
// Software
//      HMODULE of a DLL implementing a software rasterizer. Must be NULL for
//      non-Software driver types.
// Flags
//      Any of those documented for D3D10CreateDevice.
// SDKVersion
//      SDK version. Use the D3D10_SDK_VERSION macro.
// ppDevice
//      Pointer to returned interface.
//
// Return Values
//  Any of those documented for
//          CreateDXGIFactory
//          IDXGIFactory::EnumAdapters
//          IDXGIAdapter::RegisterDriver
//          D3D10CreateDevice
//
///////////////////////////////////////////////////////////////////////////

__gshared _D3D10CreateDevice D3D10CreateDevice;

extern (Windows) {
    alias _D3D10CreateDevice = HRESULT function(IDXGIAdapter      pAdapter,
                                                D3D10_DRIVER_TYPE DriverType,
                                                HMODULE           Software,
                                                UINT              Flags,
                                                UINT              SDKVersion,
                                                ID3D10Device      *ppDevice);
}

///////////////////////////////////////////////////////////////////////////
// D3D10CreateDeviceAndSwapChain
// ------------------------------
//
// ppAdapter
//      If NULL, D3D10CreateDevice will choose the primary adapter and
//      create a new instance from a temporarily created IDXGIFactory.
//      If non-NULL, D3D10CreateDevice will register the appropriate
//      device, if necessary (via IDXGIAdapter::RegisterDrver), before
//      creating the device.
// DriverType
//      Specifies the driver type to be created: hardware, reference or
//      null.
// Software
//      HMODULE of a DLL implementing a software rasterizer. Must be NULL for
//      non-Software driver types.
// Flags
//      Any of those documented for D3D10CreateDevice.
// SDKVersion
//      SDK version. Use the D3D10_SDK_VERSION macro.
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
//          D3D10CreateDevice
//          IDXGIFactory::CreateSwapChain
//
///////////////////////////////////////////////////////////////////////////

__gshared _D3D10CreateDeviceAndSwapChain D3D10CreateDeviceAndSwapChain;

extern (Windows) {
    alias _D3D10CreateDeviceAndSwapChain = HRESULT function(
        IDXGIAdapter pAdapter,
        D3D10_DRIVER_TYPE DriverType,
        HMODULE Software,
        UINT Flags,
        UINT SDKVersion,
        DXGI_SWAP_CHAIN_DESC* pSwapChainDesc,
        IDXGISwapChain* ppSwapChain,
        ID3D10Device* ppDevice);
}

///////////////////////////////////////////////////////////////////////////
// D3D10CreateBlob:
// -----------------
// Creates a Buffer of n Bytes
//////////////////////////////////////////////////////////////////////////

__gshared _D3D10CreateBlob D3D10CreateBlob;

alias _D3D10CreateBlob = HRESULT function(SIZE_T NumBytes, LPD3D10BLOB ppBuffer);
