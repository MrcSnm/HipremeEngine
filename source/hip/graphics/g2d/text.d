module hip.graphics.g2d.text;

import hip.graphics.g2d.textrenderer;
import hip.api.data.font;

version(WebAssembly) version = UseDRuntimeDecoder;
version(PSVita) version = UseDRuntimeDecoder;



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

    int boundsWidth = -1, boundsHeight = -1;

    //Line widths, containing width for each line for correctly aplying text align
    uint[] linesWidths;

    protected string _text;
    protected dstring _dtext;
    protected dstring processedText;

    //Debugging?

    protected bool shouldRenderSpace = false;
    protected bool shouldRenderLineBreak = false;

    protected HipTextStopConfig[] textConfig;
    protected float[] vertices;

    //Caching
    protected size_t _drawableTextCount = 0;
    protected size_t maxDrawableTextCount = 0;
    protected bool shouldUpdateText = true;

    this(int boundsWidth = -1, int boundsHeight = -1)
    {
        linesWidths.length = 1;
        this.boundsWidth = boundsWidth;
        this.boundsHeight = boundsHeight;
    }
    string text(){return _text;}

    size_t drawableTextCount(){return _drawableTextCount;}

    
    string text(string newText)
    {
        if(newText != _text)
        {
            version(UseDRuntimeDecoder)
            {
                dstring dtext;
                foreach(dchar ch; newText) dtext~= ch;
            }
            else
            {
                import std.utf:toUTF32;
                dstring dtext = newText.toUTF32;
            }
            _drawableTextCount = countVertices(dtext);
            shouldUpdateText = true;
            if(_drawableTextCount > maxDrawableTextCount)
            {
                //As it is a quad, it needs to have floats * 4
                vertices.length = _drawableTextCount * (HipTextRendererVertex.sizeof/float.sizeof) * 4;
                maxDrawableTextCount = _drawableTextCount;
                vertices[] = 0;
            }
            _text = newText;
            _dtext = dtext;
        }
        return _text;
    }

    float[] getVertices()
    {
        if(shouldUpdateText)
            updateText(font);
        
        return vertices[0..drawableTextCount * (HipTextRendererVertex.sizeof/float.sizeof) * 4];
    }
    
    protected void updateAlign(int lineNumber, out int displayX, out int displayY, int boundsWidth, int boundsHeight)
    {
         
        getAlign(x, y, linesWidths[lineNumber], height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
    }
    public void setFont(IHipFont font)
    {
        this.font = font;
        this.updateText(font);
    }

    package void updateText(IHipFont font)
    {
        HipTextStopConfig.parseText(_dtext, processedText, textConfig);
        font.calculateTextBounds(processedText, linesWidths, width, height);
        int yoffset = 0;
        int xoffset = 0;
        dstring str = processedText;
        //4 floats(vec2 pos, vec2 texst) and 4 vertices per character
        alias v = vertices;
        int vI = 0; //vertex buffer index

        dchar lastCharacter = 0;
        int kerningAmount = 0;
        int lineBreakCount = 0;
        int displayX = void, displayY = void;
        updateAlign(0, displayX, displayY, boundsWidth, boundsHeight);
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
                    updateAlign(++lineBreakCount, displayX, displayY, boundsWidth, boundsHeight);
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
    import hip.api.graphics.color;
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
        return HipTextStopConfig(cast(int)indexToParse, cast()HipColor.white);
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
                    newX = ((x + boundsWidth)/2) - (width / 2);
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
                    newY = newY + (boundsHeight/2) + height/2;
                else
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
    

private size_t countVertices(dstring str)
{
    size_t i = 0;
    foreach(ch; str)
    {
        if(ch != ' ' && ch != '\n')
            i++;
    }
    return i;
}
