/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.geometrybatch;
import hip.graphics.orthocamera;
import hip.hiprenderer.renderer;
import hip.hiprenderer.shader;
import hip.error.handler;
import hip.graphics.mesh;
import hip.math.matrix;
import hip.util.format;
import hip.math.utils;
import hip.math.vector;
public import hip.api.graphics.color;
public import hip.api.graphics.batch;


enum defaultColor = HipColor.white;

/**
*   This class uses the vertex layout XYZ RGBA.
*   it is meant to be a 2D API for drawing primitives
*/
class GeometryBatch : IHipBatch
{
    protected Mesh mesh;
    protected index_t currentIndex;
    protected index_t currentVertex;
    protected index_t verticesCount;
    protected index_t indicesCount;
    protected HipColor currentColor;
    HipOrthoCamera camera;
    float[] vertices;
    index_t[] indices;
    
    this(HipOrthoCamera camera = null, index_t verticesCount=64_000, index_t indicesCount=64_000)
    {
        Shader s = HipRenderer.newShader(HipShaderPresets.GEOMETRY_BATCH); 
        s.addVarLayout(new ShaderVariablesLayout("Geom", ShaderTypes.VERTEX, 0)
        .append("uModel", Matrix4.identity)
        .append("uView", Matrix4.identity)
        .append("uProj", Matrix4.identity));

        s.addVarLayout(new ShaderVariablesLayout("FragVars", ShaderTypes.FRAGMENT, 0)
        .append("uGlobalColor", cast(float[4])[1,1,1,1]));

        mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_VAO(), s);
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
        this.setColor(defaultColor);

        if(camera is null)
            camera = new HipOrthoCamera();
        this.camera = camera;

    }

    protected pragma(inline) void checkVerticesCount(int howMuch)
    {
        if(verticesCount+howMuch <= this.vertices.length/7)
            ErrorHandler.assertExit(verticesCount + howMuch <= this.vertices.length/7,
            format!"Too many vertices (%s) for a buffer of size %s"(verticesCount+howMuch, this.vertices.length/7)
            );
    }


    /**
    * Adds a vertex to the structure and return its current index.
    */
    index_t addVertex(float x, float y, float z)
    {
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
    void addIndex(index_t[] newIndices ...)
    {
        if(currentIndex+newIndices.length >= this.indices.length)
            ErrorHandler.assertExit(false,
            format!"Too many indices (%s) for a buffer of size %s"(currentIndex+1, this.indices.length)
            );

        foreach(index; newIndices)
            indices[currentIndex++] = index;
    }
    void setColor(in HipColor c)
    {
        currentColor = c;
    }
    pragma(inline, true)
    protected void triangleVertices(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        checkVerticesCount(3);
        addVertex(x1, y1, 0);
        addVertex(x2, y2, 0);
        addVertex(x3, y3, 0);
        addIndex(
            cast(index_t)(verticesCount-3),
            cast(index_t)(verticesCount-2),
            cast(index_t)(verticesCount-1)
        );
    }


    pragma(inline)
    protected void fillEllipseVertices(int x, int y, int radiusW, int radiusH, int degrees, int precision)
    {
        assert(precision >= 3, "Can't have a circle with less than 3 vertices");

        //Normalize the precision for iterating it on the loop,
        //Multiply by degrees * DEG_TO_RAD
        float angle_mult = (1.0/precision) * degrees * (PI/180.0);

        checkVerticesCount(2);
        index_t centerIndex = addVertex(x, y, 0);
        //The first vertex
        index_t lastVert = addVertex(x + radiusW*cos(0.0), y + radiusH*sin(0.0), 0);
        index_t firstVert = lastVert;
        
        checkVerticesCount(precision);
        for(int i = 0; i < precision; i++)
        {
            //Divide degrees for the total iterations
            float nextAngle = (i+1)*angle_mult;

            //Use a temporary variable to hold the new lastVert for more performance
            //on addIndex calls
            index_t tempNewLastVert = addVertex(x+radiusW*cos(nextAngle), y + radiusH*sin(nextAngle), 0);
            
            addIndex(
                centerIndex, //Puts the center first
                lastVert, //Appends the vertex from the last iteration
                tempNewLastVert//Appends the next vertex
            );
            //Updates the last iteration with the next vertex
            lastVert = tempNewLastVert;
        }

        addIndex(
            centerIndex,
            lastVert,
            firstVert
        );
    }



    void drawEllipse(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColor color = HipColor.invalid, int precision = 24)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.LINE)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.LINE);
        }   
        float angle_mult = (1.0/precision) * degrees * (PI/180.0);
        checkVerticesCount(1);
        index_t currVert = addVertex(x+ radiusW*cos(0.0), y + radiusH*sin(0.0), 0);
        index_t firstVert = currVert;

        checkVerticesCount(precision);
        for(int i = 1; i < precision+1; i++)
        {
            float nextAngle = angle_mult * i;
            index_t tempNextVert = addVertex(x + radiusW * cos(nextAngle), y + radiusH*sin(nextAngle), 0);

            addIndex(currVert, tempNextVert);
            currVert = tempNextVert;
        }

        addIndex(firstVert, currVert);
        setColor(oldColor);
    }

    private HipColor setColorIfChangedAndGetOldColor(in HipColor color)
    {
        HipColor oldColor = currentColor;
        if(color != HipColor.invalid)
            setColor(color);
        return oldColor;
    }

    ///With this default precision, the circle should be smooth enough
    void fillEllipse(int x, int y, int radiusW, int radiusH = -1, int degrees = 360, in HipColor color = HipColor.invalid, int precision = 24)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(radiusH == -1)
            radiusH = radiusW;
        if(HipRenderer.getMode != HipRendererMode.TRIANGLES)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        }
        fillEllipseVertices(x, y, radiusW, radiusH, degrees, precision);
        setColor(oldColor);
    }

    void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.TRIANGLES)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        }
        triangleVertices(x1,y1,x2,y2,x3,y3);
        setColor(oldColor);
    }
    void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.LINE_STRIP)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.LINE_STRIP);
        }
        triangleVertices(x1, y1, x2, y2, x3, y3);
        setColor(oldColor);
    }
    
    void drawLine(int x1, int y1, int x2, int y2, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.LINE)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.LINE);
        }
        checkVerticesCount(2);
        addVertex(x1, y1, 0);
        addVertex(x2, y2, 0);

        addIndex(
            cast(index_t)(verticesCount-2),
            cast(index_t)(verticesCount-1)
        );
        setColor(oldColor);
    }

    pragma(inline) void drawLine(float x1, float y1, float x2, float y2, in HipColor color = HipColor.invalid)
    {
        drawLine(
            cast(int)x1,
            cast(int)y1,
            cast(int)x2,
            cast(int)y2,
            color
        );
    }

    void drawQuadraticBezierLine(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);

        Vector2 last = Vector2(x0, y0);

        float precisionMultiplier = 1.0f/precision;

        for(int i = 0; i <= precision; i++)
        {
            float t = cast(float)i*precisionMultiplier;
            float tNext = t+precisionMultiplier;
            Vector2 bz = quadraticBezier(x0, y0, x1, y1, x2, y2, tNext);
            drawLine(last.x, last.y, bz.x, bz.y);
            last = bz;
        }
        drawLine(last.x, last.y, x2, y2);
        setColor(oldColor);
    }

    void drawPixel(int x, int y, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.POINT)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.POINT);
        }
        checkVerticesCount(1);
        addVertex(x, y, 0);
        addIndex(verticesCount);
        setColor(oldColor);
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
        checkVerticesCount(4);
        index_t topLeft = addVertex(x, y, 0);
        index_t botLeft = addVertex(x, y+h, 0);
        index_t botRight= addVertex(x+w, y+h, 0);
        index_t topRight= addVertex(x+w, y, 0);
 
        addIndex(
            topLeft, botLeft, botRight,
            botRight, topRight, topLeft
        );

    }

    void drawRectangle(int x, int y, int w, int h, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.LINE_STRIP)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.LINE_STRIP);
        }
        rectangleVertices(x,y,w,h);
        setColor(oldColor);
    }
  

    void fillRectangle(int x, int y, int w, int h, in HipColor color = HipColor.invalid)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.TRIANGLES)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        }
        rectangleVertices(x,y,w,h);
        setColor(oldColor);
    }

    void flush()
    {
        const uint count = this.currentIndex;
        if(count == 0)
            return;
        verticesCount = 0;
        currentIndex = 0;
        currentVertex = 0;
        this.mesh.updateVertices(this.vertices);
        this.mesh.updateIndices(this.indices);

        mesh.shader.setFragmentVar("FragVars.uGlobalColor", cast(float[4])[1,1,1,1]);
        mesh.shader.setVertexVar("Geom.uProj",  camera.proj);
        mesh.shader.setVertexVar("Geom.uModel", Matrix4.identity());
        mesh.shader.setVertexVar("Geom.uView",  camera.view);

        mesh.shader.bind();
        mesh.shader.sendVars();
        //Vertices to render = indices.length
        
        this.mesh.draw(count);
    }

}