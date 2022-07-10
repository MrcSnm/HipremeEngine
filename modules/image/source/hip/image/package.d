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
public import hip.hipengine.api.data.image;


IHipBMPDecoder bmp;
IHipJPEGDecoder jpeg;
IHipPNGDecoder png;
IHipWebPDecoder webP;


version(HipSDLImage)
final class HipSDLImageDecoder : IHipAnyImageDecoder
{
    import bindbc.sdl.bind.sdlsurface;
    import bindbc.sdl.bind.sdlrwops;
    import bindbc.sdl.bind.sdlpixels;
    import bindbc.sdl.image;
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

    uint getWidth()
    {
        if(img !is null)
            return img.width;
        return 0;
    }

    uint getHeight()
    {
        if(img !is null)
            return img.height;
        return 0;
    }

    void* getPixels()
    {
        if(img !is null)
            return trueImg.imageData.bytes.ptr;
        return null;
    }

    ubyte getBytesPerPixel()
    {
        //Every true image color has 4 bytes per pixel
        return 4;
    }

    ubyte[] getPalette()
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
    uint getWidth(){return 0;}
    uint getHeight(){return 0;}
    void* getPixels(){return null;}
    ubyte getBytesPerPixel(){return 0;}
    ubyte[] getPalette(){return null;}
    void dispose(){}
}

///Use that alias for supporting more platforms
version(HipSDLImageDecoder)
    alias HipPlatformImageDecoder = HipSDLImageDecoder;
else version(HipARSDImageDecoder)
    alias HipPlatformImageDecoder = HipARSDImageDecoder;
else
{
    alias HipPlatformImageDecoder = HipNullImageDecoder;
    pragma(msg, "WARNING: Using NullImageDecoder.");
}
