module implementations.renderer.shader;
import bindbc.opengl;
import implementations.renderer.backend.gl.shader;
import implementations.renderer.shader;
import util.file;

enum ShaderStatus
{
    SUCCESS,
    VERTEX_COMPILATION_ERROR,
    FRAGMENT_COMPILATION_ERROR,
    LINK_ERROR,
    UNKNOWN_ERROR
}

enum ShaderTypes
{
    FLOAT,
    INT
}
enum HipShaderPresets
{
    DEFAULT,
    FRAME_BUFFER,
    GEOMETRY_BATCH,
    SPRITE_BATCH,
    NONE
}


interface IShader
{
    VertexShader createVertexShader();
    FragmentShader createFragmentShader();
    ShaderProgram createShaderProgram();

    bool compileShader(FragmentShader fs, string shaderSource);
    bool compileShader(VertexShader vs, string shaderSource);
    bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs);
    void setCurrentShader(ShaderProgram program);
    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
    int  getId(ref ShaderProgram prog, string name);

    final void setVar(T)(ref ShaderProgram prog, string name, T value)
    {
        int id = getId(prog, name);
        setVar(id, value);
    }
    void setVar(int id, int val);
    void setVar(int id, bool val);
    void setVar(int id, float val);
    void setVar(int id, float[2] val); ///Vec2
    void setVar(int id, float[3] val); ///Vec3
    void setVar(int id, float[4] val); ///Vec4
    void setVar(int id, float[9] val); ///Matrix3
    void setVar(int id, float[16] val); ///Matrix4
    void deleteShader(FragmentShader* fs);
    void deleteShader(VertexShader* vs);

}

abstract class VertexShader
{
    abstract string getDefaultVertex();
    abstract string getFrameBufferVertex();
    abstract string getGeometryBatchVertex();
    abstract string getSpriteBatchVertex();
}
abstract class FragmentShader
{
    abstract string getDefaultFragment();
    abstract string getFrameBufferFragment();
    abstract string getGeometryBatchFragment();
    abstract string getSpriteBatchFragment();
}

abstract class ShaderProgram{}


public class Shader
{
    VertexShader vertexShader;
    FragmentShader fragmentShader;
    ShaderProgram shaderProgram;
    //Optional
    IShader shaderImpl;
    string fragmentShaderPath;
    string vertexShaderPath;

    this(IShader shaderImpl)
    {
        this.shaderImpl = shaderImpl;
        vertexShader = shaderImpl.createVertexShader();
        fragmentShader = shaderImpl.createFragmentShader();
        shaderProgram = shaderImpl.createShaderProgram();
    }
    this(IShader shaderImpl, string vertexSource, string fragmentSource)
    {
        this(shaderImpl);
        ShaderStatus status = loadShaders(vertexSource, fragmentSource);
        if(status != ShaderStatus.SUCCESS)
        {
            import def.debugging.log;
            logln("Failed loading shaders");
        }
    }

    void setFromPreset(HipShaderPresets preset = HipShaderPresets.DEFAULT)
    {
        ShaderStatus status = ShaderStatus.SUCCESS;
        switch(preset) with(HipShaderPresets)
        {
            case SPRITE_BATCH:
                status = loadShaders(vertexShader.getSpriteBatchVertex(), fragmentShader.getSpriteBatchFragment());
                break;
            case FRAME_BUFFER:
                status = loadShaders(vertexShader.getFrameBufferVertex(), fragmentShader.getFrameBufferFragment());
                break;
            case GEOMETRY_BATCH:
                status = loadShaders(vertexShader.getGeometryBatchVertex(), fragmentShader.getGeometryBatchFragment());
                break;
            case DEFAULT:
                status = loadShaders(vertexShader.getDefaultVertex(),fragmentShader.getDefaultFragment());
                break;
            case NONE:
            default:
                break;
        }
        if(status != ShaderStatus.SUCCESS)
        {
            import def.debugging.log;
            logln("Failed loading shaders");
        }
    }

    ShaderStatus loadShaders(string vertexShaderSource, string fragmentShaderSource)
    {
        if(!shaderImpl.compileShader(vertexShader, vertexShaderSource))
            return ShaderStatus.VERTEX_COMPILATION_ERROR;
        if(!shaderImpl.compileShader(fragmentShader, fragmentShaderSource))
            return ShaderStatus.FRAGMENT_COMPILATION_ERROR;
        if(!shaderImpl.linkProgram(shaderProgram, vertexShader, fragmentShader))
            return ShaderStatus.LINK_ERROR;
        deleteShaders();
        return ShaderStatus.SUCCESS;
    }

    ShaderStatus loadShadersFromFiles(string vertexShaderPath, string fragmentShaderPath)
    {
        this.vertexShaderPath = vertexShaderPath;
        this.fragmentShaderPath = fragmentShaderPath;
        return loadShaders(getFileContent(vertexShaderPath), getFileContent(fragmentShaderPath));
    }

    ShaderStatus reloadShaders()
    {
        return loadShadersFromFiles(this.vertexShaderPath, this.fragmentShaderPath);
    }

    void setVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {
        shaderImpl.sendVertexAttribute(layoutIndex, valueAmount, dataType, normalize, stride, offset);
    }

    void setVar(T)(string name, T val)
    {
        shaderImpl.setVar(this.shaderProgram, name, val);
    }
    public void setVar(T)(int id, T val)
    {
        shaderImpl.setVar(id, val);
    }

    void bind()
    {
        shaderImpl.setCurrentShader(shaderProgram);
    }


    protected void deleteShaders()
    {
        shaderImpl.deleteShader(&fragmentShader);
        shaderImpl.deleteShader(&vertexShader);
    }

}