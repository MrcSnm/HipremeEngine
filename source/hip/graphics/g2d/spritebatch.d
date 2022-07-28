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
import hip.math.matrix;
import hip.error.handler;
import hip.hiprenderer.shader;
import hip.graphics.material;
import hip.graphics.g2d.sprite;
import hip.hipengine.api.graphics.color;
import hip.math.vector;

/**
*   This is what to expect in each vertex sent to the sprite batch
*/
@HipShaderInputLayout struct HipSpriteVertex
{
    Vector3 position;
    HipColor color;
    Vector2 tex_uv;
    int texID;

    static enum floatCount = cast(ulong)(HipSpriteVertex.sizeof/float.sizeof);
    static enum quadCount = floatCount*4;
}

/**
*   The spritebatch contains 2 shaders.
*   One shader is entirely internal, which you don't have any control, this is for actually being able
*   to draw stuff on the screen.
*
*   The another one is a post processing shader, which the spritebatch doesn't uses by default. If 
*   setPostProcessingShader()
*/
class HipSpriteBatch
{
    index_t maxQuads;
    index_t[] indices;
    float[] vertices;
    bool hasBegun;

    protected bool hasInitTextureSlots;
    protected Shader spriteBatchShader;

    ///Post Processing Shader
    protected Shader ppShader;
    protected HipFrameBuffer fb;
    protected HipTextureRegion fbTexRegion;
    

    HipOrthoCamera camera;
    Mesh mesh;
    Material material;

    protected HipTexture[] currentTextures;
    int usingTexturesCount;

    uint quadsCount;

    this(HipOrthoCamera camera = null, index_t maxQuads = 10_900)
    {
        import hip.util.conv:to;
        ErrorHandler.assertExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.maxQuads = maxQuads;
        indices = new index_t[maxQuads*6];
        vertices = new float[maxQuads*HipSpriteVertex.quadCount]; //XYZ -> 3, RGBA -> 4, ST -> 2, TexID 3+4+2+1=10
        vertices[] = 0;
        currentTextures = new HipTexture[](HipRenderer.getMaxSupportedShaderTextures());
        usingTexturesCount = 0;

        this.spriteBatchShader = HipRenderer.newShader(HipShaderPresets.SPRITE_BATCH);
        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_ST_TID_VAO(), spriteBatchShader);
        mesh.vao.bind();
        mesh.createVertexBuffer(cast(index_t)(maxQuads*HipSpriteVertex.quadCount), HipBufferUsage.DYNAMIC);
        mesh.createIndexBuffer(cast(index_t)(maxQuads*6), HipBufferUsage.STATIC);
        mesh.sendAttributes();
        

        spriteBatchShader.addVarLayout(new ShaderVariablesLayout("Cbuf1", ShaderTypes.VERTEX, ShaderHint.NONE)
        .append("uModel", Matrix4.identity)
        .append("uView", Matrix4.identity)
        .append("uProj", Matrix4.identity));

        spriteBatchShader.addVarLayout(new ShaderVariablesLayout("Cbuf", ShaderTypes.FRAGMENT, ShaderHint.NONE)
        .append("uBatchColor", cast(float[4])[1,1,1,1])
        );


        spriteBatchShader.useLayout.Cbuf;
        spriteBatchShader.bind();
        spriteBatchShader.sendVars();

        if(camera is null)
            camera = new HipOrthoCamera();
        this.camera = camera;

        index_t offset = 0;
        for(index_t i = 0; i < cast(index_t)(maxQuads*6); i+=6)
        {
            indices[i + 0] = cast(index_t)(0+offset);
            indices[i + 1] = cast(index_t)(1+offset);
            indices[i + 2] = cast(index_t)(2+offset);

            indices[i + 3] = cast(index_t)(2+offset);
            indices[i + 4] = cast(index_t)(3+offset);
            indices[i + 5] = cast(index_t)(0+offset);
            offset+= 4; //Offset calculated for each quad
        }
        mesh.setVertices(vertices);
        mesh.setIndices(indices);
        setTexture(HipTexture.getPixelTexture());
    }

    void setShader(Shader s)
    {
        if(fb is null)
        {
            Viewport v = HipRenderer.getCurrentViewport;
            fb = HipRenderer.newFrameBuffer(cast(int)v.w, cast(int)v.h);
            // fbTexRegion = new HipTextureRegion(fb.getTexture());
        }
        this.ppShader = s;
    }

    void begin()
    {
        if(hasBegun)
            return;
        if(ppShader !is null)
            fb.bind();
        hasBegun = true;
    }

    /**
    *   Sets the texture slot/index for the current quad and points it to the next quad
    */
    void addQuad(ref float[HipSpriteVertex.quadCount] quad, int slot)
    {
        if(quadsCount+1 > maxQuads)
            flush();

        quad[T1] = slot;
        quad[T2] = slot;
        quad[T3] = slot;
        quad[T4] = slot;

        for(ulong i = 0; i < HipSpriteVertex.quadCount; i++)
            vertices[(HipSpriteVertex.quadCount*quadsCount)+i] = quad[i];
        
        quadsCount++;
    }

    void addQuads(uint count)(ref float[count] quadsVertices, int slot)
    {
        static assert(count % HipSpriteVertex.quadCount == 0, "Count must be divisible by 40");
        enum int countOfQuads = cast(int)(count /HipSpriteVertex.quadCount);

        for(int i = 0; i < quadsCount; i++)
        {
            quadsVertices[i*HipSpriteVertex.quadCount + T1] = slot;
            quadsVertices[i*HipSpriteVertex.quadCount + T2] = slot;
            quadsVertices[i*HipSpriteVertex.quadCount + T3] = slot;
            quadsVertices[i*HipSpriteVertex.quadCount + T4] = slot;
        }


        uint index = 0;
        uint startCopyIndex = cast(uint)(HipSpriteVertex.quadCount*this.quadsCount);

        while(index < count)
        {
            vertices[startCopyIndex + index] = quadsVertices[index];
            index++;
        }
        this.quadsCount+= countOfQuads;
    }
    
    pragma(inline, true)
    private int getNextTextureID(HipTexture t)
    {
        for(int i = 0; i < usingTexturesCount; i++)
            if(currentTextures[i] == t)
                return i;

        if(usingTexturesCount + 1 == currentTextures.length)
            return -1;
        currentTextures[usingTexturesCount] = t;
        return usingTexturesCount++;
    }
    /**
    *   Sets the current texture in use on the sprite batch and returns its slot.
    */
    protected int setTexture(HipTexture texture)
    {
        int slot = getNextTextureID(texture);
        if(slot == -1)
        {
            flush();
            slot = getNextTextureID(texture);
        }
        else if(!hasInitTextureSlots)
        {
            hasInitTextureSlots = true;
            spriteBatchShader.initTextureSlots(texture, "uTex1", HipRenderer.getMaxSupportedShaderTextures());
        }
        return slot;
    }
    protected int setTexture(HipTextureRegion reg){return setTexture(reg.texture);}

    void draw(uint count)(HipTexture t, ref float[count] vertices)
    {
        static assert(count % HipSpriteVertex.quadCount == 0,
        mixin("\"Quads count to draw must be divisible by ", count, "\""));


        ErrorHandler.assertExit(t.width != 0 && t.height != 0, "Tried to draw 0 bounds sprite");
        int slot = setTexture(t);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        static if((count / HipSpriteVertex.quadCount) == 1)
            addQuad(vertices, slot);
        else
            addQuads(vertices, slot);
    }
    void draw(HipSprite s)
    {
        float[HipSpriteVertex.quadCount] v = s.getVertices();
        ErrorHandler.assertExit(s.width != 0 && s.height != 0, "Tried to draw 0 bounds sprite");
        int slot = setTexture(s.texture);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");
        ///X Y Z, RGBA, UV, 4 vertices
        addQuad(v, slot);
    }


    void draw(HipTextureRegion reg, int x, int y, int z = 0, HipColor color = HipColor.white)
    {
        float[HipSpriteVertex.quadCount] v = getTextureRegionVertices(reg,x,y,z,color);
        ErrorHandler.assertExit(reg.regionWidth != 0 && reg.regionHeight != 0, "Tried to draw 0 bounds region");
        int slot = setTexture(reg);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        ///X Y Z, RGBA, UV, 1, 4 vertices

        addQuad(v, slot);
    }

    static float[HipSpriteVertex.quadCount] getTextureRegionVertices(HipTextureRegion reg,
    int x, int y, int z = 0, HipColor color = HipColor.white)
    {
        float[HipSpriteVertex.quadCount] ret;
        
        ret[X1] = x;
        ret[Y1] = y;
        ret[Z1] = z;

        ret[X2] = x+reg.regionWidth;
        ret[Y2] = y;
        ret[Z2] = z;
        
        ret[X3] = x+reg.regionWidth;
        ret[Y3] = y+reg.regionHeight;
        ret[Z3] = z;

        ret[X4] = x;
        ret[Y4] = y+reg.regionHeight;
        ret[Z4] = z;

        const float[8] v = reg.getVertices();
        ret[U1] = v[0];
        ret[V1] = v[1];
        ret[U2] = v[2];
        ret[V2] = v[3];
        ret[U3] = v[4];
        ret[V3] = v[5];
        ret[U4] = v[6];
        ret[V4] = v[7];

        ret[R1] = color.r;
        ret[G1] = color.g;
        ret[B1] = color.b;
        ret[A1] = color.a;

        ret[R2] = color.r;
        ret[G2] = color.g;
        ret[B2] = color.b;
        ret[A2] = color.a;

        ret[R3] = color.r;
        ret[G3] = color.g;
        ret[B3] = color.b;
        ret[A3] = color.a;

        ret[R4] = color.r;
        ret[G4] = color.g;
        ret[B4] = color.b;
        ret[A4] = color.a;
        
        return ret;
    }

    void end()
    {
        if(!hasBegun)
            return;
        this.flush();
        if(ppShader !is null)
        {
            fb.unbind();
            draw(fbTexRegion, 0,0 );
            flush();
        }
        hasBegun = false;
    }

    void flush()
    {
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        // mesh.shader.bind();
        // mesh.shader.setFragmentVar("uBatchColor", cast(float[4])[1,1,1,1]);
        // material.bind();
        // foreach(i; 0..16)
        //     currentTextures[0].bind(i);
        mesh.shader.setVertexVar("Cbuf1.uProj", camera.proj);
        mesh.shader.setVertexVar("Cbuf1.uModel",Matrix4.identity());
        mesh.shader.setVertexVar("Cbuf1.uView", camera.view);
        
        mesh.shader.bind();
        foreach(i; 0..usingTexturesCount)
            currentTextures[i].bind(i);
        mesh.shader.sendVars();

        mesh.updateVertices(vertices);
        mesh.draw(quadsCount*6);

        ///Some operations may require texture unbinding(D3D11 Framebuffer)
        foreach(i; 0..usingTexturesCount)
            currentTextures[i].unbind(i);

        quadsCount = 0;
        usingTexturesCount = 0;
    }
}


enum
{
    //X, Y, Z (Position)
    //R, G, B, A (Color)
    //U, V (HipTexture Coordinates)
    //T (HipTexture Slot/Index)
    X1 = 0,
    Y1,
    Z1,
    R1,
    G1,
    B1,
    A1,
    U1,
    V1,
    T1,

    X2,
    Y2,
    Z2,
    R2,
    G2,
    B2,
    A2,
    U2,
    V2,
    T2,

    X3,
    Y3,
    Z3,
    R3,
    G3,
    B3,
    A3,
    U3,
    V3,
    T3,

    X4,
    Y4,
    Z4,
    R4,
    G4,
    B4,
    A4,
    U4,
    V4,
    T4
}