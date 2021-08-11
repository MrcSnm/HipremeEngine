module view.paralleltestscene;
import implementations.renderer;
import std.stdio;
import graphics.image;
import graphics.g2d;
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
        
        // }, true);
        
    }
    override void render()
    {
        HipAssetManager.checkLoad();
        batch.begin();
        if(spr.texture.img !is null)
        {
            batch.draw(spr);
        }
        batch.end();
    }

}