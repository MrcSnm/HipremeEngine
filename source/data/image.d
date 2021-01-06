module data.image;
import sdl.loader;
import std.system, std.array : replace;
import error.handler;

public static class ResourceManager
{
    private static SDL_Renderer* renderer;
    public static SDL_Surface*[string] loadedImages = null;
    public static SDL_Texture*[string] loadedTextures = null;

    public static bool init(SDL_Renderer* renderer)
    {
        ResourceManager.renderer = renderer;
        int imgFlags = IMG_INIT_PNG | IMG_INIT_TIF | IMG_INIT_JPG | IMG_INIT_WEBP;
        if(!(IMG_Init(imgFlags) & imgFlags))
        {
            return false;
        }
        return true;
    }

    public static bool loadTexture(string textureName)
    {   
        SDL_Texture* texture = null;
        textureName = sanitizePath(textureName);
        if((textureName in ResourceManager.loadedImages) == null)
        {
            SDL_Surface* img = null;
            img = IMG_Load(textureName.ptr);
            
            texture = SDL_CreateTextureFromSurface(renderer, img);
            ErrorHandler.assertErrorMessage(texture != null, "Loading Texture: ", "Could not load texture " ~ textureName);
            ResourceManager.loadedTextures[textureName] = texture;
            return true;
        }
        return false;
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
        img = SDL_LoadBMP(imageName.ptr);
        ErrorHandler.assertErrorMessage(img != null, "Loading Image: ", "Could not load image " ~ imageName);
        ResourceManager.loadedImages[imageName] = img;
        return true;
    }
    return false;
}

SDL_Texture* getTexture(string textureName)
{

}