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
		if(!loadCImGUI())
			writeln("Could not load dll");
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
	
	
	AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);

	Sound_AudioInfo info;
		
	info.channels=1;
	info.rate = 22_050;
	info.format = SDL_AudioFormat.AUDIO_S16;

	AudioSource sc = Audio.getSource(buf);
	Audio.setPitch(sc, 0.5);
	import def.debugging.runtime;

	DI.start(gWindow);
	Audio.play(sc);
	
	// SDL_FillRect(gScreenSurface, null, SDL_MapRGB(gScreenSurface.format, 0xff, 0xff, 0x00));
	// SDL_Surface* imgTeste;
	// if(loadImage(Assets.Graphics.Sprites.teste_bmp))
	// {
	// 	imgTeste = getImage(Assets.Graphics.Sprites.teste_bmp);
	// 	SDL_BlitSurface(imgTeste, null, gScreenSurface, null);
	// }
	bool quit = false;
	KeyboardHandler kb = new KeyboardHandler();

	

	// _Key k = new class _Key
	// {
	// 	override void onDown(){quit = true;}
	// 	override void onUp(){}
	// };
	// kb.addKeyListener(SDL_Keycode.SDLK_ESCAPE, k);
	// 	override void onDown(){import util.time : Time; writeln(this.meta.getDowntimeDuration());}
	// kb.addKeyListener(SDL_Keycode.SDLK_a, new class _Key
	// {
	// 	override void onUp(){}
	// });
	// kb.rebind(k, SDLK_F10);

	// EventDispatcher ev = new EventDispatcher(&kb);

	float angle=0;
	float angleSum = 0.01;
	import std.math:sin,cos;
	bool show_demo_window = true;
    bool show_another_window = false;
	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
	
	while(!quit)
	{
	// 	ev.handleEvent();
	    SDL_Event e;
		while(SDL_PollEvent(&e)) 
		{
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
        DI.update();

        // 1. Show the big demo window (Most of the sample code is in igShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (show_demo_window)
             igShowDemoWindow(&show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {
			import implementations.imgui.imgui_debug;
            static float f = 1f;
			static float v = 1f;
			
			Audio.setPitch(sc, f);
			Audio.setVolume(sc, v);
            static int counter = 0;
			

            igBegin("Hello, world!", null,0);                          // Create a window called "Hello, world!" and append into it.


            igText("This is some useful text.");               // Display some text (you can use a format strings too)
            igCheckbox("Demo Window", &show_demo_window);      // Edit bools storing our window open/close state
            igCheckbox("Another Window", &show_another_window);

            igSliderFloat("pitch", &f, 0.1f, 4.0f, null, 0);            // Edit 1 float using a slider from 0.0f to 1.0f
            igSliderFloat("voolume", &v, 0.1f, 4.0f, null, 0);            // Edit 1 float using a slider from 0.0f to 1.0f
            igColorEdit4("clear color", cast(float*)&clear_color,0); // Edit 3 floats representing a color

            if (igButton("Button".ptr, ImVec2()))                            // Buttons return true when clicked (most widgets return true when edited/activated)
                counter++;
            igSameLine(0,0);
            igText("counter = %d", counter);

            igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / igGetIO().Framerate, igGetIO().Framerate);
            igEnd();
			igBegin("New Window!", null, 0);
			igSameLine(0,0);
			igText("Hello Worlder");
			igSameLine(0,0);
			igText("Hello Worlder");
			igEnd();
        }

        // 3. Show another simple window.
        if (show_another_window)
        {
            igBegin("Another Window", &show_another_window, 0);   // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            igText("Hello from another window!");
            if (igButton("Close Me".ptr, ImVec2()))
                show_another_window = false;
            igEnd();
        }

        // Rendering
		// glViewport(0, 0, cast(int)io.DisplaySize.x, cast(int)io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
		DI.render();

        SDL_GL_SwapWindow(gWindow);
		
		// SDL_UpdateWindowSurface(gWindow);
		// SDL_Delay(16);
    }
	
		//////////END IMGUI

	    // SDL_SetRenderDrawColor(renderer, r, g, b, 0xFF);
		// SDL_RenderClear(gWindow);
		// SDL_RenderPresent(gWindow);
	//	alSource3f(src, AL_POSITION, cos(angle) * 10, 0, sin(angle) * 10);
		angle+=angleSum;
		
	// Cleanup

	SDL_GL_DeleteContext(SDL_GL_GetCurrentContext());


	exitEngine(&gWindow);
	Audio.onDestroy();

	return 1;
}

version(Android){}
else
{
	void main()
	{
		SDL_main();		
	}
}
