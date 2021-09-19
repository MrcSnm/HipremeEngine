// D import file generated from 'source\view\animationtestscene.d'
module view.animationtestscene;
import view.scene;
import hiprenderer.viewport;
import hiprenderer.renderer;
import util.tween;
import graphics.g2d.animation;
import graphics.g2d.sprite;
import graphics.g2d.spritebatch;
class AnimationTestScene : Scene
{
	HipAnimation anim;
	HipSpriteBatch batch;
	HipSpriteAnimation spr;
	HipAnimationFrame frame;
	HipTween tween;
	this()
	{
		batch = new HipSpriteBatch;
		Texture t = new Texture("graphics/sprites/sprite.png");
		Array2D!TextureRegion sheet = TextureRegion.spritesheet(t, 32, 32, 96, 128, 0, 0, 0, 0);
		anim = new HipAnimation("Character");
		anim.addTrack((new HipAnimationTrack("walk_down", 12, true)).addFrames(HipAnimationFrame(sheet[0, 0]), HipAnimationFrame(sheet[0, 1]), HipAnimationFrame(sheet[0, 2]))).addTrack((new HipAnimationTrack("walk_left", 12, false)).addFrames(HipAnimationFrame(sheet[1, 0]), HipAnimationFrame(sheet[1, 1]), HipAnimationFrame(sheet[1, 2]))).addTrack((new HipAnimationTrack("walk_right", 12, true)).addFrames(HipAnimationFrame.fromTextureRegions(sheet, 2, 0, 2, 2))).addTrack((new HipAnimationTrack("walk_up", 12, false)).addFrames(HipAnimationFrame(sheet[3, 0]), HipAnimationFrame(sheet[3, 1]), HipAnimationFrame(sheet[3, 2])));
		spr = new HipSpriteAnimation(anim);
		spr.setAnimation("walk_right");
		tween = HipTween.to!(["x"])(15, spr, 400).play;
	}
	override void update(float dt);
	override void render();
}
