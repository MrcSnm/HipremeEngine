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


/**
*   The spritebatch contains 2 shaders.
*   One shader is entirely internal, which you don't have any control, this is for actually being able
*   to draw stuff on the screen.
*
*   The another one is a post processing shader, which the spritebatch doesn't uses by default. If
*   setPostProcessingShader()
*/
class HipSpriteBatchInstanced : IHipBatch, IHipSpriteBatchImpl
{
    protected bool hasInitTextureSlots;
    Shader spriteBatchShader;
    HipSpriteVertexInstancedPerInstance[] vertices;

    ///Post Processing Shader
    protected Shader ppShader;
    protected HipFrameBuffer fb;
    protected HipTextureRegion fbTexRegion;
    protected float managedDepth = 0;

    HipOrthoCamera camera;
    Mesh mesh;

    protected IHipTexture[] currentTextures;
    int usingTexturesCount;
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
        spriteBatchShader.addVarLayout(ShaderVariablesLayout.from!(HipSpriteVertexUniform)(HipRenderer.getInfo));
        spriteBatchShader.addVarLayout(ShaderVariablesLayout.from!(HipSpriteFragmentUniform)(HipRenderer.getInfo));
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
        setTexture(HipTexture.getPixelTexture());

    }
    void setCurrentDepth(float depth){managedDepth = depth;}

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
    
    private int getNextTextureID(IHipTexture t)
    {
        for(int i = 0; i < usingTexturesCount; i++)
            if(currentTextures[i] is t)
                return i;
        if(usingTexturesCount < currentTextures.length)
        {
            currentTextures[usingTexturesCount] = t;
            return usingTexturesCount++;
        }
        return -1;
    }
    /**
    *   Sets the current texture in use on the sprite batch and returns its slot.
    */
    protected int setTexture (IHipTexture texture)
    {
        int slot = getNextTextureID(texture);
        if(slot == -1)
        {
            flush();
            slot = getNextTextureID(texture);
        }
        return slot;
    }
    protected int setTexture(IHipTextureRegion reg){return setTexture(reg.getTexture());}

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
        int width = texture.getWidth(), height = texture.getHeight();
        ErrorHandler.assertExit(width != 0 && height != 0, "Tried to draw 0 bounds texture");
        int slot = setTexture(texture);
        HipSpriteVertexInstancedPerInstance base = *cast(HipSpriteVertexInstancedPerInstance*) vertices.ptr;
        base.vTexID = slot;
        addInstance(base);
    }
    void draw(IHipTexture texture, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        import hip.global.gamedef;
        if(color.a == 0) return;
        if(instanceCount + 1 > maxInstances)
            flush();
        if(texture is null)
            texture = cast()getDefaultTexture();

        int width = texture.getWidth(), height = texture.getHeight();
        ErrorHandler.assertExit(width != 0 && height != 0, "Tried to draw 0 bounds texture");
        int slot = setTexture(texture);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        addInstance(HipSpriteVertexInstancedPerInstance(Vector2(x, y), Vector2(width*scaleX, height*scaleY), color, z, rotation, slot));
    }


    void draw(IHipTextureRegion reg, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
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

            uMVP.set(HipSpriteVertexUniform(camera.getMVP));
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