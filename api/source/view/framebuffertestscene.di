// D import file generated from 'source\view\framebuffertestscene.d'
module view.framebuffertestscene;
import view.scene;
import console.log;
import graphics.g2d;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
class FrameBufferTestScene : Scene
{
	HipFrameBuffer fb;
	HipSpriteBatch batch;
	HipSprite sp;
	this()
	{
		batch = new HipSpriteBatch;
		sp = new HipSprite("graphics/sprites/sprite.png");
		fb = HipRenderer.newFrameBuffer(800, 600);
	}
	override void render();
}
