module hip.image_backend.gamut;
import hip.api.data.image;

version(HipGamutImageDecoder):
final class HipGamutImageDecoder : IHipImageDecoder
{
    import gamut;
    Image img;
    string path;
    this(string path = "")
    {
        this.path = path;
    }
    bool startDecoding(ubyte[] data, void delegate() onSuccess, void delegate() onFailure)
    {
        img.loadFromMemory(data, LOAD_RGB | LOAD_ALPHA | LOAD_8BIT);
        if(img.isValid)
        {
            img.changeLayout(LAYOUT_GAPLESS | LAYOUT_VERT_STRAIGHT);
            onSuccess();
        }
        else
            onFailure();
        return img.isValid;
    }

    uint getWidth() const
    {
        if(img.isValid)
            return img.width;
        return 0;
    }

    uint getHeight() const
    {
        if(img.isValid)
            return img.height;
        return 0;
    }

    const(ubyte[]) getPixels()  const
    {
        if(img.isValid)
            return img.allPixelsAtOnce();
        return null;
    }

    ubyte getBytesPerPixel() const
    {
        final switch(img.type) with(PixelType)
        {
            case l8: return 1;
            case l16: return 2;
            case lf32: return 4;
            case la8: return 2;
            case la16: return 4;
            case laf32: return 8;
            case rgb8: return 3;
            case rgb16: return 6;
            case rgbf32: return 12;
            case rgba8: return 4;
            case rgba16: return 8;
            case rgbaf32: return 16;
            case unknown: assert(false, "Invalid image?");
        }
    }
    ///Paletted PNG, BMP, GIF, and PIC images are automatically depalettized.
    ubyte[] getPalette() const{return null;}

    void dispose()
    {
        destroy(img);
    }
}
