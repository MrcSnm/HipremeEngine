/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.textrenderer;
import hip.graphics.g2d;
import hip.graphics.mesh;
import hip.util.data_structures;
import hip.math.utils : max;
import hip.util.conv:to;
import hip.error.handler;
import hip.console.log;
import hip.math.matrix;
import hip.hipengine.api.data.font;
import hip.hiprenderer;
import hip.graphics.g2d.text;


enum HipTextAlign
{
    CENTER,
    TOP,
    LEFT,
    RIGHT,
    BOTTOM
}


/**
*   Don't change those names. If the variable names are changed, the shaders should stop working
*/
@HipShaderInputLayout struct HipTextRendererVertex
{
    import hip.math.vector;
    Vector2 vPos;
    Vector2 vTexST;
}



private Shader bmTextShader = null;

/**
*   This class oculd be refactored in the future to actually
* use a spritebatch for its drawing.
*/
class HipTextRenderer
{
    HipFont font;
    Mesh mesh;
    index_t[] indices;
    float[] vertices;

    private HipText[] textPool;
    private int poolActive;
    private uint quadsCount;

    this(ushort maxIndices = index_t_maxQuadIndices)
    {
        if(bmTextShader is null)
        {
            bmTextShader = HipRenderer.newShader(HipShaderPresets.BITMAP_TEXT);
            bmTextShader.addVarLayout(new ShaderVariablesLayout("Cbuf", ShaderTypes.VERTEX, 0)
            .append("uModel", Matrix4.identity)
            .append("uView", Matrix4.identity)
            .append("uProj", Matrix4.identity)
            );
            bmTextShader.addVarLayout(new ShaderVariablesLayout("FragBuf", ShaderTypes.FRAGMENT, 0)
            .append("uColor", cast(float[4])[1.0,1.0,1.0,1.0])
            );

            bmTextShader.setFragmentVar("FragBuf.uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]);
            bmTextShader.uModel = Matrix4.identity;
            const Viewport v = HipRenderer.getCurrentViewport();
            bmTextShader.uView = Matrix4.identity;
            bmTextShader.uProj = Matrix4.orthoLH(0, v.w, v.h, 0, 0.01, 100);
            bmTextShader.bind();
            bmTextShader.sendVars();
        }
        mesh = new Mesh(HipVertexArrayObject.getVAO!HipTextRendererVertex, bmTextShader);
        //4 vertices per quad
        mesh.createVertexBuffer("DEFAULT".length*4, HipBufferUsage.DYNAMIC);
        //6 indices per quad
        indices = new index_t[](maxIndices);
        mesh.createIndexBuffer(maxIndices, HipBufferUsage.STATIC);
        mesh.sendAttributes();
        HipVertexArrayObject.putQuadBatchIndices(indices, maxIndices / 6);
        mesh.setIndices(indices);
    }
    void setFont(HipFont font)
    {
        this.font = font;
    }


    //Defers a call to updateText
    void addText(int x, int y, dstring newText, HipTextAlign alignh = HipTextAlign.CENTER, HipTextAlign alignv = HipTextAlign.CENTER)
    {
        HipText obj;
        if(poolActive <= textPool.length)
        {
            textPool.length = ++poolActive;
            obj = textPool[$-1] = new HipText();
        }
        else
            obj = textPool[poolActive++];
        obj.text = newText;
        obj.setFont(font);
        obj.x = x;
        obj.y = y;
        obj.alignh = alignh;
        obj.alignv = alignv;

    }

    void draw(HipText text)
    {
        float[] verts = text.getVertices;
        uint beforeCount = quadsCount;
        quadsCount+= text.text.length;


        if(vertices.length < quadsCount*4*4) //4 floats, 4 vertices
            vertices.length = quadsCount*4*4;
        
        vertices[beforeCount*4*4..quadsCount*4*4] = verts[0..$];
    }



    void render()
    {
        foreach(i; 0..poolActive)
            draw(textPool[i]);
        this.font.texture.bind();
        mesh.setVertices(vertices);
        mesh.draw(quadsCount*6);

        poolActive = 0;
        quadsCount = 0;
    }
}
