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

	
	HipRenderer.initExternal(HipRendererType.GL3, 800, 600);
	//Initialize 2D context
	loadDefaultAssets((){initializeGame();}, (err)
	{
		loglnError("Could not load all default assets! ", err);
	});
}

import hip.graphics.g2d;
__gshared IHipTexture texture;
// __gshared IImage img;

private void initializeGame()
{
	import hip.graphics.g2d;
	import hip.console.log;
	import hip.assetmanager;
	logln("Initialized Game");
	HipAssetManager.initialize();
	HipRenderer2D.initialize();
	sys = new GameSystem(FRAME_TIME);

	IHipAssetLoadTask task = HipAssetManager.loadTexture2("graphics/sprites/sprite.png");
	task.into(&texture);

	// IHipAssetLoadTask task2 = HipAssetManager.loadImage("graphics/sprites/sprite.png");
	// task2.into(&img);

	WasmStartGameLoop();

}
extern(C) void WasmStartGameLoop();

export extern(C) void HipremeRender()
{
	if(sys !is null)
	{
		if(texture !is null)
		{
			logln(texture.getWidth);
		}
		// logln(img is null);
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
	import hip.assetmanager;
	if(sys !is null || HipAssetManager.isLoading)
	{
		dt/= 1000; //To seconds. Javascript gives in MS.
		import hip.api;
		sys.update(dt);
		sys.postUpdate();
	}
	return false;
}