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
        case FLOAT:
            return GL_FLOAT;
        case INT:
            return GL_INT;
        case BOOL:
            return GL_BOOL;
    }
}


class Hip_GL3_VertexBufferObject : IHipVertexBufferImpl
{
    immutable int  usage;
    size_t size;
    uint vbo;

    private __gshared Hip_GL3_VertexBufferObject boundVbo;

    this(size_t size, HipBufferUsage usage)
    {
        this.size = size;
        this.usage = getGLUsage(usage);
        glCall(() => glGenBuffers(1, &this.vbo));
    }
    void bind()
    {
        if(boundVbo !is this)
        {
            glCall(()=>glBindBuffer(GL_ARRAY_BUFFER, this.vbo));
            boundVbo = this;
        }
    }
    void unbind()
    {
        if(boundVbo is this)
        {
            glCall(()=>glBindBuffer(GL_ARRAY_BUFFER, 0));
            boundVbo = null;
        }
    }
    void setData(size_t size, const(void*) data)
    {
        this.size = size;
        this.bind();
        glCall(() => glBufferData(GL_ARRAY_BUFFER, size, cast(void*)data, this.usage));
    }
    void updateData(int offset, size_t size, const(void*) data)
    {
        if(size + offset > this.size)
        {
            ErrorHandler.assertExit(
                false, "Tried to set data with size "~to!string(size)~"and offset "~to!string(offset)~
        "for vertex buffer with size "~to!string(this.size));
        }
        this.bind();
        glCall(() => glBufferSubData(GL_ARRAY_BUFFER, offset, size, cast(void*)data));
    }
    ~this(){glCall(() => glDeleteBuffers(1, &this.vbo));}
}
class Hip_GL3_IndexBufferObject : IHipIndexBufferImpl
{
    immutable int  usage;
    size_t size;
    index_t count;
    uint ebo;

    private __gshared Hip_GL3_IndexBufferObject boundEbo;

    this(index_t count, HipBufferUsage usage)
    {
        this.size = index_t.sizeof*count;
        this.count = count;
        this.usage = getGLUsage(usage);
        glCall(() => glGenBuffers(1, &this.ebo));
    }
    void bind()
    {
        if(boundEbo !is this)
        {
            glCall(() => glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.ebo));
            boundEbo = this;
        }
    }
    void unbind()
    {
        if(boundEbo is this)
        {
            glCall(() => glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0));
            boundEbo = null;
        }
    }
    void setData(index_t count, const index_t* data)
    {
        this.count = count;
        this.size = index_t.sizeof*count;
        this.bind();
        glCall(() => glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_t.sizeof*count, cast(void*)data, this.usage));
    }
    void updateData(int offset, index_t count, const index_t* data)
    {
        ErrorHandler.assertExit((offset+count)*index_t.sizeof <= size);
        this.bind();
        glCall(() => glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, (offset+count)*index_t.sizeof, cast(void*)data));
    }
    ~this(){glCall(() => glDeleteBuffers(1, &this.ebo));}
}

//Used as a wrapper 
class Hip_GL_VertexArrayObject : IHipVertexArrayImpl
{
    import hip.util.data_structures;
    IHipVertexBufferImpl vbo;
    IHipIndexBufferImpl ebo;
    private alias VAOInfo = Pair!(HipVertexAttributeInfo, uint, "info", "stride");
    VAOInfo[] vaoInfos;

    bool isWaitingCreation = false;

    private __gshared Hip_GL_VertexArrayObject boundVAO;

    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
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
        if(boundVAO !is this)
        {
            vbo.bind();
            ebo.bind();
            foreach(vao; vaoInfos)
            {
                glCall(() => glEnableVertexAttribArray(vao.info.index));
                glCall(() => glVertexAttribPointer(
                    vao.info.index,
                    vao.info.count,
                    getGLAttributeType(vao.info.valueType),
                    GL_FALSE,
                    vao.stride,
                    cast(void*)vao.info.offset
                ));
            }
            boundVAO = this;
        }
    }
        
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
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

    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        if(info.index + 1 > vaoInfos.length)
            vaoInfos.length = info.index + 1;
        vaoInfos[info.index] = VAOInfo(info, stride);
    }
    void createInputLayout(Shader s){}
}

version(HipGLUseVertexArray) class Hip_GL3_VertexArrayObject : IHipVertexArrayImpl
{
    uint vao;
    private __gshared Hip_GL3_VertexArrayObject boundVao;
    this()
    {
        glCall(() => glGenVertexArrays(1, &this.vao));
    }
    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        if(boundVao !is this)
        {
            glCall(() => glBindVertexArray(this.vao));
            boundVao = this;
        }
    }
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        if(boundVao is this)
        {
            glCall(() => glBindVertexArray(0));
            boundVao = null;
        }
    }
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        glCall(() => glVertexAttribPointer(
            info.index,
            info.count, 
            getGLAttributeType(info.valueType),
            GL_FALSE,
            stride,
            cast(void*)info.offset
        ));
        glCall(() => glEnableVertexAttribArray(info.index));
    }
    void createInputLayout(Shader s){}
    ~this(){glCall(() => glDeleteVertexArrays(1, &this.vao));}
}