/**
*    This file provides the essential information for specifying vertices
*   for the target 3D API. Its Attributes/Layout, some preset layouts.
*    The workflow for vertices are entirely based on OpenGL, using VAOs and VBOs
*
*/

module implementations.renderer.vertex;
import implementations.renderer.renderer;
public import implementations.renderer.backend.gl.vertex;

enum InternalVertexAttribute
{
    POSITION = 0,
    TEXTURE_COORDS,
    COLOR
}

enum InternalVertexAttributeFlags
{
    POSITION = 1 << InternalVertexAttribute.POSITION,
    TEXTURE_COORDS = 1 << InternalVertexAttribute.TEXTURE_COORDS,
    COLOR = 1 << InternalVertexAttribute.COLOR,
}
enum HipBufferUsage
{
    DYNAMIC,
    STATIC,
    DEFAULT
}

enum HipAttributeType
{
    FLOAT,
    INT,
    BOOL
}


struct HipVertexAttributeInfo
{
    uint index;
    uint count;
    uint offset;
    uint typeSize;
    HipAttributeType valueType;
    string name;
}


interface IHipVertexBufferImpl
{
    void bind();
    void unbind();
    void setData(ulong size, const void* data);
    void updateData(int offset, ulong size, const void* data);
}
interface IHipIndexBufferImpl
{
    void bind();
    void unbind();
    void setData(uint count, const uint* data);
    void updateData(int offset, uint count, const uint* data);
}
interface IHipVertexArrayImpl
{
    void bind();
    void unbind();
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride);
}


/**
*   Binds the (almost)C api on a D struct
*/
class HipVertexArrayObject
{
    IHipVertexArrayImpl  VAO;
    IHipVertexBufferImpl VBO;
    IHipIndexBufferImpl  EBO;
    uint stride;
    HipVertexAttributeInfo[] infos;
    
    this()
    {
        this.VAO = HipRenderer.createVertexArray();
    }
    void createIndexBuffer(uint count, HipBufferUsage usage)
    {
        this.EBO = HipRenderer.createIndexBuffer(count, usage);
    }
    void createVertexBuffer(ulong size, HipBufferUsage usage)
    {
        this.VBO = HipRenderer.createVertexBuffer(size, usage);
    }
    /**
    *   This function creates an attribute information,
    * for later sending it(it is necessary as the stride needs to be recalculated)
    */
    HipVertexArrayObject appendAttribute(uint count, HipAttributeType valueType, uint typeSize, string infoName)
    {
        HipVertexAttributeInfo info;
        info.name = infoName;
        info.count = count;
        info.valueType = valueType;
        info.typeSize = typeSize;
        info.index = cast(uint)infos.length;
        //It actually is the `last stride`, which is the same as the offset is the total current stride
        info.offset = stride;
        infos~= info;
        stride+= count*typeSize;
        return this;
    }
    /**
    *   Iterates the VAO list and set each attribute info active
    */
    void sendAttributes()
    {
        foreach(info; infos)
            this.VAO.setAttributeInfo(info, stride);
    }

    void bind()
    {
        this.VAO.bind();
    }
    void unbind()
    {
        this.VAO.unbind();
    }

    void setVBOData(ulong dataSize, const void* data)
    {
        this.bind();
        this.VBO.setData(dataSize, data);
    }
    void setEBOData(uint count, const uint* data)
    {
        this.EBO.setData(count, data);
    }

    static HipVertexArrayObject getXYZ_RGBA_ST_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(3, FLOAT, float.sizeof, "position") //X, Y, Z
                .appendAttribute(4, FLOAT, float.sizeof, "color") //R, G, B, A
                .sendAttributes();
        }
        return obj;
    }

    static HipVertexArrayObject getXYZ_RGBA_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(3, FLOAT, float.sizeof, "position") //X, Y, Z
                .appendAttribute(4, FLOAT, float.sizeof, "color") //R, G, B, A
                .appendAttribute(2, FLOAT, float.sizeof, "tex_st") //S, T (Texture coordinates)
                .sendAttributes();
        }
        return obj;
    }

    static HipVertexArrayObject getXY_RGBA_ST_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(2, FLOAT, float.sizeof, "position"); //X, Y, Z
            obj.appendAttribute(4, FLOAT, float.sizeof, "color"); //R, G, B, A
            obj.appendAttribute(2, FLOAT, float.sizeof, "tex_st"); //S, T (Texture coordinates)
        }
        obj.sendAttributes();
        return obj;
    }
}