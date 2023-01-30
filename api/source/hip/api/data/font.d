module hip.api.data.font;
public import hip.api.renderer.texture;


alias HipCharKerning = int[dchar];
alias HipFontKerning = HipCharKerning[dchar];


struct HipFontChar
{
    ///Not meant to support more than ushort right now
    uint id;
    ///Those are in absolute values
    int x, y, width, height;

    int xoffset, yoffset, xadvance, page, chnl; 


    ///Normalized values
    float normalizedX, normalizedY, normalizedWidth, normalizedHeight;
}

interface IHipFont
{
    int getKerning(dchar current, dchar next) const;
    void calculateTextBounds(in dstring text, ref uint[] linesWidths, out int maxWidth, out int height) const;
    ref HipFontChar[dchar] characters();
    ref IHipTexture texture();
    uint spaceWidth() const;
    uint spaceWidth(uint newWidth);
    uint lineBreakHeight() const;
    uint lineBreakHeight(uint newHeight);
    IHipFont getFontWithSize(uint size);
}

abstract class HipFont : IHipFont
{
    
    abstract int getKerning(dchar current, dchar next) const;

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
    final ref IHipTexture texture(){return _texture;}
    final uint spaceWidth() const {return _spaceWidth;}
    final uint spaceWidth(uint newWidth){return _spaceWidth = newWidth;}
    final uint lineBreakHeight() const {return _lineBreakHeight;}
    final uint lineBreakHeight(uint newHeight){return _lineBreakHeight = newHeight;}


    final void calculateTextBounds(in dstring text, ref uint[] linesWidths, out int maxWidth, out int height) const
    {
        int w = 0, h = lineBreakHeight;
        int lastMaxW = 0;
        int lineIndex = 0;
        linesWidths[] = 0;

        for(int i = 0; i < text.length; i++)
        {
            const HipFontChar* ch = text[i] in characters;
            if(ch is null)
                continue;
            int kern = 0;
            if(i+1 < text.length)
            {
                kern = getKerning(text[i], text[i+1]);
                if(kern != 0)
                {
                    import std.stdio;
                    writeln("Kerning Found:", kern);
                }
            }
            switch(text[i])
            {
                case '\n':
                    h+= ch && ch.height != 0 ? ch.height : lineBreakHeight;
                    lastMaxW = w > lastMaxW ? w : lastMaxW;
                    if(lineIndex + 1 > linesWidths.length)
                        linesWidths.length = lineIndex + 1;
                    linesWidths[lineIndex++] = w;
                    w = 0;
                    break;
                case ' ':
                    w+= ch && ch.width != 0 ? ch.width : spaceWidth;
                    break;
                default:
                    w+= ch.xadvance + kern;

                    break;
            }
        }
        maxWidth = w > lastMaxW ? w : lastMaxW;
        if(lineIndex >= linesWidths.length)
            linesWidths.length++;
        linesWidths[lineIndex] = w;
        height = h;
    }
}
