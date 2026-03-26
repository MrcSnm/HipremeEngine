/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2026
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2026.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.spritebatch;
import hip.graphics.mesh;
import hip.graphics.orthocamera;
import hip.hiprenderer.renderer;
import hip.assets.texture;
import hip.hiprenderer.framebuffer;
import hip.error.handler;
import hip.hiprenderer.shader;
import hip.config.renderer;
public import hip.api.graphics.batch;
public import hip.api.graphics.color;
public import hip.api.renderer.shaders.spritebatch;
import hip.graphics.g2d.spritebatch_instanced;
import hip.graphics.g2d.spritebatch_vertex;


interface IHipSpriteBatchImpl
{
    void setCurrentDepth(float depth) @nogc;
    void flush();
    void draw();
    void draw(IHipTextureRegion reg, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0);
    void draw(IHipTexture texture, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0);
    void draw(IHipTexture t, ubyte[] vertices);
}


/**
*   The spritebatch contains 2 shaders.
*   One shader is entirely internal, which you don't have any control, this is for actually being able
*   to draw stuff on the screen.
*
*   The another one is a post processing shader, which the spritebatch doesn't uses by default. If
*   setPostProcessingShader()
*/
class HipSpriteBatch : IHipBatch
{
    
    protected float managedDepth = 0;
    Shader spriteBatchShader;
    protected Shader ppShader;

    protected IHipSpriteBatchImpl impl;

    this(HipOrthoCamera camera = null, index_t maxQuads = DefaultMaxSpritesPerBatch, index_t maxInstances = DefaultMaxSpritesPerBatchInstanced)
    {
        import hip.hiprenderer.initializer;
        import hip.util.conv:to;
        ErrorHandler.assertLazyExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.spriteBatchShader = newShader(HipShaderPresets.SPRITE_BATCH);
        if(camera is null)
            camera = new HipOrthoCamera();
        
        if(spriteBatchShader.isInstanced)
            impl = new HipSpriteBatchInstanced(spriteBatchShader, camera, maxInstances);
        else
            impl = new HipSpriteBatchVertex(spriteBatchShader, camera, maxQuads);
        spriteBatchShader.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);

    }
    void setCurrentDepth(float depth) @nogc
    {
        impl.setCurrentDepth(depth);
    }
  
    void draw(IHipTexture t, ubyte[] vertices)
    {
        impl.draw(t, vertices);
    }

    void draw(IHipTexture texture, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        impl.draw(texture, x, y, z, color, scaleX, scaleY, rotation);
    }


    void draw(IHipTextureRegion reg, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        impl.draw(reg, x, y, z, color, scaleX, scaleY, rotation);
    }
    void draw()
    {
        impl.draw();
    }

    void flush()
    {
        impl.flush();
    }
}