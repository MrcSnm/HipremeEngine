
module gamescript.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
	mixin Preload;

	immutable int[2] WorldSize = [1280, 720];
	
	/** Constructor */
	override void initialize()
	{
		
		setWindowTitle("Hipreme Engine Test");
		setWorldSize(WorldSize[0], WorldSize[1]);
		setFont(HipDefaultAssets.getDefaultFontWithSize(62));
	
	}
	/** Called every frame */
	override void update(float dt)
	{
		
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		
		drawText("You can start using the D Scripting API Here!", 0, 0, 2.0, HipColor.white,
			HipTextAlign.center, Size(WorldSize[0], WorldSize[1]), true
		);
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}
	override void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	