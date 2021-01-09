module implementations.renderer.shader;
import bindbc.opengl;
import implementations.renderer.shaderimpl.glshader;
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

public class Shader
{
    VertexShader vertexShader;
    FragmentShader fragmentShader;
    ShaderProgram shaderProgram;
    //Optional
    string fragmentShaderPath;
    string vertexShaderPath;

    this(bool createDefault = true)
    {
        vertexShader = createVertexShader();
        fragmentShader = createFragmentShader();
        shaderProgram = createShaderProgram();
        if(createDefault)
        {
            loadShaders(DEFAULT_VERTEX, DEFAULT_FRAGMENT);
        }
    }

    int loadShaders(string vertexShaderSource, string fragmentShaderSource)
    {
        if(!compileShader(vertexShader, vertexShaderSource))
            return ShaderStatus.VERTEX_COMPILATION_ERROR;
        if(!compileShader(fragmentShader, fragmentShaderSource))
            return ShaderStatus.FRAGMENT_COMPILATION_ERROR;
        if(!linkProgram(shaderProgram, vertexShader, fragmentShader))
            return ShaderStatus.LINK_ERROR;
        deleteShaders();
        return ShaderStatus.SUCCESS;
    }

    int loadShadersFromFiles(string vertexShaderPath, string fragmentShaderPath)
    {
        this.vertexShaderPath = vertexShaderPath;
        this.fragmentShaderPath = fragmentShaderPath;
        return loadShaders(getFileContent(vertexShaderPath), getFileContent(fragmentShaderPath));
    }

    int reloadShaders()
    {
        return loadShadersFromFiles(this.vertexShaderPath, this.fragmentShaderPath);
    }

    void setVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {
        sendVertexAttribute(layoutIndex, valueAmount, dataType, normalize, stride, offset);
    }


    protected void deleteShaders()
    {
        deleteShader(&fragmentShader);
        deleteShader(&vertexShader);
    }

}