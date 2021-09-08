/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hiprenderer.renderer;
public import hiprenderer.config;
public import hiprenderer.shader;
public import hiprenderer.texture;
public import hiprenderer.vertex;
import hiprenderer.framebuffer;
import hiprenderer.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
import console.log;
import core.stdc.stdlib:exit;

public import hiprenderer.backend.gl.renderer;

version(Windows)
{
    import hiprenderer.backend.d3d.renderer;
    import hiprenderer.backend.d3d.texture;
}
import hiprenderer.backend.gl.texture;
import hiprenderer.backend.sdl.texture;

enum HipWindowMode
{
    WINDOWED,
    FULLSCREEN,
    BORDERLESS_FULLSCREEN
}
enum HipRendererType
{
    GL3,
    D3D11,
    SDL,
    NONE
}

enum HipRendererMode
{
    POINT,
    LINE,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP
}

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

enum HipBlendEquation
{
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    MIN,
    MAX
}


interface IHipRendererImpl
{
    public bool init(SDL_Window* window, SDL_Renderer* renderer);
    version(dll){public bool initExternal();}
    public bool isRowMajor();
    public SDL_Window* createWindow(uint width, uint height);
    public SDL_Renderer* createRenderer(SDL_Window* window);
    public Shader createShader();
    public IHipFrameBuffer createFrameBuffer(int width, int height);
    public IHipVertexArrayImpl  createVertexArray();
    public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
    public IHipIndexBufferImpl  createIndexBuffer(index_t count, HipBufferUsage usage);
    public int queryMaxSupportedPixelShaderTextures();
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void setViewport(Viewport v);
    public bool setWindowMode(HipWindowMode mode);
    public bool hasErrorOccurred(out string err, string line = __FILE__, int line =__LINE__);
    public void begin();
    public void setRendererMode(HipRendererMode mode);
    public void drawIndexed(index_t count, uint offset = 0);
    public void drawVertices(index_t count, uint offset = 0);
    public void end();
    public void clear();
    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void fillRect(int x, int y, int width, int height);
    public void drawRect(int x, int y, int w, int h);
    public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
    public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
    public void drawLine(int x1, int y1, int x2, int y2);
    public void drawPixel(int x, int y); 
    public void draw(Texture t, int x, int y);
    public void draw(Texture t, int x, int y, SDL_Rect* rect);
    public void dispose();
}

class HipRenderer
{
    __gshared:
    protected static Viewport currentViewport = null;
    protected static Viewport mainViewport = null;
    protected static IHipRendererImpl rendererImpl;
    public static SDL_Renderer* renderer = null;
    public static SDL_Window* window = null;
    public static Shader currentShader;
    package static HipRendererType rendererType = HipRendererType.NONE;

    public static uint width, height;
    protected static HipRendererConfig currentConfig;

    public static bool init(string confPath)
    {
        import data.ini;
        IniFile ini = IniFile.parse(confPath);
        HipRendererConfig cfg;
        if(ini.configFound && ini.noError)
        {
            cfg.bufferingCount = ini.tryGet!ubyte("buffering.count", 2);
            cfg.multisamplingLevel = ini.tryGet!ubyte("multisampling.level", 0);
            cfg.vsync = ini.tryGet("vsync.on", true);
            
            int width = ini.tryGet("screen.width", 1280);
            int height = ini.tryGet("screen.height", 720);
            string renderer = ini.tryGet("screen.renderer", "GL3");

            switch(renderer)
            {
                case "GL3":
                    return init(new Hip_GL3Renderer(), &cfg, width, height);
                case "D3D11":
                    version(Windows)
                        return init(new Hip_D3D11_Renderer(), &cfg, width, height);
                    else
                        return false;
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
        return init(new Hip_GL3Renderer(), &cfg, 1280, 720);
    }

    version(dll) public static bool initExternal(HipRendererType type)
    {
        import hiprenderer.backend.sdl.sdlrenderer;
        HipRenderer.rendererType = type;
        final switch(type)
        {
            case HipRendererType.D3D11:
                version(Windows){rendererImpl = new Hip_D3D11_Renderer();break;}
                else{return false;}
            case HipRendererType.GL3:
                rendererImpl = new Hip_GL3Renderer();
                break;
            case HipRendererType.SDL:
                rendererImpl = new Hip_SDL_Renderer();
                break;
            case HipRendererType.NONE:
                return false;
        }
        bool ret = rendererImpl.initExternal();
        afterInit();
        return ret;
    }
    private static afterInit()
    {
        mainViewport = new Viewport(0,0,800, 600);
        setViewport(mainViewport);
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
    }

    public static bool init(IHipRendererImpl impl, HipRendererConfig* config, uint width, uint height)
    {
        ErrorHandler.startListeningForErrors("Renderer initialization");
        if(config != null)
            currentConfig = *config;
        rendererImpl = impl;
        window = rendererImpl.createWindow(width, height);
        ErrorHandler.assertErrorMessage(window != null, "Error creating window", "Could not create SDL GL Window");
        // renderer = rendererImpl.createRenderer(window);
        // ErrorHandler.assertErrorMessage(renderer != null, "Error creating renderer", "Could not create SDL Renderer");
        rendererImpl.init(window, renderer);
        HipRenderer.width = width;
        HipRenderer.height = height;
        int w, h;
        SDL_GetWindowSize(window, &w, &h);
        afterInit();

        return ErrorHandler.stopListeningForErrors();
    }
    public static HipRendererType getRendererType(){return rendererType;}
    public static HipRendererConfig getCurrentConfig(){return currentConfig;}
    public static int getMaxSupportedShaderTextures(){return rendererImpl.queryMaxSupportedPixelShaderTextures();}
    public static ITexture getTextureImplementation()
    {
        
        switch(HipRenderer.getRendererType())
        {
            case HipRendererType.GL3:
                return new Hip_GL3_Texture();
            case HipRendererType.D3D11:
                version(Windows)
                    return new Hip_D3D11_Texture();
                else
                    return null;
            case HipRendererType.SDL:
                return new Hip_SDL_Texture();
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
    public static Viewport getCurrentViewport(){return currentViewport;}
    public static void setViewport(Viewport v)
    {
        this.currentViewport = v;
        rendererImpl.setViewport(v);
        // SDL_RenderSetViewport(renderer, &v.bounds);
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
    }
    public static bool hasErrorOccurred(out string err, string file = __FILE__, int line =__LINE__)
    {
        return rendererImpl.hasErrorOccurred(err, file, line);
    }

    public static void exitOnError(string file = __FILE__, int line = __LINE__)
    {
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
    }

    public static void setRendererMode(HipRendererMode mode)
    {
        rendererImpl.setRendererMode(mode);
        HipRenderer.exitOnError();
    }

    public static void drawIndexed(index_t count, uint offset = 0)
    {
        rendererImpl.drawIndexed(count, offset);
        HipRenderer.exitOnError();
    }
    public static void drawIndexed(HipRendererMode mode, index_t count, uint offset = 0)
    {
        HipRenderer.setRendererMode(mode);
        HipRenderer.drawIndexed(count, offset);
    }
    public static void drawVertices(index_t count, uint offset = 0)
    {
        rendererImpl.drawVertices(count, offset);
        HipRenderer.exitOnError();
    }
    public static void drawVertices(HipRendererMode mode, index_t count, uint offset = 0)
    {
        rendererImpl.setRendererMode(mode);
        rendererImpl.drawVertices(count, offset);
    }

    public static void end()
    {
        rendererImpl.end();
    }
    public static void clear()
    {
        rendererImpl.clear();
    }
    public static void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        rendererImpl.clear(r,g,b,a);
    }
    public static void fillRect(int x, int y, int width, int height)
    {
        rendererImpl.fillRect(x,y,width,height);
    }
    public static void draw(Texture t, int x, int y)
    {
        rendererImpl.draw(t, x, y);
    }
    public static void draw(Texture t, int x, int y, SDL_Rect* rect)
    {
        rendererImpl.draw(t,x, y,rect);
    }
    public static void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        rendererImpl.drawTriangle(x1,y1,x2,y2,x3,y3);
    }
    public static void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        rendererImpl.fillTriangle(x1,y1,x2,y2,x3,y3);
    }
    public static void drawRect(int x, int y, int w, int h)
    {
        rendererImpl.drawRect(x,y,w,h);
    }
    public static void drawLine(int x1, int y1, int x2, int y2)
    {
        rendererImpl.drawLine(x1,y1,x2,y2);
    }
    public static void drawPixel(int x, int y)
    {
        rendererImpl.drawPixel(x,y);
    }
    public static void dispose()
    {
        rendererImpl.dispose();
        if(renderer != null)
            SDL_DestroyRenderer(renderer);
        if(window != null)
            SDL_DestroyWindow(window);
        renderer = null;
        window = null;
        IMG_Quit();
    }


}