module implementations.renderer.spritebatch;
import implementations.renderer.mesh;
import core.stdc.string:memcpy;
import implementations.renderer.renderer;
import math.matrix;
import implementations.renderer.shader;
import implementations.renderer.sprite;
import graphics.color;
import math.vector;

/**
*   This is what to expect in each vertex sent to the sprite batch
*/
struct HipSpriteVertex
{
    Vector3 position;
    HipColor color;
    Vector2 tex_uv;
}

private enum spriteVertexSize = cast(uint)(HipSpriteVertex.sizeof/float.sizeof);

class HipSpriteBatch
{
    uint maxQuads;
    uint[] indices;
    float[] vertices;
    bool hasBegun;
    Shader shader;
    Mesh mesh;

    protected uint quadsCount;

    this(uint maxQuads = 20_000)
    {
        this.maxQuads = maxQuads;
        indices = new uint[maxQuads*6];
        vertices = new float[maxQuads*spriteVertexSize*4]; //XYZ -> 3, RGBA -> 4, ST -> 2, 3+4+2=9
        vertices[] = 0;

        Shader s = HipRenderer.newShader(HipShaderPresets.SPRITE_BATCH);
        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_ST_VAO(), s);
        mesh.vao.bind();
        mesh.createVertexBuffer(maxQuads*spriteVertexSize*4, HipBufferUsage.DYNAMIC);
        mesh.createIndexBuffer(maxQuads*6, HipBufferUsage.STATIC);
        mesh.sendAttributes();

        import std.stdio;
        setShader(s);

        int offset = 0;
        for(int i = 0; i < maxQuads; i+=6)
        {
            indices[i + 0] = 0+offset;
            indices[i + 1] = 1+offset;
            indices[i + 2] = 2+offset;

            indices[i + 3] = 2+offset;
            indices[i + 4] = 3+offset;
            indices[i + 5] = 0+offset;
            offset+= 4; //Offset calculated for each quad
        }
        mesh.setVertices(vertices);
        mesh.setIndices(indices);
    }

    void setShader(Shader s)
    {
        this.shader = s;
        mesh.setShader(s);
    }

    void begin()
    {
        if(hasBegun)
            return;
        hasBegun = true;
    }
    void draw(HipSprite s)
    {
        const float[] v = s.getVertices();

        s.texture.bind();
        for(int i = 0; i < 9*4; i++)
            vertices[(9*4*quadsCount)+i] = v[i];
        quadsCount++;
    }

    void end()
    {
        if(!hasBegun)
            return;
        this.flush();
        hasBegun = false;
    }

    void flush()
    {
        mesh.shader.bind();
        mesh.shader.setVar("uBatchColor", cast(float[4])[1,1,1,1]);
        mesh.shader.setVar("uProj", Matrix4.orthoLH(0, 800, 0, 600, 0.001, 1));
        mesh.shader.setVar("uModel",Matrix4.identity());
        mesh.shader.setVar("uView", Matrix4.identity());

        mesh.updateVertices(vertices);
        mesh.draw(quadsCount*6);
        quadsCount = 0;
    }
}


enum
{
    X1 = 0,
    Y1,
    Z1,
    R1,
    G1,
    B1,
    A1,
    U1,
    V1,

    X2,
    Y2,
    Z2,
    R2,
    G2,
    B2,
    A2,
    U2,
    V2,

    X3,
    Y3,
    Z3,
    R3,
    G3,
    B3,
    A3,
    U3,
    V3,

    X4,
    Y4,
    Z4,
    R4,
    G4,
    B4,
    A4,
    U4,
    V4
}