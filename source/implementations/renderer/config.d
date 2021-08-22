/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.renderer.config;

struct HipRendererConfig
{
    ///Use level 0 for pixel art games
    ubyte multisamplingLevel = 0;
    ///Single/Double/Triple buffering
    ubyte bufferingCount = 2;
    bool isMatrixRowMajor = true;
    bool vsync = true;
}