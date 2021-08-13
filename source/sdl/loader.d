/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

/**
*   Module responsibly for loading dynamic link libraries
*/
module sdl.loader;
public:
    import bindbc.sdl;
    import bindbc.sdl.image;
    import implementations.audio.audio;
    import implementations.renderer.renderer;
    import bindbc.sdl.ttf;
    import sdl.sdl_sound;
    import std.system;
private 
{
    import std.stdio;
    import error.handler;
    import std.conv : to;
    import global.consts;
}

version(Android){immutable string CURRENT_SDL_VERSION = "SDL_2_0_12";}
else version(Windows){immutable string CURRENT_SDL_VERSION = "SDL_2_0_10";}
else version(linux){immutable string CURRENT_SDL_VERSION = "SDL_2_0_8";}
/** 
 * This function will load SDL Dependencies
 * Returns: HAS_ANY_ERROR_HAPPENNED
 */
version(BindSDL_Static){}
else
{
    bool loadSDLLibs(bool audio3D)
    {
        version(Android){return false;}
        else
        {
            SDLSupport ret = loadSDL();
            ErrorHandler.startListeningForErrors("Loading SDL Libraries");
            string errorHeader;
            string errorMessage; 
            string filetype;
            switch(os)
            {
                case os.win32:
                case os.win64:
                    errorHeader = "Missing DLL";
                    errorMessage = "Missing DLL 'SDL2.dll'\nVersion ";
                    filetype = ".dll";
                    break;
                default:
                    errorHeader = "Missing Library";
                    errorMessage = "Library 'libsdl2.so'\nVersion ";
                    filetype = ".so";
            }
            if(ret != sdlSupport)
            {
                if(ret == SDLSupport.noLibrary)
                    ErrorHandler.showErrorMessage(errorHeader, errorMessage ~ CURRENT_SDL_VERSION);
                else if(ret == SDLSupport.badLibrary)
                    ErrorHandler.showErrorMessage("Lower " ~ filetype ~ " version ", "Your " ~ filetype ~ " version is lower than the version expected " ~ CURRENT_SDL_VERSION);
            }
            //Load image loading support
            ErrorHandler.assertErrorMessage(loadSDLImage() == sdlImageSupport, "Could not load library", "SDL Image library hasn't been able to load");
            int imgFlags = IMG_INIT_PNG | IMG_INIT_TIF | IMG_INIT_JPG;
            ErrorHandler.assertErrorMessage((IMG_Init(imgFlags) & imgFlags) > 0, "Could not initialize library",  "SDL Image library could not initialize");
            //Load Audio support
            Audio.initialize(audio3D);
            //Load Font support
            // ErrorHandler.assertErrorMessage(loadSDLTTF() == sdlTTFSupport, "Could not load library", "SDL TTF library hasn't been able to load");
            ErrorHandler.assertErrorMessage(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) == 0, "SDL Initialization",  "SDL could not initialize\nSDL Error: " ~ to!string(SDL_GetError()));

            Sound_Init();
            return ErrorHandler.stopListeningForErrors();
        }
    }
}