module implementations.renderer.vertex;
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

struct VertexAttributeInfo
{
    uint index;
    uint length;
    uint offset;
    uint typeSize;
    int valueType;
    string name;
}

/**
*   Binds the (almost)C api on a D struct
*/
struct VertexArrayObject
{
    uint ID;
    uint VBO;
    uint EBO;

    uint index;
    uint offset;
    uint stride;
    VertexAttributeInfo[] infos;

    bool isStatic;

    public static VertexArrayObject create(bool isStatic)
    {
        VertexArrayObject ret;
        ret.ID = createVertexArrayObject();
        ret.VBO = createVertexBufferObject();
        ret.isStatic = isStatic;
        return ret;
    }

    /**
    *   This function creates an attribute information,
    * for later sending it(it is necessary as the stride needs to be recalculated)
    */
    void appendAttribute(uint length, int type, uint typeSize, string infoName)
    {
        VertexAttributeInfo info;
        info.name = infoName;
        info.length = length;
        info.valueType = type;
        info.typeSize = typeSize;
        info.index = index;
        //It actually is the `last stride`, which is the same as the offset is the total current stride
        info.offset = stride;
        infos~= info;
        index++;
        stride+= length*typeSize;
    }
    /**
    *   Changes by implementation
    */
    void sendAttributes()
    {
        foreach(info; infos)
        {
            setVertexAttribute(info, stride);
        }
    }

    void use()
    {
        useVertexArrayObject(this);
    }

    void setData(void* data, size_t dataSize)
    {
        use();
        setVertexArrayObjectData(this, data, dataSize);
    }


    void clean()
    {
        deleteVertexArrayObject(this);
        deleteVertexBufferObject(this);
        deleteElementBufferObject(this);
    }
}

VertexArrayObject getXYZ_RGBA_ST_VAO(bool isStatic)
{
    VertexArrayObject obj = VertexArrayObject.create(isStatic);
    with(AttributeType)
    {
        obj.appendAttribute(3, FLOAT, float.sizeof, "position"); //X, Y, Z
        obj.appendAttribute(4, FLOAT, float.sizeof, "color"); //R, G, B, A
    }
    obj.sendAttributes();
    return obj;
}

VertexArrayObject getXYZ_RGBA_VAO(bool isStatic)
{
    VertexArrayObject obj = VertexArrayObject.create(isStatic);
    with(AttributeType)
    {
        obj.appendAttribute(3, FLOAT, float.sizeof, "position"); //X, Y, Z
        obj.appendAttribute(4, FLOAT, float.sizeof, "color"); //R, G, B, A
        obj.appendAttribute(2, FLOAT, float.sizeof, "tex_st"); //S, T (Texture coordinates)
    }
    obj.sendAttributes();
    return obj;
}

VertexArrayObject getXY_RGBA_ST_VAO(bool isStatic)
{
    VertexArrayObject obj = VertexArrayObject.create(isStatic);
    with(AttributeType)
    {
        obj.appendAttribute(2, FLOAT, float.sizeof, "position"); //X, Y, Z
        obj.appendAttribute(4, FLOAT, float.sizeof, "color"); //R, G, B, A
        obj.appendAttribute(2, FLOAT, float.sizeof, "tex_st"); //S, T (Texture coordinates)
    }
    obj.sendAttributes();
    return obj;
}