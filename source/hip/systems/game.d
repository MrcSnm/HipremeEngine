/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.systems.game;
import hip.global.gamedef;
import hip.hipaudio.audio;
import hip.view;
import hip.error.handler;
import hip.api.view.scene;

import hip.systems.timer_manager;
import hip.event.dispatcher;
import hip.event.handlers.keyboard;
import hip.event.handlers.mouse;
import hip.windowing.events;
import hip.hiprenderer.renderer;
import hip.graphics.g2d.renderer2d;
public import hip.event.handlers.input_listener;

version(Load_DScript)
{
    import hip.systems.hotload;
    import hip.systems.compilewatcher;
    import std.typecons:Tuple;
    private bool getDubError(Tuple!(int, "status", string, "output") dubObj, out string err)
    {
        import hip.console.log;
        if(dubObj.status != 2)
        {
            import core.stdc.stdlib:exit;
            import std.stdio;
            writeln("Dub error: ", dubObj);
            exit(1); 
        }
        else
        {
            import hip.util.string:indexOf, lastIndexOf;
            int errInd = dubObj.output.indexOf("Warning:");
            if(errInd == -1)
                errInd = dubObj.output.indexOf("Error:"); //Check first for warnings
            if(errInd == -1) return false;
            errInd = dubObj.output.lastIndexOf("\n", errInd)-1;
            err = dubObj.output[errInd..$];
            return true;
        }
    }
    extern(System) AScene function() HipremeEngineGameInit;
    extern(System) void function() HipremeEngineGameDestroy;
}


class GameSystem
{
    /** 
     * Holds the member that generates the events as inputs
     */
    EventDispatcher dispatcher;
    AScene[] scenes;

    HipInputListener inputListener;
    HipInputListener scriptInputListener;
    string projectDir;
    protected __gshared AScene externalScene;

    version(Load_DScript)
    {
        static CompileWatcher watcher;
        protected static HotloadableDLL hotload;
    }
    bool hasFinished;
    float fps = 0;
    float targetFPS = 0;
    float fpsAccumulator = 0;
    size_t frames = 0;

    this(float targetFPS)
    {
        this.targetFPS = targetFPS;
        dispatcher = new EventDispatcher(HipRenderer.window);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.setWindowSize(width, height);
            resizeRenderer2D(width, height);
            foreach (AScene s; scenes)
                s.onResize(width, height);
        });
        inputListener = new HipInputListener(dispatcher);
        scriptInputListener = new HipInputListener(dispatcher);
        inputListener.addKeyboardListener(HipKey.ESCAPE, 
            (meta){hasFinished = true;}
        );
        inputListener.addKeyboardListener(HipKey.F1, 
            (meta){import hip.bind.interpreters; reloadInterpreter();},
            HipButtonType.up
        );

        version(Load_DScript)
        {
            inputListener.addKeyboardListener(HipKey.F5,(meta)
                {
                    import hip.console.log;
                    rawlog("Recompiling and Reloading game ");
                    recompileReloadExternalScene();
                }, HipButtonType.up
            );
        }

        
        
    }

    void loadGame(string gameDll)
    {
        version(Load_DScript)
        {
            import hip.filesystem.hipfs;
            import hip.util.path;
            import hip.util.system;
            import hip.util.string:indexOf;
            import hip.console.log;


            if(gameDll.isAbsolutePath && HipFS.absoluteIsFile(gameDll))
            {
                projectDir = gameDll.dirName;
            }
            else if(!gameDll.extension && gameDll.indexOf("projects/") == -1)
            {
                projectDir = joinPath("projects", gameDll);
                gameDll = joinPath("projects", gameDll, gameDll);
            }
            else
                projectDir = gameDll;

            watcher = new CompileWatcher(projectDir, null, ["d"]).run;

            hotload = new HotloadableDLL(gameDll, (void* lib)
            {
                ErrorHandler.assertLazyExit(lib != null, "No library " ~ gameDll ~ " was found");
                HipremeEngineGameInit = 
                    cast(typeof(HipremeEngineGameInit))
                    dynamicLibrarySymbolLink(lib, "HipremeEngineGameInit");
                ErrorHandler.assertLazyExit(HipremeEngineGameInit != null,
                "HipremeEngineGameInit wasn't found when looking into "~gameDll);
                HipremeEngineGameDestroy = 
                    cast(typeof(HipremeEngineGameDestroy))
                    dynamicLibrarySymbolLink(lib, "HipremeEngineGameDestroy");
                ErrorHandler.assertLazyExit(HipremeEngineGameDestroy != null,
                "HipremeEngineGameDestroy wasn't found when looking into "~gameDll);
            });
        }
    }

    void recompileGame()
    {
        version(Load_DScript)
        {
            import std.process:executeShell;
            import std.stdio;
            auto dub = executeShell("cd "~projectDir~" && dub");

            writeln(projectDir);
            writeln(dub);
            
            //2 == up to date
            string err;
            if(getDubError(dub, err))
            {
                version(Windows)
                {
                    import core.sys.windows.winuser;
                    MessageBoxA(null, (err~"\0").ptr, "GameDLL Compilation Failure\0".ptr,  MB_ICONERROR | MB_OK);
                }
                import hip.console.log;
                loglnError(err, " GameDLL Compilation Failure");
            }
            hotload.reload();
        }
    }

    void startGame()
    {
        version(Test)
        {
            // addScene(new SoundTestScene());
            // addScene(new ChainTestScene());
            // addScene(new AssetTest());
            import hip.view.testscene;
            addScene(new TestScene());
        }
        else version(Load_DScript)
        {
            ErrorHandler.assertExit(HipremeEngineGameInit != null, "No game was loaded");
            externalScene = HipremeEngineGameInit();
            addScene(externalScene);
        }
        else version(Standalone)
        {
            import script.entry;
            externalScene = new HipEngineMainScene();
            addScene(externalScene);
        }
    }

    void recompileReloadExternalScene()
    {
        version(Load_DScript)
        {
            import hip.util.array:remove;
            import hip.console.log;
            if(hotload)
            {
                rawlog("Recompiling game");
                HipTimerManager.clearSchedule();
                HipremeEngineGameDestroy();
                scenes.remove(externalScene);
                externalScene = null;
                recompileGame(); // Calls hotload.reload();
                startGame();
            }
        }
    }

    /**
    *   Adding a scene will initialize them, while checking for assets referencing for auto loading them.
    */
    void addScene(AScene s)
    {
        import hip.console.log;
        import hip.assetmanager;
        logln("Initializing scene ", s.getName);
    	s.initialize();

        scenes~= s;
    }

    bool update(float deltaTime)
    {
        import hip.assetmanager;
        import std.stdio;
        frames++;
        fpsAccumulator+= deltaTime;
        if(fpsAccumulator >= 1.0)
        {
            import hip.console.log;
            // logln("FPS: ", frames);
            frames = 0;
            fpsAccumulator = 0;
        }
        HipAudio.update();
        HipTimerManager.update(deltaTime);
        HipAssetManager.update();
        
        version(Load_DScript)
        {
            if(watcher.update())
                recompileReloadExternalScene();
        }
        dispatcher.handleEvent();
        dispatcher.pollGamepads(deltaTime);
        inputListener.update();
        scriptInputListener.update();

        if(hasFinished || dispatcher.hasQuit)
            return false;
        foreach(s; scenes)
        {
            if(s is null)
            {
                import hip.console.log;
                logln("SCENE IS NULL");
            }
            else
                s.update(deltaTime);
        }

        return true;
    }
    void render()
    {
        foreach (AScene s; scenes)
            s.render();
        HipTimerManager.render();
    }
    void postUpdate()
    {
        dispatcher.postUpdate();
    }
    
    void quit()
    {
        version(Load_DScript)
        {
            if(hotload !is null)
            {
                destroy(watcher);
                if(HipremeEngineGameDestroy != null)
                    HipremeEngineGameDestroy();
                scenes.length = 0;
                externalScene = null;
                hotload.dispose();
            }
        }
        import hip.assetmanager;
        HipAssetManager.dispose();
 
    }
}