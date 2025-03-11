module hip.api.graphics.text;
import hip.api.data.font;

enum HipTextAlign
{
    CENTER,
    TOP,
    LEFT,
    RIGHT,
    BOTTOM
}

void getPositionFromAlignment(
    int x, int y, int width, int height, HipTextAlign alignh, HipTextAlign alignv, 
    out int newX, out int newY, int boundsWidth, int boundsHeight
)
{
    newX = x;
    newY = y;
    with(HipTextAlign)
    {
        switch(alignh)
        {
            case CENTER:
                if(boundsWidth != -1)
                {
                    newX = (x + (boundsWidth)/2) - (width / 2);
                }
                else
                    newX-= width/2;
                break;
            case RIGHT:
                newX-= width;
                break;
            case LEFT:
            default:
                break;
        }
        switch(alignv)
        {
            case CENTER:
                if(boundsHeight != -1)
                    newY = newY + (boundsHeight/2) - height/2;
                else
                    newY+= height/2;
                break;
            case BOTTOM:
                newY-= height;
                break;
            case TOP:
            default:
                break;
        }
    }
}

int putTextVertices(
    IHipFont font, HipTextRendererVertexAPI[] vertices,
    string str, int x, int y, float depth,
    HipTextAlign alignh = HipTextAlign.CENTER, HipTextAlign alignv = HipTextAlign.CENTER,
    int boundsWidth = -1, int boundsHeight = -1, bool wordWrap = false, bool shouldRenderSpace
)
{
    int yoffset = 0;
    bool isFirstLine = true;
    int vI = 0;
    int height = font.getTextHeight(str);
    foreach(HipLineInfo lineInfo; font.wordWrapRange(str, wordWrap ? boundsWidth : -1))
    {
        if(!isFirstLine)
        {
            yoffset+= font.lineBreakHeight;
        }
        isFirstLine = false;
        int xoffset = 0;
        int displayX = void, displayY = void;
        int lineYOffset = yoffset;
        if(alignv == HipTextAlign.TOP) lineYOffset-= lineInfo.minYOffset;

        getPositionFromAlignment(x, y, lineInfo.width, lineInfo.height ? height : lineInfo.height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
        for(int i = 0; i < lineInfo.line.length; i++)
        {
            int kerning = lineInfo.kerningCache[i];
            const(HipFontChar)* ch = lineInfo.fontCharCache[i];

            switch(lineInfo.line[i])
            {
                case ' ':
                    if(!shouldRenderSpace)
                    {
                        xoffset+= font.spaceWidth;
                        break;
                    }
                    goto default;
                default:
                    if(ch is null) continue;
                    ch.putCharacterQuad(
                        cast(float)(xoffset+displayX+ch.xoffset+kerning),
                        cast(float)(yoffset+displayY+lineYOffset + ch.yoffset), depth,
                        vertices[vI..vI+4]
                    );
                    vI+= 4;
                    xoffset+= ch.xadvance;
            }
        }
    }
    return vI;
}
