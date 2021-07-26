module view.paralleltestscene;
import data.assetpacker;
import data.assetmanager;
import view.scene;

class ParallelTestScene : Scene
{
    this()
    {
        // HipAssetManager.loadImage("./assets/graphics/sprites/rex.png", true);

        updateAssetInPack("gamepack.hap", 
        [
            "assets/audio/active_matrix_edited.wav",
            "assets/audio/junkyard-a-class.mp3",
            "assets/audio/the-sound-of-silence.wav",
            "nodub.sh",
        ]);
        
        
    }
    override void render()
    {
        HipAssetManager.checkLoad();
    }

}