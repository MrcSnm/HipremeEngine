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
public import hip.api.data.asset;
public import hip.api.data.image;


IHipBMPDecoder bmp;
IHipJPEGDecoder jpeg;
IHipPNGDecoder png;
IHipWebPDecoder webP;


/**
*   This class represents pixel data on RAM (CPU Powered)
*   this is useful for loading images on another thread and then
*   sending it to the GPU
*/
public class Image : HipAsset, IImage
{
    IHipImageDecoder decoder;
    string imagePath;
    int width, height;
    ubyte bytesPerPixel;
    ushort bitsPerPixel;
    
    ubyte[] pixels;
    this(string path = "")
    {
        import hip.util.system : sanitizePath;
        import hip.image_backend.impl;
        path = sanitizePath(path);
        super("Image_"~path);
        imagePath = path;
        decoder = getDecoder(path);
    }
    this(in string path, in ubyte[] buffer, void delegate(IImage self) onSuccess, void delegate() onFailure)
    {
        this(path);
        loadFromMemory(cast(ubyte[])buffer, onSuccess, onFailure);
    }

    static immutable(IImage) getPixelImage()
    {
        __gshared Image img;
        __gshared ubyte[4] pixel = IHipImageDecoder.getPixel();
        if(img is null)
        {
            img = new Image("Pixel");
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

    override bool isReady() const { return hasLoadedData(); }

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

    override void onDispose() {decoder.dispose(); }
    override void onFinishLoading() { }
    alias w = width;
    alias h = height;
}


