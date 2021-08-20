module directx.d3dx11;
//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx11.h
//  Content:    D3DX11 utility library
//
//////////////////////////////////////////////////////////////////////////////

version(Windows):

enum D3DX11_DEFAULT            = (cast(UINT) -1);
enum D3DX11_FROM_FILE          = (cast(UINT) -3);
enum DXGI_FORMAT_FROM_FILE     = (cast(DXGI_FORMAT) -3);

// Includes
public import directx.d3d11;
public import directx.d3dx11;
public import directx.d3dx11core;
public import directx.d3dx11tex;
public import directx.d3dx11async;

// Errors
enum _FACDD  = 0x876;

HRESULT MAKE_DDHRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACDD, code);
}

alias D3DX11_ERR = int;
enum : D3DX11_ERR
{
    D3DX11_ERR_CANNOT_MODIFY_INDEX_BUFFER       = MAKE_DDHRESULT(2900),
    D3DX11_ERR_INVALID_MESH                     = MAKE_DDHRESULT(2901),
    D3DX11_ERR_CANNOT_ATTR_SORT                 = MAKE_DDHRESULT(2902),
    D3DX11_ERR_SKINNING_NOT_SUPPORTED           = MAKE_DDHRESULT(2903),
    D3DX11_ERR_TOO_MANY_INFLUENCES              = MAKE_DDHRESULT(2904),
    D3DX11_ERR_INVALID_DATA                     = MAKE_DDHRESULT(2905),
    D3DX11_ERR_LOADED_MESH_HAS_NO_DATA          = MAKE_DDHRESULT(2906),
    D3DX11_ERR_DUPLICATE_NAMED_FRAGMENT         = MAKE_DDHRESULT(2907),
    D3DX11_ERR_CANNOT_REMOVE_LAST_ITEM		    = MAKE_DDHRESULT(2908),
}