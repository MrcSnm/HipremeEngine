module graphics.texture;
import implementations.renderer.renderer;
import bindbc.sdl;

public class Texture
{
    SDL_Texture* texture;
    int width, height;
    immutable string texturePath;
    private bool mHasLoaded;

    this(string path)
    {
        texturePath = path;
    }

    bool load()
    {
        if(!mHasLoaded)
        {
            if(texture != null)
            {
                SDL_QueryTexture(texture, null, null, &width, &height);
                mHasLoaded = true;
                return true;
            }
            return false;
        }
        else
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
        SDL_DestroyTexture(this.texture);
        texture = null;
    }

    int getWidth(){return width;}
    bool isLoaded(){return mHasLoaded;}
    int getHeight(){return height;}
}