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
import view.scene;
import data.assetpacker;
import console.log;
import hiprenderer;
import graphics.g2d.tilemap;
import graphics.g2d.spritebatch;

class TilemapTestScene : Scene
{
    Tilemap map;
    HipSpriteBatch batch;
    this()
    {
        HapFile f = HapFile.get("gamepack.hap");
        batch = new HipSpriteBatch();


        map = Tilemap.readTiledTMX("maps/minitest.tmx");
        rawlog(map.layers["Camada de Tiles 1"].tiles);
        // rawlog(f.getChunksList());
        // (Tileset.fromTSX());
    }

    override void render()
    {
        HipRenderer.clear();
        batch.begin();

        map.render(batch);
        batch.end();
    }
}