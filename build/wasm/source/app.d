import hip.console.console;
import hip.filesystem.hipfs;
import hip.console.log;
import hip.error.handler;
import hip.systems.game;
import hip.hiprenderer.renderer;
import hip.global.gamedef;

import hip.wasm;

/**
* Build:
* dub build --build=debug --skip-registry=all --arch=wasm32-unknown-unknown-wasm
*/

enum float FRAME_TIME = 1000/60; //60 frames per second

extern(C) void callDg(JSDelegateType!(void delegate()));


void main()
{
	import std.stdio;
	import hip.util.time;
	import hip.wasm;
	int a = 500;
	

	auto dg = (){
		a++;
		writeln("Javascript is calling D!!!, check the new A", a);
	};
		
	callDg(sendJSDelegate!(dg).tupleof);
	writeln(a);


	HipTime.initialize();
	Console.install(Platforms.WASM);
	HipFS.install("./");
	HipRenderer.initExternal(HipRendererType.GL3, 800, 600);
	//Initialize 2D context
	import hip.graphics.g2d;
	string err;
	if(!loadDefaultAssets(err))
		loglnError("Could not load default assets! ", err);
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
	sys.postUpdate();
	return false;
}