
module graphics.g2d.tilemap;
import util.string;
import util.file;
import data.hipfs;
import math.rect;
import graphics.g2d.spritebatch;
import hiprenderer.texture;

import arsd.dom;

enum TileLayerType 
{
	TILE_LAYER = "tilelayer",
	IMAGE_LAYER = "imagelayer",
	OBJECT_LAYER = "objectgroup",
}
enum TileDrawOrder 
{
	TOP_DOWN,
	DOWN_TOP,
}
struct TileProperty
{
	string name;
	string type;
	string value;
	T get(T)()
	{
		return to!T(value);
	}
	void set(string v);
	void set(T)(T v)
	{
		value = to!string(v);
	}
}
struct TileLayerObject
{
	ushort gid;
	uint height;
	ushort id;
	string name;
	int rotation;
	string type;
	bool visible;
	uint width;
	int x;
	int y;
	TileProperty[string] properties;
}
struct TileAnimationFrame
{
	ushort id;
	int duration;
}
struct Tile
{
	ushort id;
	ushort currentFrame;
	TextureRegion region;
	TileProperty[string] properties;
	TileAnimationFrame[] animation;
	alias properties this;
}
class TileLayer
{
	string name;
	ushort[] tiles;
	bool visible;
	int x;
	int y;
	int width;
	int height;
	ushort id;
	string type;
	string drawOrder;
	TileProperty[string] properties;
	float opacity;
	void render(Tilemap map, HipSpriteBatch batch, bool shouldEndBatch = false);
}
class Tileset
{
	uint columns;
	uint firstGid;
	string texturePath;
	uint textureHeight;
	uint textureWidth;
	Texture texture;
	int margin;
	string name;
	string path;
	int spacing;
	uint tileCount;
	uint tileHeight;
	uint tileWidth;
	Tile[] tiles;
	this(uint tileCount)
	{
		this.tiles = new Tile[tileCount];
		this.tileCount = tileCount;
	}
	static Tileset fromTSX(ubyte[] tsxData, string tsxPath, bool autoLoadTexture = true);
	static Tileset fromXMLElement(Element tileset, string tsxPath = "", bool autoLoadTexture = true);
	static Tileset fromTSX(string tsxPath, bool autoLoadTexture = true);
	void loadTexture();
	TextureRegion getTextureRegion(ushort id);
	Tile* getTile(ushort id);
}
class Tilemap
{
	string path;
	uint width;
	uint height;
	bool isInfinite;
	protected TileLayer[] layersArray;
	TileLayer[string] layers;
	string orientation;
	string renderorder;
	string tiled_version;
	uint tileHeight;
	uint tileWidth;
	Tileset[] tilesets;
	string getTSXPath(string tsxName);
	void render(HipSpriteBatch batch);
	Tileset getTilesetForID(ushort id);
	TextureRegion getTextureRegionForID(ushort id);
	Tile* getTileForID(ushort id);
	static Tilemap readTiledTMX(ubyte[] tiledData, string tiledPath, bool autoLoadTexture = true);
	protected static TileLayer tileLayerFromElement(Element l);
	protected static TileLayer objectLayerFromElement(Element objgroup);
	static Tilemap readTiledTMX(string tiledPath);
	static Tilemap readTiledJSON(ubyte[] tiledData);
	static Tilemap readTiledJSON(string tiledPath);
	alias layers this;
}
