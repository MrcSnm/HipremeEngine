
module hiprenderer.backend.gl.framebuffer;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
import hiprenderer.shader;
import hiprenderer.texture;
import hiprenderer.backend.gl.texture;
class Hip_GL3_FrameBuffer : IHipFrameBuffer
{
	Texture retTexture;
	uint rbo;
	uint fbo;
	uint texture;
	this(int width, int height)
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
