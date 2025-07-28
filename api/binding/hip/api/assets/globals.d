module hip.api.assets.globals;
public import hip.api.data.font;
public import hip.api.renderer.texture;

version(ScriptAPI)
{
    void initGlobalAssets()
    {
        import hip.api.data.image;
        import hip.api.internal;
        loadClassFunctionPointers!HipGlobalAssetsBinding;
        import hip.api.console;
        setImageDecoderProvider(getDecoder);
        log("HipEngineAPI: Initialized Global Assets");
    }
    class HipGlobalAssetsBinding
    {
        extern(System) __gshared
        {
            const(HipFont) function() getDefaultFont;
            HipFont function(uint size) getDefaultFontWithSize;
            const(IHipTexture) function() getDefaultTexture;
            IHipImageDecoder function(string path) getDecoder;
        }
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipGlobalAssetsBinding;
}
else version(DirectCall)
{
    public import hip.global.gamedef;
    public import hip.image_backend.impl: getDecoder;
}