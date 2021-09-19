// D import file generated from 'source\view\spritetestscene.d'
module view.spritetestscene;
import bindbc.sdl;
import hiprenderer.backend.gl.renderer;
import hiprenderer.shader;
import graphics.g2d;
import hiprenderer.renderer;
import view.scene;
class SpriteTestScene : Scene
{
	HipSpriteBatch batch;
	HipSprite sprite;
	this()
	{
		import console.log;
		batch = new HipSpriteBatch;
		import data.hipfs;
		string output;
		sprite = new HipSprite("graphics/sprites/sprite.png");
	}
	public override void render();
	public override void onResize(uint width, uint height);
}
