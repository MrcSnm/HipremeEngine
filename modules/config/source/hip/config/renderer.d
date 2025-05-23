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
else version(Android) enum GLMaxOneBoundTexture = true;
else enum GLMaxOneBoundTexture = false;


/**
 * HipRenderer implements a delayed unbinding. That means it will only unbind a resource when trying to bind
 * another resource
 * This works for both OpenGL and Direct3D 11.
 * But does not work for metal, since the render pipeline state can't be reused between frames.
 */
enum UseDelayedUnbinding = !HasMetal;

/**
 * This can provide a reduced memory usage for sprites which can also be a big win for other platforms. You may increase that amount but can't surpass index_t.max / 4
 */
enum DefaultMaxSpritesPerBatch = 1024;
// enum DefaultMaxSpritesPerBatch = 10922;
// enum DefaultMaxGeometryBatchVertices = ushort.max;
enum DefaultMaxGeometryBatchVertices = 8_192;




/**
 * On WebGL, there's not much point in disabling them.
 */
version(WebAssembly) enum GLShouldDisableVertexAttrib = false;
else enum GLShouldDisableVertexAttrib = true;

enum GLMaxVertexAttributes = 64;




pragma(LDC_no_typeinfo)
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