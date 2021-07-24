module implementations.renderer.tilemap;
import std.conv:to;
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

struct Tile
{
    ushort id;
    TileProperty[string] properties;
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
    string texturePath; //"image"
    uint  textureHeight; //"imageheight"
    uint  textureWidth; //"imagewidth"
    int margin;
    string name;
    int spacing;
    uint tilecount;
    uint tileheight;
    
}

enum Tiled = import("source/implementations/renderer/map1.json");

class Tilemap
{
    uint width;
    uint height;
    bool isInfinite;
    TileLayer[] layers;
    string orientation;
    string renderorder;
    string tiled_version;

    uint tileHeight;
    Tileset[] tilesets;


    static Tilemap readTiled()
    {
        Tilemap ret = new Tilemap();
        JSONValue json = parseJSON(Tiled);
        ret.height =    cast(uint)json["height"].integer;
        ret.isInfinite =          json["infinite"].boolean;
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

            ret.layers~= layer;
        }

        ret.orientation = json["orientation"].str;
        ret.renderorder = json["renderorder"].str;
        ret.tileHeight  = cast(uint)json["tileheight"].integer;

        JSONValue tilesets = json["tilesets"].array;

        foreach(t; tilesets)
        {
            Tileset tileset;

            tileset.columns     = cast(ushort)t["columns"].integer;
            tileset.firstgid    = cast(ushort)t["firstgid"].integer;
        }

        return ret;
    }
}