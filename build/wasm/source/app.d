module source.app;

import std.stdio;

extern(C)
{
	float mathRandom();
}


/**
* Build:
* dub build --build=plain --skip-registry=all --arch=wasm32-unknown-unknown-wasm
*/
extern(C) int monotimeNow();

void speedTest()
{
	import hip.math.random;
	import arsd.webassembly;
	int timeStarted =  monotimeNow();
	writeln("Started");
	foreach(_; 0..1_000_000)
	{
		Random.range(0, 1000);
	}
	writeln("Finished ", monotimeNow() - timeStarted);

	auto Math = eval!NativeHandle("return Math");
	int now = monotimeNow();
	foreach(i; 0..1_000_000)
	float d = Math.methods.random!float();
	writeln(monotimeNow() - now);
}


void main()
{
	import hip.console.console;
	import hip.filesystem.hipfs;
	import hip.console.log;
	import hip.error.handler;
	import hip.hiprenderer.renderer;
	import hip.global.gamedef;
	Console.install(Platforms.WASM);
	HipFS.install("./");
	HipRenderer.initExternal(HipRendererType.GL3, 800, 600);
	//Initialize 2D context
	import hip.graphics.g2d;
	if(!loadDefaultAssets())
		loglnError("Could not load default assets!");
	HipRenderer2D.initialize();
	import hip.api;
	drawTexture(null, 100, 100);
	renderSprites();
	renderGeometries();
	logln("Hello world");
}


export extern(C) void HipremeRender()
{
	import hip.api;

}