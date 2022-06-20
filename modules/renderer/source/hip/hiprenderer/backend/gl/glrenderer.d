/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.glrenderer;
import hip.hiprenderer.renderer;
import hip.hiprenderer.framebuffer;
import hip.hiprenderer.shader;
import hip.hiprenderer.backend.gl.glframebuffer;
import hip.hiprenderer.backend.gl.glshader;
import hip.hiprenderer.viewport;

version(Android)
    version = NoWindow;
else version(Have_windowing)
    version = HasWindow;
else
    version = NoWindow;

import hip.windowing.window;
import hip.util.conv;
import hip.math.rect;
import hip.error.handler;
version(Android)
{
    public import gles.gl30;
}
else version(PSVita)
{
    public import gles;
}
else
{
    public import bindbc.opengl;
}
import hip.console.log;


/**
*
*   Those functions here present are fairly inneficient as there is not batch ocurring,
*   as I don't understand how to implement it right now, I'll mantain those functions for having
*   static access to drawing
*/
class Hip_GL3Renderer : IHipRendererImpl
{
    HipWindow window;
    Shader currentShader;
    protected static bool isGLBlendEnabled = false;
    protected static GLenum mode;

    public final bool isRowMajor(){return true;}

    HipWindow createWindow(uint width, uint height)
    {
        version(NoWindow){return null;}
        else version(HasWindow)
        {
            HipWindow wnd = new HipWindow(width, height, 
                HipWindowFlags.RESIZABLE | HipWindowFlags.MINIMIZABLE | HipWindowFlags.MAXIMIZABLE);
            wnd.start();
            return wnd;
        }
    }
    Shader createShader()
    {
        return new Shader(new Hip_GL3_ShaderImpl());
    }
    public bool init(HipWindow window)
    {
        this.window = window;
        window.startOpenGLContext();
        GLSupport ver = loadOpenGL();
        rawlog("GL Renderer: ",  glGetString(GL_RENDERER));
        rawlog("GL Version: ",  glGetString(GL_VERSION));
        rawlog("GLSL Version: ",  glGetString(GL_SHADING_LANGUAGE_VERSION));
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
        glViewport(cast(int)v.x, cast(int)v.y, cast(GLsizei)v.w, cast(GLsizei)v.h);
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
        GLenum errorCode = glGetError();
        static enum GL_STACK_OVERFLOW = 0x0503;
        static enum GL_STACK_UNDERFLOW = 0x0504;
        switch(errorCode)
        {
            case GL_NO_ERROR:
                err = `GL_NO_ERROR at `~file~":"~to!string(line)~`:
    No error has been recorded. The value of this symbolic constant is guaranteed to be 0.`;
                    break;
            case GL_INVALID_ENUM:
                err = `GL_INVALID_ENUM at `~file~":"~to!string(line)~`:
    An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.`;
                break;
            case GL_INVALID_VALUE:
                err = `GL_INVALID_VALUE at `~file~":"~to!string(line)~`:
    A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.`;
                break;
            case GL_INVALID_OPERATION:
                err = `GL_INVALID_OPERATION at `~file~":"~to!string(line)~`:
    The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.`;
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                err = `GL_INVALID_FRAMEBUFFER_OPERATION at `~file~":"~to!string(line)~`:
    The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.`;
                break;
            case GL_OUT_OF_MEMORY:
                err = `GL_OUT_OF_MEMORY at `~file~":"~to!string(line)~`:
    There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.`;
                break;
            case GL_STACK_UNDERFLOW:
                err = `GL_STACK_UNDERFLOW at `~file~":"~to!string(line)~`:
    An attempt has been made to perform an operation that would cause an internal stack to underflow.`;
                break;
            case GL_STACK_OVERFLOW:
                err = `GL_STACK_OVERFLOW at `~file~":"~to!string(line)~`:
    An attempt has been made to perform an operation that would cause an internal stack to overflow.`;
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
            window.rendererPresent();
            glFlush();
            glFinish();
        }
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

    public void dispose()
    {
        if(window !is null)
        {
            window.destroyOpenGLContext();
        }
    }
}