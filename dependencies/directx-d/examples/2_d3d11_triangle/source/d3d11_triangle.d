//--------------------------------------------------------------------------------------
// File: Tutorial02.cpp
//
// This application displays a triangle using Direct3D 11
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

import core.runtime;
import std.stdio;
import std.format;
import std.string : toStringz;
import std.utf : toUTF16z;
import core.stdc.stdio;
import core.stdc.string : memset;

import directx.win32;
import directx.d3d11;
import directx.d3dx11async;
import directx.d3dcompiler;

//import directx.math;
//#include <xnamath.h>

//--------------------------------------------------------------------------------------
// Structures
//--------------------------------------------------------------------------------------

struct FLOAT3
{
 float x, y, z;
}

struct SimpleVertex
{
    FLOAT3[] Pos;
}

bool _FAILED(HRESULT res, string f = __PRETTY_FUNCTION__, uint l = __LINE__)
{
    import std.conv:to;
    bool ret = FAILED(res);
    if(ret)
        writeln("Fodeu at " ~ f ~ ":" ~ to!string(l));
    return ret;
}


//--------------------------------------------------------------------------------------
// Global Variables
//--------------------------------------------------------------------------------------
// NOTE: in D this is thread-local, use __gshared for C style globals
HINSTANCE               g_hInst = null;
HWND                    g_hWnd = null;
D3D_DRIVER_TYPE         g_driverType = D3D_DRIVER_TYPE_HARDWARE;
D3D_FEATURE_LEVEL       g_featureLevel = D3D_FEATURE_LEVEL_11_0;
ID3D11Device            g_pd3dDevice = null;
ID3D11DeviceContext     g_pImmediateContext = null;
IDXGISwapChain          g_pSwapChain = null;
ID3D11RenderTargetView  g_pRenderTargetView = null;
ID3D11VertexShader      g_pVertexShader = null;
ID3D11PixelShader       g_pPixelShader = null;
ID3D11InputLayout       g_pVertexLayout = null;
ID3D11Buffer            g_pVertexBuffer = null;


//--------------------------------------------------------------------------------------
// Entry point to the program. Initializes everything and goes into a message processing 
// loop. Idle time is used to render the scene.
//--------------------------------------------------------------------------------------
int myWinMain()
{
    import std.stdio;

    writeln("Hello world");
    if( _FAILED( InitWindow( null, 0 ) ) )
        return 0;

    if( _FAILED( InitDevice() ) )
    {
        CleanupDevice();
        return 0;
    }

    // Main message loop
    MSG msg;
    while( true)
    {
        if( PeekMessage( &msg, null, 0, 0, PM_REMOVE ) )
        {
            TranslateMessage( &msg );
            DispatchMessage( &msg );
            if( msg.message == WM_QUIT )
                break;
        }
        Render();
    }

    CleanupDevice();

    return S_OK;
}


// extern (Windows)
int main()
{
    int result;

	try
    {
		result = myWinMain();
    }

    catch (Exception e)            // catch any uncaught exceptions
    {
        MessageBox(null, toUTF16z(e.msg), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;             // _failed
    }

	return result;
}

//--------------------------------------------------------------------------------------
// Register class and create window
//--------------------------------------------------------------------------------------
HRESULT InitWindow( HINSTANCE hInstance, int nCmdShow )
{
    HINSTANCE hInst = GetModuleHandleA(null);
    WNDCLASS  wc;

    wc.lpszClassName = "DWndClass";
    wc.style         = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = &WndProc;
    wc.hInstance     = hInst;
    wc.hIcon         = LoadIcon(cast(HINSTANCE) null, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(cast(HINSTANCE) null, IDC_CROSS);
    wc.hbrBackground = cast(HBRUSH) (COLOR_WINDOW + 1);
    wc.lpszMenuName  = null;
    wc.cbClsExtra    = wc.cbWndExtra = 0;
    auto a = RegisterClass(&wc);
    assert(a);

    g_hWnd = CreateWindow("DWndClass", "D3D Triangle", WS_THICKFRAME |
                         WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE,
                         CW_USEDEFAULT, CW_USEDEFAULT, 400, 300, HWND_DESKTOP,
                         cast(HMENU) null, hInst, null);
    assert(g_hWnd);
    RECT rc = { 0, 0, 640, 480 };
    AdjustWindowRect( &rc, WS_OVERLAPPEDWINDOW, FALSE );
    
    if( !g_hWnd )
        return E_FAIL;

    ShowWindow( g_hWnd, SW_SHOW );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Helper for compiling shaders with D3DX11
//--------------------------------------------------------------------------------------
HRESULT CompileShaderFromFile( string szFileName, string szEntryPoint, string szShaderModel, ID3DBlob* ppBlobOut )
{
    HRESULT hr = S_OK;

    DWORD dwShaderFlags = D3DCOMPILE_ENABLE_STRICTNESS;
debug {
    // Set the D3DCOMPILE_DEBUG flag to embed debug information in the shaders.
    // Setting this flag improves the shader debugging experience, but still allows 
    // the shaders to be optimized and to run exactly the way they will run in 
    // the release configuration of this program.
    dwShaderFlags |= D3DCOMPILE_DEBUG;
}

    ID3DBlob pErrorBlob;

	hr = D3DCompileFromFile ( toUTF16z(szFileName), null, null, toStringz(szEntryPoint), toStringz(szShaderModel),
		dwShaderFlags, 0, ppBlobOut, &pErrorBlob);

    if( _FAILED(hr) )
    {
        if( pErrorBlob ) 
        {
            MessageBoxA( null, cast(char*)pErrorBlob.GetBufferPointer(), "Error", MB_OK );
            pErrorBlob.Release();
        }
        return hr;
    }
    if( pErrorBlob ) pErrorBlob.Release();

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Create Direct3D device and swap chain
//--------------------------------------------------------------------------------------
HRESULT InitDevice()
{
    HRESULT hr = S_OK;

    RECT rc;
    GetClientRect( g_hWnd, &rc );
    UINT width = rc.right - rc.left;
    UINT height = rc.bottom - rc.top;

    UINT createDeviceFlags = 0;
debug {
    createDeviceFlags |= D3D11_CREATE_DEVICE_DEBUG; //Not working
    createDeviceFlags = 0;
}

    D3D_DRIVER_TYPE[] driverTypes =
    [
        D3D_DRIVER_TYPE_HARDWARE,
        D3D_DRIVER_TYPE_WARP,
        D3D_DRIVER_TYPE_REFERENCE,
    ];
    UINT numDriverTypes = cast(UINT)driverTypes.length;

    D3D_FEATURE_LEVEL[] featureLevels =
    [
        D3D_FEATURE_LEVEL_11_0,
        D3D_FEATURE_LEVEL_10_1,
        D3D_FEATURE_LEVEL_10_0,
    ];
	UINT numFeatureLevels = cast(UINT)featureLevels.length;

    DXGI_SWAP_CHAIN_DESC sd;
    memset( &sd, 0, DXGI_SWAP_CHAIN_DESC.sizeof );
    sd.BufferCount = 1;
    sd.BufferDesc.Width = width;
    sd.BufferDesc.Height = height;
    sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    sd.BufferDesc.RefreshRate.Numerator = 60;
    sd.BufferDesc.RefreshRate.Denominator = 1;
    sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    sd.OutputWindow = g_hWnd;
    sd.SampleDesc.Count = 1;
    sd.SampleDesc.Quality = 0;
    sd.Windowed = TRUE;


    for( UINT driverTypeIndex = 0; driverTypeIndex < numDriverTypes; driverTypeIndex++ )
    {
        g_driverType = driverTypes[driverTypeIndex];
        hr = D3D11CreateDeviceAndSwapChain( null, g_driverType, null, createDeviceFlags, featureLevels.ptr, numFeatureLevels,
                                            D3D11_SDK_VERSION, &sd, &g_pSwapChain, &g_pd3dDevice, &g_featureLevel, &g_pImmediateContext );
        if( SUCCEEDED( hr ) )
            break;
    }
    if( _FAILED( hr ) )
        return hr;

    // Create a render target view
    ID3D11Texture2D pBackBuffer;
    hr = g_pSwapChain.GetBuffer( 0, &IID_ID3D11Texture2D, cast( LPVOID* )&pBackBuffer );
    if( _FAILED( hr ) )
        return hr;

    hr = g_pd3dDevice.CreateRenderTargetView( pBackBuffer, null, &g_pRenderTargetView );
    pBackBuffer.Release();
    if( _FAILED( hr ) )
        return hr;

    g_pImmediateContext.OMSetRenderTargets( 1, &g_pRenderTargetView, null );

    // Setup the viewport
    D3D11_VIEWPORT vp;
    vp.Width = cast(FLOAT)width;
    vp.Height = cast(FLOAT)height;
    vp.MinDepth = 0.0f;
    vp.MaxDepth = 1.0f;
    vp.TopLeftX = 0;
    vp.TopLeftY = 0;
    g_pImmediateContext.RSSetViewports( 1, &vp );

    // Compile the vertex shader
    ID3DBlob pVSBlob;
    hr = CompileShaderFromFile( "Tutorial02.fx" , "VS", "vs_4_0", &pVSBlob );
    if( _FAILED( hr ) )
    {
        MessageBox( null,
                    "The FX file cannot be compiled.  Please run this executable from the directory that contains the FX file.", "Error", MB_OK );
        return hr;
    }

	// Create the vertex shader
	hr = g_pd3dDevice.CreateVertexShader( pVSBlob.GetBufferPointer(), pVSBlob.GetBufferSize(), null, &g_pVertexShader );
	if( _FAILED( hr ) )
	{	
		pVSBlob.Release();
        return hr;
	}

    // Define the input layout
    D3D11_INPUT_ELEMENT_DESC[] layout =
    [
        { "POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0 },
    ];
	UINT numElements =  cast(UINT)layout.length;

    // Create the input layout
	hr = g_pd3dDevice.CreateInputLayout( layout.ptr, numElements, pVSBlob.GetBufferPointer(),
                                          pVSBlob.GetBufferSize(), &g_pVertexLayout );
	pVSBlob.Release();
	if( _FAILED( hr ) )
        return hr;

    // Set the input layout
    g_pImmediateContext.IASetInputLayout( g_pVertexLayout );

	// Compile the pixel shader
	ID3DBlob pPSBlob;
    hr = CompileShaderFromFile( "Tutorial02.fx", "PS", "ps_4_0", &pPSBlob );
    if( _FAILED( hr ) )
    {
        MessageBox( null,
                    "The FX file cannot be compiled.  Please run this executable from the directory that contains the FX file.", "Error", MB_OK );
        return hr;
    }

	// Create the pixel shader
	hr = g_pd3dDevice.CreatePixelShader( pPSBlob.GetBufferPointer(), pPSBlob.GetBufferSize(), null, &g_pPixelShader );
	pPSBlob.Release();
    if( _FAILED( hr ) )
        return hr;

    // Create vertex buffer
    SimpleVertex vertices = {
    [
        FLOAT3( 0.0f, 0.5f, 0.5f ),
        FLOAT3( 0.5f, -0.5f, 0.5f ),
        FLOAT3( -0.5f, -0.5f, 0.5f ),
    ] };
    D3D11_BUFFER_DESC bd;
	memset( &bd, 0, D3D11_BUFFER_DESC.sizeof );
    bd.Usage = D3D11_USAGE_DEFAULT;
    bd.ByteWidth = FLOAT3.sizeof * 3;
    bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
	bd.CPUAccessFlags = 0;
    D3D11_SUBRESOURCE_DATA InitData;
	memset( &InitData, 0, D3D11_SUBRESOURCE_DATA.sizeof );
    InitData.pSysMem = vertices.Pos.ptr;
    hr = g_pd3dDevice.CreateBuffer( &bd, &InitData, &g_pVertexBuffer );
    if( _FAILED( hr ) )
        return hr;

    // Set vertex buffer
    UINT stride = FLOAT3.sizeof;
    UINT offset = 0;
    g_pImmediateContext.IASetVertexBuffers( 0, 1, &g_pVertexBuffer, &stride, &offset );

    // Set primitive topology
    g_pImmediateContext.IASetPrimitiveTopology( D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Clean up the objects we've created
//--------------------------------------------------------------------------------------
void CleanupDevice()
{
    if( g_pImmediateContext ) g_pImmediateContext.ClearState();

    if( g_pVertexBuffer ) g_pVertexBuffer.Release();
    if( g_pVertexLayout ) g_pVertexLayout.Release();
    if( g_pVertexShader ) g_pVertexShader.Release();
    if( g_pPixelShader ) g_pPixelShader.Release();
    if( g_pRenderTargetView ) g_pRenderTargetView.Release();
    if( g_pSwapChain ) g_pSwapChain.Release();
    if( g_pImmediateContext ) g_pImmediateContext.Release();
    if( g_pd3dDevice ) g_pd3dDevice.Release();
}


//--------------------------------------------------------------------------------------
// Called every time the application receives a message
//--------------------------------------------------------------------------------------
extern(Windows) LRESULT WndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam ) nothrow
{
    PAINTSTRUCT ps;
    HDC hdc;

    switch( message )
    {
        case WM_PAINT:
            hdc = BeginPaint( hWnd, &ps );
            EndPaint( hWnd, &ps );
            break;

        case WM_DESTROY:
            PostQuitMessage( 0 );
            break;
        default:
            break;
    }

    return DefWindowProc( hWnd, message, wParam, lParam );
}


//--------------------------------------------------------------------------------------
// Render a frame
//--------------------------------------------------------------------------------------
void Render()
{
    // Clear the back buffer 
    float[4] ClearColor = [ 0.0f, 0.125f, 0.3f, 1.0f ]; // red,green,blue,alpha
    g_pImmediateContext.ClearRenderTargetView( g_pRenderTargetView, ClearColor.ptr );

    // Render a triangle
	g_pImmediateContext.VSSetShader( g_pVertexShader, null, 0 );
	g_pImmediateContext.PSSetShader( g_pPixelShader, null, 0 );
    g_pImmediateContext.Draw( 3, 0 );

    // Present the information rendered to the back buffer to the front buffer (the screen)
    g_pSwapChain.Present( 0, 0 );
}
