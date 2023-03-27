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
    private uint quadsCount;
    protected float managedDepth = 0;

    this(HipOrthoCamera camera, index_t maxIndices = index_t_maxQuadIndices)
    {
        if(bmTextShader is null)
        {
            bmTextShader = HipRenderer.newShader(HipShaderPresets.BITMAP_TEXT);
            bmTextShader.addVarLayout(ShaderVariablesLayout.from!HipTextRendererVertexUniforms);
            bmTextShader.addVarLayout(ShaderVariablesLayout.from!HipTextRendererFragmentUniforms);
            const Viewport v = HipRenderer.getCurrentViewport();
            bmTextShader.uProj = Matrix4.orthoLH(0, v.width, v.height, 0, 0.01, 100);
            bmTextShader.setDefaultBlock("FragVars");
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
            render();
        }
        this.font = font;
    }

    void setColor(HipColorf color)
    {
        if(this.color != color)
        {
            render();
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


    void draw(HipText text)
    {
        float[] verts = text.getVertices;
        uint beforeCount = quadsCount;
        quadsCount+= text.drawableTextCount;


        if(vertices.length < quadsCount*4) //4 vertices
            vertices.length = quadsCount*4;
        
        vertices[beforeCount*4..quadsCount*4] = cast(HipTextRendererVertex[])(verts[0..$]);
    }


    void draw()
    {
        
    }
    alias render = flush;
    void flush()
    {
        if(font is null)
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Font Missing", "No font attached on HipTextRenderer");
            return;
        }
        HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
        foreach(i; 0..poolActive)
        {
            draw(textPool[i]);
        }
        if(quadsCount != 0)
        {
            mesh.bind();
            this.font.texture.bind();
            mesh.shader.setVertexVar("Cbuf.uProj", camera.proj, true);
            mesh.shader.setVertexVar("Cbuf.uView", camera.view, true);
            mesh.shader.sendVars();
            mesh.setVertices(cast(float[])vertices[0..quadsCount*4]);
            mesh.draw(quadsCount*6);
            font.texture.unbind();
            mesh.unbind();
        }
        poolActive = 0;
        quadsCount = 0;
    }
}
    