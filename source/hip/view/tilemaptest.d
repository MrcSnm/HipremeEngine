/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.view.tilemaptest;
import hip.data.assetpacker;
import hip.view.scene;
import hip.data.assetpacker;
import hip.console.log;
import hip.hiprenderer;
import hip.graphics.g2d.sprite;
import hip.graphics.g2d.tilemap;
import hip.graphics.g2d.spritebatch;

class TilemapTestScene : Scene
{
    Tilemap map;
    HipSpriteBatch batch;
    HipSprite spr;
    HipSprite sprite;
    HipSprite sprite2;
    this()
    {
        // HapFile f = HapFile.get("gamepack.hap");
        batch = new HipSpriteBatch();


        // map = Tilemap.readTiledTMX("maps/Test.tmx");
        spr = new HipSprite(map.tilesets[0].texture);
        sprite = new HipSprite("graphics/sprites/sprite.png");
        sprite2 = new HipSprite("graphics/sprites/shaun.png");
        // rawlog(map.layers["Camada de Tiles 1"].tiles);
        // rawlog(f.getChunksList());
        // (Tileset.fromTSX());
    }

    override void render()
    {
        import hip.util.time;
        HipRenderer.clear(255, 0, 0, 255);
        batch.begin();
        batch.draw(sprite);
        // batch.draw(sprite2);
        // map.render(batch);
        batch.end();
    }
}