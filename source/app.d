/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
import hip.console.log;
import hip.console.console;
import hip.bind.external;
import hip.filesystem.hipfs;
import hip.error.handler;
import hip.global.gamedef;
import hip.hipaudio.audio;
import hip.assetmanager;
import hip.systems.timer_manager;

version(Windows)
{
	import hip.hiprenderer.backend.d3d.d3drenderer;
}
import hip.hiprenderer.renderer;
import hip.view;
import hip.systems.game;
import hip.bind.interpreters;
import hip.config.opts;

version(dll)
{
	version(WebAssembly){}
	else version(PSVita){}
	else version = ManagesMainDRuntime;
}
version(dll){}
else version(AppleOS) { version = ManagesMainDRuntime;}
else version = HandleArguments;
////
version(ManagesMainDRuntime)
{
	import core.runtime;
}
version(WebAssembly) version = ExternallyManagedDeltaTime;
version(AppleOS)     version = ExternallyManagedDeltaTime;
version(PSVita)      version = ExternallyManagedDeltaTime;


/**
* Compiling instructions:

* Desktop: dub
* UWP: dub build -c uwp
* Android: dub build -c android --compiler=ldc2 -a aarch64--linux-android
*
*	Linker:
*	If you wish to use LLD on Windows, you will need to install Windows 10 SDK.
*	And include on dub the following lflags:
*	"lflags": [
		"-libpath:C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.29.30133\\lib\\x64\\"
	],
*
*	The libpath is required for getting to link a "compatible" libcmt, which unfortunately is not really compatible for some reason.
*	This comment here will be stored as a documentation.
*/


__gshared string projectToLoad;
///Came from bin/desktop/engine_opts.json 
__gshared string buildCommand;
__gshared bool isUsingInterpreter = false;
__gshared HipInterpreterEntry interpreterEntry;


/** 
 * What this function does is basically parse the arguments for the
 * engine entry point:
 *
 *	- lua specified: Automatically initialize lua interpreter, and loads source/scripting/lua/main.lua
 *	- lua source specified: Automatically initialize lua interpreter and loads the source specified
 *	- Project Path specified: Loads the DLL found in the project path
 *
 */
version(HandleArguments)
void HipremeHandleArguments()
{
	import hip.util.path;
	version(Load_DScript)
	{
		if(arguments.length < 2)
		{
			import hip.data.json;
			import hip.filesystem.hipfs;
			string engineExe = arguments[0];
			string engineOpts = engineExe.dirName.joinPath("engine_opts.json").normalizePath;
			hiplog("Loading ", engineOpts);
			if(HipFS.absoluteExists(engineOpts))
			{
				string data;
				ErrorHandler.assertExit(HipFS.absoluteReadText(engineOpts, data), "Error reading engine_opts.json");
				JSONValue v = parseJSON(data);
				if(v.hasErrorOccurred)
				{
					ErrorHandler.assertExit(false, "Error parsing engine_opts.json", v.error);
				}
				else
				{
					projectToLoad = v["defaultProject"].str;
					buildCommand = v["buildCmd"].str;
				}
			}
			return;
		}
	}
	if(arguments.length == 2) //Project Path
	{
		import hip.util.path;
		if(arguments[1] == "lua")
		{
			interpreterEntry.intepreter = HipInterpreter.lua;
			interpreterEntry.sourceEntry = "source/scripting/lua/main.lua";
			isUsingInterpreter = true;
		}
		else if(arguments[1].extension == ".lua")
		{
			interpreterEntry.intepreter = HipInterpreter.lua;
			interpreterEntry.sourceEntry = arguments[1];
			isUsingInterpreter = true;
		}
		else
			projectToLoad = arguments[1];
	}
}

// import core.sys.windows.windows;
// extern(Windows) int NtSetTimerResolution(ULONG RequestedResolution, BOOLEAN Set, PULONG ActualResolution);
// // HACK: this allows to Sleep under 15.6ms smh
// 	uint unused;
// 	NtSetTimerResolution(5000, TRUE, &unused);


static void initEngine(bool audio3D = false)
{
	import hip.internal_configuration;
	Console.install(ActivePlatform, getPlatformPrintFunction());
	loglnInfo("Console installed for ", ActivePlatform);
	HipFS.initializeAbsolute();
	version(HandleArguments)
		HipremeHandleArguments();

	string fsInstallPath = getFSInstallPath(projectToLoad);
	HipFS.install(fsInstallPath, getFilesystemValidations());
	loglnInfo("HipFS installed at path ", fsInstallPath);

	import hip.bind.dependencies;
	loadEngineDependencies();
}


enum float FRAME_TIME = 1000/60; //60 frames per second

export extern(C) int HipremeMain(int windowWidth = -1, int windowHeight = -1)
{
	import hip.data.ini;
	import hip.math.random;
	import hip.util.time;
	HipTime.initialize();
	Random.initialize();
	initEngine(true);

	if(isUsingInterpreter)
		startInterpreter(interpreterEntry.intepreter);


	version(Android)
	{
		bool hasProFeature = HipAndroid.javaCall!(bool, "hasProFeature");
		bool hasLowLatencyFeature =HipAndroid.javaCall!(bool, "hasLowLatencyFeature");
		int getOptimalAudioBufferSize = HipAndroid.javaCall!(int, "getOptimalAudioBufferSize");
		int getOptimalSampleRate = HipAndroid.javaCall!(int, "getOptimalSampleRate");

		HipAudio.initialize(getAudioImplementationForOS, 
			hasProFeature,
			hasLowLatencyFeature,
			getOptimalAudioBufferSize,
			getOptimalSampleRate
		);
	}
	else
		HipAudio.initialize(getAudioImplementationForOS);
	version(dll)
	{
		import hip.console.log;
		hiplog("Will init renderer");
		version(UWP){HipRenderer.initExternal(HipRendererType.D3D11, windowWidth, windowHeight);}
		else version(WebAssembly){HipRenderer.initExternal(HipRendererType.GL3, windowWidth, windowHeight);}
		else version(Android)
		{
			version(Have_gles){}else{static assert(false, "Android build requires GLES on its dependencies.");}
			HipRenderer.initExternal(HipRendererType.GL3, windowWidth, windowHeight);
		}
		else version(PSVita){HipRenderer.initExternal(HipRendererType.GL3, windowWidth, windowHeight);}
		else static assert(false, "No renderer for this platform");
	}
	else
	{
		string confFile;
		HipFS.absoluteReadText("renderer.conf", confFile); //Ignore return, renderer can handle no conf.
		HipRenderer.initialize(confFile, "renderer.conf");
	}
	loadDefaultAssets((){gameInitialize();}, (err)
	{
		loglnError("Could not load default assets! ", err);
	});
	return 0;
}

version(WebAssembly) extern(C) void WasmStartGameLoop();

void gameInitialize()
{
	import hip.console.log;
	loglnInfo("Initializing Asset Manager");
	HipAssetManager.initialize();
	sys = new GameSystem(FRAME_TIME);

	//Initialize 2D context
	import hip.graphics.g2d;
	HipRenderer2D.initialize(interpreterEntry, true);
	
	if(isUsingInterpreter)
		loadInterpreterEntry(interpreterEntry.intepreter, interpreterEntry.sourceEntry);
	//After initializing engine, every dependency has been load
	sys.loadGame(projectToLoad, buildCommand);
	sys.startGame();
	version(Desktop){HipremeDesktopGameLoop();}
	else version(WebAssembly){WasmStartGameLoop();}
}
import hip.network;


/** 
 * This function will destroy SDL and dispose every resource
 */
static void destroyEngine()
{
	// hiplog("Closing ", onlineSockets.length, " Socket ", " Connections");
	// foreach(socket; onlineSockets)
	// {
	// 	socket.disconnect();
	// }

	sys.quit();
	HipRenderer.dispose();
	HipAudio.onDestroy();
}



/**
*	Initializes the D runtime, import hip.external functions
*/
export extern(C) void HipremeInit()
{
	version(ManagesMainDRuntime)
	{
		rt_init();
		importExternal();
	}
}
/**
*	Loads shared libraries and setups the engine modules:
*
*	- Console
*
*	- HipFS
*
*	- HipRenderer
*
*	- HipAudio
*
*/
version(dll)
{
	version(WebAssembly)
	{
		import hip.windowing.platforms.browser;
		int main()
		{
			string[] _;
			int[2] windowSize = getWindowSize(null, _);
			return HipremeMain(windowSize[0], windowSize[1]);
		}
	}
}
else version(AppleOS){}
else
{
	private string[] arguments;
	int main(string[] args)
	{
		arguments = args;
		return HipremeMain();
	}
}

///Steps an engine frame
bool HipremeUpdateBase()
{
	if(!sys.update(g_deltaTime))
		return false;
	if(isUsingInterpreter)
		updateInterpreter();
	sys.postUpdate();
	return true;
}

version(ExternallyManagedDeltaTime)
{
	export extern(System) bool HipremeUpdate(float dt)
	{
		g_deltaTime = dt;
		return HipremeUpdateBase();
	}
}
else version(dll) export extern(System) bool HipremeUpdate()
{
	import hip.util.time;
	import core.time:dur;
	import core.thread.osthread;
	long initTime = HipTime.getCurrentTime();
	if(HipremeUpdateBase())
	{
		long sleepTime = cast(long)(FRAME_TIME - g_deltaTime.msecs);
		if(sleepTime > 0)
		{
			Thread.sleep(dur!"msecs"(sleepTime));
		}
		// g_deltaTime = (cast(float)(HipTime.getCurrentTime() - initTime) / 1.nsecs); //As seconds
		g_deltaTime = 0.016;
		// logln(g_deltaTime);

		return true;
	}
	return false;
}
version(Desktop)
{
	void HipremeDesktopGameLoop()
	{
		import hip.util.time;
		import core.time:dur;
		import core.thread : Thread;
		bool isUpdating = true;
		while(isUpdating)
		{
			long initTime = HipTime.getCurrentTime();
			long sleepTime = cast(long)(FRAME_TIME - g_deltaTime.msecs);
			if(sleepTime > 0)
			{
				Thread.sleep(dur!"msecs"(sleepTime));
			}
			isUpdating = HipremeUpdateBase();
			HipremeRender();
			g_deltaTime = (cast(float)(HipTime.getCurrentTime() - initTime) / 1.nsecs); //As seconds
		}
		HipremeDestroy();
	}
}
/**
* This function was created for making it rendering optional. On Android, 
* the game is only rendered when the renderer is dirty, it is absolutely
* not recommended to do game logic on the render
*/
export extern(System) void HipremeRender()
{
	import hip.bind.interpreters;
	import hip.graphics.g2d.renderer2d;
	HipRenderer.begin();
	HipRenderer.clear(0,0,0,255);
	sys.render();
	if(isUsingInterpreter)
		renderInterpreter();
	finishRender2D();
	HipRenderer.end();
}
export extern(System) void HipremeDestroy()
{
	logln("Destroying HipremeEnginess");
	destroyEngine();
	version(ManagesMainDRuntime)
		rt_term();
}

export extern(System) void logMessage(string message)
{
	import hip.console.log;
	rawlog(message);
}

version(UWP)
{
	import core.sys.windows.dll;
	mixin SimpleDllMain;

}

public import exportd;
import android_entry;