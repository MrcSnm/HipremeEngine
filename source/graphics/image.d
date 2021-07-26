module graphics.image;

import error.handler;
import bindbc.sdl;
import util.system;
import std.string;
import def.debugging.log;
import std.stdio;


/**
*   This class represents pixel data on RAM (CPU Powered)
*   this is useful for loading images on another thread and then
*   sending it to the GPU
*/
public class Image
{
    SDL_Surface* data;
    string imagePath;
    int rgbColorKey;

    this(string path, int rgbColorKey = -1)
    {
        if(rgbColorKey != -1)
            this.rgbColorKey = rgbColorKey;
        imagePath = sanitizePath(path);
    }
    
    this(ubyte[] data, string path)
    {
        imagePath = sanitizePath(path);
    }

    shared bool loadFromMemory(ref ubyte[] data)
    {
        SDL_RWops* rw = SDL_RWFromMem(data.ptr, cast(int)data.length);
        SDL_Surface* img = IMG_Load_RW(rw, 1); //Free SDL_RWops
        return setColorKey(img, this.imagePath);
    }

    shared bool loadFromFile()
    {
        SDL_Surface* img = null;
        img = IMG_Load(toStringz(imagePath));
        return setColorKey(img, imagePath);
    }

    protected shared bool setColorKey(SDL_Surface* img, string imagePath)
    {
        ErrorHandler.assertErrorMessage(img != null, "Decoding Image: ", "Could not load image " ~ imagePath);
        if(img != null && rgbColorKey != -1)
            SDL_SetColorKey(img, SDL_TRUE, SDL_MapRGB(img.format,
            cast(ubyte)(rgbColorKey >> 16), //R
            cast(ubyte)((rgbColorKey >> 8) & 255), //G
            cast(ubyte)(rgbColorKey & 255))); //B
        data = cast(shared)img;
        return !ErrorHandler.stopListeningForErrors();
    }


    shared bool load(void function() onLoad)
    {
        bool ret = loadFromFile();
        if(ret)
            onLoad();
        return ret;
    }

    void dispose()
    {
        if(data != null)
            SDL_FreeSurface(data);
        data = null;
    }
}