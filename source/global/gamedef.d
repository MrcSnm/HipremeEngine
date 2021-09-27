/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module global.gamedef;
import systems.game;
import bindbc.sdl;

public:
    immutable static enum ENGINE_NAME = "Hipreme Engine";
    static int SCREEN_WIDTH = 800;
    static int SCREEN_HEIGHT = 600;
    static SDL_Window* gWindow = null;
    static SDL_Surface* gScreenSurface = null;
    ///Globally shared for accessing it on Android Game Thread
   __gshared GameSystem sys;
   __gshared float g_deltaTime = 0;



float getDisplayDPI(uint displayIndex = 0)
{
   float diagonalDPI;
   float verticalDPI;
   float horizontalDPI;
   SDL_GetDisplayDPI(displayIndex, &diagonalDPI, &horizontalDPI, &verticalDPI);

   return horizontalDPI;
}