module hip.assets.tilemap;
public import hip.api.data.tilemap;
public import hip.api.data.asset;
import hip.assets.texture;
import hip.config.opts;
import hip.image;
import hip.data.json;

class HipTileset : HipAsset, IHipTileset
{
    uint _columns; uint columns() const =>_columns;

    ///Means where the tileset id starts
    uint _firstGid; uint firstGid() const => _firstGid;
    

    ///"image" in tiled

    string _texturePath; string texturePath() const => _texturePath;
    ///"imageheight" in tiled
    uint  _textureHeight; uint  textureHeight() const => _textureHeight;
    ///"imagewidth" in tiled 
    uint  _textureWidth; uint  textureWidth() const => _textureWidth;
    IHipTexture _texture; IHipTexture texture()     => _texture;
    int _margin; int margin() const => _margin;

    override string name() const => super.name;

    ///Only available when loaded via .tsx
    string _path; string path() const => _path;
    int _spacing; int spacing() const => _spacing;
    uint _tileHeight; uint tileHeight() const => _tileHeight;
    uint _tileWidth; uint tileWidth() const => _tileWidth;
    Tile[] _tiles; Tile[] tiles() => _tiles;

    void setTexture(IHipTexture texture)
    {
        this._texture = texture;
        this._textureWidth = texture.getWidth;
        this._textureHeight = texture.getHeight;
    }

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

    static HipTileset read (string path, void delegate(HipTileset self) onSuccess, void delegate() onError, uint firstGid = 1)
    {
        import hip.util.path;
        switch(path.extension)
        {
            case "xml":
            case "tmx":
                throw new Exception("TMX/TSX parser was removed for making the engine smaller.");
            case "tsj":
            case "json":
                return HipTileset.readJSON(path, firstGid, onSuccess, onError);
            default:
                assert(false, "Unrecognized extension for file "~path);
        }
    }

    static HipTileset readFromMemory (string path, string data, void delegate(HipTileset) onSuccess, void delegate() onError, uint firstGid = 1)
    {
        import hip.util.path;
        switch(path.extension)
        {
            case "xml":
            case "tmx":
                throw new Exception("TMX/TSX parser was removed for making the engine smaller.");
            case "tsj":
            case "json":
                HipTileset ret = new HipTileset(0);
                ret._path = path;
                ret._firstGid = firstGid;
                ret.loadJSON(parseJSON(data), onSuccess, onError);
                return ret;
            default:
                assert(false, "Unrecognized extension for file "~path);
        }
    }

    static HipTileset readJSON (string path, uint firstGid, void delegate(HipTileset self) onSuccess, void delegate() onError)
    {
        import hip.api.filesystem.hipfs;
        import hip.console.log;
        HipTileset tileset = new HipTileset(0);
        tileset._path = path;
        tileset._firstGid = firstGid;

        HipFS.readText(path).addOnSuccess((in void[] data)
        {
            tileset.loadJSON(parseJSON(cast(string)data), onSuccess, onError);
            return FileReadResult.free;
        }).addOnError((err)
        {
            loglnWarn("Could not read file at path ", path," ", err);
        });
        return tileset;
    }

    public static HipTileset readJSON (string path, uint firstGid, const JSONValue t, void delegate(HipTileset self) onSuccess, void delegate() onError)
    {
        HipTileset ret = new HipTileset(0);
        ret._path = path;
        ret._firstGid = firstGid;
        ret.loadJSON(t, onSuccess, onError);
        return ret;
    }

    private void loadJSON (const JSONValue t, void delegate(HipTileset self) onSuccess, void delegate() onError)
    {
        import hip.util.path;
        if(t.hasErrorOccurred)
        {
            import hip.error.handler;
            ErrorHandler.showErrorMessage("JSON Parsing Error on Tilemap", t.toString);
            return onError();
        }

        _tiles = new Tile[cast(uint)t["tilecount"].integer];
        _texturePath   =             t["image"].str;
        if(!isAbsolutePath(_texturePath) && _path.length)
            _texturePath = joinPath(dirName(_path), _texturePath).normalizePath;
        _textureHeight =   cast(uint)t["imageheight"].integer;
        _textureWidth  =   cast(uint)t["imagewidth"].integer;
        _columns       = cast(ushort)t["columns"].integer;
        _margin        =    cast(int)t["margin"].integer;
        _name          =             t["name"].str;
        _spacing       =    cast(int)t["spacing"].integer;
        _tileHeight    =   cast(uint)t["tileheight"].integer;
        _tileWidth     =   cast(uint)t["tilewidth"].integer;

        if("tiles" in t)
        {
            foreach (currentTile; t["tiles"].array)
            {
                Tile tile;
                tile.id = cast(ushort)currentTile["id"].integer;
                
                foreach(prop; currentTile["properties"].array)
                {
                    tile.properties[prop["name"].str] = propFromJSON(prop);
                }
                tiles[tile.id] = tile;
            }
        }
        onSuccess(this);
    }


    import hip.util.data_structures;
    static IHipTileset fromSpritesheet(Array2D_GC!IHipTextureRegion regions)
    {
        import hip.error.handler;
        import hip.assets.texture;
        ErrorHandler.assertExit(regions.getWidth > 0 && regions.getHeight > 0, "Invalid spritesheet");
        HipTileset t = new HipTileset(regions.getWidth * regions.getHeight);
        t._name = "Created from Spritesheet";
        t._firstGid = 1;
        t.setTexture(regions[0,0].getTexture);
        t._tileWidth = regions[0,0].getWidth();
        t._tileHeight = regions[0,0].getHeight();
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
    static IHipTileset fromAtlas(HipTextureAtlas atlas)
    {
        HipTileset t = new HipTileset(cast(uint)atlas.frames.length);
        t._firstGid = 1;
        t._name = "Tileset from Atlas: "~atlas.name;
        t.setTexture(atlas.texture);
        int i = 0;
        foreach(atlasFrame; atlas)
        {
            Tile* tile = &t.tiles[i++];
            if(!t.tileWidth)
            {
                t._tileWidth = atlasFrame.region.getWidth;
                t._tileHeight = atlasFrame.region.getHeight;
            }
            //TODO: May use clone one day if direct assign doesn't fit.
            tile.region = atlasFrame.region;
            tile.id = cast(ushort)i;
        }
        return t;
    }

    this(uint tileCount)
    {
        super("HipTileset");
        _tiles = new Tile[tileCount];
        _typeID = assetTypeID!HipTileset;
    }
    IImage textureImage;

    IImage loadImage(void delegate(IImage self) onSuccess, void delegate() onFailure)
    {
        import hip.error.handler;
        import hip.api.filesystem.hipfs;
        import hip.util.path;
        if(textureImage is null)
        {
            ErrorHandler.assertExit(texturePath != "", "No texture path for loading tilemap texture");
            HipFS.read(texturePath)
            .addOnError((string err)
            {
                ErrorHandler.showErrorMessage("Error loading image required by Tileset: "~texturePath, err);
                onFailure();
            })
            .addOnSuccess((in ubyte[] imgData)
            {
                textureImage = new Image(texturePath, cast(ubyte[])imgData, onSuccess, onFailure);
                return FileReadResult.free;
            });
        }
        return textureImage;
    }

    bool loadTexture()
    {
        import hip.error.handler;
        import hip.assets.texture;
        if(textureImage is null)
        {
            loadImage((_){loadTexture();}, (){});
            return false;
        }
        _texture = new HipTexture(textureImage);
        int i = 0;
        for(int y = margin; y < textureHeight; y+= (tileHeight+spacing))
            for(int x = margin, currCol = 0 ; currCol < columns; currCol++, x+= (tileWidth+spacing))
            {
                Tile* t = &tiles[i];
                t.region = new HipTextureRegion(texture, x, y, x+tileWidth, y+tileHeight);
                i++;
            }

        return texture !is null && texture.hasSuccessfullyLoaded();
    }
    
    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return _texture !is null;}
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

    void addTileset(IHipTileset tileset){tilesets~= cast(HipTileset)tileset;}

    protected HipTileLayer[] layersArray;
    HipTileset[] tilesets;
    this()
    {
        super("HipTilemap");
        _typeID = assetTypeID!HipTilemap;
    }

    IHipTileset getTilesetForID(ushort id)
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

    static HipTilemap readTiledJSON (string mapPath, const ubyte[] tiledData, void delegate(HipTilemap) onSuccess, void delegate() onError)
    {
        import hip.data.json;
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

        foreach(l; json["layers"].array)
        {
            HipTileLayer layer = new HipTileLayer(ret);

            //Check first the layer type.
            layer.name    =             l["name"].str;
            layer.type    =             l["type"].str;
            layer.id      = cast(ushort)l["id"].integer;
            layer.opacity =             l["opacity"].integer;
            layer.visible =             l["visible"].boolean;
            layer.x       = cast(int)   l["x"].integer;
            layer.y       = cast(int)   l["y"].integer;
            if(layer.type == TileLayerType.OBJECT_LAYER)
            {
                import hip.util.array:uninitializedArray;
                int objIndex = 0;
                layer.objects = uninitializedArray!(TiledObject[])(l["objects"].array.length);
                foreach(JSONValue o; l["objects"].array)
                {
                    TiledObject obj;

                    obj.id      = cast(ushort)o["id"].integer;
                    obj.name    =             o["name"].str;
                    obj.type    =             o["type"].str;
                    obj.visible =             o["visible"].boolean;


                    obj.data.rect.x       = cast(int)   o["x"].floating;
                    obj.data.rect.rotation= cast(ushort)(o["rotation"].integer % 360);
                    obj.data.rect.y       = cast(int)   o["y"].floating;
                    obj.data.rect.height  = cast(uint)  o["height"].floating;
                    obj.data.rect.width   = cast(uint)  o["width"].floating;


                    if("text" in o)
                    {
                        import hip.util.data_structures:staticArray;
                        obj.dataType = TiledObjectTypes.text;
                        JSONValue txtObj = o["text"];
                        obj.properties["__text"] = TileProperty(null, Variant.make(tryGetValue!string(txtObj, "text")));
                        obj.properties["__fontfamily"] = TileProperty(null, Variant.make(tryGetValue!string(txtObj, "fontfamily")));
                        obj.properties["__wrap"] = TileProperty(null,  Variant.make(tryGetValue!bool(txtObj, "wrap")));
                    }
                    else if("polyline" in o)
                    {
                        JSONValue[] line = o["polyline"].array;
                        int x = obj.data.rect.x;
                        int y = obj.data.rect.y;
                        obj.dataType = TiledObjectTypes.line;
                        obj.data.rect.getLine() = [
                            tryGetValue(line[0], "x", 0) + x,
                            tryGetValue(line[0], "y", 0) + y,

                            tryGetValue(line[1], "x", 0) + x,
                            tryGetValue(line[1], "y", 0) + y,
                        ];
                    }
                    else if("polygon" in o)
                    {
                        JSONValue[] poly = o["polygon"].array;
                        obj.dataType = poly.length == 3 ? TiledObjectTypes.triangle : TiledObjectTypes.polygon;

                        if(poly.length == 3)
                        {
                            obj.data.triangle = [
                                tryGetValue(poly[0], "x", 0),
                                tryGetValue(poly[0], "y", 0),

                                tryGetValue(poly[1], "x", 0),
                                tryGetValue(poly[1], "y", 0),

                                tryGetValue(poly[2], "x", 0),
                                tryGetValue(poly[2], "y", 0),
                            ];
                        }
                        else
                        {
                            obj.data.polygon = new int[2][poly.length];
                            foreach(i, v; poly)
                                obj.data.polygon[i] = [
                                    tryGetValue(poly[i], "x", 0),
                                    tryGetValue(poly[i], "y", 0)
                                ];
                        }
                    }
                    else if("gid" in o)
                    {
                        obj.dataType = TiledObjectTypes.tile;
                        obj.tile.gid = cast(ushort)o["gid"].integer;
                    }
                    else if("ellipse" in o)
                        obj.dataType = TiledObjectTypes.ellipse;
                    else if("point" in o)
                        obj.dataType = TiledObjectTypes.point;
                    else
                        obj.dataType = TiledObjectTypes.rect;

                    const(JSONValue)* v = ("properties" in o);
                    if(v != null)
                    {
                        foreach(p; v.array) //Properties
                            obj.properties[p["name"].str] = propFromJSON(p);
                    }
                    layer.objects[objIndex++] = obj;
                }

            }
            else if(layer.type == TileLayerType.TILE_LAYER)
            {
                auto layerData = l["data"].array;
                layer.height  = cast(uint)  l["height"].integer;
                layer.width   = cast(uint)  l["width"].integer;
                layer.tiles.reserve(layerData.length);
                foreach(d; layerData)
                    layer.tiles~= cast(ushort)d.integer;
            }

            const(JSONValue)* layerProp = ("properties" in l);
            if(layerProp != null)
            {
                foreach(p; layerProp.array)
                    layer.properties[p["name"].str] = propFromJSON(p);
            }
            ret.layersArray~=layer;
            ret._layers[layer.name] = layer;
        }

        size_t maxTilesets = json["tilesets"].array.length;
        auto onTilesetLoad = delegate(HipTileset tileset)
        {
            ret.tilesets~= tileset;
            if(ret.tilesets.length == maxTilesets)
                onSuccess(ret);
        };
        foreach(t; json["tilesets"].array)
        {
            import hip.util.path;
            const(JSONValue)* source = ("source" in t);
            uint firstGid = cast(ushort)t["firstgid"].integer;

            ///Returns are being ignored since it is being handled on the onTilesetLoad
            if(source !is null)
            {
                import hip.console.log;
                loglnWarn("Reading from source: ", joinPath(dirName(mapPath), source.str).normalizePath);
                HipTileset.read(joinPath(dirName(mapPath), source.str).normalizePath, onTilesetLoad, onError, firstGid);
            }
            else
                HipTileset.readJSON(dirName(mapPath), firstGid, t, onTilesetLoad, onError);
        }



        return ret;
    }
    static void readTiledJSON (string tiledPath, void delegate(HipTilemap) onSuccess, void delegate() onError)
    {
        import hip.api.filesystem.hipfs;
        HipFS.read(tiledPath).addOnSuccess((in ubyte[] data)
        {
            HipTilemap.readTiledJSON(tiledPath, cast(ubyte[])data, onSuccess, onError);
            return FileReadResult.free;
        }).addOnError((err)
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not read Tiled TMX from path ", tiledPath);
            onError();
        });
    }


    ///Those arguments are actually synchronous on all platforms. This is to simulate JS API.
    void loadImages(void delegate() onSuccess, void delegate() onFailure)
    {
        int counter = 0;
        auto onSuccessInternal = delegate(IImage _)
        {
            if(++counter == tilesets.length)
                onSuccess();
        };
        foreach(HipTileset tileset; tilesets)
            tileset.loadImage(onSuccessInternal, onFailure);
    }

    bool loadTextures()
    {
        foreach(HipTileset tileset; tilesets)
            if(!tileset.loadTexture())
                return false;
        return true;
    }
    
    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return true;}
    
    
}

private TileProperty propFromJSON(JSONValue v)
{
    import hip.util.exception;
    JSONValue* t = "type" in v;
    TileProperty ret = void;
    enforce(t !is null, "propFromJSON must have a 'type'");
    ret.type = t.str;
    switch(ret.type)
    {
        case "object", "int":
            ret.val = Variant.make(v["value"].integer);
            break;
        case "bool":
            ret.val = Variant.make(v["value"].boolean);
            break;
        case "float":
            ret.val = Variant.make(v["value"].floating);
            break;
        case "color", "string", "file":
            ret.val = Variant.make(v["value"].str);
            break;
        default:
            throw new Exception("Unknown property for TiledProperty of type "~ret.type);
    }
    return ret;
}