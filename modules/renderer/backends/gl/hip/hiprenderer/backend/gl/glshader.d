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
import hip.api.renderer.shader;
import hip.hiprenderer.renderer;
import hip.api.renderer.shadervar;
import hip.util.conv;
import hip.util.format: fastUnsafeCTFEFormat, format;
import hip.error.handler;

class HipGLShaderProgram : HipShaderProgram
{
    uint fragmentShader;
    uint vertexShader;
    uint program;
    protected HipBlendFunction blendSrc = HipBlendFunction.CONSTANT_COLOR, blendDst = HipBlendFunction.CONSTANT_COLOR;
    protected HipBlendEquation blendEq = HipBlendEquation.DISABLED;
    protected ShaderVariablesLayout[] layouts;


    private __gshared HipGLShaderProgram boundShader;
    private __gshared HipBlendFunction currSrc, currDst;
    private __gshared HipBlendEquation currEq;
    private __gshared blendingEnabled = false;


    this()
    {
        vertexShader = glCall(() => glCreateShader(GL_VERTEX_SHADER));
        fragmentShader = glCall(() => glCreateShader(GL_FRAGMENT_SHADER));
        program = glCall(() => glCreateProgram());
    }

    static bool compileShader(GLuint shaderID, string shaderSource)
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
                    GLint logLength = 0;
                    glCall(() => glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &logLength));
                    infoLog = cast(char[])malloc(logLength)[0..logLength];
                    glCall(() =>glGetShaderInfoLog(shaderID, logLength, &logLength, infoLog.ptr));
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

    override void dispose()
    {
        glCall(() => glDeleteShader(vertexShader));
        glCall(() => glDeleteShader(fragmentShader));
        glCall(() => glDeleteProgram(program));
        vertexShader = fragmentShader = program = 0;
    }

    bool isUsingUbo;
    int[string] uniformIds;

    private int getId(string name)
    {
        int* ret = name in uniformIds;
        if(ret)
            return *ret;
        int v = glCall(() =>glGetUniformLocation(program, cast(char*)name.ptr)); //Immutable anyway
        uniformIds[name] = v;
        return v;
    }

    override int getId(string name, ShaderVariablesLayout layout)
    {
        int varID = getId(name);
        if(varID <= 0)
        {
            string existingVariables;
            foreach(k, v; layout.variables)
                existingVariables~= "\t"~k~"\n";
            ErrorHandler.showErrorMessage("Uniform not found",
            "Variable named '"~name~"' does not exists in shader "~this.name~
            " Existing variables: "~existingVariables);
        }
        return varID;
    }

    override public void setBlending(HipBlendFunction src, HipBlendFunction dst, HipBlendEquation eq)
    {
        blendSrc = src;
        blendDst = dst;
        blendEq = eq;
    }

    override void unbind()
    {
        glCall(() =>glUseProgram(0));
    }
    private void sendVar(ref ShaderVar sVar, ShaderVariablesLayout layout)
    {
        int id = 0;
        if(sVar.type != UniformType.custom) 
            id = getId(sVar.name, layout);
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
                        sendVar(v, layout);
                }
                break;
            case none:break;
        }
        sVar.isDirty = false;
    }

    override void sendVars(ShaderVariablesLayout[] layouts)
    {
        bind();
        foreach(ShaderVariablesLayout l; layouts)
        {
            if(!l.isDirty)
                continue;
            l.isDirty = false;
            foreach (ref ShaderVarLayout v; l.variables)
            {
                if(!v.sVar.isDirty)
                    continue;
                sendVar(v.sVar,l);
            }
        }
    }

    override bool setShaderVar(ShaderVar* sv, void* value)
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

    override bool buildShader(string shaderSource, string shaderPath, bool isInstanced = false)
    {
        name = shaderPath;
        if(!compileShader(vertexShader, preprocess(shaderSource, ShaderTypes.vertex, isInstanced)))
            return false;
        if(!compileShader(fragmentShader, preprocess(shaderSource, ShaderTypes.fragment, isInstanced)))
            return false;

        glCall(() =>glAttachShader(program, vertexShader));
        glCall(() =>glAttachShader(program, fragmentShader));
        glCall(() =>glLinkProgram(program));
        
        int success;
        int length;
        char[4096] infoLog;

        glCall(() =>glGetProgramiv(program, GL_LINK_STATUS, &success));

        if(ErrorHandler.assertErrorMessage(success==true, "Shader linking error", "Linking failed"))
        {
            glCall(() => glGetProgramInfoLog(program, 4096, &length, infoLog.ptr));
            ErrorHandler.showErrorMessage("Linking error: ", cast(string)(infoLog[0..length]));
        }
        return success == true;
    }
   

    override void bind()
    {
        if(boundShader !is this)
        {
            if(blendEq == HipBlendEquation.DISABLED)
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
                if(currEq != blendEq)
                {
                    currEq = blendEq;
                    glCall(() => glBlendEquation(getGLBlendEquation(blendEq)));
                }
                if(currSrc != blendSrc || currDst != blendDst)
                {
                    currSrc = blendSrc;
                    currDst = blendDst;
                    glCall(() => glBlendFunc(getGLBlendFunction(blendSrc), getGLBlendFunction(blendDst)));
                }
            }
            glCall(() =>glUseProgram(program));
            boundShader = this;
        }
    }

    override void bindArrayOfTextures(IHipTexture[] textures, string varName)
    {
        bool shouldControlBind = boundShader !is this;

        if(shouldControlBind)
            bind();
        
        foreach(int i; 0..cast(int)textures.length)
            textures[i].bind(i);
        if(shouldControlBind)
            unbind();
    }
    override void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        if(layout.hint & ShaderHint.GL_USE_BLOCK)
            ErrorHandler.assertExit(false, "Use HipGL3 for Uniform Block support.");
    }
    override void onRenderFrameEnd(){}

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




static if(OpenGLHasUniformBufferSupport) 
class HipGL3ShaderProgram : HipGLShaderProgram
{
    struct UBO
    {
        Hip_GL3_Buffer buffer;
        uint bindPoint;
    }
    import hip.hiprenderer.backend.gl.glbuffer;
    protected ShaderVariablesLayout[] ubos;
    private static UBO[] boundUBO;

    uint id = 0;

    override void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        UBO* b = new UBO(
            new Hip_GL3_Buffer(layout.getLayoutSize(), HipResourceUsage.Dynamic, HipRendererBufferType.uniform),            
        );

        layout.setAdditionalData(cast(void*)b, true);
        setUboBindPoint(layout.name, *b);
        ubos~= layout;
    }

    protected static bool isUBOBound(UBO ubo)
    {
        return boundUBO[ubo.bindPoint].buffer is ubo.buffer;
    }
    protected static void bindUBO(UBO ubo)
    {
        if(boundUBO.length <= ubo.bindPoint)
            boundUBO.length = ubo.bindPoint + 1;
        if(!isUBOBound(ubo))
        {
            boundUBO[ubo.bindPoint] = ubo;
            glCall(() =>glBindBufferBase(GL_UNIFORM_BUFFER, ubo.bindPoint, ubo.buffer.handle));
        }
    }
    
    protected void setUboBindPoint(string name, ref UBO ubo)
    {
        int blockIndex = glCall(() =>glGetUniformBlockIndex(program, cast(char*)name.ptr));
        if(blockIndex == GL_INVALID_INDEX)
        {
            throw new Exception(
                "OpenGL GLSL Usage Error: setUboBindPoint"~
                "\nProgram: " ~name~
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
    override void sendVars(ShaderVariablesLayout[] layouts)
    {
        foreach(ShaderVariablesLayout l; layouts)
        {
            import core.stdc.string;
            UBO* ubo = cast(UBO*)l.getAdditionalData();
            if(l.isDirty)
            {
                ubo.buffer.updateData(0, l.getBlockData()[0..l.getLayoutSize()]);
                // writeln("Bind ", l.name, " to ", ubo.blockIndex);
                l.isDirty = false;
            }
            bindUBO(*ubo);
        }   
    }

    override void dispose()
    {
        foreach (ub; ubos)
        {
            UBO* ubo = cast(UBO*)ub.getAdditionalData();
            glCall(() => glDeleteBuffers(1, &ubo.buffer.handle));
        }
        ubos.length = 0;
        super.dispose();
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



private string getShaderVersion(string str)
{
    import hip.util.string;
    return betweenInclusive(str, "#version ", "\n");
}
private string getShaderPrecision(string str)
{
    import hip.util.string;
    return betweenInclusive(str, "precision ", ";\n");
}

private string preprocess(string shader, ShaderTypes type, bool isInstanced = false)
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
    if(isInstanced)
        prefix~= "#define INSTANCED\n";
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

    #define UVEC2 vec2
    #define IVEC2 vec2
    #define UINT float
    #define INT float
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

    #define UVEC2 uvec2
    #define IVEC2 ivec2
    #define UINT uint
    #define INT int

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