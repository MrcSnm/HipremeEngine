module hip.api;

import hip.console.log;
alias log = rawlog;
alias logg = logln;

public import hip.filesystem.hipfs;
public import hip.assetmanager;
public import hip.game.utils : HipGameUtils;
public import hip.systems.timer_manager : HipTimerManager;
public import HipDefaultAssets = hip.global.gamedef : getDefaultFont, getDefaultTexture, getDefaultFontWithSize;
///All other functions that are actually exported is expected to be in that module.
// public import exportd;
public import hip.global.gamedef;
public import hip.image_backend.impl: getDecoder;

public import hip.global.gamedef : HipInput, HipInputListener;
public import hip.network;
public import hip.graphics.g2d.renderer2d;
public import hip.filesystem.hipfs;
public import hip.audio;
public import hip.api.config;
public import hip.api.view.scene;
public import hip.api.renderer.core;


mixin template HipEngineMain(alias StartScene, HipAssetLoadStrategy strategy = HipAssetLoadStrategy.loadAll)
{
	immutable string ScriptModules = import("scriptmodules.txt");
	pragma(msg, ScriptModules);
    pragma(mangle, "HipremeEngineMainScene")
    export extern(C) AScene HipremeEngineMainScene()
    {
        mixin LoadAllAssets!(ScriptModules);
        loadReferenced();
        return new StartScene();
    }
}