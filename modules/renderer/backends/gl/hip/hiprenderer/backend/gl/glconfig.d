module hip.hiprenderer.backend.gl.glconfig;
import hip.config.renderer;

struct GLCapabilities
{
    bool uniformBuffers;
    bool sizedInternalFormats;
    bool vertexArrayObjects;
    bool multipleRenderTargets;
    bool depth24;
    bool packedDepthStencil;
    bool instancing;
    bool hasBufferMap;
    bool gles3Features;
}

static if(UseWebGL)
immutable(GLCapabilities) hipGlCapabilities()
{
    import gles;
    GLCapabilities ret;
    if(isWebGL2) with(ret)
    {
        uniformBuffers = true;
        sizedInternalFormats = true;
        packedDepthStencil = true;
        depth24 = true;
        vertexArrayObjects = true;
        instancing = true;
        gles3Features = true;
    }
    return cast(immutable)ret;
}
else 
immutable GLCapabilities hipGlCapabilities = GLCapabilities(
    uniformBuffers:  OpenGLHasUniformBufferSupport,
    sizedInternalFormats:  HasGLES3FeatureSet,
    packedDepthStencil:  HasGLES3FeatureSet,
    depth24:  HasGLES3FeatureSet,
    vertexArrayObjects:  OpenGLHasVAOSupport,
    instancing:  OpenGLHasInstancedDraw,
    hasBufferMap:  OpenGLHasBufferMapSupport,
    gles3Features: HasGLES3FeatureSet
);