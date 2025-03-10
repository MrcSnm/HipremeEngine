/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
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
    index_t maxQuads;
    index_t[] indices;
    HipSpriteVertex[] vertices;

    protected bool hasInitTextureSlots;
    Shader spriteBatchShader;

    ///Post Processing Shader
    protected Shader ppShader;
    protected HipFrameBuffer fb;
    protected HipTextureRegion fbTexRegion;
    protected float managedDepth = 0;

    HipOrthoCamera camera;
    Mesh mesh;

    protected IHipTexture[] currentTextures;
    int usingTexturesCount;

    uint lastDrawQuadsCount = 0;
    uint quadsCount;


    ShaderVar* uProj, uModel, uView, uTex;


    this(HipOrthoCamera camera = null, index_t maxQuads = DefaultMaxSpritesPerBatch)
    {
        import hip.hiprenderer.initializer;
        import hip.util.conv:to;
        ErrorHandler.assertLazyExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.maxQuads = maxQuads;
        indices = new index_t[maxQuads*6];
        vertices = new HipSpriteVertex[maxQuads]; //XYZ -> 3, RGBA -> 4, ST -> 2, TexID 3+4+2+1=10
        vertices[] = HipSpriteVertex.init;
        currentTextures = new IHipTexture[](HipRenderer.getMaxSupportedShaderTextures());
        usingTexturesCount = 0;


        this.spriteBatchShader = newShader(HipShaderPresets.SPRITE_BATCH);
        spriteBatchShader.addVarLayout(ShaderVariablesLayout.from!(HipSpriteVertexUniform)(HipRenderer.getInfo));
        spriteBatchShader.addVarLayout(ShaderVariablesLayout.from!(HipSpriteFragmentUniform)(HipRenderer.getInfo));
        spriteBatchShader.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);

        mesh = new Mesh(HipVertexArrayObject.getVAO!HipSpriteVertex, spriteBatchShader);
        mesh.vao.bind();
        mesh.createVertexBuffer(cast(index_t)(maxQuads*HipSpriteVertex.quadCount), HipBufferUsage.DYNAMIC);
        mesh.createIndexBuffer(cast(index_t)(maxQuads*6), HipBufferUsage.STATIC);

        

        spriteBatchShader.useLayout.Cbuf;
        // spriteBatchShader.bind();
        // spriteBatchShader.sendVars();
        mesh.sendAttributes();
        

        spriteBatchShader.useLayout.Cbuf;
        spriteBatchShader.bind();
        spriteBatchShader.sendVars();

        uProj = mesh.shader.get("Cbuf1.uProj", ShaderTypes.VERTEX);
        uModel = mesh.shader.get("Cbuf1.uModel", ShaderTypes.VERTEX);
        uView = mesh.shader.get("Cbuf1.uView", ShaderTypes.VERTEX);
        // uTex = mesh.shader.get("Cbuf.uTex", ShaderTypes.FRAGMENT);

        if(camera is null)
            camera = new HipOrthoCamera();
        this.camera = camera;
        HipVertexArrayObject.putQuadBatchIndices(indices, maxQuads);
        mesh.setVertices(vertices);
        mesh.setIndices(indices);
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

    /**
    *   Sets the texture slot/index for the current quad and points it to the next quad
    */
    void addQuad(void[] quad, int slot)
    {
        if(quadsCount+1 > maxQuads)
            flush();

        size_t start = quadsCount*4;
        import core.stdc.string;
        HipSpriteVertex* v = cast(HipSpriteVertex*)vertices.ptr + start;
        memcpy(v, quad.ptr, HipSpriteVertex.sizeof * 4);
        setTID(v[0..4], slot);
        
        quadsCount++;
    }

    void addQuads(void[] quadsVertices, int slot)
    {
        import hip.util.array:swapAt;
        assert(quadsVertices.length % (HipSpriteVertex.sizeof*4) == 0, "Count must be divisible by HipSpriteVertex.sizeof*4");
        HipSpriteVertex[] v = cast(HipSpriteVertex[])quadsVertices;
        uint countOfQuads = cast(uint)(v.length / 4);


        while(countOfQuads > 0)
        {
            size_t remainingQuads = this.maxQuads - this.quadsCount;
            if(remainingQuads == 0)
            {
                flush();
                this.usingTexturesCount = 1;
                swapAt(this.currentTextures, 0, slot);//Guarantee the target slot is being used
                remainingQuads = this.maxQuads;
            }
            size_t quadsToDraw = (countOfQuads < remainingQuads) ? countOfQuads : remainingQuads;


            size_t start = quadsCount*4;
            size_t end = start + quadsToDraw*4;


            vertices[start..end] = v;
            for(int i = 0; i < quadsToDraw; i++)
                setTID(vertices[start+i*4..$], slot);

            v = v[quadsToDraw*4..$];

            this.quadsCount+= quadsToDraw;


            countOfQuads-= quadsToDraw;
        }
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

    protected static bool isZeroAlpha(void[] vertices)
    {
        HipSpriteVertex[] v = cast(HipSpriteVertex[])vertices;
        return v[0].vColor.a == 0 && v[1].vColor.a == 0 && v[2].vColor.a == 0 && v[3].vColor.a == 0;
    }

    void draw(IHipTexture t, ubyte[] vertices)
    {
        if(isZeroAlpha(vertices)) return;
        ErrorHandler.assertExit(t.getWidth != 0 && t.getHeight != 0, "Tried to draw 0 bounds sprite");
        int slot = setTexture(t);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        if(vertices.length == HipSpriteVertex.sizeof * 4)
            addQuad(vertices, slot);
        else
            addQuads(vertices, slot);
    }

    void draw(IHipTexture texture, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        import hip.global.gamedef;
        if(color.a == 0) return;
        if(quadsCount+1 > maxQuads)
            flush();
        if(texture is null)
            texture = cast()getDefaultTexture();
        ErrorHandler.assertExit(texture.getWidth() != 0 && texture.getHeight() != 0, "Tried to draw 0 bounds texture");
        int slot = setTexture(texture);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        size_t startVertex = quadsCount *4;
        size_t endVertex = startVertex + 4;

        getTextureVertices(vertices[startVertex..endVertex], slot, texture,x,y,managedDepth,color, scaleX, scaleY, rotation);
        quadsCount++;
    }


    void draw(IHipTextureRegion reg, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        if(color.a == 0) return;
        if(quadsCount+1 > maxQuads)
            flush();
        ErrorHandler.assertExit(reg.getWidth() != 0 && reg.getHeight() != 0, "Tried to draw 0 bounds region");
        int slot = setTexture(reg);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");
        size_t startVertex = quadsCount*4;
        size_t endVertex = startVertex + 4;

        getTextureRegionVertices(vertices[startVertex..endVertex], slot, reg,x,y,managedDepth,color, scaleX, scaleY, rotation);
        quadsCount++;
    }


    private static void setTID(HipSpriteVertex[] vertices, int tid)
    {
        static if(!GLMaxOneBoundTexture)
        {
            vertices[0].vTexID = tid;
            vertices[1].vTexID = tid;
            vertices[2].vTexID = tid;
            vertices[3].vTexID = tid;
        }
    }

    pragma(inline, true)
    private static Vector3[4] getBounds(float x, float y, float z, float width, float height, float scaleX = 1, float scaleY = 1)
    {
        width*= scaleX;
        height*= scaleY;
        return [
            Vector3(x, y, z),
            Vector3(x+width, y, z),
            Vector3(x+width, y+height, z),
            Vector3(x, y+height, z),
        ];
    }

    pragma(inline, true)
    private static Vector3[4] getBoundsFromRotation(float x, float y, float z, float width, float height, float rotation, float scaleX = 1, float scaleY = 1)
    {
        import hip.math.utils:cos,sin;
        width*= scaleX;
        height*= scaleY;
        float centerX = -width/2;
        float centerY = -height/2;
        float x2 = x + width;
        float y2 = y + height;
        float c = cos(rotation);
        float s = sin(rotation);

        return [
            Vector3(c*centerX - s*centerY + x, c*centerY + s*centerX + y, z),
            Vector3(c*x2 - s*centerY + x, c*centerY + s*x2 + y, z),
            Vector3(c*x2 - s*y2 + x, c*y2 + s*x2 + y, z),
            Vector3(c*centerX - s*y2 + x, c*y2 + s*centerX + y, z),
        ];
    }

    static void getTextureVertices(HipSpriteVertex[] output, int slot, IHipTexture texture,
    int x, int y, float z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        int width = texture.getWidth();
        int height = texture.getHeight();
        Vector3[4] spritePos = rotation == 0 ? getBounds(x,y,z,width,height,scaleX,scaleY) :getBoundsFromRotation(x,y,z,width,height,rotation,scaleX,scaleY);

        foreach(size_t i, ref HipSpriteVertex v; output)
        {
            v.vTexST = Vector2(HipTextureRegion.defaultVertices[i*2], HipTextureRegion.defaultVertices[i*2+1]);
            v.vColor = color;
            v.vPosition = spritePos[i];
            static if(!GLMaxOneBoundTexture)
                v.vTexID = slot;
        }
    }

    static void getTextureRegionVertices(HipSpriteVertex[] output, int slot, IHipTextureRegion reg,
    int x, int y, float z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        int width = reg.getWidth();
        int height = reg.getHeight();
        float[8] uvVertices = reg.getVertices();

        Vector3[4] spritePos = rotation == 0 ? getBounds(x,y,z,width,height,scaleX,scaleY) :getBoundsFromRotation(x,y,z,width,height,rotation,scaleX,scaleY);

        foreach(size_t i, ref HipSpriteVertex v; output)
        {
            v.vTexST = Vector2(uvVertices[i*2], uvVertices[i*2+1]);
            v.vColor = color;
            v.vPosition = spritePos[i];
            static if(!GLMaxOneBoundTexture)
                v.vTexID = slot;
        }
    }

    

    void draw()
    {

        if(quadsCount - lastDrawQuadsCount != 0)
        {
            for(int i = usingTexturesCount; i < currentTextures.length; i++)
                currentTextures[i] = currentTextures[0];
            mesh.bind();

            uProj.set(camera.proj, true);
            uModel.set(Matrix4.identity(), true);
            uView.set(camera.view, true);

            // mesh.shader.setFragmentVar(uTex, currentTextures);
            mesh.shader.bindArrayOfTextures(currentTextures, "uTex");
            mesh.shader.sendVars();

            size_t start = lastDrawQuadsCount*4;
            size_t end = quadsCount*4;
            mesh.updateVertices(cast(void[])vertices[start..end],cast(int)start);
            mesh.draw((quadsCount-lastDrawQuadsCount)*6, HipRendererMode.TRIANGLES, lastDrawQuadsCount*6);

            ///Some operations may require texture unbinding(D3D11 Framebuffer)
            foreach(i; 0..usingTexturesCount)
                currentTextures[i].unbind(i);
            mesh.unbind();
        }
        lastDrawQuadsCount = quadsCount;
    }

    void flush()
    {
        if(ppShader !is null)
            fb.bind();
        draw();
        lastDrawQuadsCount = quadsCount = usingTexturesCount = 0;
        if(ppShader !is null)
        {
            fb.unbind();
            draw(fbTexRegion, 0,0 );
            draw();
        }
        lastDrawQuadsCount = quadsCount = usingTexturesCount = 0;
    }
}