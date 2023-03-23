module hip.api.impl;

version(Have_hipreme_engine) version = DirectCall;

//Console
public import hip.api.console;

//Assets
public import hip.api.data.textureatlas;
public import hip.api.data.tilemap;
public import hip.api.data.csv;
public import hip.api.data.ini;
public import hip.api.data.jsonc;

//Rendering
public import hip.api.graphics.color;
public import hip.api.renderer.texture;
public import hip.api.renderer.viewport;
public import hip.api.graphics.g2d.renderer2d;

//View
public import hip.api.view.scene;

//File system
public import hip.api.filesystem.hipfs;

//Audio
public import hip.api.audio;


//Game
public import hip.api.systems.timer;

//Input
public import HipInput = hip.api.input;
public import hip.api.input.button:AutoRemove, HipButtonType;
public import hip.api.input.keyboard : HipKey;
public import hip.api.input.gamepad;
public import hip.api.input.mouse : HipMouseButton;
alias IHipInputMap = HipInput.IHipInputMap;


//Realiasing based on function pointers

version(DirectCall)
{
    public import hip.filesystem.hipfs;
    public import hip.assetmanager;
    public import hip.game.utils : HipGameUtils;
    public import hip.systems.timer_manager : HipTimerManager;
    public import HipDefaultAssets = hip.global.gamedef : getDefaultFont, getDefaultTexture, getDefaultFontWithSize;
    ///All other functions that are actually exported is expected to be in that module.
    // public import exportd;
}
else
{
	public import HipFS = hip.api.filesystem.definitions;
    public import HipAssetManager = hip.api.assets.assets_binding;
    public import hip.api.game.game_binding : HipGameUtils;
    public import hip.api.systems.system_binding: HipTimerManager;
    public import HipDefaultAssets = hip.api.assets.globals: getDefaultFont, getDefaultTexture, getDefaultFontWithSize;
}