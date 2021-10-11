/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipengine;

/**
* For building the API some rules must be followed:
*
*	1: Public Interfaces, Structs and Abstract Classes must always be declared somewhere at hipengine.api;
*	2: Methods will most of the time return an interface when dealing it at scripting time, at release
*	build, the can return the entire class.
*	3: The User API will contain classes named as the same as those defined at the HipremeEngine, so
*	the user will actually use some aliass.
*	4: When building for release (version(Have_hipreme_engine)), api should publicly import the actual
*	class definition.
*	5: For maintaining consistency, this package may declare some public imports that should be delegated
*	to the actual API when that API is an aliased import.
*/



// version (HipremeAudio)
// {
// 	public import hipaudio;
// }
// version (HipremeRenderer)
// {
// 	public import hiprenderer;
// }
version (HipremeG2D)
{
	public import hipengine.api.graphics.color;
	public import hipengine.api.renderer.texture;
	public import hipengine.api.graphics.g2d.hipsprite;
}
//View + Renderer
public import hipengine.api.graphics.g2d.renderer2d;
public import hipengine.api.view;


// version(HipremeEngineDef)
// {
// 	public import hipengine.api.math;
// 	public import hipengine.api.audio;
// 	// public import math.vector;
	
// 	//Input
// 	public import HipInput = hipengine.api.input;
// 	alias initInput = HipInput.initInput;

// 	import hipengine.internal;
// 	public import hipengine.internal:initializeHip;
// }
// else
// {
	//Audio
	public import hipengine.api.audio;

	//Math
	public import hipengine.api.math;

	//Input
	public import HipInput = hipengine.api.input;
	alias initInput = HipInput.initInput;
	alias IHipInputMap = HipInput.IHipInputMap;

	version(Have_hipreme_engine) //Aliased import fix
		public import event.handlers.inputmap;

	import hipengine.internal;
	public import hipengine.internal:initializeHip;
// }

///Most important functions here
version(Script)
{
	void function(string s) log;
	void function(Object obj) hipDestroy;
}
void initConsole()
{
	version(Script){mixin(loadSymbol("log"));}
}

mixin template HipEngineMain(alias StartScene)
{
	version(Script)
	{
		__gshared AScene _exportedScene;
		version(Windows)
		{
			import core.sys.windows.dll;
			mixin SimpleDllMain;
		}
		export extern(System) AScene HipremeEngineGameInit()
		{
			import hipengine;
			import core.runtime;
			rt_init();
			initializeHip();
			initInput();
			initMath();
			initConsole();
			initG2D();
			HipAudio.initAudio();
			return _exportedScene = new StartScene();
		}
		export extern(System) void HipremeEngineGameDestroy(){if(_exportedScene)destroy(_exportedScene);_exportedScene=null;}
	}
	else
		alias HipEngineMainScene  = StartScene;
}