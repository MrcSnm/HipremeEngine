module data.image;
import sdl.loader;
import std.system, std.array : replace;
import error.handler;

public static class ResourceManager
{
    public static SDL_Surface*[string] loadedImages = null;

    public static void disposeResources()
    {
        foreach(image; loadedImages)
        {
            SDL_FreeSurface(image);
            image = null;
        }
    }
}
private:
string sanitizePath(string path)
{
    switch(os)
    {
        case os.win32:
        case os.win64:
            return replace(path, "/", "\\");
        default:
            return replace(path, "\\", "/");
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
        img = SDL_LoadBMP(cast(char*)imageName);
        ErrorHandler.assertErrorMessage(img == null, "Loading Image: ", "Could not load image " ~ imageName);
        ResourceManager.loadedImages[imageName] = img;
        return true;
    }
    return false;
}
