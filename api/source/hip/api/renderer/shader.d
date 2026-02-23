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
interface IShader
{
    VertexShader createVertexShader();
    FragmentShader createFragmentShader();
    ShaderProgram createShaderProgram();

    bool compileShader(FragmentShader fs, string shaderSource);
    bool compileShader(VertexShader vs, string shaderSource);
    bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs);

    void setBlending(ShaderProgram prog, HipBlendFunction src, HipBlendFunction dst, HipBlendEquation eq);
    void bind(ShaderProgram program);
    void unbind(ShaderProgram program);
    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
    int  getId(ref ShaderProgram prog, string name, ShaderVariablesLayout layout);
    

    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(FragmentShader* fs);
    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(VertexShader* vs);

    void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram);
    bool setShaderVar(ShaderVar* sv, ShaderProgram prog, void* value);
    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts);

    /** 
     * Each graphics API has its own way to bind array of textures, thus, this version was required.
     */
    void bindArrayOfTextures(ref ShaderProgram prog, IHipTexture[] textures, string varName);
    void dispose(ref ShaderProgram);

    void onRenderFrameEnd(ShaderProgram program);
}

abstract class VertexShader
{
}
abstract class FragmentShader
{
}

abstract class ShaderProgram
{
    string name;
}