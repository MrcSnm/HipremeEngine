module hip.assets.tilemap;
public import hip.api.data.tilemap;
import hip.config.opts;
import hip.assets.image;
import hip.asset;

class HipTilesetImpl : HipTileset
{
    // static if(hasTSXSupport)
    // {
    //     import arsd.dom;

    //     static Tileset fromTSX(ubyte[] tsxData, string tsxPath, bool autoLoadTexture = true)
    //     {
    //         string xmlFile = cast(string)tsxData;
    //         auto document = new XmlDocument(xmlFile);
    //         auto tileset = document.querySelector("tileset");
    //         return Tileset.fromXMLElement(tileset, tsxPath, autoLoadTexture);
    //     }

        
    //     static Tileset fromXMLElement(Element tileset, string tsxPath="", bool autoLoadTexture=true)
    //     {
    //         auto image   = tileset.querySelector("image");

    //         const uint tileCount = to!uint(tileset.getAttribute("tilecount"));
    //         Tileset ret = new Tileset(tileCount);
    //         ret.path = tsxPath;

    //         //Tileset
    //         ret.name        =         tileset.getAttribute("name");
    //         ret.tileWidth   = to!uint(tileset.getAttribute("tilewidth"));
    //         ret.tileHeight  = to!uint(tileset.getAttribute("tileheight"));
    //         ret.columns     = to!uint(tileset.getAttribute("columns"));

    //         //Image
    //         ret.texturePath   =         image.getAttribute("source");
    //         ret.textureWidth  = to!uint(image.getAttribute("width"));
    //         ret.textureHeight = to!uint(image.getAttribute("height"));

    //         if(autoLoadTexture)
    //             ret.loadTexture();
            
    //         Element[] tiles = tileset.querySelectorAll("tile");

    //         foreach(t; tiles)
    //         {
    //             Tile tile;
    //             tile.id = to!ushort(t.getAttribute("id"));
    //             Element anim = t.querySelector("animation");
    //             if(anim !is null)
    //             {
    //                 Element[] frames = anim.querySelectorAll("frame");
    //                 tile.animation = new TileAnimationFrame[frames.length];

    //                 foreach(f; frames)
    //                 {
    //                     TileAnimationFrame tFrame;
    //                     tFrame.id       = to!ushort(f.getAttribute("tileid"));
    //                     tFrame.duration =    to!int(f.getAttribute("duration"));
    //                 }
    //             }
    //         }

    //         return ret;
    //     }


    //     static Tileset fromTSX(string tsxPath, bool autoLoadTexture = true)
    //     {
    //         void[] tsxData;
    //         if(!HipFS.read(tsxPath, tsxData))
    //         {
    //             import hip.error.handler;
    //             ErrorHandler.showWarningMessage("Could not load TSX ", tsxPath);
    //             return null;
    //         }
    //         return fromTSX(cast(ubyte[])tsxData, tsxPath, autoLoadTexture);
    //     }

    //     protected static TileLayer tileLayerFromElement(Element l)
    //     {
    //         import hip.util.string:split;
    //         import hip.util.file:stripLineBreaks;
    //         TileLayer layer = new TileLayer();
    //         layer.type    = TileLayerType.TILE_LAYER;
    //         layer.id      = to!ushort(l.getAttribute("id"));
    //         layer.name    =           l.getAttribute("name");
    //         layer.width   =   to!uint(l.getAttribute("width"));
    //         layer.height  =   to!uint(l.getAttribute("height"));
    //         string[] data = l.querySelector("data").innerText.stripLineBreaks.split(",");
    //         layer.tiles.reserve(data.length);
    //         for(int i = 0; i < data.length;i++)
    //             layer.tiles~=to!ushort(data[i]);
            
    //         return layer;
    //     }

    //     protected static TileLayer objectLayerFromElement(Element objgroup)
    //     {
    //         TileLayer layer = new TileLayer();
    //         layer.type = TileLayerType.OBJECT_LAYER;
    //         layer.id   = toDefault!(ushort)(objgroup.getAttribute("id"));
    //         layer.name = objgroup.getAttribute("name");
    //         Element[] objs = objgroup.querySelectorAll("object");
    //         foreach(o; objs)
    //         {
    //             TileLayerObject obj;
    //             obj.gid     = toDefault!(ushort)(o.getAttribute("gid"));
    //             obj.height  =   toDefault!(uint)(o.getAttribute("height"));
    //             obj.id      = toDefault!(ushort)(o.getAttribute("id"));
    //             obj.name    =            (o.getAttribute("name"));
    //             obj.rotation=    toDefault!(int)(o.getAttribute("rotation"));
    //             obj.type    =            (o.getAttribute("type"));
    //             obj.visible =   toDefault!(bool)(o.getAttribute("visible"));
    //             obj.width   =   toDefault!(uint)(o.getAttribute("width"));
    //             obj.x       =    toDefault!(int)(o.getAttribute("x"));
    //             obj.y       =    toDefault!(int)(o.getAttribute("y"));
    //             Element[] props = o.querySelectorAll("properties");
    //             foreach(p; props)
    //             {
    //                 TileProperty tp;
    //                 tp.name  = p.getAttribute("name");
    //                 tp.type  = p.getAttribute("type");
    //                 tp.value = p.getAttribute("value");
    //                 obj.properties[tp.name] = tp;
    //             }
    //         }
    //         return layer;
    //     }
    //     static Tilemap readTiledTMX(string tiledPath)
    //     {
    //         void[] tmxData;
    //         if(!HipFS.read(tiledPath, tmxData))
    //         {
    //             import hip.error.handler;
    //             ErrorHandler.showWarningMessage("Could not read Tiled TMX from path ", tiledPath);
    //             return null;
    //         }
    //         return readTiledTMX(cast(ubyte[])tmxData, tiledPath);
    //     }

    //     static Tilemap readTiledTMX(ubyte[] tiledData, string tiledPath, bool autoLoadTexture = true)
    //     {
    //         Tilemap ret = new Tilemap();
    //         string xmlFile = cast(string)tiledData;
    //         auto document = new XmlDocument(xmlFile);
    //         auto map = document.querySelector("map");
    //         ret.path = tiledPath;

    //         ret.tiled_version =         map.getAttribute("tiledVersion");
    //         ret.orientation   =         map.getAttribute("orientation");
    //         ret.width         = to!uint(map.getAttribute("width"));
    //         ret.height        = to!uint(map.getAttribute("height"));
    //         ret.tileWidth     = to!uint(map.getAttribute("tilewidth"));
    //         ret.tileHeight    = to!uint(map.getAttribute("tileheight"));
    //         ret.isInfinite    = (to!uint(map.getAttribute("infinite")) == 1);
    //         ret.renderorder   =         map.getAttribute("renderorder");

    //         auto tileset = document.querySelectorAll("tileset");

    //         foreach(t; tileset)
    //         {
    //             string tsxPath = t.getAttribute("source");
    //             Tileset set;
    //             if(tsxPath != null)
    //                 set = Tileset.fromTSX(ret.getTSXPath(tsxPath), autoLoadTexture);
    //             else
    //             {
    //                 set = Tileset.fromXMLElement(t, ret.getTSXPath("null"));
    //                 //Using getTSXPath with any string, as it will be replaced later 
    //                 //For the texture path
    //             }
    //             set.firstGid = to!uint(t.getAttribute("firstgid"));
    //             ret.tilesets~=set;
    //         }

    //         auto layers = document.querySelectorAll("map > layer");
    //         foreach(l; layers)
    //         {
    //             TileLayer layer = Tilemap.tileLayerFromElement(l);
    //             ret.layersArray~= layer;
    //             ret.layers[layer.name] = layer;
    //         }

    //         Element[] objGroups = document.querySelectorAll("map > objectgroup");
    //         foreach(objGroup; objGroups)
    //         {
    //             TileLayer layer = Tilemap.objectLayerFromElement(objGroup);
    //             ret.layers[layer.name] = layer;
    //         }

    //         return ret;
    //     }


    // }
    // else static if(Version.HipTSX)
    // {
    //     static assert(false, `Please call dub add arsd-official:dom for using TSX parser`);
    // }

    static HipTilesetImpl read (string path, uint firstGid)
    {
        import hip.util.path;
        switch(path.extension)
        {
            case "xml":
            case "tmx":
                assert(false, `Please call dub add arsd-official:dom for using TSX parser`);
            case "tsj":
            case "json":
                return HipTilesetImpl.readJSON(path, firstGid);
            default:
                assert(false, "Unrecognized extension for file "~path);
        }
    }

    static HipTilesetImpl readJSON (string path, uint firstGid)
    {
        import std.json;
        import hip.filesystem.hipfs;
        import hip.console.log;
        string data;

        if(!HipFS.readText(path, data))
        {
            loglnWarn("Could not read file named ", path);
            return null;
        }
        return readJSON(path, parseJSON(data), firstGid);
    }

    import std.json;
    static HipTilesetImpl readJSON (string path, JSONValue t, uint firstGid)
    {
        HipTilesetImpl ret = new HipTilesetImpl(cast(uint)t["tilecount"].integer);
        ret.columns       = cast(ushort)t["columns"].integer;
        ret.texturePath   =             t["image"].str;
        ret.textureHeight =   cast(uint)t["imageheight"].integer;
        ret.textureWidth  =   cast(uint)t["imagewidth"].integer;
        ret.margin        =    cast(int)t["margin"].integer;
        ret.name          =             t["name"].str;
        ret.spacing       =    cast(int)t["spacing"].integer;
        ret.tileHeight    =   cast(uint)t["tileheight"].integer;
        ret.tileWidth     =   cast(uint)t["tilewidth"].integer;
        ret.path = path;
        ret.firstGid = firstGid;

        if("tiles" in t)
        {
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
                ret.tiles[tile.id] = tile;
            }
        }

        return ret;
    }

    import hip.util.data_structures;
    static HipTileset fromSpritesheet(Array2D_GC!IHipTextureRegion regions)
    {
        import hip.error.handler;
        import hip.assets.texture;
        ErrorHandler.assertExit(regions.getWidth > 0 && regions.getHeight > 0, "Invalid spritesheet");
        HipTilesetImpl t = new HipTilesetImpl(regions.getWidth * regions.getHeight);
        t.name = "Created from Spritesheet";
        t.firstGid = 1;
        t.setTexture(regions[0,0].getTexture);
        t.tileWidth = regions[0,0].getWidth();
        t.tileHeight = regions[0,0].getHeight();
        int i = 0;
        for(int y = 0; y < regions.getHeight; y++)
            for(int x = 0; x < regions.getWidth; x++)
            {
                Tile* tile = &t.tiles[i++];
                tile.id = cast(ushort)i;
                tile.region = regions[x, y]; //TODO: May use clone one day if direct assign doesn't fit
                // t.region = (cast(HipTextureRegion)regions[x, y]).clone;
            }

        return t;
    }
    import hip.assets.textureatlas;
    /**
    *   Untested. D's Associative Arrays aren't deterministic, this is subject to bug.
    */
    static HipTileset fromAtlas(HipTextureAtlas atlas)
    {
        HipTilesetImpl t = new HipTilesetImpl(cast(uint)atlas.frames.length);
        t.firstGid = 1;
        t.name = "Tileset from Atlas: "~atlas.name;
        t.setTexture(atlas.texture);
        int i = 0;
        foreach(atlasFrame; atlas)
        {
            Tile* tile = &t.tiles[i++];
            if(!t.tileWidth)
            {
                t.tileWidth = atlasFrame.region.getWidth;
                t.tileHeight = atlasFrame.region.getHeight;
            }
            //TODO: May use clone one day if direct assign doesn't fit.
            tile.region = atlasFrame.region;
            tile.id = cast(ushort)i;
        }
        return t;
    }

    this(uint tileCount){super(tileCount);}

    IImage textureImage;

    IImage loadImage()
    {
        import hip.error.handler;
        import hip.console.log;
        import hip.filesystem.hipfs;
        import hip.util.path;
        if(textureImage is null)
        {
            ErrorHandler.assertExit(texturePath != "", "No texture path for loading tilemap texture");
            string imagePath = replaceFileName(path, texturePath);
            ubyte[] data;
            if(!HipFS.read(imagePath, data))
            {
                loglnError("Error loading image at path ",imagePath, " required by Tileset");
                return null;
            }
            return textureImage = new Image(imagePath, data);
        }
        return textureImage;
    }

    bool loadTexture()
    {
        import hip.assets.texture;

        IImage img = loadImage();
        if(img is null)
            return false;
        texture = new HipTexture(img);
        int i = 0;
        for(int y = margin; y < textureHeight; y+= (tileHeight+spacing))
            for(int x = margin, currCol = 0 ; currCol < columns; currCol++, x+= (tileWidth+spacing))
            {
                Tile* t = &tiles[i];
                t.region = new HipTextureRegion(texture, x, y, x+tileWidth, y+tileHeight);
                i++;
            }

        return texture.hasSuccessfullyLoaded();
    }
}


class HipTilemap : HipAsset, IHipTilemap
{

    int _x, _y;
    HipColor _color = HipColor.white;
    float _scaleX = 1.0, _scaleY = 1.0;
    float _rotation = 0;

    string _path;
    uint _width, _height;
    bool _isInfinite;
    HipTileLayer[string] _layers;
    string _orientation;
    string _renderOrder;
    string _tiledVersion;
    uint _tileWidth, _tileHeight;

    this(uint width = 0, uint height = 0, uint tileWidth = 0, uint tileHeight = 0)
    {
        super("HipTilemap");
        _typeID = assetTypeID!HipTilemap;
        this._width = width;
        this._height = height;
        this._tileWidth = tileWidth;
        this._tileHeight = tileHeight;
    }

    ref int x() => _x;
    ref int y() => _y;
    ref HipColor color() => _color;
    ref float scaleX() => _scaleX;
    ref float scaleY() => _scaleY;
    float scale() => _scaleX;
    float scale(float sc) => _scaleX = _scaleY = sc;
    ref float rotation() => _rotation;

    ///Used for rendering order
    string path() const => _path;
    uint width() const => _width;
    uint height() const => _height;
    bool isInfinite() const => _isInfinite;
    ref HipTileLayer[string] layers() => _layers;
    string orientation() const => _orientation;
    string renderorder() const => _renderOrder;
    string tiled_version() const => _tiledVersion;
    uint tileHeight() const => _tileHeight;
    uint tileWidth() const => _tileWidth;

    void setTileSize(uint tileWidth, uint tileHeight)
    {
        _tileWidth = tileWidth;
        _tileHeight = tileHeight;
    }

    void addTileset(HipTileset tileset){tilesets~= cast(HipTilesetImpl)tileset;}

    protected HipTileLayer[] layersArray;
    HipTilesetImpl[] tilesets;
    this()
    {
        super("HipTilemap");
        _typeID = assetTypeID!HipTilemap;
    }

    HipTileset getTilesetForID(ushort id)
    {
        if(tilesets.length == 0)
            return null;
        for(int i = 0; i < cast(int)tilesets.length-1; i++)
        {
            if(id >= tilesets[i].firstGid && id < tilesets[i+1].firstGid)
                return tilesets[i];
        }
        return tilesets[$-1];
    }


    string getTSXPath(string tsxName)
    {
        import hip.util.path : replaceFileName;
        return replaceFileName(path, tsxName);
    }

    static HipTilemap readTiledJSON (string mapPath, ubyte[] tiledData)
    {
        import std.json;
        HipTilemap ret = new HipTilemap();
        ret._path = mapPath;
        JSONValue json = parseJSON(cast(string)(tiledData));
        ret._height     =    cast(uint)json["height"].integer;
        ret._isInfinite =              json["infinite"].boolean;
        ret._width      =    cast(uint)json["width"].integer;
        ret._orientation=              json["orientation"].str;
        ret._renderOrder=              json["renderorder"].str;
        ret._tileHeight =    cast(uint)json["tileheight"].integer;
        ret._tileWidth  =    cast(uint)json["tilewidth"].integer;

        JSONValue[] layers =      json["layers"].array;

        foreach(l; layers)
        {
            HipTileLayer layer = new HipTileLayer();

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
            ret._layers[layer.name] = layer;
        }

        JSONValue[] jtilesets = json["tilesets"].array;

        foreach(t; jtilesets)
        {
            const(JSONValue)* source = ("source" in t);
            uint firstGid = cast(ushort)t["firstgid"].integer;
            HipTilesetImpl tileset;

            if(source !is null)
            {
                import hip.util.path;
                tileset = HipTilesetImpl.read(joinPath(dirName(mapPath), source.str), firstGid);
            }
            else
                tileset = HipTilesetImpl.readJSON("null", t, firstGid);
            ret.tilesets~= tileset;
        }

        return ret;
    }
    static HipTilemap readTiledJSON (string tiledPath)
    {
        import hip.filesystem.hipfs;
        void[] jsonData;
        if(!HipFS.read(tiledPath, jsonData))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not read Tiled TMX from path ", tiledPath);
            return null;
        }
        return readTiledJSON(tiledPath, cast(ubyte[])jsonData);
    }


    void loadImages()
    {
        foreach(HipTilesetImpl tileset; tilesets)
            tileset.loadImage();
    }

    bool loadTextures()
    {
        foreach(HipTilesetImpl tileset; tilesets)
            if(!tileset.loadTexture())
                return false;
        return true;
    }
    
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return true;}
    
    
}