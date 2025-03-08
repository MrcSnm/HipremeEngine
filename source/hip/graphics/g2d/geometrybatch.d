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
import hip.math.utils;
import hip.math.vector;
public import hip.api.graphics.color;
public import hip.api.graphics.batch;


enum defaultColor = HipColor.white;

@HipShaderInputLayout struct HipGeometryBatchVertex
{
    import hip.math.vector;
    Vector3 vPosition;
    // @HipShaderInputPadding float __padding = 0;
    HipColor vColor = HipColor.white;

    static enum floatCount = HipGeometryBatchVertex.sizeof / float.sizeof;
}

@HipShaderVertexUniform("Geom")
struct HipGeometryBatchVertexUniforms
{
    Matrix4 uModel = Matrix4.identity;
    Matrix4 uView = Matrix4.identity;
    Matrix4 uProj = Matrix4.identity;
}

@HipShaderFragmentUniform("FragVars")
struct HipGeometryBatchFragmentUniforms
{
    float[4] uGlobalColor = [1,1,1,1];
}

/**
*   This class uses the vertex layout XYZ RGBA.
*   it is meant to be a 2D API for drawing primitives
*/
class GeometryBatch : IHipBatch
{
    protected Mesh mesh;
    protected index_t lastIndexDrawn;
    protected index_t lastVertexDrawn;
    protected index_t currentIndex;
    protected index_t verticesCount;
    protected index_t indicesCount;
    protected HipColor currentColor;

    float managedDepth = 0;
    HipOrthoCamera camera;
    HipGeometryBatchVertex[] vertices;
    index_t[] indices;

    
    this(HipOrthoCamera camera = null, index_t verticesCount=DefaultMaxGeometryBatchVertices, index_t indicesCount=DefaultMaxGeometryBatchVertices)
    {
        import hip.hiprenderer.initializer;
        Shader s = newShader(HipShaderPresets.GEOMETRY_BATCH);
        s.addVarLayout(ShaderVariablesLayout.from!(HipGeometryBatchVertexUniforms)(HipRenderer.getInfo));
        s.addVarLayout(ShaderVariablesLayout.from!(HipGeometryBatchFragmentUniforms)(HipRenderer.getInfo));
        s.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);


        mesh = new Mesh(HipVertexArrayObject.getVAO!HipGeometryBatchVertex, s);
        vertices = new HipGeometryBatchVertex[verticesCount];
        indices = new index_t[indicesCount];
        indices[] = 0;
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
        if(verticesCount+howMuch >= this.vertices.length/HipGeometryBatchVertex.floatCount)
        {
            import hip.util.string;
            String s = String("Too many vertices ", verticesCount+howMuch, " for a buffer of size ", 
                this.vertices.length/HipGeometryBatchVertex.floatCount
            );
            ErrorHandler.assertExit(false, s.toString);
        }
    }

    void setCurrentDepth(float depth){managedDepth = depth;}


    /**
    * Adds a vertex to the structure and return its current index.
    */
    index_t addVertex(float x, float y, float z)
    {
        if(currentColor.a == 0) return verticesCount;
        vertices[verticesCount] = HipGeometryBatchVertex(
            Vector3(x,y,z),
            currentColor
        );
        return verticesCount++;
    }
    
    void addIndex(index_t[] newIndices ...)
    {
        if(currentColor.a == 0) return;
        if(currentIndex+newIndices.length >= this.indices.length)
        {
            import hip.util.string;
            String s = String("Too many indices ", currentIndex+1, " for a buffer of size ", this.indices.length);
            ErrorHandler.assertExit(false, s.toString);
        }
        foreach(index; newIndices)
            indices[currentIndex++] = index;
    }
    void setColor(HipColor c)
    {
        assert(c != HipColor.no, "Can't use 'no' color on geometry batch");
        currentColor = c;
    }

    protected void triangleVertices(int x1, int y1, int x2, int y2, int x3, int y3)
    {
        checkVerticesCount(3);
        addVertex(x1, y1, managedDepth);
        addVertex(x2, y2, managedDepth);
        addVertex(x3, y3, managedDepth);
        addIndex(
            cast(index_t)(verticesCount-3),
            cast(index_t)(verticesCount-2),
            cast(index_t)(verticesCount-1)
        );
    }


    protected void fillEllipseVertices(int x, int y, int radiusW, int radiusH, int degrees, int startDegrees ,int precision)
    {
        // assert(precision >= 3, "Can't have a circle with less than 3 vertices");

        //Normalize the precision for iterating it on the loop,
        //Multiply by degrees * DEG_TO_RAD
        float angle_mult = (1.0/precision) * (degrees) * (PI/180.0);

        float startAngle = (PI/180.0) * startDegrees;

        checkVerticesCount(2);
        index_t centerIndex = addVertex(x, y, managedDepth);
        //The first vertex
        index_t lastVert = addVertex(x + radiusW*cos(startAngle), y + radiusH*sin(startAngle), managedDepth);
        index_t firstVert = lastVert;
        
        checkVerticesCount(precision);
        for(int i = 0; i < precision; i++)
        {
            //Divide degrees for the total iterations
            float nextAngle = (i+1)*angle_mult + startAngle;

            //Use a temporary variable to hold the new lastVert for more performance
            //on addIndex calls
            index_t tempNewLastVert = addVertex(x+radiusW*cos(nextAngle), y + radiusH*sin(nextAngle), managedDepth);
            
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



    void drawEllipse(int x, int y, int radiusW, int radiusH, int degrees = 360, HipColor color = HipColor.no, int precision = 24)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.LINE)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.LINE);
        }
        float angle_mult = (1.0/precision) * degrees * (PI/180.0);
        checkVerticesCount(1);
        index_t currVert = addVertex(x+ radiusW*cos(0.0), y + radiusH*sin(0.0), managedDepth);
        index_t firstVert = currVert;

        checkVerticesCount(precision);
        for(int i = 1; i < precision+1; i++)
        {
            float nextAngle = angle_mult * i;
            index_t tempNextVert = addVertex(x + radiusW * cos(nextAngle), y + radiusH*sin(nextAngle), managedDepth);

            addIndex(currVert, tempNextVert);
            currVert = tempNextVert;
        }

        addIndex(firstVert, currVert);
        setColor(oldColor);
    }

    private HipColor setColorIfChangedAndGetOldColor(in HipColor color)
    {
        HipColor oldColor = currentColor;
        if(color != HipColor.no)
            setColor(color);
        return oldColor;
    }

    ///With this default precision, the circle should be smooth enough
    void fillEllipse(int x, int y, int radiusW, int radiusH = -1, int degrees = 360, HipColor color = HipColor.no, int precision = 24)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(radiusH == -1)
            radiusH = radiusW;
        if(HipRenderer.getMode != HipRendererMode.TRIANGLES)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        }
        fillEllipseVertices(x, y, radiusW, radiusH, degrees, 0, precision);
        setColor(oldColor);
    }

    void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color = HipColor.no)
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
    void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color = HipColor.no)
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
    
    void drawLine(int x1, int y1, int x2, int y2, HipColor color = HipColor.no)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.LINE)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.LINE);
        }
        checkVerticesCount(2);
        addVertex(x1, y1, managedDepth);
        addVertex(x2, y2, managedDepth);

        addIndex(
            cast(index_t)(verticesCount-2),
            cast(index_t)(verticesCount-1)
        );
        setColor(oldColor);
    }

    void drawLine(float x1, float y1, float x2, float y2, HipColor color = HipColor.no)
    {
        drawLine(
            cast(int)x1,
            cast(int)y1,
            cast(int)x2,
            cast(int)y2,
            color
        );
    }

    void drawQuadraticBezierLine(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, HipColor color = HipColor.no)
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

    void drawPixel(int x, int y, HipColor color = HipColor.no)
    {
        HipColor oldColor = setColorIfChangedAndGetOldColor(color);
        if(HipRenderer.getMode != HipRendererMode.POINT)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.POINT);
        }
        checkVerticesCount(1);
        addVertex(x, y, managedDepth);
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
        index_t topLeft = addVertex(x, y, managedDepth);
        index_t botLeft = addVertex(x, y+h, managedDepth);
        index_t botRight= addVertex(x+w, y+h, managedDepth);
        index_t topRight= addVertex(x+w, y, managedDepth);
 
        addIndex(
            topLeft, botLeft, botRight,
            botRight, topRight, topLeft
        );

    }

    void drawRectangle(int x, int y, int w, int h, HipColor color = HipColor.no)
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

    void fillRoundRect(int x, int y, int w, int h, int radius = 4, HipColor color = HipColor.no, int vertices = 16)
    {
        if(radius == 0)
            return fillRectangle(x,y,w,h,color);
        if(HipRenderer.getMode != HipRendererMode.TRIANGLES)
        {
            flush();
            HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        }
        int vPerEdge = vertices/4;
        int r2 = radius*2;
        HipColor old = setColorIfChangedAndGetOldColor(color);

        ///Draw internal rect.
        rectangleVertices(x+radius, y+radius, w-r2, h-r2);

        ///Draw ellipses and also draw border rects
        //Top Left
        fillEllipseVertices(x+radius, y+radius, radius, radius, 90, 180, vPerEdge);
        rectangleVertices(x+radius, y, w - r2, radius);
        //Top Right
        fillEllipseVertices(x+w-radius, y+radius, radius, radius, 90, 270, vPerEdge);
        rectangleVertices(x+w-radius, y+radius, radius, h-r2);
        // Bottom Right
        fillEllipseVertices(x+w-radius, y+h-radius, radius, radius, 90, 0, vPerEdge);
        rectangleVertices(x+radius, y+h-radius, w-r2, radius);
        //Bottom Left
        fillEllipseVertices(x+radius, y+h-radius, radius, radius, 90, 90, vPerEdge);
        rectangleVertices(x, y+radius, radius, h-r2);

        setColor(old);
    }
  

    void fillRectangle(int x, int y, int w, int h, HipColor color = HipColor.no)
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

    void draw()
    {
        const uint count = this.currentIndex;
        import hip.console.log;

        if(count - lastIndexDrawn != 0)
        {
            mesh.bind();
            mesh.updateVertices(cast(float[])vertices[lastVertexDrawn..verticesCount], lastVertexDrawn);
            mesh.updateIndices(indices[lastIndexDrawn..currentIndex], lastIndexDrawn);

            mesh.shader.setFragmentVar("FragVars.uGlobalColor", cast(float[4])[1,1,1,1], true);
            mesh.shader.setVertexVar("Geom.uProj",  camera.proj, true);
            mesh.shader.setVertexVar("Geom.uModel", Matrix4.identity(), true);
            mesh.shader.setVertexVar("Geom.uView",  camera.view, true);

            mesh.shader.sendVars();
            //Vertices to render = indices.length
            this.mesh.draw(count - lastIndexDrawn, HipRenderer.getMode, lastIndexDrawn);
            mesh.unbind();
        }
        lastIndexDrawn = count;
        lastVertexDrawn = verticesCount;
    }

    void flush()
    {
        draw();
        lastVertexDrawn = verticesCount = 0;
        lastIndexDrawn = currentIndex = 0;
    }

}