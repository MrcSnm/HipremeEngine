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

public interface IHipImageDecoder
{
    ///Use that for decoding from memory, returns wether decode was successful
    bool startDecoding(void[] data);
    uint getWidth();
    uint getHeight();
    void* getPixels();
    ubyte getBytesPerPixel();
    final ushort getBitsPerPixel(){return getBytesPerPixel()*8;}
    ///Dispose the pixels
    void dispose();
}

//In progress?
public interface IHipPNGDecoder  : IHipImageDecoder{}
public interface IHipJPEGDecoder : IHipImageDecoder{}
public interface IHipWebPDecoder : IHipImageDecoder{}
public interface IHipBMPDecoder  : IHipImageDecoder{}
public interface IHipAnyImageDecoder : IHipPNGDecoder, IHipJPEGDecoder, IHipWebPDecoder, IHipBMPDecoder{}
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
public class Image : HipAsset
{
    protected shared bool _ready;
    IHipImageDecoder decoder;
    string imagePath;
    uint width, height;
    ubyte bytesPerPixel;
    ushort bitsPerPixel;
    void* pixels;

    this(in string path)
    {
        super("Image_"~path);
        decoder = new HipPlatformImageDecoder();
        imagePath = sanitizePath(path);
    }


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
    override void onDispose(){decoder.dispose();}
    override void onFinishLoading(){}
    alias w = width;
    alias h = height;
}