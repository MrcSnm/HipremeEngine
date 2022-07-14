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


enum HipTextAlign
{
    CENTER,
    TOP,
    LEFT,
    RIGHT,
    BOTTOM
}

@HipShaderInputLayout struct HipTextRendererVertex
{
    import hip.math.vector;
    Vector2 vPos;
    Vector2 vTexST;
}



private Shader bmTextShader = null;

class HipTextRenderer
{
    HipFont font;
    Mesh mesh;
    ///For controlling easier without having to mess with align
    int x, y;
    ///Where it is actually rendered
    int displayX, displayY;

    ///Update dynamically based on the font, the text scale and the text length
    uint width, height;

    //Line widths, containing width for each line for correctly aplying text align
    uint[] linesWidths;

    HipTextAlign alignh = HipTextAlign.LEFT;
    HipTextAlign alignv = HipTextAlign.TOP;
    index_t[] indices;
    float[] vertices;

    dstring text;

    //Debugging?

    protected bool shouldRenderSpace = false;
    protected bool shouldRenderLineBreak = false;

    //Caching
    protected size_t lastTextLength = 0;
    protected bool shouldUpdateText = true;

    this()
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
        linesWidths.length = 1;
        text = "";
        mesh = new Mesh(HipVertexArrayObject.getVAO!HipTextRendererVertex, bmTextShader);
        //4 vertices per quad
        mesh.createVertexBuffer("DEFAULT".length*4, HipBufferUsage.DYNAMIC);
        //6 indices per quad
        mesh.createIndexBuffer("DEFAULT".length*6, HipBufferUsage.DYNAMIC);
        mesh.sendAttributes();
    }
    void setFont(HipFont font)
    {
        this.font = font;
    }
    protected void updateAlign(int lineNumber)
    {
        uint w = linesWidths[lineNumber];
        displayX = x;
        displayY = y;
        with(HipTextAlign)
        {
            switch(alignh)
            {
                case CENTER:
                    displayX-= w/2;
                    break;
                case RIGHT:
                    displayX-= w;
                    break;
                case LEFT:
                default:
                    break;
            }
            switch(alignv)
            {
                case CENTER:
                    displayY+= height/2;
                    break;
                case BOTTOM:
                    displayY+= height;
                    break;
                case TOP:
                default:
                    break;
            }
        }
    }

    float[] getVertices()
    {
        int yoffset = 0;
        int xoffset = 0;
        //4 floats(vec2 pos, vec2 texst) and 4 vertices per character
        float[] v = new float[text.length*4*4];
        int vI = 0; //vertex buffer index

        dchar lastCharacter = 0;
        int kerningAmount = 0;
        int lineBreakCount = 0;
        updateAlign(0);
        HipFontChar* ch;
        for(int i = 0; i < text.length; i++)
        {
            ch = text[i] in font.characters;
            switch(text[i])
            {
                case '\n':
                    xoffset = 0;
                    updateAlign(++lineBreakCount);
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

                    kerningAmount = font.getKerning(lastCharacter, ch.id);
                    xoffset+= ch.xoffset+kerningAmount;
                    yoffset+= ch.yoffset;
                    //Gen vertices 

                    //Top left
                    v[vI++] = xoffset+displayX; //X
                    v[vI++] = yoffset+displayY; //Y
                    v[vI++] = ch.normalizedX; //S
                    v[vI++] = ch.normalizedY; //T

                    //Top Right
                    v[vI++] = xoffset+displayX+ch.width; //X+W
                    v[vI++] = yoffset+displayY; //Y
                    v[vI++] = ch.normalizedX + ch.normalizedWidth; //S+W
                    v[vI++] = ch.normalizedY; //T

                    //Bot right
                    v[vI++] = xoffset+displayX+ch.width; //X+W
                    v[vI++] = yoffset+displayY + ch.height; //Y
                    v[vI++] = ch.normalizedX + ch.normalizedWidth; //S+W
                    v[vI++] = ch.normalizedY + ch.normalizedHeight; //T

                    //Bot left
                    v[vI++] = xoffset+displayX; //X
                    v[vI++] = yoffset+displayY + ch.height; //Y+H
                    v[vI++] = ch.normalizedX; //S
                    v[vI++] = ch.normalizedY + ch.normalizedHeight; //T+H

                    yoffset-= ch.yoffset;
                    xoffset-= ch.xoffset+kerningAmount;
                    xoffset+= ch.xadvance;

            }
            lastCharacter = text[i];

        }
        return v;
    }

    

    //Defers a call to updateText
    void setText(dstring newText)
    {
        if(text != newText)
        {
            lastTextLength = text.length;
            text = newText;
            this.shouldUpdateText = true;
        }
    }


    protected void recalculateTextBounds()
    {
        int w, h;
        int lastMaxW = 0;
        int lineIndex = 0;

        for(int i = 0; i < text.length; i++)
        {
            HipFontChar* ch = text[i] in font.characters;
            switch(text[i])
            {
                case '\n':
                    h+= ch && ch.height != 0 ? ch.height : font.lineBreakHeight;
                    lastMaxW = max(w, lastMaxW);
                    if(lineIndex + 1 > linesWidths.length)
                        linesWidths.length = lineIndex + 1;
                    linesWidths[lineIndex++] = w;
                    w = 0;
                    break;
                case ' ':
                    w+= ch && ch.width != 0 ? ch.width : font.spaceWidth;
                    break;
                default:
                    w+= ch.xadvance;
                    break;
            }
        }
        width = max(w, lastMaxW);
        if(lineIndex >= linesWidths.length)
            linesWidths.length++;
        linesWidths[lineIndex] = w;
        height = h;
    }

    public void updateText()
    {
        recalculateTextBounds();
        if(text.length > lastTextLength)
        {
            indices.length = (text.length*6);
            index_t index = 0;
            for(index_t i = 0; i < text.length; i++)
            {
                indices[index+0] = cast(index_t)(i*4+0);
                indices[index+1] = cast(index_t)(i*4+1);
                indices[index+2] = cast(index_t)(i*4+2);

                indices[index+3] = cast(index_t)(i*4+2);
                indices[index+4] = cast(index_t)(i*4+3);
                indices[index+5] = cast(index_t)(i*4+0);
                index+=6;
            }
            mesh.setIndices(indices);
        }
        vertices = getVertices();
        mesh.setVertices(vertices);
        shouldUpdateText = false;
    }

    void render()
    {
        if(shouldUpdateText)
            updateText();
        this.font.texture.bind();
        mesh.draw(indices.length);
    }
}
