
module hiprenderer.backend.d3d.texture;
version (Windows)
{
	import hiprenderer.backend.d3d.renderer;
	import data.image;
	import directx.d3d11;
	import bindbc.sdl;
	import error.handler;
	import hiprenderer.texture;
	private __gshared ID3D11ShaderResourceView nullSRV = null;
	private __gshared ID3D11SamplerState nullSamplerState = null;
	class Hip_D3D11_Texture : ITexture
	{
		ID3D11Texture2D texture;
		ID3D11ShaderResourceView resource;
		ID3D11SamplerState sampler;
		float[4] borderColor;
		int filter;
		int wrap;
		void setTextureFilter(TextureFilter mag, TextureFilter min);
		package void updateSamplerState();
		public void setWrapMode(TextureWrapMode mode);
		public bool load(Image image);
		void bind();
		void bind(int slot);
		void unbind();
		void unbind(int slot);
	}
	pure int Hip_D3D11_getTextureFilter(TextureFilter min, TextureFilter mag);
	pure int Hip_D3D11_getWrapMode(TextureWrapMode mode);
}
