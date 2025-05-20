module hip.api.data.font;
import hip.api.data.asset;
public import hip.api.renderer.texture;


alias HipCharKerning = int[dchar];
alias HipFontKerning = HipCharKerning[dchar];
///see hip.graphics.g2d.textrenderer
struct HipTextRendererVertexAPI
{
    float[3] vPosition = [0,0,0];
    float[2] vTexST = [0,0];
}

/** 
 *  A text information that is returned from the word wrap range.
 *  Beyond the information with line and width, it also has a cache.
 *  This cache is used for optimization in both kerning and associative array
 *  lookup. This can make a big difference by having a single lookup instead of
 *  2. The lookup is the slowest part of text rendering, which makes this a lot faster.
 */
pragma(LDC_no_typeinfo)
struct HipLineInfo
{
    string line;
    int height;
    int width;
    int minYOffset;
    const(HipFontChar)*[512] fontCharCache = void;
    int[512] kerningCache = void;
}

pragma(LDC_no_typeinfo)
struct HipWordWrapRange
{
    private string inputText;
    private IHipFont font;
    private int maxWidth, currIndex;
    private HipLineInfo currLine = void;
    private bool hasFinished;

    void initialize(string inputText, IHipFont font, int maxWidth) @nogc
    {
        this.inputText = inputText;
        currLine.height = 0;
        currLine.width = 0;
        currLine.minYOffset = 0;
        this.font = font;
        this.maxWidth = maxWidth <= 0 ? int.max : maxWidth;
        currIndex = 0;
        hasFinished = false;
    }

    bool empty() @nogc {return hasFinished;}
    /** 
     * Every time it pops the front, it will search for words. Words are defined as text delimited
     * by spaces. If a word is bigger than the max width, it will be cutten and the word will spam
     * through multiple lines. 
     */
    void popFront() @nogc
    {
        const(HipFontChar)* ch, next;
        int currWidth = 0, wordWidth = 0, wordStartIndex = currIndex;
        uint spaceWidth = font.spaceWidth;

        for(int i = currIndex, it = 0; i < inputText.length; i++, it++)
        {
            if(ch is null)
            {
                ch = inputText[i] in font.characters;
                if(ch is null)
                {
                    currLine.kerningCache[it] = 0;
                    currLine.fontCharCache[it] = null;
                    continue;
                }
            }
            currLine.height = ch.height > currLine.height ?  ch.height : currLine.height;
            currLine.minYOffset = ch.yoffset < currLine.minYOffset ? ch.yoffset : currLine.minYOffset;
            int kern = 0;
            if(i + 1 < inputText.length)
            {
                next = inputText[i+1] in font.characters;
                if(next) kern = font.getKerning(ch, next);
            }
            currLine.kerningCache[it] = kern;
            currLine.fontCharCache[it] = ch;
            switch(inputText[i])
            {
                case '\n':
                    currLine.line = inputText[currIndex..i];
                    currLine.width = currWidth + wordWidth;
                    wordWidth = 0;
                    wordStartIndex = i+1;
                    currIndex = i+1;
                    return;
                case ' ':
                    if(spaceWidth + wordWidth + currWidth > maxWidth)
                    {
                        currLine.line = inputText[currIndex..i];
                        currLine.width = currWidth+wordWidth;
                        currIndex = i+1;
                        return;
                    }
                    else
                    {
                        currWidth+= wordWidth + spaceWidth;
                        wordStartIndex = i;
                        wordWidth = 0;
                    }
                    break;
                default:
                    if(wordWidth + ch.xadvance + kern + currWidth > maxWidth)
                    {
                        if(wordStartIndex == currIndex)
                        {
                            currWidth = wordWidth;
                            wordStartIndex = i;
                        }
                        ///Subtract one for ignoring the space.
                        currLine.line = inputText[currIndex..wordStartIndex];
                        currLine.width = currWidth;
                        if(wordStartIndex < inputText.length && inputText[wordStartIndex] == ' ')
                            wordStartIndex++;
                        currIndex = wordStartIndex;
                        return;
                    }
                    wordWidth += ch.xadvance + kern;
                    break;
            }
            ch = next;
        }
        if(currIndex < inputText.length && inputText[currIndex] == ' ')
            currIndex++;
        currLine.line = inputText[currIndex..$];
        currLine.width = currWidth+wordWidth;
        currIndex = cast(int)inputText.length;
        if(currLine.line.length == 0) hasFinished = true;
    }

    HipLineInfo front() @nogc
    {
        if(currIndex == 0) popFront();
        return currLine;
    }
}

struct HipFontChar
{
    uint id;
    ///Those are in absolute values
    int x, y, width, height;

    int xoffset, yoffset, xadvance, page, chnl;

    ///Normalized values
    float normalizedX, normalizedY, normalizedWidth, normalizedHeight;
    int glyphIndex;
    void putCharacterQuad(float x, float y, float depth, HipTextRendererVertexAPI[] quad, float scale = 1) const @nogc
    {
        import hip.util.data_structures;
        float w = width*scale, h = height*scale;
        //Gen vertices 
        quad[0..4] = [
            //Top left
            HipTextRendererVertexAPI(
                [x, y, depth],
                [normalizedX, normalizedY] //ST
            ),
            //Top Right
            HipTextRendererVertexAPI(
                [x+w, y,depth],
                [normalizedX + normalizedWidth, normalizedY] //S + Wnorm, T
            ),
            //Bot right
            HipTextRendererVertexAPI(
                [x+ w, y +h, depth],
                [
                    normalizedX + normalizedWidth, //S+Wnorm
                    normalizedY + normalizedHeight //T+Hnorm
                ]
            ),
            //Bot left
            HipTextRendererVertexAPI(
                [x, y + h, depth],
                [normalizedX, normalizedY + normalizedHeight] // S, T+Hnorm
            )
        ].staticArray;

    }
}

interface IHipFont
{
    int getKerning(const(HipFontChar)* current, const(HipFontChar)* next) const @nogc;
    int getKerning(dchar current, dchar next) const @nogc;
    uint getHeight() const @nogc;
    /** 
     * 
     * Params:
     *   text = The text
     *   linesWidths = Save width per line
     *   biggestWidth = The biggest width in lines
     *   height = Height of all the lines together
     *   maxWidth = If maxWidth != -1, it will break the text into lines automatically. 
     */
    void calculateTextBounds(in string text, ref uint[] linesWidths, out int biggestWidth, out int height, int maxWidth = -1) const;
    /**
     *
     * Params:
     *   text = Input text
     * Returns: 0 if there is no line break is being done
     */
    final uint getTextHeight(in string text)
    {
        import hip.util.string;
        return count(text, "\n") * lineBreakHeight;
    }
    HipWordWrapRange wordWrapRange(string text, int maxWidth) const @nogc;
    ref HipFontChar[dchar] characters() @nogc;
    ref inout(IHipTexture) texture() inout @nogc;
    uint spaceWidth() const @nogc;
    uint spaceWidth(uint newWidth) @nogc;

    ///Used for reference as height for text
    uint lineBreakHeight() const @nogc;
    uint lineBreakHeight(uint newHeight) @nogc;

}

abstract class HipFont : HipAsset, IHipFont
{
    
    abstract int getKerning(dchar current, dchar next) const;
    abstract int getKerning(const(HipFontChar)* current, const(HipFontChar)* next) const;

    this()
    {
        super("Font");
    }

    ///Underlying GPU texture
    IHipTexture _texture;
    HipFontChar[dchar] _characters;
    ///Saves the space width for the bitmap text process the ' '. If the original spaceWidth is == 0, it won't draw a quad
    uint _spaceWidth;
    ///How much the line break will offset in Y the next char
    uint _lineBreakHeight;

    ///////Properties///////
    final ref HipFontChar[dchar] characters(){return _characters;}
    final ref const(HipFontChar[dchar]) characters() const {return _characters;}
    final ref inout(IHipTexture) texture() inout {return _texture;}
    final uint spaceWidth() const {return _spaceWidth;}
    final uint spaceWidth(uint newWidth){return _spaceWidth = newWidth;}
    final uint lineBreakHeight() const {return _lineBreakHeight;}
    final uint lineBreakHeight(uint newHeight){return _lineBreakHeight = newHeight;}


    abstract uint getHeight() const;

    final HipWordWrapRange wordWrapRange(string text, int maxWidth) const @nogc
    {
        ///Needs to be returned like that or else, it will memset everytime
        HipWordWrapRange ret = void;
        ret.initialize(text, cast(IHipFont)this, maxWidth);
        return ret;
    }
    

    final void calculateTextBounds(string text, ref uint[] linesWidths, out int biggestWidth, out int height, int maxWidth = -1) const
    {
        int i = 0;
        foreach(HipLineInfo lineInfo; wordWrapRange(text, maxWidth))
        {
            if(lineInfo.width > biggestWidth) biggestWidth = lineInfo.width;
            if(linesWidths.length < i+1)
                linesWidths.length++;
            linesWidths[i++] = lineInfo.width;
        }
        height = lineBreakHeight*i;
    }
    HipFont getFontWithSize(uint size);

    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return _texture !is null;}

}
