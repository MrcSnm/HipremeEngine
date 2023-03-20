module hip.api.assets.globals;
public import hip.api.data.font;
public import hip.api.renderer.texture;


version(Script) void initGlobalAssets()
{
    import hip.api.internal;
    loadClassFunctionPointers!HipGlobalAssetsBinding;
    import hip.api.console;
    log("HipEngineAPI: Initialized Global Assets");
}

version(Script) 
{
    class HipGlobalAssetsBinding
    {
        extern(System) static
        {
            const(IHipFont) function() getDefaultFont;
            IHipFont function(uint size) getDefaultFontWithSize;
            const(IHipTexture) function() getDefaultTexture;
        }
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipGlobalAssetsBinding;
}