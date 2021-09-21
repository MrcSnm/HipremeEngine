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
private import event.dispatcher;
private import event.handlers.keyboard;
import std.typecons:Tuple;
import view;


private bool getDubError(Tuple!(int, "status", string, "output") dubObj, out string err)
{
    import console.log;
    if(dubObj.status != 2)
    {
        import core.stdc.stdlib:exit;
        rawlog("Dub error: ", dubObj);
        exit(1);
    }
    else
    {
        import util.string:indexOf, lastIndexOf;
        long errInd = dubObj.output.indexOf("Warning:");
        if(errInd == -1)
            errInd = dubObj.output.indexOf("Error:"); //Check first for warnings
        if(errInd == -1) return false;
        errInd = dubObj.output.lastIndexOf("\n", errInd)-1;
        err = dubObj.output[errInd..$];
        return true;
    }
}

extern(C) AScene function() HipremeEngineGameInit;
extern(C) void function() HipremeEngineGameDestroy;



class GameSystem
{
    /** 
     * Holds the member that generates the events as inputs
     */
    EventDispatcher dispatcher;
    KeyboardHandler keyboard;
    AScene[] scenes;
    string projectDir;
    protected static AScene externalScene;
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
        {
            projectDir = buildNormalizedPath("projects", gameDll);
            gameDll = buildNormalizedPath("projects", gameDll, gameDll);
        }

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

    void recompileGame()
    {
        import std.process:executeShell;
        auto dub = executeShell("cd "~projectDir~" && dub");
        
        //2 == up to date
        string err;
        if(getDubError(dub, err))
        {
            import core.sys.windows.windows;
            import std.stdio;
            MessageBoxA(null, (err~"\0").ptr, "GameDLL Compilation Failure\0".ptr,  MB_ICONERROR | MB_OK);
        }
        hotload.reload();
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
        keyboard.addKeyListener(SDLK_ESCAPE, new class HipButton
        {
            override void onDown(){hasFinished = true;}
            override void onUp(){}
        });

        keyboard.addKeyListener(SDLK_F5, new class HipButton
        {
            override void onDown()
            {
            }
            override void onUp()
            {
                import util.array:remove;
                if(hotload)
                {
                    HipremeEngineGameDestroy();
                    scenes.remove(externalScene);
                    externalScene = null;
                    recompileGame(); // Calls hotload.reload();
                    startExternalGame();
                }
            }
        });
        dispatcher = new EventDispatcher(&keyboard);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.width = width;
            HipRenderer.height = height;
            foreach (AScene s; scenes)
                s.onResize(width, height);
        });
    }

    void addScene(AScene s)
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
        foreach (AScene s; scenes)
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
            if(HipremeEngineGameDestroy != null)
                HipremeEngineGameDestroy();
            scenes.length = 0;
            externalScene = null;
            hotload.dispose();
        }
        SDL_Quit();
    }
}