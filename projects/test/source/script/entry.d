
module script.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene
{
	
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
		
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}

	void pushLayer(Layer l){}
	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	