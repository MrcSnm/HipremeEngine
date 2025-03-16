
module gamescript.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
	mixin Preload;

	/** Constructor */
	override void initialize()
	{
		
	
	}
	/** Called every frame */
	override void update(float dt)
	{
		
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		drawText("Top Left", 0, 0, 1.0, HipColor.white, HipTextAlign.topLeft);
		drawText("Top Center", 400, 0, 1.0, HipColor.white, HipTextAlign.topCenter);
		drawText("Top Right", 800, 0, 1.0, HipColor.white, HipTextAlign.topRight);


		drawText("Bot Left", 0, 600, 1.0, HipColor.white, HipTextAlign.botLeft);
		drawText("Bot Center", 400, 600, 1.0, HipColor.white, HipTextAlign.botCenter);
		drawText("Bot Right", 800, 600, 1.0, HipColor.white, HipTextAlign.botRight);

		
		drawText("You can start using the D Scripting API Here!", 400, 300, 2.0, HipColor.white,
			HipTextAlign.center
		);
	
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}
	override void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	