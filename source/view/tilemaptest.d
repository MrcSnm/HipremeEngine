module view.tilemaptest;
import std.stdio;
import view.scene;
import data.assetpacker;
import def.debugging.log;
import implementations.renderer;
import implementations.renderer.tilemap;

class TilemapTestScene : Scene
{
    Tilemap map;
    this()
    {
        // (Tileset.fromTSX());
    }

    override void render()
    {
        HipRenderer.clear();

    }
}