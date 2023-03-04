/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.image;
public import hip.api.data.image;


IHipBMPDecoder bmp;
IHipJPEGDecoder jpeg;
IHipPNGDecoder png;
IHipWebPDecoder webP;


version(HipARSDImageDecoder)
final class HipARSDImageDecoder : IHipAnyImageDecoder
{
    import arsd.image;
    MemoryImage img;
    TrueColorImage trueImg;
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


version(HipGamutImageDecoder)
final class HipGamutImageDecoder : IHipAnyImageDecoder
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
        img.loadFromMemory(data);
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

final class HipNullImageDecoder : IHipAnyImageDecoder
{
    this(string path){}
    bool startDecoding(void[] data, void delegate() onSuccess, void delegate() onFailure)
    {
        onFailure();
        return false;
    }
    uint getWidth() const {return 0;}
    uint getHeight() const {return 0;}
    const(ubyte)[] getPixels() const {return null;}
    ubyte getBytesPerPixel() const {return 0;}
    const(ubyte)[] getPalette() const {return null;}
    void dispose(){}
}


version(WebAssembly)
{
    import hip.wasm;
    extern(C) struct BrowserImage
    {
        size_t handle;
        bool valid() const {return handle > 0;}
        alias handle this;
    }
    //Returns a BrowserImage, but can't use it in type directly.
    extern(C) size_t WasmDecodeImage(
        size_t imgPathLength, char* imgPathChars, ubyte* data, size_t dataSize,
        JSDelegateType!(void delegate(BrowserImage)) onImageLoad
    );

    extern(C) size_t WasmImageGetWidth(size_t);
    extern(C) size_t WasmImageGetHeight(size_t);
    extern(C) ubyte* WasmImageGetPixels(size_t);
    extern(C) void WasmImageDispose(size_t);

    final class HipWasmImageDecoder : IHipAnyImageDecoder
    {
        //Everything here needs to be cached for not calling the Wasm bridge.
        private uint width, height;
        private size_t timePixelsGet = 0;
        BrowserImage img;
        string path;
        ubyte[] pixels;
        this(string path)
        {
            assert(path, "HipWasmImageDecoder requires a path.");
            this.path = path;
        }
        bool startDecoding(void[] data, void delegate() onSuccess, void delegate() onFailure)
        {
            import hip.console.log;
            img = WasmDecodeImage(path.length, cast(char*)path.ptr, cast(ubyte*)data.ptr, data.length, sendJSDelegate!((BrowserImage _img)
            {
                assert(img == _img, "Different image returned!");
                if(img.valid)
                {
                    width = WasmImageGetWidth(img);
                    height = WasmImageGetHeight(img);
                    pixels = getWasmBinary(WasmImageGetPixels(img));
                    hiplog(width, " x ", height, " ", pixels.length, " bytes");

                    (width != 0 && height != 0) ? onSuccess() : onFailure();
                }
                else
                {
                    loglnError("Corrupted JS image object.");
                    onFailure();
                }
            }).tupleof);

            return img.valid && width != 0 && height != 0;
        }
        uint getWidth() const {return width;}
        uint getHeight() const {return height;}
        const(ubyte)[] getPixels() const 
        {
            return cast(const(ubyte)[])pixels;
        }
        ubyte getBytesPerPixel() const {return 4;}
        const(ubyte)[] getPalette() const {return null;}
        void dispose()
        {
            assert(img.valid, "Invalid dispose call.");
            WasmImageDispose(img);
            freeWasmBinary(pixels);
            img = 0;
            pixels = null;
        }
    }
}


public class HipImageImpl : IImage
{
    IHipImageDecoder decoder;
    string imagePath;
    int width, height;
    ubyte bytesPerPixel;
    ushort bitsPerPixel;
    
    ubyte[] pixels;
    this(string path = "")
    {
        imagePath = path;
        decoder = new HipPlatformImageDecoder(path);
    }

    static immutable(IImage) getPixelImage()
    {
        __gshared HipImageImpl img; 
        __gshared ubyte[4] pixel = IHipImageDecoder.getPixel();
        if(img is null)
        {
            img = new HipImageImpl("Pixel");
            img.pixels = pixel;
            img.width = 1;
            img.height = 1;
            img.bytesPerPixel = 4;
        }
        return cast(immutable)img;
    }
    string getName() const {return imagePath;}
    uint getWidth() const {return width;}
    uint getHeight() const {return height;}
    ubyte getBytesPerPixel() const {return bytesPerPixel;}
    const(ubyte[]) getPalette() const {return decoder.getPalette;}
    const(ubyte[]) getPixels() const {return pixels;}

    void loadRaw(in ubyte[] pixels, int width, int height, ubyte bytesPerPixel)
    {
        this.width = width;
        this.height = height;
        this.pixels = cast(ubyte[])pixels;
        this.bytesPerPixel = bytesPerPixel;
        this.bitsPerPixel = cast(ubyte)(bytesPerPixel*8);
    }


    bool loadFromMemory(ubyte[] data, void delegate(IImage self) onSuccess, void delegate() onFailure)
    {
        import hip.error.handler;
        if(ErrorHandler.assertErrorMessage(data.length != 0, "No data was passed to load Image.", "Could not load image"))
            return false;
        if(ErrorHandler.assertLazyErrorMessage(decoder.startDecoding(data, ()
        {
            width         = decoder.getWidth();
            height        = decoder.getHeight();
            bitsPerPixel  = decoder.getBitsPerPixel();
            bytesPerPixel = decoder.getBytesPerPixel();
            pixels        = cast(ubyte[])decoder.getPixels();
            onSuccess(this);
        }, onFailure),
        "Decoding Image: ", "Could not load image " ~ imagePath))
            return false;
        
        return true;
    }

    bool hasLoadedData() const {return pixels !is null && width != 0 && height != 0;}

    ubyte[] monochromeToRGBA() const
    {
        import hip.error.handler;
        ubyte[] pix = new ubyte[](4*width*height); //RGBA for each pixel
        ErrorHandler.assertExit(pix != null, "Out of memory when converting monochrome to RGBA");
        uint pixelsLength = width*height;
        ubyte color;
        uint z;
        for(uint i = 0; i < pixelsLength; i++)
        {
            //Palette r color = palette[pixels[i]*4]
            color = (cast(ubyte*)pixels)[i];
            pix[z++] = color; //R
            pix[z++] = color; //G
            pix[z++] = color; //B
            pix[z++] = color; //A
        }

        return pix;
    }

    ubyte[] convertPalettizedToRGBA() const
    {
        import hip.error.handler;
        ubyte[] pix = new ubyte[](4*width*height); //RGBA for each pixel
        ErrorHandler.assertExit(pix != null, "Out of memory when converting palette pixels to RGBA");

        uint pixelsLength = width*height;
        const(ubyte[]) palette = decoder.getPalette();

        uint colorIndex;
        uint z;
        for(uint i = 0; i < pixelsLength; i++)
        {
            //Palette r color = palette[pixels[i]*4]
            colorIndex = (cast(ubyte*)pixels)[i]*4;
            pix[z++]   = palette[colorIndex]; //R
            pix[z++] = palette[colorIndex+1]; //G
            pix[z++] = palette[colorIndex+2]; //B
            pix[z++] = palette[colorIndex+3]; //A
        }

        return pix;
    }

    void dispose()
    {
        decoder.dispose();
    }
    alias w = width;
    alias h = height;
}


///Use that alias for supporting more platforms
version(HipARSDImageDecoder) alias HipPlatformImageDecoder = HipARSDImageDecoder;
else version(HipGamutImageDecoder) alias HipPlatformImageDecoder = HipGamutImageDecoder;
else version(WebAssembly) alias HipPlatformImageDecoder = HipWasmImageDecoder;
else
{
    alias HipPlatformImageDecoder = HipNullImageDecoder;
    pragma(msg, "WARNING: Using NullImageDecoder.");
}
