module hip.api.data.font;
import hip.api.data.asset;
public import hip.api.renderer.texture;
public import hip.api.renderer.shaders.spritebatch: HipSpriteVertex, HipSpriteVertexInstancedPerInstance;


alias HipCharKerning = int[dchar];
alias HipFontKerning = HipCharKerning[dchar];

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
    float height;
    float width;
    float minYOffset;
    const(HipFontChar)*[512] fontCharCache = void;
    float[512] kerningCache = void;
}

pragma(LDC_no_typeinfo)
struct HipWordWrapRange
{
    private string inputText;
    private IHipFont font;
    private float maxWidth;
    int currIndex;
    private float scale = 1.0f;
    private HipLineInfo currLine = void;
    private bool hasFinished;

    void initialize(string inputText, IHipFont font, float maxWidth, float scale) @nogc
    {
        this.inputText = inputText;
        currLine.height = 0;
        currLine.width = 0;
        currLine.minYOffset = 0;
        this.scale = scale;
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
        float currWidth = 0, wordWidth = 0;
        int wordStartIndex = currIndex;
        float spaceWidth = font.spaceWidth * scale;

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
            float chHeight = ch.height * scale;
            float chXAdvance = ch.xadvance * scale;
            float chYOffset = ch.yoffset * scale;

            currLine.height = (chHeight > currLine.height ?  chHeight : currLine.height);
            currLine.minYOffset = chYOffset < currLine.minYOffset ? chYOffset : currLine.minYOffset;
            float kern = 0;
            if(i + 1 < inputText.length)
            {
                next = inputText[i+1] in font.characters;
                if(next) kern = font.getKerning(ch, next);
            }
            currLine.kerningCache[it] = kern;
            kern *= scale;
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
                    if(wordWidth + chXAdvance + kern + currWidth > maxWidth)
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
                    wordWidth += chXAdvance + kern;
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
    short x, y, width, height;

    short xoffset, yoffset, xadvance, page, chnl;

    ///Normalized values
    ushort normalizedX, normalizedY, normalizedWidth, normalizedHeight;
    int glyphIndex;
    void putCharacterQuad(float x, float y, ushort depth, HipColor color, HipSpriteVertex[] quad, float scale = 1, ushort tex=0) const @nogc
    {
        import hip.math.vector;
        import hip.util.data_structures;
        short w = cast(short)(width*scale), h = cast(short)(height*scale);

        short ux = cast(short)x, uy = cast(short)y, z = cast(short)depth;
        //Gen vertices 
        quad[0..4] = [
            //Top left
            HipSpriteVertex(
                short2(ux, uy),
                color,
                ushort2(normalizedX, normalizedY), //ST,
                z,
                tex
            ),
            //Top Right
            HipSpriteVertex(
                short2(cast(short)(ux+w), uy),
                color,
                ushort2(cast(ushort)(normalizedX + normalizedWidth), normalizedY), 
                z, //S + Wnorm, T
                tex
            ),
            //Bot right
            HipSpriteVertex(
                short2(cast(short)(ux+w), cast(short)(uy +h)),
                color,
                ushort2(
                    cast(short)(normalizedX + normalizedWidth), //S+Wnorm
                    cast(ushort)(normalizedY + normalizedHeight) //T+Hnorm
                ), z, tex
            ),
            //Bot left
            HipSpriteVertex(
                short2(ux, cast(short)(uy + h)),
                color,
                ushort2(normalizedX, cast(ushort)(normalizedY + normalizedHeight)), z, // S, T+Hnorm
                tex
            )
        ].staticArray;
    }
    void putCharacterInstance(float x, float y, ushort depth, HipColor color, ref HipSpriteVertexInstancedPerInstance instance, float scale = 1, ushort tex=0) const @nogc
    {
        import hip.util.data_structures;
        short w = cast(short)(width*scale), h = cast(short)(height*scale);
        short ux = cast(short)x, uy = cast(short)y, z = cast(short)depth;
        instance = HipSpriteVertexInstancedPerInstance(
            [ux, uy],
            [w, h],
            color,
            0.0f, //Rotation
            depth,
            tex,
            [normalizedX, normalizedY],
            [normalizedWidth, normalizedHeight]
        );
    }
}

interface IHipFont
{
    int getKerning(const(HipFontChar)* current, const(HipFontChar)* next) const @nogc;
    int getKerning(dchar current, dchar next) const @nogc;
    uint getHeight() const @nogc;
    IHipTexture getTexture();
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
    HipWordWrapRange wordWrapRange(string text, int maxWidth, float scale = 1.0f) const @nogc;
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

    final IHipTexture getTexture() { return _texture; }

    ///////Properties///////
    final ref HipFontChar[dchar] characters(){return _characters;}
    final ref const(HipFontChar[dchar]) characters() const {return _characters;}
    final ref inout(IHipTexture) texture() inout {return _texture;}
    final uint spaceWidth() const {return _spaceWidth;}
    final uint spaceWidth(uint newWidth){return _spaceWidth = newWidth;}
    final uint lineBreakHeight() const {return _lineBreakHeight;}
    final uint lineBreakHeight(uint newHeight){return _lineBreakHeight = newHeight;}


    abstract uint getHeight() const;

    final HipWordWrapRange wordWrapRange(string text, int maxWidth, float scale = 1.0f) const @nogc
    {
        ///Needs to be returned like that or else, it will memset everytime
        HipWordWrapRange ret = void;
        ret.initialize(text, cast(IHipFont)this, maxWidth, scale);
        return ret;
    }
    

    final void calculateTextBounds(string text, float scale, ref float[] linesWidths, out float biggestWidth, out float height, int maxWidth = -1) const
    {
        int i = 0;
        foreach(HipLineInfo lineInfo; wordWrapRange(text, maxWidth, scale))
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