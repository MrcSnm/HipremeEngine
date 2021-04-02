module graphics.texture;
import graphics.image;
import implementations.renderer.renderer;
import bindbc.sdl;

public class Texture
{
    SDL_Texture* data;
    int width, height;
    immutable string texturePath;
    private bool mIsLoaded;
    
    this(string path, bool load = false)
    {
        import util.system;
        texturePath = sanitizePath(path);
        if(load)
            loadFromFile();
    }

    this(Image img)
    {
       loadFromImage(img);
       texturePath = img.imagePath;
    }

    /**
    *   Loads a texture into the GPU from RAM 
    */ 
    void loadFromImage(Image img)
    {
        if(img.data != null)
        {
            data = SDL_CreateTextureFromSurface(Renderer.renderer, img.data);
            width = img.data.w;
            height = img.data.h;
            mIsLoaded = true;
        }
    }

    SDL_Rect getBounds()
    {
        return SDL_Rect(0,0,width,height);
    }


    bool loadFromFile()
    {
        if(data != null)
            dispose();
        Image img = new Image(texturePath);
        if(img.load())
        {
            this.loadFromImage(img);
            return true;
        }
        return false;
    }
    bool loadFromFile(void function() onload)
    {
        if(loadFromFile())
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
        mIsLoaded = false;
    }

    bool isLoaded(){return mIsLoaded;}
}