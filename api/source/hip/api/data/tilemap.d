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

enum TileDrawOrder
{
    TOP_DOWN,
    DOWN_TOP
}

/**
*   Simple Key/Value type defining a property inside a Tile.
*/
struct TileProperty
{
    string name;
    string type;
    string value;
    void set(string v){value = v;}

    version(Have_util)
    {
        T get(T)()
        {
            import hip.util.conv;
            return to!T(value);
        }
        void set(T)(T v)
        {
            import hip.util.conv;
            value = to!string(v);
        }
    }
}

/**
*   A simple object which can mean absolutely anything inside a TileLayer.
*   Usually used for implementing:
-   Camera Dead Zones
-   Event Systems
-   Trigger Areas
*/
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
    bool visible;
    int x, y, width, height;
    ushort id;
    string type;
    string drawOrder;
    TileProperty[string] properties;
    float opacity;
}

/**
*   Tileset is a data set containing tiles. It has information about the underlying texture used for a tile.
*/
abstract class HipTileset
{
    uint columns;

    ///Means where the tileset id starts
    uint firstGid;

    ///"image" in tiled
    string texturePath; 
    ///"imageheight" in tiled
    uint  textureHeight;
    ///"imagewidth" in tiled 
    uint  textureWidth; 

    IHipTexture texture;
    int margin;
    string name;

    ///Only available when loaded via .tsx
    string path;
    int spacing;
    uint tileCount;
    uint tileHeight;
    uint tileWidth;

    ///Usually only accessed when looking for a specific property
    public Tile[] tiles;

    this(uint tileCount)
    {
        this.tiles = new Tile[tileCount];
        this.tileCount = tileCount;
    }

    IHipTextureRegion getTextureRegion(ushort id)
    {
        return tiles[id - firstGid].region;
    }
    Tile* getTile(ushort id){return &tiles[id - firstGid];}
}


/**
*   Tilemap is a set of tile layers. It contains information on the maximum map size, holds all the tilesets needed for
*   actually drawing the layers.
*/
interface IHipTilemap
{
    string path() const;
    uint width() const;
    uint height() const;
    bool isInfinite() const;
    ref HipTileLayer[string] layers();
    string orientation() const;
    string renderorder() const;
    string tiled_version() const;

    uint tileHeight() const;
    uint tileWidth() const;

    HipTileset getTilesetForID(ushort id);
    final IHipTextureRegion getTextureRegionForID(ushort id)
    {
        return getTilesetForID(id).getTextureRegion(id);
    }
    final Tile* getTileForID(ushort id){return getTilesetForID(id).getTile(id);}

    alias layers this;
}