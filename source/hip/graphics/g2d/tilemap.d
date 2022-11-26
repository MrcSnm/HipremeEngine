/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.graphics.g2d.tilemap;
import hip.filesystem.hipfs;
import hip.math.rect;
import hip.graphics.g2d.spritebatch;
import hip.util.string;
import std.file;
import hip.util.file;
import std.json;
import hip.error.handler;
import hip.assets.texture;


import hip.util.reflection;
enum hasTSXSupport = Version.HipTSX && hasModule!"arsd.dom";

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

struct  TileProperty
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
    ushort currentFrame;
    HipTextureRegion region;
    TileProperty[string] properties;
    TileAnimationFrame[] animation;
    alias properties this;
}

class TileLayer
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


    void render(Tilemap map, HipSpriteBatch batch, bool shouldRenderBatch = false)
    {
        uint w = width, h = height;
        uint th = map.tileHeight, tw = map.tileWidth;

        ushort lastId;
        HipTextureRegion lastTexture;


        for(int i = 0, _y = y; i < w; i++, _y+= th)
            for(int j =0, _x = x; j < h; j++, _x+= tw)
            {
                ushort targetTile = tiles[i*w+j];
                if(targetTile == 0)
                    continue;
                if(lastId != targetTile)
                {
                    /**
                    * Probably worth caching as it is: 
                    * - one pointer dereference (map->)
                    * - one function call (getTextureRegionForID)
                    * - one function call (getTilesetForID)
                    * - one pointer derefenrece (tileset->)
                    * - one function call (getTextureRegion)
                    */
                    lastId = targetTile;
                    lastTexture = map.getTextureRegionForID(targetTile);
                }
                batch.draw(lastTexture, _x, _y);
            }

        if(shouldRenderBatch)
            batch.render();
    }
    
}

class Tileset
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

    HipTexture texture;
    int margin;
    string name;

    ///Only available when loaded via .tsx
    string path;
    int spacing;
    uint tileCount;
    uint tileHeight;
    uint tileWidth;

    ///Usually only accessed when looking for a specific property
    Tile[] tiles;

    this(uint tileCount)
    {
        this.tiles = new Tile[tileCount];
        this.tileCount = tileCount;
    }

    
    static if(hasTSXSupport)
    {
        import arsd.dom;

        static Tileset fromTSX(ubyte[] tsxData, string tsxPath, bool autoLoadTexture = true)
        {
            string xmlFile = cast(string)tsxData;
            auto document = new XmlDocument(xmlFile);
            auto tileset = document.querySelector("tileset");
            return Tileset.fromXMLElement(tileset, tsxPath, autoLoadTexture);
        }

        
        static Tileset fromXMLElement(Element tileset, string tsxPath="", bool autoLoadTexture=true)
        {
            auto image   = tileset.querySelector("image");

            const uint tileCount = to!uint(tileset.getAttribute("tilecount"));
            Tileset ret = new Tileset(tileCount);
            ret.path = tsxPath;

            //Tileset
            ret.name        =         tileset.getAttribute("name");
            ret.tileWidth   = to!uint(tileset.getAttribute("tilewidth"));
            ret.tileHeight  = to!uint(tileset.getAttribute("tileheight"));
            ret.columns     = to!uint(tileset.getAttribute("columns"));

            //Image
            ret.texturePath   =         image.getAttribute("source");
            ret.textureWidth  = to!uint(image.getAttribute("width"));
            ret.textureHeight = to!uint(image.getAttribute("height"));

            if(autoLoadTexture)
                ret.loadTexture();
            
            Element[] tiles = tileset.querySelectorAll("tile");

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

            return ret;
        }


        static Tileset fromTSX(string tsxPath, bool autoLoadTexture = true)
        {
            void[] tsxData;
            if(!HipFS.read(tsxPath, tsxData))
            {
                import hip.error.handler;
                ErrorHandler.showWarningMessage("Could not load TSX ", tsxPath);
                return null;
            }
            return fromTSX(cast(ubyte[])tsxData, tsxPath, autoLoadTexture);
        }

        protected static TileLayer tileLayerFromElement(Element l)
        {
            import hip.util.string:split;
            import hip.util.file:stripLineBreaks;
            TileLayer layer = new TileLayer();
            layer.type    = TileLayerType.TILE_LAYER;
            layer.id      = to!ushort(l.getAttribute("id"));
            layer.name    =           l.getAttribute("name");
            layer.width   =   to!uint(l.getAttribute("width"));
            layer.height  =   to!uint(l.getAttribute("height"));
            string[] data = l.querySelector("data").innerText.stripLineBreaks.split(",");
            layer.tiles.reserve(data.length);
            for(int i = 0; i < data.length;i++)
                layer.tiles~=to!ushort(data[i]);
            
            return layer;
        }

        protected static TileLayer objectLayerFromElement(Element objgroup)
        {
            TileLayer layer = new TileLayer();
            layer.type = TileLayerType.OBJECT_LAYER;
            layer.id   = toDefault!(ushort)(objgroup.getAttribute("id"));
            layer.name = objgroup.getAttribute("name");
            Element[] objs = objgroup.querySelectorAll("object");
            foreach(o; objs)
            {
                TileLayerObject obj;
                obj.gid     = toDefault!(ushort)(o.getAttribute("gid"));
                obj.height  =   toDefault!(uint)(o.getAttribute("height"));
                obj.id      = toDefault!(ushort)(o.getAttribute("id"));
                obj.name    =            (o.getAttribute("name"));
                obj.rotation=    toDefault!(int)(o.getAttribute("rotation"));
                obj.type    =            (o.getAttribute("type"));
                obj.visible =   toDefault!(bool)(o.getAttribute("visible"));
                obj.width   =   toDefault!(uint)(o.getAttribute("width"));
                obj.x       =    toDefault!(int)(o.getAttribute("x"));
                obj.y       =    toDefault!(int)(o.getAttribute("y"));
                Element[] props = o.querySelectorAll("properties");
                foreach(p; props)
                {
                    TileProperty tp;
                    tp.name  = p.getAttribute("name");
                    tp.type  = p.getAttribute("type");
                    tp.value = p.getAttribute("value");
                    obj.properties[tp.name] = tp;
                }
            }
            return layer;
        }
        static Tilemap readTiledTMX(string tiledPath)
        {
            void[] tmxData;
            if(!HipFS.read(tiledPath, tmxData))
            {
                import hip.error.handler;
                ErrorHandler.showWarningMessage("Could not read Tiled TMX from path ", tiledPath);
                return null;
            }
            return readTiledTMX(cast(ubyte[])tmxData, tiledPath);
        }

        static Tilemap readTiledTMX(ubyte[] tiledData, string tiledPath, bool autoLoadTexture = true)
        {
            Tilemap ret = new Tilemap();
            string xmlFile = cast(string)tiledData;
            auto document = new XmlDocument(xmlFile);
            auto map = document.querySelector("map");
            ret.path = tiledPath;

            ret.tiled_version =         map.getAttribute("tiledVersion");
            ret.orientation   =         map.getAttribute("orientation");
            ret.width         = to!uint(map.getAttribute("width"));
            ret.height        = to!uint(map.getAttribute("height"));
            ret.tileWidth     = to!uint(map.getAttribute("tilewidth"));
            ret.tileHeight    = to!uint(map.getAttribute("tileheight"));
            ret.isInfinite    = (to!uint(map.getAttribute("infinite")) == 1);
            ret.renderorder   =         map.getAttribute("renderorder");

            auto tileset = document.querySelectorAll("tileset");

            foreach(t; tileset)
            {
                string tsxPath = t.getAttribute("source");
                Tileset set;
                if(tsxPath != null)
                    set = Tileset.fromTSX(ret.getTSXPath(tsxPath), autoLoadTexture);
                else
                {
                    set = Tileset.fromXMLElement(t, ret.getTSXPath("null"));
                    //Using getTSXPath with any string, as it will be replaced later 
                    //For the texture path
                }
                set.firstGid = to!uint(t.getAttribute("firstgid"));
                ret.tilesets~=set;
            }

            auto layers = document.querySelectorAll("map > layer");
            foreach(l; layers)
            {
                TileLayer layer = Tilemap.tileLayerFromElement(l);
                ret.layersArray~= layer;
                ret.layers[layer.name] = layer;
            }

            Element[] objGroups = document.querySelectorAll("map > objectgroup");
            foreach(objGroup; objGroups)
            {
                TileLayer layer = Tilemap.objectLayerFromElement(objGroup);
                ret.layers[layer.name] = layer;
            }

            return ret;
        }


    }
    else static if(Version.HipTSX)
    {
        static assert(false, `Please call dub add arsd-official:dom for using TSX parser`);
    }

    void loadTexture()
    {
        import hip.util.path:replaceFileName;
        ErrorHandler.assertExit(texturePath != "", "No texture path for loading tilemap texture");

        string texPath = replaceFileName(path, texturePath);

        texture = new HipTexture(texPath);

        int i = 0;
        for(int y = 0; y < textureHeight; y+= tileHeight)
            for(int x = 0; x < textureWidth; x+= tileWidth)
            {
                Tile* t = &tiles[i];
                t.region = new HipTextureRegion(texture, x, y, x+tileWidth, y+tileHeight);
                i++;
            }
    }

    HipTextureRegion getTextureRegion(ushort id)
    {
        return tiles[id - firstGid].region;
    }
    Tile* getTile(ushort id){return &tiles[id - firstGid];}

    // alias tiles this;
}


class Tilemap
{
    string path;
    uint width;
    uint height;
    bool isInfinite;
    ///Used for rendering order
    protected TileLayer[] layersArray;
    TileLayer[string] layers;
    string orientation;
    string renderorder;
    string tiled_version;

    uint tileHeight;
    uint tileWidth;
    Tileset[] tilesets;

    string getTSXPath(string tsxName)
    {
        import hip.util.path : replaceFileName;
        return replaceFileName(path, tsxName);
    }

    void render(HipSpriteBatch batch)
    {
        foreach(l; layers)
            l.render(this, batch);
    }

    Tileset getTilesetForID(ushort id)
    {
        if(tilesets.length == 1)
            return tilesets[0];
        for(int i = 0; i < tilesets.length-1; i++)
        {
            if(id >= tilesets[i].firstGid && id < tilesets[i+1].firstGid)
                return tilesets[i];
        }
        return tilesets[$-1];
    }
    HipTextureRegion getTextureRegionForID(ushort id)
    {
        return getTilesetForID(id).getTextureRegion(id);
    }
    Tile* getTileForID(ushort id){return getTilesetForID(id).getTile(id);}

    
    static Tilemap readTiledJSON(ubyte[] tiledData)
    {
        Tilemap ret = new Tilemap();
        JSONValue json = parseJSON(cast(string)(tiledData));
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
            TileLayer layer = new TileLayer();

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
            ret.layersArray~=layer;
            ret.layers[layer.name] = layer;
        }

        JSONValue[] jtilesets = json["tilesets"].array;

        foreach(t; jtilesets)
        {
            uint tileCount = cast(uint)t["tilecount"].integer;
            Tileset tileset;

            const(JSONValue)* source = ("source" in t);
            if(source !is null)
            {
                version(HipTSX)
                    tileset = Tileset.fromTSX(source.str);
                else
                    assert(0, "No TSX support");
            }
            else
            {
                tileset = new Tileset(tileCount);
                tileset.columns       = cast(ushort)t["columns"].integer;
                tileset.texturePath   =             t["image"].str;
                tileset.textureHeight =   cast(uint)t["imageheight"].integer;
                tileset.textureWidth  =   cast(uint)t["imagewidth"].integer;
                tileset.margin        =    cast(int)t["margin"].integer;
                tileset.name          =             t["name"].str;
                tileset.spacing       =    cast(int)t["spacing"].integer;
                tileset.tileHeight    =   cast(uint)t["tileheight"].integer;
                tileset.tileWidth     =   cast(uint)t["tilewidth"].integer;
            }
            tileset.firstGid      = cast(ushort)t["firstgid"].integer;

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
        ret.tilesets~= tileset;
        }

        return ret;
    }
    static Tilemap readTiledJSON(string tiledPath)
    {
        void[] jsonData;
        if(!HipFS.read(tiledPath, jsonData))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not read Tiled TMX from path ", tiledPath);
            return null;
        }
        return readTiledJSON(cast(ubyte[])jsonData);
    }

    alias layers this;
}