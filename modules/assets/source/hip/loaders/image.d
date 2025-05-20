module hip.loaders.image;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;

final class HipImageLoadTask : HipAssetLoadTask
{
    private IHipFSPromise fs;
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
                worker = HipAssetManager.loadWorker("Load Image", ()
                {
                    fs = HipFS.read(path)
                    .addOnError((string error){result = cantLoad; this.error = error;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        _asset = new Image(path, data, (IImage img){result = loaded;}, (){result = cantLoad;});
                        return FileReadResult.keep;
                    });
                });
                break;
            case loading, mainThreadLoading:
                break;
            case cantLoad: goto case loaded;
            case loaded:
                if(fs !is null)
                {
                    fs.dispose();
                    fs = null;
                }
                break;
        }
    }

}