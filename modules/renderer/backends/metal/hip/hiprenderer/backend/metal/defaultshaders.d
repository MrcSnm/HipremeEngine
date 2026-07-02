module hip.hiprenderer.backend.metal.defaultshaders;

import hip.api.renderer.core;
import hip.config.renderer;
private enum MetalDefaultShadersPath = __MODULE__;


static if(!HasMetal)
{
    immutable DefaultShader[] DefaultShaders;
}
else:

immutable DefaultShader[] DefaultShaders = [
    HipShaderPresets.FRAME_BUFFER: DefaultShader(MetalDefaultShadersPath, &getFrameBufferShader),
    HipShaderPresets.GEOMETRY_BATCH: DefaultShader(MetalDefaultShadersPath, &getGeometryBatchShader),
    HipShaderPresets.SPRITE_BATCH: DefaultShader(MetalDefaultShadersPath, &getSpriteBatchShader, () => true),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(MetalDefaultShadersPath, &getBitmapTextShader),
    HipShaderPresets.NONE: DefaultShader(MetalDefaultShadersPath)
];

private {
    string getFrameBufferShader(ShaderExtra){return import("metal/framebuffer.metal");}
    string getGeometryBatchShader(ShaderExtra){return import("metal/geometrybatch.metal");}
    string getSpriteBatchShader(ShaderExtra extra)
    {
        import hip.util.string;
        string ret = import("metal/spritebatch.metal");
        ret = ret.replace("/* GENERATED_EXTRA_BUFFERS */", extra.callArguments);
        ret = ret.replace("/* USER_FUNCTION */", extra.extraSource);

        return ret;
    }
    string getBitmapTextShader(ShaderExtra){return import("metal/bitmaptext.metal");}
}