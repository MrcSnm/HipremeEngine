// D import file generated from 'source\view\bitmaptestscene.d'
module view.bitmaptestscene;
import graphics.g2d.tilemap;
import sdl.event.handlers.input.keyboard_layout;
import hiprenderer;
import graphics.g2d;
import graphics.mesh;
import sdl.event.handlers.keyboard;
import console.log;
import view.scene;
class BitmapTestScene : Scene
{
	HipBitmapText txt;
	static KeyboardLayout abnt2;
	this()
	{
		txt = new HipBitmapText;
		abnt2 = new KeyboardLayoutABNT2;
		txt.setBitmapFont(HipBitmapFont.fromFile("assets/fonts/arial.fnt"));
		txt.x = HipRenderer.width / 2;
		txt.alignh = HipTextAlign.CENTER;
	}
	override void render();
}
