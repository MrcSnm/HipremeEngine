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
import hip.assetmanager;
public import hip.graphics.orthocamera;
public import hip.api.graphics.batch;
public import hip.api.graphics.text : HipTextAlign, Size;

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
    Matrix4 uMVP = Matrix4.identity;
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
class HipTextRenderer : IHipBatch
{
    IHipFont font;
    Mesh mesh;
    index_t[] indices;
    HipTextRendererVertex[] vertices;

    protected HipColor color;
    protected HipOrthoCamera camera;
    protected float managedDepth = 0;
    private uint quadsCount;
    private uint lastDrawQuadsCount;
    bool shouldRenderLineBreak, shouldRenderSpace;
    private __gshared uint[] linesWidths;

    this(HipOrthoCamera camera, index_t maxQuads = DefaultMaxSpritesPerBatch)
    {
        import hip.error.handler;
        import hip.util.conv:to;
        if(bmTextShader is null)
        {
            import hip.hiprenderer.initializer;
            bmTextShader = newShader(HipShaderPresets.BITMAP_TEXT);
            bmTextShader.addVarLayout(ShaderVariablesLayout.from!(HipTextRendererVertexUniforms)(HipRenderer.getInfo));
            bmTextShader.addVarLayout(ShaderVariablesLayout.from!(HipTextRendererFragmentUniforms)(HipRenderer.getInfo));
            bmTextShader.setBlending(HipBlendFunction.SRC_ALPHA, HipBlendFunction.ONE_MINUS_SRC_ALPHA, HipBlendEquation.ADD);
            const Viewport v = HipRenderer.getCurrentViewport();
            bmTextShader.uMVP = Matrix4.orthoLH(0, v.width, v.height, 0, 0.01, 100);
            bmTextShader.setDefaultBlock("FragVars");
            bmTextShader.sendVars();
        }
        ErrorHandler.assertLazyExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is "~to!string(index_t.max/6));
        mesh = new Mesh(HipVertexArrayObject.getVAO!HipTextRendererVertex, bmTextShader);
        //6 indices per quad
        vertices = new HipTextRendererVertex[](maxQuads*4);
        mesh.setIndices(HipRenderer.getQuadIndexBuffer(maxQuads));
        mesh.createVertexBuffer(cast(index_t)vertices.length, HipResourceUsage.Dynamic);
        mesh.sendAttributes();
        mesh.setVertices(vertices);
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

    void setColor(HipColor color)
    {
        if(this.color != color)
        {
            if(this.color != HipColor.no)
                draw();
            bmTextShader.uColor = HipColorf(color);
        }
        this.color = color;
    }

    /**
     * Implementation for unchanging text.
     *  The text will be saved, represented as an internal ID to a managed static HipText. Which means the texture will be baked
     *  so it is possible to actually draw it a lot faster as all the preprocessings are done once.
     */
    void draw(string str, int x, int y, float scale = 1, HipTextAlign align_ = HipTextAlign.centerLeft, Size bounds = Size.init, bool wordWrap = false)
    {
        import hip.api.graphics.text;
        int vI = quadsCount*4; //vertex buffer index
        vI+= putTextVertices(font, (cast(HipTextRendererVertexAPI[])vertices)[vI..$], str, x, y, managedDepth, scale, align_, bounds, wordWrap, shouldRenderSpace);
        quadsCount = vI/4;
    }

    ///This way it will reallocate once.
    void addVertices(void[] vertices, IHipFont font)
    {
        if(vertices.length > 0)
        {
            setFont(font);
            HipTextRendererVertex[] theVerts = cast(HipTextRendererVertex[])vertices;
            if(theVerts.length+quadsCount*4 > this.vertices.length)
                this.vertices.length = theVerts.length+quadsCount*4;
            this.vertices[quadsCount*4..quadsCount*4+theVerts.length] = theVerts[0..$];
            quadsCount+= theVerts.length/4;
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

        if(quadsCount - lastDrawQuadsCount != 0)
        {
            mesh.bind();
            this.font.texture.bind();
            mesh.shader.setVertexVar("Cbuf.uMVP", camera.getMVP(), true);
            mesh.shader.sendVars();

            size_t start = lastDrawQuadsCount*4;
            size_t end = quadsCount*4;

            mesh.updateVertices(vertices[start..end], cast(int)start);

            mesh.draw((quadsCount - lastDrawQuadsCount)*6, HipRendererMode.triangles, lastDrawQuadsCount*6);
            font.texture.unbind();
            mesh.unbind();
        }
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