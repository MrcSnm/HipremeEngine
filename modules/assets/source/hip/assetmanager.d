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


enum HipAssetResult
{
    cantLoad,
    loading,
    loaded
}

interface IHipAssetLoadTask
{
    bool hasFinishedLoading();
    void await();
}


class HipAssetLoadTask : IHipAssetLoadTask
{
    string name;
    HipAssetResult result = HipAssetResult.cantLoad;
    HipAsset asset = null;
    protected HipWorkerThread worker;
    protected void[] partialData;

    this(string name, HipAsset asset)
    {
        this.name = name;
        this.asset = asset; 
        if(asset is null)
            result = HipAssetResult.cantLoad;
        else
            result = HipAssetResult.loaded;
    }

    bool hasFinishedLoading(){return result == HipAssetResult.loaded;}
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
        return partialData;
    }

}



import hip.hipengine.api.data.commons : HipDeferrableTypes;
import hip.hipengine.api.data.font;
mixin template HipDeferredLoadImpl()
{
    import hip.util.reflection;
    
    private void deferredLoad(T, string funcName)(HipAssetLoadTask task)
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


    pragma(msg, typeof(this).stringof, " ", hasType!"HipTexture");
    pragma(msg, typeof(this).stringof, " ", hasType!"hip.assets.texture.HipTexture");
    static if(hasType!"hip.assets.texture.HipTexture" && hasMethod!(typeof(this), "setTexture", HipTexture))
    {
        void setTexture(HipAssetLoadTask task)
        {
            deferredLoad!(HipTexture, "setTexture")(task);
        }
    }
    static if(hasType!"hip.hipengine.api.font.HipFont" && hasMethod!(typeof(this), "setFont", HipFont))
    {
        void setFont(HipAssetLoadTask task)
        {
            deferredLoad!(HipFont, "setFont")(task);
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
    import core.sync.mutex;

    protected static HipWorkerPool workerPool;
    static float currentTime;
    //Caching
    protected static HipAsset[string] assets;
    protected static HipAssetLoadTask[string] loadQueue;

    //Thread Communication
    protected static HipAssetLoadTask[] completeQueue;
    protected static Mutex completeMutex;
    protected static void delegate(HipAsset)[][HipAssetLoadTask] completeHandlers;
    

    //Auto Loading
    protected static HipAsset[string] referencedAssets;
    protected static bool isCheckingReferenced = false;


    static this()
    {
        completeMutex = new Mutex();
        workerPool = new HipWorkerPool(8);
    }
    static bool isAsync = true;

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

    static bool isLoading(){return workerPool.isIdle;}
    static void awaitLoad(){workerPool.await;}

    static void awaitTask(HipAssetLoadTask task)
    {
        import core.sync.semaphore;
        auto semaphore = new Semaphore(0);
        task.worker.pushTask("Await Single", ()
        {
            semaphore.notify;
        });
        semaphore.wait;
        destroy(semaphore);
    }

    private static HipWorkerThread loadWorker(void delegate() loadFn, void delegate(string taskName) onFinish = null, bool onMainThread = false)
    {
        if(isAsync)
            return workerPool.pushTask("Load", loadFn, onFinish, onMainThread);
        else
        {
            loadFn();
            if(onFinish !is null)
                onFinish("Load");
        }
        return null;
    }


    // private static HipAsset delegate() getLoadable(string path)
    // {
    //     import hip.util.path;
    //     string ext = path.extension;

    //     switch(ext)
    //     {
    //         case ".png":
    //         case ".jpg":
    //         case ".bmp":
    //         case ".tga":
    //         case ".targa":
    //             return (){
    //                 Image img = new Image(path);
    //                 return img;
    //             };
    //         case ".ttf":
    //             return (){
    //                 return new Hip_TTF_Font(path);
    //             };
    //         case ".bmfont":
    //         case ".fnt":
    //             return (){
    //                 return new HipBitmapFont(path);
    //             };
    //         default:
    //             return null;
    //     }
    // }

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
    private static HipAssetLoadTask loadSimple(string path, HipAsset function(string pathOrLocation) loadAsset)
    {
        HipAssetLoadTask task;
        task = loadBase(path, loadWorker(()
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
    private static HipAssetLoadTask loadComplex(string path, void[] function(string pathOrLocation) loadAsset, HipAsset delegate(void[] partialData) onWorkerLoadComplete)
    {
        HipAssetLoadTask task;
        task = loadBase(path, loadWorker(()
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

    static HipAssetLoadTask loadImage(string imagePath)
    {
        HipAssetLoadTask task = loadSimple(imagePath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            auto ret = new Image(pathOrLocation);
            ret.loadFromMemory(HipFS.read(pathOrLocation));
            return ret;
        });
        return task;
    }

    static HipAssetLoadTask loadTexture(string texturePath)
    {
        import hip.util.memory;
        HipAssetLoadTask task = loadComplex(texturePath, (pathOrLocation)
        {
            import hip.filesystem.hipfs;
            Image img = new Image(pathOrLocation);
            img.loadFromMemory(HipFS.read(pathOrLocation));
            return toHeapSlice(img);
        }, (partialData)
        {
            Image img = cast(Image)partialData.ptr;
            HipTexture ret = new HipTexture(img);
            freeGCMemory(partialData);
            return ret;
        });
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

    static void addOnCompleteHandler(void delegate(HipAsset) onComplete, HipAssetLoadTask task)
    {
        completeHandlers[task]~= onComplete;
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
                    if(auto handlers = task in completeHandlers)
                    {
                        foreach(handler; *handlers)
                            handler(task.asset);
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