/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module bind.dependencies;
import error.handler;
import std.conv:to;
import bindbc.cimgui;
import bindbc.sdl;
import bindbc.sdl.ttf;
import bindbc.sdl.image;
import bindbc.loader : SharedLib;
import implementations.imgui.imgui_impl_sdl;


version(Android){immutable string CURRENT_SDL_VERSION = "SDL_2_0_12";}
else version(Windows){immutable string CURRENT_SDL_VERSION = "SDL_2_0_10";}
else version(linux){immutable string CURRENT_SDL_VERSION = "SDL_2_0_8";}

private void showDLLMissingError(string dllName)
{
    version(Windows)
        ErrorHandler.showErrorMessage("Missing DLL Error", dllName~".dll is missing");
    else
        ErrorHandler.showErrorMessage("Missing Shared Library Error lib", dllName~".so is missing");
}

private bool loadSDLDependencies()
{
    SDLSupport ret = loadSDL();
    if(ret != sdlSupport)
    {
        if(ret == SDLSupport.noLibrary)
        {
            showDLLMissingError("SDL2");
            return false;
        }
        else if(ret == SDLSupport.badLibrary)
            ErrorHandler.showErrorMessage("SDL2 missing symbols", "Your SDL2 library version is missing some symbols.
Crashes may happen");
    }
    if(ErrorHandler.assertErrorMessage(loadSDLImage() == sdlImageSupport, "Could not load library", "SDL Image library hasn't been able to load"))
        return false;
    int imgFlags = IMG_INIT_PNG | IMG_INIT_TIF | IMG_INIT_JPG | IMG_INIT_WEBP;
    if(ErrorHandler.assertErrorMessage((IMG_Init(imgFlags) & imgFlags) > 0, "Could not initialize library",  "SDL Image library could not initialize"))
        return false;
    //Load Audio support

    //Load Font support
    // ErrorHandler.assertErrorMessage(loadSDLTTF() == sdlTTFSupport, "Could not load library", "SDL TTF library hasn't been able to load");
    if(ErrorHandler.assertErrorMessage(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) == 0, "SDL Initialization",  "SDL could not initialize\nSDL Error: " ~ to!string(SDL_GetError())))
        return false;
    return true;


}

bool loadEngineDependencies()
{
    ErrorHandler.startListeningForErrors("Loading Shared Libraries");

    if(!loadSDLDependencies())
        ErrorHandler.showErrorMessage("SDL2 Loading error", "Could not load all SDL2 dependencies");

    void function(SharedLib) implementation = null;
    static if(!CIMGUI_USER_DEFINED_IMPLEMENTATION)
        implementation = &bindSDLImgui;

    if(!loadcimgui(implementation))
    {
        ErrorHandler.showErrorMessage("Could not load cimgui", "Cimgui.dll not found");
    }

    return ErrorHandler.stopListeningForErrors();
}