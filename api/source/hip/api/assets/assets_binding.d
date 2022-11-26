module hip.api.assets.assets_binding;
public import hip.api.data.commons;
public import hip.api.data.font;
public import hip.api.renderer.texture;

private alias thisModule = __traits(parent, {});

version(Script) void initAssetManager()
{
    import hip.api.internal;
    loadModuleFunctionPointers!(thisModule, "HipAssetManager");
    import hip.api.console;
    log("HipengineAPI: Initialized AssetManager");
}

version(Script) extern(System)
{
    ///Returns whether asset manager is loading anything
    bool function() isLoading;
    ///Stops the code from running and awaits asset manager to finish loading
    void function() awaitLoad;
    ///Returns a load task for texture
    IHipAssetLoadTask function(string path) loadTexture;
    ///Returns a load task for image
    IHipAssetLoadTask function(string path) loadImage;
    // /Returns a load task for font, when used, 
    IHipAssetLoadTask function(string path, int fontSize = 48) loadFont;
}