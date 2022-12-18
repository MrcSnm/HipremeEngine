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
*	1: Public Interfaces, Structs and Abstract Classes must always be declared somewhere at hip.api;
*	2: Methods will most of the time return an interface when dealing it at scripting time, at release
*	build, the can return the entire class.
*	3: The User API will contain classes named as the same as those defined at the HipremeEngine, so
*	the user will actually use some aliass.
*	4: When building for release (version(Have_hipreme_engine)), api should publicly import the actual
*	class definition.
*	5: For maintaining consistency, this package may declare some public imports that should be delegated
*	to the actual API when that API is an aliased import.
*/

public import hip.api.impl;

///Most important functions here
version(Script)
{
	private alias hipDestroyFn = extern(C) void function(Object obj);
	hipDestroyFn hipDestroy;
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
			import hip.api.internal:initializeHip;

			rt_init();
			initializeHip();
			initConsole();
			HipFS.initFS();
			initMath();
			initG2D();
			HipAudio.initAudio();
			HipInput.initInput();
			HipDefaultAssets.initGlobalAssets();
			HipAssetManager.initAssetManager();
			initTimerAPI();
			initGameAPI();
			
			return _exportedScene = new StartScene();
		}
		export extern(System) void HipremeEngineGameDestroy()
		{
			if(_exportedScene)
			{
				_exportedScene.dispose();
				destroy(_exportedScene);
			}
			_exportedScene=null;
		}
	}
	else
		alias HipEngineMainScene  = StartScene;
}