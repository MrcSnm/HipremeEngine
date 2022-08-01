module hip.graphics.g2d.text;

import hip.graphics.g2d.textrenderer;
import hip.hipengine.api.data.font;


/**
*   Formatting the text:
* Text should be formatted using the $() syntax.
* Currently, no formatting is support, but that syntax is reserved and in the future, it
* will be used as for example: $(RGB, 1.0, 1.0, 1.0) or even $(WHITE), so, basic parsing
* is being done for accounting how many text does really need to be rendered.
*/
class HipText
{
    HipTextAlign alignh = HipTextAlign.LEFT;
    HipTextAlign alignv = HipTextAlign.TOP;

    IHipFont font;

    int x, y;
    ///Update dynamically based on the font, the text scale and the text length
    int width, height;

    //Line widths, containing width for each line for correctly aplying text align
    uint[] linesWidths;

    protected dstring _text;
    protected dstring processedText;

    //Debugging?

    protected bool shouldRenderSpace = false;
    protected bool shouldRenderLineBreak = false;

    protected HipTextStopConfig[] textConfig;
    protected float[] vertices;

    //Caching
    protected size_t lastTextLength = 0;
    protected bool shouldUpdateText = true;

    this()
    {
        linesWidths.length = 1;
    }
    dstring text(){return _text;}

    dstring text(dstring newText)
    {
        if(newText != _text)
        {
            shouldUpdateText = true;
            if(newText.length > _text.length)
            {
                //As it is a quad, it needs to have floats * 4
                vertices.length = newText.length * (HipTextRendererVertex.sizeof/float.sizeof) * 4;
            }
            _text = newText;
        }
        return _text;
    }

    float[] getVertices()
    {
        if(shouldUpdateText)
            updateText(font);
        return vertices;
    }
    
    protected void updateAlign(int lineNumber, out int displayX, out int displayY)
    {
        getAlign(x, y, linesWidths[lineNumber], height, alignh, alignv, displayX, displayY);
    }
    public void setFont(IHipFont font){this.font = font;}

    package void updateText(IHipFont font)
    {
        HipTextStopConfig.parseText(_text, processedText, textConfig);
        font.calculateTextBounds(processedText, linesWidths, width, height);
        int displayX, displayY;
        int yoffset = 0;
        int xoffset = 0;
        dstring str = processedText;
        //4 floats(vec2 pos, vec2 texst) and 4 vertices per character
        alias v = vertices;
        int vI = 0; //vertex buffer index

        dchar lastCharacter = 0;
        int kerningAmount = 0;
        int lineBreakCount = 0;
        updateAlign(0, displayX, displayY);
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
                    updateAlign(++lineBreakCount, displayX, displayY);
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
            lastCharacter = str[i];
        }
        shouldUpdateText = false;
    }
}


/**
*   The text stop config defines how this text will behave a
*/
package struct HipTextStopConfig
{
    import hip.hipengine.api.graphics.color;
    int startIndex;
    HipColor color;

    //This is just a plan, not supported right now
    public static enum Tokens
    {
        alignh = "alignh",
        alignv = "alignv",
        rgb = "rgb",
        color = "color",
        bold = "bold",
        italic = "italic",
        red = "red",
        green = "green",
        blue = "blue",
    }

    private static HipTextStopConfig parseToken(in dstring text, size_t indexToParse, out size_t continueIndex)
    {
        import hip.util.conv;
        import hip.util.string;
        import hip.util.algorithm;
        import hip.error.handler;
        int endIndex = text[indexToParse..$].indexOf(")"); //Won't support parenthesis between them.
        ErrorHandler.assertErrorMessage(endIndex != -1, "Invalid HipTextStopConfig formatting", "Missing ending parenthesis on string ");
        continueIndex = endIndex+indexToParse;


        auto range = splitRange(text[indexToParse..endIndex], ",");
        dstring token = range.front;
        range.popFront();

        switch(token)
        {
            case "rgb":
            {
                HipColor c = HipColor(0, 0, 0, 1.0);
                range.map!((x) => x.trim.to!float).put(&c.r, &c.g, &c.b);
                return HipTextStopConfig(cast(int)indexToParse, c);
            }
            default: break;
        }
        return HipTextStopConfig(cast(int)indexToParse, HipColor.white);
    }


    static void parseText(in dstring text, out dstring parsedText, ref HipTextStopConfig[] config)
    {
        size_t indexConfig = 0;
        size_t lastParseIndex = 0;
        dstring parsingText;
        for(size_t i = 0; i < text.length; i++)
        {
            if(i+1 < text.length && text[i] == '$' && text[i+1] == '(') //Found something to parse
            {
                parsingText~= text[lastParseIndex..i-1];
                HipTextStopConfig cfg = parseToken(text, i+1, i); //Update i
                lastParseIndex = i;
                if(indexConfig >= config.length)
                    config.length++;
                config[indexConfig++] = cfg;
            }
        }
        parsedText = parsingText ~ text[lastParseIndex..$];
    }

}



void getAlign(
    int x, int y, int width, int height, HipTextAlign alignh, HipTextAlign alignv, 
    out int newX, out int newY
)
{
    newX = x;
    newY = y;
    with(HipTextAlign)
    {
        switch(alignh)
        {
            case CENTER:
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
                newY+= height/2;
                break;
            case BOTTOM:
                newY+= height;
                break;
            case TOP:
            default:
                break;
        }
    }
}
    