/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.engine_runtime;

import hip.console.log;
import hip.console.console;
import hip.bind.external;
import hip.filesystem.hipfs;
import hip.error.handler;
import hip.global.gamedef;
import hip.audio;
import hip.assetmanager;
import hip.systems.timer_manager;
import hip.internal_configuration;

version(Windows)
{
	import hip.hiprenderer.backend.d3d.d3drenderer;
}
import hip.view;
import hip.systems.game;
import hip.bind.interpreters;
import hip.config.opts;
import hip.config.args : parseHipremeEngineArgs, printHipremeEngineArgsHelp;
import hip.util.allocator : frameAllocatorGuardEnabled;
import hip.network;

version(Desktop)        version = LocalGameLoop;
version(NintendoSwitch) version = LocalGameLoop;

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

__gshared string[] rt_options = ["gcopt=profile:1"];
__gshared string[] arguments;
__gshared long hipStartupTimeMs;


/**
 * What this function does is basically parse the arguments for the
 * engine entry point:
 *
 *	- lua specified: Automatically initialize lua interpreter, and loads source/scripting/lua/main.lua
 *	- lua source specified: Automatically initialize lua interpreter and loads the source specified
 *	- Project Path specified: Loads the DLL found in the project path
 *
 */
void HipremeHandleArguments()
{
	static if(HandleArguments)
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
						if("frameAllocatorGuard" in v)
							frameAllocatorGuardEnabled = v["frameAllocatorGuard"].boolean;
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
}

// import core.sys.windows.windows;
// extern(Windows) int NtSetTimerResolution(ULONG RequestedResolution, BOOLEAN Set, PULONG ActualResolution);
// // HACK: this allows to Sleep under 15.6ms smh
// 	uint unused;
// 	NtSetTimerResolution(5000, TRUE, &unused);

version(Standalone)
{
    pragma(mangle, "HipGetEntryFilePath")
    extern(C) string HipGetEntryFilePath();
}
static bool initEngine(bool audio3D = false)
{
	import hip.internal_configuration;
	import hip.console.report;
	Console.install(ActivePlatform, getPlatformPrintFunction());
	reportRow("engine", "console", ActivePlatform);

	auto parsedArgs = parseHipremeEngineArgs(arguments, frameAllocatorGuardEnabled);
	if(parsedArgs.verbose.specified)
		setVerboseLogging(parsedArgs.verbose.value);
	if(parsedArgs.help.value)
	{
		printHipremeEngineArgsHelp(&rawlog);
		return false;
	}

	// Keep HipremeHandleArguments receiving the format it understands: [exe, project].
	string[] remainingArgs;
	if(arguments.length)
		remainingArgs ~= arguments[0];
	if(parsedArgs.project.value.length)
		remainingArgs ~= parsedArgs.project.value;
	arguments = remainingArgs;

	HipFS.initializeAbsolute();
	HipremeHandleArguments();
	if(parsedArgs.frameGuard.specified)
		frameAllocatorGuardEnabled = parsedArgs.frameGuard.value;

	string fsInstallPath = getFSInstallPath(projectToLoad);
	HipFS.install(fsInstallPath, getFilesystemValidations());
	string projPath;
	version(Standalone)
	{
		import hip.util.path;
		projPath = buildNormalizedPath(HipGetEntryFilePath(), "..", "..", ".."); //source/gamescript/entry.d
	}
	setIHipFS(HipFS, projPath);
	reportRow("engine", "filesystem", fsInstallPath);

	import hip.bind.dependencies;
	loadEngineDependencies();
	return true;
}


enum float FRAME_TIME = 1000/60; //60 frames per second
// enum float FRAME_TIME = 1000/144; //144 frames per second

export extern(C) int HipremeMain(int windowWidth = -1, int windowHeight = -1)
{
	import hip.data.ini;
	import hip.math.random;
	import hip.util.time;
	import hip.console.report;
	import backtraced;
	import hip.hiprenderer:PreInitializeHipRenderer, HipRenderer;

	backtraced_Register();
	HipTime.initialize();
	hipStartupTimeMs = HipTime.getCurrentTimeAsMsLong();

	if(!initEngine(true))
		return 0;
	Random.initialize();

	if(isUsingInterpreter)
		startInterpreter(interpreterEntry.intepreter);
	PreInitializeHipRenderer();
	PreInitializeHipAudio();

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

	ReportTimer rendererTimer = ReportTimer.start();
	version(InitExternal)
	{
		import hip.api.renderer.core;
		hiplog("Initializing Renderer Externally");
		HipRenderer.initExternal(ExternalInitRendererType, windowWidth, windowHeight);
	}
	else
	{
		string confFile;
		HipFS.absoluteReadText("renderer.conf", confFile); //Ignore return, renderer can handle no conf.
		HipRenderer.initialize(confFile, "renderer.conf");
	}
	rendererTimer.report("renderer");
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
	hiplog("Initializing Asset Manager");
	HipAssetManager.initialize();
	hip.global.gamedef.sys = new GameSystem(FRAME_TIME);

	//Initialize 2D context
	import hip.graphics.g2d;
	HipRenderer2D.initialize(interpreterEntry, true);

	if(isUsingInterpreter)
		loadInterpreterEntry(interpreterEntry.intepreter, interpreterEntry.sourceEntry);
	//After initializing engine, every dependency has been load
	sys.loadGame(projectToLoad, buildCommand);
	sys.startGame();
	version(WebAssembly)
		WasmStartGameLoop();
	else version(LocalGameLoop)
		HipremeLocalGameLoop();
}


/**
 * Some Resources must be freed safely.
 * One example is the Network. It won't be able to recognize disconnection if it is not done manually.
 *
 * In the future, it also may restore some state pre-engine run. For example, Android sound/screen state
 */
static void destroyEngine()
{
	import hip.hiprenderer.renderer;

	// hiplog("Closing ", onlineSockets.length, " Socket ", " Connections");
	disconnectNetwork();
	sys.quit();
	HipRenderer.dispose();
	HipAudio.onDestroy();
}



/**
*	Initializes the D runtime, import hip.external functions
*/
export extern(C) void HipremeInit()
{
	static if(ManagesMainDRuntime)
	{
		import core.runtime;
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

///Steps an engine frame
export extern(System) bool HipremeUpdate(float dt)
{
	g_deltaTime = dt;
	import hip.graphics.g2d.profiling;
	setFrameInitTime();
	if(!sys.update(g_deltaTime))
		return false;
	if(isUsingInterpreter)
		updateInterpreter();
	sys.postUpdate();
	return true;
}

version(WebAssembly)
{
	/**
	 * The main difference is that on WebAssembly, Hipreme Engine loop is not separated between
	 * update and render. That happens because the wasm bridge makes things slower. So it is better
	 * to simply merge all wasm calls together.
	 * Params:
	 *   dt = Delta Time
	 * Returns: Whether the engine should continue looping
	 */
	export extern(System) bool HipremeEngineLoop(float dt)
	{
		if(!HipremeUpdate(dt))
			return false;
		HipremeRender();
		gFrameAllocator.reset();
		return true;
	}
}

version(LocalGameLoop)
void HipremeLocalGameLoop()
{
	version(Desktop) long initTime;
	bool isUpdating = true;
	while(isUpdating)
	{
		float dt = 0.016f;
		version(Desktop)
		{
			import hip.util.time;
			import core.time : dur;
			import core.thread : Thread;
			initTime = HipTime.getCurrentTime();
			long sleepTime = cast(long)(FRAME_TIME - g_deltaTime.msecs);
			if(sleepTime > 0)
				Thread.sleep(dur!"msecs"(sleepTime));
			dt = g_deltaTime;
		}
		isUpdating = HipremeUpdate(dt);
		if(isUpdating)
			HipremeRender();
		gFrameAllocator.reset();
		version(Desktop)
			g_deltaTime = (cast(float)(HipTime.getCurrentTime() - initTime) / 1.nsecs); //As seconds
	}
	version(Desktop)
		HipremeDestroy();
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
	import hip.hiprenderer.renderer;

	static bool firstFrame = true;
	if(firstFrame)
	{
		firstFrame = false;
		import hip.util.time;
		import hip.console.report;
		reportRow("timings", "first frame", HipTime.getCurrentTimeAsMsLong() - hipStartupTimeMs, " ms");
		HipAudio.reportPendingInitIfReady();
		flushReport();
		HipAudio.printPendingInit();
	}
	
	HipRenderer.begin();
	beginRender2D(0);
	HipRenderer.clear(0,0,0,255);
	sys.render();
	if(isUsingInterpreter)
		renderInterpreter();
	//TODO: Do multiframe rendering.
	finishRender2D();
	HipRenderer.end();
}
export extern(System) void HipremeDestroy()
{
	logln("Destroying HipremeEngine");
	// If the engine exits before the first frame, still print the startup report.
	import hip.console.report : reportWasFlushed, flushReport;
	if(!reportWasFlushed())
		flushReport();
	destroyEngine();
	// Only terminate the runtime when the engine owns it (no D `main`).
	// On desktop/script builds druntime is managed by main; calling rt_term()
	// here tears down the GC while still inside the game loop and can hang.
	static if(ManagesMainDRuntime && !HasMain)
	{
		import core.runtime;
		rt_term();
	}
}

export extern(System) void logMessage(string message)
{
	import hip.console.log;
	rawlog(message);
}

export extern(System) void verboseMessage(string message)
{
	import hip.console.console : Console;
	if(Console.DEFAULT !is null)
		Console.DEFAULT.hipLog(message, verboseLogging);
}
