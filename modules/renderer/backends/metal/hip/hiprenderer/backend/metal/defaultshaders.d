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
    HipShaderPresets.SPRITE_BATCH: DefaultShader(MetalDefaultShadersPath, &getSpriteBatchShader),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(MetalDefaultShadersPath, &getBitmapTextShader),
    HipShaderPresets.NONE: DefaultShader(MetalDefaultShadersPath)
];

private {
    string getFrameBufferShader(){return import("metal/framebuffer.metal");}
    string getGeometryBatchShader(){return import("metal/geometrybatch.metal");}
    string getSpriteBatchShader(){return import("metal/spritebatch.metal");}
    string getBitmapTextShader(){return import("metal/bitmaptext.metal");}
}