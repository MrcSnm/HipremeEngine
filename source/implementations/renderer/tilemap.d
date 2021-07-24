module implementations.renderer.tilemap;
import std.conv:to;
import arsd.dom;
import util.file;
import std.json;

enum TileLayerType
{
    TILE_LAYER   = "tilelayer",
    IMAGE_LAYER  = "imagelayer",
    OBJECT_LAYER = "objectgroup"
}
enum TileDrawOrder
{
    TOP_DOWN,
    DOWN_TOP
}

struct TileProperty
{
    string name;
    string type;
    string value;

    T get(T)(){return to!T(value);}
    void set(string v){value = v;}
    void set(T)(T v){value = to!string(v);}
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
    TileProperty[string] properties;
    TileAnimationFrame[] animation;
    alias properties this;
}

struct TileLayer
{
    string name;
    ushort[] tiles;
    bool visible;
    int x, y, width, height;
    ushort id;
    string type;
    string drawOrder;
    TileProperty[string] properties;
    float opacity;
    
}

class Tileset
{
    uint columns;
    uint firstGid;
    string texturePath; //"image"
    uint  textureHeight; //"imageheight"
    uint  textureWidth; //"imagewidth"
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


    static auto fromTSX(string tsxPath)
    {
        string xmlFile = getFileContent(tsxPath);
        auto document = new XmlDocument(xmlFile);
        import std.stdio;
        auto tileset = document.querySelector("tileset");
        auto image = document.querySelector("image");

        uint tileCount = to!uint(tileset.getAttribute("tilecount"));
        Tileset ret = new Tileset(tileCount);

        //Tileset
        ret.name        =         tileset.getAttribute("name");
        ret.tileWidth   = to!uint(tileset.getAttribute("tilewidth"));
        ret.tileHeight  = to!uint(tileset.getAttribute("tileheight"));
        ret.columns     = to!uint(tileset.getAttribute("columns"));

        //Image
        ret.texturePath   =         image.getAttribute("source");
        ret.textureWidth  = to!uint(image.getAttribute("width"));
        ret.textureHeight = to!uint(image.getAttribute("height"));
        
        Element[] tiles = document.querySelectorAll("tile");

        foreach(t; tiles)
        {
            Tile tile;
            tile.id = to!ushort(t.getAttribute("id"));
            Element anim = t.querySelector("animation");
            if(anim !is null)
            {
                Element[] frames = anim.querySelectorAll("frame");
                tile.animation = new TileAnimationFrame[frames.length];

                foreach(f; frames)
                {
                    TileAnimationFrame tFrame;
                    tFrame.id       = to!ushort(f.getAttribute("tileid"));
                    tFrame.duration =    to!int(f.getAttribute("duration"));
                }
            }
        }

        return document;
    }

    alias tiles this;
}

enum Tiled = import("source/implementations/renderer/map1.json");

class Tilemap
{
    uint width;
    uint height;
    bool isInfinite;
    TileLayer[string] layers;
    string orientation;
    string renderorder;
    string tiled_version;

    uint tileHeight;
    uint tileWidth;
    Tileset[] tilesets;


    static Tilemap readTiled()
    {
        Tilemap ret = new Tilemap();
        JSONValue json = parseJSON(Tiled);
        ret.height     =    cast(uint)json["height"].integer;
        ret.isInfinite =              json["infinite"].boolean;
        ret.width      =    cast(uint)json["width"].integer;
        ret.orientation=              json["orientation"].str;
        ret.renderorder=              json["renderorder"].str;
        ret.tileHeight =    cast(uint)json["tileheight"].integer;
        ret.tileWidth  =    cast(uint)json["tilewidth"].integer;

        JSONValue[] layers =      json["layers"].array;

        foreach(l; layers)
        {
            TileLayer layer;

            //Check first the layer type.
            layer.type    =             l["type"].str;
            layer.id      = cast(ushort)l["id"].integer;
            layer.name    =             l["name"].str;
            layer.opacity =             l["opacity"].integer;
            layer.visible =             l["visible"].boolean;
            layer.x       = cast(int)   l["x"].integer;
            layer.y       = cast(int)   l["y"].integer;
            if(layer.type == TileLayerType.OBJECT_LAYER)
            {
                JSONValue[] objs = l["objects"].array;

                foreach(o; objs)
                {
                    TileLayerObject obj;
                    obj.gid     = cast(ushort)o["gid"].integer;
                    obj.height  = cast(uint)  o["height"].integer;
                    obj.id      = cast(ushort)o["id"].integer;
                    obj.name    =             o["name"].str;
                    obj.rotation= cast(int)   o["rotation"].integer;
                    obj.type    =             o["type"].str;
                    obj.visible =             o["visible"].boolean;
                    obj.width   = cast(uint)  o["width"].integer;
                    obj.x       = cast(int)   o["x"].integer;
                    obj.y       = cast(int)   o["y"].integer;

                    const(JSONValue)* v = ("properties" in o);
                    if(v != null)
                    {
                        const(JSONValue)[] props = v.array;
                        foreach(p; props)
                        {
                            TileProperty tp;
                            tp.name  = p["name"].str;
                            tp.type  = p["type"].str;
                            tp.value = p["value"].toString;

                            obj.properties[tp.name] = tp;
                        }
                    }
                }
            }
            else if(layer.type == TileLayerType.TILE_LAYER)
            {
                JSONValue[] layerData = l["data"].array;
                layer.height  = cast(uint)  l["height"].integer;
                layer.width   = cast(uint)  l["width"].integer;
                layer.tiles.reserve(layerData.length);
                foreach(d; layerData)
                    layer.tiles~= cast(ushort)d.integer;
            }

            const(JSONValue)* layerProp = ("properties" in l);
            if(layerProp != null)
            {
                const(JSONValue)[] layerProps = layerProp.array;
                foreach(p; layerProps)
                {
                    TileProperty tp;
                    tp.name  = p["name"].str;
                    tp.type  = p["type"].str;
                    tp.value = p["value"].toString;
                    layer.properties[tp.name] = tp;
                }
            }

            ret.layers[layer.name] = layer;
        }

        JSONValue[] tilesets = json["tilesets"].array;

        foreach(t; tilesets)
        {
            uint tileCount = cast(uint)t["tilecount"].integer;
            Tileset tileset = new Tileset(tileCount);

            tileset.columns       = cast(ushort)t["columns"].integer;
            tileset.firstGid      = cast(ushort)t["firstgid"].integer;
            tileset.texturePath   =             t["image"].str;
            tileset.textureHeight =   cast(uint)t["imageheight"].integer;
            tileset.textureWidth  =   cast(uint)t["imagewidth"].integer;
            tileset.margin        =    cast(int)t["margin"].integer;
            tileset.name          =             t["name"].str;
            tileset.spacing       =    cast(int)t["spacing"].integer;
            tileset.tileHeight    =   cast(uint)t["tileheight"].integer;
            tileset.tileWidth     =   cast(uint)t["tilewidth"].integer;

            JSONValue[] tiles = t["tiles"].array;

            foreach (currentTile; tiles)
            {
                Tile tile;
                tile.id = cast(ushort)currentTile["id"].integer;
                
                JSONValue[] tProps = currentTile["properties"].array;
                foreach(prop; tProps)
                {
                    TileProperty _p;

                    _p.name  = prop["name"].str;
                    _p.type  = prop["type"].str;
                    _p.value = prop["value"].toString;
                    tile.properties[_p.name] = _p;
                }
                tileset.tiles[tile.id] = tile;
            }
        }

        return ret;
    }

    alias layers this;
}