/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.tilemaptest;
import data.assetpacker;
import std.stdio;
import view.scene;
import data.assetpacker;
import def.debugging.log;
import implementations.renderer;
import graphics.g2d.tilemap;

class TilemapTestScene : Scene
{
    Tilemap map;
    this()
    {
        HapFile f = HapFile.get("gamepack.hap");
        rawlog(f.getChunksList());
        // (Tileset.fromTSX());
    }

    override void render()
    {
        HipRenderer.clear();

    }
}