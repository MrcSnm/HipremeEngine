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
public import hip.hiprenderer.config;
public import hip.hiprenderer.shader;
public import hip.hiprenderer.vertex;
public import hip.hiprenderer.framebuffer;
public import hip.hiprenderer.viewport;
public import hip.api.renderer.texture;
public import hip.api.renderer.operations;
public import hip.api.graphics.color;
public import hip.hiprenderer.shader.shadervar;
import hip.windowing.window;
import hip.math.rect;
import hip.error.handler;
import hip.console.log;

///Could later be moved to windowing
enum HipWindowMode
{
    WINDOWED,
    FULLSCREEN,
    BORDERLESS_FULLSCREEN
}

///Which API is being used
enum HipRendererType
{
    GL3,
    D3D11,
    METAL,
    NONE
}


/// Primitive which the renderer will use
enum HipRendererMode
{
    POINT,
    LINE,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP
}




//////////////////////////////////////////Metadata//////////////////////////////////////////

//Shaders
enum HipShaderInputLayout;
/**
*   Use this special UDA to say this type is only for accumulating stride and thus should not
*   be defined on shader
*/
enum HipShaderInputPadding;
/**
*   Declares that the struct is as VertexUniform block. 
*/
struct HipShaderVertexUniform
{
    /**
    *   This name is the base uniform name accessed when dealing with HLSL Api.
    *   i.e: Constant Buffer block name
    */
    string name; 
}
/**
*   Declares that the struct is as FragmentUniform block. 
*/
struct HipShaderFragmentUniform
{
    /**
    *   This name is the base uniform name accessed when dealing with HLSL Api.
    *   i.e: Constant Buffer block name
    */
    string name;
}

/**
*   Minimal interface for another API implementation
*/
interface IHipRendererImpl
{
    public bool init(HipWindow window);
    version(dll){public bool initExternal();}
    public bool isRowMajor();
    void setErrorCheckingEnabled(bool enable = true);
    public Shader createShader();
    public ShaderVar* createShaderVar(ShaderTypes shaderType, UniformType uniformType, string varName, size_t length);
    public IHipFrameBuffer createFrameBuffer(int width, int height);
    public IHipVertexArrayImpl  createVertexArray();
    public IHipVertexBufferImpl createVertexBuffer(size_t size, HipBufferUsage usage);
    public IHipIndexBufferImpl  createIndexBuffer(index_t count, HipBufferUsage usage);
    public IHipTexture  createTexture();
    public int queryMaxSupportedPixelShaderTextures();
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void setViewport(Viewport v);
    public bool setWindowMode(HipWindowMode mode);
    public void setDepthTestingEnabled(bool);
    public void setDepthTestingFunction(HipDepthTestingFunction);
    public void setStencilTestingEnabled(bool);
    public void setStencilTestingMask(uint mask);
    public void setColorMask(ubyte r, ubyte g, ubyte b, ubyte a);
    ///When pass func evaluates to true, then it is said to be passed
    public void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask);
    public void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass);
    public bool hasErrorOccurred(out string err, string line = __FILE__, size_t line =__LINE__);
    public void begin();
    public void setRendererMode(HipRendererMode mode);
    public void drawIndexed(index_t count, uint offset = 0);
    public void drawVertices(index_t count, uint offset = 0);
    public void end();
    public void clear();
    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void dispose();
}

private struct HipRendererResources
{
    IHipTexture[] textures;
    Shader[] shaders;
    IHipVertexArrayImpl[]  vertexArrays;
    IHipVertexBufferImpl[]  vertexBuffers;
    IHipIndexBufferImpl[]  indexBuffers;
}

class HipRenderer
{
    static struct Statistics 
    {
        ulong drawCalls;
        ulong renderFrames;
    }
    __gshared
    {
        protected Viewport currentViewport;
        protected Viewport mainViewport;
        protected IHipRendererImpl rendererImpl;
        protected HipRendererMode rendererMode;
        protected Statistics stats;
        public  HipWindow window = null;
        public  Shader currentShader;
        package HipRendererType rendererType = HipRendererType.NONE;

        public uint width, height;
        protected HipRendererConfig currentConfig;

        protected HipRendererResources res;
        protected bool depthTestingEnabled;
        protected HipDepthTestingFunction currentDepthTestFunction;
    }

    public static bool initialize (string confData, string confPath)
    {
        import hip.data.ini;
        import hip.hiprenderer.initializer;
        IniFile ini = IniFile.parse(confData, confPath);
        HipRendererConfig cfg;
        rendererType = getRendererTypeFromVersion();
        int renderWidth = 128;
        int renderHeight = 720;
        string defaultRenderer = "OpenGL3";
        version(AppleOS) defaultRenderer = "Metal";
        if(!ini.configFound || !ini.noError)
        {
            if(!ini.configFound)
                logln("No renderer.conf found");
            if(!ini.noError)
            {
                logln("Renderer.conf parsing error");
                rawerror(ini.errors);
            }
            hiplog("Defaulting renderer to "~defaultRenderer);
        }
        else
        {
            cfg.bufferingCount = ini.tryGet!ubyte("buffering.count", 2);
            cfg.multisamplingLevel = ini.tryGet!ubyte("multisampling.level", 0);
            cfg.fullscreen = ini.tryGet("screen.fullscreen", false);
            cfg.vsync = ini.tryGet("vsync.on", true);
            
            renderWidth = ini.tryGet("screen.width", 1280);
            renderHeight = ini.tryGet("screen.height", 720);
            string renderer = ini.tryGet("screen.renderer", "GL3");
            rendererType = rendererFromString(renderer);
        }
        return initialize(getRendererWithFallback(rendererType), &cfg, renderWidth, renderHeight);
    }

    public static Statistics getStatistics(){return stats;}
    version(dll) public static bool initExternal(HipRendererType type, int windowWidth = -1, int windowHeight = -1)
    {
        import hip.hiprenderer.initializer;
        rendererType = type;
        if(windowWidth == -1)
            windowWidth = 1920;
        if(windowHeight == -1)
            windowHeight = 1080;
        return initialize(getRendererWithFallback(type), null, cast(uint)windowWidth, cast(uint)windowHeight, true);
    }

    private static HipWindow createWindow(uint width, uint height)
    {
        HipWindow wnd = new HipWindow(width, height, HipWindowFlags.DEFAULT);
        version(Android){}
        else wnd.start();
        return wnd;
    }

    public static bool initialize (IHipRendererImpl impl, HipRendererConfig* config, uint width, uint height, bool isExternal = false)
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
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);

        return ErrorHandler.stopListeningForErrors();
    }
    public static void setWindowSize(int width, int height)
    {
        assert(width > 0 && height > 0, "Window width and height must be greater than 0");
        logln("Changing window size to ", [width, height]);
        window.setSize(cast(uint)width, cast(uint)height);
        HipRenderer.width  = width;
        HipRenderer.height = height;
    }
    public static HipRendererType getRendererType(){return rendererType;}
    public static HipRendererConfig getCurrentConfig(){return currentConfig;}
    public static int getMaxSupportedShaderTextures(){return rendererImpl.queryMaxSupportedPixelShaderTextures();}


    public static IHipTexture getTextureImplementation()
    {
        res.textures~= rendererImpl.createTexture();
        return res.textures[$-1];
    }

    public static void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        rendererImpl.setColor(r,g,b,a);
    }

    public static Viewport getCurrentViewport(){return currentViewport;}
    public static void setViewport(Viewport v)
    {
        this.currentViewport = v;
        v.updateForWindowSize(width, height);
        rendererImpl.setViewport(v);
    }

    public static void reinitialize()
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

    public static void setCamera()
    {
        
    }
    /**
    * Fixes the matrix order based on the config and renderer.
    * If the renderer is column and the config is row, it will tranpose
    */
    public static T getMatrix(T)(ref T mat)
    {
        if(currentConfig.isMatrixRowMajor && !rendererImpl.isRowMajor())
            return mat.transpose();
        return mat;
    }

    private static Shader _createShader()
    {
        res.shaders~= rendererImpl.createShader();
        return res.shaders[$-1];
    }
    public static ShaderVar* createShaderVar(ShaderTypes shaderType, UniformType uniformType, string varName, size_t length)
    {
        return rendererImpl.createShaderVar(shaderType, uniformType, varName, length);
    }


    public static Shader newShader(HipShaderPresets shaderPreset = HipShaderPresets.DEFAULT)
    {
        Shader ret = _createShader();
        ret.setFromPreset(shaderPreset);
        return ret;
    }
    public static Shader newShader(string vertexShader, string fragmentShader)
    {
        Shader ret = _createShader();
        ret.loadShadersFromFiles(vertexShader, fragmentShader);
        return ret;
    }
    public static HipFrameBuffer newFrameBuffer(int width, int height, Shader frameBufferShader = null)
    {
        return new HipFrameBuffer(rendererImpl.createFrameBuffer(width, height), width, height, frameBufferShader);
    }
    public static IHipVertexArrayImpl  createVertexArray()
    {
        res.vertexArrays~= rendererImpl.createVertexArray();
        return res.vertexArrays[$-1];
    }
    public static IHipVertexBufferImpl  createVertexBuffer(size_t size, HipBufferUsage usage)
    {
        res.vertexBuffers~= rendererImpl.createVertexBuffer(size, usage);
        return res.vertexBuffers[$-1];
    }
    public static IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        res.indexBuffers~= rendererImpl.createIndexBuffer(count, usage);
        return res.indexBuffers[$-1];
    }
    public static void setShader(Shader s)
    {
        currentShader = s;
        s.bind();
    }
    public static bool hasErrorOccurred(out string err, string file = __FILE__, size_t line =__LINE__)
    {
        return rendererImpl.hasErrorOccurred(err, file, line);
    }

    public static void exitOnError(string file = __FILE__, size_t line = __LINE__)
    {
        import core.stdc.stdlib:exit;
        string err;
        if(hasErrorOccurred(err, file, line))
        {
            loglnError(err, file,":",line);
            exit(-1);
        }
    }

    public static void begin()
    {

        rendererImpl.begin();
    }
    
    public static void setErrorCheckingEnabled(bool enable = true)
    {
        rendererImpl.setErrorCheckingEnabled(enable);
    }

    public static void setRendererMode(HipRendererMode mode)
    {
        rendererMode = mode;
        rendererImpl.setRendererMode(mode);
    }
    public static HipRendererMode getMode(){return rendererMode;}

    public static void drawIndexed(index_t count, uint offset = 0)
    {
        rendererImpl.drawIndexed(count, offset);
        stats.drawCalls++;
    }
    public static void drawIndexed(HipRendererMode mode, index_t count, uint offset = 0)
    {
        HipRendererMode currMode = rendererMode;
        if(mode != currMode) HipRenderer.setRendererMode(mode);
        HipRenderer.drawIndexed(count, offset);
        stats.drawCalls++;
        if(mode != currMode) HipRenderer.setRendererMode(currMode);
    }
    public static void drawVertices(index_t count, uint offset = 0)
    {
        rendererImpl.drawVertices(count, offset);
    }
    public static void drawVertices(HipRendererMode mode, index_t count, uint offset = 0)
    {
        rendererImpl.setRendererMode(mode);
        HipRenderer.drawVertices(count, offset);
    }

    public static void end()
    {
        rendererImpl.end();
        foreach(sh; res.shaders) sh.onRenderFrameEnd();
        stats.drawCalls=0;
        stats.renderFrames++;
    }
    public static void clear()
    {
        rendererImpl.clear();
        stats.drawCalls++;
    }
    public static void clear(HipColorf color)
    {
        auto rgba = color.unpackRGBA;
        rendererImpl.clear(rgba[0], rgba[1], rgba[2], rgba[3]);
        stats.drawCalls++;
    }
    public static void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        rendererImpl.clear(r,g,b,a);
        stats.drawCalls++;
    }
    static HipDepthTestingFunction getDepthTestingFunction()
    {
        return currentDepthTestFunction;
    }
    static bool isDepthTestingEnabled()
    {
        return depthTestingEnabled;
    }
    static void setDepthTestingEnabled(bool enable)
    {
        rendererImpl.setDepthTestingEnabled(enable);
    }
    static void setDepthTestingFunction(HipDepthTestingFunction fn)
    {
        rendererImpl.setDepthTestingFunction(fn);
        currentDepthTestFunction = fn;
    }

    static void setStencilTestingEnabled(bool bEnable)
    {
        rendererImpl.setStencilTestingEnabled(bEnable);
    }
    static void setStencilTestingMask(uint mask)
    {
        rendererImpl.setStencilTestingMask(mask);
    }
    static void setColorMask(ubyte r, ubyte g, ubyte b, ubyte a)
    {
        rendererImpl.setColorMask(r,g,b,a);
    }
    static void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask)
    {
        rendererImpl.setStencilTestingFunction(passFunc, reference, mask);
    }
    static void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass)
    {
        rendererImpl.setStencilOperation(stencilFail, depthFail, stencilAndDephPass);
    }
    
    public static void dispose()
    {
        rendererImpl.dispose();
        if(window !is null)
            window.exit();
        window = null;
    }
}