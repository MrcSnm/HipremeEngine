import std.stdio;
import core.thread;
import sdl.loader;
import error.handler;
import global.consts;
import std.conv : to;
import global.assets;
import data.image;
import implementations.audio.audio;
import bindbc.sdl.mixer;
import bindbc.openal;
import implementations.audio.backend.alefx;
import sdl.event.dispatcher;
import sdl.event.handlers.keyboard;
version(Android)
{
	import jni.helper.androidlog;
	import core.runtime : rt_init;
}


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
		loadSDLLibs(audio3D);
}

static void list_audio_devices(const ALCchar *devices)
{
        const(char)* device = devices;
		const(char)* next = devices + 1;
        size_t len = 0;

        writeln("Devices list:\n");
        writeln("----------\n");
        while (device && *device != '\0' && next && *next != '\0') 
		{
			writefln("%s\n", to!string(device));
			import core.stdc.string:strlen;
			len = strlen(device);
			device += (len + 1);
			next += (len + 2);
        }
        writeln("----------\n");
}


extern(C)int SDL_main()
{
	initEngine(true);
	initializeWindow(&gWindow, &gScreenSurface);
	
	AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);
	Sound_AudioInfo info;
	
	info.channels=1;
	info.rate = 22_050;
	info.format = SDL_AudioFormat.AUDIO_S16;

	AudioSource sc = Audio.getSource(buf);
	Audio.setPitch(sc, 0.5);
	import def.debugging.runtime;
	
	
	Audio.play(sc);
	
	SDL_FillRect(gScreenSurface, null, SDL_MapRGB(gScreenSurface.format, 0xff, 0xff, 0x00));
	SDL_Surface* imgTeste;
	if(loadImage(Assets.Graphics.Sprites.teste_bmp))
	{
		imgTeste = getImage(Assets.Graphics.Sprites.teste_bmp);
		SDL_BlitSurface(imgTeste, null, gScreenSurface, null);
	}
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

	    // SDL_SetRenderDrawColor(renderer, r, g, b, 0xFF);
		// SDL_RenderClear(gWindow);
		// SDL_RenderPresent(gWindow);
		SDL_UpdateWindowSurface(gWindow);
		SDL_Delay(16);
	//	alSource3f(src, AL_POSITION, cos(angle) * 10, 0, sin(angle) * 10);
		angle+=angleSum;
		
	}

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
