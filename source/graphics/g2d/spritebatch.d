/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module graphics.g2d.spritebatch;
import graphics.mesh;
import core.stdc.string:memcpy;
import graphics.orthocamera;
import hiprenderer.renderer;
import math.matrix;
import error.handler;
import hiprenderer.shader;
import graphics.material;
import graphics.g2d.sprite;
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
    index_t maxQuads;
    index_t[] indices;
    float[] vertices;
    bool hasBegun;
    Shader shader;
    HipOrthoCamera camera;
    Mesh mesh;
    Material material;

    protected uint quadsCount;

    this(index_t maxQuads = 10_900)
    {
        import std.conv:to;
        ErrorHandler.assertExit(is(index_t == ushort) && index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        this.maxQuads = maxQuads;
        indices = new index_t[maxQuads*6];
        vertices = new float[maxQuads*spriteVertexSize*4]; //XYZ -> 3, RGBA -> 4, ST -> 2, 3+4+2=9
        vertices[] = 0;

        Shader s = HipRenderer.newShader(HipShaderPresets.SPRITE_BATCH);
        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_ST_VAO(), s);
        mesh.vao.bind();
        mesh.createVertexBuffer(cast(index_t)(maxQuads*spriteVertexSize*4), HipBufferUsage.DYNAMIC);
        mesh.createIndexBuffer(cast(index_t)(maxQuads*6), HipBufferUsage.STATIC);
        mesh.sendAttributes();
        setShader(s);
        

        shader.addVarLayout(new ShaderVariablesLayout("Cbuf1", ShaderTypes.VERTEX, ShaderHint.NONE)
        .append("uModel", Matrix4.identity)
        .append("uView", Matrix4.identity)
        .append("uProj", Matrix4.identity));

        shader.addVarLayout(new ShaderVariablesLayout("Cbuf", ShaderTypes.FRAGMENT, ShaderHint.NONE)
        .append("uBatchColor", cast(float[4])[1,1,1,1])
        );


        shader.useLayout.Cbuf;
        shader.bind();
        shader.sendVars();

        // material = new Material(mesh.shader);
        // material.setFragmentVar("uBatchColor", cast(float[4])[1,0,0,1]);

        camera = new HipOrthoCamera();

        index_t offset = 0;
        for(index_t i = 0; i < maxQuads; i+=6)
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
        // mesh.shader.bind();
        // mesh.shader.setFragmentVar("uBatchColor", cast(float[4])[1,1,1,1]);
        // material.bind();
        mesh.shader.setVertexVar("Cbuf1.uProj", camera.proj);
        mesh.shader.setVertexVar("Cbuf1.uModel",Matrix4.identity());
        mesh.shader.setVertexVar("Cbuf1.uView", camera.view);
        
        mesh.shader.bind();
        mesh.shader.sendVars();
        HipRenderer.exitOnError();

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