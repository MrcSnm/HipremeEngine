import std.stdio;
import core.thread;
import sdl.loader;
import error.handler;
import global.consts;
import std.conv : to;
import global.assets;
import data.image;
import sdl.event.dispatcher;
import sdl.event.handlers.keyboard;


/** 
 * Fast access for SDL Event Types
 */
immutable SDL_EventType types;


int main(string[] args)
{
	loadSDLLibs();
	initializeWindow(&gWindow, &gScreenSurface);
	SDL_FillRect(gScreenSurface, null, SDL_MapRGB(gScreenSurface.format, 0xff, 0xff, 0x00));
	
	SDL_Surface* imgTeste;
	if(loadImage(Assets.Graphics.Sprites.teste_bmp))
	{
		imgTeste = getImage(Assets.Graphics.Sprites.teste_bmp);
		SDL_BlitSurface(imgTeste, null, gScreenSurface, null);
	}
	bool quit = false;
	KeyboardHandler kb = new KeyboardHandler();

	_Key k = new class _Key
	{
		override void onDown(){quit = true;}
		override void onUp(){}
	};
	kb.addKeyListener(SDL_Keycode.SDLK_ESCAPE, k);
	kb.addKeyListener(SDL_Keycode.SDLK_a, new class _Key
	{
		override void onDown(){import util.time : Time; writeln(this.meta.getDowntimeDuration());}
		override void onUp(){}
	});
	kb.rebind(k, SDLK_F10);

	EventDispatcher ev = new EventDispatcher(&kb);

	while(!quit && !ev.hasQuit)
	{
		ev.handleEvent();
		SDL_UpdateWindowSurface(gWindow);
		Thread.sleep(16.msecs);
	}

	exitEngine(&gWindow);
	return 1;
}