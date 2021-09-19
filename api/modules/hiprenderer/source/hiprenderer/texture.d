
module hiprenderer.texture;
import data.assetmanager;
import error.handler;
import hiprenderer.renderer;
import data.image;
import bindbc.sdl;
public import util.data_structures : Array2D;
enum TextureWrapMode 
{
	CLAMP_TO_EDGE,
	CLAMP_TO_BORDER,
	REPEAT,
	MIRRORED_REPEAT,
	MIRRORED_CLAMP_TO_EDGE,
	UNKNOWN,
}
enum TextureFilter 
{
	LINEAR,
	NEAREST,
	NEAREST_MIPMAP_NEAREST,
	LINEAR_MIPMAP_NEAREST,
	NEAREST_MIPMAP_LINEAR,
	LINEAR_MIPMAP_LINEAR,
}
interface ITexture
{
	void setWrapMode(TextureWrapMode mode);
	void setTextureFilter(TextureFilter min, TextureFilter mag);
	bool load(Image img);
	void bind();
	void bind(int slot);
	void unbind();
	void unbind(int slot);
}
class Texture
{
	Image img;
	uint width;
	uint height;
	TextureFilter min;
	TextureFilter mag;
	package ITexture textureImpl;
	protected this()
	{
		textureImpl = HipRenderer.getTextureImplementation();
	}
	this(string path = "")
	{
		this();
		if (path != "")
			load(path);
	}
	public void bind();
	public void bind(int slot);
	public void unbind();
	public void unbind(int slot);
	public void setWrapMode(TextureWrapMode mode);
	public void setTextureFilter(TextureFilter min, TextureFilter mag);
	SDL_Rect getBounds();
	void render(int x, int y);
	public bool load(string path);
}
class TextureRegion
{
	Texture texture;
	public 
	{
		float u1;
		float v1;
		float u2;
		float v2;
	}
	protected float[8] vertices;
	int regionWidth;
	int regionHeight;
	this(string texturePath, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
	{
		texture = new Texture(texturePath);
		setRegion(u1, v1, u2, v2);
	}
	this(Texture texture, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
	{
		this.texture = texture;
		setRegion(u1, v1, u2, v2);
	}
	this(Texture texture, uint u1, uint v1, uint u2, uint v2)
	{
		this.texture = texture;
		setRegion(texture.width, texture.height, u1, v1, u2, v2);
	}
	public static Array2D!TextureRegion spritesheet(Texture t, uint frameWidth, uint frameHeight, uint width, uint height, uint offsetX, uint offsetY, uint offsetXPerFrame, uint offsetYPerFrame);
	static Array2D!TextureRegion spritesheet(Texture t, uint frameWidth, uint frameHeight);
	public void setRegion(float u1, float v1, float u2, float v2);
	void setRegion(uint width, uint height, uint u1, uint v1, uint u2, uint v2);
	void setRegion(uint u1, uint v1, uint u2, uint v2);
	public ref float[8] getVertices();
}
