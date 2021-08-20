module directx.d3dx11core;
///////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx11core.h
//  Content:    D3DX11 core types and functions
//
///////////////////////////////////////////////////////////////////////////

version(Windows):

import directx.win32;
import directx.com;
import directx.d3d11;

// TODO: better handling to dll version name

// Current name of the DLL shipped in the same SDK as this header.

enum D3DX11_DLL_W = "d3dx11_43.dll"w;
enum D3DX11_DLL_A = "d3dx11_43.dll";

alias D3DX11_DLL_W D3DX11_DLL;

///////////////////////////////////////////////////////////////////////////
// D3DX11_SDK_VERSION:
// -----------------
// This identifier is passed to D3DX11CheckVersion in order to ensure that an
// application was built against the correct header files and lib files. 
// This number is incremented whenever a header (or other) change would 
// require applications to be rebuilt. If the version doesn't match, 
// D3DX11CreateVersion will return FALSE. (The number itself has no meaning.)
///////////////////////////////////////////////////////////////////////////


enum D3DX11_SDK_VERSION = 43;


version(D3D_DIAG_DLL)
extern(Windows) BOOL D3DX11DebugMute(BOOL Mute);  

extern(Windows) HRESULT D3DX11CheckVersion(UINT D3DSdkVersion, UINT D3DX11SdkVersion);


//////////////////////////////////////////////////////////////////////////////
// ID3DX11ThreadPump:
//////////////////////////////////////////////////////////////////////////////

interface ID3DX11DataLoader
{
	extern(Windows):
	HRESULT Load();
	HRESULT Decompress(void** ppData, SIZE_T* pcBytes);
	HRESULT Destroy();
}

interface ID3DX11DataProcessor
{
	extern(Windows):
	HRESULT Process(void* pData, SIZE_T cBytes);
	HRESULT CreateDeviceObject(void** ppDataObject);
	HRESULT Destroy();
}

mixin( uuid!(ID3DX11ThreadPump, "C93FECFA-6967-478a-ABBC-402D90621FCB") );
interface ID3DX11ThreadPump : IUnknown
{
	extern(Windows):
    HRESULT AddWorkItem(ID3DX11DataLoader pDataLoader, ID3DX11DataProcessor pDataProcessor, HRESULT* pHResult, void** ppDeviceObject);
    UINT GetWorkItemCount();

    HRESULT WaitForAllItems();
    HRESULT ProcessDeviceWorkItems(UINT iWorkItemCount);

    HRESULT PurgeAllItems();
    HRESULT GetQueueStatus(UINT* pIoQueue, UINT* pProcessQueue, UINT* pDeviceQueue);
}


extern(Windows) HRESULT D3DX11CreateThreadPump(UINT cIoThreads, UINT cProcThreads, ID3DX11ThreadPump* ppThreadPump);

extern(Windows) HRESULT D3DX11UnsetAllDeviceObjects(ID3D11DeviceContext pContext);



///////////////////////////////////////////////////////////////////////////

enum _FACD3D  = 0x876;

HRESULT MAKE_D3DHRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACD3D, code);
}

HRESULT MAKE_D3DSTATUS(T)(T code) {
	return MAKE_HRESULT(0, _FACD3D, code);
}

enum D3DERR_INVALIDCALL                  = MAKE_D3DHRESULT(2156);
enum D3DERR_WASSTILLDRAWING              = MAKE_D3DHRESULT(540);
