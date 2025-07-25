module hip.loaders.tileset;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;

final class HipTilesetLoadTask : HipAssetLoadTask
{
    private HipFSPromise fs;
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
                worker = HipAssetManager.loadWorker("Load and Decode Tileset", ()
                {
                    HipFS.read(path)
                    .addOnError((string err){error = err; result = cantLoad;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        HipTileset.readFromMemory(path, cast(string)data, (HipTileset set)
                        {
                            asset = set;
                            set.loadImage((IImage img){result = mainThreadLoading;}, (){result = cantLoad; error = "Failed at loading Tileset image.";});
                        }, (){result = cantLoad; error = "Failed at creating Tileset";});
                        return FileReadResult.free;
                    });
                });
                break;
            case loading:
                break;
            case mainThreadLoading:
                HipTileset set = cast(HipTileset)asset;
                if(!set.loadTexture())
                {
                    error = "Could not load Texture from Tileset";
                    result = cantLoad;
                    return;
                }
                result = loaded;
                break;
            case cantLoad: goto case loaded;
            case loaded:
                break;
        }
    }

}