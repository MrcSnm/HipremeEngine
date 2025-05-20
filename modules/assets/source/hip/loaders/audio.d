module hip.loaders.audio;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;
import hip.asset;

final class HipAudioLoadTask : HipAssetLoadTask
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
                worker = HipAssetManager.loadWorker("Load and Decode Audio", ()
                {
                    fs = HipFS.read(path)
                    .addOnError((string error){result = cantLoad; this.error = error;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        auto clip = new hip.assets.audioclip.HipAudioClip();
                        asset = clip;
                        clip.loadFromMemory(data, getEncodingFromName(path), HipAudioType.SFX,
                        (in ubyte[] newData)
                        {
                            result = loaded;
                        }, (){result = cantLoad;});
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