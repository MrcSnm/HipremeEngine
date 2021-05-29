module implementations.renderer.backend.gl.vertex;

import bindbc.opengl;
import implementations.renderer.vertex;

enum AttributeType
{
    FLOAT = GL_FLOAT,
    INT = GL_INT,
    BOOL = GL_BOOL
}

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


class Hip_GL3_VertexBufferObject : IVertexBufferImpl
{
    immutable ulong size;
    immutable int  usage;
    uint vbo;

    this(ulong size, HipBufferUsage usage)
    {
        this.size = size;
        this.usage = getGLUsage(usage);
        glGenBuffers(GL_ARRAY_BUFFER, this.vbo);
    }
    void bind(){glBindBuffer(GL_ARRAY_BUFER, this.vbo);}
    void unbind(){glBindBuffer(GL_ARRAY_BUFFER, 0);}
    void setData(ulong size, const void* data)
    {
        assert(size <= this.size);
        this.bind();
        glBufferData(GL_ARRAY_BUFFER, size, data, this.usage);
    }
    void updateData(int offset, ulong size, const void* data)
    {
        assert(size+offset <= this.size);
        this.bind();
        glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
    }
    ~this(){glDeleteBuffers(1, &this.vbo);}
}
class Hip_GL3_IndexBufferObject : IIndexBufferImpl
{
    immutable uint count;
    immutable int  usage;
    uint ebo;
    this(uint* data, uint count, HipBufferUsage usage)
    {
        this.count = count;
        this.usage = getGLUsage(usage);
        glGenBuffers(GL_ELEMENT_ARRAY_BUFFER, this.ebo);
    }
    void bind(){glBindBuffer(GL_ELEMENT_ARRAY_BUFER, this.ebo);}
    void unbind(){glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);}
    void setData(ulong size, const void* data)
    {
        assert(size <= this.size);
        this.bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, this.usage);
    }
    void updateData(int offset, ulong size, const void* data)
    {
        assert(size+offset <= this.size);
        this.bind();
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, data);
    }
    ~this(){glDeleteBuffers(1, &this.ebo);}
}

uint createVertexArrayObject()
{
    uint vao;
    glGenBuffers(GL_VERTEX_ARRAY, &vao);
    return vao;
}

void setVertexAttribute(ref VertexAttributeInfo info, uint stride)
{
    glVertexAttribPointer(info.index, info.length, info.valueType, GL_FALSE, stride, cast(void*)info.offset);
    glEnableVertexAttribArray(info.index);
}

void useVertexArrayObject(ref VertexArrayObject obj)
{
    glBindVertexArray(obj.ID);
}

void setVertexArrayObjectData(ref VertexArrayObject obj, void* data, size_t dataSize)
{
    if(obj.isStatic)
        glBufferData(GL_ARRAY_BUFFER, dataSize, data, GL_STATIC_DRAW);
    else
        glBufferData(GL_ARRAY_BUFFER, dataSize, data, GL_DYNAMIC_DRAW);
}

void deleteVertexArrayObject(ref VertexArrayObject obj)
{
    glDeleteBuffers(1, &obj.ID);
    obj.ID = 0;
    obj.index = 0;
}

void deleteVertexBufferObject(ref VertexArrayObject obj)
{
    if(obj.VBO != 0)
    {
        glDeleteBuffers(1, &obj.VBO);
        obj.VBO = 0;
    }
}

void deleteElementBufferObject(ref VertexArrayObject obj)
{
    if(obj.EBO != 0)
    {
        glDeleteBuffers(1, &obj.EBO);
        obj.EBO = 0;
    }
}
