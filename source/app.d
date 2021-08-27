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
	alias HipremeAndroid = javaGetPackage!("com.hipremeengine.app.HipremeEngine");
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
		// HipFS.install(HipremeAndroid.javaCall!(string, "getApplicationDir"));
		HipFS.install("");
		rawlog("Starting engine on android\nWorking Dir: ", HipFS.getPath(""));
	}
	else version(UWP)
	{
		Console.install(Platforms.UWP, &uwpPrint);
		HipFS.install(getcwd(), (string path, out string msg)
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
		Console.install();
		import std.file:getcwd;
		HipFS.install(getcwd());
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
extern(C)int SDL_main()
{
	import data.ini;
	initEngine(true);
	version(Android)
		HipAudio.initialize(HipAudioImplementation.OPENSLES);
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
	
	//AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);

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
	version(UWP){}
	else version(Android){}
	else
	{
		while(HipremeUpdate()){HipremeRender();}
		HipremeDestroy();
		destroyEngine();
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
	version(CIMGUI) DI.onDestroy();
	HipRenderer.dispose();
	HipAudio.onDestroy();
	sys.quit();
}



version(Android)
{
	extern(C) void Java_com_hipremeengine_app_HipremeEngine_HipremeInit(JNIEnv* env, jclass clazz)
	{
		HipremeInit();
		HipremeAndroid.setEnv(env);
		aaMgr = cast(AAssetManager*)HipremeAndroid.javaCall!(Object, "getAssetManager");
		aaMgr = AAssetManager_fromJava(env, aaMgr);
		
	}

	extern(C) jint Java_com_hipremeengine_app_HipremeEngine_HipremeMain(JNIEnv* env, jclass clazz)
	{
		int ret = HipremeMain();
		import hiprenderer.viewport;
		int[2] wsize = HipremeAndroid.javaCall!(int[2], "getWindowSize");
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
		HipremeAndroid.setEnv(null);
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
///Setup the engine
export extern(C) int HipremeMain(){return SDL_main();}
version(dll){}
else{void main(){HipremeMain();}}

///Steps an engine frame
export extern(C) bool HipremeUpdate()
{
	if(!sys.update())
		return false;
	sys.postUpdate();
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