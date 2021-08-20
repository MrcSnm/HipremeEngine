/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module graphics.g2d.geometrybatch;
import implementations.renderer.renderer;
import implementations.renderer.shader;
import graphics.mesh;
import math.matrix;
import graphics.color;
import std.format:format;


/**
*   This class uses the vertex layout XYZ RGBA.
*   it is meant to be a 2D API for drawing primitives
*/
class GeometryBatch
{
    protected Mesh mesh;
    protected Shader currentShader;
    protected index_t currentIndex;
    protected index_t currentVertex;
    protected index_t verticesCount;
    protected index_t indicesCount;
    protected HipColor currentColor;
    HipRendererMode mode;
    float[] vertices;
    index_t[] indices;
    
    this(index_t verticesCount, index_t indicesCount)
    {
        Shader s = HipRenderer.newShader(HipShaderPresets.GEOMETRY_BATCH); 
        s.addVarLayout(new ShaderVariablesLayout("Geom", ShaderTypes.VERTEX, 0)
        .append("uModel", Matrix4.identity)
        .append("uView", Matrix4.identity)
        .append("uProj", Matrix4.identity));

        s.addVarLayout(new ShaderVariablesLayout("FragVars", ShaderTypes.FRAGMENT, 0)
        .append("uGlobalColor", cast(float[4])[1,1,1,1]));

        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_VAO(), s);
        setShader(s);
        vertices = new float[verticesCount*7]; //XYZ, RGBA
        indices = new index_t[indicesCount];
        indices[] = 0;
        vertices[] = 0;
        //Initialize the mesh with 0
        mesh.createVertexBuffer(verticesCount, HipBufferUsage.DYNAMIC);
        mesh.createIndexBuffer(indicesCount, HipBufferUsage.DYNAMIC);
        mesh.vao.bind();
        mesh.setIndices(indices);
        mesh.setVertices(vertices);
        mesh.sendAttributes();
        this.setColor(HipColor(1,1,1,1));

    }

    void setShader(Shader s)
    {
        currentShader = s;
        mesh.setShader(s);
    }

    /**
    * Adds a vertex to the structure and return its current index.
    */
    index_t addVertex(float x, float y, float z)
    {
        assert(verticesCount+1 <= this.vertices.length/7,
            format!"Too many vertices (%s) for a buffer of size %s"(verticesCount+1, this.vertices.length/7)
        );

        alias c = currentColor;
        vertices[currentVertex++] = x;
        vertices[currentVertex++] = y;
        vertices[currentVertex++] = z;
        vertices[currentVertex++] = c.r;
        vertices[currentVertex++] = c.g;
        vertices[currentVertex++] = c.b;
        vertices[currentVertex++] = c.a;

        return verticesCount++;
    }
    pragma(inline, true)
    void addIndex(index_t index)
    {
        assert(currentIndex+1 <= this.indices.length,
            format!"Too many indices (%s) for a buffer of size %s"(currentIndex+1, this.indices.length)
        );
        indices[currentIndex++] = index;
    }
    void setColor(HipColor c)
    {
        currentColor = c;
    }
    pragma(inline, true)
    protected void triangleVertices(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        addVertex(x1, y1, 0);
        addVertex(x2, y2, 0);
        addVertex(x3, y3, 0);
        addIndex(cast(index_t)(verticesCount-3));
        addIndex(cast(index_t)(verticesCount-2));
        addIndex(cast(index_t)(verticesCount-1));
    }
    void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        if(mode != HipRendererMode.TRIANGLES)
        {
            flush();
            mode = HipRendererMode.TRIANGLES;
        }
        triangleVertices(x1,y1,x2,y2,x3,y3);
    }
    void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color)
    {
        currentColor = color;
        fillTriangle(x1,y1,x2,y2,x3,y3);
    }
    void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        if(mode != HipRendererMode.LINE_STRIP)
        {
            flush();
            mode = HipRendererMode.LINE_STRIP;
            HipRenderer.setRendererMode(mode);
        }
        triangleVertices(x1, y1, x2, y2, x3, y3);
    }
    void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color)
    {
        currentColor = color;
        drawTriangle(x1,y1,x2,y2,x3,y3);
    }
    void drawLine(int x1, int y1, int x2, int y2)
    {
        if(mode != HipRendererMode.LINE)
        {
            flush();
            mode = HipRendererMode.LINE;
            HipRenderer.setRendererMode(mode);
        }
        addVertex(x1, y1, 0);
        addVertex(x2, y2, 0);

        addIndex(cast(index_t)(verticesCount-2));
        addIndex(cast(index_t)(verticesCount-1));
    }
    void drawLine(int x1, int y1, int x2, int y2, HipColor color)
    {
        currentColor = color;
        drawLine(x1,y1,x2,y2);
    }

    void drawPixel(int x, int y)
    {
        if(mode != HipRendererMode.POINT)
        {
            flush();
            mode = HipRendererMode.POINT;
            HipRenderer.setRendererMode(mode);
        }
        addVertex(x, y, 0);
        addIndex(verticesCount);
    }
    void drawPixel(int x, int y, HipColor color)
    {
        currentColor = color;
        drawPixel(x,y);
    }

    /**
    *   Draws the following rectangle scheme:
    *  0 _______ 3
    *   |       |
    *   |       |
    *   |_______|
    *  1        2
    *   0, 1, 2
    *   2, 3, 0
    */
    pragma(inline, true)
    protected void rectangleVertices(int x, int y, int w, int h)
    {
        index_t topLeft = addVertex(x, y, 0);
        index_t botLeft = addVertex(x, y+h, 0);
        index_t botRight= addVertex(x+w, y+h, 0);
        index_t topRight= addVertex(x+w, y, 0);

        addIndex(topLeft);
        addIndex(botLeft);
        addIndex(botRight);

        addIndex(botRight);
        addIndex(topRight);
        addIndex(topLeft);

    }

    void drawRectangle(int x, int y, int w, int h)
    {
        if(mode != HipRendererMode.TRIANGLES)
        {
            flush();
            mode = HipRendererMode.TRIANGLES;
            HipRenderer.setRendererMode(mode);
        }
        rectangleVertices(x,y,w,h);
    }
    void drawRectangle(int x, int y, int w, int h, HipColor color)
    {
        currentColor = color;
        drawRectangle(x,y,w,h);
    }

    void fillRectangle(int x, int y, int w, int h)
    {
        if(mode != HipRendererMode.LINE_STRIP)
        {
            flush();
            mode = HipRendererMode.LINE_STRIP;
            HipRenderer.setRendererMode(mode);
        }
        rectangleVertices(x,y,w,h);
    }
    void fillRectangle(int x, int y, int w, int h, HipColor color)
    {
        currentColor = color;
        fillRectangle(x,y,w,h);
    }

    void flush()
    {
        const uint count = this.currentIndex;
        verticesCount = 0;
        currentIndex = 0;
        currentVertex = 0;
        this.mesh.updateVertices(this.vertices);
        this.mesh.updateIndices(this.indices);

        currentShader.setFragmentVar("FragVars.uGlobalColor", cast(float[4])[1,1,1,1]);
        static float t = 0;
        t-= 0.001;
        currentShader.setVertexVar("Geom.uProj", Matrix4.orthoLH(0, 800, 600, 0, 0.1, 1));
        currentShader.setVertexVar("Geom.uModel",Matrix4.identity());
        currentShader.setVertexVar("Geom.uView", Matrix4.identity());
        currentShader.bind();
        currentShader.sendVars();
        //Vertices to render = indices.length
        
        this.mesh.draw(count);
    }

}