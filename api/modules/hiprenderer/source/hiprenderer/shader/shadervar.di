// D import file generated from 'source\hiprenderer\shader\shadervar.d'
module hiprenderer.shader.shadervar;
import hiprenderer.shader.shader;
import hiprenderer.renderer;
import error.handler;
import std.conv : to;
import math.matrix;
enum ShaderHint : uint
{
	NONE = 0,
	GL_USE_BLOCK = 1 << 0,
	GL_USE_STD_140 = 1 << 1,
	D3D_USE_HLSL_4 = 1 << 2,
}
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
	none,
}
struct ShaderVar
{
	import util.data_structures : Array;
	import std.traits;
	void* data;
	string name;
	ShaderTypes shaderType;
	UniformType type;
	ulong singleSize;
	ulong varSize;
	bool isDynamicArrayReference;
	const T get(T)()
	{
		static if (isDynamicArray!T)
		{
			alias _t = typeof(T.init[0]);
			Array!_t* arr = cast(Array!_t*)data;
			return arr.data[0..arr.length];
		}
		else
		{
			return *cast(T*)this.data;
		}
	}
	bool set(T)(T value)
	{
		import core.stdc.string;
		static assert(isNumeric!T || isBoolean!T || isStaticArray!T || isDynamicArray!T || is(T == Matrix3) || is(T == Matrix4), "Invalid type " ~ T.stringof);
		static if (is(T == Matrix3) || is(T == Matrix4))
		{
			value = HipRenderer.getMatrix(value);
		}

		if (value.sizeof != varSize)
			return false;
		static if (isDynamicArray!T)
		{
			alias _t = typeof(T.init[0]);
			Array!_t* arr = cast(Array!_t*)data;
			arr.dispose();
			Array!_t temp = Array!_t.fromDynamicArray(value);
			memcpy(data, &temp, varSize);
		}
		else
		{
			memcpy(data, &value, varSize);
		}
		return true;
	}
	auto opAssign(T)(T value)
	{
		static if (is(T == ShaderVar))
		{
			this.data = value.data;
			this.name = value.name;
			this.shaderType = value.shaderType;
			this.varSize = value.varSize;
			this.singleSize = value.singleSize;
		}
		else
		{
			ErrorHandler.assertExit(this.set(value), "Value set for '" ~ name ~ "' is invalid.");
		}
		return this;
	}
	private void throwOnOutOfBounds(size_t index);
	auto opIndexAssign(T)(T value, size_t index)
	{
		import core.stdc.string;
		throwOnOutOfBounds(index);
		ErrorHandler.assertExit(index * singleSize + T.sizeof <= varSize, "Value assign of type " ~ T.stringof ~ " at index " ~ to!string(index) ~ " is invalid for shader variable " ~ name ~ " of type " ~ to!string(type));
		if (isDynamicArrayReference)
			(cast(Array!T*)data)[index] = value;
		else
			memcpy(cast(ubyte*)data + singleSize * index, &value, T.sizeof);
		return value;
	}
	auto ref opIndex(size_t index)
	{
		throwOnOutOfBounds(index);
		switch (type)
		{
			with (UniformType)
			{
				case floating2:
				{
					return get!(float[2])[index];
				}
				case floating3:
				{
					return get!(float[3])[index];
				}
				case floating4:
				{
					return get!(float[4])[index];
				}
				case floating2x2:
				{
					return get!(float[4])[index];
				}
				case floating3x3:
				{
					return get!(float[9])[index];
				}
				case floating4x4:
				{
					return get!(float[16])[index];
				}
				default:
				{
					ErrorHandler.assertExit(false, "opIndex is unsupported in var of type " ~ to!string(type));
					return 0;
				}
			}
		}
	}
	static ShaderVar* create(ShaderTypes t, string varName, bool data);
	static ShaderVar* create(ShaderTypes t, string varName, int data);
	static ShaderVar* create(ShaderTypes t, string varName, uint data);
	static ShaderVar* create(ShaderTypes t, string varName, float data);
	static ShaderVar* create(ShaderTypes t, string varName, float[2] data);
	static ShaderVar* create(ShaderTypes t, string varName, float[3] data);
	static ShaderVar* create(ShaderTypes t, string varName, float[4] data);
	static ShaderVar* create(ShaderTypes t, string varName, float[9] data);
	static ShaderVar* create(ShaderTypes t, string varName, float[16] data);
	static ShaderVar* create(ShaderTypes t, string varName, int[] data);
	static ShaderVar* create(ShaderTypes t, string varName, uint[] data);
	static ShaderVar* create(ShaderTypes t, string varName, float[] data);
	protected static ShaderVar* create(ShaderTypes t, string varName, void* varData, UniformType type, ulong varSize, ulong singleSize, bool isDynamicArrayReference = false);
	void dispose();
}
struct ShaderVarLayout
{
	ShaderVar* sVar;
	uint alignment;
	uint size;
}
class ShaderVariablesLayout
{
	import hiprenderer.shader.var_packing;
	ShaderVarLayout[string] variables;
	private string[] namesOrder;
	string name;
	ShaderTypes shaderType;
	protected void* data;
	protected void* additionalData;
	protected bool isAdditionalAllocated;
	private bool isLocked;
	public immutable int hint;
	protected uint lastPosition;
	private VarPosition function(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = (float).sizeof) packFunc;
	this(string layoutName, ShaderTypes t, uint hint, ShaderVar*[] variables...)
	{
		import core.stdc.stdlib : malloc;
		this.name = layoutName;
		this.shaderType = t;
		this.hint = hint;
		switch (HipRenderer.getRendererType())
		{
			case HipRendererType.GL3:
			{
				packFunc = &glSTD140;
				break;
			}
			case HipRendererType.D3D11:
			{
				packFunc = &dxHLSL4;
				break;
			}
			case HipRendererType.NONE:
			{
			}
			default:
			{
				break;
			}
		}
		if (packFunc is null)
			packFunc = &nonePack;
		foreach (ShaderVar* v; variables)
		{
			ErrorHandler.assertExit(v.shaderType == t, "ShaderVariableLayout must contain only one shader type");
			ErrorHandler.assertExit((v.name in this.variables) is null, "Variable named " ~ v.name ~ " is already in the layout " ~ name);
			this.variables[v.name] = ShaderVarLayout(v, 0, 0);
			namesOrder ~= v.name;
		}
		calcAlignment();
		data = malloc(getLayoutSize());
		ErrorHandler.assertExit(data != null, "Out of memory");
	}
	void lock();
	final void calcAlignment();
	void* getBlockData();
	ShaderVariablesLayout append(T)(string varName, T data)
	{
		import core.stdc.stdlib : realloc;
		ErrorHandler.assertExit((varName in variables) is null, "Variable named " ~ varName ~ " is already in the layout " ~ name);
		ErrorHandler.assertExit(!isLocked, "Can't append ShaderVariable after it has been locked");
		ShaderVar* v = ShaderVar.create(this.shaderType, varName, data);
		variables[varName] = ShaderVarLayout(v, 0, 0);
		namesOrder ~= varName;
		calcAlignment();
		this.data = realloc(this.data, getLayoutSize());
		ErrorHandler.assertExit(this.data != null, "Out of memory");
		return this;
	}
	final ulong getLayoutSize();
	final void setAdditionalData(void* d, bool isAllocated);
	final const const(void*) getAdditionalData();
	auto opDispatch(string member)()
	{
		return variables[member].sVar;
	}
	void dispose();
}
private bool isShaderVarNameValid(ref string varName);
