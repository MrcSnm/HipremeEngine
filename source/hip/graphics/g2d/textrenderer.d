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

    protected HipColor color;
    protected HipOrthoCamera camera;
    protected float managedDepth = 0;
    private uint quadsCount;
    private uint lastDrawQuadsCount;
    bool shouldRenderLineBreak, shouldRenderSpace;
    private __gshared uint[] linesWidths;

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

    void setColor(HipColor color)
    {
        if(this.color != color)
            draw();
        this.color = color;
        bmTextShader.uColor = HipColorf(color);
    }

    /** 
     * Implementation for unchanging text.
     *  The text will be saved, represented as an internal ID to a managed static HipText. Which means the texture will be baked
     *  so it is possible to actually draw it a lot faster as all the preprocessings are done once.
     */
    void draw(string text, int x, int y, HipTextAlign alignh = HipTextAlign.CENTER, HipTextAlign alignv = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1)
    {
        import hip.util.string : toUTF32;
        import hip.api.graphics.text;
        import hip.math.vector;

        dstring str = text.toUTF32;
        int width = void, height = void;
        font.calculateTextBounds(str, linesWidths, width, height);
        int yoffset = 0;
        int xoffset = 0;
        //4 floats(vec2 pos, vec2 texst) and 4 vertices per character
        alias v = vertices;
        int vI = quadsCount; //vertex buffer index

        int kerningAmount = 0;
        int lineBreakCount = 0;
        int displayX = void, displayY = void;
        getPositionFromAlignment(x, y, linesWidths[0], height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
        HipFontChar* lastCharacter;
        HipFontChar* ch;
        for(int i = 0; i < str.length; i++)
        {
            ch = str[i] in font.characters;
            if(ch is null)
            {
                import hip.error.handler;
                import hip.util.conv;
                ErrorHandler.showWarningMessage("Unrecognized character found", "Unrecognized: "~to!string(str[i]));
                continue;
            }
            switch(str[i])
            {
                case '\n':
                    xoffset = 0;
                    getPositionFromAlignment(x, y, linesWidths[++lineBreakCount], height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
                    if(ch && ch.width != 0 && ch.height != 0 && shouldRenderLineBreak)
                        goto default;
                    else
                    {
                        yoffset+= ch && ch.height != 0 ? ch.height : font.lineBreakHeight;
                    }
                    break;
                case ' ':
                    if(shouldRenderSpace)
                        goto default;
                    else
                        xoffset+= ch && ch.width != 0 ? ch.width : font.spaceWidth;
                    break;
                default:
                    //Find kerning
                    if(lastCharacter)
                        kerningAmount = font.getKerning(lastCharacter, ch);
                    xoffset+= ch.xoffset+kerningAmount;
                    yoffset+= ch.yoffset;
                    //Gen vertices 

                    //Top left
                    v[vI++] = HipTextRendererVertex(
                        Vector3(
                            xoffset+displayX, //X
                            yoffset+displayY, //Y
                            managedDepth
                        ),
                        Vector2(ch.normalizedX, ch.normalizedY) //ST
                    );
                    //Top Right
                    v[vI++] = HipTextRendererVertex(
                        Vector3(
                            xoffset+displayX+ch.width,
                            yoffset+displayY,
                            managedDepth
                        ),
                        Vector2(ch.normalizedX + ch.normalizedWidth, ch.normalizedY) //S + Wnorm, T
                    );
                    //Bot right
                    v[vI++] = HipTextRendererVertex(
                        Vector3(
                            xoffset+displayX+ch.width, //X+W
                            yoffset+displayY + ch.height,//Y+H
                            managedDepth
                        ), 
                        Vector2(
                            ch.normalizedX + ch.normalizedWidth, //S+Wnorm
                            ch.normalizedY + ch.normalizedHeight //T+Hnorm
                        )
                    );
                    //Bot left
                    v[vI++] = HipTextRendererVertex(
                        Vector3(
                            xoffset+displayX, //X
                            yoffset+displayY + ch.height, //Y+H
                            managedDepth
                        ),
                        Vector2(
                            ch.normalizedX, ch.normalizedY + ch.normalizedHeight // S, T+Hnorm
                        )
                    );

                    yoffset-= ch.yoffset;
                    xoffset-= ch.xoffset+kerningAmount;
                    xoffset+= ch.xadvance;

            }
            lastCharacter = ch;
        }
        quadsCount = vI;
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
    