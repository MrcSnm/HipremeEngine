/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.assetmanager;
import hip.util.data_structures: Node;
import hip.util.reflection;
import hip.error.handler;
import hip.console.log : hiplog;


private string buildConstantsFromFolderTree(string code, Node!string node, int depth = 0)
{
    import hip.util.path;
    import hip.util.string;
    if(node.hasChildren && node.data.extension == "")
    {
        code = "\t".repeat(depth)~"class " ~ node.data~ "\n"~"\t".repeat(depth)~"{\n";
        foreach(child; node.children)
        {
            code~= "\t".repeat(depth)~buildConstantsFromFolderTree(code, child, depth+1)~"\n";
        }
        code~="\n"~"\t".repeat(depth)~"}\n";
    }
    else if(!node.hasChildren && node.data.extension != "")
    {
        string propName = node.data[0..$-(node.data.extension.length+1)];
        return "\tpublic static enum "~propName~" = `"~node.buildPath~"`;";
    }
    return code;
}

mixin template HipAssetsGenerateEnum(string filePath)
{
    import hip.util.path;
    mixin(buildConstantsFromFolderTree("", buildFolderTree(import(filePath).split('\n'))));
}


import hip.util.system;
import hip.concurrency.thread;
import hip.concurrency.mutex;
public import hip.image;
public import hip.hiprenderer.texture;
public import hip.hipaudio.clip;
public import hip.assets.texture;
public import hip.assets.tilemap;
public import hip.font.bmfont;
public import hip.font.ttf;
public import hip.assets.csv;
public import hip.assets.jsonc;
public import hip.data.ini;
public import hip.api.data.commons;
public import hip.assets.textureatlas;
public import hip.util.data_structures;
public import hip.api.data.font;



mixin template HipDeferredLoadImpl()
{
    import hip.util.reflection;
    private void deferredLoad(T, string funcName)(IHipAssetLoadTask task)
    {
        alias func = __traits(getMember, typeof(this), funcName);
        if(task.asset !is null)
            func( cast(T)task.asset);
        else
            HipAssetManager.addOnCompleteHandler(task, (asset)
            {
                func(cast(T)asset);
            });
    }

    pragma(msg, typeof(this).stringof, hasType!"hip.assets.texture.HipTexture",  hasMethod!(typeof(this), "setTexture", IHipTexture));
    static if(hasType!"hip.assets.texture.HipTexture" && hasMethod!(typeof(this), "setTexture", IHipTexture))
    {
        final void setTexture(IHipAssetLoadTask task)
        {
            deferredLoad!(HipTexture, "setTexture")(task);
        }
    }
    static if(hasType!"hip.api.data.font.HipFont" && hasMethod!(typeof(this), "setFont", IHipFont))
    {
        final void setFont(IHipAssetLoadTask task)
        {
            deferredLoad!(HipFont, "setFont")(task);
        }
    }
}

string HipDeferredLoad()
{
    return q{
    mixin HipDeferredLoadImpl __dload__;
    static foreach(func;  __traits(allMembers, __dload__))
    {
        mixin("alias ",func," = __dload__.", func,";");
    }};
}



class HipAssetManager
{
    import hip.config.opts;

    package __gshared HipWorkerPool workerPool;
    __gshared float currentTime;

    /**
     * Due to a bug in the D Runtime, I can't use TypeInfo over the dll boundaries.
     * `is` is being used instead of opEquals
     */
    protected __gshared IHipAssetLoadTask delegate(string path, string file = __FILE__, size_t line = __LINE__)[string] typedAssetFactory;
    //Caching
    protected __gshared HipAsset[string] assets;
    protected __gshared IHipAssetLoadTask[string] loadCache;

    //Thread Communication
    protected __gshared IHipAssetLoadTask[] loadQueue;
    protected __gshared void delegate(HipAsset)[][IHipAssetLoadTask] completeHandlers;


    public static void initialize()
    {
        import hip.loaders.audio;
        import hip.loaders.fonts;
        import hip.loaders.image;
        import hip.loaders.text;
        import hip.loaders.texture_atlas;
        import hip.loaders.texture;
        import hip.loaders.tilemap;
        import hip.loaders.tileset;

        workerPool = new HipWorkerPool(HIP_ASSETMANAGER_WORKER_POOL);
        typedAssetFactory = [
            typeid(hip.api.audio.audioclip.IHipAudioClip).toString : (string path, string f, size_t l)=> new HipAudioLoadTask(path,path, null, f, l),
            typeid(IHipFont).toString : (string path, string f, size_t l)
            {
                import hip.util.path;
                hiplog("Trying to load the font ", path, "EXT: ", path.extension);
                switch(path.extension)
                {
                    case "bmfont":
                    case "fnt":
                        return new HipBMFontLoadTask(path, path, null, 48, f, l);
                    case "ttf":
                    case "otf":
                        return new HipTTFFontLoadTask(path, path, null, 48, f, l);
                    default: return null;
                }
            },
            typeid(IImage).toString :  (string path, string f, size_t l) => new HipImageLoadTask(path,path,null,f,l),
            typeid(string).toString :  (string path, string f, size_t l) => new HipFileLoadTask(path,path,null,f,l),
            typeid(IHipIniFile).toString :  (string path, string f, size_t l) => new HipINILoadTask(path,path,null,f,l),
            typeid(IHipCSV).toString :  (string path, string f, size_t l) => new HipCSVLoadTask(path,path,null,f,l),
            typeid(IHipJSONC).toString :  (string path, string f, size_t l) => new HipJSONCLoadTask(path,path,null,f,l),
            typeid(IHipTextureAtlas).toString :  (string path, string f, size_t l) => new HipTextureAtlasLoadTask(path,path,null, ":IGNORE",f,l),
            typeid(IHipTexture).toString :  (string path, string f, size_t l) => new HipTextureLoadTask(path,path,null,f,l),
            typeid(IHipTilemap).toString :  (string path, string f, size_t l) => new HipTilemapLoadTask(path,path,null,f,l),
            typeid(IHipTileset).toString :  (string path, string f, size_t l) => new HipTilesetLoadTask(path,path,null,f,l),
        ];

    }

    static bool isAsync = HipConcurrency;

    static if(HipConcurrency)
    {
        import core.sync.mutex;
    }


    @ExportD static HipAsset getAsset(string name)
    {
        if(HipAsset* asset = name in assets)
            return *asset;
        return null;
    }

    @ExportD static string getStringAsset(string name)
    {
        HipAsset asset = getAsset(name);
        if(asset !is null)
        {
            HipFileAsset fA = cast(HipFileAsset)asset;
            assert(fA !is null, "Asset fetched is not a file asset.");
            return fA.getText;
        }
        else
            return null;
    }

    static pragma(inline, true) T get(T)(string name) {return cast(T)getAsset(name);}
    static pragma(inline, true) T get(T : string)(string name) {return getStringAsset(name);}

    ///Returns whether asset manager is loading anything
    @ExportD static bool isLoading(string file = __FILE__, uint line = __LINE__)
    {
        return loadQueue.length != 0;
    }
    ///Returns whether asset manager is loading anything
    @ExportD static int getAssetsToLoadCount(){return cast(int)loadQueue.length;}

    ///Stops the code from running and awaits asset manager to finish loading
    @ExportD static void awaitLoad()
    {
        workerPool.await;
        update();
    }

    static void awaitTask(IHipAssetLoadTask task)
    {
        static if(HipConcurrency)
        {
            import hip.asset_manager.load_task;
            import core.sync.semaphore;
            HipAssetLoadTask lTask = cast(HipAssetLoadTask)task;
            auto semaphore = new Semaphore(0);
            lTask.worker.pushTask("Await Single", ()
            {
                semaphore.notify;
            });
            semaphore.wait;
            destroy(semaphore);
            update();
        }
    }

    package static HipWorkerThread loadWorker(string taskName, void delegate() loadFn, void delegate(string taskName) onFinish = null, bool onMainThread = false)
    {
        //TODO: Make it don't use at all worker and threads.
        //? Maybe it is not actually needed, as it can be handled by version(HipConcurrency)
        return workerPool.pushTask(taskName, loadFn, onFinish, onMainThread);
    }

    @ExportD static IHipTextureRegion createTextureRegion(IHipTexture texture, float u1 = 0.0, float v1 = 0.0, float u2 = 1.0, float v2 = 1.0)
    {
        return new HipTextureRegion(texture, u1, v1, u2, v2);
    }
    @ExportD static void registerAsset(TypeInfo tID, IHipAssetLoadTask delegate(string path,string file, size_t line) assetFactory)
    {
        if(tID.toString in typedAssetFactory)
        {
            ErrorHandler.showErrorMessage("Asset already registered:", tID.toString);
            throw new Exception("Attempt to register twice the same type.");
        }
        typedAssetFactory[tID.toString] = assetFactory;
    }

    @ExportD static IHipAssetLoadTask loadAsset(TypeInfo tID, string path, string file = __FILE__, size_t line = __LINE__)
    {
        auto assetFactory = tID.toString in typedAssetFactory;
        if(!assetFactory)
        {
            import hip.util.string;
            String s = String();

            foreach(type, factory; typedAssetFactory)
                s~= "\n\t- "~type.toString;

            ErrorHandler.showErrorMessage("Asset type was not registered in AssetManager:", tID.toString);
            ErrorHandler.showErrorMessage("Registered Types: ", s.toString);

            throw new Exception("Please register the type first.");
        }



        return (*assetFactory)(path, file, line);
    }

    @ExportD static IHipTilemap createTilemap(uint width, uint height, uint tileWidth, uint tileHeight)
    {
        return new HipTilemap(width, height, tileWidth, tileHeight);
    }
    @ExportD static IHipTileset tilesetFromAtlas(IHipTextureAtlas atlas){return HipTilesetImpl.fromAtlas(cast(HipTextureAtlas)atlas);}
    @ExportD static IHipTileset tilesetFromSpritesheet(Array2D_GC!IHipTextureRegion sp){return HipTilesetImpl.fromSpritesheet(sp);}

    static void addOnCompleteHandler(IHipAssetLoadTask task, void delegate(HipAsset) onComplete)
    {
        import hip.asset_manager.load_task;
        if(task.asset !is null)
            onComplete(task.asset);
        else
        {
            hiplog("Added a complete handler for ", (cast(HipAssetLoadTask)task).name);
            completeHandlers[cast(HipAssetLoadTask)task]~= onComplete;
        }
    }

    static void addOnLoadingFinish(void delegate() onFinish)
    {
        workerPool.addOnAllTasksFinished(onFinish);
    }

    /**
    *   This function is responsible for calling worker's onTaskFinish on the main thread if it has one.
    *   After that, it will execute any deferred task to the AssetManager, such as setting a HipSprite or HipFont asset.
    */
    static void update()
    {
        import hip.util.array:remove;
        import hip.asset_manager.load_task;
        workerPool.startWorking();
        for(int i = 0; i < loadQueue.length; i++)
        {
            IHipAssetLoadTask task = loadQueue[i];
            HipAssetLoadTask lTask = cast(HipAssetLoadTask)task;
            task.update();

            final switch(task.result) with(HipAssetResult)
            {
                case loading, waiting, mainThreadLoading: break;
                case cantLoad:
                    ErrorHandler.showWarningMessage("Could not load task: "~lTask.name, " Error: "~ lTask.error);
                    loadQueue.remove(task);
                    break;
                case loaded:
                    if(auto handlers = task in completeHandlers)
                    {
                        //Subject to a logger
                        hiplog(lTask.name, " executing handlers");
                        foreach(handler; *handlers)
                        {
                            handler(lTask._asset);
                        }
                        handlers.length = 0;
                        completeHandlers.remove(task);
                        loadQueue.remove(task);
                    }
                    break;
            }
        }

        workerPool.pollFinished();
    }

    /**
    *   Cleans everything up. Puts AssetManager in an invalid state
    */
    static void dispose()
    {
        import hip.error.handler;
        workerPool.dispose();
        foreach(HipAsset asset; assets.byValue)
            asset.dispose();
        destroy(assets);
        destroy(loadQueue);
        destroy(workerPool);
    }
}