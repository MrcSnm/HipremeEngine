/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.font.hipfont;
import hip.filesystem.hipfs;


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
    HipFontChar[dchar] characters;
    ///Saves the space width for the bitmap text process the ' '. If the original spaceWidth is == 0, it won't draw a quad
    uint spaceWidth;
    ///How much the line break will offset in Y the next char
    uint lineBreakHeight;

    int getKerning(dchar current, dchar next);
}


private struct RenderizedChar
{
    dchar ch;
    int size;
    int width;
    int height;

    ubyte[] data;

    void blitToTexture(ref ubyte[] texture, int startX, int startY, int textureWidth, int textureHeight)
    {
        assert(startX + width < textureWidth, "Out of X boundaries");
        for(size_t i = 0; i < height; i++)
        {
            size_t pos = (startY+i)*textureWidth + startX;
            assert(startY + i < textureHeight, "Out of Y boundaries");
            texture[pos..pos+width] = data[i*width..(i+1)*width];
        }
    }



    void dispose()
    {
        if(data.ptr != null)
        {
            stbtt_FreeBitmap(data.ptr, null);
            data = null;
        }
    }
}
class Hip_TTF_Font : HipFont
{
    import arsd.ttf;
    protected float fontScale;
    protected TtfFont font;
    protected ubyte[] generatedTexture;
    public static immutable dstring defaultCharset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\\|'\"`/*-+,.;_=!@#$%&()[]{}~^?";

    this(string path)
    {
        ubyte[] output;
        if(HipFS.read(path, output))
        {
            font = TtfFont(output);
        }
    }
    override int getKerning(dchar current, dchar next){return stbtt_GetCodepointKernAdvance(&font.font, int(current), int(next));}

    
    protected RenderizedChar renderCharacter(dchar ch, int size, float shift_x = 0.0, float shift_y = 0.0)
    {
        RenderizedChar rch;
        rch.ch = ch;
        rch.data = font.renderCharacter(ch, size, rch.width, rch.height, shift_x, shift_y);
        return rch;
    }
    /**
    *   I'm no good packer. The image will be at least 2048xMinPowOf2
    */
    ubyte[] generateTexture(int size, dstring charset = defaultCharset, uint maxWidth = 800, uint maxHeight = 600)
    {
        import hip.util.memory;
        //First guarantee the big size
        ubyte[] texture = allocSlice!ubyte(maxWidth*maxHeight);

        scope RenderizedChar[] fontChars;

        scope(exit)
        {
            foreach(ch; fontChars)
                ch.dispose();
        }

        foreach(dc; charset)
        {
            fontChars~= renderCharacter(dc, size);
        }
        import std.algorithm:sort;
        enum hSpacing = 1;
        enum vSpacing = 1;
        float x = 1;
        float y = 0;
        int largestHeightInRow = 0;
        foreach(fontCh; sort!"a.height > b.height"(fontChars))
        {
            if(x + fontCh.width + hSpacing > maxWidth)
            {
                x = hSpacing;
                y+= largestHeightInRow + vSpacing;
                largestHeightInRow = 0;
            }
            fontCh.blitToTexture(texture, cast(int)(x), cast(int)(y), maxWidth, maxHeight);
            x+= fontCh.width + hSpacing;

            if(fontCh.height > largestHeightInRow)
                largestHeightInRow = fontCh.height;

        }
        return texture;
    }


    void dispose(ubyte[] texture)
    {
        import core.stdc.stdlib;
        free(texture.ptr);
        texture = null;
    }


}
