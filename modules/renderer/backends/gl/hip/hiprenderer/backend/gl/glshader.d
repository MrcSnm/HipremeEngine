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


version(GLES32) version = GLES3;
version(GLES30) version = GLES3;

version(OpenGL):
import hip.api.renderer.texture;
import hip.hiprenderer.backend.gl.glrenderer;
import hip.hiprenderer.shader;
import hip.hiprenderer.renderer;
import hip.api.renderer.shadervar;
import hip.util.conv;
import hip.util.format: fastUnsafeCTFEFormat, format;
import hip.error.handler;



class Hip_GL3_FragmentShader : FragmentShader
{
    uint shader;
}
class Hip_GL3_VertexShader : VertexShader
{
    uint shader;
}
class Hip_GL3_ShaderProgram : ShaderProgram
{
    bool isUsingUbo;
    uint program;
    int[string] uniformIds;

    int getId(string name)
    {
        int* ret = name in uniformIds;
        if(ret)
            return *ret;
        int v = glCall(() =>glGetUniformLocation(program, cast(char*)name.ptr)); //Immutable anyway
        uniformIds[name] = v;
        return v;
    }
    protected HipBlendFunction blendSrc = HipBlendFunction.CONSTANT_COLOR, blendDst = HipBlendFunction.CONSTANT_COLOR;
    protected HipBlendEquation blendEq = HipBlendEquation.DISABLED;
}


GLenum getGLBlendFunction(HipBlendFunction func)
{
    final switch(func) with(HipBlendFunction)
    {
        case  ZERO: return GL_ZERO;
        case  ONE: return GL_ONE;
        case  SRC_COLOR: return GL_SRC_COLOR;
        case  ONE_MINUS_SRC_COLOR: return GL_ONE_MINUS_SRC_COLOR;
        case  DST_COLOR: return GL_DST_COLOR;
        case  ONE_MINUS_DST_COLOR: return GL_ONE_MINUS_DST_COLOR;
        case  SRC_ALPHA: return GL_SRC_ALPHA;
        case  ONE_MINUS_SRC_ALPHA: return GL_ONE_MINUS_SRC_ALPHA;
        case  DST_ALPHA: return GL_DST_ALPHA;
        case  ONE_MINUS_DST_ALPHA: return GL_ONE_MINUS_DST_ALPHA;
        case  CONSTANT_COLOR: return GL_CONSTANT_COLOR;
        case  ONE_MINUS_CONSTANT_COLOR: return GL_ONE_MINUS_CONSTANT_COLOR;
        case  CONSTANT_ALPHA: return GL_CONSTANT_ALPHA;
        case  ONE_MINUS_CONSTANT_ALPHA: return GL_ONE_MINUS_CONSTANT_ALPHA;
    }
}
GLenum getGLBlendEquation(HipBlendEquation eq)
{
    final switch(eq) with (HipBlendEquation)
    {
        case DISABLED: return GL_FUNC_ADD;
        case ADD: return GL_FUNC_ADD;
        case SUBTRACT: return GL_FUNC_SUBTRACT;
        case REVERSE_SUBTRACT: return GL_FUNC_REVERSE_SUBTRACT;
        case MIN: return GL_MIN;
        case MAX: return GL_MAX;
    }
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

    static string getShaderVersion(string str)
    {
        import hip.util.string;
        return between(str, "#version ", "\n");
    }
    static string getShaderPrecision(string str)
    {
        import hip.util.string;
        return between(str, "precision ", "\n");
    }

    static string preprocess(string shader, ShaderTypes type)
    {
        string ver = getShaderVersion(shader);
        string prefix;
        
        string precision = getShaderPrecision(shader);
        if(!ver.length)
            prefix = shaderVersion;
        if(!precision.length)
            prefix~= floatPrecision;
        
        final switch(type)
        {
            case ShaderTypes.fragment:
                prefix~= "#define FRAGMENT\n";
                break;
            case ShaderTypes.vertex:
                prefix~= "#define VERTEX\n";
                break;
            case ShaderTypes.geometry:assert(false, "Unuspported geometry.");
            case ShaderTypes.none:assert(false, "Unuspported none.");
        }
        prefix~= 
`#if __VERSION__ == 100
    #define INOUT varying
    #define IN varying
    #define OUT varying
    #define OUT_COLOR gl_FragColor
    #define UNIFORM_BUFFER_OBJECT(bindingN, structType, varName, structDecl ) struct structType structDecl ; uniform structType varName
    #ifdef FRAGMENT
        #define SAMPLE2D texture2D
    #elif defined(VERTEX)
        #define ATTRIBUTE(LOC) attribute
    #endif
#else
    #define IN in
    #define OUT out
    #define OUT_COLOR outPixelColor
    #define UNIFORM_BUFFER_OBJECT(bindingN, structType, varName, structDecl) layout(std140) uniform structType structDecl varName

    #ifdef FRAGMENT
        #define INOUT IN
        #define SAMPLE2D texture
        out vec4 outPixelColor;
    #else
        #define INOUT OUT
        #define ATTRIBUTE(LOC) layout (location = LOC) in
    #endif
#endif

#ifdef FRAGMENT
#define ENTRY_POINT fragmentMain()
#elif defined(VERTEX)
#define ENTRY_POINT vertexMain()
#endif
#line 1 0
`;
        return prefix ~ shader ~ "\nvoid main(){ENTRY_POINT;}";
    }


    bool compileShader(GLuint shaderID, string shaderSource)
    {
        char* source = cast(char*)shaderSource.ptr; 
        GLint[1] lengths = [cast(GLint)shaderSource.length];
        glCall(() =>glShaderSource(shaderID, 1, &source, lengths.ptr));
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
        shaderSource = preprocess(shaderSource, ShaderTypes.vertex);
        return compileShader((cast(Hip_GL3_VertexShader)vs).shader, shaderSource);
    }
    bool compileShader(FragmentShader fs, string shaderSource)
    {
        shaderSource = preprocess(shaderSource, ShaderTypes.fragment);
        return compileShader((cast(Hip_GL3_FragmentShader)fs).shader, shaderSource);
    }

    bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs)
    {
        uint prog = (cast(Hip_GL3_ShaderProgram)program).program;

        glCall(() =>glAttachShader(prog, (cast(Hip_GL3_VertexShader)vs).shader));
        glCall(() =>glAttachShader(prog, (cast(Hip_GL3_FragmentShader)fs).shader));
        glCall(() =>glLinkProgram(prog));
        
        int success;
        int length;
        char[4096] infoLog;

        glCall(() =>glGetProgramiv(prog, GL_LINK_STATUS, &success));

        if(ErrorHandler.assertErrorMessage(success==true, "Shader linking error", "Linking failed"))
        {
            glCall(() => glGetProgramInfoLog(prog, 4096, &length, infoLog.ptr));
            ErrorHandler.showErrorMessage("Linking error: ", cast(string)(infoLog[0..length]));
        }
        
        return success==true;
    }
    int getId(ref ShaderProgram prog, string name, ShaderVariablesLayout layout)
    {
        int varID = (cast(Hip_GL3_ShaderProgram)prog).getId(name);
        if(varID <= 0)
        {
            string existingVariables;
            foreach(k, v; layout.variables)
                existingVariables~= "\t"~k~"\n";
            ErrorHandler.showErrorMessage("Uniform not found",
            "Variable named '"~name~"' does not exists in shader "~prog.name~
            "Existing variables: "~existingVariables);
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

    private __gshared Hip_GL_ShaderImpl boundShader;
    private __gshared HipBlendFunction currSrc, currDst;
    private __gshared HipBlendEquation currEq;
    private __gshared blendingEnabled = false;

    public void setBlending(ShaderProgram prog, HipBlendFunction src, HipBlendFunction dst, HipBlendEquation eq)
    {
        Hip_GL3_ShaderProgram p = cast(Hip_GL3_ShaderProgram)prog;
        p.blendSrc = src;
        p.blendDst = dst;
        p.blendEq = eq;
    }

    void bind(ShaderProgram program)
    {
        if(boundShader !is this)
        {
            Hip_GL3_ShaderProgram p = cast(Hip_GL3_ShaderProgram)program;
            if(p.blendEq == HipBlendEquation.DISABLED)
            {
                if(blendingEnabled)
                {
                    glCall(() => glDisable(GL_BLEND));
                    blendingEnabled = false;
                }
            }
            else
            {
                if(!blendingEnabled)
                {
                    glCall(() => glEnable(GL_BLEND));
                    blendingEnabled = true;
                }
                if(currEq != p.blendEq)
                {
                    currEq = p.blendEq;
                    glCall(() => glBlendEquation(getGLBlendEquation(p.blendEq)));
                }
                if(currSrc != p.blendSrc || currDst != p.blendDst)
                {
                    currSrc = p.blendSrc;
                    currDst = p.blendDst;
                    glCall(() => glBlendFunc(getGLBlendFunction(p.blendSrc), getGLBlendFunction(p.blendDst)));
                }
            }
            glCall(() =>glUseProgram(p.program));
            boundShader = this;
        }
    }
    void unbind(ShaderProgram program)
    {
        if(boundShader is this)
        {
            glCall(() =>glUseProgram(0));
            boundShader = null;
        }
    }
    private void sendVar(ref ShaderVar sVar, ref ShaderProgram prog, ShaderVariablesLayout layout)
    {
        int id = 0;
        if(sVar.type != UniformType.custom) 
            id = getId(prog, sVar.name, layout);
        final switch(sVar.type) with(UniformType)
        {
            case boolean:
                glCall(() => glUniform1i(id, sVar.get!bool));
                break;
            case integer:
                glCall(() => glUniform1i(id, sVar.get!int));
                break;
            case integer_array:
                int[] temp = sVar.get!(int[]);
                glCall(() =>glUniform1iv(id, cast(int)temp.length, temp.ptr));
                break;
            case uinteger:
                glCall(() =>glUniform1ui(id, sVar.get!uint));
                break;
            case uinteger_array:
                uint[] temp = sVar.get!(uint[]);
                glCall(() =>glUniform1uiv(id, cast(int)temp.length, temp.ptr));
                break;
            case floating:
                glCall(() =>glUniform1f(id, sVar.get!float));
                break;
            case floating2:
                float[2] temp = sVar.get!(float[2]);
                glCall(() =>glUniform2f(id, temp[0], temp[1]));
                break;
            case floating3:
                float[3] temp = sVar.get!(float[3]);
                glCall(() =>glUniform3f(id, temp[0], temp[1], temp[2]));
                break;
            case floating4:
                float[4] temp = sVar.get!(float[4]);
                glCall(() =>glUniform4f(id, temp[0], temp[1], temp[2], temp[3]));
                break;
            case floating2x2:
                glCall(() => glUniformMatrix2fv(id, 1, GL_FALSE, cast(float*)sVar.get!(float[4]).ptr));
                break;
            case floating3x3:
                glCall(() =>glUniformMatrix3fv(id, 1, GL_FALSE, cast(float*)sVar.get!(float[9]).ptr));
                break;
            case floating4x4:
                glCall(() => glUniformMatrix4fv(id, 1, GL_FALSE, cast(float*)sVar.get!(float[16]).ptr));
                break;
            case floating_array:
                float[] temp = sVar.get!(float[]);
                glCall(() => glUniform1fv(id, cast(int)temp.length, temp.ptr));
                break;
            case texture_array:
                GLint[] temp = sVar.get!(GLint[]);
                glCall(() => glUniform1iv(id, cast(int)temp.length, cast(int*)temp.ptr));
                break;
            case custom:
                foreach(v; sVar.variables)
                {
                    if(v.isDirty)
                        sendVar(v, prog, layout);
                }
                break;
            case none:break;
        }
        sVar.isDirty = false;
    }

    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
    {
        bind(prog);
        foreach(ShaderVariablesLayout l; layouts)
        {
            if(!l.isDirty)
                continue;
            l.isDirty = false;
            foreach (ref ShaderVarLayout v; l.variables)
            {
                if(!v.sVar.isDirty)
                    continue;
                sendVar(v.sVar, prog, l);
            }
        }
    }

    bool setShaderVar(ShaderVar* sv, ShaderProgram prog, void* value)
    {
        ///Optimization for not allocating when inside loops.
        __gshared int[] temp;
        switch(sv.type) with(UniformType)
        {
            case texture_array:
            {
                IHipTexture[] textures = *cast(IHipTexture[]*)value;
                if(textures.length > temp.length)
                    temp.length = textures.length;
                int length = cast(int)textures.length;
                foreach(i; 0..length)
                    temp[i] = i;
                sv.set(temp, false);
                return true;
            }
            default: return false;
        }
    }

    void bindArrayOfTextures(ref ShaderProgram prog, IHipTexture[] textures, string varName)
    {
        bool shouldControlBind = boundShader !is this;

        if(shouldControlBind)
            bind(prog);
        
        foreach(int i; 0..cast(int)textures.length)
            textures[i].bind(i);
        if(shouldControlBind)
            unbind(prog);
    }
    void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram)
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
    void onRenderFrameEnd(ShaderProgram program){}
}



static if(OpenGLHasUniformBufferSupport) 
class Hip_GL3_ShaderImpl : Hip_GL_ShaderImpl
{
    struct UBO
    {
        Hip_GL3_Buffer buffer;
        uint bindPoint;
    }
    import hip.hiprenderer.backend.gl.glbuffer;
    protected ShaderVariablesLayout[] ubos;
    uint id = 0;

    override void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram)
    {
        UBO* b = new UBO(
            new Hip_GL3_Buffer(layout.getLayoutSize(), HipResourceUsage.Dynamic, HipRendererBufferType.uniform),            
        );

        layout.setAdditionalData(cast(void*)b, true);
        setUboBindPoint(shaderProgram, layout.name, *b);
        ubos~= layout;
    }
    
    protected void setUboBindPoint(const ref ShaderProgram prog, string name, ref UBO ubo)
    {
        int program = (cast(Hip_GL3_ShaderProgram)prog).program;
        int blockIndex = glCall(() =>glGetUniformBlockIndex(program, cast(char*)name.ptr));
        if(blockIndex == GL_INVALID_INDEX)
        {
            throw new Exception(
                "OpenGL GLSL Usage Error: setUboBindPoint"~
                "\nProgram: " ~prog.name~
                "\nUniform Buffer Object block with expected name '"~name~"' not found." ~
                "\nPlease check hip.hiprenderer.backend.gl.defaultshaders #define examples for using "~
                "UNIFORM_BUFFER_OBJECT in your shader." ~
                "\nExample Usage:\n"~
                "UNIFORM_BUFFER_OBJECT(0, Camera, camera, 
                {
                    mat4 uMVP;
                });
                ATTRIBUTE(0) vec3 vPosition;
                void main()
                {
                    gl_Position = camera.uMVP * vec4(vPosition, 1.0);
                }"
            );
        }
        ubo.bindPoint = id++;
        glCall(() => glUniformBlockBinding(program, blockIndex, ubo.bindPoint));
    }
    override void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
    {
        Hip_GL3_ShaderProgram glProg = cast(Hip_GL3_ShaderProgram)prog;
        foreach(k, ShaderVariablesLayout l; layouts)
        {
            import core.stdc.string;
            UBO* ubo = cast(UBO*)l.getAdditionalData();
            if(l.isDirty)
            {
                ubo.buffer.updateData(0, l.getBlockData()[0..l.getLayoutSize()]);
                // writeln("Bind ", l.name, " to ", ubo.blockIndex);
                l.isDirty = false;
            }
            glCall(() =>glBindBufferBase(GL_UNIFORM_BUFFER, ubo.bindPoint, ubo.buffer.handle));
        }   
    }

    override void dispose(ref ShaderProgram prog)
    {
        foreach (ub; ubos)
        {
            UBO* ubo = cast(UBO*)ub.getAdditionalData();
            glCall(() => glDeleteBuffers(1, &ubo.buffer.handle));
        }
        ubos.length = 0;
        super.dispose(prog);
    }
}

static if(UseGLES)
    enum floatPrecision = "precision mediump float;\n";
else
    enum floatPrecision = "";

version(GLES32) version = GLES3;
version(GLES30) version = GLES3;

version(GLES3)
{
    enum shaderVersion = "#version 300 es\n";
    // enum floatPrecision = "";
}
else version(GLES20)
{
    static if(UseWebGL)
    {
        string shaderVersion() {
            import gles;
            return isWebGL2 ? "#version 300 es\n" : "#version 100\n";
        }
    }
    else enum shaderVersion = "#version 100\n";
}
else
    enum shaderVersion = "#version 330 core\n";
