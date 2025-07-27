module hip.loaders.texture_atlas;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;
import hip.console.log;

/**
*   Returns a load task for a texture atlas
*   If ":IGNORE" is provided for texturePath, the following behavior will occur:
*   - .json: Will try to load a file with same name but with extension .png
*   - .atlas: texturePath is always ignored
*   - .txt(or any): Load a file with same name but extension .png
*   - .xml: Ignore internal texture path to try file with same name but .png extension
*/
final class HipTextureAtlasLoadTask : HipAssetLoadTask
{
    private HipFSPromise fs;
    protected Image img;
    string texturePath = ":IGNORE";

    this(string path, string name, HipAsset asset, string texturePath, const(ubyte)[] extraData, string fileRequesting, size_t lineRequesting)
    {
        super(path, name, asset, extraData, fileRequesting, lineRequesting);
        this.texturePath = texturePath;
    }

    override void update()
    {
        final switch(result) with (HipAssetResult)
        {
            case waiting:
                result = loading;
                worker = HipAssetManager.loadWorker("Load and Decode TextureAtlas", ()
                {
                    HipFS.read(path)
                    .addOnError((string err){error = err; result = cantLoad;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        HipTextureAtlas tAtlas = HipTextureAtlas.readFromMemory(data, path, texturePath);
                        asset = tAtlas;

                        HipFS.read(tAtlas.getTexturePath())
                        .addOnError((string err){error = err; result = cantLoad;})
                        .addOnSuccess((in ubyte[] imgData)
                        {
                            new Image(tAtlas.getTexturePath(), imgData, (IImage self)
                            {
                                img = cast(Image)self;
                                result = mainThreadLoading;
                            }, (){result = cantLoad; error = "Could not load image for TextureAtlas";});
                            return FileReadResult.free;
                        });
                        return FileReadResult.free;
                    });
                });
                break;
            case loading:
                break;
            case mainThreadLoading:
                HipTextureAtlas atlas = cast(HipTextureAtlas)asset;
                if(!atlas.loadTexture(img))
                {
                    error = "Could not load Texture from TextureAtlas at ";
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