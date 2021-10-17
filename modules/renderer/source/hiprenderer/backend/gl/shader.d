/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hiprenderer.backend.gl.shader;
import hiprenderer.backend.gl.renderer;
import hiprenderer.shader;
import hiprenderer.renderer;
import hiprenderer.shader.shadervar;
import util.conv;
import error.handler;

version(Android)
{
    enum shaderVersion = "#version 300 es";
    enum floatPrecision = "";
    // enum floatPrecision = "precision mediump;";
}
else
{
    enum shaderVersion = "#version 330 core";
    enum floatPrecision = "";
}

class Hip_GL3_FragmentShader : FragmentShader
{
    uint shader;
    override final string getDefaultFragment()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            uniform vec4 globalColor;
            in vec4 vertexColor;
            in vec2 tex_uv;
            uniform sampler2D tex1;
            out vec4 outPixelColor;

            void main()
            {
                outPixelColor = vertexColor*globalColor*texture(tex1, tex_uv);
            }
        };
    }
    override final string getFrameBufferFragment()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            

            in vec2 inTexST;
            uniform sampler2D uBufferTexture;
            uniform vec4 uColor;
            out vec4 outPixelColor;

            void main()
            {
                vec4 col = texture(uBufferTexture, inTexST);
                float grey = (col.r+col.g+col.b)/3.0;
                outPixelColor = grey * uColor;
            }
        };
    }
    override final string getSpriteBatchFragment()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            uniform sampler2D uTex1[}~to!string(HipRenderer.getMaxSupportedShaderTextures())~q{];

            uniform vec4 uBatchColor;

            in vec4 inVertexColor;
            in vec2 inTexST;
            in float inTexID;

            out vec4 outPixelColor;
            void main()
            {
                int texId = int(inTexID);
                outPixelColor = texture(uTex1[texId], inTexST)* inVertexColor * uBatchColor;
                // outPixelColor = vec4(texId, texId, texId, 1.0)* inVertexColor * uBatchColor;
            }
        };
    }

    override final string getGeometryBatchFragment()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            

            uniform vec4 uGlobalColor;
            in vec4 inVertexColor;
            out vec4 outPixelColor;

            void main()
            {
                outPixelColor = inVertexColor * uGlobalColor;
            }
        };
    }

    override final string getBitmapTextFragment()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            

            uniform vec4 uColor;
            uniform sampler2D uTex;
            in vec2 inTexST;
            out vec4 outPixelColor;

            void main()
            {
                outPixelColor = texture(uTex, inTexST)*uColor;
            }
        };
    }
}
class Hip_GL3_VertexShader : VertexShader
{
    uint shader;

    override final string getDefaultVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            layout (location = 0) in vec3 position;
            layout (location = 1) in vec4 color;
            layout (location = 2) in vec2 texCoord;
            uniform mat4 proj;


            out vec4 vertexColor;
            out vec2 tex_uv;

            void main()
            {
                gl_Position = proj*vec4(position, 1.0f);
                vertexColor = color;
                tex_uv = texCoord;
            }
        };
    }
    override final string getFrameBufferVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            layout (location = 0) in vec2 vPosition;
            layout (location = 1) in vec2 vTexST;

            out vec2 inTexST;

            void main()
            {
                gl_Position = vec4(vPosition, 0.0, 1.0);
                inTexST = vTexST;
            }
        };
    }
    override final string getSpriteBatchVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            layout (location = 0) in vec3 vPosition;
            layout (location = 1) in vec4 vColor;
            layout (location = 2) in vec2 vTexST;
            layout (location = 3) in float vTexID;

            uniform mat4 uProj;
            uniform mat4 uModel;
            uniform mat4 uView;
            
            out vec4 inVertexColor;
            out vec2 inTexST;
            out float inTexID;

            void main()
            {
                gl_Position = uProj*uView*uModel*vec4(vPosition, 1.0f);
                inVertexColor = vColor;
                inTexST = vTexST;
                inTexID = vTexID;
            }
        };
    }
    override final string getGeometryBatchVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            layout (location = 0) in vec3 vPosition;
            layout (location = 1) in vec4 vColor;

            uniform mat4 uProj;
            uniform mat4 uModel;
            uniform mat4 uView;
            
            out vec4 inVertexColor;

            void main()
            {
                gl_Position = uProj*uView*uModel*vec4(vPosition, 1.0f);
                inVertexColor = vColor;
            }
        };
    }

    override final string getBitmapTextVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{
            
            layout (location = 0) in vec2 vPos;
            layout (location = 1) in vec2 vTexST;

            uniform mat4 uModel;
            uniform mat4 uView;
            uniform mat4 uProj;

            out vec2 inTexST;

            void main()
            {
                gl_Position = uProj * uView * uModel * vec4(vPos, 1.0, 1.0);
                inTexST = vTexST;
            }
        };
    }
}
class Hip_GL3_ShaderProgram : ShaderProgram{uint program;}

class Hip_GL3_ShaderImpl : IShader
{
    import util.data_structures:Pair;
    protected ShaderVariablesLayout[] layouts;
    protected Pair!(ShaderVariablesLayout, uint)[] ubos;
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
            ErrorHandler.showErrorMessage("Compilation error:", cast(string)(infoLog));
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
            ErrorHandler.showErrorMessage("Linking error: ", cast(string)(infoLog));
        }
        
        return success==true;
    }
    int getId(ref ShaderProgram prog, string name)
    {
        int varID = glGetUniformLocation((cast(Hip_GL3_ShaderProgram)prog).program, name.ptr);
        if(varID < 0)
        {
            ErrorHandler.showErrorMessage("Uniform not found",
            "Variable named '"~name~"' does not exists in the shader");
        }
        return varID;
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


    void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts)
    {
        foreach(l; layouts)
        {
            foreach (v; l.variables)
            {
                int id = getId(prog, v.sVar.name);
                final switch(v.sVar.type) with(UniformType)
                {
                    case boolean:
                        glUniform1i(id, v.sVar.get!bool);
                        break;
                    case integer:
                        glUniform1i(id, v.sVar.get!int);
                        break;
                    case integer_array:
                        int[] temp = v.sVar.get!(int[]);
                        glUniform1iv(id, cast(int)temp.length, temp.ptr);
                        break;
                    case uinteger:
                        glUniform1ui(id, v.sVar.get!uint);
                        break;
                    case uinteger_array:
                        uint[] temp = v.sVar.get!(uint[]);
                        glUniform1uiv(id, cast(int)temp.length, temp.ptr);
                        break;
                    case floating:
                        glUniform1f(id, v.sVar.get!float);
                        break;
                    case floating2:
                        float[2] temp = v.sVar.get!(float[2]);
                        glUniform2f(id, temp[0], temp[1]);
                        break;
                    case floating3:
                        float[3] temp = v.sVar.get!(float[3]);
                        glUniform3f(id, temp[0], temp[1], temp[2]);
                        break;
                    case floating4:
                        float[4] temp = v.sVar.get!(float[4]);
                        glUniform4f(id, temp[0], temp[1], temp[2], temp[3]);
                        break;
                    case floating2x2:
                        glUniformMatrix2fv(id, 1, GL_FALSE, cast(float*)v.sVar.get!(float[4]).ptr);
                        break;
                    case floating3x3:
                        glUniformMatrix3fv(id, 1, GL_FALSE, cast(float*)v.sVar.get!(float[9]).ptr);
                        break;
                    case floating4x4:
                        glUniformMatrix4fv(id, 1, GL_FALSE, cast(float*)v.sVar.get!(float[16]).ptr);
                        break;
                    case floating_array:
                        float[] temp = v.sVar.get!(float[]);
                        glUniform1fv(id, cast(int)temp.length, temp.ptr);
                        break;
                    case none:break;
                }
            }
        }
                
    }

    void initTextureSlots(ref ShaderProgram prog, Texture texture, string varName, int slotsCount)
    {
        setCurrentShader(prog);
        int varID = getId(prog, varName);
        int[] temp = new int[](slotsCount);
        for(int i = 0; i < slotsCount; i++)
            temp[i] = i;
        glUniform1iv(varID, slotsCount, temp.ptr);
        destroy(temp);
    }
    void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        if(layout.hint & ShaderHint.GL_USE_BLOCK)
        {
            uint ubo;
            glGenBuffers(1, &ubo);
            glBindBuffer(GL_UNIFORM_BUFFER, ubo);
            glBufferData(GL_UNIFORM_BUFFER, layout.getLayoutSize(), null, GL_DYNAMIC_DRAW);
            glBindBuffer(GL_UNIFORM_BUFFER, 0);
            ubos~= Pair!(ShaderVariablesLayout, uint)(layout, ubo);
        }
    }
    protected void updateUbo(ref Pair!(ShaderVariablesLayout, int) ubo)
    {
        glBindBuffer(GL_UNIFORM_BUFFER, ubo.b);
        glBufferSubData(GL_UNIFORM_BUFFER, 0, ubo.a.getLayoutSize(), ubo.a.getBlockData());
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
    }

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
    void dispose(ref ShaderProgram prog)
    {
        Hip_GL3_ShaderProgram p = cast(Hip_GL3_ShaderProgram)prog;
        glDeleteProgram(p.program);

        foreach (ub; ubos)
            glDeleteBuffers(1, &ub.b);
        ubos.length = 0;
    }
}