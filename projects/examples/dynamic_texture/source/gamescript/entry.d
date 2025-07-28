
module gamescript.entry;
import hip.api;
import hip.assets.texture;
import hip.assets.image;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
	mixin Preload;
	HipTexture tex;

	/** Constructor */
	override void initialize()
	{
		Image img = new Image(256, 256, 1);
		for(int i = 0; i < 256; i++)
		{
			for(int x = 0; x < 256; x++)
			{
				size_t idx = i*256+x;
				img.pixels[idx] = i < 50 ? 0xff : 0;
			}
		}
		tex = new HipTexture(img, HipResourceUsage.Dynamic);

		for(int y = 50; y < 100; y++)
		{
			for(int x = 0; x < 256; x++)
			{
				size_t idx = y*256+x;
				img.pixels[idx] = 0x44;
			}
		}
		tex.updatePixels(0, 50, 256, 50, img.pixels[50*256..$]);

	}
	/** Called every frame */
	override void update(float dt)
	{

	}
	/** Renderer only, may not be called every frame */
	override void render()
	{

		drawText("You can start using the D Scripting API Here!", 400, 300, 2.0, HipColor.white,
			HipTextAlign.center
		);

		drawTexture(tex, 200, 200);

	}
	/** Pre destroy */
	override void dispose()
	{

	}
	override void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
