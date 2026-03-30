/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2026
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.spritebatch_instanced;
import hip.graphics.g2d.spritebatch;
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


private struct CachedTexture
{
    IHipTexture texture;
    int width, height;
    ushort slot;
}

/**
*   The spritebatch contains 2 shaders.
*   One shader is entirely internal, which you don't have any control, this is for actually being able
*   to draw stuff on the screen.
*
*   The another one is a post processing shader, which the spritebatch doesn't uses by default. If
*   setPostProcessingShader()
*/
final class HipSpriteBatchInstanced
{
    protected bool hasInitTextureSlots;
    CachedTexture cachedTexture;
    Shader spriteBatchShader;
    HipSpriteVertexInstancedPerInstance[] vertices;

    ///Post Processing Shader
    protected Shader ppShader;
    protected HipFrameBuffer fb;
    protected HipTextureRegion fbTexRegion;
    protected ushort managedDepth = 0;

    HipOrthoCamera camera;
    Mesh mesh;

    protected IHipTexture[] currentTextures;
    ushort usingTexturesCount;
    uint maxInstances;
    uint instanceCount;
    ShaderVariablesLayout uMVP;

    this(Shader spriteBatchShader, HipOrthoCamera camera, uint maxInstances = 50_000)
    {
        import hip.hiprenderer.initializer;
        import hip.util.conv:to;
        currentTextures = new IHipTexture[](HipRenderer.getMaxSupportedShaderTextures());
        this.maxInstances = maxInstances;
        usingTexturesCount = 0;
        this.spriteBatchShader = spriteBatchShader;
        spriteBatchShader.setup!(HipSpriteVertexUniform, HipSpriteFragmentUniform)(HipRenderer.getInfo);
        spriteBatchShader.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);

        mesh = new Mesh(HipVertexArrayObject.getVAO!(HipSpriteVertexInstancedPerVertex, HipSpriteVertexInstancedPerInstance)(
            [
                HipVertexAttributeCreateInfo(4, HipResourceUsage.Immutable, ShaderInputRate.perVertex),
                HipVertexAttributeCreateInfo(maxInstances, HipResourceUsage.Dynamic, ShaderInputRate.perInstance)
            ]
        ), spriteBatchShader);
        
        vertices = new HipSpriteVertexInstancedPerInstance[](maxInstances);
        mesh.setVertices(spriteBatchInstancedVertices, 0);
        mesh.setVertices(vertices, 1);
        mesh.setIndices(HipRenderer.createQuadIndexBuffer(1, HipResourceUsage.Immutable));
        mesh.sendAttributes();


        spriteBatchShader.bind();
        spriteBatchShader.sendVars();

        uMVP = mesh.shader.getBuffer("Cbuf1");
        this.camera = camera;
        // vertices = cast(HipSpriteVertex[])mesh.vao.VBO.getBuffer();
        int width, height;
        ushort slot;
        setTexture(HipTexture.getPixelTexture(), width, height, slot);

    }
    void setCurrentDepth(float depth) @nogc {managedDepth = cast(ushort)depth;}

    void setShader(Shader s)
    {
        if(fb is null)
        {
            Viewport v = HipRenderer.getCurrentViewport;
            fb = HipRenderer.newFrameBuffer(cast(int)v.width, cast(int)v.height);
            // fbTexRegion = new HipTextureRegion(fb.getTexture());
        }
        this.ppShader = s;
    }
    
    private ushort getNextTextureID(IHipTexture t)
    {
        for(ushort i = 0; i < usingTexturesCount; i++)
            if(currentTextures[i] is t)
                return i;
        if(usingTexturesCount < currentTextures.length)
        {
            currentTextures[usingTexturesCount] = t;
            return usingTexturesCount++;
        }
        return ushort.max;
    }
    /**
    *   Sets the current texture in use on the sprite batch and returns its slot.
    */
    protected void setTexture (IHipTexture texture, out int width, out int height, out ushort slot)
    {
        if(texture is cachedTexture.texture)
        {
            width = cachedTexture.width;
            height = cachedTexture.height;
            slot = cachedTexture.slot;
        }
        else
        {
            width = texture.getWidth(), height = texture.getHeight();
            ErrorHandler.assertExit(width != 0 && height != 0, "Tried to draw 0 bounds texture");
            slot = getNextTextureID(texture);
            if(slot == ushort.max)
            {
                flush();
                slot = getNextTextureID(texture);
            }
            cachedTexture = CachedTexture(texture, width, height, slot);
        }
    }
    protected void setTexture(IHipTextureRegion reg, out int width, out int height, out ushort slot){ return setTexture(reg.getTexture(), width, height, slot); }

    pragma(inline, true)
    void addInstance(HipSpriteVertexInstancedPerInstance instance)
    {
        vertices[instanceCount++] = instance;
    }

    void draw(IHipTexture texture, ubyte[] vertices)
    {
        import hip.global.gamedef;
        if(texture is null)
            texture = cast()getDefaultTexture();
        int width, height;
        ushort slot;
        setTexture(texture, width, height, slot);
        HipSpriteVertexInstancedPerInstance base = *cast(HipSpriteVertexInstancedPerInstance*) vertices.ptr;
        base.vTexID = slot;
        addInstance(base);
    }
    void draw(IHipTexture texture, int x, int y, ushort z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        import hip.global.gamedef;
        if(color.a == 0) return;
        if(instanceCount + 1 > maxInstances)
            flush();
        if(texture is null)
            texture = cast()getDefaultTexture();
        int width, height;
        ushort slot;
        setTexture(texture, width, height, slot);
        addInstance(
            HipSpriteVertexInstancedPerInstance(
                [cast(ushort)x, cast(ushort)y],  [cast(ushort)(width*scaleX), cast(ushort)(width*scaleY)], 
                color, rotation, z, slot,
                [0,0], [ushort.max, ushort.max]));
    }


    void draw(IHipTextureRegion reg, int x, int y, ushort z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
       draw(reg.getTexture, x, y, z, color, scaleX, scaleY, rotation);
    }

    void draw()
    {
        if(instanceCount)
        {
            for(int i = usingTexturesCount; i < currentTextures.length; i++)
                currentTextures[i] = currentTextures[0];
            mesh.bind();

            static Matrix4 mvp;
            Matrix4 camMvp = camera.getMVP;
            if(camMvp != mvp)
            {
                mvp = camMvp;
                uMVP.set(HipSpriteVertexUniform(camera.getMVP));
            }
            mesh.shader.bindArrayOfTextures(currentTextures, "uTex");
            mesh.shader.sendVars();

            mesh.updateVertices(vertices[0..instanceCount], 0, 1);

            // mesh.vao.VBO.unmapBuffer();
            mesh.drawInstanced(HipRendererMode.triangles, instanceCount, 6);

            ///Some operations may require texture unbinding(D3D11 Framebuffer)
            foreach(i; 0..usingTexturesCount)
                currentTextures[i].unbind(i);
            mesh.unbind();
        // mesh.vao.VBO.getBuffer();

        }
        instanceCount = 0;
        usingTexturesCount = 0;
    }

    void flush()
    {
        if(ppShader !is null)
            fb.bind();
        draw();
        if(ppShader !is null)
        {
            fb.unbind();
            draw(fbTexRegion, 0,0 );
            draw();
        }
    }
}