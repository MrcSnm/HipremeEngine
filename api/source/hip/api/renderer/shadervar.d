module hip.api.renderer.shadervar;
import hip.api.renderer.core;
import hip.api.renderer.shader;
import hip.api.graphics.color;
import hip.math.vector;
public import hip.api.renderer.shadervar;

/**
*   Changes how the Shader behaves based on the backend
*/
enum ShaderHint : ubyte
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
    custom,
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
        else static if(is(T == float[3]) || is(T == Vector3)) return floating3;
        else static if(is(T == float[4]) || is(T == HipColorf) || is(T == Vector4)) return floating4;
        else static if(isTypeArrayOf!(float, T, 9)) return floating3x3;
        else static if(isTypeArrayOf!(float, T, 16)) return floating4x4;
        else static if(is(T == float[])) return floating_array;
        else static if(is(T == IHipTexture[])) return texture_array;
        else static if(is(T == struct)) return custom;
        else return none;
    }
}
private size_t sizeFromType(T)()
{
    static assert(!is(T == int[]) && !is(T == float[]) && !is(T == uint[]), "Unsupported yet.");
    return T.sizeof;
}
private size_t singleSizeFromType(T)()
{
    import std.traits:isArray;
    static if(isArray!T)
        return T.init[0].sizeof;
    else
        return T.sizeof;
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
    bool isDynamicArrayReference;
    bool isDirty = true;
    size_t singleSize;

    ShaderHint flags;
    ShaderVariablesLayout layout;
    ///Used only for UniformType.custom
    ShaderVar[] variables;
    public bool isBlackboxed() const { return (flags & ShaderHint.Blackbox) != 0;}
    public bool usesMaxTextures() const { return (flags & ShaderHint.MaxTextures) != 0;}


    size_t varSize() const{return data.length;}
    size_t length() const {return varSize / singleSize;}

    T get(T)() const
    {
        static if(isDynamicArray!T)
            return cast(T)data;
        else
            return *(cast(T*)this.data.ptr);
    }


    private void setDirty()
    {
        foreach(v; variables)
            v.setDirty();
        this.layout.isDirty = true;
        isDirty = true;
    }

    bool setBlackboxed(T)(T value)
    {
        import core.stdc.string;
        if(value.sizeof != varSize || !isBlackboxed) return false;
        setDirty();
        memcpy(data.ptr, &value, varSize);
        return true;
    }
    bool set(T)(const T value, bool validateData)
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
    private static ShaderVar createBase(
        ShaderTypes t,
        string varName,
        UniformType type,
        size_t varSize,
        size_t singleSize,
        ShaderVariablesLayout layout,
        ubyte[] buffer
    )
    {
        if(!isShaderVarNameValid(varName))
            throw new Exception("Variable '"~varName~"' is invalid.");
        ShaderVar s;
        s.data = buffer[0..varSize];
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
    ShaderVar sVar;
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
    private ShaderVarLayout*[] varOrder;
    private string[] unusedBlackboxed;
    string name;
    ///char* representation of name
    const(char)* nameZeroEnded;
    protected IShader owner;

    //Single block representation of variables content
    protected ubyte[] data;
    protected void* additionalData;

    ///The hint are used for the Shader backend as a notifier
    public immutable int hint;
    protected size_t lastPosition;

    ///A function that must return a variable size when position = 0
    private VarPosition function(
        size_t varSize,
        size_t lastAlignment,
        bool isLast,
        UniformType type
    ) packFunc;

    ShaderTypes shaderType;
    private TypeInfo fromType;
    bool isDirty = true;
    protected bool isAdditionalAllocated;

    /**
    *   Use the layout name for mentioning the uniform/cbuffer block name.
    *
    *   Its members are the ShaderVar* passed
    *
    *   Params:
    *       layoutName = From which block it will be accessed on the shader
    *       t = What is the shader type that holds those variables
    *       hint = Use ShaderHint for additional information, multiple hints may be passed
    */
    private this(HipRendererType type, string layoutName, ShaderTypes t, ShaderHint hint, TypeInfo from)
    {
        import core.stdc.stdlib:malloc;
        this.name = layoutName;
        this.nameZeroEnded = (layoutName~"\0").ptr;
        this.shaderType = t;
        this.hint = hint;
        this.fromType = from;

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
    }

    private void doCopy(TypeInfo t, void* data, size_t dataSize)
    {
        import core.stdc.string;
        if(t !is fromType)
            throw new Exception("ShaderVariableLayout usage Error: "~
            "\n\tType Expected: "~fromType.toString~
            "\n\tType Received: "~t.toString
            );
        // if(memcmp(this.data.ptr, data, dataSize) != 0)
        // {
        //     this.isDirty = true;
        //     memcpy(this.data.ptr, data, dataSize);
        // }
    }

    void set(T)(const T data)
    {
        import core.stdc.string;
        doCopy(typeid(T), cast(void*)&data, T.sizeof);
        static foreach(i, mem; __traits(allMembers, T))
        {
            // if(memcmp(getBlockData + varOrder[i].alignment, &__traits(getMember, data, mem), varOrder[i].size) != 0)
            {
                varOrder[i].sVar.set(__traits(getMember, data, mem), false);
                // varOrder[i].sVar.isDirty = true;
                this.isDirty = true;
            }

        }
    }


    const(char)* nameStringz() const
    {
        return this.nameZeroEnded;
    }
    
    private static ShaderVar[] getVars(T)(ref ShaderVariablesLayout layout, ref ShaderVar base, size_t lastAlign)
    {
        ShaderVar[] vars = [];
        foreach(mem; __traits(allMembers, T))
        {
            alias member = __traits(getMember, T, mem);
            alias Tmem = typeof(member);
            alias a = __traits(getAttributes, member);
            VarPosition pos = layout.packFunc(sizeFromType!(Tmem), lastAlign, false, uniformTypeFrom!Tmem);
            
            string actualName;
            if(uniformTypeFrom!Tmem == UniformType.custom)
                actualName = base.name~"."~mem;
            else
                actualName = base.name~"."~mem~"\0";
            ShaderVar v = ShaderVar.createBase(layout.shaderType, actualName, uniformTypeFrom!Tmem, sizeFromType!Tmem, singleSizeFromType!Tmem, layout, layout.data[lastAlign..pos.endPos]);

            static if(uniformTypeFrom!Tmem == UniformType.custom)
                v.variables = getVars!(Tmem)(layout, v, lastAlign);
            vars~= v;
            lastAlign = pos.endPos;
        }
        return vars;
    }

    static ShaderVariablesLayout from(T)(HipRendererInfo info)
    {
        enum attr = __traits(getAttributes, T);
        static assert(is(typeof(attr[0]) == HipShaderUniform),
            "Type "~T.stringof~" doesn't have a HipShaderUniform attached to it."
        );
        static assert(attr[0].instanceName.length, "instanceName should be specified if you're using OpenGL.");
        enum shaderType = attr[0].type;
        static assert(
            attr[0].name !is null,
            "HipShaderUniform "~T.stringof~" must contain a name as it is required to work in Direct3D 11"
        );
        ShaderVariablesLayout ret = new ShaderVariablesLayout(info.type, attr[0].name, shaderType, ShaderHint.NONE, typeid(T));
        ret.data = new ubyte[ret.calcLayoutSize!T(ret.packFunc)];

        size_t lastAlign = 0;
        foreach(i, mem; __traits(allMembers, T))
        {
            alias member = __traits(getMember, T, mem);
            alias Tmem = typeof(member);
            alias a = __traits(getAttributes, member);
            string actualName = attr[0].instanceName~"."~mem;

            /**
            *   Calculates the shader variables alignment based on the packFunc passed at startup.
            *   Those functions are based on the shader vendor and version. Align should be called
            *   always when there is a change on the layout.
            */
            VarPosition pos = ret.packFunc(
                sizeFromType!(Tmem), 
                lastAlign, 
                i == cast(int)__traits(allMembers, T).length-1,
                uniformTypeFrom!Tmem
            );
            ShaderVarLayout v = ShaderVarLayout(
                ShaderVar.createBase(shaderType, actualName, uniformTypeFrom!Tmem, sizeFromType!Tmem, singleSizeFromType!Tmem, ret, ret.data[pos.startPos..pos.endPos]),
                pos.startPos,
                pos.size
            );

            static if(uniformTypeFrom!Tmem == UniformType.custom)
            {
                ///This is only needed for old OpenGL!!!
                v.sVar.variables = ShaderVariablesLayout.getVars!(Tmem)(ret, v.sVar, lastAlign);
            }
            lastAlign = pos.endPos;
            size_t uSize = info.uniformMapper(shaderType, uniformTypeFrom!Tmem);

            static if(is(typeof(a[0]) == ShaderHint) && a[0] & ShaderHint.Blackbox)
            {
                // if(uSize == 0)
                //     throw new Exception("Unused blackboxed: "~mem);//unusedBlackboxed~= mem;
                v.sVar.flags|= a[0];
            }
            ret.variables[actualName] = v;
            ret.varOrder~= actualName in ret.variables;
        }
        ret.lastPosition = lastAlign;
        return ret;
    }

    IShader getShader(){return owner;}
    void lock(IShader owner)
    {
        if(this.owner is null)
            this.owner = owner;
    }

    private size_t calcLayoutSize(T)(VarPosition function(
        size_t varSize,
        size_t lastAlignment,
        bool isLast,
        UniformType type
    ) packFunc
    )
    {
        size_t lastAlign = 0;
        static foreach(i, mem; __traits(allMembers, T))
        {{
            VarPosition pos = packFunc(
                sizeFromType!(typeof(__traits(getMember, T, mem))),
                lastAlign, 
                i == cast(int)__traits(allMembers, T).length-1, 
                uniformTypeFrom!(typeof(__traits(getMember, T, mem)))
            );
            lastAlign = pos.endPos;
        }}
        return lastAlign;
    }

    void* getBlockData(){return data.ptr;}

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
        import core.memory;
        foreach (ref v; variables)
        {
            v.sVar.dispose();
            v.alignment = 0;
            v.size = 0;
        }
        if(data !is null)
            GC.free(data.ptr);
        if(isAdditionalAllocated && additionalData != null)
            GC.free(additionalData);
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