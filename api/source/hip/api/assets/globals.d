module hip.api.assets.globals;
public import hip.api.data.font;
public import hip.api.renderer.texture;

private alias thisModule = __traits(parent, {});

void initGlobalAssets()
{
    version(Script)
    {
        import hip.api.internal;
        loadModuleFunctionPointers!thisModule;
    }
}

version(Script) extern(System)
{
    const(IHipFont) function() getDefaultFont;
    IHipFont function(uint size) getDefaultFontWithSize;
    const(IHipTexture) function() getDefaultTexture;
}