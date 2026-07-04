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
    HipShaderPresets.NONE: DefaultShader(MetalDefaultShadersPath)
];

private {
    string getFrameBufferShader(ShaderEffect){return import("metal/framebuffer.metal");}
    string getGeometryBatchShader(ShaderEffect){return import("metal/geometrybatch.metal");}
    string getSpriteBatchShader(ShaderEffect fx)
    {
        import hip.util.string;
        string ret = import("metal/spritebatch.metal");
        ret = ret.replace("/* GENERATED_EXTRA_BUFFERS */", fx.getMainArguments());
        ret = ret.replace("/* EFFECT_PARAMS_DEFINITION */", fx.getEffectParamsDefinition());
        ret = ret.replace("/* EFFECT_PARAMS_CALL */", fx.getEffectParamsCall());
        ret = ret.replace("/* GLOBALS_DEFINITION */", fx.getGlobalDefinitions());
        ret = ret.replace("/* USER_FUNCTION */", fx.getSource());

        return ret;
    }
}