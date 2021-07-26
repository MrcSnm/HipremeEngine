module view.paralleltestscene;
import data.assetmanager;
import view.scene;

class ParallelTestScene : Scene
{
    this()
    {
        HipAssetManager.loadImage("./assets/graphics/sprites/rex.png", true);
        
    }
    override void render()
    {
        HipAssetManager.checkLoad();
    }

}