/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.renderer.backend.gl.vertex;

import bindbc.opengl;
import std.format:format;
import implementations.renderer.shader;
import implementations.renderer.vertex;


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
    void setData(ulong size, const void* data)
    {
        this.size = size;
        this.bind();
        glBufferData(GL_ARRAY_BUFFER, size, data, this.usage);
    }
    void updateData(int offset, ulong size, const void* data)
    {
        assert(size+offset <= this.size, format!"Tried to set data with size %s and offset %s for vertex buffer with size %s"(size, offset, this.size));
        this.bind();
        glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
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
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_t.sizeof*count, data, this.usage);
    }
    void updateData(int offset, index_t count, const index_t* data)
    {
        assert((offset+count)*index_t.sizeof <= this.size);
        this.bind();
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, data);
    }
    ~this(){glDeleteBuffers(1, &this.ebo);}
}

class Hip_GL3_VertexArrayObject : IHipVertexArrayImpl
{
    uint vao;
    this(){glGenVertexArrays(1, &this.vao);}
    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo){glBindVertexArray(this.vao);}
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo){glBindVertexArray(0);}
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        glVertexAttribPointer(info.index, info.count, 
            getGLAttributeType(info.valueType), GL_FALSE, stride, cast(void*)info.offset);
        glEnableVertexAttribArray(info.index);
    }
    void createInputLayout(Shader s){}
    ~this(){glDeleteVertexArrays(1, &this.vao);}
}