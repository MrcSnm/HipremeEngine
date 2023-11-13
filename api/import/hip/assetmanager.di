module hip.assetmanager;
public import hip.api.data.commons;
public import hip.api.data.font;
public import hip.api.data.textureatlas;
public import hip.api.data.tilemap;
public import hip.api.renderer.texture;


extern class HipAssetManager
{
    extern(System) __gshared static
    {
        ///Returns whether asset manager is loading anything
        bool isLoading ();
        ///Stops the code from running and awaits asset manager to finish loading
        void awaitLoad ();

        /** 
        * Used for manually creating texture regions. This is used by the game code abstraction.
        */
        IHipTextureRegion createTextureRegion (IHipTexture texture, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1);
        
        /** 
        * Used for creating procedurally generated Tilemap:
        ```d
        IHipTilemap map = HipAssetManager.createTilemap(200, 200, 1, 1);
        map.addTileset(HipAssetManager.tilesetFromSpritesheet(mySpritesheet));
        HipTileLayer layer = map.addNewLayer("MyLayer", 200, 200);
        //Define your tiles by accessing layer.tiles = []
        ```
        */
        IHipTilemap createTilemap (uint width, uint height, uint tileWidth, uint tileHeight, bool isInfinite = false);

        
        /**
        *   Reserved for deferred loading.
        *   Use it on your own risk.
        */
        void addOnCompleteHandler  (IHipAssetLoadTask task, void delegate(IHipAsset) onComplete);

        IHipAsset getAsset (string name);
        string getStringAsset (string name);

        ///File reading wrapped in asset manager.
        IHipAssetLoadTask loadFile (string path, string f = __FILE__, size_t l = __LINE__);

        ///Loads an in memory audio clip
        IHipAssetLoadTask loadAudio (string path, string f = __FILE__, size_t l = __LINE__);

        ///Returns a load task for texture
        IHipAssetLoadTask loadTexture (string path, string f = __FILE__, size_t l = __LINE__);
        ///Returns a load task for image
        IHipAssetLoadTask loadImage (string path, string f = __FILE__, size_t l = __LINE__);
        ///Returns a load task for tilemap
        IHipAssetLoadTask loadTilemap (string path, string f = __FILE__, size_t l = __LINE__);

        /**
        * `   This  is used in conjunction usually with `createTilema.
        *   `loadTileset` is a way of loading an externally defined tileset for your procedural map.
        *   Use `loadTilemap` when you have a complete map which you wish to load.
        */
        IHipAssetLoadTask loadTileset (string path, string f = __FILE__, size_t l = __LINE__);


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
        IHipAssetLoadTask loadCSV (string path, string f = __FILE__, size_t l = __LINE__);
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
        IHipAssetLoadTask loadINI (string path, string f = __FILE__, size_t l = __LINE__);
        /**
        *   Usage:
        ```d
        //Must import hip.data.json for actually using it.
        import hip.data.json;
        JSONValue json = hipJSON.getJSON!JSONValue;
        json["myProperty"].str//or other types
        ```
        * Returns: IHipJSONC
        */
        IHipAssetLoadTask loadJSONC (string path, string f = __FILE__, size_t l = __LINE__);
        /** 
        *   Returns a load task for a texture atlas
        *   If ":IGNORE" is provided for texturePath, the following behavior will occur:
        *   - .json: Will try to load a file with same name but with extension .png
        *   - .atlas: texturePath is always ignored
        *   - .txt(or any): Load a file with same name but extension .png
        *   - .xml: Ignore internal texture path to try file with same name but .png extension
        */
        IHipAssetLoadTask loadTextureAtlas (string atlasPath, string texturePath = ":IGNORE", string f = __FILE__, size_t l = __LINE__);
        // /Returns a load task for font, when used, 
        IHipAssetLoadTask loadFont (string path, int fontSize = 48, string f = __FILE__, size_t l = __LINE__);
        version(Have_util)
        {
            public import hip.util.data_structures:Array2D, Array2D_GC;
            IHipTileset tilesetFromSpritesheet (Array2D_GC!IHipTextureRegion spritesheet);
        }   
        IHipTileset tilesetFromAtlas (IHipTextureAtlas atlas);
    }
}