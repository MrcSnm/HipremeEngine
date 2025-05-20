module hip.loaders.text;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;

abstract class HipTextLoadTask : HipAssetLoadTask
{
    abstract string getWorkerName() const;
    protected abstract HipAsset loadAsset(in ubyte[] data);
    this(string path, string name, HipAsset asset, string fileRequesting, size_t lineRequesting)
    {
        super(path,name,asset,fileRequesting,lineRequesting);
    }

    override void update()
    {
        final switch(result) with (HipAssetResult)
        {
            case waiting:
                result = loading;
                worker = HipAssetManager.loadWorker(getWorkerName(), ()
                {
                    HipFS.read(path)
                    .addOnError((string error){ result = cantLoad; this.error = error; })
                    .addOnSuccess((in ubyte[] data)
                    {
                        asset = loadAsset(data);
                        result = loaded;
                        return FileReadResult.keep;
                    });
                });
                break;
            case loading, mainThreadLoading:
                break;
            case loaded: break;
            case cantLoad: break;
        }
    }

}

final class HipFileLoadTask : HipTextLoadTask
{
    this(string path, string name, HipAsset asset, string fileRequesting, size_t lineRequesting)
    {
        super(path,name,asset,fileRequesting,lineRequesting);
    }
    override string getWorkerName() const{ return "Load File"; }
    override protected HipAsset loadAsset(in ubyte[] data)
    {
        HipFileAsset ret = new HipFileAsset(path);
        ret.load(data);
        return ret;
    }
}

final class HipINILoadTask : HipTextLoadTask
{
    this(string path, string name, HipAsset asset, string fileRequesting, size_t lineRequesting)
    {
        super(path,name,asset,fileRequesting,lineRequesting);
    }
    override string getWorkerName() const{ return "Load INI"; }
    override protected HipAsset loadAsset(in ubyte[] data)
    {
        HipINI ret = new HipINI();
        ret.loadFromMemory(cast(string)data, path);
        return ret;
    }
}

final class HipCSVLoadTask : HipTextLoadTask
{
    this(string path, string name, HipAsset asset, string fileRequesting, size_t lineRequesting)
    {
        super(path,name,asset,fileRequesting,lineRequesting);
    }
    override string getWorkerName() const{ return "Load CSV"; }
    override protected HipAsset loadAsset(in ubyte[] data)
    {
        HipCSV ret = new HipCSV();
        ret.loadFromMemory(cast(string)data, ',', '"', path);
        return ret;
    }
}

final class HipJSONCLoadTask : HipTextLoadTask
{
    this(string path, string name, HipAsset asset, string fileRequesting, size_t lineRequesting)
    {
        super(path,name,asset,fileRequesting,lineRequesting);
    }
    override string getWorkerName() const{ return "Load JSONC"; }
    override protected HipAsset loadAsset(in ubyte[] data)
    {
        HipJSONC ret = new HipJSONC();
        ret.loadFromMemory(cast(string)data, path);
        return ret;
    }
}
