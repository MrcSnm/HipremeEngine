// D import file generated from 'source\hiprenderer\backend\gl\texture.d'
module hiprenderer.backend.gl.texture;
import hiprenderer.texture;
import hiprenderer.backend.gl.renderer;
import data.image;
import bindbc.opengl;

class Hip_GL3_Texture : ITexture
{
	GLuint textureID = 0;
	int width;
	int height;
	uint currentSlot;
	protected int getGLWrapMode(TextureWrapMode mode);
	protected int getGLMinMagFilter(TextureFilter filter);
	void bind();
	void unbind();
	void bind(int slot);
	void unbind(int slot);
	void setWrapMode(TextureWrapMode mode);
	void setTextureFilter(TextureFilter min, TextureFilter mag);
	bool load(Image image);
}
