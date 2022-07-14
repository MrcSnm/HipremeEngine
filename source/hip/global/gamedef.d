/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.global.gamedef;
import hip.systems.game;
import hip.event.handlers.inputmap;

public:
    immutable static enum ENGINE_NAME = "Hipreme Engine";
    static int SCREEN_WIDTH = 800;
    static int SCREEN_HEIGHT = 600;
    ///Globally shared for accessing it on Android Game Thread
   __gshared GameSystem sys;
   __gshared float g_deltaTime = 0;
   __gshared HipInputMap map;




float getDisplayDPI(uint displayIndex = 0)
{
   float diagonalDPI;
   float verticalDPI;
   float horizontalDPI;
   // SDL_GetDisplayDPI(displayIndex, &diagonalDPI, &horizontalDPI, &verticalDPI);

   return horizontalDPI;
}