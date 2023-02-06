module gamescript.entry;
import hip.api;
import hip.util.conv;
import hip.tween;
import hip.timer;

import gamescript.board;
import gamescript.background;
import gamescript.config;
import gamescript.game;
import gamescript.game_hud;
import gamescript.text;

//TODO: Future support for enums (need the recursive folder generator)
// import hip.assetmanager;
// mixin HipAssetsGenerateEnum!("assets");

class MainScene : AScene
{
	Game game;
	Board board;
	Text text;
	GameHud hud;

	mixin Preload;

	/** Constructor */	
	override void initialize()
	{
        logg("Hello World From Game");
		setFont(null);
		Viewport v = getCurrentViewport();
		v.type = ViewportType.fit;
		v.setWorldSize(GAME_WIDTH, GAME_HEIGHT);
		setCameraSize(GAME_WIDTH, GAME_HEIGHT);
		setViewport(v);

		logg([v.x, v.y, v.width, v.height, v.worldWidth, v.worldHeight]);

		game = new Game();

		hud = new GameHud(game);

		hud.showEnterToStartGame();

	}

	/** Called every frame */
	override void update(float dt)
	{
		game.update(dt);
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		game.render();
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}

	override void pushLayer(Layer l){}
	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;