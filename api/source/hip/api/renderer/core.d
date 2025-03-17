module hip.api.renderer.core;
public import hip.api.input.window;
public import hip.api.renderer.vertex;
public import hip.api.renderer.operations;
public import hip.api.renderer.viewport;
public import hip.api.renderer.texture;
public import hip.api.renderer.framebuffer;
public import hip.api.renderer.shader;
public import hip.api.renderer.shadervar;


///Could later be moved to windowing
enum HipWindowMode
{
    WINDOWED,
    FULLSCREEN,
    BORDERLESS_FULLSCREEN
}


/**
 * Maybe should not be used in user facing api.
 */
pragma(LDC_no_typeinfo)
struct DefaultShader
{
    ///Path on where the shaders are stored.
    string path;
    ///Vertex Source
    string function() vSource;
    ///Fragment Source
    string function() fSource;
}

pragma(LDC_no_typeinfo)
struct HipRendererInfo
{
    HipRendererType type;
    size_t function(ShaderTypes, UniformType) uniformMapper;
}

///Which API is being used
enum HipRendererType
{
    GL3,
    D3D11,
    METAL,
    NONE
}


/// Primitive which the renderer will use
enum HipRendererMode
{
    POINT,
    LINE,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP
}




//////////////////////////////////////////Metadata//////////////////////////////////////////

//Shaders
enum HipShaderInputLayout;
/**
*   Use this special UDA to say this type is only for accumulating stride and thus should not
*   be defined on shader
*/
enum HipShaderInputPadding;
/**
*   Declares that the struct is as VertexUniform block.
*/
pragma(LDC_no_typeinfo)
struct HipShaderVertexUniform
{
    /**
    *   This name is the base uniform name accessed when dealing with HLSL Api.
    *   i.e: Constant Buffer block name
    */
    string name;
}
/**
*   Declares that the struct is as FragmentUniform block.
*/
pragma(LDC_no_typeinfo)
struct HipShaderFragmentUniform
{
    /**
    *   This name is the base uniform name accessed when dealing with HLSL Api.
    *   i.e: Constant Buffer block name
    */
    string name;
}

/**
*   Minimal interface for another API implementation
*/
interface IHipRendererImpl
{
    public bool init(IHipWindow window);
    version(dll){public bool initExternal();}
    public bool isRowMajor();
    void setErrorCheckingEnabled(bool enable = true);
    public IShader createShader();
    size_t function(ShaderTypes shaderType, UniformType uniformType) getShaderVarMapper();
    public IHipFrameBuffer createFrameBuffer(int width, int height);
    public IHipVertexArrayImpl  createVertexArray();
    public IHipRendererBuffer createBuffer(size_t size, HipBufferUsage usage, HipRendererBufferType type);
    public IHipTexture  createTexture();
    public int queryMaxSupportedPixelShaderTextures();
    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void setViewport(Viewport v);
    public bool setWindowMode(HipWindowMode mode);
    public void setDepthTestingEnabled(bool);
    public void setDepthTestingFunction(HipDepthTestingFunction);
    public void setStencilTestingEnabled(bool);
    public void setStencilTestingMask(uint mask);
    public void setColorMask(ubyte r, ubyte g, ubyte b, ubyte a);
    ///When pass func evaluates to true, then it is said to be passed
    public void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask);
    public void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass);
    public bool hasErrorOccurred(out string err, string line = __FILE__, size_t line =__LINE__);
    public void begin();
    public void setRendererMode(HipRendererMode mode);
    public void drawIndexed(index_t count, uint offset = 0);
    public void drawVertices(index_t count, uint offset = 0);
    public void end();
    public void clear();
    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
    public void dispose();
}