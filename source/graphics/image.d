module graphics.image;

import error.handler;
import bindbc.sdl;
import util.system;


/**
*   This class represents pixel data on RAM (CPU Powered)
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

    bool load()
    {
        SDL_Surface* img = null;
        img = IMG_Load(imagePath.ptr);
        ErrorHandler.assertErrorMessage(img != null, "Loading Image: ", "Could not load image " ~ imagePath);
        if(img != null && rgbColorKey != -1)
            SDL_SetColorKey(img, SDL_TRUE, SDL_MapRGB(img.format,
            cast(ubyte)(rgbColorKey >> 16), //R
            cast(ubyte)((rgbColorKey >> 8) & 255), //G
            cast(ubyte)(rgbColorKey & 255))); //B
        data = img;
        return img!=null;
    }

    bool load(void function() onLoad)
    {
        bool ret = load();
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