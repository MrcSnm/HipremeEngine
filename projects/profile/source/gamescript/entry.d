module gamescript.entry;
import hip.game2d.sprite;
import hip.api.graphics.g2d.renderer2d;
import HRandom = hip.math.random:Random;
import hip.api;

enum SPRITES_COUNT = 100;
enum MIN_SPEED = 50;
enum MAX_SPEED = 150;
enum SCREEN_W = 800;
enum SCREEN_H = 600;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene
{
	HipMultiSprite sprites;
	float[] speeds;


	@Asset("graphics/ball.png")
	IHipTexture texture;

	mixin Preload;
	
	/** Constructor */
	override void initialize()
	{
		logg(getAssetsForPreload);
		sprites = new HipMultiSprite(SPRITES_COUNT);
		speeds = new float[SPRITES_COUNT];
		sprites.setTexture(texture);
		foreach(i; 0..SPRITES_COUNT)
		{
			sprites[i].y = HRandom.Random.range(0, SCREEN_H);
			speeds[i] = HRandom.Random.range(MIN_SPEED, MAX_SPEED);
		}

	}
	/** Called every frame */
	override void update(float dt)
	{
		foreach(i, sp; sprites)
		{
			if(sp.x < SCREEN_W - sp.width)
				sp.x+= speeds[i] * dt;
		}
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		setRendererErrorCheckingEnabled(false);
		sprites.draw();
		setRendererErrorCheckingEnabled(true);
	}
	/** Pre destroy */
	override void dispose()
	{
		speeds.length = 0;
		destroy(texture);
	}

	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	