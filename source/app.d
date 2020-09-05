import std.stdio;
import sdl.loader;
import error.handler;
import global.consts;
import std.conv : to;
import global.assets;
import data.image;
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

static void initEngine()
{
	version(Android)
	{
		rt_init();
		alogi("D_LANG", "Came here");
		alogi("HipremeEngine", "Starting engine on android");
	}
	version(BindSDL_Static){}
	else
		loadSDLLibs();
}


extern(C)int SDL_main()
{
	initEngine();
	initializeWindow(&gWindow, &gScreenSurface);
	SDL_FillRect(gScreenSurface, null, SDL_MapRGB(gScreenSurface.format, 0xff, 0xff, 0x00));
	
	SDL_Surface* imgTeste;
	if(loadImage(Assets.Graphics.Sprites.teste_bmp))
	{
		imgTeste = getImage(Assets.Graphics.Sprites.teste_bmp);
		SDL_BlitSurface(imgTeste, null, gScreenSurface, null);
	}
	bool quit = false;
	// KeyboardHandler kb = new KeyboardHandler();

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
	}

	exitEngine(&gWindow);
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
