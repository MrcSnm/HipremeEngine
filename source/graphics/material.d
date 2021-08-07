module graphics.material;
import math.matrix;
import math.vector;
import implementations.renderer.shader;

class Material
{
    ShaderVar[string] variables;
    Shader shader;
    this(Shader s)
    {
        this.shader = s;
    }

    void setVertexVar(T)(string varName, T data){setVar(ShaderTypes.VERTEX, varName, data);}
    void setFragmentVar(T)(string varName, T data){setVar(ShaderTypes.FRAGMENT, varName, data);}
    alias setPixelVar = setFragmentVar;
    void setGeometryVar(T)(string varName, T data){setVar(ShaderTypes.GEOMETRY, varName, data);}




    void setVar(ShaderTypes t, string varName, bool data){setVar(t, varName, &data, UniformType.boolean, data.sizeof);}
    void setVar(ShaderTypes t, string varName, int data){setVar(t, varName, &data, UniformType.integer, data.sizeof);}
    void setVar(ShaderTypes t, string varName, uint data){setVar(t, varName, &data, UniformType.uinteger, data.sizeof);}
    void setVar(ShaderTypes t, string varName, float data){setVar(t, varName, &data, UniformType.floating, data.sizeof);}
    void setVar(ShaderTypes t, string varName, float[2] data){setVar(t, varName, &data, UniformType.floating2, data.sizeof);}
    void setVar(ShaderTypes t, string varName, float[3] data){setVar(t, varName, &data, UniformType.floating3, data.sizeof);}
    void setVar(ShaderTypes t, string varName, float[4] data){setVar(t, varName, &data, UniformType.floating4, data.sizeof);}
    void setVar(ShaderTypes t, string varName, float[9] data){setVar(t, varName, &data, UniformType.floating3x3, data.sizeof);}
    void setVar(ShaderTypes t, string varName, float[16] data){setVar(t, varName, &data, UniformType.floating4x4, data.sizeof);}
    void setVar(ShaderTypes t, string varName, Vector2 data){setVar(t, varName, &data, UniformType.floating2, data.sizeof);}
    void setVar(ShaderTypes t, string varName, Vector3 data){setVar(t, varName, &data, UniformType.floating3, data.sizeof);}
    void setVar(ShaderTypes t, string varName, Vector4 data){setVar(t, varName, &data, UniformType.floating4, data.sizeof);}
    void setVar(ShaderTypes t, string varName, Matrix3 data){setVar(t, varName, &data, UniformType.floating3x3, data.sizeof);}
    void setVar(ShaderTypes t, string varName, Matrix4 data){setVar(t, varName, &data, UniformType.floating4x4, data.sizeof);}

    protected void setVar(ShaderTypes t, string varName, void* varData, UniformType type, ulong varSize)
    {
        import core.stdc.string : memcpy;
        ShaderVar* variable = (varName in variables);
        if(variable is null)
        {
            import core.stdc.stdlib : malloc;
            ShaderVar s;
            s.data = malloc(varSize);
            s.name = varName;
            s.shaderType = t;
            s.type = type;
            s.varSize = varSize;
            variables[varName] = s;
            variable = (varName in variables);
        }
        memcpy(variable.data, varData, variable.varSize);
    }

    protected void setShaderVar(ref ShaderVar v)
    {
        switch(v.shaderType) with(ShaderTypes)
        {
            case FRAGMENT:
                mixin(getSetShaderVarCall("Fragment"));
                break;
            case VERTEX:
                mixin(getSetShaderVarCall("Vertex"));
                break;
            case GEOMETRY:
            default:
                break;
        }
    }

    void bind()
    {
        shader.bind();
        foreach(ref ShaderVar v; variables)
            setShaderVar(v);
    }
}

private string getSetShaderVarCall(string shaderT)
{
    import util.string : replaceAll;
    return q{
    final switch(v.type) with(UniformType)
    {
        case boolean:
            shader.set$Var(v.name, *cast(bool*)v.data);
            break;
        case integer:
            shader.set$Var(v.name, *cast(int*)v.data);
            break;
        case uinteger:
            shader.set$Var(v.name, *cast(uint*)v.data);
            break;
        case floating:
            shader.set$Var(v.name, *cast(float*)v.data);
            break;
        case floating2:
            shader.set$Var(v.name, *cast(float[2]*)v.data);
            break;
        case floating3:
            shader.set$Var(v.name, *cast(float[3]*)v.data);
            break;
        case floating4:
            shader.set$Var(v.name, *cast(float[4]*)v.data);
            break;
        case floating2x2:
            break;
        case floating3x3:
            shader.set$Var(v.name, *cast(Matrix3*)v.data);
            break;
        case floating4x4:
            shader.set$Var(v.name, *cast(Matrix4*)v.data);
            break;
    }}.replaceAll('$', shaderT);
}