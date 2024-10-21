module hip.image_backend.arsd;
import hip.api.data.image;


version(HipARSDImageDecoder)
final class HipARSDImageDecoder : IHipAnyImageDecoder
{
    import arsd.image;
    private
    {
        MemoryImage img;
        TrueColorImage trueImg;
    }
    string path;
    this(string path = "")
    {
        this.path = path;
    }
    bool startDecoding(ubyte[] data, void delegate() onSuccess, void delegate() onFailure)
    {
        img = loadImageFromMemory(data);
        if(img !is null)
        {
            trueImg = img.getAsTrueColorImage;
            onSuccess();
        }
        else
            onFailure();

        return (img !is null) && (trueImg !is null);
    }

    uint getWidth() const
    {
        if(img !is null)
            return img.width;
        return 0;
    }

    uint getHeight() const
    {
        if(img !is null)
            return img.height;
        return 0;
    }

    const(ubyte[]) getPixels()  const
    {
        if(img !is null)
            return trueImg.imageData.bytes;
        return null;
    }

    ubyte getBytesPerPixel() const
    {
        //Every true image color has 4 bytes per pixel
        return 4;
    }

    ubyte[] getPalette() const
    {
        return null;
    }

    void dispose()
    {
        img.clearInternal;
        destroy(trueImg);
        destroy(img);
    }
}
