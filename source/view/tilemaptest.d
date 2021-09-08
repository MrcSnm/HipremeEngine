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
import graphics.g2d.sprite;
import graphics.g2d.tilemap;
import graphics.g2d.spritebatch;

class TilemapTestScene : Scene
{
    Tilemap map;
    HipSpriteBatch batch;
    HipSprite spr;
    this()
    {
        // HapFile f = HapFile.get("gamepack.hap");
        batch = new HipSpriteBatch();


        map = Tilemap.readTiledTMX("maps/Test.tmx");
        spr = new HipSprite(map.tilesets[0].texture);
        // rawlog(map.layers["Camada de Tiles 1"].tiles);
        // rawlog(f.getChunksList());
        // (Tileset.fromTSX());
    }

    override void render()
    {
        import util.time;

        HipRenderer.clear();
        batch.begin();
        // batch.draw(spr);
        HipTime.initPerformanceMeasurement("Tilemap Rendering");
        map.render(batch);
        HipTime.finishPerformanceMeasurement("Tilemap Rendering");
        batch.end();
    }
}