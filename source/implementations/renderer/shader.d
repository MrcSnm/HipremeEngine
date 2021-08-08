module implementations.renderer.shader;
import bindbc.opengl;
import error.handler;
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
    VERTEX,
    FRAGMENT,
    GEOMETRY, //Unsupported yet
    NONE 
}

enum HipShaderPresets
{
    DEFAULT,
    FRAME_BUFFER,
    GEOMETRY_BATCH,
    SPRITE_BATCH,
    BITMAP_TEXT,
    NONE
}

enum UniformType
{
    boolean,
    integer,
    uinteger,
    floating,
    floating2,
    floating3,
    floating4,
    floating2x2,
    floating3x3,
    floating4x4,
    none
}

enum ShaderHint : uint
{
    NONE = 0,
    GL_USE_BLOCK = 1<<0,
}

struct ShaderVar
{
    void* data;
    string name;
    ShaderTypes shaderType;
    UniformType type;
    ulong singleSize;
    ulong varSize;

    const T get(T)(){return *(cast(T*)this.data);}
    bool set(T)(T data)
    {
        import std.traits;
        import core.stdc.string;
        static assert(isNumeric!T || isBoolean!T || isStaticArray!T, "Invalid type "~T.stringof);

        if(data.sizeof != varSize)
            return false;
        memcpy(this.data, &data, varSize);
        return true;
    }
    auto opAssign(T)(T value)
    {
        static if(is(T == ShaderVar))
        {
            this.data = value.data;
            this.name = value.name;
            this.shaderType = value.shaderType;
            this.varSize = value.varSize;
            this.singleSize = value.singleSize;
        }
        else
            assert(this.set(value), "Value set for '"~name~"' is invalid.");
        return this;
    }

    private void throwOnOutOfBounds(size_t index)
    {
        switch(type) with(UniformType)
        {
            case floating2:
                assert(index < 2, "Index out of bounds on shader variable "~name);
                break;
            case floating3:
                assert(index < 3, "Index out of bounds on shader variable "~name);
                break;
            case floating4:
                assert(index < 4, "Index out of bounds on shader variable "~name);
                break;
            case floating2x2:
                assert(index < 4, "Index out of bounds on shader variable "~name);
                break;
            case floating3x3:
                assert(index < 9, "Index out of bounds on shader variable "~name);
                break;
            case floating4x4:
                assert(index < 16, "Index out of bounds on shader variable "~name);
                break;
            default:
                import std.conv:to;
                assert(false, "opIndex is unsupported in var of type "~to!string(type));
        }
    }

    auto opIndexAssign(T)(T value, size_t index)
    {
        import core.stdc.string;
        import std.conv:to;
        throwOnOutOfBounds(index);
        assert(index*singleSize + T.sizeof <= varSize, "Value assign of type "~T.stringof~" at index "~to!string(index)~
        " is invalid for shader variable "~name~" of type "~to!string(type));
        memcpy(cast(ubyte*)data + singleSize*index, &value, T.sizeof);
        return value;
    }

    ref auto opIndex(size_t index)
    {
        throwOnOutOfBounds(index);
        switch(type) with(UniformType)
        {
            case floating2:
                return get!(float[2])[index];
            case floating3:
                return get!(float[3])[index];
            case floating4:
                return get!(float[4])[index];
            case floating2x2:
                return get!(float[4])[index];
            case floating3x3:
                return get!(float[9])[index];
            case floating4x4:
                return get!(float[16])[index];
            default:
                import std.conv:to;
                assert(false, "opIndex is unsupported in var of type "~to!string(type));
        }
    }

    static ShaderVar* get(ShaderTypes t, string varName, bool data){return ShaderVar.get(t, varName, &data, UniformType.boolean, data.sizeof, data.sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, int data){return ShaderVar.get(t, varName, &data, UniformType.integer, data.sizeof, data.sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, uint data){return ShaderVar.get(t, varName, &data, UniformType.uinteger, data.sizeof, data.sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, float data){return ShaderVar.get(t, varName, &data, UniformType.floating, data.sizeof, data.sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, float[2] data){return ShaderVar.get(t, varName, &data, UniformType.floating2, data.sizeof, data[0].sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, float[3] data){return ShaderVar.get(t, varName, &data, UniformType.floating3, data.sizeof, data[0].sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, float[4] data){return ShaderVar.get(t, varName, &data, UniformType.floating4, data.sizeof, data[0].sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, float[9] data){return ShaderVar.get(t, varName, &data, UniformType.floating3x3, data.sizeof, data[0].sizeof);}
    static ShaderVar* get(ShaderTypes t, string varName, float[16] data){return ShaderVar.get(t, varName, &data, UniformType.floating4x4, data.sizeof, data[0].sizeof);}
    protected static ShaderVar* get(ShaderTypes t, string varName, void* varData, UniformType type, ulong varSize, ulong singleSize)
    {
        import core.stdc.string : memcpy;
        import core.stdc.stdlib : malloc;
        assert(isShaderVarNameValid(varName), "Variable '"~varName~"' is invalid.");
        ShaderVar* s = new ShaderVar();
        s.data = malloc(varSize);
        assert(s.data !is null, "Out of memory");
        s.name = varName;
        s.shaderType = t;
        s.type = type;
        s.varSize = varSize;
        s.singleSize = singleSize;
        memcpy(s.data, varData, varSize);
        return s;
    }

    void dispose()
    {
        import core.stdc.stdlib:free;
        type = UniformType.none;
        shaderType = ShaderTypes.NONE;
        singleSize = 0;
        varSize = 0;
        if(data != null)
            free(data);
        data = null;
    }
}

struct ShaderVarLayout
{
    ShaderVar* sVar;
    uint alignment;
    uint size;
}

/**
*   This class is meant to be created together with the Shaders.
*   
*   Those are meant to wrap the cbuffer from Direct3D and Uniform Block from OpenGL.
*
*   By wrapping the uniforms/cbuffers layouts, it is much easier to send those variables from any API.
*/
class ShaderVariablesLayout
{
    ShaderVarLayout[string] variables;
    string name;
    ShaderTypes shaderType;
    protected void* data;
    protected void* additionalData;
    protected bool isAdditionalAllocated;
    private bool isLocked;

    ///The hint are used for the Shader backend as a notifier
    public immutable int hint;
    protected uint lastPosition;

    /**
    *   Use the layout name for mentioning the uniform/cbuffer block name.
    *
    *   Its members are the ShaderVar* passed
    *
    *   Params:
    *       layoutName = From which block it will be accessed on the shader
    *       t = What is the shader type that holds those variables
    *       hint = Use ShaderHint for additional information, multiple hints may be passed
    *       variables = Usually you won't pass any and use .append for writing less
    */
    this(string layoutName, ShaderTypes t, uint hint, ShaderVar*[] variables ...)
    {
        import core.stdc.stdlib:malloc;
        this.name = layoutName;
        this.shaderType = t;
        this.hint = hint;
        uint position = 0;
        foreach(ShaderVar* v; variables)
        {
            assert(v.shaderType == t, "ShaderVariableLayout must contain only one shader type");
            assert((v.name in this.variables) is null, "Variable named "~v.name~" is already in the layout "~name);
            uint size = glSTD140(v, 0);
            position = glSTD140(v, position);
            this.variables[v.name] = ShaderVarLayout(v, position-size, size);
        }
        data = malloc(getLayoutSize());
        assert(data != null, "Out of memory");
        lastPosition = position;
    }
    void lock(){this.isLocked = true;}

    /**
    *   Uses the OpenGL's GLSL Std 140 for getting the variable position.
    *   This function must return what is the end position given the last variable size.
    */
    final uint glSTD140(ref ShaderVar* v, uint lastAlignment = 0,  uint n = float.sizeof)
    {
        uint newN;
        final switch(v.type) with(UniformType)
        {
            case floating:
            case uinteger:
            case integer:
            case boolean:
                newN = n;
                break;
            case floating2:
                newN = n*2;
                break;
            case floating3:
            case floating4:
            case floating2x2:
                newN = n*4;
                break;
            case floating3x3:
                newN = n*12;
                break;
            case floating4x4:
                newN = n*16;
                break;
            case none:
                assert(false, "Can't use none uniform type on ShaderVariablesLayout");
        }
        if(lastAlignment == 0)
            return newN;

        uint n4 = n*4;
        if(lastAlignment % n4 > (lastAlignment+newN) % n4 || newN % n4 == 0)
            return lastAlignment+ (lastAlignment % n4) + newN;
        
        return lastAlignment + newN;
    }

    void* getBlockData()
    {
        import core.stdc.string:memcpy;
        foreach(v; variables)
            memcpy(data+v.alignment, v.sVar.data, v.size);
        return data;
    }

    ShaderVariablesLayout append(T)(string varName, T data)
    {
        import core.stdc.stdlib:realloc;
        assert((varName in variables) is null, "Variable named "~varName~" is already in the layout "~name);
        assert(!isLocked, "Can't append ShaderVariable after it has been locked");
        ShaderVar* v = ShaderVar.get(this.shaderType, varName, data);
        uint sz = glSTD140(v, 0);
        uint pos = glSTD140(v, lastPosition);
        lastPosition = pos;
        variables[varName] = ShaderVarLayout(v, lastPosition-sz, sz);
        this.data = realloc(this.data, getLayoutSize());
        assert(this.data != null, "Out of memory");

        return this;
    }
    final ulong getLayoutSize(){return lastPosition;}
    final void setAdditionalData(void* d, bool isAllocated)
    {
        this.additionalData = d;
        this.isAdditionalAllocated = isAllocated;
    }
    final const(void*) getAdditionalData() const {return cast(const(void*))additionalData;}

    auto opDispatch(string member)()
    {
        return variables[member].sVar;
    }

    void dispose()
    {
        import core.stdc.stdlib:free;
        foreach (ref v; variables)
        {
            v.sVar.dispose();
            v.alignment = 0;
            v.size = 0;
            v.sVar = null;
        }
        if(data != null)
            free(data);
        if(isAdditionalAllocated && additionalData != null)
            free(additionalData);
        additionalData = null;
        data = null;
    }
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

    final void setVertexVar(T)(ref ShaderProgram prog, string name, T value)
    {
        int id = getId(prog, name);
        setVertexVar(id, value);
    }
    final void setFragmentVar(T)(ref ShaderProgram prog, string name, T value)
    {
        int id = getId(prog, name);
        setFragmentVar(id, value);
    }
    void setFragmentVar(int id, int val);
    void setFragmentVar(int id, bool val);
    void setFragmentVar(int id, float val);
    void setFragmentVar(int id, float[2] val); ///Vec2
    void setFragmentVar(int id, float[3] val); ///Vec3
    void setFragmentVar(int id, float[4] val); ///Vec4
    void setFragmentVar(int id, float[9] val); ///Matrix3
    void setFragmentVar(int id, float[16] val); ///Matrix4

    void setVertexVar(int id, int val);
    void setVertexVar(int id, bool val);
    void setVertexVar(int id, float val);
    void setVertexVar(int id, float[2] val); ///Vec2
    void setVertexVar(int id, float[3] val); ///Vec3
    void setVertexVar(int id, float[4] val); ///Vec4
    void setVertexVar(int id, float[9] val); ///Matrix3
    void setVertexVar(int id, float[16] val); ///Matrix4

    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(FragmentShader* fs);
    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(VertexShader* vs);

    void createVariablesBlock(ref ShaderVariablesLayout layout);
    void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts);
    void dispose(ref ShaderProgram);
}

abstract class VertexShader
{
    abstract string getDefaultVertex();
    abstract string getFrameBufferVertex();
    abstract string getGeometryBatchVertex();
    abstract string getSpriteBatchVertex();
    abstract string getBitmapTextVertex();
}
abstract class FragmentShader
{
    abstract string getDefaultFragment();
    abstract string getFrameBufferFragment();
    abstract string getGeometryBatchFragment();
    abstract string getSpriteBatchFragment();
    abstract string getBitmapTextFragment();
}

abstract class ShaderProgram{}


public class Shader
{
    VertexShader vertexShader;
    FragmentShader fragmentShader;
    ShaderProgram shaderProgram;
    ShaderVariablesLayout[string] layouts;
    protected ShaderVariablesLayout defaultLayout;
    //Optional
    IShader shaderImpl;
    string fragmentShaderPath;
    string vertexShaderPath;

    private bool isUseCall = false;

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
            case BITMAP_TEXT:
                status = loadShaders(vertexShader.getBitmapTextVertex(), fragmentShader.getBitmapTextFragment());
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
            logln("Failed loading shaders with status ", status, " at preset ", preset);
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

    public void setVertexVar(T)(string name, T val){shaderImpl.setVertexVar(this.shaderProgram, name, val);}
    public void setVertexVar(T)(int id, T val){shaderImpl.setVertexVar(id, val);}
    public void setFragmentVar(T)(string name, T val){shaderImpl.setFragmentVar(this.shaderProgram, name, val);}
    public void setFragmentVar(T)(int id, T val){shaderImpl.setFragmentVar(id, val);}

    protected ShaderVar* findByName(string name)
    {
        import std.array : split;
        string[] names = name.split(".");
        bool isDefault = names[0] == "";

        if(isDefault)
        {
            import std.stdio;
            ShaderVarLayout* sL = names[1] in defaultLayout.variables;
            if(sL !is null)
                return sL.sVar;
        }
        else
        {
            ShaderVariablesLayout* l = (names[0] in layouts);
            if(l !is null)
            {
                ShaderVarLayout* sL = names[1] in l.variables;
                if(sL !is null)
                    return sL.sVar;
            }
        }
        return null;
    }

    public ShaderVar* get(string name){return findByName(name);}

    // public void setVertexVar(T)(string name, T val)
    // {

    // }

    public void addVarLayout(ShaderVariablesLayout layout)
    {
        assert((layout.name in layouts) is null, "Shader: VariablesLayout '"~layout.name~"' is already defined");
        if(defaultLayout is null)
            defaultLayout = layout;
        layouts[layout.name] = layout;
        shaderImpl.createVariablesBlock(layout);
    }

    /** 
     * This creates a state in the current shader to which block will be accessed
     * when using setVertexVar(".property"). If no default block is set ("")
     * .property will always access the first block defined
     * Params:
     *   blockName = Which block will be accessed with .property
     */
    public void setDefaultBlock(string blockName){defaultLayout = layouts[blockName];}

    void bind()
    {
        shaderImpl.setCurrentShader(shaderProgram);
    }

    auto opDispatch(string member)()
    {
        static if(member == "useLayout")
        {
            isUseCall = true;
            return this;
        }
        else
        {
            if(isUseCall)
            {
                setDefaultBlock(member);
                isUseCall = false;
                ShaderVar s;
                return s;
            }
            return *defaultLayout.variables[member].sVar;
        }
    }
    auto opDispatch(string member, T)(T value)
    {
        assert(defaultLayout.variables[member].sVar.set(value), "Invalid value of type "~
        T.stringof~" passed to "~defaultLayout.name~"."~member);
    }

    void sendVars()
    {
        shaderImpl.sendVars(shaderProgram, layouts);
    }


    protected void deleteShaders()
    {
        shaderImpl.deleteShader(&fragmentShader);
        shaderImpl.deleteShader(&vertexShader);
    }

}

private bool isShaderVarNameValid(ref string varName)
{
    import std.algorithm;
    
    return varName.length > 0 && 
    varName.countUntil(" ") == -1;
}