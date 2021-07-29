module view.paralleltestscene;
import implementations.renderer;
import std.stdio;
import graphics.image;
import data.assetpacker;
import data.assetmanager;
import view.scene;

class ParallelTestScene : Scene
{
    HipSpriteBatch batch;
    HipSprite spr;
    this()
    {
        batch = new HipSpriteBatch();
        spr = new HipSprite("./assets/graphics/sprites/rex.png");

        // HipAssetMnager.loadImage("./assets/graphics/sprites/rex.png", (Image img)
        // {
        //     img.writeln;
        // }, true);
        
    }
    override void render()
    {
        HipAssetManager.checkLoad();
        batch.begin();
        if(spr.texture.img !is null)
        {
            batch.draw(spr);
            spr.getVertices().writeln;
        }
        else
            "Vei".writeln;
        batch.end();
    }

}