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

/**
 * Information about how the resource is used.
 */
enum HipResourceUsage : ubyte
{
    ///Usually means the resource is able to change, but with subpar speed
    Default,
    ///Means that the resource is optimized to be changed from the CPU
    Dynamic,
    ///The resource is immutable and can't be changed
    Immutable,
}

enum HipResourceAccess : ubyte
{
    ///Can only write from that resource
    write,
    ///Can only read from that resource
    read,
    ///Read and write from that resource
    readWrite
}

enum HipAttributeType : ubyte
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
    vertex,
    uniform
}

interface IHipRendererBuffer
{
    HipRendererBufferType type() const;
    void bind();
    void unbind();
    void setData(const void[] data);
    /**
     * This API is not available on OpenGL. Use set/update data instead.
     * Returns: The mapped GPU buffer
     */
    ubyte[] getBuffer();
    /**
     * This API is only necessary when dealing with D3D. The buffer is automatically mapped when getBuffer is called.
     */
    void unmapBuffer();
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
        ShaderProgram shaderProgram
    );
}

