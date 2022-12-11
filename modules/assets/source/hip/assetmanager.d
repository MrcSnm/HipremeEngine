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
import hip.util.concurrency;
import hip.util.data_structures: Node;
import hip.util.reflection;

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


version(HipAssets):

import hip.util.system;
import hip.asset;
import hip.util.concurrency;
public import hip.asset;
public import hip.assets.image;
public import hip.assets.texture;
public import hip.assets.tilemap;
public import hip.assets.font;
public import hip.assets.csv;
public import hip.assets.jsonc;
public import hip.assets.ini;
public import hip.api.data.commons;
public import hip.assets.textureatlas;
public import hip.util.data_structures;



class HipAssetLoadTask : IHipAssetLoadTask
{
    string name;
    HipAssetResult _result = HipAssetResult.cantLoad;
    HipAsset _asset = null;
    protected HipWorkerThread worker;
    protected void[] partialData;

    this(string name, HipAsset asset)
    {
        this.name = name;
        this._asset = _asset; 
        if(asset is null)
            _result = HipAssetResult.cantLoad;
        else
            _result = HipAssetResult.loaded;
    }

    bool hasFinishedLoading() const{return result == HipAssetResult.loaded;}
    bool opCast(T : bool)() const{return hasFinishedLoading;}
    
    void await(){HipAssetManager.awaitTask(this);}

    void givePartialData(void[] data)
    {
        if(partialData !is null)
            throw new Error("AssetLoadTask already has partial data");
        partialData = data;
    }

    void[] takePartialData()
    {
        if(partialData is null)
            throw new Error("No partial data was set before taking it");
        void[] ret = partialData;
        partialData = null;
        return ret;
    }
    
    HipAssetResult result() const {return _result;}
    IHipAsset asset(){return _asset;}
    HipAssetResult result(HipAssetResult newResult){return _result = newResult;}
    IHipAsset asset(IHipAsset newAsset){return _asset = cast(HipAsset)newAsset;}

}



import hip.api.data.font;
mixin template HipDeferredLoadImpl()
{
    import hip.util.reflection;
    
    private void deferredLoad(T, string funcName)(IHipAssetLoadTask task)
    {
        alias func = __traits(getMember, typeof(this), funcName);
        if(task.asset !is null)
            func( cast(T)task.asset);
        else
            HipAssetManager.addOnCompleteHandler(
            (asset)
            {
                func(cast(T)asset);
            }, task);
    }

    pragma(msg, typeof(this).stringof, hasType!"hip.assets.texture.HipTexture",  hasMethod!(typeof(this), "setTexture", IHipTexture));
    static if(hasType!"hip.assets.texture.HipTexture" && hasMethod!(typeof(this), "setTexture", IHipTexture))
    {
        final void setTexture(IHipAssetLoadTask task)
        {
            deferredLoad!(HipTexture, "setTexture")(task);
        }
    }
    static if(hasType!"hip.api.data.font.IHipFont" && hasMethod!(typeof(this), "setFont", IHipFont))
    {
        final void setFont(IHipAssetLoadTask task)
        {
            deferredLoad!(HipFontAsset, "setFont")(task);
        }
    }
}

enum HipDeferredLoad()
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

    protected __gshared HipWorkerPool workerPool;
    __gshared float currentTime;
    //Caching
    protected __gshared HipAsset[string] assets;
    protected __gshared HipAssetLoadTask[string] loadQueue;

    //Thread Communication
    protected __gshared HipAssetLoadTask[] completeQueue;
    protected __gshared DebugMutex completeMutex;
    protected __gshared void delegate(HipAsset)[][HipAssetLoadTask] completeHandlers;
    

    //Auto Loading
    protected __gshared HipAsset[string] referencedAssets;
    protected __gshared bool isCheckingReferenced = false;


    public static void initialize()
    {
        completeMutex = new DebugMutex();
        workerPool = new HipWorkerPool(HIP_ASSETMANAGER_WORKER_POOL);
    }

    version(HipConcurrency)
    {
        import core.sync.mutex;
        static bool isAsync = true;
    }
    else
    {
        static bool isAsync = false;
    }

    static void startCheckingReferences(){isCheckingReferenced = true;}
    static void stopCheckingReferences()
    {
        isCheckingReferenced = false;
        foreach(key, value; referencedAssets)
        {
            if(value.typeID == assetTypeID!Image)
            {

            }
            else if(value.typeID == assetTypeID!HipTexture)
            {

            }
        }
        referencedAssets.clear();
    }

    static HipAsset getAsset(string name)
    {
        if(HipAsset* asset = name in assets)
            return *asset;
        else if(isCheckingReferenced && (name in referencedAssets) is null)
        {
            // load()
        }
        return null;
    }
    static pragma(inline, true) T getAsset(T : HipAsset)(string name) {return cast(T)getAsset(name);}

    static HipAssetLoadTask tryLoadAsset(T: HipAsset)(string name)
    {
        
    }

    @ExportD static bool isLoading(){return !workerPool.isIdle;}
    @ExportD static void awaitLoad()
    {
        workerPool.await;
        update();
    }

    static void awaitTask(HipAssetLoadTask task)
    {
        version(HipConcurrency)
        {
            import core.sync.semaphore;
            auto semaphore = new Semaphore(0);
            task.worker.pushTask("Await Single", ()
            {
                semaphore.notify;
            });
            semaphore.wait;
            destroy(semaphore);
            update();
        }
    }

    private static HipWorkerThread loadWorker(string taskName, void delegate() loadFn, void delegate(string taskName) onFinish = null, bool onMainThread = false)
    {
        //TODO: Make it don't use at all worker and threads.
        return workerPool.pushTask(taskName, loadFn, onFinish, onMainThread);
        // if(isAsync)
        //     return workerPool.pushTask(taskName, loadFn, onFinish, onMainThread);
        // else
        // {
        //     loadFn();
        //     if(onFinish !is null)
        //         onFinish(taskName);
        // }
        // return null;
    }

    /** 
     * Checks whether the file has been loaded already or not:
     *  if: returns its previous task
     *  else: Put a new one on load cache and retunr
     */
    private static HipAssetLoadTask loadBase(string path, HipWorkerThread worker)
    {
        HipAsset asset = getAsset(path);
        if(asset !is null){return new HipAssetLoadTask(path, asset);}
        else if(HipAssetLoadTask* task = path in loadQueue){return *task;}

        auto task = new HipAssetLoadTask(path, null);
        loadQueue[path] = task;
        task.result = HipAssetResult.loading;
        task.worker = worker;
        return task;
    }

    /**
    *   loadSimple must be used when the asset can be totally constructed on the worker thread and then returned to the main thread
    */
    private static HipAssetLoadTask loadSimple(string taskName, string path, HipAsset delegate(string pathOrLocation) loadAsset)
    {
        HipAssetLoadTask task;
        task = loadBase(path, loadWorker(taskName~path, ()
        {
            task.asset = loadAsset(path);
            if(task.asset !is null)
                task.result = HipAssetResult.loaded;
            else
                task.result = HipAssetResult.cantLoad;
            putComplete(task);
        }));
        return task;
    }

    /**
    *   loadComplex is used when part of the asset can be constructed on worker thread, but for completing the load, it must finish on main thread
    */
    private static HipAssetLoadTask loadComplex(string taskName, string path, 
        void[] delegate(string pathOrLocation) loadAsset, 
        HipAsset delegate(void[] partialData) onWorkerLoadComplete
    )
    {
        HipAssetLoadTask task;
        task = loadBase(path, loadWorker(taskName~path, ()
        {
            task.givePartialData(loadAsset(path));
        }, (name)
        {
            task.asset = onWorkerLoadComplete(task.takePartialData());
            if(task.asset !is null)
                task.result = HipAssetResult.loaded;
            else
                task.result = HipAssetResult.cantLoad;
            putComplete(task);
        }, true));
        return task;
    }

    @ExportD static IHipAssetLoadTask loadImage(string imagePath)
    {
        HipAssetLoadTask task = loadSimple("Load Image ", imagePath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            auto ret = new Image(pathOrLocation);
            if(!ret.loadFromMemory(HipFS.read(pathOrLocation)))
                return null;
            return ret;
        });
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadTexture(string texturePath)
    {
        import hip.util.memory;
        HipAssetLoadTask task = loadComplex("Load Texture ", texturePath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            Image img = new Image(pathOrLocation);
            if(!img.loadFromMemory(HipFS.read(pathOrLocation)))
                return null;
            return toHeapSlice(img);
            }, (partialData)
        {
            if(partialData is null)
                return null;
            Image img = cast(Image)partialData.ptr;
            HipTexture ret = new HipTexture(img);
            freeGCMemory(partialData);
            return ret;
        });
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadCSV(string path)
    {
        HipAssetLoadTask task = loadSimple("Load CSV", path, (pathOrLocation)
        {
            auto ret = new HipCSV();
            if(!ret.loadFromFile(pathOrLocation))
                return null;
            return ret;
        });
        workerPool.startWorking();
        return task;
    }
    @ExportD static IHipAssetLoadTask loadINI(string path)
    {
        HipAssetLoadTask task = loadSimple("Load INI", path, (pathOrLocation)
        {
            auto ret = new HipINI();
            if(!ret.loadFromFile(pathOrLocation))
                return null;
            return ret;
        });
        workerPool.startWorking();
        return task;
    }
    @ExportD static IHipAssetLoadTask loadJSONC(string path)
    {
        HipAssetLoadTask task = loadSimple("Load JSONC", path, (pathOrLocation)
        {
            auto ret = new HipJSONC();
            if(!ret.loadFromFile(pathOrLocation))
                return null;
            return ret;
        });
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadTextureAtlas(string atlasPath, string texturePath = ":IGNORE")
    {
        import hip.console.log;
        import hip.util.memory;
        import hip.assets.textureatlas;
        class TextureAtlasIntermediaryData
        {
            Image image;
            HipTextureAtlas atlas;
        }
        HipAssetLoadTask task = loadComplex("Load TextureAtlas ", atlasPath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            TextureAtlasIntermediaryData inter = new TextureAtlasIntermediaryData();
            inter.atlas = HipTextureAtlas.read(atlasPath, texturePath);
            string imagePath = inter.atlas.getTexturePath();
            inter.image = new Image(imagePath);
            if(!inter.image.loadFromMemory(HipFS.read(imagePath)))
                return null;
            return toHeapSlice(inter);
            }, (partialData)
        {
            if(partialData is null)
                return null;
            scope(exit) freeGCMemory(partialData);
            auto inter = cast(TextureAtlasIntermediaryData)partialData.ptr;
            if(!inter.atlas.loadTexture(inter.image))
            {
                loglnError("Could not load HipTextureAtlas texture ", inter.atlas.getTexturePath());
                return null;
            }
            return inter.atlas;
        });
        workerPool.startWorking();
        return task;
    }


    @ExportD static IHipAssetLoadTask loadTilemap(string tilemapPath)
    {
        import hip.console.log;
        import hip.util.memory;
        import hip.assets.tilemap;
        class TileMapIData
        {   
            HipTilemap map;
        }
        HipAssetLoadTask task = loadComplex("Load Tilemap ", tilemapPath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            TileMapIData inter = new TileMapIData();
            inter.map = HipTilemap.readTiledJSON(pathOrLocation);
            inter.map.loadImages();
            return toHeapSlice(inter);
            }, (partialData)
        {
            if(partialData is null)
                return null;
            scope(exit) freeGCMemory(partialData);
            auto inter = cast(TileMapIData)partialData.ptr;
            if(!inter.map.loadTextures())
            {
                loglnError("Could not load HipTilemap textures ", inter.map.path);
                return null;
            }
            HipTilemap ret = inter.map;
            return ret;
        });
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadTileset(string tilesetPath)
    {
        import hip.console.log;
        import hip.util.memory;
        import hip.assets.tilemap;
        class TilsetData
        {   
            HipTilesetImpl tileset;
        }
        HipAssetLoadTask task = loadComplex("Load Tileset ", tilesetPath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            TilsetData inter = new TilsetData();
            inter.tileset = HipTilesetImpl.read(pathOrLocation, 1);
            inter.loadImage();
            return toHeapSlice(inter);
            }, (partialData)
        {
            if(partialData is null)
                return null;
            scope(exit) freeGCMemory(partialData);
            auto inter = cast(TilsetData)partialData.ptr;
            if(!inter.tileset.loadTexture())
            {
                loglnError("Could not load HipTileset texture ", inter.tileset.path);
                return null;
            }
            HipTilesetImpl ret = inter.tileset;
            return ret;
        });
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipTilemap createTilemap(uint width, uint height, uint tileWidth, uint tileHeight)
    {
        return new HipTilemap(width, height, tileWidth, tileHeight);
    }
    @ExportD static IHipTileset tilesetFromAtlas(IHipTextureAtlas atlas){return HipTilesetImpl.fromAtlas(cast(HipTextureAtlas)atlas);}
    @ExportD static IHipTileset tilesetFromSpritesheet(Array2D_GC!IHipTextureRegion sp){return HipTilesetImpl.fromSpritesheet(sp);}

    @ExportD static IHipAssetLoadTask loadFont(string fontPath, int fontSize = 48)
    {
        import hip.util.path;
        switch(fontPath.extension)
        {
            case "bmfont":
            case "fnt":
                return loadBMFont(fontPath);
            case "ttf":
            case "otf":
                return loadTTF(fontPath, fontSize);
            default: return null;
        }
    }

    private static HipAssetLoadTask loadTTF(string ttfPath, int fontSize)
    {
        import hip.font.ttf;
        import hip.assets.font;
        import hip.util.memory;

        class IntermediaryData
        {
            Hip_TTF_Font font;
            ubyte[] rawImage;
            this(Hip_TTF_Font fnt, ubyte[] img){font = fnt; rawImage = img;}
        }

        HipAssetLoadTask task = loadComplex("Load TTF", ttfPath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            Hip_TTF_Font font = new Hip_TTF_Font(pathOrLocation, fontSize);
            ubyte[] rawImage;
            if(!font.partialLoad(HipFS.read(pathOrLocation), rawImage))
                return null;
            return toHeapSlice(new IntermediaryData(font, rawImage));
        }, (partialData)
        {
            if(partialData is null)
                return null;
            scope(exit) freeGCMemory(partialData);

            IntermediaryData i = (cast(IntermediaryData)partialData.ptr);
            if(!i.font.loadTexture(i.rawImage))
                return null;
            HipFontAsset fnt = new HipFontAsset(i.font);
            return fnt;
        });
        workerPool.startWorking();
        return task;
    }

    private static HipAssetLoadTask loadBMFont(string fontPath)
    {
        import hip.font.bmfont;
        import hip.assets.font;
        import hip.image;
        import hip.util.memory;
        import hip.console.log;

        class IntermediaryData
        {
            HipBitmapFont font;
            HipImageImpl img;
            this(HipBitmapFont fnt, HipImageImpl img){font = fnt; this.img = img;}
        }

        HipAssetLoadTask task = loadComplex("Load BMFont", fontPath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            HipBitmapFont font = new HipBitmapFont();

            if(!font.loadAtlas(HipFS.readText(fontPath), fontPath))
            {
                loglnError("Could not read atlas");
                return null;
            }
            HipImageImpl img = new HipImageImpl();
            if(!img.loadFromMemory(HipFS.read(font.getTexturePath)))
            {
                loglnError("Could not read image");
                return null;
            }
            return toHeapSlice(new IntermediaryData(font, img));
        }, (partialData)
        {
            if(partialData is null)
            {
                loglnError("No partial data");
                return null;
            }
            scope(exit) freeGCMemory(partialData);

            IntermediaryData i = (cast(IntermediaryData)partialData.ptr);
            if(!i.font.loadTexture(new HipTexture(i.img)))
            {
                loglnError("Could not read texture");
                return null;
            }
            HipFontAsset fnt = new HipFontAsset(i.font);
            return fnt;
        });
        workerPool.startWorking();
        return task;
    }
    

   
    /** 
     * Synchronized function for putting it into the completed queue for preparing the finish handlers
     */
    private static void putComplete(HipAssetLoadTask task)
    {
        if(task.result == HipAssetResult.loaded)
        {
            completeMutex.lock();
                completeQueue~= task;
            completeMutex.unlock();       
        }
    }

    static void addOnCompleteHandler(void delegate(HipAsset) onComplete, IHipAssetLoadTask task)
    {
        completeHandlers[cast(HipAssetLoadTask)task]~= onComplete;
    }

    /**
    *   This function is responsible for calling worker's onTaskFinish on the main thread if it has one.
    *   After that, it will execute any deferred task to the AssetManager, such as setting a HipSprite or HipFont asset.
    */
    static void update()
    {
        workerPool.pollFinished();
        completeMutex.lock();
            if(completeQueue.length)
            {
                foreach(task; completeQueue)
                {
                    //Subject to a logger
                    import hip.console.log;
                    loglnInfo("Finished ", task.name);
                    if(auto handlers = task in completeHandlers)
                    {
                        foreach(handler; *handlers)
                            handler(task._asset);
                    }
                }
                completeQueue.length = 0;
                completeHandlers.clear();
            }

        completeMutex.unlock();
    }

    /**
    *   Cleans everything up. Puts AssetManager in an invalid state
    */
    static void dispose()
    {
        import hip.error.handler;
        ErrorHandler.assertExit(!isCheckingReferenced, "Tried to dispose AssetManager while checking referenced assets");
        workerPool.dispose();
        foreach(HipAsset asset; assets.byValue)
            asset.dispose();
        destroy(assets);
        destroy(loadQueue);
        destroy(completeMutex);
        destroy(workerPool);
    }
}