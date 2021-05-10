import std.stdio;
import core.thread;
import sdl.loader;
import error.handler;
import global.consts;
import std.conv : to;
import global.assets;
import data.image;
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
import def.debugging.gui;


/** 
 * Fast access for SDL Event Types
 */
// immutable SDL_EventType types;

static SDL_Surface* gScreenSurface = null;

static void initEngine(bool audio3D = false)
{
	
	version(Android)
	{
		rt_init();
		alogi("D_LANG", "Came here");
		alogi("HipremeEngine", "Starting engine on android");
	}
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
			writeln("Could not load cimgui");
		}
	}
}




extern(C)int SDL_main()
{
	initEngine(true);
	HipRendererConfig cfg;
	HipRenderer.init(new Hip_GL3Renderer(), &cfg);
	import graphics.image;
	import graphics.g2d.sprite;
	Texture t = new Texture(Assets.Graphics.Sprites.teste_bmp);

	Sprite s = new Sprite(t);
	SDL_Rect clip = SDL_Rect(0,0,t.width/2,t.height);

	
	//AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);

	Sound_AudioInfo info;
		
	info.channels=1;
	info.rate = 22_050;
	info.format = SDL_AudioFormat.AUDIO_S16;

	//AudioSource sc = Audio.getSource(buf);
	//Audio.setPitch(sc, 1);
	import def.debugging.runtime;

	// DI.start(HipRenderer.window);
	import global.fonts.icons;

	// ImFontConfig cfg = DI.getDefaultFontConfig("Default + Icons");
	// ImFontAtlas_AddFontDefault(igGetIO().Fonts, &cfg);
	// DI.mergeFont("assets/fonts/"~FontAwesomeSolid, 16, FontAwesomeRange, &cfg);



	import implementations.imgui.imgui_impl_opengl3;
	//ImGui_ImplOpenGL3_CreateFontsTexture();
	
	//Audio.play(sc);
	
	bool quit = false;
	KeyboardHandler kb = new KeyboardHandler();

	

	Key k = new class Key
	{
		override void onDown(){quit = true;}
		override void onUp(){}
	};
	kb.addKeyListener(SDL_Keycode.SDLK_ESCAPE, k);
	kb.addKeyListener(SDL_Keycode.SDLK_a, new class Key
	{
		override void onDown(){import util.time : Time; writeln(this.meta.getDowntimeDuration());}
		override void onUp(){}
	});

	EventDispatcher ev = new EventDispatcher(&kb);

	float angle=0;
	float angleSum = 0.01;
	import std.math:sin,cos;
	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
	
	while(!quit)
	{
		ev.handleEvent();
	    SDL_Event e;
		while(SDL_PollEvent(&e)) 
		{
			// DI.update(&e);
			switch(e.type)
			{
				case SDL_QUIT:
					quit = true;
					break;
//				case SDL_KEYDOWN:
//					alogi("D_LANG", to!string(e.key.keysym.sym));
				default:break;
			}
		}


		///////////START IMGUI

		// Start the Dear ImGui frame
		HipRenderer.currentShader.setVar("proj", Matrix4.orthoLH(0, 800, 600, 0, 0, 1));
		HipRenderer.begin();
		HipRenderer.clear(255,0,0,255);
		// HipRenderer.drawLine(0, 0, 1, 1);
		HipRenderer.drawRect(0,0,0,0);
		HipRenderer.drawTriangle(0,0,0,0,0,0);
		// s.draw();
        HipRenderer.end();
        // DI.begin();
		// static bool open = true;
		// igShowDemoWindow(&open);
		// import implementations.imgui.imgui_debug;
		// addDebug!(s);

		// if(igButton("Viewport flag".ptr, ImVec2(0,0)))
		// {
		// 	//writeln(igGetIO().ConfigFlags);
		// 	igGetIO().ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
		// }

        // // Rendering
		// // glViewport(0, 0, cast(int)io.DisplaySize.x, cast(int)io.DisplaySize.y);
		
		// DI.end();

	
    }
	//	alSource3f(src, AL_POSITION, cos(angle) * 10, 0, sin(angle) * 10);
		angle+=angleSum;
		
	// Cleanup

	destroyEngine();

	return 1;
}

/** 
 * This function will destroy SDL and dispose every resource
 */
static void destroyEngine()
{
    ResourceManager.disposeResources();
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
