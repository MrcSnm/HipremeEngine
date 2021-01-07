module graphics.texture;
import graphics.image;
import implementations.renderer.renderer;
import bindbc.sdl;

public class Texture
{
    SDL_Texture* data;
    int width, height;
    immutable string texturePath;
    private bool mHasLoaded;

    this(Image img)
    {
        if(img.data != null)
        {
            data = SDL_CreateTextureFromSurface(Renderer.renderer, img.data);
            width = img.data.w;
            height = img.data.h;
            texturePath = img.imagePath;
            mHasLoaded = true;
        }
    }

    this(string path, bool load = false)
    {
        texturePath = path;
        if(load)
            this.load();
    }

    bool load()
    {
        if(!mHasLoaded)
        {
            if(data != null)
            {
                SDL_QueryTexture(data, null, null, &width, &height);
                mHasLoaded = true;
                return true;
            }
            return false;
        }
        return true;
    }
    bool load(void function() onload)
    {
        if(load())
        {
            onload();
            return true;
        }
        return false;
    }

    void render(int x, int y)
    {
        Renderer.draw(this, x, y);
    }

    /**
    *   Let the engine call it for updating the resource state
    */
    void dispose()
    {
        SDL_DestroyTexture(this.data);
        data = null;
        width = 0;
        height = 0;
        mHasLoaded = false;
    }

    int getWidth(){return width;}
    bool isLoaded(){return mHasLoaded;}
    int getHeight(){return height;}
}