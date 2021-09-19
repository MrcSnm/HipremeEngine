
module hiprenderer.shader.shader;
import math.matrix;
import error.handler;
import hiprenderer.shader.shadervar;
public import hiprenderer.shader.shadervar : ShaderHint, ShaderVariablesLayout, ShaderVar;
import hiprenderer.backend.gl.shader;
import hiprenderer.shader;
import hiprenderer.renderer;
import util.file;
enum ShaderStatus 
{
	SUCCESS,
	VERTEX_COMPILATION_ERROR,
	FRAGMENT_COMPILATION_ERROR,
	LINK_ERROR,
	UNKNOWN_ERROR,
}
enum ShaderTypes 
{
	VERTEX,
	FRAGMENT,
	GEOMETRY,
	NONE,
}
enum HipShaderPresets 
{
	DEFAULT,
	FRAME_BUFFER,
	GEOMETRY_BATCH,
	SPRITE_BATCH,
	BITMAP_TEXT,
	NONE,
}
interface IShader
{
	VertexShader createVertexShader();
	FragmentShader createFragmentShader();
	ShaderProgram createShaderProgram();
	bool compileShader(FragmentShader fs, string shaderSource);
	bool compileShader(VertexShader vs, string shaderSource);
	bool linkProgram(ref ShaderProgram program, VertexShader vs, FragmentShader fs);
	void setCurrentShader(ShaderProgram program);
	void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
	int getId(ref ShaderProgram prog, string name);
	void deleteShader(FragmentShader* fs);
	void deleteShader(VertexShader* vs);
	void createVariablesBlock(ref ShaderVariablesLayout layout);
	void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts);
	void initTextureSlots(ref ShaderProgram prog, Texture texture, string varName, int slotsCount);
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
abstract class ShaderProgram
{
}
public class Shader
{
	VertexShader vertexShader;
	FragmentShader fragmentShader;
	ShaderProgram shaderProgram;
	ShaderVariablesLayout[string] layouts;
	protected ShaderVariablesLayout defaultLayout;
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
		if (status != ShaderStatus.SUCCESS)
		{
			import console.log;
			logln("Failed loading shaders");
		}
	}
	void setFromPreset(HipShaderPresets preset = HipShaderPresets.DEFAULT);
	ShaderStatus loadShaders(string vertexShaderSource, string fragmentShaderSource);
	ShaderStatus loadShadersFromFiles(string vertexShaderPath, string fragmentShaderPath);
	ShaderStatus reloadShaders();
	void setVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
	public void setVertexVar(T)(string name, T val)
	{
		ShaderVar* v = findByName(name);
		if (v != null)
		{
			ErrorHandler.assertExit(v.shaderType == ShaderTypes.VERTEX, "Variable named " ~ name ~ " must be from Vertex Shader");
			v.set(val);
		}
		else
			ErrorHandler.showWarningMessage("Shader Vertex Var not set on shader loaded from '" ~ vertexShaderPath ~ "'", "Could not find shader var with name " ~ name ~ (layouts.length == 0 ? ". Did you forget to addVarLayout on the shader?" : "Did you forget to add a layout namespace to the var name?"));
	}
	public void setFragmentVar(T)(string name, T val)
	{
		ShaderVar* v = findByName(name);
		if (v != null)
		{
			ErrorHandler.assertExit(v.shaderType == ShaderTypes.FRAGMENT, "Variable named " ~ name ~ " must be from Fragment Shader");
			v.set(val);
		}
		else
			ErrorHandler.showWarningMessage("Shader Fragment Var not set on shader loaded from '" ~ fragmentShaderPath ~ "'", "Could not find shader var with name " ~ name ~ (layouts.length == 0 ? ". Did you forget to addVarLayout on the shader?" : "Did you forget to add a layout namespace to the var name?"));
	}
	protected ShaderVar* findByName(string name);
	public ShaderVar* get(string name);
	public void addVarLayout(ShaderVariablesLayout layout);
	public void setDefaultBlock(string blockName);
	void bind();
	auto opDispatch(string member)()
	{
		static if (member == "useLayout")
		{
			isUseCall = true;
			return this;
		}
		else
		{
			if (isUseCall)
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
		ErrorHandler.assertExit(defaultLayout.variables[member].sVar.set(value), "Invalid value of type " ~ T.stringof ~ " passed to " ~ defaultLayout.name ~ "." ~ member);
	}
	void sendVars();
	void initTextureSlots(Texture texture, string varName, int slotsCount);
	protected void deleteShaders();
}
