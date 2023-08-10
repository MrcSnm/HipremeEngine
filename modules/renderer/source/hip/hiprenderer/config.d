/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.config;

version(Android) enum UseGLES = true;
else version(PSVita) enum UseGLES = true;
else version(WebAssembly) enum UseGLES = true;
else enum UseGLES = false;

version(OpenGL)
{
    version(Android){}
    else version(PSVita){}
    else version(WebAssembly){}
    else version(Have_bindbc_opengl){}
    else static assert(false, "Tried to use OpenGL, but supplied no platform or library containing OpenGL.");
}


struct HipRendererConfig
{
    ///Use level 0 for pixel art games
    ubyte multisamplingLevel = 0;
    ///Single/Double/Triple buffering
    ubyte bufferingCount = 2;
    bool isMatrixRowMajor = true;
    bool fullscreen = false;
    bool vsync = true;


    void logConfiguration()
    {
        import hip.console.log;
        loglnInfo("Starting HipRenderer with configuration: ",
        "\nMultisamplingLevel: ", multisamplingLevel,
        "\nBufferingCount: ", bufferingCount,
        "\nFullscreen: ", fullscreen,
        "\nVsync: ", vsync? "activated" : "deactivated");
    }
}