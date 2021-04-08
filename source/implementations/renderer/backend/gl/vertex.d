module implementations.renderer.backend.gl.vertex;

import bindbc.opengl;
import implementations.renderer.vertex;


enum AttributeType
{
    FLOAT = GL_FLOAT,
    INT = GL_INT,
    BOOL = GL_BOOL
}

uint createVertexArrayObject()
{
    uint vao;
    glGenBuffers(GL_VERTEX_ARRAY, &vao);
    return vao;
}

uint createVertexBufferObject()
{
    uint vbo;
    glGenBuffers(GL_ARRAY_BUFFER, &vbo);
    return vbo;
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
