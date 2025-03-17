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

enum HipRendererBufferType : ubyte
{
    index,
    vertex
}

interface IHipRendererBuffer
{
    HipRendererBufferType type() const;
    void bind();
    void unbind();
    void setData(const void[] data);
    void updateData(int offset, const void[] data);
}


interface IHipVertexArrayImpl
{
    void bind(IHipRendererBuffer vbo, IHipRendererBuffer ebo);
    void unbind(IHipRendererBuffer vbo, IHipRendererBuffer ebo);
    /**
    * GL also needs to bind both the vertex and index buffer before creatting the input layout
    * Direct3D 11 needs vertex shader information for creating a VAO
    * Metal needs a ShaderProgram for cerating a pipelinestate
    */
    void createInputLayout(
        IHipRendererBuffer vbo, IHipRendererBuffer ebo,
        HipVertexAttributeInfo[] info, uint stride,
        VertexShader vertexShader,
        ShaderProgram shaderProgram
    );
}

