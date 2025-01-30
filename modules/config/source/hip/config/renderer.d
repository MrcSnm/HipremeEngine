/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.config.renderer;

version(Android) enum UseGLES = true;
else version(PSVita) enum UseGLES = true;
else version(WebAssembly) enum UseGLES = true;
else enum UseGLES = false;

version(OpenGL)  enum HasOpenGL = true;
else enum HasOpenGL = false;

version(AppleOS) enum HasMetal = true;
else enum HasMetal = false;

version(Direct3D_11) enum HasDirect3D = true;
else enum HasDirect3D = false;

version(PSVita) enum GLMaxOneBoundTexture = true;
else version(WebAssembly) enum GLMaxOneBoundTexture = true;
else enum GLMaxOneBoundTexture = false;




struct HipRendererConfig
{
    ///Use level 0 for pixel art games
    ubyte multisamplingLevel = 0;
    ///Single/Double/Triple buffering
    ubyte bufferingCount = 2;
    bool isMatrixRowMajor = true;
    bool fullscreen = false;
    bool vsync = true;
}