module hip.game2d.text;

import hip.api.data.font;
import hip.api.graphics.text;
import hip.util.data_structures;


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

    HipFont font;
    int x, y;
    bool wordWrap;

    DirtyFlagsCmp!(
        shouldUpdateText, x, y, 
        wordWrap, font,
        alignh, alignv
    ) checkDirty;


    float depth = 0;
    ///Update dynamically based on the font, the text scale and the text content
    int width, height;

    int boundsWidth = -1, boundsHeight = -1;

    //Line widths, containing width for each line for correctly aplying text align
    uint[] linesWidths;

    protected string _text;
    protected dstring _dtext;
    protected dstring processedText;
    protected HipColor _color = HipColor.black;

    //Debugging?

    protected bool shouldRenderSpace = false;
    protected bool shouldRenderLineBreak = false;

    protected HipTextStopConfig[] textConfig;
    protected HipTextRendererVertexAPI[] vertices;

    //Caching
    protected size_t _drawableTextCount = 0;
    protected size_t maxDrawableTextCount = 0;
    public bool shouldUpdateText = true;

    this(int boundsWidth = -1, int boundsHeight = -1, bool bWordWrap = false)
    {
        import hip.api;
        checkDirty.start(this);
        this.font = cast()HipDefaultAssets.getDefaultFont();
        linesWidths.length = 1;
        wordWrap = bWordWrap;
        this.boundsWidth = boundsWidth;
        this.boundsHeight = boundsHeight;
    }
    this(string text, int x, int y, HipFont fnt = null, int boundsWidth = -1, int boundsHeight = -1, bool bWordWrap = false)
    {
        this(boundsWidth, boundsHeight, bWordWrap);
        this.setPosition(x,y);
        this.text = text;
        if(fnt) font = fnt;
    }
    string text() const {return _text;}
    size_t drawableTextCount() const {return _drawableTextCount;}

    
    string text(string newText)
    {
        if(newText != _text)
        {
            import hip.util.string;
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

    void setPosition(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    HipColor color() => _color;
    HipColor color(HipColor c) => _color = c;

    void[] getVertices()
    {
        checkDirty();
        if(shouldUpdateText)
        {
            updateText(font);
            checkDirty.start(this);
        }
        
        return cast(void[])vertices[0..drawableTextCount * 4];
    }
    
    protected void updateAlign(int lineNumber, out int displayX, out int displayY, int boundsWidth, int boundsHeight)
    {
        import hip.api.graphics.text;
        getPositionFromAlignment(x, y, linesWidths[lineNumber], height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
    }
    

    public void getSize(out int width, out int height)
    {
        if(processedText == null)
            HipTextStopConfig.parseText(_dtext, processedText, textConfig);
        font.calculateTextBounds(processedText, linesWidths, width, height, boundsWidth);
        this.width = width;
        this.height = height;
    }
    public void setAlign(HipTextAlign alignh, HipTextAlign alignv)
    {
        this.alignh = alignh;
        this.alignv = alignv;
    }

    package void updateText(IHipFont font)
    {
        HipTextStopConfig.parseText(_dtext, processedText, textConfig);
        int vI = 0; //vertex buffer index

        bool isFirstLine = true;
        int yoffset = 0;
        foreach(HipLineInfo lineInfo; font.wordWrapRange(processedText, wordWrap ? boundsWidth : -1))
        {
            if(!isFirstLine)
            {
                yoffset+= font.lineBreakHeight;
            }
            isFirstLine = false;
            int xoffset = 0;
            int displayX = void, displayY = void;
            getPositionFromAlignment(x, y, lineInfo.width, height, alignh, alignv, displayX, displayY, boundsWidth, boundsHeight);
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
                            cast(float)(yoffset+displayY+ch.yoffset), depth,
                            vertices[vI..vI+4]
                        );
                        vI+= 4;
                        xoffset+= ch.xadvance;
                }
            }
        }
        shouldUpdateText = false;
    }

    void draw()
    {
        import hip.api.graphics.g2d.g2d_binding;
        setTextColor(color);
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
                range.map((dstring x) => x.trim.to!float).put(&c.r, &c.g, &c.b);
                return HipTextStopConfig(cast(int)indexToParse, c);
            }
            default: break;
        }
        return HipTextStopConfig(cast(int)indexToParse, cast()HipColorf.white);
    }


    static void parseText(in dstring text, out dstring parsedText, ref HipTextStopConfig[] config)
    {
        parsedText = text;
        // size_t indexConfig = 0;
        // size_t lastParseIndex = 0;
        // dstring parsingText;
        // for(size_t i = 0; i < text.length; i++)
        // {
        //     if(i+1 < text.length && text[i] == '$' && text[i+1] == '(') //Found something to parse
        //     {
        //         parsingText~= text[lastParseIndex..i-1];
        //         HipTextStopConfig cfg = parseToken(text, i+1, i); //Update i
        //         lastParseIndex = i;
        //         if(indexConfig >= config.length)
        //             config.length++;
        //         config[indexConfig++] = cfg;
        //     }
        // }
        // //!FIXME: This allocated on each frame. It should both be used a @nogc operation (String) or it should 
        // //!find a way to create a range to be used instead of a string.
        // if(lastParseIndex == 0)
        // {
        //     parsedText = text;
        //     return;
        // }
        // parsedText = parsingText ~ text[lastParseIndex..$];
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
