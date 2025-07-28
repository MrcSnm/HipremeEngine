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
import hip.audio;
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

version(WebAssembly) version = CustomRuntime;
version(CustomRuntimeTest) version = CustomRuntime;
version(PSVita) version = CustomRuntime;

version(Standalone)
{
    pragma(mangle, "HipremeEngineMainScene")
    extern(C) AScene HipremeEngineMainScene();
}

version(Load_DScript)
{
    import hip.systems.hotload;
    import hip.systems.compilewatcher;
    private bool getDubError(string line)
    {
        import hip.console.log;
        import hip.util.string:indexOf, lastIndexOf;
        int errInd = line.indexOf("Warning:");
        if(errInd == -1) errInd = line.indexOf("Error:"); //Check first for warnings
        return errInd != -1;
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
    string projectDir, buildCommand = "redub build";
    ///Resets delta time after a reload for not jumping frames.
    protected bool shouldResetDelta;
    protected __gshared AScene externalScene;

    version(Load_DScript)
    {
        static CompileWatcher watcher;
        protected static HotloadableDLL hotload;
    }
    bool hasFinished;
    bool isInUpdate;
    float fps = 0;
    float targetFPS = 0;
    float fpsAccumulator = 0;
    size_t frames = 0;

    this(float targetFPS)
    {
        this.targetFPS = targetFPS;
        dispatcher = new EventDispatcher(HipRenderer.window, &this.isInUpdate);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.width  = width;
            HipRenderer.height = height;
            resizeRenderer2D(width, height);
            foreach (AScene s; scenes)
                s.onResize(width, height);
        });
        inputListener = new HipInputListener(dispatcher);
        scriptInputListener = new HipInputListener(dispatcher);

        import hip.console.log;
        inputListener.addKeyboardListener(HipKey.ESCAPE,
            (meta){hasFinished = true;}
        );
        // inputListener.addKeyboardListener(HipKey.F1,
        //     (meta){import hip.bind.interpreters; reloadInterpreter();},
        //     HipButtonType.up
        // );

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

    void loadGame(string gameDll, string buildCommand)
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
            this.buildCommand = buildCommand ? buildCommand : this.buildCommand;

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
            scope string[] errors;
            import hip.console.log;

            static void logFun(string line)
            {
                rawlog(line);
            }

            int status = hip.systems.compilewatcher.recompileGame(projectDir, buildCommand, &getDubError, &logFun,  errors);
            //2 == up to date
            if(errors.length)
            {
                loglnError(errors);
                foreach(err; errors) loglnError(err);
            }
            else
                hotload.reload();
        }
    }

    void startGame()
    {
        import hip.view.load_scene;
        import hip.assetmanager;
        version(Test)
        {
            // addScene(new SoundTestScene());
            // addScene(new ChainTestScene());
            // addScene(new AssetTest());
            import hip.view.testscene;
            import hip.console.log;
            import hip.api.data.commons;
            mixin LoadReferencedAssets!(["hip.view.testscene"]);
            loadReferenced;
            hiplog("starting test scene.");
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
            import hip.console.log;
            hiplog("Starting Game");
            externalScene = HipremeEngineMainScene();
            addScene(externalScene);
        }

        LoadingScene load = new LoadingScene();
        addScene(load, false);
        HipAssetManager.addOnLoadingFinish(()
        {
            removeScene(load);
        });
    }

    void recompileReloadExternalScene()
    {
        version(Load_DScript)
        {
            import hip.util.array:remove;
            import hip.console.log;
            if(hotload)
            {
                shouldResetDelta = true;
                rawlog("Recompiling game");
                HipTimerManager.clearSchedule();
                scriptInputListener.clearAll();
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
    void addScene(AScene s, bool isOnLoadFinish = true)
    {
        import hip.assetmanager;

        auto onLoadFn = ()
        {
            import hip.console.log;
            version(CustomRuntime)
            {
                s.preload();
                loglnWarn("Initializing scene ", s.getName);
                s.initialize();
                scenes~= s;
            }
            else
            {
                try{
                    s.preload();
                    loglnWarn("Initializing scene ", s.getName);
                    s.initialize();
                    scenes~= s;
                }
                catch (Error e){scriptFatalError(e);}
            }
        };
        if(isOnLoadFinish)
            HipAssetManager.addOnLoadingFinish(onLoadFn);
        else
            onLoadFn();
        // }
    }

    void removeScene(AScene s)
    {
        import hip.util.array:remove;
        remove(scenes, s);
    }


    bool update(float deltaTime)
    {
        import hip.assetmanager;
        isInUpdate = true;
        frames++;
        fpsAccumulator+= deltaTime;
        if(shouldResetDelta)
        {
            deltaTime = 0;
            shouldResetDelta = false;
        }
        if(fpsAccumulator >= 1.0)
        {
            import hip.console.log;
            // logln("FPS: ", frames);
            frames = 0;
            fpsAccumulator = 0;
        }
        import hip.console.log;

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
            import hip.console.log;
            version(CustomRuntime)
            {
                if(s is null) logln("SCENE IS NULL");
                else s.update(deltaTime);
            }
            else
            {
                try
                {
                    if(s is null) logln("SCENE IS NULL");
                    else s.update(deltaTime);
                }
                catch (Error e){scriptFatalError(e);}
            }
        }

        return true;
    }

    version(CustomRuntime){}
    else
    void scriptFatalError(Throwable e, string file = __FILE__, size_t line = __LINE__, string func = __PRETTY_FUNCTION__)
    {
        import hip.console.log;
        import hip.util.path;
        loglnError(e.msg, ". Project: (", projectDir, ") at file (", e.file, ":",e.line, ")");
        quit();
        ErrorHandler.assertExit(false, "Script Fatal Error", file, line, __MODULE__, func);
    }
    void render()
    {
        version(CustomRuntime)
        {
            foreach (AScene s; scenes)
                s.render();
        }
        else
        {
            try
            {
                foreach (AScene s; scenes)
                    s.render();
            }
            catch(Throwable e){scriptFatalError(e);}
        }
        HipTimerManager.render();
    }
    void postUpdate()
    {
        dispatcher.postUpdate();
        isInUpdate = false;
    }

    void quit()
    {
        version(Load_DScript)
        {
            if(hotload !is null)
            {
                if(HipremeEngineGameDestroy != null)
                    HipremeEngineGameDestroy();
                scenes.length = 0;
                externalScene = null;
                hotload.dispose();
                watcher.stop();
            }
        }
        import hip.assetmanager;
        HipAssetManager.dispose();

    }
}