module hip.api.assets.assets_binding;
public import hip.api.data.commons;
public import hip.api.data.font;
public import hip.api.data.textureatlas;
public import hip.api.data.tilemap;
public import hip.api.renderer.texture;

private alias thisModule = __traits(parent, {});

version(Script) void initAssetManager()
{
    import hip.api.internal;
    loadModuleFunctionPointers!(thisModule, "HipAssetManager");
    import hip.api.console;
    log("HipengineAPI: Initialized AssetManager");
}

version(Script) extern(System)
{
    ///Returns whether asset manager is loading anything
    bool function() isLoading;
    ///Stops the code from running and awaits asset manager to finish loading
    void function() awaitLoad;
    ///Returns a load task for texture
    IHipAssetLoadTask function(string path) loadTexture;
    ///Returns a load task for image
    IHipAssetLoadTask function(string path) loadImage;
    ///Returns a load task for tilemap
    IHipAssetLoadTask function(string path) loadTilemap;

    /**
    *   This function is used in conjunction usually with `createTilemap`.
    *   Use `loadTilemap` when you have a complete map which you wish to load.
    *   loadTileset is a way of loading an externally defined tileset for your procedural map.
    */
    IHipAssetLoadTask function(string path) loadTileset;


    /**
    *   Usage:
    ```d
    //Iterate every value
    foreach(v; csv) //or
    //Iterate columns
    foreach(v; csv.getColumnRange(0)) //or
    //Iterate rows
    foreach(v; csv.getRow(0))
    //Get the csv cell
    csv[x, y]
    ```
    * Returns: IHipCSV
    */
    IHipAssetLoadTask function(string path) loadCSV;
    /**
    *   Usage:
    ```d
    //If not found, use 2 as default
    ini.tryGet!ubyte("buffering.count", 2);
    //Alternative usage
    ini.buffering.count.get!ubyte 
    ```
    * Returns: IHipINI
    */
    IHipAssetLoadTask function(string path) loadINI;
    /**
    *   Usage:
    ```d
    //Must import std.json for actually using it.
    import std.json;
    JSONValue json = hipJSON.getJSON!JSONValue;
    json["myProperty"].str//or other types
    ```
    * Returns: IHipJSONC
    */
    IHipAssetLoadTask function(string path) loadJSONC;

    version(Have_util)
    {
        public import hip.util.data_structures:Array2D, Array2D_GC;
        HipTileset function(Array2D_GC!IHipTextureRegion spritesheet) tilesetFromSpritesheet;
    }   
    HipTileset function(IHipTextureAtlas atlas) tilesetFromAtlas;

    /** 
     * Used for creating procedurally generated Tilemap:
     ```d
     IHipTilemap map = HipAssetManager.createTilemap(200, 200, 1, 1);
     map.addTileset(HipAssetManager.tilesetFromSpritesheet(mySpritesheet));
     HipTileLayer layer = map.addNewLayer("MyLayer", 200, 200);
     //Define your tiles by accessing layer.tiles = []
     ```
     */
    IHipTilemap function(uint width, uint height, uint tileWidth, uint tileHeight, bool isInfinite = false) createTilemap;
    //TODO: IHipAssetLoadTask function(string path) loadHapFile;


    /** 
    *   Returns a load task for a texture atlas
    *   If ":IGNORE" is provided for texturePath, the following behavior will occur:
    *   - .json: Will try to load a file with same name but with extension .png
    *   - .atlas: texturePath is always ignored
    *   - .txt(or any): Load a file with same name but extension .png
    *   - .xml: Ignore internal texture path to try file with same name but .png extension
    */
    IHipAssetLoadTask function(string atlasPath, string texturePath = ":IGNORE") loadTextureAtlas;
    // /Returns a load task for font, when used, 
    IHipAssetLoadTask function(string path, int fontSize = 48) loadFont;
}