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
import hip.error.handler;
import hip.console.log : hiplog;


version(WebAssembly) version = CustomRuntime;
version(PSVita) version = CustomRuntime;

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
import hip.util.concurrency;
public import hip.asset;
public import hip.assets.image;
public import hip.assets.audioclip;
public import hip.assets.texture;
public import hip.assets.tilemap;
public import hip.assets.font;
public import hip.assets.csv;
public import hip.assets.jsonc;
public import hip.assets.ini;
public import hip.api.data.commons;
public import hip.assets.textureatlas;
public import hip.util.data_structures;



final class HipAssetLoadTask : IHipAssetLoadTask
{
    string name;
    string path;
    HipAssetResult _result = HipAssetResult.cantLoad;
    HipAsset _asset = null;
    protected HipWorkerThread worker;
    protected void[] partialData;


    private string fileRequesting;
    private size_t lineRequesting;

    this(string path, string name, HipAsset asset, string fileRequesting, size_t lineRequesting)
    {
        assert(name != null, "Asset load task can't receive null name");
        this.path = path;
        this.name = name;
        this._asset = asset;
        this.fileRequesting = fileRequesting;
        this.lineRequesting = lineRequesting;
        if(asset is null)
            _result = HipAssetResult.cantLoad;
        else
            _result = HipAssetResult.loaded;
    }

    bool hasFinishedLoading() const{return result == HipAssetResult.loaded;}
    bool opCast(T : bool)() const{return hasFinishedLoading;}


    void addOnCompleteHandler(void delegate(IHipAsset) onComplete)
    {
        HipAssetManager.addOnCompleteHandler(this, onComplete);
    }
    void addOnCompleteHandler(void delegate(string) onComplete)
    {
        HipAssetManager.addOnCompleteHandler(this, (asset)
        {
            HipFileAsset theAsset = cast(HipFileAsset)asset;
            assert(theAsset !is null, "Asset received is not a text");
            onComplete(theAsset.getText);
        });
    }


    void into(string*[] variables...)
    {
        import hip.error.handler;
        final switch(_result) with(HipAssetResult)
        {
            case loaded:
                foreach(v; variables)
                    *v = (cast(HipFileAsset)(asset)).getText;
                break;
            case loading:
                //variables are implicitly `scope`, need to duplicate.
                string*[] vars = variables.dup;
                addOnCompleteHandler((string data)
                {
                    foreach(v; vars)
                        *v = data;
                });
                break;
            case cantLoad:
                ErrorHandler.showWarningMessage("Can't load a null asset into a variable address", name);
                break;
        }
    }


    void into(void* function(IHipAsset asset) castFunc, IHipAsset*[] variables...)
    {
        import hip.error.handler;
        final switch(_result) with(HipAssetResult)
        {
            case loaded:
                foreach(v; variables)
                    *v = cast(IHipAsset)castFunc(asset);
                break;
            case loading:
                //variables are implicitly `scope`, need to duplicate.
                IHipAsset*[] vars = variables.dup;
                addOnCompleteHandler((IHipAsset completeAsset)
                {
                    IHipAsset theAsset = cast(IHipAsset)castFunc(completeAsset);
                    assert(theAsset !is null, "Null asset received in complete handler?");
                    foreach(v; vars)
                        *v = theAsset;
                });
                break;
            case cantLoad:
                ErrorHandler.showWarningMessage("Can't load a null asset into a variable address", name);
                break;
        }
    }
    
    void await()
    {
        if(_result == HipAssetResult.loading)
            HipAssetManager.awaitTask(this);
    }

    void givePartialData(void[] data)
    {
        import hip.util.conv:to;
        if(partialData !is null)
        {
            version(CustomRuntime)
                assert(false, "AssetLoadTask already has partial data for task "~name~" (requested at "~fileRequesting~":"~lineRequesting.to!string~")");
            else
                throw new Error("AssetLoadTask already has partial data for task "~name~" (requested at "~fileRequesting~":"~lineRequesting.to!string~")");
        }
        partialData = data;
    }

    void[] takePartialData()
    {
        import hip.util.conv:to;
        if(partialData is null)
        {
            version(CustomRuntime)
                assert(false, "No partial data was set before taking it for task "~name~ " (requested at "~fileRequesting~":"~lineRequesting.to!string~")");
            else
                throw new Error("No partial data was set before taking it for task "~name~ " (requested at "~fileRequesting~":"~lineRequesting.to!string~")");
        }
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
    protected __gshared void delegate(IHipAsset)[][HipAssetLoadTask] completeHandlers;
    


    public static void initialize()
    {
        completeMutex = new DebugMutex(0);
        workerPool = new HipWorkerPool(HIP_ASSETMANAGER_WORKER_POOL);
    }

    version(HipConcurrency)
    {
        import core.sync.mutex;
        import std.compiler;
        static bool isAsync = true;
    }
    else
    {
        static bool isAsync = false;
    }


    @ExportD static IHipAsset getAsset(string name)
    {
        if(HipAsset* asset = name in assets)
            return *asset;
        return null;
    }

    @ExportD static string getStringAsset(string name)
    {
        IHipAsset asset = getAsset(name);
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
    @ExportD static bool isLoading(){return !workerPool.isIdle;}
    ///Stops the code from running and awaits asset manager to finish loading
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
        //? Maybe it is not actually needed, as it can be handled by version(HipConcurrency)
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
    private static HipAssetLoadTask loadBase(string taskName, string path, lazy HipWorkerThread worker, string fileRequesting = __FILE__, size_t lineRequesting = __LINE__)
    {
        HipAsset asset = cast(HipAsset)getAsset(path);
        if(asset !is null){return new HipAssetLoadTask(path, taskName, asset, fileRequesting, lineRequesting);}
        else if(HipAssetLoadTask* task = path in loadQueue){return *task;}

        auto task = new HipAssetLoadTask(path, taskName, null, fileRequesting, lineRequesting);
        loadQueue[path] = task;
        task.result = HipAssetResult.loading;
        task.worker = worker;
        return task;
    }

    private static void delegate(HipAsset) onSuccessLoad(HipAssetLoadTask task)
    {
        return (HipAsset asset)
        {
            ///Will need specific code. Web works differently
            version(WebAssembly)
            {
                workerPool.signalTaskFinish();
            }
            task.asset = asset;
            task.result = HipAssetResult.loaded;
            putComplete(task);
        };
    }

    private static void delegate(string err = "") onFailureLoad(HipAssetLoadTask task)
    {
        return (err)
        {
            ErrorHandler.showWarningMessage("Could not load task: "~ task.name, err);
            task.result = HipAssetResult.cantLoad;
            putComplete(task);
        };
    }


    /**
    *   loadSimple must be used when the asset can be totally constructed on the worker thread and then returned to the main thread
    */
    private static HipAssetLoadTask loadSimple(string taskName, string path, void delegate(string pathOrLocation, 
    void delegate(HipAsset) onSuccess, void delegate(string err = "") onFailure) loadAsset, 
    string f = __FILE__, size_t l = __LINE__)
    {
        HipAssetLoadTask task;
        taskName = taskName~":"~path;
        task = loadBase(taskName, path, loadWorker(taskName, ()
        {
            loadAsset(path, onSuccessLoad(task), onFailureLoad(task));
        }), f, l);
        return task;
    }

    version(WebAssembly)
    {
        
        private static void delegate(void[] partialData) onSuccessLoadFirstStep(HipAssetLoadTask task, 
        void delegate(string taskName) nextStep)
        {
            return (void[] partialData)
            {
                task.givePartialData(partialData);
                workerPool.notifyOnFinishOnMainThread(nextStep, false)(task.name);
            };
        }

        /**
        *   The main difference in that version is that it doesn't depends on HipConcurrency to put
        *   on notifyOnFinish. That was decided because it is impossible to actually know when something
        *   has finished on Browser. The notfyOnFinish callback must be passed manually.
        */
        private static HipAssetLoadTask loadComplex(
            string taskName,
            string path,
            void delegate(
                string pathOrLocation, 
                void delegate(void[] partialData) onFirstStepComplete, 
                void delegate(string err = "") onFailure
            ) loadAsset, 

            void delegate (
                void[] partialData,
                void delegate(HipAsset) onSuccess,
            ) mainThreadLoadFunction,
            string f = __FILE__,
            size_t l = __LINE__
        )
        {
            HipAssetLoadTask task;
            taskName = taskName~":"~path;

            auto nextStep = (string _)
            {
                mainThreadLoadFunction(task.takePartialData(), onSuccessLoad(task));
            };

            task = loadBase(taskName, path, loadWorker(taskName, ()
            {
                loadAsset(path, onSuccessLoadFirstStep(task, nextStep), onFailureLoad(task));
            }, null, true), f, l);

            return task;
        }
    }
    else
    {
        /**
        *   loadComplex is used when part of the asset can be constructed on worker thread, but for completing the load, it must finish on main thread
        */
        private static HipAssetLoadTask loadComplex(
            string taskName,
            string path,
            void delegate(
                string pathOrLocation, 
                void delegate(void[] partialData) onFirstStepComplete, 
                void delegate(string err = "") onFailure
            ) loadAsset, 

            void delegate (
                void[] partialData,
                void delegate(HipAsset) onSuccess,
            ) mainThreadLoadFunction,
            string f = __FILE__,
            size_t l = __LINE__
        )
        {
            HipAssetLoadTask task;
            taskName = taskName~":"~path;

            task = loadBase(taskName, path, loadWorker(taskName, ()
            {
                loadAsset(path, (void[] partialData)
                {
                    task.givePartialData(partialData);
                }, onFailureLoad(task));
            }, (_)
            {
                mainThreadLoadFunction(task.takePartialData(), onSuccessLoad(task));
            }, true), f, l);

            return task;
        }
    }

    @ExportD static IHipAssetLoadTask loadFile(string filePath, string f = __FILE__, size_t l = __LINE__)
    {
        void delegate(string,void delegate(HipAsset), void delegate(string err = "")) assetLoadFunc = 
        (pathOrLocation,onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                HipFileAsset asset = new HipFileAsset(pathOrLocation);
                asset.load(data);
                onSuccess(asset);
            }).addOnError((string err)
            {
                onFailure("Could not read file with err: " ~ err);
            });
        };
        HipAssetLoadTask task = loadSimple("Load File ", filePath, assetLoadFunc, f, l);
        workerPool.startWorking();
        return task;
    }


    @ExportD static IHipAssetLoadTask loadImage(string imagePath, string f = __FILE__, size_t l = __LINE__)
    {
        void delegate(string,void delegate(HipAsset), void delegate(string err = "")) assetLoadFunc = 
        (pathOrLocation,onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                new Image(pathOrLocation, cast(ubyte[])data, (IImage img){onSuccess(cast(HipAsset)img);}, (){onFailure();});
            }).addOnError((string err)
            {
                onFailure("Could not read file with err: " ~ err);
            });
        };
        HipAssetLoadTask task = loadSimple("Load Image ", imagePath, assetLoadFunc, f, l);
        workerPool.startWorking();
        return task;
    }

    /** 
     * This can be totally loaded on the other thread. loadSimple is enough
     */
    @ExportD static IHipAssetLoadTask loadAudio(string audioPath, string f = __FILE__, size_t l = __LINE__)
    {
        hiplog("Loading Audio: ", audioPath);
        void delegate(string, void delegate(HipAsset), void delegate(string err)) assetLoadFunc =
        (pathOrLocation, onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                auto clip = new hip.assets.audioclip.HipAudioClip();
                clip.loadFromMemory(data, getEncodingFromName(pathOrLocation), HipAudioType.SFX,
                (in ubyte[] newData)
                {
                    onSuccess(clip);
                }, (){onFailure("Could not load HipAudioClip.");});

            }).addOnError((string err)
            {
                onFailure("Could not read file "~audioPath~" with error "~err);
            });
        };
        HipAssetLoadTask task = loadSimple("Load AudioClip", audioPath, assetLoadFunc, f, l);
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadTexture(string texturePath, string f = __FILE__, size_t l = __LINE__)
    {
        import hip.util.memory;
        void delegate(string, void delegate(void[]), void delegate(string err = "")) assetLoadFunc = 
        (pathOrLocation, onFirstStepComplete, onFailure)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                new Image(pathOrLocation, cast(ubyte[])data, 
                (IImage img)
                {
                    onFirstStepComplete(toHeapSlice(img));
                }, (){onFailure();});
            }).addOnError((string err)
            {
                ErrorHandler.showErrorMessage("Could not read file ", err);
            });
        };

        void delegate(void[], void delegate(HipAsset)) onPartialDataLoaded = 
        (partialData, onSuccess)
        {
            Image img = cast(Image)(cast(IImage)partialData.ptr);
            HipTexture ret = new HipTexture(img);
            onSuccess(ret);
            void* gcObjCopy = cast(void*)img;
            freeGCMemory(gcObjCopy); 
        };
        HipAssetLoadTask task = loadComplex("Load Texture", texturePath, assetLoadFunc, onPartialDataLoaded, f, l);
        workerPool.startWorking();
        return task;
    }

   
    @ExportD static IHipAssetLoadTask loadCSV(string path, string f = __FILE__, size_t l = __LINE__)
    {
        HipAssetLoadTask task = loadSimple("Load CSV", path, (pathOrLocation, onSuccess, onError)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                auto ret = new HipCSV();
                ret.loadFromMemory(cast(string)data);
                onSuccess(ret);
            }).addOnError((string err)
            {
                onError("Error reading file: "~ err);
            });
        }, f, l);
        workerPool.startWorking();
        return task;
    }
    @ExportD static IHipAssetLoadTask loadINI(string path, string f = __FILE__, size_t l = __LINE__)
    {
        HipAssetLoadTask task = loadSimple("Load INI", path, (pathOrLocation, onSuccess, onError)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                auto ret = new HipINI();
                ret.loadFromMemory(cast(string)data, pathOrLocation);
                onSuccess(ret);
            }).addOnError((string err)
            {
                onError("Error reading file: "~ err);
            });
        }, f, l);

        workerPool.startWorking();
        return task;
    }
    @ExportD static IHipAssetLoadTask loadJSONC(string path, string f = __FILE__, size_t l = __LINE__)
    {
        HipAssetLoadTask task = loadSimple("Load JSONC", path, (pathOrLocation, onSuccess, onError)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                auto ret = new HipJSONC();
                ret.loadFromMemory(cast(string)data);
                onSuccess(ret);
            }).addOnError((string err)
            {
                onError("Error reading file: "~ err);
            });
        }, f, l);

        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadTextureAtlas(string atlasPath, string texturePath = ":IGNORE", 
    string f = __FILE__, size_t l = __LINE__)
    {
        import hip.util.memory;
        import hip.assets.textureatlas;
        class TextureAtlasIntermediaryData
        {
            Image image;
            HipTextureAtlas atlas;
        }
        void delegate(string, void delegate(void[]), void delegate(string err = "")) assetLoadFunc = 
        (pathOrLocation, onFirstStepComplete, onFailure)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                TextureAtlasIntermediaryData inter = new TextureAtlasIntermediaryData();
                inter.atlas = HipTextureAtlas.readFromMemory(cast(ubyte[])data, atlasPath, texturePath);
                
                HipFS.read(inter.atlas.getTexturePath()).addOnSuccess((in ubyte[] imgData)
                {
                    inter.image = new Image(pathOrLocation, imgData, 
                    (IImage _)
                    {
                        onFirstStepComplete (toHeapSlice(inter));
                    }, (){onFailure("Failure trying to read image");});
                }).addOnError((err){onFailure("Failure trying to read atlas");});
            }).addOnError((string err)
            {
                ErrorHandler.showErrorMessage("Could not read file: ", err);
            });
        };

        void delegate(void[], void delegate(HipAsset)) onPartialDataLoaded = 
        (partialData, onSuccess)
        {
            scope(exit) freeGCMemory(partialData);
            auto inter = cast(TextureAtlasIntermediaryData)partialData.ptr;
            if(!inter.atlas.loadTexture(inter.image))
            {
                assert(false, "Need to implement onError for texture atlas.");
            }
            onSuccess(inter.atlas);
            freeGCMemory(partialData);
        };
        HipAssetLoadTask task = loadComplex("Load TextureAtlas", atlasPath, assetLoadFunc, onPartialDataLoaded, f, l);

        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipAssetLoadTask loadTilemap(string tilemapPath, string f = __FILE__, size_t l = __LINE__)
    {
        import hip.util.memory;
        import hip.assets.tilemap;

        HipAssetLoadTask task = loadComplex("Load Tilemap ", tilemapPath, (pathOrLocation, onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;
            HipTilemap map;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                map = HipTilemap.readTiledJSON(pathOrLocation, cast(ubyte[])data, (_)
                {
                    map.loadImages(()
                    {
                        onSuccess(toHeapSlice(map));
                    }, (){onFailure();});
                }, (){onFailure();});
            }).addOnError((string err)
            {
                onFailure("Failed loading tilemap data."~err);
            });
            }, (partialData, onSuccess)
        {
            scope(exit) freeGCMemory(partialData);
            auto map = cast(HipTilemap)partialData.ptr;
            if(!map.loadTextures())
            {
                assert(false, "Could not load HipTilemap textures " ~ map.path);
            }
            onSuccess(map);
        }, f, l);
        workerPool.startWorking();
        return task;
    }


    @ExportD static IHipAssetLoadTask loadTileset(string tilesetPath, string f = __FILE__, size_t l = __LINE__)
    {
        import hip.util.memory;
        import hip.assets.tilemap;
        HipAssetLoadTask task = loadComplex("Load Tileset ", tilesetPath, (pathOrLocation, onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;

            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                auto onTilesetJsonLoaded = delegate(HipTilesetImpl tileset)
                {
                    tileset.loadImage((IImage _)
                    {
                        onSuccess(toHeapSlice(tileset));
                    }, (){onFailure("Failed loading image for tileset");}); 
                };
                auto onTilesetJsonFailure = delegate(){onFailure("Failed loading tileset json");};
                HipTilesetImpl.readFromMemory(pathOrLocation, cast(string)data, onTilesetJsonLoaded, onTilesetJsonFailure);
            }).addOnError((string err)
            {
                onFailure("Failed reading file for tileset");
            });
            }, (partialData, onSuccess)
        {
            scope(exit) freeGCMemory(partialData);
            HipTilesetImpl tileset = cast(HipTilesetImpl)partialData.ptr;
            if(!tileset.loadTexture())
                assert(false, "Could not load HipTileset texture " ~ tileset.path);
            onSuccess(tileset);
        }, f, l);
        workerPool.startWorking();
        return task;
    }

    @ExportD static IHipTextureRegion createTextureRegion(IHipTexture texture, float u1 = 0.0, float v1 = 0.0, float u2 = 1.0, float v2 = 1.0)
    {
        return new HipTextureRegion(texture, u1, v1, u2, v2);
    }
    @ExportD static IHipTilemap createTilemap(uint width, uint height, uint tileWidth, uint tileHeight)
    {
        return new HipTilemap(width, height, tileWidth, tileHeight);
    }
    @ExportD static IHipTileset tilesetFromAtlas(IHipTextureAtlas atlas){return HipTilesetImpl.fromAtlas(cast(HipTextureAtlas)atlas);}
    @ExportD static IHipTileset tilesetFromSpritesheet(Array2D_GC!IHipTextureRegion sp){return HipTilesetImpl.fromSpritesheet(sp);}

    @ExportD static IHipAssetLoadTask loadFont(string fontPath, int fontSize = 48, string f = __FILE__, size_t l = __LINE__)
    {
        import hip.util.path;
        hiplog("Trying to load the font ", fontPath, "EXT: ", fontPath.extension);
        switch(fontPath.extension)
        {
            case "bmfont":
            case "fnt":
                return loadBMFont(fontPath, f, l);
            case "ttf":
            case "otf":
                return loadTTF(fontPath, fontSize, f, l);
            default: return null;
        }
    }

    private static HipAssetLoadTask loadTTF(string ttfPath, int fontSize, string f = __FILE__, size_t l = __LINE__)
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

        HipAssetLoadTask task = loadComplex("Load TTF", ttfPath, (pathOrLocation, onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;
            Hip_TTF_Font font = new Hip_TTF_Font(pathOrLocation, fontSize);
            ubyte[] rawImage;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] data)
            {
                if(!font.partialLoad(cast(ubyte[])data, rawImage))
                    onFailure("Could not load font data");
                onSuccess(toHeapSlice(new IntermediaryData(font, rawImage)));
            }).addOnError((string err)
            {
                onFailure("Could not read file "~err);
            });
        }, (partialData, onSuccess)
        {
            scope(exit) freeGCMemory(partialData);
            IntermediaryData i = (cast(IntermediaryData)partialData.ptr);
            if(!i.font.loadTexture(i.rawImage))
            {
                assert(false, "Failed loading TTF Font");
            }
            HipFontAsset fnt = new HipFontAsset(i.font);
            onSuccess(fnt);
        }, f, l);
        workerPool.startWorking();
        return task;
    }

    private static HipAssetLoadTask loadBMFont(string fontPath, string f = __FILE__, size_t l = __LINE__)
    {
        import hip.font.bmfont;
        import hip.assets.font;
        import hip.image;
        import hip.util.memory;

        class IntermediaryData
        {
            HipBitmapFont font;
            HipImageImpl img;
            this(HipBitmapFont fnt, HipImageImpl img){font = fnt; this.img = img;}
        }
        hiplog("Loading bmfont");

        HipAssetLoadTask task = loadComplex("Load BMFont", fontPath, 
        (pathOrLocation, onSuccess, onFailure)
        {
            import hip.filesystem.hipfs;
            HipFS.read(pathOrLocation).addOnSuccess((in ubyte[] fontData)
            {
                HipBitmapFont font = new HipBitmapFont();
                if(!font.loadAtlas(cast(string)fontData, pathOrLocation))
                    return onFailure("Could not load font atlas.");
                HipImageImpl img = new HipImageImpl(font.getTexturePath);

                HipFS.read(font.getTexturePath).addOnSuccess((in ubyte[] imgData)
                {
                    img.loadFromMemory(cast(ubyte[])imgData, (IImage _)
                    {
                        onSuccess(toHeapSlice(new IntermediaryData(font, img)));
                    }, 
                    ()
                    {
                        onFailure("Could not decode image.");
                    });
                }).addOnError((string err)
                {
                    onFailure("Could not load font image "~err);
                });
                
            }).addOnError((string err)
            {
                onFailure("Could read file atlas");
            });
        },
        (partialData, onSuccess)
        {
            IntermediaryData i = (cast(IntermediaryData)partialData.ptr);
            if(!i.font.loadTexture(new HipTexture(i.img)))
                assert(false, "Could not read texture");
            HipFontAsset fnt = new HipFontAsset(i.font);
            onSuccess(fnt);
            freeGCMemory(partialData);

        }, f, l);
        workerPool.startWorking();
        return task;
    }
    

   
    /** 
     * Synchronized function for putting it into the completed queue for preparing the finish handlers
     */
    private static void putComplete(HipAssetLoadTask task)
    {
        completeMutex.lock();
            if(task.result == HipAssetResult.loaded)
            {
                assert((cast(HipAsset)task.asset) !is null, "Can't putComplete a null asset.");
                assets[task.path] = cast(HipAsset)task.asset;
            }
            completeQueue~= task;
        completeMutex.unlock();       
    }

    static void addOnCompleteHandler(IHipAssetLoadTask task, void delegate(IHipAsset) onComplete)
    {
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
        completeMutex.lock();
            if(completeQueue.length)
            {
                foreach(task; completeQueue)
                {
                    //Subject to a logger
                    hiplog(task.name, " executing handlers");
                    if(auto handlers = task in completeHandlers)
                    {
                        foreach(handler; *handlers)
                            handler(task._asset);
                        handlers.length = 0;
                    }
                    completeHandlers.remove(task);
                }
                completeQueue.length = 0;
            }
        completeMutex.unlock();
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
        destroy(completeMutex);
        destroy(workerPool);
    }
}