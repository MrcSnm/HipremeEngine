/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.bind.dependencies;
import hip.error.handler;
import bindbc.loader : SharedLib;


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

bool loadEngineDependencies()
{
    ErrorHandler.startListeningForErrors("Loading Shared Libraries");

    void function(SharedLib) implementation = null;

    version(HipremeEngineLua)
    {
        import bindbc.lua;
        LuaSupport l = loadLua();
        if(l != luaSupport)
        {
            // ErrorHandler.assertExit(l != luaSupport.noLibrary, "Could not find any lua library");
            // ErrorHandler.showErrorMessage("Bad Lua Library", "Unknown lua version found");
        }
    }


    version(CIMGUI)
    {
        import bindbc.cimgui;
        static if(!CIMGUI_USER_DEFINED_IMPLEMENTATION)
            implementation = &bindSDLImgui;

        if(!loadcimgui(implementation))
        {
            ErrorHandler.showErrorMessage("Could not load cimgui", "Cimgui.dll not found");
        }
    }

    return ErrorHandler.stopListeningForErrors();
}