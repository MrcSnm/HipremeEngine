
module systems.game;
import bindbc.sdl;
import hiprenderer.renderer;
import systems.hotload;
private import sdl.event.dispatcher;
private import sdl.event.handlers.keyboard;
import view;
extern (C) Scene function() HipremeEngineGameInit;
extern (C) void function() HipremeEngineGameDestroy;
class GameSystem
{
	EventDispatcher dispatcher;
	KeyboardHandler keyboard;
	Scene[] scenes;
	protected static Scene externalScene;
	protected static HotloadableDLL hotload;
	bool hasFinished;
	float fps;
	void loadGame(string gameDll);
	void startExternalGame();
	this()
	{
		keyboard = new KeyboardHandler;
		keyboard.addKeyListener(SDLK_ESCAPE, new class Key
		{
			override void onDown();
			override void onUp();
		}
		);
		keyboard.addKeyListener(SDLK_F5, new class Key
		{
			override void onDown();
			override void onUp();
		}
		);
		dispatcher = new EventDispatcher(&keyboard);
		dispatcher.addOnResizeListener((uint width, uint height)
		{
			HipRenderer.width = width;
			HipRenderer.height = height;
			foreach (Scene s; scenes)
			{
				s.onResize(width, height);
			}
		}
		);
	}
	void addScene(Scene s);
	bool update(float deltaTime);
	void render();
	void postUpdate();
	void quit();
}
