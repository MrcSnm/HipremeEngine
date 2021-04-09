module implementations.renderer.renderer;
public import implementations.renderer.config;
public import implementations.renderer.shader;
public import implementations.renderer.texture;
import graphics.g2d.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
import bindbc.opengl;
import std.stdio:writeln;


public import implementations.renderer.backend.gl.renderer;

enum HipWindowMode
{
    WINDOWED,
    FULLSCREEN,
    BORDERLESS_FULLSCREEN
}
enum RendererType
{
    GL3,
    D3D11,
    SDL,
    NONE
}


interface RendererImpl
{
    public bool init(SDL_Window* window, SDL_Renderer* renderer);
    public SDL_Window* createWindow();
    public SDL_Renderer* createRenderer(SDL_Window* window);
    public Shader createShader(bool createDefault = true);
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void setViewport(Viewport v);
    public bool setWindowMode(HipWindowMode mode);
    public void begin();
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
    protected static Viewport currentViewport = null;
    protected static Viewport mainViewport = null;
    protected static RendererImpl rendererImpl;
    public static SDL_Renderer* renderer = null;
    public static SDL_Window* window = null;
    public static Shader currentShader;
    public static RendererType rendererType = RendererType.NONE;
    protected static HipRendererConfig currentConfig;


    public static bool init(RendererImpl impl, HipRendererConfig* config)
    {
        ErrorHandler.startListeningForErrors("Renderer initialization");
        if(config != null)
            currentConfig = *config;
        rendererImpl = impl;
        window = rendererImpl.createWindow();
        ErrorHandler.assertErrorMessage(window != null, "Error creating window", "Could not create SDL GL Window");
        // renderer = rendererImpl.createRenderer(window);
        // ErrorHandler.assertErrorMessage(renderer != null, "Error creating renderer", "Could not create SDL Renderer");
        rendererImpl.init(window, renderer);

        int w, h;
        SDL_GetWindowSize(window, &w, &h);
        mainViewport = new Viewport(0,0,w, h);
        setViewport(mainViewport);
        // setShader(rendererImpl.createShader(true));

        return ErrorHandler.stopListeningForErrors();
    }
    public static HipRendererConfig getCurrentConfig()
    {
        return currentConfig;
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
    public static Shader newShader(bool createDefault = true)
    {
        return rendererImpl.createShader(createDefault);
    }
    public static void setShader(Shader s)
    {
        currentShader = s;
        s.setAsCurrent();
    }
    public static void begin()
    {
        rendererImpl.begin();
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