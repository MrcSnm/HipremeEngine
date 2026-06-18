module gamescript.entry;
import hip.game2d.sprite;
import hip.api;
import HRandom = hip.math.random:Random;
import hip.api;
import hip.assets.texture;

enum SPRITES_COUNT = 50_000;
enum MIN_SPEED = 200;
enum MAX_SPEED = 400;
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
	__gshared HipTexture texture;

	mixin Preload;
	
	/** Constructor */
	override void initialize()
	{
		// logg(getAssetsForPreload);
		sprites = new HipMultiSprite(SPRITES_COUNT);
		speeds = new float[SPRITES_COUNT];

		// logg(texture.getWidth);
		sprites.setTexture(texture);
		foreach(i; 0..SPRITES_COUNT)
		{
			sprites[i].y = HRandom.Random.range(0, SCREEN_H);
			speeds[i] = HRandom.Random.range(MIN_SPEED, MAX_SPEED);
		}

		auto sz = getMaxScreenSize();

		setWindowSize(SCREEN_W, SCREEN_H, true);
		setWindowSize(sz[0], sz[1], true);
		// logg(getMaxScreenSize());


	}
	/** Called every frame */
	override void update(float dt)
	{
		HipSprite[] sps = sprites.sprites;
		foreach(sp; 0..SPRITES_COUNT)
		{
			HipSprite s = sps.ptr[sp];
			if(s.x < SCREEN_W - s.width)
			{
				s.x+= speeds[sp] * dt;
			}
		}
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		// setRendererErrorCheckingEnabled(false);
		// sprites.draw();

		HipSprite[] sps = sprites.sprites;
		IHipTexture tex = sprites.texture;
		for(int i = 0; i < SPRITES_COUNT; i++)
		{
			HipSprite s = sps.ptr[i];
			drawTexture(tex, cast(int)s.x, cast(int)s.y);
		}
		// drawTexture(sprites.texture, cast(int)sprites[0].x, cast(int)sprites[0].y);
		// setRendererErrorCheckingEnabled(true);
	}
	/** Pre destroy */
	override void dispose()
	{
		speeds.length = 0;
		destroy(texture);
	}

	override void onResize(uint width, uint height)
	{
		setWindowSize(width, height, false);
	}
}

mixin HipEngineMain!MainScene;
	