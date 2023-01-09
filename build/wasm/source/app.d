module source.app;
import hip.console.console;
import hip.filesystem.hipfs;
import hip.console.log;
import hip.error.handler;
import hip.systems.game;
import hip.hiprenderer.renderer;
import hip.global.gamedef;


/**
* Build:
* dub build --build=plain --skip-registry=all --arch=wasm32-unknown-unknown-wasm
*/

enum float FRAME_TIME = 1000/60; //60 frames per second
void main()
{
	import hip.util.time;
	HipTime.initialize();
	Console.install(Platforms.WASM);
	HipFS.install("./");
	HipRenderer.initExternal(HipRendererType.GL3, 800, 600);
	//Initialize 2D context
	import hip.graphics.g2d;
	if(!loadDefaultAssets())
		loglnError("Could not load default assets!");
	HipRenderer2D.initialize();
	sys = new GameSystem(FRAME_TIME);
}

export extern(C) void HipremeRender()
{
	HipRenderer.setColor(0,0,0,255);
	HipRenderer.clear();
	// sys.render();
	// import hip.api;
	// drawTexture(null, 100, 100);
	// renderSprites();
	// renderGeometries();
}

export extern(C) bool HipremeUpdate(float dt)
{
	dt/= 1000; //To seconds. Javascript gives in MS.
	import hip.api;
	sys.update(dt);
	import std.stdio;
	if(HipInput.isKeyPressed(HipKey.SPACE))
	{
		r+= + 1*dt;
		if(r > 1.0) r = 0;
	}
	sys.postUpdate();
	return false;
}