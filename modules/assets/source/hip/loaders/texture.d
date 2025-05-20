module hip.loaders.texture;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;
import hip.console.log;
import hip.hiprenderer.texture;

final class HipTextureLoadTask : HipAssetLoadTask
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
                worker = HipAssetManager.loadWorker("Load and Decode Texture", ()
                {
                    fs = HipFS.read(path)
                    .addOnError((string error){result = cantLoad; this.error = error; })
                    .addOnSuccess((in ubyte[] data)
                    {
                        asset = new Image(path, data, (IImage self)
                        {
                            result = mainThreadLoading;
                        }, (){ result = cantLoad; error = "Could not decode image for Texture."; });
                        return FileReadResult.keep;
                    });
                });
                break;
            case loading:
                break;
            case mainThreadLoading:
                HipTexture t = new HipTexture(cast(Image)asset);
                asset = t;
                hiplog("AssetManager: Texture: Loaded ", path, " ", t.toHipString.toString);
                result = loaded;
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