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
import def.debugging.gui;


/** 
 * Fast access for SDL Event Types
 */
// immutable SDL_EventType types;

static SDL_Window* gWindow = null;
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

SDL_Window* createSDL_GL_Window()
{
	SDL_GL_LoadLibrary(null);

	//Set GL Version
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_ACCELERATED_VISUAL, 1);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MINOR_VERSION, 5);
	//Create window type
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_STENCIL_SIZE, 8);
	alias f = SDL_WindowFlags;
	SDL_WindowFlags flags = (f.SDL_WINDOW_OPENGL | f.SDL_WINDOW_RESIZABLE | f.SDL_WINDOW_ALLOW_HIGHDPI);

	SDL_Window* window = SDL_CreateWindow("GL Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, flags);
	SDL_GLContext ctx = SDL_GL_CreateContext(window);
	SDL_GL_MakeCurrent(window, ctx);
	GLSupport ver = loadOpenGL();
	
	writeln(ver);
	SDL_GL_SetSwapInterval(1);
	return window;
}


extern(C)int SDL_main()
{
	initEngine(true);
	gWindow = createSDL_GL_Window();
	//initializeWindow(&gWindow, &gScreenSurface);
	//AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);

	Sound_AudioInfo info;
		
	info.channels=1;
	info.rate = 22_050;
	info.format = SDL_AudioFormat.AUDIO_S16;

	//AudioSource sc = Audio.getSource(buf);
	//Audio.setPitch(sc, 1);
	import def.debugging.runtime;

	DI.start(gWindow);
	import global.fonts.icons;

	ImFontConfig cfg = DI.getDefaultFontConfig("Default + Icons");
	ImFontAtlas_AddFontDefault(igGetIO().Fonts, &cfg);
	DI.mergeFont("assets/fonts/"~FontAwesomeSolid, 16, FontAwesomeRange, &cfg);



	import implementations.imgui.imgui_impl_opengl3;
	//ImGui_ImplOpenGL3_CreateFontsTexture();
	
	//Audio.play(sc);
	
	// SDL_FillRect(gScreenSurface, null, SDL_MapRGB(gScreenSurface.format, 0xff, 0xff, 0x00));
	// SDL_Surface* imgTeste;
	// if(loadImage(Assets.Graphics.Sprites.teste_bmp))
	// {
	// 	imgTeste = getImage(Assets.Graphics.Sprites.teste_bmp);
	// 	SDL_BlitSurface(imgTeste, null, gScreenSurface, null);
	// }
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
			DI.update(&e);
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
        DI.begin();
        {
			import implementations.imgui.imgui_debug;
			// addDebug!(sc, AudioSource3D);
        }

		if(igButton("Viewport flag".ptr, ImVec2(0,0)))
		{
			//writeln(igGetIO().ConfigFlags);
			igGetIO().ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
		}

        // Rendering
		// glViewport(0, 0, cast(int)io.DisplaySize.x, cast(int)io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
		DI.end();

        SDL_GL_SwapWindow(gWindow);
		
		// SDL_UpdateWindowSurface(gWindow);
		// SDL_Delay(16);
    }
	    // SDL_SetRenderDrawColor(renderer, r, g, b, 0xFF);
		// SDL_RenderClear(gWindow);
		// SDL_RenderPresent(gWindow);
	//	alSource3f(src, AL_POSITION, cos(angle) * 10, 0, sin(angle) * 10);
		angle+=angleSum;
		
	// Cleanup

	destroyEngine();

	return 1;
}

static void destroyEngine()
{
	SDL_GL_DeleteContext(SDL_GL_GetCurrentContext());
	DI.onDestroy();

	exitEngine(&gWindow);
	Audio.onDestroy();
}

version(Android){}
else
{
	void main()
	{
		SDL_main();		
	}
}
