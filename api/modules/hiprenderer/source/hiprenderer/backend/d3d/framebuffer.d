
module hiprenderer.backend.d3d.framebuffer;
import directx.d3d11;
import error.handler;
import hiprenderer.texture;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
import hiprenderer.shader;
import hiprenderer.backend.d3d.renderer;
import hiprenderer.backend.d3d.texture;
private __gshared ID3D11RenderTargetView nullRenderTargetView = null;
class Hip_D3D11_FrameBuffer : IHipFrameBuffer
{
	Texture retTexture;
	ID3D11Texture2D renderTargetTexture;
	ID3D11RenderTargetView renderTargetView;
	ID3D11ShaderResourceView shaderResourceView;
	this(uint width, uint height)
	{
		create(width, height);
	}
	void create(uint width, uint height);
	void resize(uint width, uint height);
	void bind();
	void unbind();
	void clear();
	Texture getTexture();
	void draw();
	void dispose();
}
