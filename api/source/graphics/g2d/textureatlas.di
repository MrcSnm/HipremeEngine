// D import file generated from 'source\graphics\g2d\textureatlas.d'
module graphics.g2d.textureatlas;
import util.file;
import std.conv : to;
import std.algorithm : countUntil;
import util.string;
import std.file;
import data.hipfs;
import hiprenderer.texture;
import math.rect;
struct AtlasFrame
{
	string filename;
	bool rotated;
	bool trimmed;
	Rect frame;
	Rect spriteSourceSize;
	Size sourceSize;
	TextureRegion region;
	alias region this;
}
class TextureAtlas
{
	string atlasPath;
	string[] texturePaths;
	AtlasFrame[string] frames;
	Texture texture;
	static TextureAtlas readJSON(ubyte[] data, string atlasPath, string texturePath);
	static TextureAtlas readJSON(string atlasPath, string texturePath = "");
	static TextureAtlas readAtlas(string atlasPath);
	static bool read(string fileName);
	alias frames this;
}
