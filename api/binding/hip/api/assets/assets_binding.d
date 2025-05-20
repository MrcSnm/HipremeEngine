module hip.api.assets.assets_binding;
public import hip.api.data.commons;
public import hip.api.data.asset;
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
             * Loads any type previously registered.
             * Can be used for:
             * - IImage
             * - string
             * - IHipINI
             * - IHipTextureAtlas
             * - IHipTexture
             * - IHipTilemap
             * - IHipTileset
             * - IHipFont
             */
            IHipAssetLoadTask function (TypeInfo tID, string path, string file = __FILE__, size_t line = __LINE__) loadAsset;

            /**
             * Usage Example:
             * registerAsset(typeid(Image), (string path, string f, size_t l) => new HipImageLoadTask(path,path,null,f,l));
             */
            void function(TypeInfo tID, IHipAssetLoadTask delegate(string path) assetFactory) registerAsset;

            
            /**
            *   Reserved for deferred loading.
            *   Use it on your own risk.
            */
            void function (IHipAssetLoadTask task, void delegate(HipAsset) onComplete) addOnCompleteHandler;

            HipAsset function(string name) getAsset;
            string function(string name) getStringAsset;

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