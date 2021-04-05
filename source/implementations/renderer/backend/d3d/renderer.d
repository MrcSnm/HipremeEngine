module implementations.renderer.backend.d3d.renderer;
version(Windows):
import implementations.renderer.shader;
import implementations.renderer.backend.d3d.shader;
import error.handler;

import graphics.g2d.viewport;
import core.stdc.string;
import directx.d3d11;
import core.sys.windows.windows;
import bindbc.sdl;

enum RendererMode
{
    POINT,
    LINE,
    LINE_STRIP,
    TRIANGLE,
    TRIANGLE_STRIP
}

ID3D11Device _hip_d3d_device = null;
ID3D11DeviceContext _hip_d3d_context = null;
IDXGISwapChain _hip_d3d_swapChain = null;
ID3D11RenderTargetView _hip_d3d_mainRenderTarget = null;

/**
*   Currently only supports direct3d11
*/
private SDL_Window* createSDL_DX_Window()
{
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "direct3d11");
    alias f = SDL_WindowFlags;
    SDL_WindowFlags flags = f.SDL_WINDOW_RESIZABLE | f.SDL_WINDOW_ALLOW_HIGHDPI;
    SDL_Window* window = SDL_CreateWindow("DX Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, flags);
    SDL_SysWMinfo wmInfo;
    SDL_GetWindowWMInfo(window, &wmInfo);
    HWND hwnd = cast(HWND)wmInfo.info.win.window;

    DXGI_SWAP_CHAIN_DESC dsc;
    
    memset(&dsc, 0, dsc.sizeof);//ZeroMemory

    dsc.BufferCount = 2;
    dsc.BufferDesc.Width = 0;
    dsc.BufferDesc.Height = 0;
    dsc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    dsc.BufferDesc.RefreshRate.Numerator = 60;
    dsc.BufferDesc.RefreshRate.Denominator = 1;
    dsc.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
    dsc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    dsc.OutputWindow = hwnd;
    dsc.SampleDesc.Count = 1;
    dsc.SampleDesc.Quality = 0;
    dsc.Windowed = true;
    dsc.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;

    uint createDeviceFlags = 0;
    const D3D_FEATURE_LEVEL[] levelArray = [D3D_FEATURE_LEVEL_11_0, D3D_FEATURE_LEVEL_10_0];
    D3D_FEATURE_LEVEL featureLevel;

    if(D3D11CreateDeviceAndSwapChain(cast(IDXGIAdapter)null, D3D_DRIVER_TYPE_HARDWARE, cast(HMODULE)null, createDeviceFlags,
    levelArray.ptr, cast(uint)levelArray.length, D3D11_SDK_VERSION, &dsc, &_hip_d3d_swapChain, &_hip_d3d_device,
    &featureLevel, &_hip_d3d_context))
    {
        Hip_D3D11_Renderer.dispose();
        return null;
    }

    return window;
}

void CreateRenderTarget()
{
    ID3D11Texture2D backBuffer;
    _hip_d3d_swapChain.GetBuffer(0, &IID_ID3D11Texture2D, cast(void**)&backBuffer);
    _hip_d3d_device.CreateRenderTargetView(backBuffer, null, &_hip_d3d_mainRenderTarget);
    backBuffer.Release();

}


class Hip_D3D11_Renderer
{
    public static SDL_Renderer* renderer = null;
    public static SDL_Window* window = null;
    protected static Viewport currentViewport;
    protected static Viewport mainViewport;
    public static Viewport getCurrentViewport(){return currentViewport;}
    public static Shader currentShader;

    public Shader createShader(bool createDefault)
    {
        return new Shader(new Hip_D3D11_ShaderImpl(), createDefault);
    }
    public bool init()
    {
        window = createSDL_DX_Window();
        ErrorHandler.assertErrorMessage(window != null, "Error creating window", "Could not create SDL D3D Window");
        renderer = SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
        ErrorHandler.assertErrorMessage(renderer != null, "Error creating renderer", "Could not create SDL Renderer");
        mainViewport = new Viewport(0,0,0,0);
        // setShader(new Shader(new Hip_D3D11_ShaderImpl()));

        return ErrorHandler.stopListeningForErrors();
    }


    public static void setMode(RendererMode mode)
    {
        if(mode == RendererMode.TRIANGLE)
        {
            _hip_d3d_context.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
        }
    }

    public static void setViewport(Viewport v)
    {
        D3D11_VIEWPORT vp;
        vp.Width = v.w;
        vp.Height = v.h;
        vp.MinDepth = 0;
        vp.MaxDepth = 1;
        vp.TopLeftX = 0;
        vp.TopLeftY = 0;

        currentViewport = v;
        _hip_d3d_context.RSSetViewports(1u, &vp);
    }

    public static void dispose()
    {
        if(_hip_d3d_swapChain)
        {
            _hip_d3d_swapChain.Release();
            _hip_d3d_swapChain = null;
        }
        if(_hip_d3d_context)
        {
            _hip_d3d_context.Release();
            _hip_d3d_context = null;
        }
        if(_hip_d3d_device)
        {
            _hip_d3d_device.Release();
            _hip_d3d_device = null;
        }
    }
}