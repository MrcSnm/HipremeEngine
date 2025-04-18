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
    HipTextAlign align_ = HipTextAlign.topLeft;
    HipFont font;
    int x, y;
    bool wordWrap;
    float scale = 1;

    DirtyFlagsCmp!(
        shouldUpdateText, x, y, 
        wordWrap, font,
        align_,
    ) checkDirty;


    float depth = 0;
    ///Update dynamically based on the font, the text scale and the text content
    int width, height;

    Size bounds;

    //Line widths, containing width for each line for correctly aplying text align
    uint[] linesWidths;

    protected string _text;
    protected string processedText;
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

    this(Size bounds = Size.init, bool bWordWrap = false)
    {
        import hip.api;
        checkDirty.start(this);
        this.font = cast()HipDefaultAssets.getDefaultFont();
        linesWidths.length = 1;
        wordWrap = bWordWrap;
        this.bounds = bounds;
    }
    this(string text, int x, int y, HipFont fnt = null, Size bounds = Size.init, bool bWordWrap = false)
    {
        this(bounds, bWordWrap);
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
            _drawableTextCount = countVertices(newText);
            shouldUpdateText = true;
            if(_drawableTextCount > maxDrawableTextCount)
            {
                //As it is a quad, it needs to have vertices * 4
                vertices.length = _drawableTextCount * 4;
                maxDrawableTextCount = _drawableTextCount;
            }
            _text = newText;
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
    
    protected void updateAlign(int lineNumber, out int displayX, out int displayY, Size bounds)
    {
        import hip.api.graphics.text;
        getPositionFromAlignment(x, y, linesWidths[lineNumber], height, align_, displayX, displayY, bounds);
    }
    

    public void getSize(out int width, out int height)
    {
        if(processedText == null)
            HipTextStopConfig.parseText(_text, processedText, textConfig);
        font.calculateTextBounds(processedText, linesWidths, width, height, bounds.width);
        this.width = width;
        this.height = height;
    }
    public void setAlign(HipTextAlign align_)
    {
        this.align_ = align_;
    }

    package void updateText(IHipFont font)
    {
        import hip.api.graphics.text;
        HipTextStopConfig.parseText(_text, processedText, textConfig);
        int vI = 0; //vertex buffer index

        vI = putTextVertices(font, vertices[vI..$], processedText, x, y, depth, scale, align_, bounds, wordWrap, shouldRenderSpace);
        shouldUpdateText = true;
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

    private static HipTextStopConfig parseToken(in string text, size_t indexToParse, out size_t continueIndex)
    {
        import hip.util.conv;
        import hip.util.string;
        import hip.util.algorithm;
        int endIndex = text[indexToParse..$].indexOf(")"); //Won't support parenthesis between them.
        assert(endIndex != -1, "Missing ending parenthesis on string at HipTextStopConfig formatting ");
        continueIndex = endIndex+indexToParse;


        auto range = splitRange(text[indexToParse..endIndex], ",");
        string token = range.front;
        range.popFront();

        switch(token)
        {
            case "rgb":
            {
                HipColorf c = HipColorf(0, 0, 0, 1.0);
                range.map((string x) => x.trim.to!float).put(&c.r, &c.g, &c.b);
                return HipTextStopConfig(cast(int)indexToParse, c);
            }
            default: break;
        }
        return HipTextStopConfig(cast(int)indexToParse, cast()HipColorf.white);
    }


    static void parseText(string text, out string parsedText, ref HipTextStopConfig[] config)
    {
        parsedText = text;
        // size_t indexConfig = 0;
        // size_t lastParseIndex = 0;
        // string parsingText;
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



private size_t countVertices(string str)
{
    size_t i = 0;
    foreach(ch; str)
    {
        if(ch != ' ' && ch != '\n')
            i++;
    }
    return i;
}
