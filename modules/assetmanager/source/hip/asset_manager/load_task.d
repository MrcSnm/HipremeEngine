module hip.asset_manager.load_task;
import hip.concurrency.thread;
import hip.config.opts;
import hip.api.data.commons;
import hip.error.handler;
import hip.assetmanager;


class HipAssetLoadTask : IHipAssetLoadTask
{
    string name;
    string path;
    HipAssetResult _result = HipAssetResult.cantLoad;
    HipAsset _asset = null;
    HipWorkerThread worker;
    string error;
    private string fileRequesting;
    private size_t lineRequesting;

    this(string path, string name, HipAsset asset, const(ubyte)[] extraData, string fileRequesting, size_t lineRequesting)
    {
        assert(name != null, "Asset load task can't receive null name");
        this.path = path;
        this.name = name;
        this._asset = asset;
        this.fileRequesting = fileRequesting;
        this.lineRequesting = lineRequesting;
        if(asset is null)
            _result = HipAssetResult.waiting;
        else
            _result = HipAssetResult.loaded;
    }

    bool hasFinishedLoading() const{return result == HipAssetResult.loaded;}
    bool opCast(T : bool)() const{return hasFinishedLoading;}


    void addOnCompleteHandler(void delegate(HipAsset) onComplete)
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
            case waiting, mainThreadLoading, loading:
                //variables are implicitly `scope`, need to duplicate.
                string*[] vars = variables.dup;
                addOnCompleteHandler((string data)
                {
                    foreach(v; vars)
                        *v = data;
                });
                break;
            case loaded:
                foreach(v; variables)
                    *v = (cast(HipFileAsset)(asset)).getText;
                break;
            case cantLoad:
                ErrorHandler.showWarningMessage("Can't load a null asset into a variable address", name);
                break;
        }
    }


    void into(void* function(HipAsset asset) castFunc, HipAsset*[] variables...)
    {
        import hip.error.handler;
        final switch(_result) with(HipAssetResult)
        {
            case waiting, mainThreadLoading, loading:
                //variables are implicitly `scope`, need to duplicate.
                HipAsset*[] vars = variables.dup;
                addOnCompleteHandler((HipAsset completeAsset)
                {
                    HipAsset theAsset = cast(HipAsset)castFunc(completeAsset);
                    assert(theAsset !is null, "Null asset received in complete handler?");
                    foreach(v; vars)
                        *v = theAsset;
                });
                break;
            case loaded:
                foreach(v; variables)
                    *v = cast(HipAsset)castFunc(asset);
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
    void update(){}

    HipAssetResult result() const {return _result;}
    HipAsset asset(){return _asset;}
    HipAssetResult result(HipAssetResult newResult){return _result = newResult;}
    HipAsset asset(HipAsset newAsset){return _asset = cast(HipAsset)newAsset;}
}