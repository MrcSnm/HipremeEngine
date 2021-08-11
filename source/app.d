import def.debugging.log;
import core.thread;
import sdl.loader;
import error.handler;
import global.consts;
import std.conv : to;
import global.assets;
import implementations.audio.audio;
import bindbc.sdl;
import bindbc.opengl;
import bindbc.openal;
import implementations.audio.backend.alefx;
import sdl.event.dispatcher;
import sdl.event.handlers.keyboard;
version(Android)
{
	import jni.helper.androidlog;
	import core.runtime : rt_init;
}
import bindbc.cimgui;
import math.matrix;
import implementations.renderer.renderer;
import implementations.renderer.backend.d3d.renderer;
import view;
import systems.game;
import def.debugging.gui;


/** 
 * Fast access for SDL Event Types
 */
// immutable SDL_EventType types;

static SDL_Surface* gScreenSurface = null;

static void initEngine(bool audio3D = false)
{
	import core.runtime;
	import def.debugging.console;
	import bind.external;
	version(dll)
	{
		rt_init();
		importExternal();
	}
	version(Android)
	{
		alogi("D_LANG", "Came here");
		alogi("HipremeEngine", "Starting engine on android");
		Console.install(Platforms.ANDROID);
	}
	else version(UWP){Console.install(Platforms.UWP, &uwpPrint);}
	else{Console.install();}
	version(BindSDL_Static){}
	else
	{
		loadSDLLibs(audio3D);
		import implementations.imgui.imgui_impl_sdl;
		import bindbc.loader : SharedLib;
		void function(SharedLib) implementation = null;
		static if(!CIMGUI_USER_DEFINED_IMPLEMENTATION)
			implementation = &bindSDLImgui;

		if(!loadcimgui(implementation))
		{
			logln("Could not load cimgui");
		}
	}
}


GameSystem sys;
extern(C)int SDL_main()
{
	import data.ini;
	import def.debugging.console;
	initEngine(true);
	version(dll)
	{
		version(UWP){HipRenderer.initExternal(HipRendererType.D3D11);}
	}
	else{HipRenderer.init("renderer.conf");}
	
	//AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);
	Sound_AudioInfo info;
	info.channels=1;
	info.rate = 22_050;
	info.format = SDL_AudioFormat.AUDIO_S16;

	//AudioSource sc = Audio.getSource(buf);
	//Audio.setPitch(sc, 1);
	// import def.debugging.runtime;
	// import global.fonts.icons;
	// import implementations.imgui.imgui_impl_opengl3;
	// DI.start(HipRenderer.window);
	// ImFontConfig cfg = DI.getDefaultFontConfig("Default + Icons");
	// ImFontAtlas_AddFontDefault(igGetIO().Fonts, &cfg);
	// DI.mergeFont("assets/fonts/"~FontAwesomeSolid, 16, FontAwesomeRange, &cfg);
	// ImGui_ImplOpenGL3_CreateFontsTexture();

	
	//Audio.play(sc);
	
	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
	sys = new GameSystem();
	version(UWP){}
	else
	{
		while(HipremeUpdate()){}
		HipremeDestroy();
		destroyEngine();
	}
	return 1;
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
	//	alSource3f(src, AL_POSITION, cos(angle) * 10, 0, sin(angle) * 10);
	// Cleanup
}

/** 
 * This function will destroy SDL and dispose every resource
 */
static void destroyEngine()
{
    //HipAssetManager.disposeResources();
	DI.onDestroy();
	HipRenderer.dispose();
	Audio.onDestroy();
    SDL_Quit();
}

version(Android){}
else
{
	void main()
	{
		SDL_main();		
	}
}


export extern(C) int HipremeMain(){return SDL_main();}
export extern(C) bool HipremeUpdate()
{
	rawlog("Mrc");
	if(!sys.update())
		return false;
	HipRenderer.begin();
	HipRenderer.clear(0,0,0,255);
	sys.render();
	HipRenderer.end();
	sys.postUpdate();
	return true;
}
export extern(C) void HipremeDestroy()
{
	destroyEngine();
}