/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.api;


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



version (HipremeG2D)
{
	public import hip.api.graphics.color;
	public import hip.api.renderer.texture;
	public import hip.api.renderer.viewport;
	public import hip.api.graphics.g2d.hipsprite;
}
//View + Renderer
public import hip.api.graphics.g2d.renderer2d;
public import hip.api.view.scene;


//Assets
public import HipAssetManager = hip.api.assets.assets_binding;
//Audio
public import hip.api.audio;
//Math
public import hip.api.math.random;
//Game
public import hip.api.systems.timer;
public import hip.api.game.game_binding : HipGameUtils;
public import hip.api.systems.system_binding: HipTimerManager;
//Input

version(Have_hipreme_engine)
	version = HasInputAPI;
else version(HipInputAPI)
	version = HasInputAPI;

version(HasInputAPI)
{
	public import HipInput = hip.api.input;
	public import hip.api.input.keyboard : HipKey;
	alias IHipInputMap = HipInput.IHipInputMap;
}

version(Have_hipreme_engine) //Aliased import fix
	public import hip.event.handlers.inputmap;

import hip.api.internal;
public import hip.api.internal:initializeHip;

///Most important functions here
version(Script)
{
	void function(string s) log;
	void function(Object obj) hipDestroy;

	void logg(Args...)(Args a)
	{
		import hip.util.conv;
		string toLog;
		foreach(arg; a)
			toLog~= arg.to!string;
		log(toLog);
	}
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
			import hip.api;
			import hip.api.math.math_binding;
			import hip.api.systems.system_binding;
			import hip.api.game.game_binding;
			import core.runtime;
			rt_init();
			initializeHip();
			initConsole();
			initMath();
			initG2D();
			HipAudio.initAudio();
			HipInput.initInput();
			HipAssetManager.initAssetManager();
			initTimerAPI();
			initGameAPI();
			
			return _exportedScene = new StartScene();
		}
		export extern(System) void HipremeEngineGameDestroy(){if(_exportedScene)destroy(_exportedScene);_exportedScene=null;}
	}
	else
		alias HipEngineMainScene  = StartScene;
}