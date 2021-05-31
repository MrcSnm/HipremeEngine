module implementations.renderer.geometrybatch;
import implementations.renderer.renderer;
import implementations.renderer.shader;
import implementations.renderer.mesh;
import graphics.color;


/**
*   This class uses the vertex layout XYZ RGBA.
*   it is meant to be a 2D API for drawing primitives
*/
class GeometryBatch
{
    protected Mesh mesh;
    protected Shader currentShader;
    protected uint currentIndex;
    protected uint currentVertex;
    protected uint verticesLength;
    protected Color currentColor;
    HipRendererMode mode;
    float[] vertices;
    uint[] indices;
    
    this(uint verticesSize, uint indicesSize, Shader shader)
    {
        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_VAO(), shader);
        vertices = new float[verticesSize];
        indices = new uint[indicesSize];
    }

    void setShader(Shader s)
    {
        currentShader = s;
    }

    /**
    * Adds a vertex to the structure and return its current index.
    */
    uint addVertex(float x, float y, float z)
    {
        alias c = currentColor;
        vertices[currentVertex++] = x;
        vertices[currentVertex++] = y;
        vertices[currentVertex++] = z;
        vertices[currentVertex++] = c.r;
        vertices[currentVertex++] = c.g;
        vertices[currentVertex++] = c.b;
        vertices[currentVertex++] = c.a;
        return verticesLength++;
    }
    pragma(inline, true)
    void addIndex(uint index)
    {
        indices[currentIndex++] = index;
    }
    void setColor(Color c)
    {
        currentColor = c;
    }
    pragma(inline, true)
    protected void triangleVertices(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        addVertex(x1, y1, 0);
        addVertex(x2, y2, 0);
        addVertex(x3, y3, 0);
        addIndex(verticesLength-3);
        addIndex(verticesLength-2);
        addIndex(verticesLength-1);
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
    void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, Color color)
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
        }
        triangleVertices(x1, y1, x2, y2, x3, y3);
    }
    void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, Color color)
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
        }
        addVertex(x1, y1, 0);
        addVertex(x2, y2, 0);

        addIndex(verticesLength-2);
        addIndex(verticesLength-1);
    }
    void drawLine(int x1, int y1, int x2, int y2, Color color)
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
        }
        addVertex(x, y, 0);
        addIndex(verticesLength);
    }
    void drawPixel(int x, int y, Color color)
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
        uint topLeft = addVertex(x, y, 0);
        uint botLeft = addVertex(x, y+h, 0);
        uint botRight= addVertex(x+w, y+h, 0);
        uint topRight= addVertex(x+w, y, 0);

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
        }
        rectangleVertices(x,y,w,h);
    }
    void drawRectangle(int x, int y, int w, int h, Color color)
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
        }
        rectangleVertices(x,y,w,h);
    }
    void fillRectangle(int x, int y, int w, int h, Color color)
    {
        currentColor = color;
        fillRectangle(x,y,w,h);
    }

    void flush()
    {
        currentIndex = 0;
        currentVertex = 0;
        this.mesh.updateVertices(this.vertices);
        this.mesh.updateIndices(this.indices);
        //Vertices to render = indices.length
        this.mesh.draw();
    }

}