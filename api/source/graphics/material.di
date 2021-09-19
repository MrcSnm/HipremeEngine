// D import file generated from 'source\graphics\material.d'
module graphics.material;
import math.matrix;
import math.vector;
import error.handler;
import hiprenderer.shader;
import hiprenderer.shader.shadervar;
class Material
{
	ShaderVar[string] variables;
	Shader shader;
	this(Shader s)
	{
		this.shader = s;
	}
	void setVertexVar(T)(string varName, T data)
	{
		setVar(ShaderTypes.VERTEX, varName, data);
	}
	void setFragmentVar(T)(string varName, T data)
	{
		setVar(ShaderTypes.FRAGMENT, varName, data);
	}
	alias setPixelVar = setFragmentVar;
	void setGeometryVar(T)(string varName, T data)
	{
		setVar(ShaderTypes.GEOMETRY, varName, data);
	}
	void setVar(ShaderTypes t, string varName, bool data);
	void setVar(ShaderTypes t, string varName, int data);
	void setVar(ShaderTypes t, string varName, uint data);
	void setVar(ShaderTypes t, string varName, float data);
	void setVar(ShaderTypes t, string varName, float[2] data);
	void setVar(ShaderTypes t, string varName, float[3] data);
	void setVar(ShaderTypes t, string varName, float[4] data);
	void setVar(ShaderTypes t, string varName, float[9] data);
	void setVar(ShaderTypes t, string varName, float[16] data);
	void setVar(ShaderTypes t, string varName, Vector2 data);
	void setVar(ShaderTypes t, string varName, Vector3 data);
	void setVar(ShaderTypes t, string varName, Vector4 data);
	void setVar(ShaderTypes t, string varName, Matrix3 data);
	void setVar(ShaderTypes t, string varName, Matrix4 data);
	protected void setVar(ShaderTypes t, string varName, void* varData, UniformType type, ulong varSize);
	protected void setShaderVar(ref ShaderVar v);
	void bind();
}
private string getSetShaderVarCall(string shaderT);
