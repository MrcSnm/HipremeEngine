module implementations.renderer.backend.gl.renderer;
import implementations.renderer.renderer;
import implementations.renderer.shader;
import implementations.renderer.backend.gl.shader;
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
*
*   Those functions here present are fairly inneficient as there is not batch ocurring,
*   as I don't understand how to implement it right now, I'll mantain those functions for having
*   static access to drawing
*/
class Hip_GL3Renderer : RendererImpl
{
    SDL_Window* window;
    SDL_Renderer* renderer;
    Shader currentShader;
    /**
    *   Does not uses EBO
    */
    protected uint[] vertexBuffersIDS;
    protected uint[] vertexArraysIDS;
    protected uint currentVertexBufferIndex;

    /**
    *   Uses EBO
    */
    protected uint[] rectangleVertexBuffersIDS;
    protected uint[] rectangleVertexArraysIDS;
    protected uint currentRectangleVertexBufferIndex;

    protected uint rectangleEBO;

    protected static immutable uint[6] rectangleIndices = [
        3, 2, 1, //Right rectangle
        1, 0, 3  //Left rectangle
    ];


    SDL_Window* createWindow()
    {
        return createSDL_GL_Window();
    }
    SDL_Renderer* createRenderer(SDL_Window* window)
    {
        return SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
    }
    Shader createShader(bool createDefault = true)
    {
        return new Shader(new Hip_GL3_ShaderImpl(), createDefault);
    }
    public bool init(SDL_Window* window, SDL_Renderer* renderer)
    {
        this.window = window;
        this.renderer = renderer;
        uint reserveAmount=1024;
        vertexBuffersIDS.reserve(reserveAmount);
        rectangleVertexBuffersIDS.reserve(reserveAmount);
        setColor();
        glGenBuffers(1, &rectangleEBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rectangleEBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, rectangleIndices.sizeof, &rectangleIndices, GL_DYNAMIC_DRAW);
        setShader(createShader(true));
        return true;
    }

    void setShader(Shader s)
    {
        currentShader = s;
    }

    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        glClearColor(r/255, g/255, b/255, a/255);
    }

    public void setViewport(Viewport v)
    {
        SDL_RenderSetViewport(renderer, &v.bounds);
    }

    protected uint getFreeVertexBufferIndex()
    {
        if(vertexBuffersIDS.length >= currentVertexBufferIndex)
        {
            uint buf;
            uint vao;
            glGenBuffers(1, &buf);
            glGenVertexArrays(1, &vao);
            vertexBuffersIDS~=buf;
            vertexArraysIDS~=vao;
        }
        uint ret = currentVertexBufferIndex;
        currentVertexBufferIndex++;
        return ret;
    }
    /**
    *   As it uses element buffer object, it is better to separate for better performance
    */
    protected uint getFreeVertexBufferIndexForRectangle()
    {
        if(rectangleVertexBuffersIDS.length >= currentRectangleVertexBufferIndex)
        {
            uint buf;
            uint vao;
            glGenBuffers(1, &buf);
            glGenVertexArrays(1, &vao);
            rectangleVertexBuffersIDS~=buf;
            rectangleVertexArraysIDS~=vao;
            glBindVertexArray(vao);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER , rectangleEBO);
            glBindVertexArray(0);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        }
        uint ret = currentRectangleVertexBufferIndex;
        currentRectangleVertexBufferIndex++;
        return ret;
    }

    /**
    *   This function is used to control the internal state for creating vertex buffers
    */
    public void begin()
    {
        currentVertexBufferIndex = 0;
        currentRectangleVertexBufferIndex = 0;
    }

    /**
    */
    public void end()
    {
        SDL_GL_SwapWindow(window);
    }

    public void draw(Texture t, int x, int y, SDL_Rect* clip = null)
    {
    }

    pragma(inline, true)
    public void render()
    {
        // SDL_GL_SwapWindow(window);
        SDL_RenderPresent(renderer);
    }
    pragma(inline, true)
    public void clear()
    {
        glClear(GL_COLOR_BUFFER_BIT);
    }

    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        glClearColor(r/255,g/255,b/255,a/255);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    /**
    *   This function must be used only for primitives which don't use EBO
    */
    pragma(inline, true)
    protected void bindNextVertexArrayObject()
    {
        uint index = getFreeVertexBufferIndex();
        glBindVertexArray(vertexArraysIDS[index]);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffersIDS[index]);
    }

    public void fillRect(int x, int y, int width, int height)
    {
        float[12] vertices = [
            -0.5, -0.5, 0,
            0.5, -0.5, 0,
            0.5, 0.5, 0,
            -0.5, 0.5, 0
        ];
        uint index = getFreeVertexBufferIndexForRectangle();
        glBindVertexArray(rectangleVertexArraysIDS[index]);
        glBindBuffer(GL_ARRAY_BUFFER, rectangleVertexBuffersIDS[index]);

        glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, &vertices, GL_DYNAMIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*float.sizeof, cast(void*)0);
        glEnableVertexAttribArray(0);
        
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast(void*)0);
    }
    public void drawRect()
    // public static void drawRect(int x, int y, int width, int height)
    {
        // rectangle();        
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast(void*)0);
    }

    public void drawLine(int x1, int y1, int x2, int y2)
    {
        int[4] line = [
            x1, y1,
            x2, y2
        ];
        bindNextVertexArrayObject();
        glBufferData(GL_ARRAY_BUFFER, int.sizeof*4, line.ptr, GL_DYNAMIC_DRAW);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
        glEnableVertexAttribArray(0);
        glDrawArrays(GL_LINES, 0, 2);
    }

    pragma(inline, true)
    protected void triangle()
    {
        float[18] triangle = [
            -0.5f, -0.5f, 0.0f,
             0.5f, -0.5f, 0.0f,
             0.0f,  0.5f, 0.0f,

             -0.6f, -0.6f, 0.0f,
             0.6f, -0.6f, 0.0f,
             0.1f,  0.6f, 0.0f,
        ];
        
        bindNextVertexArrayObject();
        glBufferData(GL_ARRAY_BUFFER, triangle.sizeof, triangle.ptr, GL_DYNAMIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
        glEnableVertexAttribArray(0);
    }

    public void drawTriangle()
    // public static void drawTriangle(float x1, float y1, float x2, float y2, float x3, float y3)
    {
        // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        triangle();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
    public void drawPixel(int x, int y)
    {
        int[2] pixel = [
            x, y,
        ];
        bindNextVertexArrayObject();
        glBufferData(GL_ARRAY_BUFFER, pixel.sizeof, pixel.ptr, GL_DYNAMIC_DRAW);
        glDrawArrays(GL_POINT, 0, 1);
        
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