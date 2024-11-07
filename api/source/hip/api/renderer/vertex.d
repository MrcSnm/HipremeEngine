module hip.api.renderer.vertex;
import hip.api.renderer.shader;

// version(Android){alias index_t = ushort;}
// else{alias index_t = uint;}
alias index_t = ushort;


index_t index_t_maxQuads()
{
    return cast(index_t)(ushort.max / 6);
}
index_t index_t_maxQuadIndices()
{
    return cast(index_t)(index_t_maxQuads * 6);
}



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
    ///Used as a unsigned r8g8b8a8 normalized type.
    Rgba32,
    Float,
    Uint,
    Int,
    Bool
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
    void setData(const void[] data);
    void updateData(int offset, const void[] data);
}
interface IHipIndexBufferImpl
{
    void bind();
    void unbind();
    void setData(const index_t[] data);
    void updateData(int offset, const index_t[] data);
}
interface IHipVertexArrayImpl
{
    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride);
    /**
    * Direct3D 11 needs vertex shader information for creating a VAO
    * Metal needs a ShaderProgram for cerating a pipelinestate
    */
    void createInputLayout(VertexShader vertexShader, ShaderProgram shaderProgram);
}

