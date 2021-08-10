module graphics.image;
import util.concurrency;
import data.asset;
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
public class Image : HipAsset
{
    SDL_Surface* data;
    protected shared bool _ready;
    string imagePath;
    int rgbColorKey;

    shared this(in string path, int rgbColorKey = -1)
    {
        super("Image_"~path);
        if(rgbColorKey != -1)
            this.rgbColorKey = rgbColorKey;
        imagePath = sanitizePath(path);
    }
    this(in string path, int rgbColorKey = -1)
    {
        super("Image_"~path);
        if(rgbColorKey != -1)
            this.rgbColorKey = rgbColorKey;
        imagePath = sanitizePath(path);
    }
    
    mixin concurrent!(
    q{this(ubyte[] data, string path)
    {
        super("Image_"~path);
        imagePath = sanitizePath(path);
    }});

    mixin concurrent!(q{
    bool loadFromMemory(ref ubyte[] data)
    {
        SDL_RWops* rw = SDL_RWFromMem(data.ptr, cast(int)data.length);
        SDL_Surface* img = IMG_Load_RW(rw, 1); //Free SDL_RWops
        return setColorKey(img);
    }});

    mixin concurrent!(
    q{bool loadFromFile()
    {
        SDL_Surface* img = null;
        img = IMG_Load(toStringz(imagePath));
        return setColorKey(img);
    }});

    shared bool setColorKey(SDL_Surface* img)
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
    bool setColorKey(SDL_Surface* img)
    {
        ErrorHandler.assertErrorMessage(img != null, "Decoding Image: ", "Could not load image " ~ imagePath);
        if(img != null && rgbColorKey != -1)
            SDL_SetColorKey(img, SDL_TRUE, SDL_MapRGB(img.format,
            cast(ubyte)(rgbColorKey >> 16), //R
            cast(ubyte)((rgbColorKey >> 8) & 255), //G
            cast(ubyte)(rgbColorKey & 255))); //B
        data = img;
        return !ErrorHandler.stopListeningForErrors();
    }

    mixin concurrent!(
    q{override bool load()
    {
        _ready = loadFromFile();
        return _ready;
    }});

    mixin concurrent!(
    q{override bool isReady()
    {
        return _ready;
    }});



    mixin concurrent!(
    q{bool load(void function() onLoad)
    {
        bool ret = loadFromFile();
        if(ret)
            onLoad();
        return ret;
    }});

    override void onDispose()
    {
        if(data != null)
            SDL_FreeSurface(data);
        data = null;
    }

    override void onFinishLoading()
    {

    }
}