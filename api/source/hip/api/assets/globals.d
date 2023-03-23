module hip.api.assets.globals;
public import hip.api.data.font;
public import hip.api.renderer.texture;

version(Have_hipreme_engine) version = DirectCall;
version(DirectCall){}
else
{
    void initGlobalAssets()
    {
        import hip.api.internal;
        loadClassFunctionPointers!HipGlobalAssetsBinding;
        import hip.api.console;
        log("HipEngineAPI: Initialized Global Assets");
    }
    class HipGlobalAssetsBinding
    {
        extern(System) __gshared
        {
            const(IHipFont) function() getDefaultFont;
            IHipFont function(uint size) getDefaultFontWithSize;
            const(IHipTexture) function() getDefaultTexture;
        }
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipGlobalAssetsBinding;
}