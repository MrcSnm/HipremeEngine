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

pragma(inline, true) T floatMapped(T)(float data) pure nothrow @nogc @trusted
{
    return cast(T)(data * T.max);
}

struct HipVertexAttributeCreateInfo
{
    ///Defines the count of buffer strides will fit in the size. So, size is count * info.vboStride
    size_t count;
    HipResourceUsage usage;
    ShaderInputRate rate;
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
    Ushort,
    Int,
    Bool
}

bool isAttributeTypeIntegral(HipAttributeType t) { return t > HipAttributeType.Float; }


struct HipVertexAttributeFieldInfo
{
    uint index;
    uint count;
    uint offset;
    uint typeSize;
    HipAttributeType valueType;
    bool isNormalized;
    string name;
}

struct HipVertexAttributeInfo
{
    ///Is that vertex attribute info used as instanced buffer.
    bool isInstanced;
    ///Buffer associated with this vertex info
    IHipRendererBuffer vbo;
    ///Accumulated size of the vertex data
    uint vboStride;
    ///How many data slots it uses, for instance, vec3 will count +3. Unused?
    uint dataCount;
    ///The fields describing the vertex
    HipVertexAttributeFieldInfo[] fields;
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
    void bind();
    void unbind();
    /**
    * GL also needs to bind both the vertex and index buffer before creatting the input layout
    * Direct3D 11 needs vertex shader information for creating a VAO
    * Metal needs a ShaderProgram for cerating a pipelinestate
    */
    void createInputLayout(
        HipVertexAttributeInfo[] info, IHipRendererBuffer ebo, ShaderProgram shaderProgram
    );
}

