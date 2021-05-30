module implementations.renderer.backend.sdl.sdlrenderer;
import implementations.renderer.backend.sdl.texture;
import implementations.renderer.renderer;
import graphics.g2d.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
import bindbc.opengl;
import std.stdio:writeln;

private SDL_Window* createSDL_GL_Window()
{
	SDL_GL_LoadLibrary(null);
	//Set GL Version
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_ACCELERATED_VISUAL, 1);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MINOR_VERSION, 5);
	//Create window type
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_STENCIL_SIZE, 8);
	alias f = SDL_WindowFlags;
	SDL_WindowFlags flags = (f.SDL_WINDOW_OPENGL | f.SDL_WINDOW_RESIZABLE | f.SDL_WINDOW_ALLOW_HIGHDPI);

	SDL_Window* window = SDL_CreateWindow("GL Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, flags);
	SDL_GLContext ctx = SDL_GL_CreateContext(window);
	SDL_GL_MakeCurrent(window, ctx);
	GLSupport ver = loadOpenGL();
	writeln(ver);
	SDL_GL_SetSwapInterval(1);
	return window;
}

/**
*   While this class is at implementation and don't have a backend folders,
*   it actually does not requires a backend(as it is using SDL for now), but
*   the structure could be changed at any time for supporting a new platform
*   that SDL does not support
*/
public class Hip_SDL_Renderer : IHipRendererImpl
{
    private Viewport currentViewport = null;
    private Viewport mainViewport = null;
    public SDL_Renderer* renderer = null;
    public SDL_Window* window = null;

    SDL_Window* createWindow()
    {
        return SDL_CreateWindow("SDL Window",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        800, 600,
        SDL_WindowFlags.SDL_WINDOW_OPENGL | SDL_WindowFlags.SDL_WINDOW_RESIZABLE
        );
    }
    SDL_Renderer* createRenderer(SDL_Window* window)
    {
        return SDL_CreateRenderer(window, 0, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
    }
    public bool init(SDL_Window* window, SDL_Renderer* renderer)
    {
        this.window = window;
        this.renderer = renderer;
        setColor();
        mainViewport = new Viewport(0,0,0,0);
        currentViewport = mainViewport;
        return ErrorHandler.stopListeningForErrors();
    }

    Shader createShader(bool createDefault = true){return null;}
    public IHipVertexArrayImpl  createVertexArray(){return null;}
    public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage){return null;}
    public IHipIndexBufferImpl  createIndexBuffer(uint count, HipBufferUsage usage){return null;}
    public bool setWindowMode(HipWindowMode mode){return false;}
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
    }
    public Viewport getCurrentViewport(){return this.currentViewport;}

    public void setViewport(Viewport v)
    {
        this.currentViewport = v;
        SDL_RenderSetViewport(renderer, &v.bounds);
    }
    public bool hasErrorOccurred(out string err, string file = __FILE__, int line = __LINE__)
    {
        return false;
    }

    public void draw(Texture t, int x, int y){draw(t,x,y, null);}
    public void draw(Texture t, int x, int y, SDL_Rect* clip = null)
    {
        SDL_Rect dest = SDL_Rect(x, y,t.width,t.height);
        if(clip != null)
        {
            dest.w=clip.w;
            dest.h=clip.h;
        }
        SDL_RenderCopy(renderer, (cast(Hip_SDL_Texture)t).data, clip, &dest);
    }
    public void begin(){}
    public void setRendererMode(HipRendererMode mode){}
    public void drawIndexed(uint count, uint offset =0){}
    public void drawVertices(uint count, uint offset =0){}

    pragma(inline, true)
    public void end()
    {
        // SDL_GL_SwapWindow(window);
        SDL_RenderPresent(renderer);
    }
    public void clear()
    {
        setColor(255,255,255,255);
        SDL_RenderClear(renderer);
    }
    pragma(inline, true)
    public void clear(ubyte r, ubyte g, ubyte b, ubyte a)
    {
        setColor(r,g,b,a);
        SDL_RenderClear(renderer);
    }

    public void fillRect(int x, int y, int width, int height)
    {
        static SDL_Rect rec;
        rec.x = x;
        rec.y = y;
        rec.w = width;
        rec.h = height;
        SDL_RenderFillRect(renderer, &rec);
    }
    public void drawRect(int x, int y, int width, int height)
    {
        static SDL_Rect rec;
        rec.x=x;
        rec.y=y;
        rec.w=width;
        rec.h=height;
        SDL_RenderDrawRect(renderer, &rec);
    }
    public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void drawLine(int x1, int y1, int x2, int y2)
    {
        SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    }
    public void drawPixel(int x, int y)
    {
        SDL_RenderDrawPoint(renderer, x, y);
    }

    public void dispose()
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        renderer = null;
        window = null;
        IMG_Quit();
    }
}