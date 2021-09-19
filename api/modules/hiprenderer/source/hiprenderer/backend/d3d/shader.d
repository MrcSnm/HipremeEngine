
module hiprenderer.backend.d3d.shader;
version (Windows)
{
	import hiprenderer.renderer;
	import hiprenderer.shader;
	import hiprenderer.backend.d3d.renderer;
	import hiprenderer.backend.d3d.utils;
	import directx;
	class Hip_D3D11_FragmentShader : FragmentShader
	{
		ID3DBlob shader;
		ID3D11PixelShader fs;
		final override string getDefaultFragment();
		final override string getFrameBufferFragment();
		final override string getGeometryBatchFragment();
		final override string getSpriteBatchFragment();
		final override string getBitmapTextFragment();
	}
	class Hip_D3D11_VertexShader : VertexShader
	{
		ID3DBlob shader;
		ID3D11VertexShader vs;
		final override string getDefaultVertex();
		final override string getFrameBufferVertex();
		final override string getGeometryBatchVertex();
		final override string getSpriteBatchVertex();
		final override string getBitmapTextVertex();
	}
	class Hip_D3D11_ShaderProgram : ShaderProgram
	{
		Hip_D3D11_VertexShader vs;
		Hip_D3D11_FragmentShader fs;
		ID3D11ShaderReflection vReflector;
		ID3D11ShaderReflection pReflector;
		bool initialize();
	}
	struct Hip_D3D11_ShaderVarAdditionalData
	{
		ID3D11Buffer buffer;
		uint id;
	}
	class Hip_D3D11_ShaderImpl : IShader
	{
		import util.data_structures : Pair;
		FragmentShader createFragmentShader();
		VertexShader createVertexShader();
		ShaderProgram createShaderProgram();
		bool compileShader(ref ID3DBlob shaderPtr, string shaderPrefix, string shaderSource);
		bool compileShader(VertexShader _vs, string shaderSource);
		bool compileShader(FragmentShader _fs, string shaderSource);
		bool linkProgram(ref ShaderProgram _program, VertexShader vs, FragmentShader fs);
		void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
		void setCurrentShader(ShaderProgram _program);
		void useShader(ShaderProgram program);
		int getId(ref ShaderProgram prog, string name);
		void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts);
		void initTextureSlots(ref ShaderProgram prog, Texture texture, string varName, int slotsCount);
		void createVariablesBlock(ref ShaderVariablesLayout layout);
		void deleteShader(FragmentShader* _fs);
		void deleteShader(VertexShader* _vs);
		void dispose(ref ShaderProgram prog);
	}
}
