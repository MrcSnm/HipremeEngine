module hip.loaders.tilemap;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;
import hip.asset;

final class HipTilemapLoadTask : HipAssetLoadTask
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
                worker = HipAssetManager.loadWorker("Load and Decode TileMap", ()
                {
                    HipFS.read(path)
                    .addOnError((string err){error = err; result = cantLoad;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        HipTilemap.readTiledJSON(path, data, (HipTilemap map)
                        {
                            asset = map;
                            map.loadImages((){result = mainThreadLoading;}, (){error = "Failed at Loading Images"; result = cantLoad;});
                        }, (){result = cantLoad;});
                        return FileReadResult.free;
                    });
                });
                break;
            case loading:
                break;
            case mainThreadLoading:
                HipTilemap map = cast(HipTilemap)asset;
                if(!map.loadTextures())
                {
                    error = "Could not load Texture from Tilemap";
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