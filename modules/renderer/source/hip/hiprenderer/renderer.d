/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.renderer;
public import hip.config.renderer;
public import hip.hiprenderer.shader;
public import hip.hiprenderer.vertex;
public import hip.hiprenderer.framebuffer;
public import hip.hiprenderer.viewport;
public import hip.api.renderer.texture;
public import hip.api.renderer.operations;
public import hip.api.graphics.color;
public import hip.api.renderer.core;
public import hip.api.renderer.shadervar;
import hip.windowing.window;
import hip.math.rect;
import hip.error.handler;
import hip.console.log;


private struct HipRendererResources
{
    IHipTexture[] textures;
    Shader[] shaders;
    IHipVertexArrayImpl[]  vertexArrays;
    IHipRendererBuffer[] buffers;
}

class HipRendererImplementation : IHipRenderer
{
    static struct Statistics
    {
        ulong drawCalls;
        ulong renderFrames;
    }
    protected Viewport currentViewport;
    protected Viewport mainViewport;
    protected IHipRendererImpl rendererImpl;
    protected HipRendererMode rendererMode;
    protected Statistics stats;
    public  HipWindow window = null;
    public  Shader currentShader;
    package HipRendererType rendererType = HipRendererType.None;

    public uint width, height;
    protected HipRendererConfig currentConfig;

    protected HipRendererResources res;
    protected bool depthTestingEnabled;
    protected HipDepthTestingFunction currentDepthTestFunction;

    protected IHipRendererBuffer quadIndexBuffer;

    public bool initialize (string confData, string confPath)
    {
        import hip.config.opts;
        import hip.data.ini;
        import hip.hiprenderer.initializer;
        HipINI ini = HipINI.parse(confData, confPath);
        HipRendererConfig cfg;
        rendererType = getRendererTypeFromVersion();
        int renderWidth = HIP_DEFAULT_WINDOW_SIZE[0];
        int renderHeight = HIP_DEFAULT_WINDOW_SIZE[1];
        string defaultRenderer = "OpenGL3";
        version(AppleOS) defaultRenderer = "Metal";
        if(!ini.configFound || !ini.noError)
        {
            import hip.util.string;
            if(!ini.configFound)
                logln("No renderer.conf found");
            if(!ini.noError)
            {
                logln("Renderer.conf parsing error");
                rawerror(BigString(ini.errors).toString);
            }
            hiplog("Defaulting renderer to "~defaultRenderer);
        }
        else
        {
            cfg.bufferingCount = ini.tryGet!ubyte("buffering.count", 2);
            cfg.multisamplingLevel = ini.tryGet!ubyte("multisampling.level", 0);
            cfg.fullscreen = ini.tryGet("screen.fullscreen", false);
            cfg.vsync = ini.tryGet("vsync.on", true);

            renderWidth = ini.tryGet("screen.width", renderWidth);
            renderHeight = ini.tryGet("screen.height", renderHeight);
            string renderer = ini.tryGet("screen.renderer", "GL3");
            rendererType = rendererFromString(renderer);
        }
        return initialize(getRendererWithFallback(rendererType), &cfg, renderWidth, renderHeight);
    }

    public Statistics getStatistics(){return stats;}
    version(dll) public bool initExternal(HipRendererType type, int windowWidth = -1, int windowHeight = -1)
    {
        import hip.hiprenderer.initializer;
        rendererType = type;
        if(windowWidth == -1)
            windowWidth = 1920;
        if(windowHeight == -1)
            windowHeight = 1080;
        return initialize(getRendererWithFallback(type), null, cast(uint)windowWidth, cast(uint)windowHeight, true);
    }

    private HipWindow createWindow(uint width, uint height)
    {
        HipWindow wnd = new HipWindow(width, height, HipWindowFlags.DEFAULT);
        version(Android){}
        else wnd.start();
        return wnd;
    }

    /**
    *   Populates a buffer with indices forming quads
    *   If the quadsCount is bigger than the existing one, throws since
    *   it probably can be set at compile time and it is easier to control like that
    */
    public IHipRendererBuffer getQuadIndexBuffer(size_t quadsCount)
    {
        if(!quadIndexBuffer)
        {
            import hip.util.array;
            quadIndexBuffer = createBuffer(quadsCount*index_t.sizeof*6, HipResourceUsage.Immutable, HipRendererBufferType.index);
            index_t[] output = uninitializedArray!(index_t[])(quadsCount*6);
            index_t index = 0;
            for(index_t i = 0; i < quadsCount; i++)
            {
                output[index+0] = cast(index_t)(i*4+0);
                output[index+1] = cast(index_t)(i*4+1);
                output[index+2] = cast(index_t)(i*4+2);

                output[index+3] = cast(index_t)(i*4+2);
                output[index+4] = cast(index_t)(i*4+3);
                output[index+5] = cast(index_t)(i*4+0);
                index+=6;
            }
            quadIndexBuffer.setData(output);
            import core.memory;
            GC.free(output.ptr);
        }

        return quadIndexBuffer;
    }

    public bool initialize (IHipRendererImpl impl, HipRendererConfig* config, uint width, uint height, bool isExternal = false)
    {
        ErrorHandler.startListeningForErrors("Renderer initialization");
        if(config != null)
            currentConfig = *config;
        currentConfig.logConfiguration();
        rendererImpl = impl;
        window = createWindow(width, height);
        ErrorHandler.assertErrorMessage(window !is null, "Error creating window", "Could not create Window");
        if(isExternal)
        {
            version(dll)
            {
                if(!rendererImpl.initExternal())
                {
                    ErrorHandler.showErrorMessage("Error Initializing Renderer", "Renderer could not initialize externally");
                    return false;
                }
            }
        }
        else
            rendererImpl.init(window);
        window.setVSyncActive(currentConfig.vsync);
        window.setFullscreen(currentConfig.fullscreen);
        window.show();
        foreach(err; window.errors)
            loglnError(err);

        setWindowSize(width, height);

        //After init
        import hip.config.opts;
        mainViewport = new Viewport(0,0, window.width, window.height);
        setViewport(mainViewport);
        setColor();
        HipRenderer.setRendererMode(HipRendererMode.triangles);

        return ErrorHandler.stopListeningForErrors();
    }
    public void setWindowSize(int width, int height) @nogc
    {
        assert(width > 0 && height > 0, "Window width and height must be greater than 0");
        logln("Changing window size to [", width, ", ",  height, "]");
        window.setSize(cast(uint)width, cast(uint)height);
        this.width  = width;
        this.height = height;
    }
    public HipRendererType getType(){return rendererType;}

    /**
     * Info is data that can't be changed from the renderer.
     */
    public HipRendererInfo getInfo()
    {
        return HipRendererInfo(
            getType,
            rendererImpl.getShaderVarMapper
        );
    }

    public HipRendererConfig getCurrentConfig(){return currentConfig;}
    public int getMaxSupportedShaderTextures(){return rendererImpl.queryMaxSupportedPixelShaderTextures();}


    public IHipTexture getTextureImplementation(HipResourceUsage usage = HipResourceUsage.Immutable)
    {
        res.textures~= rendererImpl.createTexture(usage);
        return res.textures[$-1];
    }

    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        rendererImpl.setColor(r,g,b,a);
    }

    public Viewport getCurrentViewport() @nogc {return currentViewport;}
    public void setViewport(Viewport v)
    {
        this.currentViewport = v;
        v.updateForWindowSize(width, height);
        rendererImpl.setViewport(v);
    }

    public void reinitialize()
    {
        version(Android)
        {
            foreach(tex; res.textures)
            {
                // (cast(Hip_GL3_Texture)tex).reload();
            }
            foreach(shader; res.shaders)
            {
                shader.reload();
            }
        }
    }

    public void setCamera()
    {

    }
    /**
    * Fixes the matrix order based on the config and renderer.
    * If the renderer is column and the config is row, it will tranpose
    */
    public T getMatrix(T)(auto ref T mat)
    {
        if(currentConfig.isMatrixRowMajor && !rendererImpl.isRowMajor())
            return mat.transpose();
        return mat;
    }

    Shader newShader()
    {
        res.shaders~= new Shader(rendererImpl.createShader());
        return res.shaders[$-1];
    }
    public Shader newShader(string shaderPath)
    {
        Shader ret = newShader();
        ret.loadShaderFromFile(shaderPath);
        return ret;
    }

    public HipFrameBuffer newFrameBuffer(int width, int height, Shader frameBufferShader = null)
    {
        return new HipFrameBuffer(rendererImpl.createFrameBuffer(width, height), width, height, frameBufferShader);
    }
    public IHipVertexArrayImpl  createVertexArray()
    {
        res.vertexArrays~= rendererImpl.createVertexArray();
        return res.vertexArrays[$-1];
    }

    public IHipRendererBuffer createBuffer(size_t size, HipResourceUsage usage, HipRendererBufferType type)
    {
        res.buffers~= rendererImpl.createBuffer(size, usage, type);
        return res.buffers[$-1];
    }
    public void setShader(Shader s)
    {
        currentShader = s;
        s.bind();
    }
    public bool hasErrorOccurred(out string err, string file = __FILE__, size_t line =__LINE__)
    {
        return rendererImpl.hasErrorOccurred(err, file, line);
    }

    public void exitOnError(string file = __FILE__, size_t line = __LINE__)
    {
        import hip.config.opts;
        import core.stdc.stdlib:exit;
        string err;
        if(hasErrorOccurred(err, file, line))
        {
            loglnError(err, file,":",line);
            static if(CustomRuntime)
                exit(-1);
            else
                throw new Error(err);
        }
    }

    public void begin()
    {

        rendererImpl.begin();
    }

    public void setErrorCheckingEnabled(bool enable = true)
    {
        rendererImpl.setErrorCheckingEnabled(enable);
    }

    public void setRendererMode(HipRendererMode mode)
    {
        if(mode != rendererMode)
        {
            rendererMode = mode;
            rendererImpl.setRendererMode(mode);
        }
    }
    public HipRendererMode getMode(){return rendererMode;}

    public void drawIndexed(index_t count, uint offset = 0)
    {
        rendererImpl.drawIndexed(count, offset);
        stats.drawCalls++;
    }
    public void drawIndexed(HipRendererMode mode, index_t count, uint offset = 0)
    {
        setRendererMode(mode);
        HipRenderer.drawIndexed(count, offset);
        stats.drawCalls++;
    }
    public void drawVertices(index_t count, uint offset = 0)
    {
        rendererImpl.drawVertices(count, offset);
    }
    public void drawVertices(HipRendererMode mode, index_t count, uint offset = 0)
    {
        rendererImpl.setRendererMode(mode);
        HipRenderer.drawVertices(count, offset);
    }

    public void end()
    {
        rendererImpl.end();
        foreach(sh; res.shaders) sh.onRenderFrameEnd();
        stats.drawCalls=0;
        stats.renderFrames++;
    }
    public void clear()
    {
        rendererImpl.clear();
        stats.drawCalls++;
    }
    public void clear(HipColorf color)
    {
        auto rgba = color.unpackRGBA;
        rendererImpl.clear(rgba[0], rgba[1], rgba[2], rgba[3]);
        stats.drawCalls++;
    }
    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        rendererImpl.clear(r,g,b,a);
        stats.drawCalls++;
    }
    HipDepthTestingFunction getDepthTestingFunction() const
    {
        return currentDepthTestFunction;
    }
    bool isDepthTestingEnabled() const
    {
        return depthTestingEnabled;
    }
    void setDepthTestingEnabled(bool enable)
    {
        rendererImpl.setDepthTestingEnabled(enable);
    }
    void setDepthTestingFunction(HipDepthTestingFunction fn)
    {
        rendererImpl.setDepthTestingFunction(fn);
        currentDepthTestFunction = fn;
    }

    void setStencilTestingEnabled(bool bEnable)
    {
        rendererImpl.setStencilTestingEnabled(bEnable);
    }
    void setStencilTestingMask(uint mask)
    {
        rendererImpl.setStencilTestingMask(mask);
    }
    void setColorMask(ubyte r, ubyte g, ubyte b, ubyte a)
    {
        rendererImpl.setColorMask(r,g,b,a);
    }
    void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask)
    {
        rendererImpl.setStencilTestingFunction(passFunc, reference, mask);
    }
    void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass)
    {
        rendererImpl.setStencilOperation(stencilFail, depthFail, stencilAndDephPass);
    }

    public void dispose()
    {
        rendererImpl.dispose();
        if(window !is null)
            window.exit();
        window = null;
    }
}


private __gshared HipRendererImplementation impl;
void PreInitializeHipRenderer()
{
    impl = new HipRendererImplementation();
    setHipRenderer(impl);
}


pragma(inline, true) HipRendererImplementation HipRenderer(){return impl;}

export extern(System) IHipRenderer HipRendererAPI()
{
    return HipRenderer;
}

void logConfiguration(HipRendererConfig config)
{
    import hip.console.log;
    with(config)
    {
        loglnInfo("Starting HipRenderer with configuration: ",
        "\nMultisamplingLevel: ", multisamplingLevel,
        "\nBufferingCount: ", bufferingCount,
        "\nFullscreen: ", fullscreen,
        "\nVsync: ", vsync? "activated" : "deactivated");
    }
}