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
import hip.game.mesh;
import hip.game.orthocamera;
import hip.assets.texture;
import hip.error.handler;
import hip.game.shader;
import hip.config.renderer;
public import hip.api.graphics.batch;
public import hip.api.graphics.color;
public import hip.api.renderer.shaders.spritebatch;
import hip.graphics.g2d.spritebatch_instanced;
import hip.graphics.g2d.spritebatch_vertex;
import hip.graphics.g2d;


/**
*   The spritebatch contains 2 shaders.
*   One shader is entirely internal, which you don't have any control, this is for actually being able
*   to draw stuff on the screen.
*
*   The another one is a post processing shader, which the spritebatch doesn't uses by default. If
*   setPostProcessingShader()
*/
final class HipSpriteBatch : IHipBatch
{
    
    protected float managedDepth = 0;
    Shader spriteBatchShader;
    Shader customSpriteBatchShader;

    protected Mesh mesh;
    protected Shader ppShader;
    protected HipSpriteBatchInstanced instanced;
    protected HipSpriteBatchVertex vertex;
    ShaderVariablesLayout uMVP, uSpritesFragmentUniform;


    this(HipOrthoCamera camera = null, index_t maxQuads = DefaultMaxSpritesPerBatch, index_t maxInstances = DefaultMaxSpritesPerBatchInstanced)
    {
        import hip.hiprenderer.initializer;
        import hip.util.conv:to;
        ErrorHandler.assertLazyExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.spriteBatchShader = createShader(HipShaderPresets.SPRITE_BATCH);
        if(camera is null)
            camera = new HipOrthoCamera();
        if(spriteBatchShader.isInstanced)
        {
            instanced = new HipSpriteBatchInstanced(this, spriteBatchShader, camera, maxInstances);
            mesh = instanced.mesh;
        }
        else
        {
            vertex = new HipSpriteBatchVertex(this, spriteBatchShader, camera, maxQuads);
            mesh = vertex.mesh;
        }
        spriteBatchShader.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);
        reinitUniforms();
    }

    void setUniforms(Matrix4 mvp, IHipTexture[] textures)
    {
        import hip.hiprenderer.renderer;
        import hip.util.time;
        
        uMVP.set(HipSpriteVertexUniform(mvp));
        uSpritesFragmentUniform.set(HipSpriteFragmentUniform(
            [1, 1, 1, 1], 
            cast(float[2])HipRenderer.window.getSize(),
            cast(float)HipTime.getCurrentTimeAsSeconds
        ));
        mesh.shader.bindArrayOfTextures(textures, "uTex");
        mesh.shader.sendVars();
    }
    void reinitUniforms()
    {
        uMVP = mesh.shader.getBuffer("Cbuf1");
        uSpritesFragmentUniform = mesh.shader.getBuffer("Cbuf");
    }

    bool isInstanced(){return instanced !is null;}

    void beginFrame(int frame)
    {
        if(instanced) instanced.beginFrame(frame);
        else vertex.beginFrame(frame);
    }
    void setCurrentDepth(float depth) @nogc{managedDepth = depth;}
  
    void draw(IHipTexture t, ubyte[] vertices, bool isText = false)
    {
        if(instanced) instanced.draw(t, vertices, isText);
        else vertex.draw(t, vertices, isText);
    }

    void setShader(Shader s)
    {
        if(s is customSpriteBatchShader)
            return;
        flush();
        if(s is null)
            mesh.setShader(spriteBatchShader);
        else
            mesh.setShader(s);
        customSpriteBatchShader = s;
        reinitUniforms();
    }

    Shader createSpriteBatchShaderEffect(string effect, ShaderVarLayoutInfo* info)
    {
        Shader s = createShader(HipShaderPresets.SPRITE_BATCH, HipRendererType.None, effect);
        ShaderVarLayoutInfo[1] layoutInfos;
        if(info !is null)
            layoutInfos = [*info];
        uint count = info is null ? 0 : 1;
        s.setup!(HipSpriteVertexUniform, HipSpriteFragmentUniform)(HipRenderer.getInfo, layoutInfos[0..count]);
        s.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);
        mesh.setShader(s);
        return s;
    }

    Shader getShader()
    {
        if(customSpriteBatchShader !is null)
            return customSpriteBatchShader;
        return spriteBatchShader;
    }

    void draw(IHipTexture texture, int x, int y, ushort z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        if(instanced) instanced.draw(texture, x, y, z, color, scaleX, scaleY, rotation);
        else vertex.draw(texture, x, y, z, color, scaleX, scaleY, rotation);
    }

    ushort getDepth(){return cast(ushort)managedDepth;}

    void setTexture(IHipTexture texture, out int width, out int height, out ushort slot)
    {
        if(instanced) instanced.setTexture(texture,width, height, slot);
        else vertex.setTexture(texture, width, height, slot);
    }


    void draw(IHipTextureRegion reg, int x, int y, ushort z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        if(instanced) instanced.draw(reg, x, y, z, color, scaleX, scaleY, rotation);
        else vertex.draw(reg, x, y, z, color, scaleX, scaleY, rotation);
    }
    void draw()
    {
        if(instanced) instanced.draw();
        else vertex.draw();
    }

    void flush()
    {
        if(instanced) instanced.flush();
        else vertex.flush();
    }
}