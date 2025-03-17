/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.glvertex;

version(OpenGL):
import hip.api.renderer.vertex;
import hip.hiprenderer.backend.gl.glrenderer;
import hip.error.handler;
import hip.util.conv;
import hip.config.opts;
import hip.hiprenderer.renderer;
import hip.hiprenderer.shader;
import hip.hiprenderer.vertex;


private int getGLUsage(HipBufferUsage usage)
{
    final switch(usage) with(HipBufferUsage)
    {
        case STATIC:
            return GL_STATIC_DRAW;
        case DEFAULT:
        case DYNAMIC:
            return GL_DYNAMIC_DRAW;
    }
}
private int getGLAttributeType(HipAttributeType _t)
{
    final switch(_t) with(HipAttributeType)
    {
        case Rgba32: return GL_UNSIGNED_BYTE;
        case Float: return GL_FLOAT;
        case Int: return GL_INT;
        case Uint: return GL_UNSIGNED_INT;
        case Bool: return GL_BOOL;
    }
}

private ubyte isGLAttributeNormalized(HipAttributeType _t)
{
    final switch(_t) with(HipAttributeType)
    {
        case Rgba32: return GL_TRUE;
        case Float: return GL_FALSE;
        case Int: return GL_FALSE;
        case Uint: return GL_FALSE;
        case Bool: return GL_FALSE;
    }
}

GLenum getBufferType(HipRendererBufferType type)
{
    final switch ( type )
    {
        case HipRendererBufferType.vertex:
            return GL_ARRAY_BUFFER;
        case HipRendererBufferType.index:
            return GL_ELEMENT_ARRAY_BUFFER;
    }
}

final class Hip_GL3_Buffer : IHipRendererBuffer
{
    size_t size;
    uint handle;
    immutable int usage;
    int glType;
    immutable HipRendererBufferType _type;

    HipRendererBufferType type() const { return _type; }


    private __gshared Hip_GL3_Buffer boundVbo;
    private __gshared Hip_GL3_Buffer boundEbo;

    this(size_t size, HipBufferUsage usage, HipRendererBufferType type)
    {
        this.size = size;
        this.usage = getGLUsage(usage);
        this._type = type;
        this.glType = getBufferType(type);
        glCall(() => glGenBuffers(1, &handle));
    }
    void bind()
    {
        if(type == HipRendererBufferType.vertex)
        {
            if(boundVbo !is this)
            {
                glCall(()=>glBindBuffer(glType, handle));
                boundVbo = this;
            }
        }
        else if(boundEbo !is this)
        {
            glCall(()=>glBindBuffer(glType, handle));
            boundEbo = this;
        }
    }
    void unbind()
    {
        if(type == HipRendererBufferType.vertex)
        {
            if(boundVbo is this)
            {
                glCall(()=>glBindBuffer(glType, 0));
                boundVbo = null;
            }
        }
        else if(boundEbo is this)
        {
            glCall(()=>glBindBuffer(glType, 0));
            boundEbo = null;
        }
    }
    void setData(const(void)[] data)
    {
        this.size = data.length;
        this.bind();
        glCall(() => glBufferData(glType, data.length, cast(void*)data.ptr, this.usage));
    }
    void updateData(int offset, const(void)[] data)
    {
        if(data.length + offset > this.size)
        {
            ErrorHandler.assertExit(
                false, "Tried to set data with size "~to!string(size)~"and offset "~to!string(offset)~
        "for buffer with size "~to!string(this.size));
        }
        this.bind();
        {
            glCall(() => glBufferSubData(glType, offset, data.length, data.ptr));
        }
    }
    ~this(){glCall(() => glDeleteBuffers(1, &handle));}
}

//Used as a wrapper 
final class Hip_GL_VertexArrayObject : IHipVertexArrayImpl
{
    import hip.util.data_structures;
    IHipRendererBuffer vbo;
    IHipRendererBuffer ebo;
    HipVertexAttributeInfo[] vaoInfos;
    uint stride;

    bool isWaitingCreation = false;

    private __gshared Hip_GL_VertexArrayObject boundVAO;

    void bind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        if(vbo is null)
        {
            isWaitingCreation = true;
            return;
        }
        else
            this.vbo = vbo;
        if(ebo is null)
        {
            isWaitingCreation = true;
            return;
        }
        else
            this.ebo = ebo;
        isWaitingCreation = false;

        static if(!GLShouldDisableVertexAttrib)
        {
            __gshared bool[GLMaxVertexAttributes] enabledAttributes;
        }

        if(boundVAO !is this)
        {
            vbo.bind();
            ebo.bind();
            foreach(info; vaoInfos)
            {
                static if(!GLShouldDisableVertexAttrib)
                {
                    if(!enabledAttributes[info.index])
                    {
                        glCall(() => glEnableVertexAttribArray(info.index));
                        enabledAttributes[info.index] = true;
                    }
                }
                else
                {
                    glCall(() => glEnableVertexAttribArray(info.index));
                }
                glCall(() => glVertexAttribPointer(
                    info.index,
                    info.count,
                    getGLAttributeType(info.valueType),
                    isGLAttributeNormalized(info.valueType),
                    stride,
                    cast(void*)info.offset
                ));
            }
            boundVAO = this;
        }
    }
        
    void unbind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        static if(UseDelayedUnbinding)
        {

        }
        else
        {
            if(boundVAO is this)
            {
                foreach(vao; vaoInfos)
                {
                    glCall(() => glDisableVertexAttribArray(vao.info.index));
                }
                vbo.unbind();
                ebo.unbind();
                boundVAO = null;
            }
        }
    }
    void createInputLayout(
        IHipRendererBuffer, IHipRendererBuffer,
        HipVertexAttributeInfo[] attInfos, uint stride,
        VertexShader s, ShaderProgram p)
    {
        import hip.hiprenderer.backend.gl.glshader;
        Hip_GL3_ShaderProgram glProg = cast(Hip_GL3_ShaderProgram)p;
        vaoInfos = attInfos;
        this.stride = stride;
        foreach(ref info; attInfos)
        {
            int attloc = glCall(() => glGetAttribLocation(glProg.program, cast(char*)info.name.ptr));
            if(attloc == -1)
                throw new Exception("Could not find attribute "~info.name~" at shader.");
            info.index = attloc;
            // glCall(() => glBindAttribLocation(glProg.program, i, vao.info.name.ptr)); That strategy does not work since the shader is already linked at that stage...
        }
    }
}

version(HipGLUseVertexArray) final class Hip_GL3_VertexArrayObject : IHipVertexArrayImpl
{
    uint vao;
    private __gshared Hip_GL3_VertexArrayObject boundVao;
    this()
    {
        glCall(() => glGenVertexArrays(1, &this.vao));
    }
    void bind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        if(boundVao !is this)
        {
            glCall(() => glBindVertexArray(this.vao));
            boundVao = this;
        }
    }
    void unbind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        if(boundVao is this)
        {
            glCall(() => glBindVertexArray(0));
            boundVao = null;
        }
    }

    void createInputLayout(IHipRendererBuffer vbo, IHipRendererBuffer ebo, HipVertexAttributeInfo[] attInfos, uint stride, VertexShader s, ShaderProgram p)
    {
        bind(vbo, ebo);
        vbo.bind();
        ebo.bind();
        foreach(info; attInfos)
        {
            glCall(() => glVertexAttribPointer(
                info.index,
                info.count,
                getGLAttributeType(info.valueType),
                isGLAttributeNormalized(info.valueType),
                stride,
                cast(void*)info.offset
            ));
            glCall(() => glEnableVertexAttribArray(info.index));
        }
    }
    ~this(){glCall(() => glDeleteVertexArrays(1, &this.vao));}
}