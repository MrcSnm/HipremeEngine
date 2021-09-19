
module graphics.g2d.bitmaptext;
import graphics.g2d;
import graphics.mesh;
import util.data_structures;
import math.matrix;
import hiprenderer;


enum HipTextAlign 
{
	CENTER,
	TOP,
	LEFT,
	RIGHT,
	BOTTOM,
}
struct HipBitmapChar
{
	uint id;
	int x;
	int y;
	int width;
	int height;
	int xoffset;
	int yoffset;
	int xadvance;
	int page;
	int chnl;
	float normalizedX;
	float normalizedY;
	float normalizedWidth;
	float normalizedHeight;
}

interface IHipBitmapFont
{
	void readAtlas(string atlasPath);
	void readTexture(string texturePath = "");
	static HipBitmapFont fromFile(string atlasPath, string texturePath = "");
}

abstract class AHipBitmapFont : IHipBitmapFont
{
	Texture texture;
	string atlasPath;
	string atlasTexturePath;
	HipBitmapChar[] characters;
	uint charactersCount;
	uint spaceWidth;
	uint lineBreakHeight;
	Pair!(int, int)[][int] kerning;
}

interface IHipBitmapText
{
	void setBitmapFont(HipBitmapFont font);
	protected void updateAlign(int lineNumber);
	float[] getVertices();
	void setText(string text);
	void render();
}

abstract class AHipBitmapText : IHipBitmapText
{
	HipBitmapFont font;
	Mesh mesh;
	int x;
	int y;
	int displayX;
	int displayY;
	uint width;
	uint height;
	uint[] linesWidths;
	HipTextAlign alignh = HipTextAlign.LEFT;
	HipTextAlign alignv = HipTextAlign.TOP;
	index_t[] indices;
	float[] vertices;
	string text;
}
