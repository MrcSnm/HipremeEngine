/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2026.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.spritebatch_vertex;
import hip.graphics.g2d.spritebatch;
import hip.game.mesh;
import hip.game.orthocamera;
import hip.assets.texture;
import hip.error.handler;
import hip.game.shader;
import hip.game.vertex;
import hip.game.framebuffer;
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
final class HipSpriteBatchVertex
{
    index_t maxQuads;
    index_t[] indices;
    HipSpriteVertex[] vertices;

    protected bool hasInitTextureSlots;
    CachedTexture cachedTexture;
    Shader spriteBatchShader;
    HipSpriteBatch batch;

    ///Post Processing Shader
    protected Shader ppShader;
    protected HipFrameBuffer fb;
    protected HipTextureRegion fbTexRegion;
    int drawOffset =0 ;

    HipOrthoCamera camera;
    Mesh mesh;

    protected IHipTexture[] currentTextures;
    ushort usingTexturesCount;

    uint lastDrawQuadsCount = 0;
    uint quadsCount;

    this(HipSpriteBatch batch, Shader spriteBatchShader, HipOrthoCamera camera = null, index_t maxQuads = DefaultMaxSpritesPerBatch)
    {
        import hip.hiprenderer.initializer;
        import hip.util.conv:to;
        this.batch = batch;
        ErrorHandler.assertLazyExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.maxQuads = maxQuads;
        vertices = new HipSpriteVertex[maxQuads*4]; //XYZ -> 3, RGBA -> 4, ST -> 2, TexID 3+4+2+1=10
        currentTextures = new IHipTexture[](HipRenderer.getMaxSupportedShaderTextures());
        usingTexturesCount = 0;


        this.spriteBatchShader = spriteBatchShader;
        

        mesh = new Mesh(HipVertexArrayObject.getVAO!(HipSpriteVertex)(
            [HipVertexAttributeCreateInfo((maxQuads*HipSpriteVertex.quadCount), HipResourceUsage.Dynamic, ShaderInputRate.perVertex)]
        ), spriteBatchShader);
        mesh.setIndices(HipRenderer.getQuadIndexBuffer(maxQuads));

        // spriteBatchShader.bind();
        // spriteBatchShader.sendVars();
        mesh.sendAttributes();


        spriteBatchShader.bind();
        spriteBatchShader.sendVars();

        if(camera is null)
            camera = new HipOrthoCamera();
        this.camera = camera;
        mesh.setVertices(vertices);
        // vertices = cast(HipSpriteVertex[])mesh.vao.VBO.getBuffer();

        int width, height;
        ushort slot;
        setTexture(HipTexture.getPixelTexture(), width , height, slot);

    }


    void setPostProcessingShader(Shader s)
    {
        if(fb is null)
        {
            Viewport v = HipRenderer.getCurrentViewport;
            fb = new HipFrameBuffer(HipRenderer.newFrameBuffer(cast(int)v.width, cast(int)v.height), cast(int)v.width, cast(int)v.height);
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


            vertices[start..end] = v[0..quadsToDraw*4];
            static if(!GLMaxOneBoundTexture)
            {
                for(int i = 0; i < quadsToDraw; i++)
                    setTID(vertices[start+i*4..$], slot);

            }

            v = v[quadsToDraw*4..$];

            this.quadsCount+= quadsToDraw;


            countOfQuads-= quadsToDraw;
        }
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
    void setTexture (IHipTexture texture,  out int width, out int height, out ushort slot)
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
    void setTexture(IHipTextureRegion reg, out int width, out int height, out ushort slot){ return setTexture(reg.getTexture(), width, height, slot); }

    protected static bool isZeroAlpha(void[] vertices)
    {
        HipSpriteVertex[] v = cast(HipSpriteVertex[])vertices;
        return v[0].vColor.a == 0 && v[1].vColor.a == 0 && v[2].vColor.a == 0 && v[3].vColor.a == 0;
    }

    void beginFrame(int frame)
    {
        drawOffset = 0;
    }

    void draw(IHipTexture t, ubyte[] vertices, bool isText)
    {
        if(isZeroAlpha(vertices)) return;
        int width, height;
        ushort slot;
        setTexture(t, width, height, slot);

        if(isText)
            slot|= 1 << 15;

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

        ushort slot;
        int width, height;
        setTexture(texture, width, height, slot);
        size_t startVertex = quadsCount *4;
        size_t endVertex = startVertex + 4;

        getTextureVertices(vertices[startVertex..endVertex], slot, width, height, x,y,z,color, scaleX, scaleY, rotation);
        quadsCount++;
    }


    void draw(IHipTextureRegion reg, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        if(color.a == 0) return;
        if(quadsCount+1 > maxQuads)
            flush();

        int width, height;
        ushort slot;
        setTexture(reg, width ,height, slot);
        size_t startVertex = quadsCount*4;
        size_t endVertex = startVertex + 4;

        getTextureRegionVertices(vertices[startVertex..endVertex], slot, reg,x,y,z,color, scaleX, scaleY, rotation);
        quadsCount++;
    }


    private static void setTID(HipSpriteVertex[] vertices, int tid)
    {
        // static if(!GLMaxOneBoundTexture)
        {
            vertices[0].vTexID = cast(ushort)tid;
            vertices[1].vTexID = cast(ushort)tid;
            vertices[2].vTexID = cast(ushort)tid;
            vertices[3].vTexID = cast(ushort)tid;
        }
    }

    pragma(inline, true)
    private static short2[4] getBounds(float x, float y, float z, float width, float height, float scaleX = 1, float scaleY = 1)
    {
        width*= scaleX;
        height*= scaleY;
        return [
            short2(cast(short)x, cast(short) y),
            short2(cast(short)(x+width), cast(short) y),
            short2(cast(short)(x+width),  cast(short)(y+height)),
            short2(cast(short)x,  cast(short)(y+height)),
        ];
    }

    pragma(inline, true)
    private static short2[4] getBoundsFromRotation(float x, float y, float z, float width, float height, float rotation, float scaleX = 1, float scaleY = 1)
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
            short2(cast(short) (c*centerX - s*centerY + x), cast(short) (c*centerY + s*centerX + y)),
            short2(cast(short) (c*x2 - s*centerY + x)     , cast(short) (c*centerY + s*x2 + y)),
            short2(cast(short) (c*x2 - s*y2 + x)          , cast(short) (c*y2 + s*x2 + y)),
            short2(cast(short) (c*centerX - s*y2 + x)     , cast(short) (c*y2 + s*centerX + y)),
        ];
    }

    static void getTextureVertices(HipSpriteVertex[] output, int slot, int width, int height,
    int x, int y, float z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        short2[4] spritePos = void;
        if(rotation == 0)
            spritePos = getBounds(x,y,z,width,height,scaleX,scaleY);
        else
            spritePos = getBoundsFromRotation(x,y,z,width,height,rotation,scaleX,scaleY);


        for(size_t i = 0; i < 4; i++)
        {
            output[i].vTexST = (cast(ushort2[4])HipTextureRegion.defaultVertices)[i];
            output[i].vColor = color;
            output[i].vPosition = spritePos[i];
            output[i].vZ = cast(ushort)z;
            // static if(!GLMaxOneBoundTexture)
                output[i].vTexID = cast(ushort)slot;
        }

    }

    static void getTextureRegionVertices(HipSpriteVertex[] output, int slot, IHipTextureRegion reg,
    int x, int y, float z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        int width = reg.getWidth();
        int height = reg.getHeight();
        ushort[8] uvVertices = reg.getVertices();

        short2[4] spritePos = rotation == 0 ? getBounds(x,y,z,width,height,scaleX,scaleY) :getBoundsFromRotation(x,y,z,width,height,rotation,scaleX,scaleY);

        for(size_t i = 0; i < 4; i++)
        {
            output[i].vTexST = ushort2(uvVertices[i*2], uvVertices[i*2+1]);
            output[i].vColor = color;
            output[i].vPosition = spritePos[i];
            output[i].vZ = cast(ushort)z;
            // static if(!GLMaxOneBoundTexture)
                output[i].vTexID = cast(ushort)slot;
        }
    }



    void draw()
    {
        if(quadsCount - lastDrawQuadsCount != 0)
        {
            for(int i = usingTexturesCount; i < currentTextures.length; i++)
                currentTextures[i] = currentTextures[0];
            mesh.bind();
            batch.setUniforms(camera.getMVP, currentTextures);

            size_t start = lastDrawQuadsCount*4;
            size_t end = quadsCount*4;
            mesh.updateVertices(cast(void[])vertices[start..end],cast(int)start);

            // mesh.vao.VBO.unmapBuffer();
            mesh.draw((quadsCount-lastDrawQuadsCount)*6, HipRendererMode.triangles, lastDrawQuadsCount*6);

            ///Some operations may require texture unbinding(D3D11 Framebuffer)
            foreach(i; 0..usingTexturesCount)
                currentTextures[i].unbind(i);
            mesh.unbind();
        // mesh.vao.VBO.getBuffer();

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