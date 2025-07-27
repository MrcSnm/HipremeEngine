module hip.loaders.fonts;
import hip.filesystem.hipfs;
import hip.asset_manager.load_task;
import hip.assetmanager;
import hip.api.data.commons;
import hip.font.bmfont;
import hip.font.ttf;
import hip.assets.texture;



final class HipTTFFontLoadTask : HipAssetLoadTask
{
    private HipFSPromise fs;
    int fontSize;
    HipFont font;
    private ubyte[] rawImage;

    this(string path, string name, HipAsset asset, int fontSize, string fileRequesting, size_t lineRequesting)
    {
        super(path, name, asset, fileRequesting, lineRequesting);
        this.fontSize = fontSize;
    }

    override void update()
    {
        final switch(result) with (HipAssetResult)
        {
            case waiting:
                result = loading;
                worker = HipAssetManager.loadWorker("Load and Decode TTF Font", ()
                {
                    HipFS.read(path)
                    .addOnError((string err){error = err; result = cantLoad;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        Hip_TTF_Font ttFont = new Hip_TTF_Font(path, fontSize);
                        font = ttFont;
                        if(!ttFont.partialLoad(data, rawImage))
                        {
                            result = cantLoad; error = "Could not load TTF data";
                            return FileReadResult.free;
                        }
                        result = mainThreadLoading;
                        return FileReadResult.free;
                    });
                });
                break;
            case loading:
                break;
            case mainThreadLoading:
                Hip_TTF_Font ttFont = cast(Hip_TTF_Font)font;
                if(!ttFont.loadTexture(rawImage))
                {
                    result = cantLoad; error = "Failed loading texture for TTF Font";
                    return;
                }
                asset = ttFont;
                result = loaded;
                break;
            case cantLoad: goto case loaded;
            case loaded:
                break;
        }
    }

}


final class HipBMFontLoadTask : HipAssetLoadTask
{
    private HipFSPromise fs;
    int fontSize;
    HipBitmapFont font;
    IImage loadedImage;

    this(string path, string name, HipAsset asset, int fontSize, string fileRequesting, size_t lineRequesting)
    {
        super(path, name, asset, fileRequesting, lineRequesting);
        this.fontSize = fontSize;
    }

    override void update()
    {
        final switch(result) with (HipAssetResult)
        {
            case waiting:
                result = loading;
                worker = HipAssetManager.loadWorker("Load and Decode BMFont", ()
                {
                    HipFS.read(path)
                    .addOnError((string err){error = err; result = cantLoad;})
                    .addOnSuccess((in ubyte[] data)
                    {
                        font = new HipBitmapFont();
                        if(!font.loadAtlas(cast(string)data, path))
                        {
                            result = cantLoad; error = "Could not load BMFont data";
                            return FileReadResult.free;
                        }
                        HipFS.read(font.getTexturePath)
                        .addOnError((string err){ result = cantLoad; error = err; })
                        .addOnSuccess((in ubyte[] imgData)
                        {
                            new Image(font.getTexturePath(), imgData, (IImage img)
                            {
                                result = mainThreadLoading;
                                loadedImage = img;
                            }, (){result = cantLoad; error = "Failed to load image data"; });
                            return FileReadResult.free;
                        });
                        return FileReadResult.free;
                    });
                });
                break;
            case loading:
                break;
            case mainThreadLoading:

                if(!font.loadTexture(new HipTexture(loadedImage, HipResourceUsage.Immutable)))
                {
                    result = cantLoad; error = "Failed loading texture for TTF Font";
                    return;
                }
                asset = font;
                result = loaded;
                break;
            case cantLoad: goto case loaded;
            case loaded:
                break;
        }
    }

}