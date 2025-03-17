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

version(GLES3)
{
    enum shaderVersion = "#version 300 es";
    enum floatPrecision = "precision mediump float;";
    // enum floatPrecision = "";
}
else version(GLES20)
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
                    case texture_array:
                        GLint[] temp = v.sVar.get!(GLint[]);
                        glCall(() => glUniform1iv(id, cast(int)temp.length, cast(int*)temp.ptr));
                        break;
                    case none:break;
                }
                v.sVar.isDirty = false;
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

    override void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram)
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
    


    override void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
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