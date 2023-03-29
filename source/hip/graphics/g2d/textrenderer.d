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
import hip.graphics.mesh;
import hip.math.matrix;
import hip.api.data.font;
import hip.hiprenderer;
import hip.graphics.g2d.text;
import hip.assetmanager;
public import hip.graphics.orthocamera;
public import hip.api.graphics.batch;
public import hip.api.graphics.text : HipTextAlign;

/**
*   Don't change those names. If the variable names are changed, the shaders should stop working
*/
@HipShaderInputLayout struct HipTextRendererVertex
{
    import hip.math.vector;
    Vector3 vPosition;
    Vector2 vTexST;

    this(Vector3 vPosition, Vector2 vTexST)
    {
        this.vPosition = vPosition;
        this.vTexST = vTexST;
    }

    static enum size_t floatsCount = (HipTextRendererVertex.sizeof / float.sizeof);
    static enum size_t quadsCount = floatsCount*4;
}

@HipShaderVertexUniform("Cbuf")
struct HipTextRendererVertexUniforms
{
    Matrix4 uModel = Matrix4.identity;
    Matrix4 uView = Matrix4.identity;
    Matrix4 uProj = Matrix4.identity;
}

@HipShaderFragmentUniform("FragVars")
struct HipTextRendererFragmentUniforms
{
    float[4] uColor = [1,1,1,1];
}


enum TextRendererPoolSize = 40_000;
private __gshared Shader bmTextShader = null;

/**
*   This class oculd be refactored in the future to actually
* use a spritebatch for its drawing.
*/
class HipTextRenderer : IHipDeferrableText, IHipBatch
{
    mixin(HipDeferredLoad);
    IHipFont font;
    Mesh mesh;
    index_t[] indices;
    HipTextRendererVertex[] vertices;

    private HipText[] textPool;
    private int poolActive;
    protected HipColorf color;
    protected HipOrthoCamera camera;
    protected float managedDepth = 0;
    private uint quadsCount;
    private uint lastDrawQuadsCount;

    this(HipOrthoCamera camera, index_t maxIndices = index_t_maxQuadIndices)
    {
        if(bmTextShader is null)
        {
            bmTextShader = HipRenderer.newShader(HipShaderPresets.BITMAP_TEXT);
            bmTextShader.addVarLayout(ShaderVariablesLayout.from!HipTextRendererVertexUniforms);
            bmTextShader.addVarLayout(ShaderVariablesLayout.from!HipTextRendererFragmentUniforms);
            bmTextShader.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);
            const Viewport v = HipRenderer.getCurrentViewport();
            bmTextShader.uProj = Matrix4.orthoLH(0, v.width, v.height, 0, 0.01, 100);
            bmTextShader.setDefaultBlock("FragVars");
            bmTextShader.bind();
            bmTextShader.sendVars();
        }
        mesh = new Mesh(HipVertexArrayObject.getVAO!HipTextRendererVertex, bmTextShader);
        //6 indices per quad
        indices = new index_t[](maxIndices);
        vertices = new HipTextRendererVertex[](TextRendererPoolSize);
        mesh.createIndexBuffer(maxIndices, HipBufferUsage.STATIC);
        mesh.createVertexBuffer(cast(index_t)vertices.length, HipBufferUsage.DYNAMIC);
        mesh.sendAttributes();
        HipVertexArrayObject.putQuadBatchIndices(indices, maxIndices / 6);
        mesh.setVertices(cast(float[])vertices);
        mesh.setIndices(indices);
        if(camera is null)
            camera = new HipOrthoCamera();
        this.camera = camera;

        import hip.global.gamedef;
        //Promise it won't modify
        setFont(cast(IHipFont)HipDefaultAssets.font);
    }

    void setCurrentDepth(float depth){managedDepth = depth;}

    void setFont(IHipFont font)
    {
        if(this.font !is null && font !is this.font)
        {
            draw();
        }
        this.font = font;
    }

    void setColor(HipColorf color)
    {
        if(this.color != color)
        {
            draw();
        }
        this.color = color;
        bmTextShader.uColor = color;
    }


    //Defers a call to updateText
    void draw(string newText, int x, int y, HipTextAlign alignh = HipTextAlign.CENTER, HipTextAlign alignv = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1)
    {
        import hip.console.log;
        HipText obj;
        if(poolActive >= textPool.length)
        {
            textPool.length = ++poolActive;
            obj = textPool[$-1] = new HipText(boundsWidth, boundsHeight);
        }
        else
            obj = textPool[poolActive++];
        obj.x = x;
        obj.y = y;
        obj.depth = managedDepth;
        obj.boundsWidth = boundsWidth;
        obj.boundsHeight = boundsHeight;
        obj.alignh = alignh;
        obj.alignv = alignv;
        obj.text = newText;
        obj.setFont(font);
    }

    /** 
     * Implementation for unchanging text.
     *  The text will be saved, represented as an internal ID to a managed static HipText. Which means the texture will be baked
     *  so it is possible to actually draw it a lot faster as all the preprocessings are done once.
     */
    void drawStatic(immutable string newText, int x, int y, HipTextAlign alignh = HipTextAlign.CENTER, HipTextAlign alignv = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1)
    {

    }


    void addVerticesFrom(HipText text)
    {
        float[] verts = text.getVertices;
        uint beforeCount = quadsCount;
        quadsCount+= text.drawableTextCount;


        if(vertices.length < quadsCount*4) //4 vertices
            vertices.length = quadsCount*4;
        
        vertices[beforeCount*4..quadsCount*4] = cast(HipTextRendererVertex[])(verts[0..$]);
    }

    ///This way it will reallocate once.
    void addVerticesFrom(HipText[] text)
    {
        if(text.length == 0) return;
        uint beforeCount = quadsCount;
        foreach(t; text) quadsCount+= t.drawableTextCount;
        if(vertices.length < quadsCount*4)
            vertices.length = quadsCount*4;

        import hip.console.log;
        // mixin loglnVars!(beforeCount, quadsCount, lastDrawQuadsCount);log();
        foreach(t; text)
        {
            vertices[beforeCount*4..(beforeCount+ t.drawableTextCount)*4] = 
                cast(HipTextRendererVertex[])(t.getVertices[]);
            beforeCount+= t.drawableTextCount;
        }
    }

    void draw()
    {
        if(font is null)
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Font Missing", "No font attached on HipTextRenderer");
            return;
        }
        foreach(t; textPool[0..poolActive])
            addVerticesFrom(t);
        if(quadsCount - lastDrawQuadsCount != 0)
        {
            mesh.bind();
            this.font.texture.bind();
            mesh.shader.setVertexVar("Cbuf.uProj", camera.proj, true);
            mesh.shader.setVertexVar("Cbuf.uView", camera.view, true);
            mesh.shader.sendVars();
            
            size_t start = lastDrawQuadsCount*4;
            size_t end = quadsCount*4;

            mesh.updateVertices(cast(float[])vertices[start..end], cast(int)start);
            mesh.draw((quadsCount - lastDrawQuadsCount)*6, HipRendererMode.TRIANGLES, lastDrawQuadsCount*6);
            font.texture.unbind();
            mesh.unbind();
        }
        poolActive = 0;
        lastDrawQuadsCount = quadsCount;
    }
    /**
    *   Flush should be took care since it could make it rewrite to the same part of the buffer agin.
    *   While shadow buffering is not implemented, use it as that.
    */
    void flush()
    {
        draw();
        lastDrawQuadsCount = quadsCount = 0;
    }
}
    