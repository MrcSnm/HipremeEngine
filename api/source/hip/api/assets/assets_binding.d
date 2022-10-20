module hip.api.assets.assets_binding;
public import hip.api.data.commons;
private alias thisModule = __traits(parent, {});

void initAssetManager()
{
    version(Script)
    {
        import hip.api.internal;
        loadModuleFunctionPointers!(thisModule, "HipAssetManager");
    }
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