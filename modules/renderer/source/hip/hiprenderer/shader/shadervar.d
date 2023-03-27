/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.shader.shadervar;
import hip.hiprenderer.shader.shader;
import hip.hiprenderer.renderer;
import hip.error.handler;
import hip.util.conv:to;
import hip.math.matrix;
import hip.api.graphics.color;

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
enum UniformType
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
        else static if(is(T == Matrix3)) return floating3x3;
        else static if(is(T == Matrix4)) return floating4x4;
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

    private bool isDirty = true;
    private bool _isBlackboxed = false;
    public bool isBlackboxed() const { return _isBlackboxed;}


    size_t varSize() const{return data.length;}
    size_t length() const {return varSize / singleSize;}

    const T get(T)()
    {
        if(_isBlackboxed) return T.init;
        static if(isDynamicArray!T)
        {
            alias _t = typeof(T.init[0]);
            Array!(_t)* arr = cast(Array!(_t)*)data.ptr;
            return arr.data[0..arr.length];
        }
        else
            return *(cast(T*)this.data.ptr);
    }

    bool setBlackboxed(T)(T value)
    {
        import core.stdc.string;
        if(value.sizeof != varSize || !_isBlackboxed) return false;
        isDirty = true;
        memcpy(data.ptr, &value, varSize);
        return true;
    }
    bool set(T)(T value, bool validateData)
    {
        import core.stdc.string;
        static assert(uniformTypeFrom!T != UniformType.none, "Invalid type "~T.stringof);
        if(value.sizeof != varSize) 
            return false;
        static if(is(T == Matrix3) || is(T == Matrix4))
            value = HipRenderer.getMatrix(value);

        if(!_isBlackboxed && validateData && value == get!T)
            return true;

        isDirty = true;
        static if(isDynamicArray!T)
        {
            if(isDynamicArrayReference)
            {
                alias TI = typeof(T.init[0]);
                if(data != null)
                {
                    Array!(TI)* arr = cast(Array!(TI)*)data;
                    arr.dispose();
                }
                auto temp = Array!TI(value);
                //TODO: May need to check how alignment works when dealing with dynamic arrays.
                data = temp.getRef[0..(void*).sizeof];
            }
            else
                memcpy(data.ptr, value.ptr, varSize);
        }
        else
            memcpy(data.ptr, &value, varSize);
        return true;
    }
    auto opAssign(T)(T value)
    {
        static if(is(T == ShaderVar))
        {
            this.data = value.data;
            this.name = value.name;
            this.shaderType = value.shaderType;
            this.singleSize = value.singleSize;
        }
        else
            ErrorHandler.assertLazyExit(this.set(value), "Value set for '"~name~"' is invalid.");
        return this;
    }

    private void throwOnOutOfBounds(size_t index)
    {
        switch(type) with(UniformType)
        {
            case floating2:
                ErrorHandler.assertExit(index < 2, "Index out of bounds on shader variable "~name);
                break;
            case floating3:
                ErrorHandler.assertExit(index < 3, "Index out of bounds on shader variable "~name);
                break;
            case floating4:
                ErrorHandler.assertExit(index < 4, "Index out of bounds on shader variable "~name);
                break;
            case floating2x2:
                ErrorHandler.assertExit(index < 4, "Index out of bounds on shader variable "~name);
                break;
            case floating3x3:
                ErrorHandler.assertExit(index < 9, "Index out of bounds on shader variable "~name);
                break;
            case floating4x4:
                ErrorHandler.assertExit(index < 16, "Index out of bounds on shader variable "~name);
                break;
            default:
                ErrorHandler.assertExit(false, "opIndex is unsupported in var of type "~to!string(type));
        }
    }

    auto opIndexAssign(T)(T value, size_t index)
    {
        import core.stdc.string;
        throwOnOutOfBounds(index);
        ErrorHandler.assertExit(index*singleSize + T.sizeof <= varSize, "Value assign of type "~T.stringof~" at index "~to!string(index)~
        " is invalid for shader variable "~name~" of type "~to!string(type));

        if(isDynamicArrayReference)
            (cast(Array!(T)*)data)[index] = value;
        else
            memcpy(cast(ubyte*)data + singleSize*index, &value, T.sizeof);
        return value;
    }

    ref auto opIndex(size_t index)
    {
        throwOnOutOfBounds(index);
        switch(type) with(UniformType)
        {
            case floating2: return get!(float[2])[index];
            case floating3: return get!(float[3])[index];
            case floating4: return get!(float[4])[index];
            case floating2x2: return get!(float[4])[index];
            case floating3x3: return get!(float[9])[index];
            case floating4x4: return get!(float[16])[index];
            default:
                ErrorHandler.assertExit(false, "opIndex is unsupported in var of type "~to!string(type));
                return 0;
        }
    }

    static ShaderVar* create(ShaderTypes t, string varName, bool data){return ShaderVar.create(t, varName, &data, UniformType.boolean, data.sizeof, data.sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, int data){return ShaderVar.create(t, varName, &data, UniformType.integer, data.sizeof, data.sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, uint data){return ShaderVar.create(t, varName, &data, UniformType.uinteger, data.sizeof, data.sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, float data){return ShaderVar.create(t, varName, &data, UniformType.floating, data.sizeof, data.sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, float[2] data){return ShaderVar.create(t, varName, &data, UniformType.floating2, data.sizeof, data[0].sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, float[3] data){return ShaderVar.create(t, varName, &data, UniformType.floating3, data.sizeof, data[0].sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, float[4] data){return ShaderVar.create(t, varName, &data, UniformType.floating4, data.sizeof, data[0].sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, float[9] data){return ShaderVar.create(t, varName, &data, UniformType.floating3x3, data.sizeof, data[0].sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, float[16] data){return ShaderVar.create(t, varName, &data, UniformType.floating4x4, data.sizeof, data[0].sizeof);}
    static ShaderVar* create(ShaderTypes t, string varName, int[] data)
    {
        Array!int dRef = Array!int(data);
        return ShaderVar.create(t, varName, &dRef, UniformType.integer_array, dRef.sizeof, dRef[0].sizeof, true);
    }
    static ShaderVar* create(ShaderTypes t, string varName, uint[] data)
    {
        Array!uint dRef = Array!uint(data);
        return ShaderVar.create(t, varName, &dRef, UniformType.uinteger_array, dRef.sizeof, dRef[0].sizeof, true);
    }
    static ShaderVar* create(ShaderTypes t, string varName, float[] data)
    {
        Array!float dRef = Array!float(data);
        return ShaderVar.create(t, varName, &dRef, UniformType.floating_array, dRef.sizeof, dRef[0].sizeof, true);
    }

    protected static ShaderVar* create(
        ShaderTypes t,
        string varName,
        void* varData,
        UniformType type,
        size_t varSize,
        size_t singleSize,
        bool isDynamicArrayReference=false
    )
    {
        import core.stdc.string : memcpy;
        ErrorHandler.assertExit(isShaderVarNameValid(varName), "Variable '"~varName~"' is invalid.");
        ShaderVar* s = new ShaderVar();
        s.data = new void[varSize];
        memcpy(s.data.ptr, varData, varSize);   
        s.name = varName;
        s.shaderType = t;
        s.type = type;
        s.isDynamicArrayReference = isDynamicArrayReference;
        s.singleSize = singleSize;
        return s;
    }
    public static ShaderVar* createBlackboxed(
        ShaderTypes t,
        string varName,
        UniformType type,
        size_t varSize,
        size_t singleSize)
    {
        ErrorHandler.assertExit(isShaderVarNameValid(varName), "Variable '"~varName~"' is invalid.");
        ShaderVar* s = new ShaderVar();
        s.data = new void[varSize];
        s.name = varName;
        s.singleSize = singleSize;
        s.shaderType = t;
        s.type = type;
        return s;
    }

    void dispose()
    {
        type = UniformType.none;
        shaderType = ShaderTypes.NONE;
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
    import hip.hiprenderer.shader.var_packing;

    ShaderVarLayout[string] variables;
    private string[] namesOrder;
    private string[] unusedBlackboxed;
    string name;
    ShaderTypes shaderType;
    protected Shader owner;

    //Single block representation of variables content
    protected void* data;
    protected void* additionalData;
    protected bool isAdditionalAllocated;
    ///Can't unlock Layout
    private bool isLocked;

    ///The hint are used for the Shader backend as a notifier
    public immutable int hint;
    protected size_t lastPosition;

    ///A function that must return a variable size when position = 0
    private VarPosition function(
        ref ShaderVar* v,
        size_t lastAlignment,
        bool isLast
    ) packFunc;


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
            case HipRendererType.METAL:
                packFunc = &glSTD140;
                break;
            case HipRendererType.NONE:
            default:break;
        }
        if(packFunc is null) packFunc = &nonePack;

        foreach(ShaderVar* v; variables)
        {
            ErrorHandler.assertExit(v.shaderType == t, "ShaderVariableLayout must contain only one shader type");
            ErrorHandler.assertExit((v.name in this.variables) is null, "Variable named "~v.name~" is already in the layout "~name);
            this.variables[v.name] = ShaderVarLayout(v, 0, 0);
            namesOrder~= v.name;
        }
        calcAlignment();
        data = malloc(getLayoutSize());
        ErrorHandler.assertExit(data != null, "Out of memory");
    }

    static ShaderVariablesLayout from(T)()
    {
        enum attr = __traits(getAttributes, T);
        static if(is(typeof(attr[0]) == HipShaderVertexUniform))
            enum shaderType = ShaderTypes.VERTEX;
        else static if(is(typeof(attr[0]) == HipShaderFragmentUniform))
            enum shaderType = ShaderTypes.FRAGMENT;
        else static assert(false, 
            "Type "~T.stringof~" doesn't have a HipShaderVertexUniform nor " ~ 
            "HipShaderFragmentUniform attached to it."
        );
        static assert(
            attr[0].name !is null,
            "HipShaderUniform "~T.stringof~" must contain a name as it is required to work in Direct3D 11"
        );
        ShaderVariablesLayout ret = new ShaderVariablesLayout(attr[0].name, shaderType, 0);
        static foreach(mem; __traits(allMembers, T))
        {{
            alias member = __traits(getMember, T.init, mem);
            alias a = __traits(getAttributes, member);
            static if(is(typeof(a[0]) == ShaderHint) && a[0] & ShaderHint.Blackbox)
            {
                size_t length = 1;
                if(a[0] & ShaderHint.MaxTextures) length =  HipRenderer.getMaxSupportedShaderTextures();
                ret.appendBlackboxed(mem, uniformTypeFrom!(typeof(member)), length);
            }
            else
            {
                ret.append(mem, __traits(getMember, T.init, mem));
            }

        }}

        return ret;
    }

    Shader getShader(){return owner;}
    void lock(Shader owner)
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
        ErrorHandler.assertExit((varName in variables) is null, "Variable named "~varName~" is already in the layout "~name);
        ErrorHandler.assertExit(!isLocked, "Can't append ShaderVariable after it has been locked");
        variables[varName] = ShaderVarLayout(v, 0, 0);
        namesOrder~= varName;
        calcAlignment();
        this.data = realloc(this.data, getLayoutSize());
        ErrorHandler.assertExit(this.data != null, "Out of memory");
        return this;
    }

    /**
    *   Appends a new variable to this layout.
    *   Type is inferred.
    */
    ShaderVariablesLayout append(T)(string varName, T data)
    {
        return append(varName, ShaderVar.create(this.shaderType, varName, data));
    }
    /**
    *   Appends a new variable to this layout.
    *   Type is inferred.
    */
    ShaderVariablesLayout appendBlackboxed(string varName, UniformType t, size_t length)
    {
        ShaderVar* sV = HipRenderer.createShaderVar(this.shaderType, t, varName, length);
        if(sV is null)
        {
            unusedBlackboxed~= varName;
            return this;
        }
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