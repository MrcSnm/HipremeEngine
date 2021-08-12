/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.renderer.backend.d3d.renderer;
version(Windows):

pragma(lib, "ole32");
pragma(lib, "user32");
pragma(lib, "d3dcompiler");
pragma(lib, "d3d11");
pragma(lib, "dxgi");
import global.consts;
import implementations.renderer.renderer;
import implementations.renderer.shader;
import implementations.renderer.framebuffer;
import implementations.renderer.backend.d3d.shader;
import implementations.renderer.backend.d3d.vertex;
import implementations.renderer.backend.d3d.utils;
import implementations.renderer.texture;
import error.handler;

import graphics.g2d.viewport;
import core.stdc.string;
import std.conv:to;
import directx.d3d11;
import core.sys.windows.windows;
import bindbc.sdl;

ID3D11Device _hip_d3d_device = null;
ID3D11DeviceContext _hip_d3d_context = null;
IDXGISwapChain _hip_d3d_swapChain = null;
ID3D11RenderTargetView _hip_d3d_mainRenderTarget = null;


class Hip_D3D11_Renderer : IHipRendererImpl
{
    public static SDL_Renderer* renderer = null;
    public static SDL_Window* window = null;
    protected static bool hasDebugAvailable;
    protected static Viewport currentViewport;
    public static Shader currentShader;

    static if(HIP_DEBUG)
    {
        import directx.dxgidebug;
        IDXGIInfoQueue dxgiQueue;
    }
    

    public SDL_Window* createWindow(uint width, uint height)
    {
        SDL_SetHint(SDL_HINT_RENDER_DRIVER, "direct3d11");
        static if(HIP_DEBUG)
        {
            SDL_SetHint(SDL_HINT_RENDER_DIRECT3D11_DEBUG, "1");
        }
        alias f = SDL_WindowFlags;
        SDL_WindowFlags flags = f.SDL_WINDOW_RESIZABLE | f.SDL_WINDOW_ALLOW_HIGHDPI;
        SDL_Window* window = SDL_CreateWindow("DX Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, flags);

        return window;
    }
    protected void initD3D(HWND hwnd, HipRendererConfig* config)
    {
        DXGI_SWAP_CHAIN_DESC dsc;
        dsc.OutputWindow = hwnd;
        dsc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
        dsc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
        dsc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL;

        ubyte bufferCount = 2;
        ubyte samplingLevel = 1;
        if(config != null)
            bufferCount = config.bufferingCount;
        if(config != null && config.multisamplingLevel > 0)
            samplingLevel = config.multisamplingLevel;

        dsc.BufferCount = bufferCount;
        dsc.SampleDesc.Count = samplingLevel;
        dsc.SampleDesc.Quality = 0;
        dsc.Windowed = TRUE; //True
        //Let user being able to switch between fullscreen and windowed
        dsc.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;

        
        // dsc.BufferDesc.Width = 0;
        // dsc.BufferDesc.Height = 0;
        // dsc.BufferDesc.RefreshRate.Numerator = 60;
        // dsc.BufferDesc.RefreshRate.Denominator = 1;

        uint createDeviceFlags = 0;
        static if(HIP_DEBUG){
            pragma(msg, "D3D11_CREATE_DEVICE_DEBUG:\n\tComment this flag if you do not have d3d11 debug device installed");

            /**
            * https://docs.microsoft.com/en-us/windows/win32/direct3d11/overviews-direct3d-11-devices-layers#debug-layer
            *
            * For Windows 10, to create a device that supports the debug layer,
            * enable the "Graphics Tools" optional feature. Go to the Settings panel,
            * under System, Apps & features, Manage optional Features,
            * Add a feature, and then look for "Graphics Tools".
            */
            createDeviceFlags|= D3D11_CREATE_DEVICE_DEBUG;
            
        }
        const D3D_FEATURE_LEVEL[] levelArray = 
        [
            D3D_FEATURE_LEVEL_11_1,
            D3D_FEATURE_LEVEL_11_0,
            D3D_FEATURE_LEVEL_10_1,
            D3D_FEATURE_LEVEL_10_0,
            D3D_FEATURE_LEVEL_9_3,
            D3D_FEATURE_LEVEL_9_1
        ];
        D3D_FEATURE_LEVEL featureLevel;

        auto res = D3D11CreateDeviceAndSwapChain(null,
                                                D3D_DRIVER_TYPE_HARDWARE,
                                                null,
                                                createDeviceFlags,
                                                levelArray.ptr,
                                                cast(uint)levelArray.length,
                                                D3D11_SDK_VERSION,
                                                &dsc,
                                                &_hip_d3d_swapChain,
                                                &_hip_d3d_device,
                                                &featureLevel,
                                                &_hip_d3d_context);

        
        if(ErrorHandler.assertErrorMessage(SUCCEEDED(res), "D3D11: Error creating device and swap chain", Hip_D3D11_GetErrorMessage(res)))
        {
            Hip_D3D11_Dispose();
            return;
        }

        static if(HIP_DEBUG)
        {
            import core.sys.windows.dll;
            HRESULT hres;
            DXGIGetDebugInterface = cast(_DXGIGetDebugInterface)GetProcAddress(GetModuleHandle("Dxgidebug.dll"), "DXGIGetDebugInterface");
            if(DXGIGetDebugInterface is null)
            {
                ErrorHandler.showErrorMessage("DLL Error", "Error loading the DXGIGetDebugInterface from Dxgidebug.dll
                Debug layer will be aborted.");
                goto rendererDefine;
            }
            hres = DXGIGetDebugInterface(&uuidof!IDXGIInfoQueue, cast(void**)&dxgiQueue);
            if(FAILED(hres))
            {
                ErrorHandler.showErrorMessage("DXGI Error", "Could not get the IDXGIInfoQueue interface. \nError: " ~
                Hip_D3D11_GetErrorMessage(hres) ~ "\nDebug layer will be aborted.");
                goto rendererDefine;
            }
            hasDebugAvailable = true;
        }
        rendererDefine:

        ID3D11Texture2D pBackBuffer;

        res = _hip_d3d_swapChain.GetBuffer(0, &IID_ID3D11Texture2D, cast(void**)&pBackBuffer);
        ErrorHandler.assertErrorMessage(SUCCEEDED(res), "Error creating D3D11Texture2D", Hip_D3D11_GetErrorMessage(res));

        //Use back buffer address to create a render target
        res = _hip_d3d_device.CreateRenderTargetView(pBackBuffer, null, &_hip_d3d_mainRenderTarget);
        ErrorHandler.assertErrorMessage(SUCCEEDED(res), "Error creating render target view", Hip_D3D11_GetErrorMessage(res));
        pBackBuffer.Release();

        _hip_d3d_context.OMSetRenderTargets(1u, &_hip_d3d_mainRenderTarget, null);
        setState();
    }

    public void setState()
    {
        D3D11_RASTERIZER_DESC desc;
        desc.CullMode = D3D11_CULL_NONE;
        ID3D11RasterizerState state;

        if(FAILED(_hip_d3d_device.CreateRasterizerState(&desc, &state)))
            HipRenderer.exitOnError();

        _hip_d3d_context.RSSetState(state);
    }
    public final bool isRowMajor(){return false;}

    public SDL_Renderer* createRenderer(SDL_Window* window)
    {
        //D3D Cannot create any sdl renderer
        return null;
        // return SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
    }

    public bool hasErrorOccurred(out string err, string file = __FILE__, int line = __LINE__)
    {
        if(hasDebugAvailable)
        {
            DXGI_INFO_QUEUE_MESSAGE* msg;
            bool hasError;
            ulong msgSize;
            for(ulong i = 0, 
            // len = dxgiQueue.GetNumStoredMessagesAllowedByRetrievalFilters(DXGI_DEBUG_DX);
            len = dxgiQueue.GetNumStoredMessages(DXGI_DEBUG_DX);
            i < len; i++)
            {
                import std.stdio;
                import core.stdc.stdlib;
                dxgiQueue.GetMessage(DXGI_DEBUG_DX, i, null, &msgSize);
                msg = cast(DXGI_INFO_QUEUE_MESSAGE*)malloc(msgSize);
                dxgiQueue.GetMessage(DXGI_DEBUG_DX, i, msg, &msgSize);
                if(msg.pDescription !is null || msg.Severity == DXGI_INFO_QUEUE_MESSAGE_SEVERITY_ERROR)
                {
                    hasError = true;
                    err~= to!string(msg.pDescription)~"\n";
                }
                free(msg);
            }
            return hasError;
        }
        else
        {
            HRESULT hres = GetLastError();
            err = Hip_D3D11_GetErrorMessage(hres);
            return FAILED(hres);
        }
    }

    public bool setWindowMode(HipWindowMode mode)
    {
        final switch(mode) with(HipWindowMode)
        {
            case BORDERLESS_FULLSCREEN:
                break;
            case FULLSCREEN:
                break;
            case WINDOWED:

                break;
        }
        return false;
    }

    public IHipFrameBuffer createFrameBuffer(int width, int height)
    {
        return null;
    }
    public IHipVertexArrayImpl  createVertexArray()
    {
        return new Hip_D3D11_VertexArrayObject();
    }
    public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage)
    {
        return new Hip_D3D11_VertexBufferObject(size, usage);
    }
    public IHipIndexBufferImpl  createIndexBuffer(uint count, HipBufferUsage usage)
    {
        return new Hip_D3D11_IndexBufferObject(count, usage);
    }

    public Shader createShader()
    {
        return new Shader(new Hip_D3D11_ShaderImpl());
    }
    public bool init(SDL_Window* window, SDL_Renderer* renderer)
    {
        this.window = window;
        this.renderer = renderer;
        SDL_SysWMinfo wmInfo;
        SDL_GetWindowWMInfo(window, &wmInfo);

        HipRendererConfig cfg = HipRenderer.getCurrentConfig();
        initD3D(cast(HWND)wmInfo.info.win.window, &cfg);
        HipRenderer.rendererType = HipRendererType.D3D11;
        // setShader(createShader(true));

        return ErrorHandler.stopListeningForErrors();
    }

    version(dll)
    {
        public bool initExternal()
        {
            import bind.external:getCoreWindowHWND;
            import def.debugging.log;
            HWND hwnd = getCoreWindowHWND();
            rawlog("OPAAAA RTEMOS AQUI");
            if(hwnd == null)
                return false;
            HipRendererConfig cfg;
            initD3D(hwnd, &cfg);
            return true;
        }
    }


    public void setRendererMode(HipRendererMode mode)
    {
        final switch(mode) with(HipRendererMode)
        {
            case TRIANGLES:
                _hip_d3d_context.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
                break;
            case TRIANGLE_STRIP:
                _hip_d3d_context.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP);
                break;
            case LINE:
                _hip_d3d_context.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_LINELIST);
                break;
            case LINE_STRIP:
                _hip_d3d_context.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP);
                break;
            case POINT:
                _hip_d3d_context.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_POINTLIST);
                break;
        }
    }

    public void setViewport(Viewport v)
    {
        D3D11_VIEWPORT vp;
        memset(&vp, 0, D3D11_VIEWPORT.sizeof);
        vp.Width = v.w;
        vp.Height = v.h;
        vp.TopLeftX = 0;
        vp.TopLeftY = 0;
        // vp.MinDepth = 0;
        // vp.MaxDepth = 1;

        currentViewport = v;
        _hip_d3d_context.RSSetViewports(1u, &vp);
    }
    


    void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255){}
    void setShader(Shader s)
    {
        currentShader = s;
    }

    void begin()
    {
        // if(HipRenderer.currentShader != currentShader)
        //     HipRenderer.setShader(currentShader);
        _hip_d3d_context.OMSetRenderTargets(1u, &_hip_d3d_mainRenderTarget, null);
    }
    void end()
    {
        _hip_d3d_swapChain.Present(0,0);
    }

    public void drawVertices(uint count, uint offset = 0)
    {
        _hip_d3d_context.Draw(count, offset);
    }
    public void drawIndexed(uint indicesSize, uint offset=0)
    {
        _hip_d3d_context.DrawIndexed(indicesSize, offset, 0);
    }
    public void drawRect(){}
    public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void drawRect(int x, int y, int w, int h){}

    void clear(){}
    
    void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        float[4] color = [cast(float)r/255, cast(float)g/255, cast(float)b/255, cast(float)a/255];
        _hip_d3d_context.ClearRenderTargetView(_hip_d3d_mainRenderTarget, color.ptr);
    }
    public void draw(Texture t, int x, int y){}
    public void draw(Texture t, int x, int y, SDL_Rect* rect){}
    public void fillRect(int x, int y, int width, int height){}
    public void drawLine(int x1, int y1, int x2, int y2){}
    public void drawPixel(int x, int y ){}

    public void dispose()
    {
        Hip_D3D11_Dispose();
    }
}

private void Hip_D3D11_Dispose()
{
    if(_hip_d3d_swapChain)
    {
        _hip_d3d_swapChain.SetFullscreenState(FALSE, null);
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
    if(_hip_d3d_mainRenderTarget)
    {
        _hip_d3d_mainRenderTarget.Release();
        _hip_d3d_mainRenderTarget = null;
    }
}

