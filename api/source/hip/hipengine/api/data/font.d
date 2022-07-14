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
}
