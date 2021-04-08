module implementations.renderer.backend.gl.shader;
import implementations.renderer.shader;
import std.conv:to;
import error.handler;
import bindbc.opengl;

class Hip_GL3_FragmentShader : FragmentShader
{
    uint shader;
    override final string getDefaultFragment()
    {
        return q{
            #version 330 core
        
            out vec4 color;
            void main()
            {
                color = vec4(1.0f, 1.0f, 1.0f, 1.0f);
            }
        };
    }
}
class Hip_GL3_VertexShader : VertexShader
{
    uint shader;

    override final string getDefaultVertex()
    {
        return q{
            #version 330 core
            layout (location = 0) in vec3 aPos;
            
            void main()
            {
                gl_Position = vec4(aPos, 1.0f);
            }
        };
    }
}
class Hip_GL3_ShaderProgram : ShaderProgram{uint program;}

class Hip_GL3_ShaderImpl : IShader
{
    FragmentShader createFragmentShader()
    {
        Hip_GL3_FragmentShader fs = new Hip_GL3_FragmentShader();
        fs.shader = glCreateShader(GL_FRAGMENT_SHADER);
        return fs;
    }

    VertexShader createVertexShader()
    {
        Hip_GL3_VertexShader vs = new Hip_GL3_VertexShader();
        vs.shader = glCreateShader(GL_VERTEX_SHADER);
        return vs;
    }
    ShaderProgram createShaderProgram()
    {
        Hip_GL3_ShaderProgram prog = new Hip_GL3_ShaderProgram();
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
    bool compileShader(VertexShader vs, string shaderSource)
    {
        return compileShader((cast(Hip_GL3_VertexShader)vs).shader, shaderSource);
    }
    bool compileShader(FragmentShader fs, string shaderSource)
    {
        return compileShader((cast(Hip_GL3_FragmentShader)fs).shader, shaderSource);
    }

    bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs)
    {
        uint prog = (cast(Hip_GL3_ShaderProgram)program).program;

        glAttachShader(prog, (cast(Hip_GL3_VertexShader)vs).shader);
        glAttachShader(prog, (cast(Hip_GL3_FragmentShader)fs).shader);
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
    void setVar(T)(ref ShaderProgram prog, string name, T val)
    {
        int varID = glGetUniformLocation((cast(Hip_GL3_ShaderProgram)prog).program, name.ptr);
        setVarImpl(varID, val);
    }
    void setVar(T)(int id, T val)
    {
        setVarImpl(id, val);
    }
    pragma(inline, true)
    protected void setVarImpl(T)(int id, T val)
    {
        static if(is(T == int))
        {
            glUniform1i(id, val);
        }
        else static if(is(T == bool))
        {
            glUniform1i(id, val);
        }
        else static if(is(T == float))
        {
            glUniform1f(id, val);
        }
        else static if(is(T == double))
        {
            glUniform1d(id, val);
        }
        else static if(T.sizeof == float.sizeof * 2)
        {
            glUniform2f(id,
            *(cast(float*)(&val)),
            *(cast(float*)(&val) + 1));
        }
        else static if(T.sizeof == float.sizeof * 3)
        {
            glUniform3f(id,
            *(cast(float*)(&val)),
            *(cast(float*)(&val) + 1),
            *(cast(float*)(&val) + 2));
        }
        else static if(T.sizeof == float.sizeof * 4)
        {
            glUniform4f(id,
            *(cast(float*)(&val)),
            *(cast(float*)(&val) + 1),
            *(cast(float*)(&val) + 2),
            *(cast(float*)(&val) + 3));
        }

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
        glUseProgram((cast(Hip_GL3_ShaderProgram)program).program);
    }

    void useShader(ShaderProgram program){glUseProgram((cast(Hip_GL3_ShaderProgram)program).program);}
    void deleteShader(FragmentShader* _fs)
    {
        auto fs = cast(Hip_GL3_FragmentShader)*_fs;
        glDeleteShader(fs.shader); fs.shader = 0;
    }
    void deleteShader(VertexShader* _vs)
    {
        auto vs = cast(Hip_GL3_VertexShader)*_vs;
        glDeleteShader(vs.shader); vs.shader = 0;
    }
}