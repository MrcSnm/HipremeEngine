module implementations.renderer.material;
import math.matrix;
import math.vector;

import implementations.renderer.shader;

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
    floating4x4
}

enum ShaderTypes
{
    VERTEX,
    FRAGMENT,
    GEOMETRY //Unsupported yet
}

struct ShaderVar
{
  void* data;
  string name;
  ShaderTypes shaderType;
  UniformType type;
}

class Material
{
    ShaderVar[string] variables;
    Shader shader;
    this(Shader s)
    {
        this.shader = s;
    }

    void setVertexVar(T)(T data, string varName){setVar(ShaderTypes.VERTEX, &data, varName, UniformType.floating4x4);}
    void setFragmentVar(T)(T data, string varName){setVar(ShaderTypes.FRAGMENT, &data, varName, UniformType.boolean);}
    alias setPixelVar = setFragmentVar;
    void setGeometryVar(T)(T data, string varName){setVar(ShaderTypes.GEOMETRY, &data, varName, UniformType.boolean);}




    void setVar(ShaderTypes t, bool data,    string varName){setVar(t, &data, varName, UniformType.boolean);}
    void setVar(ShaderTypes t, int data,     string varName){setVar(t, &data, varName, UniformType.integer);}
    void setVar(ShaderTypes t, uint data,    string varName){setVar(t, &data, varName, UniformType.uinteger);}
    void setVar(ShaderTypes t, float data,   string varName){setVar(t, &data, varName, UniformType.floating);}
    void setVar(ShaderTypes t, Vector2 data, string varName){setVar(t, &data, varName, UniformType.floating2);}
    void setVar(ShaderTypes t, Vector3 data, string varName){setVar(t, &data, varName, UniformType.floating3);}
    void setVar(ShaderTypes t, Vector4 data, string varName){setVar(t, &data, varName, UniformType.floating4);}
    void setVar(ShaderTypes t, Matrix3 data, string varName){setVar(t, &data, varName, UniformType.floating3x3);}
    void setVar(ShaderTypes t, Matrix4 data, string varName){setVar(t, &data, varName, UniformType.floating4x4);}

    void setVar(ShaderTypes t, void* varData, string varName, UniformType type)
    {
        variables[varName] = ShaderVar(varData, varName, t, type);
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