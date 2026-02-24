module hip.hiprenderer.initializer;
import hip.hiprenderer.renderer;

public HipRendererType rendererFromString(string str)
{
    import hip.error.handler;
    switch(str) with(HipRendererType)
    {
        case "GL3": return GL3;
        case "D3D11": return D3D11;
        case "Metal": return Metal;
        default:
        {
            ErrorHandler.showErrorMessage("Invalid renderer '"~str~"'",
            `
                Available renderers:
                    GL3
                    D3D11
                    Metal

                Fallback to GL3
            `);
            return GL3;
        }
    }
}
public IHipRendererImpl getRendererWithFallback(HipRendererType type)
{
    import hip.console.log;
    static HipRendererType[3] getRendererFallback(HipRendererType type)
    {
        switch(type) with(HipRendererType)
        {
            case GL3: return [GL3, D3D11, Metal];
            case D3D11: return [D3D11, GL3, None];
            case Metal: return [Metal, GL3, None];
            default: return [None, None, None];
        }
    }
    foreach(fallback; getRendererFallback(type))
    {
        IHipRendererImpl impl = getRendererImplementation(fallback);
        if(fallback == HipRendererType.None)
            break;
        if(impl !is null)
            return impl;
        logln(fallback, " wasn't included in the build, trying next fallback.");
    }
    return null;
}


public HipRendererType getRendererTypeFromVersion()
{
    with(HipRendererType)
    return HasDirect3D ? D3D11 : HasMetal ? Metal : HasOpenGL ? GL3 : None;
}

public IHipRendererImpl getRendererImplementation(HipRendererType type)
{
    static IHipRendererImpl getOpenGLRenderer()
    {
        static if(HasOpenGL)
        {
            import hip.hiprenderer.backend.gl.glrenderer;
            return new Hip_GL3Renderer();
        }
        else return null;
    }
    static IHipRendererImpl getDirect3DRenderer()
    {
        static if(HasDirect3D)
        {
            import hip.hiprenderer.backend.d3d.d3drenderer;
            return new Hip_D3D11_Renderer();
        }
        else return null;
    }
    static IHipRendererImpl getMetalRenderer()
    {
        static if(HasMetal)
        {
            import hip.hiprenderer.backend.metal.mtlrenderer;
            return new HipMTLRenderer();
        }
        else return null;
    }
    switch ( type )
    {
        case HipRendererType.GL3: return getOpenGLRenderer;
        case HipRendererType.D3D11: return getDirect3DRenderer;
        case HipRendererType.Metal: return getMetalRenderer;
        default: return null;
    }
}

immutable(DefaultShader[]) getDefaultFromModule(string mod)()
{
    static if(__traits(compiles, {mixin("import ",mod,";");}))
    {
        mixin("static import ", mod, ";");
        static if(__traits(getMember, mixin(mod), "DefaultShaders"))
            return mixin(mod,".DefaultShaders");
    }
    return [];
}

/**
 * Default Shaders are all accessed with
 * HipDefaultShaders[HipRendererType][HipShaderPresets]
 */
immutable DefaultShader[][] HipDefaultShaders = [
    HipRendererType.GL3: getDefaultFromModule!"hip.hiprenderer.backend.gl.defaultshaders",
    HipRendererType.D3D11: getDefaultFromModule!"hip.hiprenderer.backend.d3d.defaultshaders",
    HipRendererType.Metal: getDefaultFromModule!"hip.hiprenderer.backend.metal.defaultshaders",
    HipRendererType.None: []
];


public Shader newShader(HipShaderPresets shaderPreset, HipRendererType type = HipRendererType.None)
{
    import hip.util.conv:to;
    import hip.console.log;
    if(type == HipRendererType.None)
        type = HipRenderer.getType();

    Shader ret = HipRenderer.newShader();
    DefaultShader shaderInfo = HipDefaultShaders[type][shaderPreset];

    ShaderStatus status = ret.loadShader(shaderInfo.shaderSource(), shaderInfo.path~"."~shaderPreset.to!string);

    if(status != ShaderStatus.SUCCESS)
        logln("Failed loading shaders with status ", status, " at preset ", shaderPreset, " on "~shaderInfo.path);
    return ret;
}