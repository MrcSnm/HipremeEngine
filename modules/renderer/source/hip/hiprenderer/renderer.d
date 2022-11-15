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

/// Those are fairly known functions in the graphics programming world
enum HipBlendFunction
{
    ZERO,
    ONE,
    SRC_COLOR,
    ONE_MINUS_SRC_COLOR,
    DST_COLOR,
    ONE_MINUS_DST_COLOR,
    SRC_ALPHA,
    ONE_MINUS_SRC_ALPHA,
    DST_ALPHA,
    ONE_MINUST_DST_ALPHA,
    CONSTANT_COLOR,
    ONE_MINUS_CONSTANT_COLOR,
    CONSTANT_ALPHA,
    ONE_MINUS_CONSTANT_ALPHA,
}

/** 
 * The equation is made by:
 * HipBlendEquation(HipBlendFunction, HipBlendFunction)
 */
enum HipBlendEquation
{
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    MIN,
    MAX
}

//////////////////////////////////////////Metadata//////////////////////////////////////////

//Shaders
enum HipShaderInputLayout;
enum HipVertexVar;
enum HipFragmentVar;
alias HipPixelVar = HipFragmentVar;


/**
*   Minimal interface for another API implementation
*/
interface IHipRendererImpl
{
    public bool init(HipWindow window);
    version(dll){public bool initExternal();}
    public bool isRowMajor();
    public HipWindow createWindow(uint width, uint height);
    public Shader createShader();
    public IHipFrameBuffer createFrameBuffer(int width, int height);
    public IHipVertexArrayImpl  createVertexArray();
    public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
    public IHipIndexBufferImpl  createIndexBuffer(index_t count, HipBufferUsage usage);
    public int queryMaxSupportedPixelShaderTextures();
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void setViewport(Viewport v);
    public bool setWindowMode(HipWindowMode mode);
    public bool isBlendingEnabled() const;
    public void setBlendFunction(HipBlendFunction src, HipBlendFunction dst);
    public void setBlendingEquation(HipBlendEquation eq);
    public bool hasErrorOccurred(out string err, string line = __FILE__, int line =__LINE__);
    public void begin();
    public void setRendererMode(HipRendererMode mode);
    public void drawIndexed(index_t count, uint offset = 0);
    public void drawVertices(index_t count, uint offset = 0);
    public void end();
    public void clear();
    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void dispose();
}

class HipRenderer
{
    static struct Statistics 
    {
        ulong drawCalls;
    }
    __gshared:
    protected static Viewport currentViewport;
    protected static Viewport mainViewport;
    protected static IHipRendererImpl rendererImpl;
    protected static HipRendererMode rendererMode;
    protected Statistics stats;
    public static HipWindow window = null;
    public static Shader currentShader;
    package static HipRendererType rendererType = HipRendererType.NONE;

    public static uint width, height;
    protected static HipRendererConfig currentConfig;

    version(Desktop)
    public static bool init (string confData, string confPath)
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
                    return init(new Hip_GL3Renderer(), &cfg, width, height);
                case "D3D11":
                    version(DirectX)
                    {
                        return init(new Hip_D3D11_Renderer(), &cfg, width, height);
                    }
                    else
                    {
                        logln("Direct3D wasn't included in this build, using OpenGL 3");
                        goto case "GL3";
                    }
                default:
                    ErrorHandler.showErrorMessage("Invalid renderer '"~renderer~"'",
                    `
                        Available renderers:
                            GL3
                            D3D11
                        Starting with GL3
                    `);
                    goto case "GL3";
            }
        }
        else
        {
            if(!ini.configFound)
                logln("No renderer.conf found, defaulting renderer to OpenGL3");
            else
            {
                logln("Renderer.conf parsing error, defaulting renderer to OpenGL3");
                rawlog(ini.errors);
            }
        }
        return init(new Hip_GL3Renderer(), &cfg, 1280, 720);
    }
    version(dll) private static IHipRendererImpl getRenderer(ref HipRendererType type)
    {
        final switch(type)
        {
            case HipRendererType.D3D11:
                version(DirectX)
                    return new Hip_D3D11_Renderer();
                else version(OpenGL)
                {
                    type = HipRendererType.GL3;
                    return new Hip_GL3Renderer();
                }
                else
                {
                    type = HipRendererType.NONE;
                    return null;
                }
            case HipRendererType.GL3:
                version(OpenGL)
                    return new Hip_GL3Renderer();
                else version(DirectX)
                {
                    type = HipRendererType.D3D11;
                    return new Hip_D3D11_Renderer();
                }
                else
                {
                    type = HipRendererType.NONE;
                    return null;
                }
            case HipRendererType.NONE:
                return null;
        }
    }

    version(dll) public static bool initExternal(HipRendererType type)
    {
        rendererImpl = getRenderer(type);
        HipRenderer.rendererType = type;
        bool ret = rendererImpl.initExternal();
        if(!ret)
            ErrorHandler.showErrorMessage("Error Initializing Renderer", "Renderer could not initialize externally");

        window = new HipWindow(800, 600, HipWindowFlags.DEFAULT);
        HipRenderer.width = 800;
        HipRenderer.height = 600;
        afterInit();
        return ret;
        // return ret;
    }
    private static afterInit()
    {
        import hip.config.opts;
        mainViewport = new Viewport(0,0, window.width, window.height);
        setViewport(mainViewport);
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        static if(HIP_ALPHA_BLEND_DEFAULT)
        {
            activateAlphaBlending();
        }
    }

    public static bool init (IHipRendererImpl impl, HipRendererConfig* config, uint width, uint height)
    {
        ErrorHandler.startListeningForErrors("Renderer initialization");
        if(config != null)
            currentConfig = *config;
        currentConfig.logConfiguration();
        rendererImpl = impl;
        window = rendererImpl.createWindow(width, height);
        ErrorHandler.assertErrorMessage(window !is null, "Error creating window", "Could not create Window");
        rendererImpl.init(window);
        window.setVSyncActive(currentConfig.vsync);
        window.setFullscreen(currentConfig.fullscreen);
        window.show();
        foreach(err; window.errors)
            loglnError(err);
        HipRenderer.width = width;
        HipRenderer.height = height;
        int w, h;
        w = window.width;
        h = window.height;
        afterInit();

        return ErrorHandler.stopListeningForErrors();
    }
    public static HipRendererType getRendererType(){return rendererType;}
    public static HipRendererConfig getCurrentConfig(){return currentConfig;}
    public static int getMaxSupportedShaderTextures(){return rendererImpl.queryMaxSupportedPixelShaderTextures();}
    public static IHipTexture getTextureImplementation()
    {
        switch(HipRenderer.getRendererType())
        {
            case HipRendererType.GL3:
                version(OpenGL)
                    return new Hip_GL3_Texture();
                else
                    return null;
            case HipRendererType.D3D11:
                version(DirectX)
                    return new Hip_D3D11_Texture();
                else
                    return null;
            default:
                ErrorHandler.showErrorMessage("No renderer implementation active",
                "Can't create a texture without a renderer implementation active");
                return null;
        }
    }

    public static void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        rendererImpl.setColor(r,g,b,a);
    }

    public static bool isBlendingEnabled()
    {
        return rendererImpl.isBlendingEnabled();
    }
    public static void setBlendFunction(HipBlendFunction sourceFunction, HipBlendFunction destinationFunction)
    {
        rendererImpl.setBlendFunction(sourceFunction, destinationFunction);
    }

    static final void activateAlphaBlending()
    {
        rendererImpl.setBlendFunction(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA);
    }

    public static Viewport getCurrentViewport(){return currentViewport;}
    public static void setViewport(Viewport v)
    {
        this.currentViewport = v;
        v.updateForWindowSize(width, height);
        rendererImpl.setViewport(v);
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
    public static Shader newShader(HipShaderPresets shaderPreset = HipShaderPresets.DEFAULT)
    {
        Shader ret = rendererImpl.createShader();
        ret.setFromPreset(shaderPreset);
        return ret;
    }
    public static Shader newShader(string vertexShader, string fragmentShader)
    {
        Shader ret = rendererImpl.createShader();
        ret.loadShadersFromFiles(vertexShader, fragmentShader);
        return ret;
    }
    public static HipFrameBuffer newFrameBuffer(int width, int height, Shader frameBufferShader = null)
    {
        return new HipFrameBuffer(rendererImpl.createFrameBuffer(width, height), width, height, frameBufferShader);
    }
    public static IHipVertexArrayImpl  createVertexArray()
    {
        return rendererImpl.createVertexArray();
    }
    public static IHipVertexBufferImpl  createVertexBuffer(ulong size, HipBufferUsage usage)
    {
        return rendererImpl.createVertexBuffer(size, usage);
    }
    public static IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        return rendererImpl.createIndexBuffer(count, usage);
    }
    public static void setShader(Shader s)
    {
        currentShader = s;
        s.bind();
        HipRenderer.exitOnError();
    }
    public static bool hasErrorOccurred(out string err, string file = __FILE__, int line =__LINE__)
    {
        return rendererImpl.hasErrorOccurred(err, file, line);
    }

    public static void exitOnError(string file = __FILE__, int line = __LINE__)
    {
        import core.stdc.stdlib:exit;
        string err;
        if(hasErrorOccurred(err, file, line))
        {
            logln(err, file,":",line);
            exit(-1);
        }
    }

    public static void begin()
    {
        rendererImpl.begin();
        HipRenderer.exitOnError();
    }

    public static void setRendererMode(HipRendererMode mode)
    {
        rendererMode = mode;
        rendererImpl.setRendererMode(mode);
        HipRenderer.exitOnError();
        stats.drawCalls++;
    }
    public static HipRendererMode getMode(){return rendererMode;}

    public static void drawIndexed(index_t count, uint offset = 0)
    {
        rendererImpl.drawIndexed(count, offset);
        HipRenderer.exitOnError();
        stats.drawCalls++;
    }
    public static void drawIndexed(HipRendererMode mode, index_t count, uint offset = 0)
    {
        HipRenderer.setRendererMode(mode);
        HipRenderer.drawIndexed(count, offset);
        stats.drawCalls++;
    }
    public static void drawVertices(index_t count, uint offset = 0)
    {
        rendererImpl.drawVertices(count, offset);
        HipRenderer.exitOnError();
    }
    public static void drawVertices(HipRendererMode mode, index_t count, uint offset = 0)
    {
        rendererImpl.setRendererMode(mode);
        HipRenderer.drawVertices(count, offset);
    }

    public static void end()
    {
        rendererImpl.end();
        stats.drawCalls=0;
    }
    public static void clear()
    {
        rendererImpl.clear();
        stats.drawCalls++;
    }
    public static void clear(HipColor color)
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
    
    public static void dispose()
    {
        rendererImpl.dispose();
        if(window !is null)
            window.exit();
        window = null;
    }
}