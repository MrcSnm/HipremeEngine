/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module systems.game;
import bindbc.sdl;
import hiprenderer.renderer;
import global.gamedef;
private import event.dispatcher;
private import event.handlers.keyboard;
import view;


version(Standalone){}
else
{
    import systems.hotload;
    import systems.compilewatcher;
    import std.typecons:Tuple;
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
}


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

    version(Standalone){} else 
    {
        static CompileWatcher watcher;
        protected static HotloadableDLL hotload;
    }
    bool hasFinished;
    float fps;

    float targetFPS;

    this(float targetFPS)
    {
        this.targetFPS = targetFPS;
        keyboard = new KeyboardHandler();
        keyboard.addKeyListener(SDLK_ESCAPE, new class HipButton
        {
            override void onDown(){hasFinished = true;}
            override void onUp(){}
        });
        version(Standalone){}
        else
        {
            keyboard.addKeyListener(SDLK_F5, new class HipButton
            {
                override void onDown(){}
                override void onUp(){recompileReloadExternalScene();}
            });
        }

        dispatcher = new EventDispatcher(&keyboard);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.width = width;
            HipRenderer.height = height;
            foreach (AScene s; scenes)
                s.onResize(width, height);
        });
    }

    void loadGame(string gameDll)
    {
        version(Standalone){}
        else
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

            watcher = new CompileWatcher(projectDir, null, ["d"]).run;

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
    }

    void recompileGame()
    {
        version(Standalone){}
        else
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
    }

    void startExternalGame()
    {
        version(Standalone)
        {
            import script.entry;
            externalScene = new HipEngineMainScene();
            addScene(externalScene);
        }
        else
        {
            assert(HipremeEngineGameInit != null, "No game was loaded");
            externalScene = HipremeEngineGameInit();
            addScene(externalScene);
        }
    }

    void recompileReloadExternalScene()
    {
        version(Standalone){}
        else
        {
            import util.array:remove;
            import console.log;
            if(hotload)
            {
                rawlog("Recompiling game");
                HipremeEngineGameDestroy();
                scenes.remove(externalScene);
                externalScene = null;
                recompileGame(); // Calls hotload.reload();
                startExternalGame();
            }
        }
    }

    

    void addScene(AScene s)
    {
    	s.init();
        scenes~= s;
    }

    bool update(float deltaTime)
    {
        version(Standalone){}
        else
        {
            if(watcher.update())
                recompileReloadExternalScene();
        }
        dispatcher.handleEvent();
        dispatcher.pollGamepads(deltaTime);

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
        version(Standalone){}
        else
        {
            if(hotload !is null)
            {
                if(HipremeEngineGameDestroy != null)
                    HipremeEngineGameDestroy();
                destroy(watcher);
                scenes.length = 0;
                externalScene = null;
                hotload.dispose();
            }
        }
        SDL_Quit();
    }
}