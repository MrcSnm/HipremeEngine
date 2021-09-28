/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hiprenderer.backend.d3d.renderer;
version(Windows):

pragma(lib, "ole32");
pragma(lib, "user32");
pragma(lib, "d3dcompiler");
pragma(lib, "d3d11");
pragma(lib, "dxgi");

import core.stdc.string;
import core.sys.windows.windows;
import std.conv:to;

import directx.d3d11;
import directx.d3d11_3;
import directx.dxgi1_4;
import bindbc.sdl;


import config.opts;
import error.handler;

import hiprenderer.shader;
import hiprenderer.texture;
import hiprenderer.viewport;
import hiprenderer.renderer;
import hiprenderer.framebuffer;

import hiprenderer.backend.d3d.shader;
import hiprenderer.backend.d3d.framebuffer;
import hiprenderer.backend.d3d.vertex;
import hiprenderer.backend.d3d.utils;


version(UWP)
    import bind.external : getCoreWindow, getCoreWindowHWND, HipExternalCoreWindow;

ID3D11Device3 _hip_d3d_device = null;
ID3D11DeviceContext _hip_d3d_context = null;
ID3D11DeviceContext3 _hip_d3d_context3 = null;
IDXGISwapChain3 _hip_d3d_swapChain = null;
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
        uint flags = SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI;
        SDL_Window* window = SDL_CreateWindow("DX Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height, cast(SDL_WindowFlags)flags);

        return window;
    }

    static void assertExit(HRESULT hres, string msg,
    string file = __FILE__, size_t line = __LINE__,
    string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        ErrorHandler.assertExit(SUCCEEDED(hres), msg~":\n\t"~Hip_D3D11_GetErrorMessage(hres),file,line,mod,func);
    }

    protected void createD3DDevice()
    {
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
            D3D_FEATURE_LEVEL_12_1,
            D3D_FEATURE_LEVEL_12_0,
            D3D_FEATURE_LEVEL_11_1,
            D3D_FEATURE_LEVEL_11_0,
            D3D_FEATURE_LEVEL_10_1,
            D3D_FEATURE_LEVEL_10_0,
            D3D_FEATURE_LEVEL_9_3,
            D3D_FEATURE_LEVEL_9_1
        ];
        D3D_FEATURE_LEVEL featureLevel;

        ID3D11Device device;
        ID3D11DeviceContext context;
        HRESULT hres = D3D11CreateDevice(cast(IDXGIAdapter)null,
            D3D_DRIVER_TYPE_HARDWARE,
            null, createDeviceFlags,
            levelArray.ptr,
            cast(uint)levelArray.length,
            D3D11_SDK_VERSION,
            &device,
            &featureLevel,
            &context
        );

        if (FAILED(hres))
        {
            ErrorHandler.showWarningMessage("D3D11: Hardware rendering device creation failed",
            "HipRenderer will try to use software renderer");
            // Initialization failed, fall back to the WARP device.
            hres = D3D11CreateDevice(
                cast(IDXGIAdapter)null,
                D3D_DRIVER_TYPE_WARP,
                null,
                createDeviceFlags,
                levelArray.ptr,
                cast(uint)levelArray.length,
                D3D11_SDK_VERSION,
                &device,
                &featureLevel,
                &context);
            assertExit(SUCCEEDED(hres), "D3D11 Could not creating any rendering context: ");
        }

        device.QueryInterface(&IID_ID3D11Device3, cast(void**)&_hip_d3d_device);
        _hip_d3d_context = context;
    }

    version(UWP)
    protected void createD3DSwapChainForCoreWindow(HipExternalCoreWindow wnd,  HipRendererConfig* config)
    {
        DXGI_SWAP_CHAIN_DESC1 dsc;
        import core.stdc.string;
        memset(&dsc, 0, DXGI_SWAP_CHAIN_DESC1.sizeof);
        dsc.Width = wnd.logicalWidth;
        dsc.Height = wnd.logicalHeight;
        dsc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
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
        // dsc.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
        dsc.Scaling = DXGI_SCALING_ASPECT_RATIO_STRETCH;
        dsc.AlphaMode = DXGI_ALPHA_MODE_IGNORE;


        IDXGIDevice3 dxgiDevice;
        assertExit(
            _hip_d3d_device.QueryInterface(&IID_IDXGIDevice3, cast(void**)&dxgiDevice)
        ,"Could not get the IDXGIDevice3 interface");

        IDXGIAdapter adapter;
        assertExit(
            dxgiDevice.GetAdapter(&adapter)
        , "Could not get DXGI Adapter");

        IDXGIFactory4 factory;
        assertExit(
            adapter.GetParent(&IID_IDXGIFactory4, cast(void**)&factory)
        ,"Could not get IDXGIFactory4");
        
        IDXGISwapChain1 swapChain;
        assertExit(factory.CreateSwapChainForCoreWindow (
            cast(IUnknown)_hip_d3d_device,
            cast(IUnknown)wnd.coreWindow,
            &dsc,
            cast(IDXGIOutput)null,
            &swapChain
        ), "Could not create swap chain for CoreWindow");

        swapChain.QueryInterface(&IID_IDXGISwapChain3, cast(void**)&_hip_d3d_swapChain);
    }
    
    protected void initD3DDebug()
    {
        static if(HIP_DEBUG)
        {
            import core.sys.windows.dll;
            HRESULT hres;
            DXGIGetDebugInterface = cast(_DXGIGetDebugInterface)GetProcAddress(GetModuleHandle("Dxgidebug.dll"), "DXGIGetDebugInterface");
            if(DXGIGetDebugInterface is null)
            {
                ErrorHandler.showErrorMessage("DLL Error", "Error loading the DXGIGetDebugInterface from Dxgidebug.dll
                Debug layer will be aborted.");
                return;
            }
            hres = DXGIGetDebugInterface(&uuidof!IDXGIInfoQueue, cast(void**)&dxgiQueue);
            if(FAILED(hres))
            {
                ErrorHandler.showErrorMessage("DXGI Error", "Could not get the IDXGIInfoQueue interface. \nError: " ~
                Hip_D3D11_GetErrorMessage(hres) ~ "\nDebug layer will be aborted.");
            }
            else
                hasDebugAvailable = true;
        }
    }

    protected void initD3DRenderTargetView()
    {
        HRESULT res;
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
    protected void initD3DFowHWND(HWND hwnd, HipRendererConfig* config)
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

        // dsc.BufferDesc.RefreshRate.Numerator = 60;
        // dsc.BufferDesc.RefreshRate.Denominator = 1;

        uint createDeviceFlags = 0;
        static if(HIP_DEBUG)
            createDeviceFlags|= D3D11_CREATE_DEVICE_DEBUG;
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

        ID3D11Device device;
        IDXGISwapChain swapChain;
        auto res = D3D11CreateDeviceAndSwapChain(null,
                                                D3D_DRIVER_TYPE_HARDWARE,
                                                null,
                                                createDeviceFlags,
                                                levelArray.ptr,
                                                cast(uint)levelArray.length,
                                                D3D11_SDK_VERSION,
                                                &dsc,
                                                &swapChain,
                                                &device,
                                                &featureLevel,
                                                &_hip_d3d_context);

        

        swapChain.QueryInterface(&IID_IDXGISwapChain3, cast(void**)&_hip_d3d_swapChain);
        device.QueryInterface(&IID_ID3D11Device3, cast(void**)&_hip_d3d_device);


        if(ErrorHandler.assertErrorMessage(SUCCEEDED(res), "D3D11: Error creating device and swap chain", Hip_D3D11_GetErrorMessage(res)))
        {
            Hip_D3D11_Dispose();
            return;
        }

        initD3DDebug();
        initD3DRenderTargetView();
    }

    version(UWP)
    protected void initD3DForCoreWindow(HipExternalCoreWindow wnd, HipRendererConfig* config)
    {
        createD3DDevice();
        initD3DDebug();
        createD3DSwapChainForCoreWindow(wnd, config);
        initD3DRenderTargetView();
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
        return new Hip_D3D11_FrameBuffer(width,height);
    }
    public IHipVertexArrayImpl  createVertexArray()
    {
        return new Hip_D3D11_VertexArrayObject();
    }
    public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage)
    {
        return new Hip_D3D11_VertexBufferObject(size, usage);
    }
    public IHipIndexBufferImpl  createIndexBuffer(index_t count, HipBufferUsage usage)
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
        initD3DFowHWND(cast(HWND)wmInfo.info.win.window, &cfg);
        HipRenderer.rendererType = HipRendererType.D3D11;
        // setShader(createShader(true));

        return ErrorHandler.stopListeningForErrors();
    }

    version(dll)
    {
        public bool initExternal()
        {
            HipRendererConfig cfg;

            initD3DForCoreWindow(getCoreWindow(), &cfg);
            // HWND hwnd = getCoreWindowHWND();
            // if(hwnd == null)
            //     return false;
            // initD3DFowHWND(hwnd, &cfg);
            return true;
        }
    }

    public int queryMaxSupportedPixelShaderTextures()
    {
        return D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT;
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

    public void drawVertices(index_t count, uint offset = 0)
    {
        _hip_d3d_context.Draw(count, offset);
    }
    public void drawIndexed(index_t indicesSize, uint offset=0)
    {
        _hip_d3d_context.DrawIndexed(indicesSize, offset, 0);
    }
    public void drawRect(){}
    public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void drawRect(int x, int y, int w, int h){}
    public void draw(Texture t, int x, int y){}
    public void draw(Texture t, int x, int y, SDL_Rect* rect){}
    public void fillRect(int x, int y, int width, int height){}
    public void drawLine(int x1, int y1, int x2, int y2){}
    public void drawPixel(int x, int y ){}

    void clear(){}
    
    void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        float[4] color = [cast(float)r/255, cast(float)g/255, cast(float)b/255, cast(float)a/255];
        _hip_d3d_context.ClearRenderTargetView(_hip_d3d_mainRenderTarget, color.ptr);
    }

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

