module hip.api.renderer.shadervar;
import hip.api.renderer.core;
import hip.api.renderer.shader;
import hip.api.graphics.color;
public import hip.api.renderer.shadervar;

/**
*   Changes how the Shader behaves based on the backend
*/
enum ShaderHint : uint
{
    NONE = 0,
    GL_USE_BLOCK = 1<<0,
    GL_USE_STD_140 = 1<<1,
    D3D_USE_HLSL_4 = 1<<2,
    /**
     * Meant for usage in uniform variables.
     * That means one Shader Variable may not be sent to the backend depending on its requirements.
     * An example for that is Array of Textures. In D3D11, it depends only on the resource being bound,
     * while on Metal and GL3, they are required to be inside a MTLBuffer or being sent as an Uniform.
     */
    Blackbox = 1 << 3,
    MaxTextures = 1 << 4
}

/**
*   Should not be used directly. The D type inference can already set that for you.
*   This is stored by the variable to know how to access itself and comunicate the shader.
*/
enum UniformType : ubyte
{
    boolean,
    integer,
    integer_array,
    uinteger,
    uinteger_array,
    floating,
    floating2,
    floating3,
    floating4,
    floating2x2,
    floating3x3,
    floating4x4,
    floating_array,
    ///Special type that is implemented by renderers backend
    texture_array,
    none
}

UniformType uniformTypeFrom(T)()
{
    import hip.util.reflection;

    with(UniformType)
    {
        static if(is(T == bool)) return boolean;
        else static if(is(T == int)) return integer;
        else static if(is(T == int[])) return integer_array;
        else static if(is(T == uint) || is(T == HipColor)) return uinteger;
        else static if(is(T == uint[])) return uinteger_array;
        else static if(is(T == float)) return floating;
        else static if(is(T == float[2])) return floating2;
        else static if(is(T == float[3])) return floating3;
        else static if(is(T == float[4]) || is(T == HipColorf)) return floating4;
        else static if(isTypeArrayOf!(float, T, 9)) return floating3x3;
        else static if(isTypeArrayOf!(float, T, 16)) return floating4x4;
        else static if(is(T == float[])) return floating_array;
        else static if(is(T == IHipTexture[])) return texture_array;
        else return none;
    }
}

/**
*   Struct that holds uniform/cbuffer information for Direct3D and OpenGL shaders. It can be any type.
*   Its data is accessed by the ShaderVariableLayout when sendVars is called. Thus, depending on its
*   corrensponding type, its data is uploaded to the GPU.
*/
struct ShaderVar
{
    import hip.util.data_structures:Array;
    import std.traits;
    void[] data;
    string name;
    ShaderTypes shaderType;
    UniformType type;
    size_t singleSize;
    bool isDynamicArrayReference;
    bool isDirty = true;

    ShaderHint flags;
    ShaderVariablesLayout layout;
    public bool isBlackboxed() const { return (flags & ShaderHint.Blackbox) != 0;}
    public bool usesMaxTextures() const { return (flags & ShaderHint.MaxTextures) != 0;}


    size_t varSize() const{return data.length;}
    size_t length() const {return varSize / singleSize;}

    const T get(T)()
    {
        static if(isDynamicArray!T)
            return cast(T)data;
        else
            return *(cast(T*)this.data.ptr);
    }


    private void setDirty()
    {
        this.isDirty = true;
        this.layout.isDirty = true;
    }

    bool setBlackboxed(T)(T value)
    {
        import core.stdc.string;
        if(value.sizeof != varSize || !isBlackboxed) return false;
        setDirty();
        memcpy(data.ptr, &value, varSize);
        return true;
    }
    bool set(T)(T value, bool validateData)
    {
        import core.stdc.string;
        static assert(uniformTypeFrom!T != UniformType.none, "Invalid type "~T.stringof);
        static if(isDynamicArray!T)
        {
            memcpy(data.ptr, value.ptr, value.length * T.init[0].sizeof);
        }
        else
        {
            if(value.sizeof != varSize)
                return false;
            if(!isBlackboxed && validateData)
            {
                import hip.math.matrix;
                auto current = get!T;
                static if(is(T == Matrix3) || is(T == Matrix4))
                {
                    if(value == current || value == current.transpose)
                        return true;
                }
                else
                {
                    if(value == current)
                        return true;
                }
            }
            memcpy(data.ptr, &value, varSize);
        }
        setDirty();
        return true;
    }

    private void throwOnOutOfBounds(size_t index)
    {
        import hip.util.conv:to;
        switch(type) with(UniformType)
        {
            case boolean, integer, uinteger, floating:
                throw new Exception("Unsupported type '"~type.to!string~"' for indexing on shader vairable "~name);
            default:
                if(index >= this.length)
                    throw new Exception("Index "~index.to!string~" ot of range [0.."~length.to!string~"] on shader variable "~name);
        }
    }

    auto opIndexAssign(T)(T value, size_t index)
    {
        import hip.util.conv:to;
        import core.stdc.string;
        throwOnOutOfBounds(index);
        if(index * singleSize + T.sizeof > varSize)
        {
            throw new Exception("Value assign of type "~T.stringof~" at index "~to!string(index)~
            " is invalid for shader variable "~name~" of type "~to!string(type));
        }

        memcpy(cast(ubyte*)data + singleSize*index, &value, T.sizeof);
        return value;
    }

    ref auto opIndex(size_t index)
    {
        throwOnOutOfBounds(index);
        switch(type) with(UniformType)
        {
            case integer_array: return get!(int[])[index];
            case uinteger_array: return get!(uint[])[index];
            case floating_array: return get!(float[])[index];
            case floating2: return get!(float[2])[index];
            case floating3: return get!(float[3])[index];
            case floating4: return get!(float[4])[index];
            case floating2x2: return get!(float[4])[index];
            case floating3x3: return get!(float[9])[index];
            case floating4x4: return get!(float[16])[index];
            default: return 0;
        }
    }

    static ShaderVar* create(ShaderTypes t, string varName, bool data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.boolean, data.sizeof, data.sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, int data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.integer, data.sizeof, data.sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, uint data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.uinteger, data.sizeof, data.sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, float data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.floating, data.sizeof, data.sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, float[2] data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.floating2, data.sizeof, data[0].sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, float[3] data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.floating3, data.sizeof, data[0].sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, float[4] data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.floating4, data.sizeof, data[0].sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, float[9] data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.floating3x3, data.sizeof, data[0].sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, float[16] data, ShaderVariablesLayout layout){return ShaderVar.create(t, varName, &data, UniformType.floating4x4, data.sizeof, data[0].sizeof, layout);}
    static ShaderVar* create(ShaderTypes t, string varName, int[] data, ShaderVariablesLayout layout)
    {
        return ShaderVar.create(t, varName, data.ptr, UniformType.floating_array, int.sizeof*data.length, int.sizeof, layout, true);
    }
    static ShaderVar* create(ShaderTypes t, string varName, uint[] data, ShaderVariablesLayout layout)
    {
        return ShaderVar.create(t, varName, data.ptr, UniformType.floating_array, uint.sizeof*data.length, uint.sizeof, layout, true);
    }
    static ShaderVar* create(ShaderTypes t, string varName, float[] data, ShaderVariablesLayout layout)
    {
        return ShaderVar.create(t, varName, data.ptr, UniformType.floating_array, float.sizeof*data.length, float.sizeof, layout, true);
    }

    protected static ShaderVar* create(
        ShaderTypes t,
        string varName,
        void* varData,
        UniformType type,
        size_t varSize,
        size_t singleSize,
        ShaderVariablesLayout layout,
        bool isDynamicArrayReference=false
    )
    {
        ShaderVar* s = createEmpty(t, varName, type, varSize, singleSize, layout);
        s.data[0..varSize] = varData[0..varSize];
        s.isDynamicArrayReference = isDynamicArrayReference;
        return s;
    }
    public static ShaderVar* createEmpty(
        ShaderTypes t,
        string varName,
        UniformType type,
        size_t varSize,
        size_t singleSize,
        ShaderVariablesLayout layout
    )
    {
        if(!isShaderVarNameValid(varName))
            throw new Exception("Variable '"~varName~"' is invalid.");
        ShaderVar* s = new ShaderVar();
        if(varSize != 0)
            s.data = new void[varSize];
        s.name = varName;
        s.singleSize = singleSize;
        s.shaderType = t;
        s.type = type;
        s.layout = layout;
        return s;
    }

    void dispose()
    {
        type = UniformType.none;
        shaderType = ShaderTypes.none;
        singleSize = 0;
        if(isDynamicArrayReference)
        {
            (cast(Array!(int)*)data).dispose();
        }
        else if(data != null)
        {
            import core.memory;
            GC.free(data.ptr);
            data = null;
        }
    }
}

struct ShaderVarLayout
{
    ShaderVar* sVar;
    size_t alignment;
    size_t size;
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
    import hip.api.renderer.var_packing;

    ShaderVarLayout[string] variables;
    private string[] namesOrder;
    private string[] unusedBlackboxed;
    string name;
    ///char* representation of name
    const(char)* nameZeroEnded;
    protected IShader owner;

    //Single block representation of variables content
    protected void* data;
    protected void* additionalData;

    ///The hint are used for the Shader backend as a notifier
    public immutable int hint;
    protected size_t lastPosition;

    ///A function that must return a variable size when position = 0
    private VarPosition function(
        ref ShaderVar* v,
        size_t lastAlignment,
        bool isLast
    ) packFunc;

    ShaderTypes shaderType;
    bool isDirty = true;
    protected bool isAdditionalAllocated;
    ///Can't unlock Layout
    private bool isLocked;

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
    this(HipRendererType type, string layoutName, ShaderTypes t, uint hint, ShaderVar*[] variables ...)
    {
        import core.stdc.stdlib:malloc;
        this.name = layoutName;
        this.nameZeroEnded = (layoutName~"\0").ptr;
        this.shaderType = t;
        this.hint = hint;

        switch(type)
        {
            case HipRendererType.GL3:
                // if(hint & ShaderHint.GL_USE_STD_140)
                    packFunc = &glSTD140;
                break;
            case HipRendererType.D3D11:
                // if(hint & ShaderHint.D3D_USE_HLSL_4)
                    packFunc = &dxHLSL4;
                break;
            case HipRendererType.Metal:
                packFunc = &glSTD140;
                break;
            case HipRendererType.None:
            default:break;
        }
        if(packFunc is null) packFunc = &nonePack;

        foreach(ShaderVar* v; variables)
        {
            if(v.shaderType != t)
                throw new Exception("ShaderVariableLayout must contain only one shader type");
            if(v.name in this.variables)
                throw new Exception("Variable named "~v.name~" is already in the layout "~name);
            this.variables[v.name] = ShaderVarLayout(v, 0, 0);
            namesOrder~= v.name;
        }
        if(variables.length > 0)
        {
            calcAlignment();
            data = malloc(getLayoutSize());
            if(data == null)
                throw new Exception("Out of memory");
        }
    }

    const(char)* nameStringz() const
    {
        return this.nameZeroEnded;
    }

    static ShaderVariablesLayout from(T)(HipRendererInfo info)
    {
        enum attr = __traits(getAttributes, T);
        static if(is(typeof(attr[0]) == HipShaderVertexUniform))
            enum shaderType = ShaderTypes.vertex;
        else static if(is(typeof(attr[0]) == HipShaderFragmentUniform))
            enum shaderType = ShaderTypes.fragment;
        else static assert(false,
            "Type "~T.stringof~" doesn't have a HipShaderVertexUniform nor " ~
            "HipShaderFragmentUniform attached to it."
        );
        static assert(
            attr[0].name !is null,
            "HipShaderUniform "~T.stringof~" must contain a name as it is required to work in Direct3D 11"
        );
        ShaderVariablesLayout ret = new ShaderVariablesLayout(info.type, attr[0].name, shaderType, 0);
        static foreach(mem; __traits(allMembers, T))
        {{
            alias member = __traits(getMember, T.init, mem);
            alias a = __traits(getAttributes, member);
            static if(is(typeof(a[0]) == ShaderHint) && a[0] & ShaderHint.Blackbox)
            {
                size_t length = 1;
                ret.appendBlackboxed(mem, uniformTypeFrom!(typeof(member)), info, length, a[0]);
            }
            else
            {
                ret.append(mem, __traits(getMember, T.init, mem));
            }

        }}

        return ret;
    }

    IShader getShader(){return owner;}
    void lock(IShader owner)
    {
        calcAlignment();
        this.owner = owner;
        this.isLocked = true;
    }

    /**
    *   Calculates the shader variables alignment based on the packFunc passed at startup.
    *   Those functions are based on the shader vendor and version. Align should be called
    *   always when there is a change on the layout.
    */
    final void calcAlignment()
    {
        size_t lastAlign = 0;
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
            memcpy(data+v.alignment, v.sVar.data.ptr, v.size);
        return data;
    }

    protected ShaderVariablesLayout append(string varName, ShaderVar* v)
    {
        import core.stdc.stdlib:realloc;
        if(varName in variables)
            throw new Exception("Variable named "~varName~" is already in the layout "~name);
        if(isLocked)
            throw new Exception("Can't append ShaderVariable after it has been locked");
        variables[varName] = ShaderVarLayout(v, 0, 0);
        assert(varName in variables, "Could not set into variables?");
        assert(variables[varName].sVar == v, "Could not set into variables?");
        namesOrder~= varName;
        calcAlignment();

        // import std.stdio; //FIXME: PROBLEM ON WASM
        // writeln("Created var ", varName, " with hints ", cast(int)v.flags);

        this.data = realloc(this.data, getLayoutSize());
        if(!this.data)
            throw new Exception("Out of memory");
        return this;
    }

    /**
    *   Appends a new variable to this layout.
    *   Type is inferred.
    */
    ShaderVariablesLayout append(T)(string varName, T data)
    {
        return append(varName, ShaderVar.create(this.shaderType, varName, data, this));
    }
    /**
    *   Appends a new variable to this layout.
    *   Type is inferred.
    */
    ShaderVariablesLayout appendBlackboxed(string varName, UniformType t, HipRendererInfo info, size_t count, ShaderHint extraFlags)
    {
        size_t uSize = info.uniformMapper(shaderType, t);
        if(uSize == 0)
        {
            unusedBlackboxed~= varName;
            return this;
        }

        ShaderVar* sV = ShaderVar.createEmpty(this.shaderType, varName, t, uSize*count, uSize, this);
        if((extraFlags & ShaderHint.MaxTextures) != 0)
            sV.setDirty();
        sV.flags|= extraFlags;
        sV.flags|= ShaderHint.Blackbox;

        return append(varName, sV);
    }
    /**
    *   For speed sake, it doesn't check whether it is valid.
    *   That means both a valid and invalid variable would return false (meaning used.)
    */
    bool isUnused(string varName) @nogc const
    {
        foreach(v; unusedBlackboxed) if(v == varName) return true;
        return false;
    }

    final size_t getLayoutSize(){return lastPosition;}
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
    import hip.util.string : indexOf;

    return varName.length > 0 &&
    varName.indexOf(" ") == -1;
}