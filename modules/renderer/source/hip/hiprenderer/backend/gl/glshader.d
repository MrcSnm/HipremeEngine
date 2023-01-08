/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.glshader;
version(Android)
{
    enum shaderVersion = "#version 300 es";
    enum floatPrecision = "";
    // enum floatPrecision = "precision mediump;";
}
else version(WebAssembly)
{
    enum shaderVersion = "#version 100";
    enum floatPrecision = "precision mediump float;";
}
else
{
    enum shaderVersion = "#version 330 core";
    enum floatPrecision = "";
}

version(OpenGL):
import hip.api.renderer.texture;
import hip.hiprenderer.backend.gl.glrenderer;
import hip.hiprenderer.shader;
import hip.hiprenderer.renderer;
import hip.hiprenderer.shader.shadervar;
import hip.util.conv;
import hip.util.format: fastUnsafeCTFEFormat, format;
import hip.error.handler;



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

    version(WebAssembly) //They are very different, so, better to keep them separate
    {
        override final string getSpriteBatchFragment()
        {
            int sup = HipRenderer.getMaxSupportedShaderTextures();
            string textureSlotSwitchCase;
            for(int i = 0; i < sup; i++)
            {
                string strI = to!string(i);
                if(i != 0)
                    textureSlotSwitchCase~="\t\t\t\telse ";
                textureSlotSwitchCase~="if(texId == "~strI~")"~
                "{gl_FragColor = texture2D(uTex1["~strI~"], inTexST)*inVertexColor*uBatchColor;}\n";
            }
            textureSlotSwitchCase~="}\n";
            enum shaderSource = q{
                uniform vec4 uBatchColor;

                varying vec4 inVertexColor;
                varying vec2 inTexST;
                varying float inTexID;

                void main()
            };
            return shaderVersion~"\n"~floatPrecision~"\n"~format!q{
                    uniform sampler2D uTex1[%s];}(sup)~
                shaderSource~
            "{"~q{
                    int texId = int(inTexID);
            }~ textureSlotSwitchCase;
        }
    }
    else
    {
        override final string getSpriteBatchFragment()
        {
            int sup = HipRenderer.getMaxSupportedShaderTextures();
            //Push the line breaks for easier debugging on gpu debugger
            string textureSlotSwitchCase = "switch(texId)\n{\n"; 
            for(int i = 0; i < sup; i++)
            {
                string strI = to!string(i);
                textureSlotSwitchCase~="case "~strI~": "~
                "\t\toutPixelColor = texture(uTex1["~strI~"], inTexST)*inVertexColor*uBatchColor;break;\n";
            }
            textureSlotSwitchCase~="}\n";

                enum shaderSource = q{

                    uniform vec4 uBatchColor;

                    in vec4 inVertexColor;
                    in vec2 inTexST;
                    in float inTexID;

                    out vec4 outPixelColor;
                    void main()
                };
            return shaderVersion~"\n"~floatPrecision~"\n"~format!q{
                    uniform sampler2D uTex1[%s];}(sup)~
                shaderSource~
            "{"~q{
                    int texId = int(inTexID);
            } ~textureSlotSwitchCase~
            "}";
            // outPixelColor = texture(uTex1[texId], inTexST)* inVertexColor * uBatchColor;
            // outPixelColor = vec4(texId, texId, texId, 1.0)* inVertexColor * uBatchColor;
        }

    }


    override final string getGeometryBatchFragment()
    {
        version(WebAssembly)
        {
            enum attr1 = q{varying};
            enum outputPixelVar = q{};
            enum outputAssignment = q{gl_FragColor};
        }
        else
        {
            enum attr1 = q{in};
            enum outputPixelVar = q{out vec4 pixelColor;};
            enum outputAssignment = q{outPixelColor};
        }
        enum shaderSource = q{
            uniform vec4 uGlobalColor;
            %s vec4 inVertexColor;
            %s

            void main()
            {
                %s = inVertexColor * uGlobalColor;
            }
        }.fastUnsafeCTFEFormat(attr1, outputPixelVar, outputAssignment);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }

    override final string getBitmapTextFragment()
    {
        version(WebAssembly)
        {
            enum attr1 = q{varying};
            enum outputPixelVar = q{};
            enum outputAssignment = q{gl_FragColor};
        }
        else
        {
            enum attr1 = q{in};
            enum outputPixelVar = q{out vec4 outPixelColor};
            enum outputAssignment = q{outPixelColor};
        }
        enum shaderSource = q{
            

            uniform vec4 uColor;
            uniform sampler2D uTex;
            %s vec2 inTexST;
            %s

            void main()
            {
                float r = texture2D(uTex, inTexST).r;
                %s = vec4(r,r,r,r)*uColor;
            }
        }.fastUnsafeCTFEFormat(attr1, outputPixelVar, outputAssignment);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
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
                gl_Position = proj*vec4(position, 1.0);
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
        version(GLES20) //`in` representation in GLES 20 is `attribute``
        {
            enum attr1 = q{attribute};
            enum attr2 = q{attribute};
            enum attr3 = q{attribute};
            enum attr4 = q{attribute};
            enum out1 = q{varying};
            enum out2 = q{varying};
            enum out3 = q{varying};
        }
        else
        {
            enum attr1 = q{layout (location = 0) in};
            enum attr2 = q{layout (location = 1) in};
            enum attr3 = q{layout (location = 2) in};
            enum attr4 = q{layout (location = 3) in};
            enum out1 = q{out};
            enum out2 = q{out};
            enum out3 = q{out};
        }
        enum shaderSource = q{
            
            %s vec3 vPosition;
            %s vec4 vColor;
            %s vec2 vTexST;
            %s float vTexID;

            uniform mat4 uProj;
            uniform mat4 uModel;
            uniform mat4 uView;
            
            %s vec4 inVertexColor;
            %s vec2 inTexST;
            %s float inTexID;

            void main()
            {
                gl_Position = uProj*uView*uModel*vec4(vPosition, 1.0);
                inVertexColor = vColor;
                inTexST = vTexST;
                inTexID = vTexID;
            }
        }.fastUnsafeCTFEFormat(attr1, attr2, attr3, attr4, out1, out2, out3);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }
    override final string getGeometryBatchVertex()
    {
        version(WebAssembly)
        {
            enum attr1 = q{attribute};
            enum attr2 = q{attribute};
            enum out1 = q{varying};
        }
        else
        {
            enum attr1 = q{layout (location = 0) in};
            enum attr2 = q{layout (location = 1) in};
            enum out1 = q{out};
        }

        enum shaderSource = q{
            
            %s vec3 vPosition;
            %s vec4 vColor;

            uniform mat4 uProj;
            uniform mat4 uModel;
            uniform mat4 uView;
            
            %s vec4 inVertexColor;

            void main()
            {
                gl_Position = uProj*uView*uModel*vec4(vPosition, 1.0);
                inVertexColor = vColor;
            }
        }.fastUnsafeCTFEFormat(attr1, attr2, out1);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }

    override final string getBitmapTextVertex()
    {
        version(WebAssembly)
        {
            enum attr1 = q{attribute};
            enum attr2 = q{attribute};
            enum out1 = q{varying};
        }
        else
        {
            enum attr1 = q{layout (location = 0) in};
            enum attr2 = q{layout (location = 1) in};
            enum out1 = q{out};
        }
        enum shaderSource = q{
            
            %s vec2 vPosition;
            %s vec2 vTexST;

            uniform mat4 uModel;
            uniform mat4 uView;
            uniform mat4 uProj;

            %s vec2 inTexST;

            void main()
            {
                gl_Position = uProj * uView * uModel * vec4(vPosition, 1.0, 1.0);
                inTexST = vTexST;
            }
        }.fastUnsafeCTFEFormat(attr1, attr2, out1);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }
}
class Hip_GL3_ShaderProgram : ShaderProgram
{
    bool isUsingUbo;
    uint program;
}


class Hip_GL_ShaderImpl : IShader
{
    import hip.util.data_structures:Pair;
    protected ShaderVariablesLayout[] layouts;
    FragmentShader createFragmentShader()
    {
        Hip_GL3_FragmentShader fs = new Hip_GL3_FragmentShader();
        fs.shader = glCreateShader(GL_FRAGMENT_SHADER);
        HipRenderer.exitOnError();
        return fs;
    }

    VertexShader createVertexShader()
    {
        Hip_GL3_VertexShader vs = new Hip_GL3_VertexShader();
        vs.shader = glCreateShader(GL_VERTEX_SHADER);
        HipRenderer.exitOnError();
        return vs;
    }
    ShaderProgram createShaderProgram()
    {
        Hip_GL3_ShaderProgram prog = new Hip_GL3_ShaderProgram();
        prog.program = glCreateProgram();
        HipRenderer.exitOnError();
        return prog;
    }
    bool compileShader(GLuint shaderID, string shaderSource)
    {
        shaderSource~="\0";
        char* source = cast(char*)shaderSource.ptr; 
        glCall(() =>glShaderSource(shaderID, 1, &source,  cast(GLint*)null));
        glCall(() =>glCompileShader(shaderID));
        int success;
        
        glCall(() => glGetShaderiv(shaderID, GL_COMPILE_STATUS, &success));
        if(ErrorHandler.assertErrorMessage(success==true, "Shader compilation error", "Compilation failed"))
        {
            import core.stdc.stdlib;
            char[] infoLog;
            version(WebAssembly)
            {
                {
                    GLint length = 0;
                    ubyte* temp = glCall(() => wglGetShaderInfoLog(shaderID));
                    length = *cast(GLint*)temp;
                    infoLog = cast(char[])temp[size_t.sizeof..+size_t.sizeof + length];
                }
            }
            else
            {
                {
                    GLint length = 0;
                    glCall(() => glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &length));
                    infoLog = cast(char[])malloc(length)[0..length];
                    glCall(() =>glGetShaderInfoLog(shaderID, length, &length, infoLog.ptr));
                }
            }
            ErrorHandler.showErrorMessage("Error on shader source: ", shaderSource);
            ErrorHandler.showErrorMessage("Compilation error:", cast(string)(infoLog));
            version(WebAssembly)
                free(infoLog.ptr - GLint.sizeof); //Remember that the pointer started in length.
            else
                free(infoLog.ptr);
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

        glCall(() =>glAttachShader(prog, (cast(Hip_GL3_VertexShader)vs).shader));
        glCall(() =>glAttachShader(prog, (cast(Hip_GL3_FragmentShader)fs).shader));
        glCall(() =>glLinkProgram(prog));
        
        int success;
        char[512] infoLog;

        glCall(() =>glGetProgramiv(prog, GL_LINK_STATUS, &success));

        if(ErrorHandler.assertErrorMessage(success==true, "Shader linking error", "Linking failed"))
        {
            glCall(() => glGetProgramInfoLog(prog, 512, null, infoLog.ptr));
            ErrorHandler.showErrorMessage("Linking error: ", cast(string)(infoLog));
        }
        
        return success==true;
    }
    int getId(ref ShaderProgram prog, string name)
    {
        int varID = glCall(() =>glGetUniformLocation((cast(Hip_GL3_ShaderProgram)prog).program, cast(char*)name.ptr)); //Immutable anyway
        if(varID < 0)
        {
            ErrorHandler.showErrorMessage("Uniform not found",
            "Variable named '"~name~"' does not exists in shader "~prog.name);
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
        glCall(() =>glVertexAttribPointer(layoutIndex, valueAmount, dataType, normalize, stride, cast(void*)offset));
        glCall(() =>glEnableVertexAttribArray(layoutIndex));
    }

    void setCurrentShader(ShaderProgram program)
    {
        glCall(() =>glUseProgram((cast(Hip_GL3_ShaderProgram)program).program));
    }

    void useShader(ShaderProgram program){glCall(() =>glUseProgram((cast(Hip_GL3_ShaderProgram)program).program));}


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
                        glCall(() => glUniform1i(id, v.sVar.get!bool));
                        break;
                    case integer:
                        glCall(() => glUniform1i(id, v.sVar.get!int));
                        break;
                    case integer_array:
                        int[] temp = v.sVar.get!(int[]);
                        glCall(() =>glUniform1iv(id, cast(int)temp.length, temp.ptr));
                        break;
                    case uinteger:
                        glCall(() =>glUniform1ui(id, v.sVar.get!uint));
                        break;
                    case uinteger_array:
                        uint[] temp = v.sVar.get!(uint[]);
                        glCall(() =>glUniform1uiv(id, cast(int)temp.length, temp.ptr));
                        break;
                    case floating:
                        glCall(() =>glUniform1f(id, v.sVar.get!float));
                        break;
                    case floating2:
                        float[2] temp = v.sVar.get!(float[2]);
                        glCall(() =>glUniform2f(id, temp[0], temp[1]));
                        break;
                    case floating3:
                        float[3] temp = v.sVar.get!(float[3]);
                        glCall(() =>glUniform3f(id, temp[0], temp[1], temp[2]));
                        break;
                    case floating4:
                        float[4] temp = v.sVar.get!(float[4]);
                        glCall(() =>glUniform4f(id, temp[0], temp[1], temp[2], temp[3]));
                        break;
                    case floating2x2:
                        glCall(() => glUniformMatrix2fv(id, 1, GL_FALSE, cast(float*)v.sVar.get!(float[4]).ptr));
                        break;
                    case floating3x3:
                        glCall(() =>glUniformMatrix3fv(id, 1, GL_FALSE, cast(float*)v.sVar.get!(float[9]).ptr));
                        break;
                    case floating4x4:
                        glCall(() => glUniformMatrix4fv(id, 1, GL_FALSE, cast(float*)v.sVar.get!(float[16]).ptr));
                        break;
                    case floating_array:
                        float[] temp = v.sVar.get!(float[]);
                        glCall(() => glUniform1fv(id, cast(int)temp.length, temp.ptr));
                        break;
                    case none:break;
                }
            }
        }
                
    }

    void initTextureSlots(ref ShaderProgram prog, IHipTexture texture, string varName, int slotsCount)
    {
        setCurrentShader(prog);
        int varID = getId(prog, varName);
        scope int[] temp = new int[](slotsCount);
        for(int i = 0; i < slotsCount; i++)
            temp[i] = i;
        glCall(() => glUniform1iv(varID, slotsCount, temp.ptr));
    }
    void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        if(layout.hint & ShaderHint.GL_USE_BLOCK)
            ErrorHandler.assertExit(false, "Use HipGL3 for Uniform Block support.");
    }

    void deleteShader(FragmentShader* _fs)
    {
        auto fs = cast(Hip_GL3_FragmentShader)*_fs;
        glCall(() => glDeleteShader(fs.shader)); fs.shader = 0;
    }
    void deleteShader(VertexShader* _vs)
    {
        auto vs = cast(Hip_GL3_VertexShader)*_vs;
        glCall(() => glDeleteShader(vs.shader)); vs.shader = 0;
    }
    void dispose(ref ShaderProgram prog)
    {
        Hip_GL3_ShaderProgram p = cast(Hip_GL3_ShaderProgram)prog;
        glCall(() => glDeleteProgram(p.program));
    }
}


version(HipGL3) class Hip_GL3_ShaderImpl : Hip_GL_ShaderImpl
{
    import hip.util.data_structures:Pair;
    protected Pair!(ShaderVariablesLayout, uint)[] ubos;

    override int getId(ref ShaderProgram prog, string name)
    {
        // auto glProg = cast(Hip_GL3_ShaderProgram)prog;
        //if(glProg.isUsingUbo)
          //  return getUboId()
        //else
        return super.getId(prog, name);
    }

    override void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        if(layout.hint & ShaderHint.GL_USE_BLOCK)
        {
            uint ubo;
            glCall(() => glGenBuffers(1, &ubo));
            glCall(() => glBindBuffer(GL_UNIFORM_BUFFER, ubo));
            glCall(() => glBufferData(GL_UNIFORM_BUFFER, layout.getLayoutSize(), null, GL_DYNAMIC_DRAW));
            glCall(() => glBindBuffer(GL_UNIFORM_BUFFER, 0));
            ubos~= Pair!(ShaderVariablesLayout, uint)(layout, ubo);
        }
    }
    protected uint getUboId(ref Pair!(ShaderVariablesLayout, int) ubo, string name)
    {
        return glCall(() =>glGetUniformBlockIndex(ubo.b, cast(char*)name.ptr));
    }
    protected void bindUbo(ref Pair!(ShaderVariablesLayout, int) ubo, int index = 0)
    {
        glCall(() =>glBindBufferBase(GL_UNIFORM_BUFFER, index, ubo.second));
    }
    protected void updateUbo(ref Pair!(ShaderVariablesLayout, int) ubo)
    {
        import core.stdc.string;
        glCall(() =>glBindBuffer(GL_UNIFORM_BUFFER, ubo.b));
        GLvoid* ptr = glMapBuffer(GL_UNIFORM_BUFFER, GL_WRITE_ONLY);
        memcpy(ptr, ubo.a.getBlockData(), ubo.a.getLayoutSize());
        glCall(() => glUnmapBuffer(GL_UNIFORM_BUFFER));
        glCall(() => glBindBuffer(GL_UNIFORM_BUFFER, 0));
    }
    


    override void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts)
    {
        Hip_GL3_ShaderProgram glProg = cast(Hip_GL3_ShaderProgram)prog;
        if(!glProg.isUsingUbo)
        {
            super.sendVars(prog, layouts);
            return;
        }
        assert(false, "UBO binding is still not in use.");
    }

    override void dispose(ref ShaderProgram prog)
    {
        foreach (ub; ubos)
            glCall(() => glDeleteBuffers(1, &ub.b));
        ubos.length = 0;
        super.dispose(prog);
    }
}