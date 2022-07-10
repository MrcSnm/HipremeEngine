/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.data.assetmanager;
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
import hip.data.asset;
import hip.util.concurrency;
public import hip.data.asset;
public import hip.data.assets.image;


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
    HipAssetResult result = HipAssetResult.cantLoad;
    HipAsset asset = null;
    immutable bool isAsync;

    version(HipAsync)
    {
        protected HipWorkerThread worker;
    }

    this(HipAsset asset)
    {
        this.asset = asset;
        isAsync = false;
        result = HipAssetResult.loaded;
    }

    this(HipAsset delegate() loadTask, bool isAsync = true)
    {
        //Force false async 
        version(HipAsync)
        {
            if(isAsync)
            {
                worker.pushTask("Load Asset", ()
                {
                    asset = loadTask();
                    result = HipAssetResult.loaded;
                });
            }
        } 
        else
        {
            isAsync = false;
            asset = loadTask();
            result = HipAssetResult.loaded;
        }
        this.isAsync = isAsync;
    }

    bool hasFinishedLoading(){return result == HipAssetResult.loaded;}
    bool opCast(T : bool)() const{return hasFinishedLoading;}
    void await()
    {
        version(HipAsync) if(isAsync)
            worker.await();
    }
    
}


class HipAssetManager
{
    protected static HipWorkerPool workerPool;
    static float currentTime;
    protected static HipAsset[string] assets;
    protected static HipAssetLoadTask[string] loadQueue;

    static this()
    {
        workerPool = new HipWorkerPool(8);
    }

    static HipAsset getAsset(string name)
    {
        if(HipAsset* asset = name in assets)
            return *asset;
        return null;
    }
    static pragma(inline, true) T getAsset(T : HipAsset)(string name) {return cast(T)getAsset(name);}
    static bool isLoading(){return workerPool.isIdle;}
    static void awaitLoad(){workerPool.await;}


    static HipAssetLoadTask loadImage(string imagePath)
    {
        HipAsset asset = getAsset(imagePath);
        if(asset !is null){return new HipAssetLoadTask(asset);}
        else if(HipAssetLoadTask* task = imagePath in loadQueue){return *task;}

        auto task = new HipAssetLoadTask(()
        {
            Image img = new Image(imagePath);
            img.loadFromFile();
            return img;
        }, true);
        loadQueue[imagePath] = task;
        return task;
    }
}