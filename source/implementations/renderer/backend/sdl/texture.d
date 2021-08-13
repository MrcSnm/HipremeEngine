/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

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