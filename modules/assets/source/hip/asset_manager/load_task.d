module hip.asset_manager.load_task;
import hip.concurrency.thread;
public import hip.asset;
import hip.config.opts;
import hip.api.data.commons;
import hip.error.handler;
import hip.assetmanager;


final class HipAssetLoadTask : IHipAssetLoadTask
{
    string name;
    string path;
    HipAssetResult _result = HipAssetResult.cantLoad;
    HipAsset _asset = null;
    HipWorkerThread worker;
    private string fileRequesting;
    private size_t lineRequesting;

    protected void[] partialData;


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
            static if(CustomRuntime)
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
            static if(CustomRuntime)
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

void delegate(string err = "") onFailureLoad(IHipAssetLoadTask task)
{
    return (err)
    {
        HipAssetLoadTask lTask = cast(HipAssetLoadTask)task;
        ErrorHandler.showWarningMessage("Could not load task: "~ lTask.name, err);
        lTask.result = HipAssetResult.cantLoad;
        HipAssetManager.putComplete(task);
    };
}
void delegate(HipAsset) onSuccessLoad(IHipAssetLoadTask task)
{
    return (HipAsset asset)
    {
        HipAssetLoadTask lTask = cast(HipAssetLoadTask)task;
        ///Will need specific code. Web works differently
        version(WebAssembly)
        {
            HipAssetManager.workerPool.signalTaskFinish();
        }
        lTask.asset = asset;
        lTask.result = HipAssetResult.loaded;
        HipAssetManager.putComplete(task);
    };
}