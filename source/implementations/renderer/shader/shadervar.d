module implementations.renderer.shader.shadervar;
import implementations.renderer.shader.shader;
import implementations.renderer.renderer;
import math.matrix;

enum ShaderHint : uint
{
    NONE = 0,
    GL_USE_BLOCK = 1<<0,
    GL_USE_STD_140 = 1<<1,

    D3D_USE_HLSL_4 = 1<<2
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
        static assert(isNumeric!T ||
        isBoolean!T || isStaticArray!T ||
        is(T == Matrix3) || is(T == Matrix4), "Invalid type "~T.stringof);

        static if(is(T == Matrix3) || is(T == Matrix4))
            data = HipRenderer.getMatrix(data);

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
    import implementations.renderer.shader.var_packing;

    ShaderVarLayout[string] variables;
    private string[] namesOrder;
    string name;
    ShaderTypes shaderType;
    protected void* data;
    protected void* additionalData;
    protected bool isAdditionalAllocated;
    ///Can't unlock Layout
    private bool isLocked;

    ///The hint are used for the Shader backend as a notifier
    public immutable int hint;
    protected uint lastPosition;

    ///A function that must return a variable size when position = 0
    private VarPosition function(
        ref ShaderVar* v,
        uint lastAlignment = 0,
        bool isLast = false,
        uint n = float.sizeof)
    packFunc;


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

        switch(HipRenderer.getRendererType())
        {
            case HipRendererType.GL3:
                // if(hint & ShaderHint.GL_USE_STD_140)
                    packFunc = &glSTD140;
                break;
            case HipRendererType.D3D11:
                // if(hint & ShaderHint.D3D_USE_HLSL_4)
                    packFunc = &dxHLSL4;  
                break;
            case HipRendererType.NONE:
            default:break;
        }
        if(packFunc is null) packFunc = &nonePack;

        foreach(ShaderVar* v; variables)
        {
            assert(v.shaderType == t, "ShaderVariableLayout must contain only one shader type");
            assert((v.name in this.variables) is null, "Variable named "~v.name~" is already in the layout "~name);
            this.variables[v.name] = ShaderVarLayout(v, 0, 0);
            namesOrder~= v.name;
        }
        calcAlignment();
        data = malloc(getLayoutSize());
        assert(data != null, "Out of memory");
    }
    void lock()
    {
        calcAlignment();
        this.isLocked = true;
    }

    final void calcAlignment()
    {
        uint lastAlign = 0;
        for(int i = 0; i < namesOrder.length; i++)
        {
            ShaderVarLayout* l = &variables[namesOrder[i]];
            VarPosition pos = packFunc(l.sVar, lastAlign, i == cast(int)namesOrder.length-1);
            l.size = pos.size;
            l.alignment = pos.startPos;
            lastAlign = pos.endPos;
        }
        lastPosition = lastAlign;
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
        variables[varName] = ShaderVarLayout(v, 0, 0);
        namesOrder~= varName;
        calcAlignment();
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


private bool isShaderVarNameValid(ref string varName)
{
    import std.algorithm;
    
    return varName.length > 0 && 
    varName.countUntil(" ") == -1;
}