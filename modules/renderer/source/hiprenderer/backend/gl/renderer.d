/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hiprenderer.backend.gl.renderer;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
import hiprenderer.shader;
import hiprenderer.backend.gl.framebuffer;
import hiprenderer.backend.gl.shader;
import hiprenderer.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
version(Android)
{
    public import gles.gl30;
}
else
{
    public import bindbc.opengl;
}
import console.log;


private SDL_Window* createSDL_GL_Window(uint width, uint height)
{
    version(Android){return null;}
    else
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

        SDL_Window* window = SDL_CreateWindow("GL Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, flags);
        SDL_GLContext ctx = SDL_GL_CreateContext(window);
        SDL_GL_MakeCurrent(window, ctx);
        GLSupport ver = loadOpenGL();
        SDL_GL_SetSwapInterval(1);
        return window;
    }
}


/**
*
*   Those functions here present are fairly inneficient as there is not batch ocurring,
*   as I don't understand how to implement it right now, I'll mantain those functions for having
*   static access to drawing
*/
class Hip_GL3Renderer : IHipRendererImpl
{
    SDL_Window* window;
    SDL_Renderer* renderer;
    Shader currentShader;
    protected static bool isGLBlendEnabled = false;
    protected static GLenum mode;

    public final bool isRowMajor(){return true;}

    SDL_Window* createWindow(uint width, uint height)
    {
        return createSDL_GL_Window(width, height);
    }
    SDL_Renderer* createRenderer(SDL_Window* window)
    {
        return SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
    }
    Shader createShader()
    {
        return new Shader(new Hip_GL3_ShaderImpl());
    }
    public bool init(SDL_Window* window, SDL_Renderer* renderer)
    {
        this.window = window;
        this.renderer = renderer;
        setColor();
        HipRenderer.rendererType = HipRendererType.GL3;
        return true;
    }

    version(dll)public bool initExternal()
    {
        return init(null, null);
    }

    void setShader(Shader s)
    {
        currentShader = s;
    }
    public int queryMaxSupportedPixelShaderTextures()
    {
        int maxTex;
        glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &maxTex);
        return maxTex;
    }

    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        glClearColor(r/255, g/255, b/255, a/255);
    }

    public IHipFrameBuffer createFrameBuffer(int width, int height)
    {
        return new Hip_GL3_FrameBuffer(width, height);
    }

    public IHipVertexArrayImpl createVertexArray()
    {
        return new Hip_GL3_VertexArrayObject();
    }
    public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage)
    {
        return new Hip_GL3_VertexBufferObject(size, usage);
    }
    public IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        return new Hip_GL3_IndexBufferObject(count, usage);
    }

    public void setViewport(Viewport v)
    {
        glViewport(v.x, v.y, v.w, v.h);
        
    }
    public bool setWindowMode(HipWindowMode mode)
    {
        final switch(mode) with(HipWindowMode)
        {
            case BORDERLESS_FULLSCREEN:
                break;
            case FULLSCREEN:
                break;
            case WINDOWED:

                break;
        }
        return false;
    }
    public bool hasErrorOccurred(out string err, string file = __FILE__, int line =__LINE__)
    {
        import std.format:format;
        GLenum errorCode = glGetError();
        static enum GL_STACK_OVERFLOW = 0x0503;
        static enum GL_STACK_UNDERFLOW = 0x0504;
        switch(errorCode)
        {
            case GL_NO_ERROR:
                err = format!`GL_NO_ERROR at %s:%s:
    No error has been recorded. The value of this symbolic constant is guaranteed to be 0.`(file, line);
                    break;
            case GL_INVALID_ENUM:
                err = format!`GL_INVALID_ENUM at %s:%s:
    An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.`(file, line);
                break;
            case GL_INVALID_VALUE:
                err = format!`GL_INVALID_VALUE at %s:%s:
    A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.`(file, line);
                break;
            case GL_INVALID_OPERATION:
                err = format!`GL_INVALID_OPERATION at %s:%s:
    The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.`(file, line);
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                err = format!`GL_INVALID_FRAMEBUFFER_OPERATION at %s:%s:
    The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.`(file, line);
                break;
            case GL_OUT_OF_MEMORY:
                err = format!`GL_OUT_OF_MEMORY at %s:%s:
    There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.`(file, line);
                break;
            case GL_STACK_UNDERFLOW:
                err = format!`GL_STACK_UNDERFLOW at %s:%s:
    An attempt has been made to perform an operation that would cause an internal stack to underflow.`(file, line);
                break;
            case GL_STACK_OVERFLOW:
                err = format!`GL_STACK_OVERFLOW at %s:%s:
    An attempt has been made to perform an operation that would cause an internal stack to overflow.`(file, line);
                break;
            default:
                err = "Unknown error code";
        }
        return errorCode != GL_NO_ERROR;
    }

    /**
    *   This function is used to control the internal state for creating vertex buffers
    */
    public void begin(){}

    /**
    */
    public void end()
    {
        version(Android){}
        else
        {
            SDL_GL_SwapWindow(window);
            // SDL_RenderPresent(renderer);
        }
    }

    public void draw(Texture t, int x, int y){}
    public void draw(Texture t, int x, int y, SDL_Rect* clip = null)
    {
        t.bind();
        
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

    protected GLenum getGLRendererMode(HipRendererMode mode)
    {
        final switch(mode) with(HipRendererMode)
        {
            case POINT:
                return GL_POINTS;
            case LINE:
                return GL_LINES;
            case LINE_STRIP:
                return GL_LINE_STRIP;
            case TRIANGLES:
                return GL_TRIANGLES;
            case TRIANGLE_STRIP:
                return GL_TRIANGLE_STRIP;
        }
    }
    protected GLenum getGLBlendFunction(HipBlendFunction func)
    {
        final switch(func) with(HipBlendFunction)
        {
            case  ZERO:
                return GL_ZERO;
            case  ONE:
                return GL_ONE;
            case  SRC_COLOR:
                return GL_SRC_COLOR;
            case  ONE_MINUS_SRC_COLOR:
                return GL_ONE_MINUS_SRC_COLOR;
            case  DST_COLOR:
                return GL_DST_COLOR;
            case  ONE_MINUS_DST_COLOR:
                return GL_ONE_MINUS_DST_COLOR;
            case  SRC_ALPHA:
                return GL_SRC_ALPHA;
            case  ONE_MINUS_SRC_ALPHA:
                return GL_ONE_MINUS_SRC_ALPHA;
            case  DST_ALPHA:
                return GL_DST_ALPHA;
            case  ONE_MINUST_DST_ALPHA:
                return GL_ONE_MINUS_DST_ALPHA;
            case  CONSTANT_COLOR:
                return GL_CONSTANT_COLOR;
            case  ONE_MINUS_CONSTANT_COLOR:
                return GL_ONE_MINUS_CONSTANT_COLOR;
            case  CONSTANT_ALPHA:
                return GL_CONSTANT_ALPHA;
            case  ONE_MINUS_CONSTANT_ALPHA:
                return GL_ONE_MINUS_CONSTANT_ALPHA;
        }
    }
    protected GLenum getGLBlendEquation(HipBlendEquation eq)
    {
        final switch(eq) with (HipBlendEquation)
        {
            case ADD:
                return GL_FUNC_ADD;
            case SUBTRACT:
                return GL_FUNC_SUBTRACT;
            case REVERSE_SUBTRACT:
                return GL_FUNC_REVERSE_SUBTRACT;
            case MIN:
                return GL_MIN;
            case MAX:
                return GL_MAX;
        }
    }
    public void setRendererMode(HipRendererMode mode)
    {
        this.mode = getGLRendererMode(mode);
    }
    public void drawVertices(index_t count, uint offset)
    {
        glDrawArrays(this.mode, offset, count);
    }
    public void drawIndexed(index_t indicesCount, uint offset = 0)
    {
        static if(is(index_t == uint))
            glDrawElements(this.mode, indicesCount, GL_UNSIGNED_INT, cast(void*)offset);
        else
            glDrawElements(this.mode, indicesCount, GL_UNSIGNED_SHORT, cast(void*)offset);
    }

    public void setBlendFunction(HipBlendFunction src, HipBlendFunction dst)
    {
        if(!isGLBlendEnabled)
        {
            glEnable(GL_BLEND);
            isGLBlendEnabled = true;
        }
        glBlendFunc(getGLBlendFunction(src), getGLBlendFunction(dst));
    }

    public void setBlendingEquation(HipBlendEquation eq)
    {
        if(!isGLBlendEnabled)
        {
            glEnable(GL_BLEND);
            isGLBlendEnabled = true;
        }
        glBlendEquation(getGLBlendEquation(eq));
    }
    public void drawRect(){}
    public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3){}
    public void drawRect(int x, int y, int w, int h){}
    public void fillRect(int x, int y, int width, int height){}
    public void drawLine(int x1, int y1, int x2, int y2){}
    public void drawPixel(int x, int y ){}

    public void dispose()
    {
        if(window != null)
        {
            SDL_GL_DeleteContext(SDL_GL_GetCurrentContext());
        }
    }
}