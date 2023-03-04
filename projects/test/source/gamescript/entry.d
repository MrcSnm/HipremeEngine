
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
		
		setFont(HipDefaultAssets.getDefaultFontWithSize(62));
	
	}
	/** Called every frame */
	override void update(float dt)
	{
		
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		
		drawText("You can start using the D Scripting API Here!", 400, 300, HipColor.white, 
			HipTextAlign.CENTER,  HipTextAlign.CENTER
		);
		renderTexts();
	
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}
	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	