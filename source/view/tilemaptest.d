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