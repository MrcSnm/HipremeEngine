// D import file generated from 'source\hiprenderer\backend\gl\shader.d'
module hiprenderer.backend.gl.shader;
import hiprenderer.backend.gl.renderer;
import hiprenderer.shader;
import hiprenderer.renderer;
import hiprenderer.shader.shadervar;
import bindbc.opengl;
version (Android)
{
	enum shaderVersion = "#version 300 es";
	enum floatPrecision = "";
}
else
{
	enum shaderVersion = "#version 330 core";
	enum floatPrecision = "";
}
class Hip_GL3_FragmentShader : FragmentShader
{
	uint shader;
	final override string getDefaultFragment();
	final override string getFrameBufferFragment();
	final override string getSpriteBatchFragment();
	final override string getGeometryBatchFragment();
	final override string getBitmapTextFragment();
}
class Hip_GL3_VertexShader : VertexShader
{
	uint shader;
	final override string getDefaultVertex();
	final override string getFrameBufferVertex();
	final override string getSpriteBatchVertex();
	final override string getGeometryBatchVertex();
	final override string getBitmapTextVertex();
}
class Hip_GL3_ShaderProgram : ShaderProgram
{
	uint program;
}
class Hip_GL3_ShaderImpl : IShader
{
	import util.data_structures : Pair;
	protected ShaderVariablesLayout[] layouts;
	protected Pair!(ShaderVariablesLayout, uint)[] ubos;
	FragmentShader createFragmentShader();
	VertexShader createVertexShader();
	ShaderProgram createShaderProgram();
	bool compileShader(GLuint shaderID, string shaderSource);
	bool compileShader(VertexShader vs, string shaderSource);
	bool compileShader(FragmentShader fs, string shaderSource);
	bool linkProgram(ref ShaderProgram program, VertexShader vs, FragmentShader fs);
	int getId(ref ShaderProgram prog, string name);
	void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
	void setCurrentShader(ShaderProgram program);
	void useShader(ShaderProgram program);
	void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts);
	void initTextureSlots(ref ShaderProgram prog, Texture texture, string varName, int slotsCount);
	void createVariablesBlock(ref ShaderVariablesLayout layout);
	protected void updateUbo(ref Pair!(ShaderVariablesLayout, int) ubo);
	void deleteShader(FragmentShader* _fs);
	void deleteShader(VertexShader* _vs);
	void dispose(ref ShaderProgram prog);
}
