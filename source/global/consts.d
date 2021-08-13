/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module global.consts;
private:
    import sdl.loader;

public:
    immutable static enum ENGINE_NAME = "Hipreme Engine";
    static int SCREEN_WIDTH = 800;
    static int SCREEN_HEIGHT = 600;
    static SDL_Window* gWindow = null;
    enum HIP_DEBUG = true;
    enum HIP_OPTIMIZE = false;
    static SDL_Surface* gScreenSurface = null;

