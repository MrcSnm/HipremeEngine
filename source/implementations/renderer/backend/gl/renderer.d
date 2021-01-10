module implementations.renderer.backend.gl.renderer;
import implementations.renderer.shader;
import graphics.texture;
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
public static class Renderer
{
    protected static Viewport currentViewport = null;
    protected static Viewport mainViewport = null;

    protected static uint[] vertexBuffersIDS;
    protected static uint currentVertexBufferIndex;


    protected static immutable uint[6] rectElementBuffer = [
        0, 1, 2,
        2, 3, 1
    ];

    public static SDL_Renderer* renderer = null;
    public static SDL_Window* window = null;

    public static Shader currentShader;

    public static bool init(uint reserveAmount=1024)
    {
        vertexBuffersIDS.reserve(reserveAmount);
        ErrorHandler.startListeningForErrors("Renderer initialization");
        window = createSDL_GL_Window();
        ErrorHandler.assertErrorMessage(window != null, "Error creating window", "Could not create SDL GL Window");
        renderer = SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
        ErrorHandler.assertErrorMessage(renderer != null, "Error creating renderer", "Could not create SDL Renderer");
        setColor();
        mainViewport = new Viewport(0,0,0,0);
        currentViewport = mainViewport;
        setShader(new Shader());
        return ErrorHandler.stopListeningForErrors();
    }

    public static void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
    }
    public static Viewport getCurrentViewport(){return this.currentViewport;}

    public static void setViewport(Viewport v)
    {
        this.currentViewport = v;
        SDL_RenderSetViewport(renderer, &v.bounds);
    }

    protected static uint getFreeVertexBuffer()
    {
        if(vertexBuffersIDS.length >= currentVertexBufferIndex)
        {
            uint buf; 
            glGenBuffers(1, &buf);
            vertexBuffersIDS~=buf;
        }
        uint ret = vertexBuffersIDS[currentVertexBufferIndex];
        currentVertexBufferIndex++;
        return ret;
    }

    /**
    *   This function is used to control the internal state for creating vertex buffers
    */
    public static void begin()
    {
        currentVertexBufferIndex = 0;       
    }

    public static void setShader(Shader s)
    {
        s.setAsCurrent();
        currentShader = s;
    }
    /**
    */
    public static void end()
    {
        SDL_GL_SwapWindow(window);
    }

    public static void draw(Texture t, int x, int y, SDL_Rect* clip = null)
    {
    }

    pragma(inline, true)
    public static void render()
    {
        // SDL_GL_SwapWindow(window);
        SDL_RenderPresent(renderer);
    }
    pragma(inline, true)
    public static void clear()
    {
        glClear(GL_COLOR_BUFFER_BIT);
    }

    public static void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        glClearColor(r/255,g/255,b/255,a/255);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    public static void fillRect(int x, int y, int width, int height)
    {
        static SDL_Rect rec;
        rec.x = x;
        rec.y = y;
        rec.w = width;
        rec.h = height;
        SDL_RenderFillRect(renderer, &rec);
    }
    public static void drawRect(int x, int y, int width, int height)
    {
        static SDL_Rect rec;
        rec.x=x;
        rec.y=y;
        rec.w=width;
        rec.h=height;
        SDL_RenderDrawRect(renderer, &rec);
    }
    public static void drawLine(int x1, int y1, int x2, int y2)
    {
        int[4] line = [
            x1, y1,
            x2, y2
        ];
        glBindBuffer(GL_ARRAY_BUFFER, getFreeVertexBuffer());
        glBufferData(GL_ARRAY_BUFFER, int.sizeof*4, line.ptr, GL_DYNAMIC_DRAW);

        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
        glEnableVertexAttribArray(0);
        glDrawArrays(GL_LINES, 0, 2);
    }

    public static void drawTriangle()
    // public static void drawTriangle(float x1, float y1, float x2, float y2, float x3, float y3)
    {
        float[9] triangle = [
            -0.5f, -0.5f, 0.0f,
             0.5f, -0.5f, 0.0f,
             0.0f,  0.5f, 0.0f
        ];
        uint vao;
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        glBindBuffer(GL_ARRAY_BUFFER, getFreeVertexBuffer());
        glBufferData(GL_ARRAY_BUFFER, triangle.sizeof, triangle.ptr, GL_DYNAMIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
        glEnableVertexAttribArray(0);
        setShader(currentShader);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    public static void drawPixel(int x, int y)
    {
        int[2] pixel = [
            x, y,
        ];
        glBindBuffer(GL_ARRAY_BUFFER, getFreeVertexBuffer());
        glBufferData(GL_ARRAY_BUFFER, int.sizeof*2, pixel.ptr, GL_DYNAMIC_DRAW);
        glDrawArrays(GL_POINT, 0, 1);
    }

    public static void dispose()
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        renderer = null;
        window = null;
        IMG_Quit();
    }
}