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

import hip.hiprenderer.backend.gl.glrenderer;
import hip.error.handler;
import hip.util.conv;
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
    ulong size;
    uint vbo;

    this(ulong size, HipBufferUsage usage)
    {
        this.size = size;
        this.usage = getGLUsage(usage);
        glGenBuffers(1, &this.vbo);
    }
    void bind(){glBindBuffer(GL_ARRAY_BUFFER, this.vbo);}
    void unbind(){glBindBuffer(GL_ARRAY_BUFFER, 0);}
    void setData(ulong size, const(void*) data)
    {
        this.size = size;
        this.bind();
        glBufferData(GL_ARRAY_BUFFER, size, cast(void*)data, this.usage);
    }
    void updateData(int offset, ulong size, const(void*) data)
    {
        ErrorHandler.assertExit(size+offset <= this.size,
        "Tried to set data with size "~to!string(size)~"and offset "~to!string(offset)~
        "for vertex buffer with size "~to!string(this.size));

        this.bind();
        glBufferSubData(GL_ARRAY_BUFFER, offset, size, cast(void*)data);
    }
    ~this(){glDeleteBuffers(1, &this.vbo);}
}
class Hip_GL3_IndexBufferObject : IHipIndexBufferImpl
{
    immutable int  usage;
    ulong size;
    index_t count;
    uint ebo;
    this(index_t count, HipBufferUsage usage)
    {
        this.size = index_t.sizeof*count;
        this.count = count;
        this.usage = getGLUsage(usage);
        glGenBuffers(1, &this.ebo);
    }
    void bind(){glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.ebo);}
    void unbind(){glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);}
    void setData(index_t count, const index_t* data)
    {
        this.count = count;
        this.size = index_t.sizeof*count;
        this.bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_t.sizeof*count, cast(void*)data, this.usage);
    }
    void updateData(int offset, index_t count, const index_t* data)
    {
        ErrorHandler.assertExit((offset+count)*index_t.sizeof <= this.size);
        this.bind();
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, cast(void*)data);
    }
    ~this(){glDeleteBuffers(1, &this.ebo);}
}

//Used as a wrapper 
class Hip_GL_VertexArrayObject : IHipVertexArrayImpl
{
    import hip.util.data_structures;
    IHipVertexBufferImpl vbo;
    IHipIndexBufferImpl ebo;
    private alias VAOInfo = Pair!(HipVertexAttributeInfo, uint, "info", "stride");
    VAOInfo[] vaoInfos;

    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        this.vbo = vbo;
        this.ebo = ebo;
        vbo.bind();
        foreach(vao; vaoInfos)
        {
            glVertexAttribPointer(
                vao.info.index,
                vao.info.count,
                getGLAttributeType(vao.info.valueType),
                GL_FALSE,
                vao.stride,
                cast(void*)vao.info.offset
            );
            glEnableVertexAttribArray(vao.info.index);
        }
    }
        
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        vbo.unbind();
        ebo.unbind();
    }

    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        if(info.index > vaoInfos.length)
            vaoInfos.length = info.index;
        vaoInfos[info.index] = VAOInfo(info, stride);
    }
    void createInputLayout(Shader s){}
}

version(HipGL3) class Hip_GL3_VertexArrayObject : IHipVertexArrayImpl
{
    uint vao;
    this(){glGenVertexArrays(1, &this.vao);}
    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo){glBindVertexArray(this.vao);}
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo){glBindVertexArray(0);}
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        glVertexAttribPointer(
            info.index,
            info.count, 
            getGLAttributeType(info.valueType),
            GL_FALSE,
            stride,
            cast(void*)info.offset
        );
        glEnableVertexAttribArray(info.index);
    }
    void createInputLayout(Shader s){}
    ~this(){glDeleteVertexArrays(1, &this.vao);}
}