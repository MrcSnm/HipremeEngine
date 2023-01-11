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
    bool startDecoding(void[] data)
    {
        img = loadImageFromMemory(data);
        if(img !is null)
            trueImg = img.getAsTrueColorImage;

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

    const(void[]) getPixels()  const
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

final class HipNullImageDecoder : IHipAnyImageDecoder
{
    bool startDecoding(void[] data){return false;}
    uint getWidth() const {return 0;}
    uint getHeight() const {return 0;}
    const(void)[] getPixels() const {return null;}
    ubyte getBytesPerPixel() const {return 0;}
    const(ubyte)[] getPalette() const {return null;}
    void dispose(){}
}


version(WebAssembly)
{
    extern(C) struct BrowserImage
    {
        size_t handle;
        bool valid() const {return handle > 0;}
        alias handle this;
    }
    import hip.wasm;
    //Returns a BrowserImage, but can't use it in type directly.
    extern(C) size_t WasmDecodeImage(
        size_t imgPathLength, char* imgPathChars, ubyte* data, size_t dataSize,
        JSFunction!(void function(BrowserImage)) onImageLoad
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
        this(string path)
        {
            assert(path, "HipWasmImageDecoder requires a path.");
            this.path = path;
        }
        bool startDecoding(void[] data)
        {
            img = WasmDecodeImage(path.length, cast(char*)path.ptr, cast(ubyte*)data.ptr, data.length, sendJSFunction!((BrowserImage _img)
            {
                // assert(img == _img, "Different image returned!");
                import std.stdio;
                writeln("Getting width: ", WasmImageGetWidth(_img));
            }));

            if(img.valid)
            {
                width = WasmImageGetWidth(img);
                height = WasmImageGetHeight(img);
            }
            return img.valid;
        }
        uint getWidth() const {return width;}
        uint getHeight() const {return height;}
        const(void)[] getPixels() const 
        {
            assert(img.valid);
            if(timePixelsGet >= 5)
            {
                assert(false, "Don't call getPixel constantly on web. It is a very heavy operation. and may be 
                collected by the JS GC. A more strategic solution is being looked.
                ");
            }
            (cast()this).timePixelsGet++;//Debug info, never do that!!
            return cast(const(void)[])(WasmImageGetPixels(img)[0..width*height*4]);
        }
        ubyte getBytesPerPixel() const {return 4;}
        const(ubyte)[] getPalette() const {return null;}
        void dispose()
        {
            assert(img.valid, "Invalid dispose call.");
            WasmImageDispose(img);
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
    
    const(void)[] pixels;
    this(string path = "")
    {
        decoder = new HipPlatformImageDecoder(path);
    }

    static immutable(IImage) getPixelImage()
    {
        static HipImageImpl img; 
        static ubyte[4] pixel = IHipImageDecoder.getPixel();
        if(img is null)
        {
            img = new HipImageImpl;
            img.pixels = cast(void[])pixel;
            img.width = 1;
            img.height = 1;
            img.bytesPerPixel = 4;
        }
        return cast(immutable)img;
    }
    string getName() const {return "";}
    uint getWidth() const {return width;}
    uint getHeight() const {return height;}
    ubyte getBytesPerPixel() const {return bytesPerPixel;}
    const(ubyte[]) getPalette() const {return decoder.getPalette;}
    const(void[]) getPixels() const {return pixels;}

    void loadRaw(in ubyte[] pixels, int width, int height, ubyte bytesPerPixel)
    {
        this.width = width;
        this.height = height;
        this.pixels = cast(void[])pixels;
        this.bytesPerPixel = bytesPerPixel;
        this.bitsPerPixel = cast(ubyte)(bytesPerPixel*8);
    }


    bool loadFromMemory(ubyte[] data)
    {
        import hip.error.handler;
        if(ErrorHandler.assertErrorMessage(data.length != 0, "No data was passed to load Image.", "Could not load image"))
            return false;
        if(ErrorHandler.assertLazyErrorMessage(decoder.startDecoding(data),
        "Decoding Image: ", "Could not load image " ~ imagePath))
            return false;
        width         = decoder.getWidth();
        height        = decoder.getHeight();
        bitsPerPixel  = decoder.getBitsPerPixel();
        bytesPerPixel = decoder.getBytesPerPixel();
        pixels        = decoder.getPixels();
        return true;
    }

    bool hasLoadedData() const {return pixels !is null && width != 0 && height != 0;}

    void[] monochromeToRGBA() const
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

        return cast(void[])pix;
    }

    void[] convertPalettizedToRGBA() const
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

        return cast(void[])pix;
    }

    void dispose()
    {
        decoder.dispose();
    }
    alias w = width;
    alias h = height;
}


///Use that alias for supporting more platforms
version(HipARSDImageDecoder)
    alias HipPlatformImageDecoder = HipARSDImageDecoder;
else version(WebAssembly)
    alias HipPlatformImageDecoder = HipWasmImageDecoder;
else
{
    alias HipPlatformImageDecoder = HipNullImageDecoder;
    pragma(msg, "WARNING: Using NullImageDecoder.");
}
