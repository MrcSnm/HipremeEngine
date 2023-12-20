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

public import hip.hiprenderer.backend.gl.glrenderer;

version(Windows)
{
    import hip.hiprenderer.backend.d3d.d3drenderer;
    import hip.hiprenderer.backend.d3d.d3dtexture;
}
version(AppleOS)
{
    import hip.hiprenderer.backend.metal.mtlrenderer;
    import hip.hiprenderer.backend.metal.mtltexture;
}

version(dll){} else version = RendererConfigFile;
import hip.hiprenderer.backend.gl.gltexture;

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

    version(RendererConfigFile)
    public static bool initialize (string confData, string confPath)
    {
        import hip.data.ini;
        IniFile ini = IniFile.parse(confData, confPath);
        HipRendererConfig cfg;
        if(ini.configFound && ini.noError)
        {
            cfg.bufferingCount = ini.tryGet!ubyte("buffering.count", 2);
            cfg.multisamplingLevel = ini.tryGet!ubyte("multisampling.level", 0);
            cfg.fullscreen = ini.tryGet("screen.fullscreen", false);
            cfg.vsync = ini.tryGet("vsync.on", true);
            
            int width = ini.tryGet("screen.width", 1280);
            int height = ini.tryGet("screen.height", 720);
            string renderer = ini.tryGet("screen.renderer", "GL3");

            switch(renderer)
            {
                case "GL3":
                    version(OpenGL)
                    {
                        rendererType = HipRendererType.GL3;
                        return initialize(new Hip_GL3Renderer(), &cfg, width, height);
                    }
                    else version(DirectX)
                    {
                        logln("OpenGL wasn't included in this build, using Direct3D");
                        goto case "D3D11";
                    }
                    else version(AppleOS)
                    {
                        logln("OpenGL wasn't included in this build, using Metal");
                        goto case "METAL";
                    }
                case "D3D11":
                    version(DirectX)
                    {
                        rendererType = HipRendererType.D3D11;
                        return initialize(new Hip_D3D11_Renderer(), &cfg, width, height);
                    }
                    else version(OpenGL)
                    {
                        logln("Direct3D wasn't included in this build, using OpenGL 3");
                        goto case "GL3";
                    }
                    else version(AppleOS)
                    {
                        logln("Direct3D wasn't included in this build, using Metal");
                        goto case "METAL";
                    }
                case "METAL":
                    version(AppleOS)
                    {
                        rendererType = HipRendererType.METAL;
                        return initialize(new HipMTLRenderer(), &cfg, width, height);
                    }
                    else version(OpenGL)
                    {
                        logln("Metal wasn't included in this build, using OpenGL 3");
                        goto case "GL3";
                    }
                    else version(DirectX)
                    {
                        logln("Metal wasn't included in this build, using Direct3D");
                        goto case "D3D11";
                    }
                default:
                    logln("Invalid renderer?" , renderer, " ' oh my freakin goodness");
                    ErrorHandler.showErrorMessage("Invalid renderer '"~renderer~"'",
                    `
                        Available renderers:
                            GL3
                            D3D11
                            METAL
                        Starting with GL3
                    `);
                    goto case "GL3";
            }
        }
        else
        {
            string defaultRenderer = "OpenGL3";
            version(AppleOS) defaultRenderer = "Metal";
            if(!ini.configFound)
                logln("No renderer.conf found");
            if(!ini.noError)
            {
                logln("Renderer.conf parsing error");
                rawerror(ini.errors);
            }
            hiplog("Defaulting renderer to "~defaultRenderer);
        }
        return initialize(getRendererFromVersion(rendererType), &cfg, 1280, 720);
    }

    public static Statistics getStatistics(){return stats;}
    private static IHipRendererImpl getRendererFromVersion(out HipRendererType type)
    {
        version(OpenGL)
        {
            type = HipRendererType.GL3;
            return new Hip_GL3Renderer();
        }
        else version(DirectX)
        {
            type = HipRendererType.D3D11;
            return new Hip_D3D11_Renderer();
        }
        else version(AppleOS)
        {
            type = HipRendererType.METAL;
            return new HipMTLRenderer();
        }
        else
        {
            type = HipRendererType.NONE;
            return null;
        }
    }
    version(dll) private static IHipRendererImpl getRenderer(ref HipRendererType type)
    {
        final switch(type)
        {
            case HipRendererType.D3D11:
                version(DirectX) return new Hip_D3D11_Renderer();
                            else return getRendererFromVersion(type);
            case HipRendererType.GL3:
                version(OpenGL) return new Hip_GL3Renderer();
                            else return getRendererFromVersion(type);
            case HipRendererType.METAL:
                version(AppleOS) return new HipMTLRenderer();
                            else return getRendererFromVersion(type);
            case HipRendererType.NONE:
                return null;
        }
    }

    version(dll) public static bool initExternal(HipRendererType type, int windowWidth = -1, int windowHeight = -1)
    {
        rendererImpl = getRenderer(type);
        HipRenderer.rendererType = type;
        logln("Initialized renderer.: ", rendererType, " renderer? ", rendererImpl !is null);
        bool ret = rendererImpl.initExternal();
        if(!ret)
            ErrorHandler.showErrorMessage("Error Initializing Renderer", "Renderer could not initialize externally");

        if(windowWidth == -1)
            windowWidth = 1920;
        if(windowHeight == -1)
            windowHeight = 1080;

        window = createWindow(windowWidth, windowHeight);
        HipRenderer.width = window.width;
        HipRenderer.height = window.height;
        afterInit();
        return ret;
    }
    private static afterInit()
    {
        import hip.config.opts;
        mainViewport = new Viewport(0,0, window.width, window.height);
        setViewport(mainViewport);
        setColor();
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
    }

    private static HipWindow createWindow(uint width, uint height)
    {
        HipWindow wnd = new HipWindow(width, height, HipWindowFlags.DEFAULT);
        version(Android){}
        else wnd.start();
        return wnd;
    }

    public static bool initialize (IHipRendererImpl impl, HipRendererConfig* config, uint width, uint height)
    {
        ErrorHandler.startListeningForErrors("Renderer initialization");
        if(config != null)
            currentConfig = *config;
        currentConfig.logConfiguration();
        rendererImpl = impl;
        window = createWindow(width, height);
        ErrorHandler.assertErrorMessage(window !is null, "Error creating window", "Could not create Window");
        rendererImpl.init(window);
        window.setVSyncActive(currentConfig.vsync);
        window.setFullscreen(currentConfig.fullscreen);
        window.show();
        foreach(err; window.errors)
            loglnError(err);
        
        setWindowSize(width, height);
        afterInit();
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


    private static IHipTexture _getTextureImplementation()
    {
        return rendererImpl.createTexture();
    }
    public static IHipTexture getTextureImplementation()
    {
        res.textures~= _getTextureImplementation();
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
                (cast(Hip_GL3_Texture)tex).reload();
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