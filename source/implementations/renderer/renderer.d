module implementations.renderer.renderer;
import implementations.renderer.shader;
import graphics.texture;
import graphics.g2d.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
import bindbc.opengl;
import std.stdio:writeln;


public import implementations.renderer.backend.gl.renderer;

interface RendererImpl
{
    public bool init(SDL_Window* window, SDL_Renderer* renderer);
    public SDL_Window* createWindow();
    public SDL_Renderer* createRenderer(SDL_Window* window);
    public Shader createShader(bool createDefault = true);
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void setViewport(Viewport v);
    public void begin();
    public void end();
    public void render();
    public void clear();
    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void fillRect(int x, int y, int width, int height);
    public void drawLine(int x1, int y1, int x2, int y2);
    public void drawPixel(int x, int y); 
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

    public static bool init(RendererImpl impl)
    {
        rendererImpl = impl;
        ErrorHandler.startListeningForErrors("Renderer initialization");
        window = rendererImpl.createWindow();
        ErrorHandler.assertErrorMessage(window != null, "Error creating window", "Could not create SDL GL Window");
        renderer = rendererImpl.createRenderer(window);
        ErrorHandler.assertErrorMessage(renderer != null, "Error creating renderer", "Could not create SDL Renderer");
        rendererImpl.init(window, renderer);
        mainViewport = new Viewport(0,0,0,0);

        return ErrorHandler.stopListeningForErrors();
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
        s.setAsCurrent();
        currentShader = s;
    }
    public static void begin()
    {
        rendererImpl.begin();
    }

    public static void end()
    {
        rendererImpl.end();
    }
    public static void render()
    {
        rendererImpl.render();
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
        
    }
    public static void draw(Texture t, int x, int y, SDL_Rect* rect)
    {

    }
    public static void drawTriangle(){}
    public static void drawRect(){}
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
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        renderer = null;
        window = null;
        IMG_Quit();
        rendererImpl.dispose();
    }


}