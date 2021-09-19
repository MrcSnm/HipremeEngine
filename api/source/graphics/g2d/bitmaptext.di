// D import file generated from 'source\graphics\g2d\bitmaptext.d'
module graphics.g2d.bitmaptext;
import graphics.g2d;
import graphics.mesh;
import util.data_structures;
import std.algorithm.comparison : max;
import std.conv : to;
import error.handler;
import console.log;
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
interface IHipBitmapText
{
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
class HipBitmapFont
{
	Texture texture;
	string atlasPath;
	string atlasTexturePath;
	HipBitmapChar[] characters;
	uint charactersCount;
	uint spaceWidth;
	uint lineBreakHeight;
	Pair!(int, int)[][int] kerning;
	void readAtlas(string atlasPath);
	void readTexture(string texturePath = "");
	static HipBitmapFont fromFile(string atlasPath, string texturePath = "");
}
private Shader bmTextShader = null;
class HipBitmapText
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
	this()
	{
		if (bmTextShader is null)
		{
			bmTextShader = HipRenderer.newShader(HipShaderPresets.BITMAP_TEXT);
			bmTextShader.addVarLayout((new ShaderVariablesLayout("Cbuf", ShaderTypes.VERTEX, 0)).append("uModel", Matrix4.identity).append("uView", Matrix4.identity).append("uProj", Matrix4.identity));
			bmTextShader.addVarLayout((new ShaderVariablesLayout("FragBuf", ShaderTypes.FRAGMENT, 0)).append("uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]));
			bmTextShader.setFragmentVar("FragBuf.uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]);
			bmTextShader.uModel = Matrix4.identity;
			const Viewport v = HipRenderer.getCurrentViewport();
			bmTextShader.uView = Matrix4.identity;
			bmTextShader.uProj = Matrix4.orthoLH(0, v.w, v.h, 0, 0.01, 100);
			bmTextShader.bind();
			bmTextShader.sendVars();
		}
		linesWidths.length = 1;
		text = "";
		mesh = new Mesh(HipVertexArrayObject.getXY_ST_VAO(), bmTextShader);
		mesh.createVertexBuffer("DEFAULT".length * 4, HipBufferUsage.DYNAMIC);
		mesh.createIndexBuffer("DEFAULT".length * 6, HipBufferUsage.DYNAMIC);
		mesh.sendAttributes();
	}
	void setBitmapFont(HipBitmapFont font);
	protected void updateAlign(int lineNumber);
	float[] getVertices();
	void setText(string text);
	void render();
}
