module hip.api.assets.assets_binding;
public import hip.api.data.commons;
public import hip.api.data.font;
public import hip.api.data.textureatlas;
public import hip.api.data.tilemap;
public import hip.api.renderer.texture;

version(ScriptAPI)
{
    void initAssetManager()
    {
        import hip.api.internal;
        loadClassFunctionPointers!(HipAssetsBinding, UseExportedClass.Yes, "HipAssetManager");
        import hip.api.console;
        log("HipengineAPI: Initialized AssetManager");
    }


    class HipAssetsBinding
    {
        extern(System) __gshared
        {
            ///Returns whether asset manager is loading anything
            bool function(string file = __FILE__, uint line = __LINE__) isLoading;

            ///Stops the code from running and awaits asset manager to finish loading
            void function() awaitLoad;

            ///Gets how many assets there is to load.
            int function() getAssetsToLoadCount;


            
            /** 
            * Used for manually creating texture regions. This is used by the game code abstraction.
            */
            IHipTextureRegion function(IHipTexture texture, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1) createTextureRegion;
            
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

            
            /**
            *   Reserved for deferred loading.
            *   Use it on your own risk.
            */
            void function (IHipAssetLoadTask task, void delegate(IHipAsset) onComplete) addOnCompleteHandler;

            IHipAsset function(string name) getAsset;
            string function(string name) getStringAsset;

            ///File reading wrapped in asset manager.
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadFile;

            ///Loads an in memory audio clip
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadAudio;

            ///Returns a load task for texture
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadTexture;
            ///Returns a load task for image
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadImage;
            ///Returns a load task for tilemap
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadTilemap;

            /**
            *   This function is used in conjunction usually with `createTilemap`.
            *   `loadTileset` is a way of loading an externally defined tileset for your procedural map.
            *   Use `loadTilemap` when you have a complete map which you wish to load.
            */
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadTileset;


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
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadCSV;
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
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadINI;
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
            IHipAssetLoadTask function(string path, string f = __FILE__, size_t l = __LINE__) loadJSONC;

            
            /** 
            *   Returns a load task for a texture atlas
            *   If ":IGNORE" is provided for texturePath, the following behavior will occur:
            *   - .json: Will try to load a file with same name but with extension .png
            *   - .atlas: texturePath is always ignored
            *   - .txt(or any): Load a file with same name but extension .png
            *   - .xml: Ignore internal texture path to try file with same name but .png extension
            */
            IHipAssetLoadTask function(string atlasPath, string texturePath = ":IGNORE", string f = __FILE__, size_t l = __LINE__) loadTextureAtlas;
            // /Returns a load task for font, when used, 
            IHipAssetLoadTask function(string path, int fontSize = 48, string f = __FILE__, size_t l = __LINE__) loadFont;

            version(Have_util)
            {
                public import hip.util.data_structures:Array2D, Array2D_GC;
                IHipTileset function(Array2D_GC!IHipTextureRegion spritesheet) tilesetFromSpritesheet;
            }   
            IHipTileset function(IHipTextureAtlas atlas) tilesetFromAtlas;

            //TODO: IHipAssetLoadTask function(string path) loadHapFile;
        }
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipAssetsBinding;
}




T get(T)(string name){return cast(T)getAsset(name); }
T get(T : string)(string name){return cast(T)getStringAsset(name);}