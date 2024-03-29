module hip.assets.image;

//Reserved for future implementation.
import hip.asset;
import hip.image;
import hip.util.reflection;


/**
*   This class represents pixel data on RAM (CPU Powered)
*   this is useful for loading images on another thread and then
*   sending it to the GPU
*/
public class Image : HipAsset, IImage
{
    HipImageImpl impl;
    string imagePath;
    int width,height;

    this(in string path)
    {
        super("Image_"~path);
        _typeID = assetTypeID!Image;
        initialize(path);
    }

    this(in string path, in ubyte[] buffer, void delegate(IImage self) onSuccess, void delegate() onFailure)
    {
        this(path);
        loadFromMemory(cast(ubyte[])buffer, onSuccess, onFailure);
    }
    private void initialize(string path)
    {
        import hip.util.system : sanitizePath;
        impl = new HipImageImpl(path);
        imagePath = sanitizePath(path);
    }
    static alias getPixelImage = HipImageImpl.getPixelImage;

    mixin(ForwardInterface!("impl", IImage));

    void loadRaw(in ubyte[] pixels, int width, int height, ubyte bytesPerPixel)
    {
        impl.loadRaw(pixels, width, height, bytesPerPixel);
        this.width = width;
        this.height = height;
    }
    bool loadFromMemory(ubyte[] data,void delegate(IImage self) onSuccess, void delegate() onFailure)
    {
        bool ret = this.impl.loadFromMemory(data, (IImage self)
        {
            this.width = impl.getWidth;
            this.height = impl.getHeight;
            onSuccess(this);
        }, onFailure);
        return ret;
    }


    override void onDispose(){impl.dispose();}
    override void onFinishLoading(){}
    alias w = width;
    alias h = height;
}
