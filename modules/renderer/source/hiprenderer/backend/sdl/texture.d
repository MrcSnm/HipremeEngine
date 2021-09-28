/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hiprenderer.backend.sdl.texture;
import hiprenderer.renderer;
import hiprenderer.texture;

import data.image;
import bindbc.sdl;

public class Hip_SDL_Texture : ITexture
{
    SDL_Texture* data;
    
    public void setWrapMode(TextureWrapMode mode){}
    public void bind(){}
    public void unbind(){}
    public void bind(int slot){}
    public void unbind(int slot){}
    public bool load(IImage img)
    {
        // SDL_Surface* surface = img;
        // data = SDL_CreateTextureFromSurface(HipRenderer.renderer, surface);
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