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
    HipShaderPresets.FRAME_BUFFER: DefaultShader(MetalDefaultShadersPath, &getFrameBufferVertex, &getFrameBufferFragment),
    HipShaderPresets.GEOMETRY_BATCH: DefaultShader(MetalDefaultShadersPath, &getGeometryBatchVertex, &getGeometryBatchFragment),
    HipShaderPresets.SPRITE_BATCH: DefaultShader(MetalDefaultShadersPath, &getSpriteBatchVertex, &getSpriteBatchFragment),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(MetalDefaultShadersPath, &getBitmapTextVertex, &getBitmapTextFragment),
    HipShaderPresets.NONE: DefaultShader(MetalDefaultShadersPath)
];

private {
    string getFrameBufferFragment(){return "";}
    string getGeometryBatchFragment(){return "";}
    string getSpriteBatchFragment(){return "";}
    string getBitmapTextFragment(){return "";}
    string getFrameBufferVertex(){return import("metal/framebuffer.metal");}
    string getGeometryBatchVertex(){return import("metal/geometrybatch.metal");}
    string getSpriteBatchVertex(){return import("metal/spritebatch.metal");}
    string getBitmapTextVertex(){return import("metal/bitmaptext.metal");}
}