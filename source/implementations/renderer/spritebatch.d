module implementations.renderer.spritebatch;
import implementations.renderer.mesh;
import implementations.renderer.renderer;
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


class HipSpriteBatch
{
    uint maxQuads;
    uint[] indices;
    float[] vertices;
    Shader shader;
    Mesh mesh;

    protected uint quadsCount;

    this(uint maxQuads = 20_000)
    {
        this.maxQuads = maxQuads;
        indices = new uint[maxQuads*6];
        vertices = new float[maxQuads*9]; //XYZ -> 3, RGBA -> 4, ST -> 2, 3+4+2=9
        vertices[] = 0;

        Shader s = HipRenderer.newShader(HipShaderPresets.SPRITE_BATCH);
        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_ST_VAO(), s);
        mesh.createVertexBuffer(maxQuads, HipBufferUsage.DYNAMIC);
        mesh.createIndexBuffer(maxQuads*6, HipBufferUsage.STATIC);
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
        *(&vertices[quadsCount*cast(uint)(HipSpriteVertex.sizeof/float.sizeof)]) = s.getVertices();
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
        mesh.updateVertices(vertices);
        mesh.draw(quadsCount);
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

    X3
    Y3
    Z3
    R3
    G3
    B3
    A3
    U3
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