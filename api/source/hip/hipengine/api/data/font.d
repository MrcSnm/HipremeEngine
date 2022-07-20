module hip.hipengine.api.data.font;
import hip.hipengine.api.renderer.texture;

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

abstract class HipFont
{
    ITexture texture;
    HipFontChar[dchar] characters;
    ///Saves the space width for the bitmap text process the ' '. If the original spaceWidth is == 0, it won't draw a quad
    uint spaceWidth;
    ///How much the line break will offset in Y the next char
    uint lineBreakHeight;

    int getKerning(dchar current, dchar next);

    final void calculateTextBounds(in dstring text, ref uint[] linesWidths, out int maxWidth, out int height)
    {
        int w, h;
        int lastMaxW = 0;
        int lineIndex = 0;

        for(int i = 0; i < text.length; i++)
        {
            HipFontChar* ch = text[i] in characters;
            if(ch is null)
                continue;
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
                    w+= ch.xadvance;
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
