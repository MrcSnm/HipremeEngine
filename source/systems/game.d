/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module systems.game;
import bindbc.sdl;
import hiprenderer.renderer;
import systems.hotload;
private import sdl.event.dispatcher;
private import sdl.event.handlers.keyboard;
import view;



extern(C) Scene function() HipremeEngineGameInit;
extern(C) void function() HipremeEngineGameDestroy;

class GameSystem
{
    /** 
     * Holds the member that generates the events as inputs
     */
    EventDispatcher dispatcher;
    KeyboardHandler keyboard;
    Scene[] scenes;
    protected static Scene externalScene;
    protected static HotloadableDLL hotload;
    bool hasFinished;
    float fps;


    void loadGame(string gameDll)
    {
        import std.path:buildNormalizedPath;
        import util.system;
        import util.string:indexOf;
        import std.stdio;

        if(gameDll.indexOf("projects/") == -1)
            gameDll = buildNormalizedPath("projects", gameDll, gameDll);

        hotload = new HotloadableDLL(gameDll, (void* lib)
        {
            assert(lib != null, "No library " ~ gameDll ~ " was found");
            HipremeEngineGameInit = 
                cast(typeof(HipremeEngineGameInit))
                dynamicLibrarySymbolLink(lib, "HipremeEngineGameInit");
            assert(HipremeEngineGameInit != null,
            "HipremeEngineGameInit wasn't found when looking into "~gameDll);
            HipremeEngineGameDestroy = 
                cast(typeof(HipremeEngineGameDestroy))
                dynamicLibrarySymbolLink(lib, "HipremeEngineGameDestroy");
            assert(HipremeEngineGameDestroy != null,
            "HipremeEngineGameDestroy wasn't found when looking into "~gameDll);
        });
    }

    void startExternalGame()
    {
        assert(HipremeEngineGameInit != null, "No game was loaded");
        externalScene = HipremeEngineGameInit();
        addScene(externalScene);
    }

    this()
    {
        keyboard = new KeyboardHandler();
        keyboard.addKeyListener(SDLK_ESCAPE, new class Key
        {
            override void onDown(){hasFinished = true;}
            override void onUp(){}
        });

        keyboard.addKeyListener(SDLK_F5, new class Key
        {
            override void onDown(){}
            override void onUp()
            {
                import util.array:remove;
                if(hotload)
                {
                    scenes.remove(externalScene);
                    externalScene = null;
                    HipremeEngineGameDestroy();
                    hotload.reload();
                    HipremeEngineGameInit();
                    startExternalGame();
                }
            }
        });
        dispatcher = new EventDispatcher(&keyboard);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.width = width;
            HipRenderer.height = height;
            foreach (Scene s; scenes)
                s.onResize(width, height);
        });

    }

    void addScene(Scene s)
    {
    	s.init();
        scenes~= s;
    }

    bool update(float deltaTime)
    {
        fps = cast(float)cast(uint)(1/deltaTime);
        import std.conv:to;
        SDL_SetWindowTitle(HipRenderer.window, (to!string(fps)~" FPS\0").ptr);
        dispatcher.handleEvent();

        if(hasFinished || dispatcher.hasQuit)
            return false;
        version(Android){}
        else {keyboard.update();}
        foreach(s; scenes)
            s.update(deltaTime);

        return true;
    }
    void render()
    {
        foreach (Scene s; scenes)
            s.render();
    }
    void postUpdate()
    {
        dispatcher.postUpdate();
    }
    
    void quit()
    {
        if(hotload !is null)
        {
            scenes.length = 0;
            externalScene = null;
            if(HipremeEngineGameDestroy != null)
                HipremeEngineGameDestroy();
            hotload.dispose();
        }
        SDL_Quit();
    }
}