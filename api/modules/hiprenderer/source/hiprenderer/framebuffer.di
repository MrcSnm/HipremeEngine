// D import file generated from 'source\hiprenderer\framebuffer.d'
module hiprenderer.framebuffer;
import hiprenderer.shader;
import hiprenderer.renderer;
import hiprenderer.texture;
interface IHipFrameBuffer
{
	void create(uint width, uint height);
	void resize(uint width, uint height);
	void bind();
	void unbind();
	void draw();
	void clear();
	Texture getTexture();
	void dispose();
}
class HipFrameBuffer : IHipFrameBuffer
{
	Shader currentShader;
	protected IHipFrameBuffer impl;
	int width;
	int height;
	this(IHipFrameBuffer fbImpl, int width, int height, Shader framebufferShader = null)
	{
		impl = fbImpl;
		this.width = width;
		this.height = height;
		if (framebufferShader is null)
			currentShader = HipRenderer.newShader(HipShaderPresets.FRAME_BUFFER);
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
package const float[24] framebufferVertices = [-1.0, -1.0, 0.0, 0.0, 1.0, -1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 0.0, 1.0, -1.0, -1.0, 0.0, 0.0];
