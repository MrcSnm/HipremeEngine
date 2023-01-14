import hip.console.console;
import hip.filesystem.hipfs;
import hip.console.log;
import hip.error.handler;
import hip.systems.game;
import hip.hiprenderer.renderer;
import hip.global.gamedef;

import hip.wasm;
import hip.data.json;

/**
* Build:
* dub build --build=debug --skip-registry=all --arch=wasm32-unknown-unknown-wasm
*/

enum float FRAME_TIME = 1000/60; //60 frames per second


void main()
{
	import hip.console.log;
	import hip.util.time;
	import hip.wasm;
	


	HipTime.initialize();
	Console.install(Platforms.WASM);
	HipFS.install("");
	void[] output;

	HipFS.read("fonts/WarsawGothic-BnBV.otf", output);

	logln(output.length);
	
	HipRenderer.initExternal(HipRendererType.GL3, 800, 600);
	//Initialize 2D context
	loadDefaultAssets((){initializeGame();}, (err)
	{
		loglnError("Could not load all default assets! ", err);
	});
}

private void initializeGame()
{
	import hip.graphics.g2d;
	import hip.console.log;
	logln("Initialized Game");
	HipRenderer2D.initialize();
	sys = new GameSystem(FRAME_TIME);
	WasmStartGameLoop();
}
extern(C) void WasmStartGameLoop();

export extern(C) void HipremeRender()
{
	if(sys !is null)
	{
		HipRenderer.setColor(0,0,0,255);
		HipRenderer.clear();
		import hip.api.graphics.g2d.renderer2d;
		drawTexture(null, 150, 50);
		renderSprites();

		drawText("Hello WASM", 50, 50);
		renderTexts();
	}
	// sys.render();
	// import hip.api;
	// drawTexture(null, 100, 100);
	// renderSprites();
	// renderGeometries();
}

export extern(C) bool HipremeUpdate(float dt)
{
	if(sys !is null)
	{
		dt/= 1000; //To seconds. Javascript gives in MS.
		import hip.api;
		sys.update(dt);
		sys.postUpdate();
	}
	return false;
}