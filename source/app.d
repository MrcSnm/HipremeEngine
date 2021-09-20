/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/
import console.log;
import console.console;
import bind.external;
import data.hipfs;
import error.handler;
import global.consts;
import hipaudio.audio;
version(Android)
{
	import jni.helper.androidlog;
	import jni.jni;
	import jni.helper.jnicall;
	///Setups an Android Package for HipremeEngine
	alias HipAndroid = javaGetPackage!("com.hipremeengine.app.HipremeEngine");
}
version(Windows)
{
	import hiprenderer.backend.d3d.renderer;
}
version(dll)
{
	import core.runtime;
}
import hiprenderer.renderer;
import view;
import systems.game;
import debugging.gui;
/**
* Compiling instructions:

* Desktop: dub
* UWP: dub build -c uwp
* Android: dub build -c android --compiler=ldc2 -a aarch64--linux-android
*/



static void initEngine(bool audio3D = false)
{
	version(Android)
	{
		Console.install(Platforms.ANDROID);
		// HipFS.install(HipAndroid.javaCall!(string, "getApplicationDir"));
		HipFS.install("");
		rawlog("Starting engine on android\nWorking Dir: ", HipFS.getPath(""));
	}
	else version(UWP)
	{
		import std.file:getcwd;
		Console.install(Platforms.UWP, &uwpPrint);
		HipFS.install(getcwd()~"\\UWPResources\\", (string path, out string msg)
		{
			if(!HipFS.exists(path))
			{
				msg = "File at path "~HipFS.getPath(path)~" does not exists. Did you forget to add it to the AppX Resources?";
				return false;
			}
			return true;
		});
	}
	else
	{
		import std.file:getcwd;
		Console.install();
		HipFS.install(getcwd()~"/assets");
	}
	version(BindSDL_Static){}
	else
	{
		import bind.dependencies;
		rawlog("Initializing SDL");
		loadEngineDependencies();
	}
}

///Globally shared for accessing it on Android Game Thread
__gshared GameSystem sys;
__gshared float g_deltaTime = 0;
enum float FRAME_TIME = 1000/60; //60 frames per second

extern(C)int SDL_main()
{
	import data.ini;
	initEngine(true);
	version(Android)
		HipAudio.initialize(HipAudioImplementation.OPENSLES, 
		HipAndroid.javaCall!(bool, "hasProFeature"),
		HipAndroid.javaCall!(bool, "hasLowLatencyFeature"),
		HipAndroid.javaCall!(int, "getOptimalAudioBufferSize"),
		HipAndroid.javaCall!(int, "getOptimalSampleRate"));
	else
		HipAudio.initialize();
	version(dll)
	{
		version(UWP){HipRenderer.initExternal(HipRendererType.D3D11);}
		else version(Android)
		{
			HipRenderer.initExternal(HipRendererType.GL3);
		}
	}
	else{HipRenderer.init("renderer.conf");}

	//Initialize 2D context
	import graphics.g2d;
	HipRenderer2D.initialize();
	

	//AudioSource sc = Audio.getSource(buf);
	//Audio.setPitch(sc, 1);
	// import debugging.runtime;
	// import imgui.fonts.icons;
	// import implementations.imgui.imgui_impl_opengl3;
	// DI.start(HipRenderer.window);
	// ImFontConfig cfg = DI.getDefaultFontConfig("Default + Icons");
	// ImFontAtlas_AddFontDefault(igGetIO().Fonts, &cfg);
	// DI.mergeFont("assets/fonts/"~FontAwesomeSolid, 16, FontAwesomeRange, &cfg);
	// ImGui_ImplOpenGL3_CreateFontsTexture();

	
	//Audio.play(sc);
	
	// ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
	sys = new GameSystem();
	sys.loadGame("TestScene");
	sys.startExternalGame();
	version(UWP){}
	else version(Android){}
	else
	{
		while(HipremeUpdate())
		{
			HipremeRender();
		}
		HipremeDestroy();
	}
	return 0;
	///////////START IMGUI
	// Start the Dear ImGui frame
	// DI.begin();
	// static bool open = true;
	// igShowDemoWindow(&open);
	// import implementations.imgui.imgui_debug;
	// addDebug!(s);

	// if(igButton("Viewport flag".ptr, ImVec2(0,0)))
	// {
	// 	//logln!(igGetIO().ConfigFlags);
	// 	igGetIO().ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
	// }

	// // Rendering
	// DI.end();
	// Cleanup
}

/** 
 * This function will destroy SDL and dispose every resource
 */
static void destroyEngine()
{
    //HipAssetManager.disposeResources();
	sys.quit();
	version(CIMGUI) DI.onDestroy();
	HipRenderer.dispose();
	HipAudio.onDestroy();
}



version(Android)
{
	import systems.input;
	
	extern(C) void Java_com_hipremeengine_app_HipremeEngine_HipremeInit(JNIEnv* env, jclass clazz)
	{
		HipremeInit();
		HipAndroid.setEnv(env);
		aaMgr = cast(AAssetManager*)HipAndroid.javaCall!(Object, "getAssetManager");
		aaMgr = AAssetManager_fromJava(env, aaMgr);
	}

	extern(C) jint Java_com_hipremeengine_app_HipremeEngine_HipremeMain(JNIEnv* env, jclass clazz)
	{
		int ret = HipremeMain();
		import hiprenderer.viewport;
		int[2] wsize = HipAndroid.javaCall!(int[2], "getWindowSize");
		HipRenderer.setViewport(new Viewport(0, 0, wsize[0], wsize[1]));
		return ret;
	}
	extern(C) jboolean Java_com_hipremeengine_app_HipremeEngine_HipremeUpdate(JNIEnv* env, jclass clazz)
	{
		return HipremeUpdate();
	}
	extern(C) void Java_com_hipremeengine_app_HipremeEngine_HipremeRender(JNIEnv* env, jclass clazz)
	{
		HipremeRender();
	}
	extern(C) void  Java_com_hipremeengine_app_HipremeEngine_HipremeDestroy(JNIEnv* env, jclass clazz)
	{
		HipAndroid.setEnv(null);
		HipremeDestroy();
	}
}  

///Initializes the D runtime and import external functions
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
export extern(C) int HipremeMain(){return SDL_main();}
version(dll){}
else{void main(){HipremeMain();}}

///Steps an engine frame
export extern(C) bool HipremeUpdate()
{
	import util.time;
	import core.thread.osthread;
	long initTime = HipTime.getCurrentTime();
	if(g_deltaTime != 0)
	{
		long sleepTime = cast(long)(FRAME_TIME - g_deltaTime);
		if(sleepTime > 0)
			Thread.sleep(dur!"msecs"(sleepTime));
	}
	if(!sys.update(g_deltaTime))
		return false;
	sys.postUpdate();
	g_deltaTime = (cast(float)(HipTime.getCurrentTime() - initTime) / 1_000_000_000); //As seconds

	return true;
}
/**
* This function was created for making it rendering optional. On Android, 
* the game is only rendered when the renderer is dirty, it is absolutely
* not recommended to do game logic on the render
*/
export extern(C) void HipremeRender()
{
	HipRenderer.begin();
	HipRenderer.clear(0,0,0,255);
	sys.render();
	HipRenderer.end();
}
export extern(C) void HipremeDestroy()
{
	destroyEngine();
	version(dll)
	{
		rt_term();
	}
}

export extern(C) void log(string log)
{
	import console.log;
	rawlog(log);
}