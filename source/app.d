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
version(dll)
{
	import core.runtime;
}
import hip.hiprenderer.renderer;
import hip.view;
import hip.systems.game;
import hip.bind.interpreters;
import hip.config.opts;


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
		"-libpath:C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.29.30133\\lib\\x64"
	],
*
*	The libpath is required for getting to link a "compatible" libcmt, which unfortunately is not really compatible for some reason.
*	This comment here will be stored as a documentation.
*/


__gshared string projectToLoad;
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
void HipremeHandleArguments(string[] args)
{
	if(args.length < 2)
		return;

	if(args.length == 2) //Project Path
	{
		import hip.util.path;
		projectToLoad = args[1];
	}
	else if(args[1] == "lua")
	{
		interpreterEntry.intepreter = HipInterpreter.lua;
		interpreterEntry.sourceEntry = "source/scripting/lua/main.lua";
		isUsingInterpreter = true;
	}
	else if(args[1][$-4..$] == ".lua")
	{
		interpreterEntry.intepreter = HipInterpreter.lua;
		interpreterEntry.sourceEntry = args[1];
		isUsingInterpreter = true;
	}
}


static void initEngine(bool audio3D = false)
{
	Platforms platform = Platforms.DEFAULT;
	void function(string) printFunc;
	string fsInstallPath = "";
	bool function(string path, out string msg)[] validations;

	version(Android)
	{
		platform = Platforms.ANDROID;
	}
	else version(UWP)
	{
		import std.file:getcwd;
		platform = Platforms.UWP;
		printFunc = &uwpPrint;
		fsInstallPath = getcwd()~"\\UWPResources\\";
		validations~= (string path, out string msg)
		{
			//As the path is installed already, it should check only for absolute paths.
			if(!HipFS.absoluteExists(path))
			{
				msg = "File at path "~path~" does not exists. Did you forget to add it to the AppX Resources?";
				return false;
			}
			return true;
		};
	}
	else
	{
		import std.file:getcwd;
		if(projectToLoad != "")
			fsInstallPath = projectToLoad~"/assets";
		else
			fsInstallPath = getcwd()~"/assets";
	}
	Console.install(platform, printFunc);
	HipFS.install(fsInstallPath, validations);
	loglnInfo("HipFS installed at path ", fsInstallPath);
	loglnInfo("Console installed for ", platform);



	import hip.bind.dependencies;
	loadEngineDependencies();
}


enum float FRAME_TIME = 1000/60; //60 frames per second

export extern(C) int HipremeMain()
{
	import hip.data.ini;
	Console.initialize();
	initEngine(true);
	if(isUsingInterpreter)
		startInterpreter(interpreterEntry.intepreter);



	version(Android)
	{
		bool hasProFeature = HipAndroid.javaCall!(bool, "hasProFeature");
		bool hasLowLatencyFeature =HipAndroid.javaCall!(bool, "hasLowLatencyFeature");
		int getOptimalAudioBufferSize = HipAndroid.javaCall!(int, "getOptimalAudioBufferSize");
		int getOptimalSampleRate = HipAndroid.javaCall!(int, "getOptimalSampleRate");

		HipAudio.initialize(HipAudioImplementation.OPENSLES, 
			hasProFeature,
			hasLowLatencyFeature,
			getOptimalAudioBufferSize,
			getOptimalSampleRate
		);
	}
	else
		HipAudio.initialize(HipAudioImplementation.XAUDIO2);
	version(dll)
	{
		import hip.console.log;
		logln("Will init renderer");
		version(UWP){HipRenderer.initExternal(HipRendererType.D3D11);}
		else version(Android)
		{
			version(Have_gles){}
			else{static assert(false, "Android build requires GLES on its dependencies.");}
			HipRenderer.initExternal(HipRendererType.GL3);
		}
		else static assert(false, "No renderer for this platform");
	}
	else
	{
		string confFile;
		HipFS.absoluteReadText("renderer.conf", confFile); //Ignore return, renderer can handle no conf.
		HipRenderer.init(confFile, "renderer.conf");
	}
	if(!loadDefaultAssets())
	{
		loglnError("Could not load default assets!");
	}
	HipAssetManager.initialize();
	sys = new GameSystem(FRAME_TIME);


	//Initialize 2D context
	import hip.graphics.g2d;
	HipRenderer2D.initialize(interpreterEntry, true);
	
	if(isUsingInterpreter)
		loadInterpreterEntry(interpreterEntry.intepreter, interpreterEntry.sourceEntry);
	//After initializing engine, every dependency has been load
	sys.loadGame(projectToLoad);
	sys.startGame();
	version(Desktop)
	{
		HipremeDesktopGameLoop();
	}
	return 0;
}

/** 
 * This function will destroy SDL and dispose every resource
 */
static void destroyEngine()
{
    //HipAssetManager.disposeResources();
	sys.quit();
	HipRenderer.dispose();
	HipAudio.onDestroy();
}



version(Android)
{
	
	import hip.jni.helper.androidlog;
	import hip.jni.jni;
	import hip.jni.helper.jnicall;
	///Setups an Android Package for HipremeEngine
	alias HipAndroid = javaGetPackage!("com.hipremeengine.app.HipremeEngine");
	import hip.systems.input;
	import hip.console.log;

	export extern(C)
	{
		void Java_com_hipremeengine_app_HipremeEngine_HipremeInit(JNIEnv* env, jclass clazz)
		{
			import hip.filesystem.systems.android;
			HipremeInit();
			JNISetEnv(env);
			aaMgr = cast(AAssetManager*)HipAndroid.javaCall!(Object, "getAssetManager");
			aaMgr = AAssetManager_fromJava(env, aaMgr);
		}

		jint Java_com_hipremeengine_app_HipremeEngine_HipremeMain(JNIEnv* env, jclass clazz)
		{
			int ret = HipremeMain();
			import hip.hiprenderer.viewport;
			int[2] wsize = HipAndroid.javaCall!(int[2], "getWindowSize");
			HipRenderer.setViewport(new Viewport(0, 0, wsize[0], wsize[1]));
			return ret;
		}
		jboolean Java_com_hipremeengine_app_HipremeEngine_HipremeUpdate(JNIEnv* env, jclass clazz)
		{
			return HipremeUpdate();
		}
		void Java_com_hipremeengine_app_HipremeEngine_HipremeRender(JNIEnv* env, jclass clazz)
		{
			HipremeRender();
		}
		void  Java_com_hipremeengine_app_HipremeEngine_HipremeDestroy(JNIEnv* env, jclass clazz)
		{
			JNISetEnv(null);
			HipremeDestroy();
		}
	}
	
}

/**
*	Initializes the D runtime, import hip.external functions
*	and initializes GameSystem, as it will handle external API's
*
*/
export extern(C) void HipremeInit()
{
	version(dll)
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
version(dll){}
else
{
	int main(string[] args)
	{
		HipremeHandleArguments(args);
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

version(dll) export extern(C) bool HipremeUpdate()
{
	import hip.util.time;
	import core.time:dur;
	import core.thread.osthread;
	version(Android)
	{
		if(HipremeUpdateBase())
			return true;
	}
	else version(UWP)
	{
		long initTime = HipTime.getCurrentTime();
		if(HipremeUpdateBase())
		{
			long sleepTime = cast(long)(FRAME_TIME - g_deltaTime.msecs);
			if(sleepTime > 0)
			{
				Thread.sleep(dur!"msecs"(sleepTime));
			}
			g_deltaTime = (cast(float)(HipTime.getCurrentTime() - initTime) / 1.nsecs); //As seconds
			return true;
		}
	}
	return false;
}
version(Desktop)
{
	void HipremeDesktopGameLoop()
	{
		import hip.util.time;
		import core.time:dur;
		import core.thread.osthread;
		while(HipremeUpdateBase())
		{
			long initTime = HipTime.getCurrentTime();
			long sleepTime = cast(long)(FRAME_TIME - g_deltaTime.msecs);
			if(sleepTime > 0)
			{
				Thread.sleep(dur!"msecs"(sleepTime));
			}
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
export extern(C) void HipremeRender()
{
	import hip.bind.interpreters;
	HipRenderer.begin();
	HipRenderer.clear(0,0,0,255);
	sys.render();
	if(isUsingInterpreter)
		renderInterpreter();
	HipRenderer.end();
}
export extern(C) void HipremeDestroy()
{
	logln("Destroying HipremeEngine");
	destroyEngine();
	version(dll)
	{
		rt_term();
	}
}

export extern(C) void log(string message)
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
