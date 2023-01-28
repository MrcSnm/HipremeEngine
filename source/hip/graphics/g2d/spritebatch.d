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
import hip.graphics.material;
public import hip.api.graphics.batch;
public import hip.api.graphics.color;
public import hip.math.vector;
public import hip.math.matrix;

/**
*   This is what to expect in each vertex sent to the sprite batch
*/
@HipShaderInputLayout struct HipSpriteVertex
{
    Vector3 position;
    HipColor color;
    Vector2 tex_uv;
    int texID;

    static enum floatCount = cast(size_t)(HipSpriteVertex.sizeof/float.sizeof);
    static enum quadCount = floatCount*4;
    static assert(HipSpriteVertex.floatCount == 10,  "SpriteVertex should contain 9 floats and 1 int");
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
    index_t maxQuads;
    index_t[] indices;
    float[] vertices;

    protected bool hasInitTextureSlots;
    protected Shader spriteBatchShader;

    ///Post Processing Shader
    protected Shader ppShader;
    protected HipFrameBuffer fb;
    protected HipTextureRegion fbTexRegion;
    

    HipOrthoCamera camera;
    Mesh mesh;
    Material material;

    protected IHipTexture[] currentTextures;
    int usingTexturesCount;

    uint quadsCount;

    this(HipOrthoCamera camera = null, index_t maxQuads = 10_900)
    {
        import hip.util.conv:to;
        ErrorHandler.assertLazyExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.maxQuads = maxQuads;
        indices = new index_t[maxQuads*6];
        vertices = new float[maxQuads*HipSpriteVertex.quadCount]; //XYZ -> 3, RGBA -> 4, ST -> 2, TexID 3+4+2+1=10
        vertices[] = 0;
        currentTextures = new IHipTexture[](HipRenderer.getMaxSupportedShaderTextures());
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
            fb = HipRenderer.newFrameBuffer(cast(int)v.width, cast(int)v.height);
            // fbTexRegion = new HipTextureRegion(fb.getTexture());
        }
        this.ppShader = s;
    }

    /**
    *   Sets the texture slot/index for the current quad and points it to the next quad
    */
    void addQuad(float[] quad, int slot)
    {
        if(quadsCount+1 > maxQuads)
            flush();

        size_t start = HipSpriteVertex.quadCount*quadsCount;
        version(none) //D way to do it, but it is also slower
        {
            size_t end = start + HipSpriteVertex.quadCount;
            vertices[start..end] = quad;
            vertices[start+ T1] = slot;
            vertices[start+ T2] = slot;
            vertices[start+ T3] = slot;
            vertices[start+ T4] = slot;
        }
        else
        {
            import core.stdc.string;
            float* v = vertices.ptr;
            memcpy(v + start, quad.ptr, HipSpriteVertex.quadCount * float.sizeof);
            *(v + T1) = slot;
            *(v + T2) = slot;
            *(v + T3) = slot;
            *(v + T4) = slot;
        }
        
        quadsCount++;
    }

    void addQuads(float[] quadsVertices, int slot)
    {
        assert(quadsVertices.length % HipSpriteVertex.quadCount == 0, "Count must be divisible by 40");
        import hip.util.array:swapAt;
        uint countOfQuads = cast(int)(quadsVertices.length /HipSpriteVertex.quadCount);


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

            size_t start = cast(size_t)(HipSpriteVertex.quadCount*this.quadsCount);
            size_t end = start + quadsToDraw * HipSpriteVertex.quadCount;



            vertices[start..end] = quadsVertices[0..quadsToDraw*HipSpriteVertex.quadCount];
            for(int i = 0; i < quadsToDraw; i++)
            {
                const size_t quadStart = i*HipSpriteVertex.quadCount;
                vertices[start + quadStart + T1] = slot;
                vertices[start + quadStart + T2] = slot;
                vertices[start + quadStart + T3] = slot;
                vertices[start + quadStart + T4] = slot;
            }
            quadsVertices = quadsVertices[quadsToDraw*HipSpriteVertex.quadCount..$];


            if(quadsToDraw + remainingQuads == maxQuads)
            {
                flush();
                this.usingTexturesCount = 1;
                swapAt(this.currentTextures, 0, slot);//Guarantee the target slot is being used
            }
            else
                this.quadsCount+= quadsToDraw;
            countOfQuads-= quadsToDraw;
        }
    }
    
    private int getNextTextureID(IHipTexture t)
    {
        for(int i = 0; i < usingTexturesCount; i++)
            if(currentTextures[i] is t)
                return i;

        if(usingTexturesCount + 1 == currentTextures.length)
            return -1;
        currentTextures[usingTexturesCount] = t;
        return usingTexturesCount++;
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
        else if(!hasInitTextureSlots)
        {
            hasInitTextureSlots = true;
            spriteBatchShader.initTextureSlots(texture, "uTex1", HipRenderer.getMaxSupportedShaderTextures());
        }
        return slot;
    }
    protected int setTexture(IHipTextureRegion reg){return setTexture(reg.getTexture());}

    void draw(IHipTexture t, float[] vertices)
    {
        ErrorHandler.assertExit(t.getWidth != 0 && t.getHeight != 0, "Tried to draw 0 bounds sprite");
        int slot = setTexture(t);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        if(vertices.length == HipSpriteVertex.quadCount)
            addQuad(vertices, slot);
        else
            addQuads(vertices, slot);
    }

    void draw(IHipTexture texture, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        import hip.global.gamedef;
        if(quadsCount+1 > maxQuads)
            flush();
        if(texture is null)
            texture = cast()getDefaultTexture();
        ErrorHandler.assertExit(texture.getWidth() != 0 && texture.getHeight() != 0, "Tried to draw 0 bounds texture");
        int slot = setTexture(texture);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        size_t startVertex = HipSpriteVertex.quadCount*quadsCount;
        size_t endVertex = startVertex + HipSpriteVertex.quadCount;

        getTextureVertices(vertices[startVertex..endVertex], slot, texture,x,y,z,color, scaleX, scaleY, rotation);
        quadsCount++;
    }


    void draw(IHipTextureRegion reg, int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        if(quadsCount+1 > maxQuads)
            flush();
        size_t startVertex = HipSpriteVertex.quadCount*quadsCount;
        size_t endVertex = startVertex + HipSpriteVertex.quadCount;
        ErrorHandler.assertExit(reg.getWidth() != 0 && reg.getHeight() != 0, "Tried to draw 0 bounds region");
        int slot = setTexture(reg);
        ErrorHandler.assertExit(slot != -1, "HipTexture slot can't be -1 on draw phase");

        getTextureRegionVertices(vertices[startVertex..endVertex], slot, reg,x,y,z,color, scaleX, scaleY, rotation);
        quadsCount++;
    }

    private static void setColor(float[] ret, in HipColor color)
    {
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
    }

    private static void setZ(float[] vertices, float z)
    {
        vertices[Z1] = z;
        vertices[Z2] = z;
        vertices[Z3] = z;
        vertices[Z4] = z;
    }
    private static void setUV(float[] vertices, in float[8] uv)
    {
        vertices[U1] = uv[0];
        vertices[V1] = uv[1];
        vertices[U2] = uv[2];
        vertices[V2] = uv[3];
        vertices[U3] = uv[4];
        vertices[V3] = uv[5];
        vertices[U4] = uv[6];
        vertices[V4] = uv[7];
    }
    private static void setTID(float[] vertices, int tid)
    {
        vertices[T1] = tid;
        vertices[T2] = tid;
        vertices[T3] = tid;
        vertices[T4] = tid;
    }
    private static void setBounds(float[] vertices, float x, float y, float width, float height, float scaleX = 1, float scaleY = 1)
    {
        width*= scaleX;
        height*= scaleY;
        vertices[X1] = x;
        vertices[Y1] = y;

        vertices[X2] = x+width;
        vertices[Y2] = y;
        
        vertices[X3] = x+width;
        vertices[Y3] = y+height;

        vertices[X4] = x;
        vertices[Y4] = y+height;
    }

    private static void setBoundsFromRotation(float[] vertices, float x, float y, float width, float height, float rotation, float scaleX = 1, float scaleY = 1)
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

        vertices[X1] = c*centerX - s*centerY + x;
        vertices[Y1] = c*centerY + s*centerX + y;

        vertices[X2] = c*x2 - s*centerY + x;
        vertices[Y2] = c*centerY + s*x2 + y;
        
        vertices[X3] = c*x2 - s*y2 + x;
        vertices[Y3] = c*y2 + s*x2 + y;

        vertices[X4] = c*centerX - s*y2 + x;
        vertices[Y4] = c*y2 + s*centerX + y;
    }


    static void getTextureVertices(float[] output, int slot, IHipTexture texture,
    int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        int width = texture.getWidth();
        int height = texture.getHeight();

        const float[8] v = HipTextureRegion.defaultVertices;
        setUV(output, v);
        setZ(output, z);
        setTID(output, slot);
        setColor(output, color);
        if(rotation == 0)
            setBounds(output, x, y, width, height, scaleX, scaleY);
        else
            setBoundsFromRotation(output, x, y, width, height, rotation, scaleX, scaleY);
    }

    static void getTextureRegionVertices(float[] output, int slot, IHipTextureRegion reg,
    int x, int y, int z = 0, in HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
    {
        int width = reg.getWidth();
        int height = reg.getHeight();
        setZ(output, z);
        setColor(output, color);
        setTID(output, slot);
        setUV(output, reg.getVertices());
        if(rotation == 0)
            setBounds(output, x, y, width, height, scaleX, scaleY);
        else
            setBoundsFromRotation(output, x, y, width, height, rotation, scaleX, scaleY);
    }

    void render()
    {
        if(ppShader !is null)
            fb.bind();
        flush();
        if(ppShader !is null)
        {
            fb.unbind();
            draw(fbTexRegion, 0,0 );
            flush();
        }
    }

    void flush()
    {
        if(quadsCount == 0)
            return;
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        // mesh.shader.bind();
        // mesh.shader.setFragmentVar("uBatchColor", cast(float[4])[1,1,1,1]);
        // material.bind();

        mesh.shader.initTextureSlots(currentTextures[0], "uTex1", HipRenderer.getMaxSupportedShaderTextures());
        mesh.bind();

        mesh.shader.setVertexVar("Cbuf1.uProj", camera.proj);
        mesh.shader.setVertexVar("Cbuf1.uModel",Matrix4.identity());
        mesh.shader.setVertexVar("Cbuf1.uView", camera.view);
        
        foreach(i; 0..usingTexturesCount)
            currentTextures[i].bind(i);
        mesh.shader.sendVars();

        mesh.updateVertices(vertices);
        mesh.draw(quadsCount*6);

        ///Some operations may require texture unbinding(D3D11 Framebuffer)
        foreach(i; 0..usingTexturesCount)
            currentTextures[i].unbind(i);
        mesh.unbind();
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