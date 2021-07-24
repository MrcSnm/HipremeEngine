module view.tilemaptest;
import view.scene;
import def.debugging.log;
import implementations.renderer;
import implementations.renderer.tilemap;

class TilemapTestScene : Scene
{
    Tilemap map;
    this()
    {
        (Tileset.fromTSX("./source/view/wateranimate2.tsx"));
    }

    override void render()
    {
        HipRenderer.clear();

    }
}