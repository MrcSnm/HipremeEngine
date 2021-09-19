// D import file generated from 'source\view\paralleltestscene.d'
module view.paralleltestscene;
import hiprenderer;
import data.image;
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
		batch = new HipSpriteBatch;
		spr = new HipSprite("./assets/graphics/sprites/rex.png");
	}
	override void render();
}
