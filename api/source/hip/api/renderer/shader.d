module hip.api.renderer.shader;
public import hip.api.renderer.operations;
public import hip.api.renderer.texture;
public import hip.api.renderer.shadervar;

enum ShaderStatus : ubyte
{
    SUCCESS,
    VERTEX_COMPILATION_ERROR,
    FRAGMENT_COMPILATION_ERROR,
    LINK_ERROR,
    UNKNOWN_ERROR
}

/** 
 * Used to define what is the input rate for shader buffer data
 */
enum ShaderInputRate : ubyte
{
    perVertex,
    perInstance
}

enum ShaderTypes : ubyte
{
    vertex,
    fragment,
    geometry, //Unsupported yet
    none
}

enum HipShaderPresets : ubyte
{
    FRAME_BUFFER,
    GEOMETRY_BATCH,
    SPRITE_BATCH,
    BITMAP_TEXT,
    NONE
}

/** 
 * This interface is currrently a Shader factory.
 */
abstract class IShader
{
    private bool* dirtyReference;
    final void setDirtyReference(bool* reference){ dirtyReference = reference; }
    final bool isDirty() { return *dirtyReference; }
    final void setDirty() { if(dirtyReference) *dirtyReference = true; }

    abstract ShaderProgram buildShader(string shaderSource, string shaderPath, bool isInstanced);

    abstract void setBlending(ShaderProgram prog, HipBlendFunction src, HipBlendFunction dst, HipBlendEquation eq);
    abstract void bind(ShaderProgram program);
    abstract void unbind(ShaderProgram program);
    abstract void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
    abstract int  getId(ref ShaderProgram prog, string name, ShaderVariablesLayout layout);
    

    abstract void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram);
    abstract bool setShaderVar(ShaderVar* sv, ShaderProgram prog, void* value);
    abstract void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[] layouts);

    /** 
     * Each graphics API has its own way to bind array of textures, thus, this version was required.
     */
    abstract void bindArrayOfTextures(ref ShaderProgram prog, IHipTexture[] textures, string varName);
    abstract void onRenderFrameEnd(ShaderProgram program);
}

abstract class ShaderProgram
{
    string name;
    abstract void dispose();
}