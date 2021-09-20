/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module data.image;
import data.hipfs;
import util.concurrency;
import data.asset;
import error.handler;
import util.system;
import console.log;
import bindbc.sdl;
public import hipengine.api.data.image;


IHipBMPDecoder bmp;
IHipJPEGDecoder jpeg;
IHipPNGDecoder png;
IHipWebPDecoder webP;

final class HipSDLImageDecoder : IHipAnyImageDecoder
{
    this()
    {
        bmp = this; jpeg = this; png = this; webP = this;
    }
    SDL_Surface* img;
    bool startDecoding(void[] data)
    {
        SDL_RWops* rw = SDL_RWFromMem(data.ptr, cast(int)data.length);
        img = IMG_Load_RW(rw, 1); //Free SDL_RWops
        // if(img != null && rgbColorKey != -1)
        //     SDL_SetColorKey(img, SDL_TRUE, SDL_MapRGB(img.format,
        //     cast(ubyte)(rgbColorKey >> 16), //R
        //     cast(ubyte)((rgbColorKey >> 8) & 255), //G
        //     cast(ubyte)(rgbColorKey & 255))); //B
        return img != null;
    }
    uint getWidth(){return (img == null) ? 0 : img.w;}
    uint getHeight(){return (img == null) ? 0 : img.h;}
    void* getPixels(){return (img == null) ? null : img.pixels;}
    ubyte getBytesPerPixel(){return (img == null) ? 0 : img.format.BytesPerPixel;}
    ubyte[] getPalette()
    {
        ubyte[] palette = new ubyte[](img.format.palette.ncolors*4);
        palette[0] = 0;
        palette[1] = 0;
        palette[2] = 0;
        palette[3] = 0;
        uint z; //Palette index
        for(int i = 1; i < img.format.palette.ncolors; i++)
        {
            SDL_Color c = img.format.palette.colors[i];
            z = i*4;
            palette[z] = c.r;
            palette[z+1] = c.g;
            palette[z+2] = c.b;
            palette[z+3] = c.a;
        }
        return palette;
    }
    ///Dispose the pixels
    void dispose(){if(img != null){SDL_FreeSurface(img);img = null;}}
}
///Use that alias for supporting more platforms
alias HipPlatformImageDecoder = HipSDLImageDecoder;

/**
*   This class represents pixel data on RAM (CPU Powered)
*   this is useful for loading images on another thread and then
*   sending it to the GPU
*/
public class Image : HipAsset, IImage
{
    protected shared bool _ready;
    IHipImageDecoder decoder;
    string imagePath;
    uint width, height;
    ubyte bytesPerPixel;
    ushort bitsPerPixel;
    void* pixels;

    protected void* convertedPixels;

    this(in string path)
    {
        super("Image_"~path);
        decoder = new HipPlatformImageDecoder();
        imagePath = sanitizePath(path);
    }
    string getName(){return name;}
    uint getWidth(){return width;}
    uint getHeight(){return height;}
    ushort getBytesPerPixel(){return bytesPerPixel;}
    void* getPixels(){return pixels;}


    bool loadFromMemory(ref ubyte[] data)
    {
        if(ErrorHandler.assertErrorMessage(decoder.startDecoding(data),
        "Decoding Image: ", "Could not load image " ~ imagePath))
            return false;
        width         = decoder.getWidth();
        height        = decoder.getHeight();
        bitsPerPixel  = decoder.getBitsPerPixel();
        bytesPerPixel = decoder.getBytesPerPixel();
        pixels        = decoder.getPixels();
        return true;
    }

    void* convertPalettizedToRGBA()
    {
        import core.stdc.stdlib:malloc;
        if(convertedPixels != null)
            return convertedPixels;
        ubyte* pix = cast(ubyte*)malloc(4*width*height); //RGBA for each pixel
        ErrorHandler.assertExit(pix != null, "Out of memory when converting palette pixels to RGBA");
        convertedPixels = pix;

        uint pixelsLength = width*height;
        ubyte[] palette = decoder.getPalette();

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

        destroy(palette);

        return cast(void*)pix;
    }

    bool loadFromFile()
    {
        ubyte[] data;
        HipFS.read(imagePath, data);
        return loadFromMemory(data);
    }

    override bool load()
    {
        _ready = loadFromFile();
        return _ready;
    }

    override bool isReady(){return _ready;}
    bool load(void function() onLoad)
    {
        bool ret = loadFromFile();
        if(ret)
            onLoad();
        return ret;
    }
    override void onDispose()
    {
        import core.stdc.stdlib:free;
        decoder.dispose();
        if(convertedPixels != null)
        {
            free(convertedPixels);
            convertedPixels = null;
        }
    }
    override void onFinishLoading(){}
    alias w = width;
    alias h = height;
}