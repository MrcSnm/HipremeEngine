module data.image;
import sdl.loader;
import std.algorithm:countUntil;
import std.string:toStringz;
import util.system;
import error.handler;

public static class ResourceManager
{
    public static SDL_Surface*[string] loadedImages = null;
    public static SDL_Texture*[string] loadedTextures = null;

    /**
    *   This function can receive an optional color key
    */
    public static bool loadTexture(string textureName, int rgbColorKey = -1)
    {   
        SDL_Texture* texture = null;
        textureName = sanitizePath(textureName);
        if((textureName in ResourceManager.loadedImages) == null)
        {
            SDL_Surface* img = null;
            img = IMG_Load(textureName.toStringz);
            if(rgbColorKey > -1)
            {
                SDL_SetColorKey(img, SDL_TRUE, SDL_MapRGB(img.format,
                cast(ubyte)(rgbColorKey >> 16), //R
                cast(ubyte)((rgbColorKey >> 8) & 255), //G
                cast(ubyte)(rgbColorKey & 255))); //B
            }
            ErrorHandler.assertErrorMessage(img != null, "Loading Texture: ", "Could not load texture " ~ textureName);
            texture = SDL_CreateTextureFromSurface(HipRenderer.renderer, img);
            ErrorHandler.assertErrorMessage(texture != null, "Loading Texture: ", "Could not create texture from pixel data from: " ~ textureName);
            ResourceManager.loadedTextures[textureName] = texture;
            SDL_FreeSurface(img);
            return true;
        }
        return false;
    }

    public static SDL_Texture* getTexture(string textureName)
    {
        return *(sanitizePath(textureName) in ResourceManager.loadedTextures);
    }


    public static void disposeResources()
    {
        foreach(ref image; loadedImages)
        {
            SDL_FreeSurface(image);
            image = null;
        }
        foreach(ref texture; loadedTextures)
        {
            SDL_DestroyTexture(texture);
            texture = null;
        }
    }
}
public:

SDL_Surface* getImage(string imageName)
{
    imageName = sanitizePath(imageName);
    if((imageName in ResourceManager.loadedImages) == null)
        return null;
    return ResourceManager.loadedImages[imageName];
}

bool loadImage(string imageName)
{   
    imageName = sanitizePath(imageName);
    if((imageName in ResourceManager.loadedImages) == null)
    {
        SDL_Surface* img = null;
        img = IMG_Load(imageName.ptr);
        ErrorHandler.assertErrorMessage(img != null, "Loading Image: ", "Could not load image " ~ imageName);
        ResourceManager.loadedImages[imageName] = img;
        return true;
    }
    return false;
}