/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.api.data.tilemap;
public import hip.api.renderer.texture;
public import hip.util.variant;
/**
*   TileLayers representations which can be found from Tiled.
*/
enum TileLayerType
{
    ///The Default one, a data structure holding tile mapping information.
    TILE_LAYER   = "tilelayer",
    ///A simple layer, containing only an image to be rendered above or below the tile layers.
    IMAGE_LAYER  = "imagelayer",
    ///A layer used only to hold data to be used within the gameplay implementation
    OBJECT_LAYER = "objectgroup"
}

enum TileDrawOrder : ubyte
{
    TOP_DOWN,
    DOWN_TOP
}

/**
*   Simple Key/Value type defining a property inside a Tile.
*/
struct TileProperty
{
    string type;
    Variant val;
    pragma(inline, true) T get(T)()
    {
        static if(is(T == string)) return val.get!string;
        else
        {
            if(val.type == Type.string_)
                val = Variant.make!T(val.get!string);
            return val.get!T;
        }
    }
    pragma(inline, true) T set(T)(T v) => val.set(v);
}

enum TiledObjectTypes : ubyte
{
    rect,
    ellipse,
    tile,
    point,
    text,
    line,
    triangle,
    polygon
}


/**
*   A simple object which can mean absolutely anything inside a TileLayer.
*   Usually used for implementing:
-   Camera Dead Zones
-   Event Systems
-   Trigger Areas

    When wanting to get its following type, call either `rect`, `ellipse`, `tile`, `point`, `line`, `triangle`, `polygon` or `text`. Try to avoid calling
    `text` multiple times since it involves 3 associative array accesses.
*/
struct TiledObject
{
    ushort id;
    bool visible;
    TiledObjectTypes dataType;
    string name;
    string type;

    TiledObjectUnion data;
    TileProperty[string] properties;

    ref TiledRectangle rect() @trusted @nogc { assert(dataType == TiledObjectTypes.rect); return data.rect;}
    ref TiledRectangle ellipse() @trusted @nogc { assert(dataType == TiledObjectTypes.ellipse); return data.rect;}
    ref TiledRectangle tile() @trusted @nogc { assert(dataType == TiledObjectTypes.tile); return data.rect;}
    ref int[2] point() @trusted @nogc { assert(dataType == TiledObjectTypes.point); return data.rect.getPoint();}
    ref int[4] line() @trusted @nogc { assert(dataType == TiledObjectTypes.line); return data.rect.getLine();}
    ref int[2][3] triangle() @trusted @nogc { assert(dataType == TiledObjectTypes.triangle); return data.triangle;}
    ref int[2][] polygon() @trusted @nogc { assert(dataType == TiledObjectTypes.polygon); return data.polygon;}

    const(TiledText) text() @trusted
    {
        assert(dataType == TiledObjectTypes.text);
        TileProperty* ff = "__fontFamily" in properties;
        TileProperty* msg = "__text" in properties;
        TileProperty* ww = "__wordWrap" in properties;

        return TiledText(data.rect, msg? msg.get!string : null, ff ? ff.get!string : null, ww ? ww.get!bool : false);
    }
}

struct TiledText
{
    TiledRectangle rect;
    string text;
    string fontFamily;
    bool wordWrap;

    alias rect this;
}
struct TiledRectangle
{
    int x, y, width, height;
    ushort rotation, gid;
    ref int[2] getPoint() @trusted @nogc { return (cast(int*)&this)[0..2]; }
    ref int[4] getLine() @trusted @nogc { return (cast(int*)&this)[0..4]; }
}

union TiledObjectUnion
{
    TiledRectangle rect;
    int[2][3] triangle;
    int[2][] polygon;
}


/**
*   The TileAnimationFrame holds what is the ID of the current frame in a TileAnimation and how much duration.
*/
struct TileAnimationFrame
{
    ushort id;
    int duration;
}

/**
*   The Tile is the smallest piece of a TileMap.
*/
struct Tile
{
    ///ID for backreferencing from TileMap
    ushort id;
    ///Which frame is in its animatoin
    ushort currentFrame;
    ///The tile texture region itself.
    IHipTextureRegion region;
    /**
    *   Properties about the tile. Usually used for implementing gameplay stats such as:
    -   Sounds
    -   Collisions and Collidibles
    -   Visual Effects
    */
    TileProperty[string] properties;
    ///Frames for playing the tile animation
    TileAnimationFrame[] animation;
    alias properties this;
}

/**
*   Tile Layer is a map of tiles consisting in a unique "texture" of tiles.
*/
final class HipTileLayer
{
    ///Layer name on the tilemap editor
    string name;
    ///Data
    ushort[] tiles;
    bool visible = true;
    int x, y, width, height;
    uint tileWidth, tileHeight;
    ushort id;
    string type;
    string drawOrder;
    TileProperty[string] properties;
    TiledObject[] objects;
    float opacity = 1.0;

    this(IHipTilemap map)
    {
        tileWidth = map.tileWidth;
        tileHeight = map.tileHeight;
    }

    /**
    *
    */
    this(string name, uint width, uint height, ushort id, IHipTilemap map)
    {
        this(map);
        this.name = name;
        this.id = id;
        this.width = width;
        this.height = height;
        tiles = new ushort[width*height];
    }

    bool isInLayerBoundaries(int x, int y, int w, int h) const @nogc
    {
        int x2 = x+w;
        int y2 = y+h;

        bool notInBoundariesX = x2 < this.x || x > this.width + this.x;
        if(notInBoundariesX)
            return false;
        bool notInBoundariesY = y2 < this.y || y > this.height + this.y;

        return !notInBoundariesY;
    }

    ///Expects I and J in column/row
    pragma(inline, true)
    ushort getTile(uint i, uint j) @nogc @safe
    {
       return tiles[j*width+i];
    }
    ushort checkedGetTile(uint i, uint j) @nogc @trusted
    {
        int target = j*width+i;
        if(i >= width || j >= height || target < 0 || target >= tiles.length)
            return 0;
        return tiles.ptr[target];
    }

    ///Gets tile from relative X and Y. Does not take into account the layer x, y
    ushort getTileXY(uint x, uint y) @nogc @safe
    {
        return getTile(cast(uint)(x / tileWidth), cast(uint)(y / tileHeight));
    }

    ///Gets tile from absolute X and Y. Takes into account the layer x, y
    ushort checkedGetTileXY(int x, int y) @nogc @trusted
    {
        if(x < this.x || y < this.y || x > this.x+this.width || y > this.y+this.height)
            return 0;
        y-= this.y;
        x-= this.x;
        return checkedGetTile(x / tileWidth, y / tileHeight);
    }
    
}

/**
*   Tileset is a data set containing tiles. It has information about the underlying texture used for a tile.
*/
interface IHipTileset
{
    uint columns() const;

    ///Means where the tileset id starts
    uint firstGid() const;
    

    ///"image" in tiled

    string texturePath() const;
    ///"imageheight" in tiled
    uint  textureHeight() const;
    ///"imagewidth" in tiled 
    uint  textureWidth() const; 

    IHipTexture texture();
    int margin() const;
    string name() const;

    ///Only available when loaded via .tsx
    string path() const;
    int spacing() const;
    uint tileHeight() const;
    uint tileWidth() const;

    ///Usually only accessed when looking for a specific property
    Tile[] tiles();

    final uint tileCount()const {return cast(uint)(cast(IHipTileset)this).tiles.length;}
    final IHipTextureRegion getTextureRegion(ushort id)
    {
        return tiles[id - firstGid].region;
    }
    final Tile* getTile(ushort id){return &tiles[id - firstGid];}
}


/**
*   Tilemap is a set of tile layers. It contains information on the maximum map size, holds all the tilesets needed for
*   actually drawing the layers.
*/
interface IHipTilemap
{
    @nogc ref int x();
    @nogc ref int y();
    @nogc ref HipColor color();
    @nogc ref float scaleX();
    @nogc ref float scaleY();

    ///Returns scaleX as the one to be modified.
    @nogc float scale();
    ///Modifies both scaleX and scaleY at the same time.
    @nogc float scale(float v);
    ref float rotation();
    

    string path() const;
    uint width() const @nogc;
    uint height() const @nogc;
    bool isInfinite() const @nogc;
    ref HipTileLayer[string] layers();
    string orientation() const @nogc;
    string renderorder() const @nogc;
    string tiled_version() const @nogc;

    uint tileHeight() const @nogc;
    uint tileWidth() const @nogc;

    final uint tileWidthScaled() @nogc {return cast(uint)(scaleX * tileWidth);}
    final uint tileHeightScaled() @nogc {return cast(uint)(scaleY * tileHeight);}

    void setTileSize(uint tileWidth, uint tileHeight);
    ///Use it when programatically creating your tilemap
    void addTileset(IHipTileset tileset);
    ///Use it when programatically creating your tilemap
    final HipTileLayer addNewLayer(string layerName, uint columns, uint rows)
    {
        return layers[layerName] = new HipTileLayer(layerName, columns, rows, cast(ushort)layers.length, this);
    }
    

    IHipTileset getTilesetForID(ushort id);
    final IHipTextureRegion getTextureRegionForID(ushort id){return getTilesetForID(id).getTextureRegion(id);}
    final Tile* getTileForID(ushort id){return getTilesetForID(id).getTile(id);}


    alias layers this;
}