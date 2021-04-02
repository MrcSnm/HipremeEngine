module implementations.renderer.backend.gl.shader;
import std.conv:to;
import error.handler;
import bindbc.opengl;

struct FragmentShader{uint shader;}
struct VertexShader{uint shader;}
struct ShaderProgram{uint program;}

enum DEFAULT_FRAGMENT = q{
    #version 330 core
    
    out vec4 color;
    void main()
    {
        color = vec4(1.0f, 1.0f, 1.0f, 1.0f);
    }
};
enum DEFAULT_VERTEX = q{
    #version 330 core
    layout (location = 0) in vec3 aPos;
    
    void main()
    {
        gl_Position = vec4(aPos, 1.0f);
    }
};



FragmentShader createFragmentShader()
{
    FragmentShader fs;
    fs.shader = glCreateShader(GL_FRAGMENT_SHADER);
    return fs;
}

VertexShader createVertexShader()
{
    VertexShader vs;
    vs.shader = glCreateShader(GL_VERTEX_SHADER);
    return vs;
}
ShaderProgram createShaderProgram()
{
    ShaderProgram prog;
    prog.program = glCreateProgram();
    return prog;
}

bool compileShader(GLuint shaderID, string shaderSource)
{
    shaderSource~="\0";
    char* source = cast(char*)shaderSource.ptr; 
    glShaderSource(shaderID, 1, &source,  cast(GLint*)null);
    glCompileShader(shaderID);
    int success;
    char[512] infoLog;

    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &success);
    if(ErrorHandler.assertErrorMessage(success==true, "Shader compilation error", "Compilation failed"))
    {
        glGetShaderInfoLog(shaderID, 512, null, infoLog.ptr);
        ErrorHandler.showErrorMessage("Compilation error:", to!string(infoLog));
    }
    return success==true;
}
bool compileShader(VertexShader vs, string shaderSource){return compileShader(vs.shader, shaderSource);}
bool compileShader(FragmentShader fs, string shaderSource){return compileShader(fs.shader, shaderSource);}

bool linkProgram(ShaderProgram program, VertexShader vs,  FragmentShader fs)
{
    uint prog = program.program;

    glAttachShader(prog, vs.shader);
    glAttachShader(prog, fs.shader);
    glLinkProgram(prog);

    int success;
    char[512] infoLog;

    glGetProgramiv(prog, GL_LINK_STATUS, &success);

    if(ErrorHandler.assertErrorMessage(success==true, "Shader linking error", "Linking failed"))
    {
        glGetProgramInfoLog(prog, 512, null, infoLog.ptr);
        ErrorHandler.showErrorMessage("Linking error: ", to!string(infoLog));
    }
    
    return success==true;
}


/**
*   params:
*       layoutIndex: The layout index defined on shader
*       valueAmount: How many values using, for 3 vertices, you can use 3
*       dataType: Which data type to send
*       normalize: If it will normalize
*       stride: Target value amount in bytes, for instance, vec3 is float.sizeof*3
*       offset: It will be calculated for each value index
*       
*/
void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
{
    glVertexAttribPointer(layoutIndex, valueAmount, dataType, normalize, stride, cast(void*)offset);
    glEnableVertexAttribArray(layoutIndex);
}

void setCurrentShader(ShaderProgram program)
{
    glUseProgram(program.program);
}

void useShader(ShaderProgram program){glUseProgram(program.program);}
void deleteShader(FragmentShader* fs){glDeleteShader(fs.shader); fs.shader = 0;}
void deleteShader(VertexShader* vs){glDeleteShader(vs.shader); vs.shader = 0;}