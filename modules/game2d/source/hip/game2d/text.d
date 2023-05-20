module hip.game2d.text;

import hip.api.data.font;
import hip.api.graphics.text;
import hip.math.vector;
import hip.game2d.renderer_data;
import std.encoding;


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
    float depth = 0;
    ///Update dynamically based on the font, the text scale and the text content
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
    protected HipTextRendererVertex[] vertices;

    //Caching
    protected size_t _drawableTextCount = 0;
    protected size_t maxDrawableTextCount = 0;
    protected bool shouldUpdateText = true;

    this(int boundsWidth = -1, int boundsHeight = -1)
    {
        import hip.api;
        this.font = cast()HipDefaultAssets.getDefaultFont();
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
            import hip.util.string;
            import hip.api;
            dstring dtext = newText.toUTF32;
            _drawableTextCount = countVertices(dtext);
            shouldUpdateText = true;
            if(_drawableTextCount > maxDrawableTextCount)
            {
                //As it is a quad, it needs to have vertices * 4
                vertices.length = _drawableTextCount * 4;
                maxDrawableTextCount = _drawableTextCount;
            }
            _text = newText;
            _dtext = dtext;
        }
        return _text;
    }

    void[] getVertices()
    {
        if(shouldUpdateText)
            updateText(font);
        
        return cast(void[])vertices[0..drawableTextCount * 4];
    }
    
    protected void updateAlign(int lineNumber, out int displayX, out int displayY, int boundsWidth, int boundsHeight)
    {
        import hip.api.graphics.text;
        getPositionFromAlignment(x, y, linesWidths[lineNumber], height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
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

        int kerningAmount = 0;
        int lineBreakCount = 0;
        int displayX = void, displayY = void;
        updateAlign(0, displayX, displayY, boundsWidth, boundsHeight);
        HipFontChar* lastCharacter;
        HipFontChar* ch;
        for(int i = 0; i < str.length; i++)
        {
            ch = str[i] in font.characters;
            if(ch is null)
            {
                import hip.api;
                logg("Unrecognized: ", str[i]);
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
                            depth
                        ),
                        Vector2(ch.normalizedX, ch.normalizedY) //ST
                    );
                    //Top Right
                    v[vI++] = HipTextRendererVertex(
                        Vector3(
                            xoffset+displayX+ch.width,
                            yoffset+displayY,
                            depth
                        ),
                        Vector2(ch.normalizedX + ch.normalizedWidth, ch.normalizedY) //S + Wnorm, T
                    );
                    //Bot right
                    v[vI++] = HipTextRendererVertex(
                        Vector3(
                            xoffset+displayX+ch.width, //X+W
                            yoffset+displayY + ch.height,//Y+H
                            depth
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
                            depth
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
        shouldUpdateText = false;
    }

    void draw()
    {
        import hip.api.graphics.g2d.g2d_binding;
        import hip.api;
        drawTextVertices(getVertices, font);
    }
}


/**
*   The text stop config defines how this text will behave a
*/
package struct HipTextStopConfig
{
    import hip.api.graphics.color;
    int startIndex;
    HipColorf color;

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
        int endIndex = text[indexToParse..$].indexOf(")"); //Won't support parenthesis between them.
        assert(endIndex != -1, "Missing ending parenthesis on string at HipTextStopConfig formatting ");
        continueIndex = endIndex+indexToParse;


        auto range = splitRange(text[indexToParse..endIndex], ",");
        dstring token = range.front;
        range.popFront();

        switch(token)
        {
            case "rgb":
            {
                HipColorf c = HipColorf(0, 0, 0, 1.0);
                range.map!((x) => x.trim.to!float).put(&c.r, &c.g, &c.b);
                return HipTextStopConfig(cast(int)indexToParse, c);
            }
            default: break;
        }
        return HipTextStopConfig(cast(int)indexToParse, cast()HipColorf.white);
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
        //!FIXME: This allocated on each frame. It should both be used a @nogc operation (String) or it should 
        //!find a way to create a range to be used instead of a string.
        if(lastParseIndex == 0)
        {
            parsedText = text;
            return;
        }
        parsedText = parsingText ~ text[lastParseIndex..$];
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
