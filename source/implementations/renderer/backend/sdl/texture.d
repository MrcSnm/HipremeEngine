module implementations.renderer.backend.sdl.texture;
import implementations.renderer.renderer;
import implementations.renderer.texture;

import graphics.image;
import bindbc.sdl;

public class Hip_SDL_Texture : ITexture
{
    SDL_Texture* data;
    
    public void setWrapMode(TextureWrapMode mode){}
    public void bind(){}
    public bool load(SDL_Surface* surface)
    {
        data = SDL_CreateTextureFromSurface(HipRenderer.renderer, surface);
        return true;
    }
    void setTextureFilter(TextureFilter mag, TextureFilter min){}

    /**
    *   Let the engine call it for updating the resource state
    */
    void dispose()
    {
        SDL_DestroyTexture(this.data);
        data = null;
    }
}