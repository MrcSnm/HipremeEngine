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

///Type safe pointer to a Shader so it can be sent to setSpriteBatcShader
struct ShaderHandle
{
    void* _this;

    auto shader()()
    {
        import hip.game.shader;
        return cast(Shader)_this;
    }
}

abstract class HipShaderProgram
{
    string name;
    private bool* dirtyReference;
    final void setDirtyReference(bool* reference){ dirtyReference = reference; }
    final bool isDirty() { return *dirtyReference; }
    final void setDirty() { if(dirtyReference) *dirtyReference = true; }

    abstract bool buildShader(string shaderSource, string shaderPath, bool isInstanced);
    abstract void setBlending(HipBlendFunction src, HipBlendFunction dst, HipBlendEquation eq);
    abstract void bind();
    abstract void unbind();
    abstract int  getId(string name, ShaderVariablesLayout layout);
    

    abstract void createVariablesBlock(ref ShaderVariablesLayout layout);
    abstract bool setShaderVar(ShaderVar* sv, void* value);
    abstract void sendVars(ShaderVariablesLayout[] layouts);

    abstract void dispose();
    /** 
     * Each graphics API has its own way to bind array of textures, thus, this version was required.
     */
    abstract void bindArrayOfTextures(IHipTexture[] textures, string varName);
    abstract void onRenderFrameEnd();
}