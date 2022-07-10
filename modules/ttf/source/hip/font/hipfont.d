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
import arsd.ttf;


version(none):

class TTFFont
{
    protected TtfFont font;

    public static immutable dstring defaultCharset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\\|'\"`/*-+,.;_=!@#$%&()[]{}~^?";

    protected ubyte[] generatedTexture;

    struct RenderizedChar
    {
        dchar ch;
        int size;
        int width;
        int height;

        ubyte[] data;

        void blitToTexture(ref ubyte[] texture, int startX, int startY, int textureWidth, int textureHeight)
        {
            for(size_t i = 0; i < height; i++)
            {
                size_t pos = (startY+i)*textureWidth + startX;
                assert(pos < textureWidth*textureHeight, "Out of boundaries while trying to blit to texture");
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

    this(string path)
    {
        ubyte[] output;
        if(HipFS.read(path, output))
        {
            font = TtfFont(output);
        }
    }

    RenderizedChar renderCharacter(dchar ch, int size, float shift_x = 0.0, float shift_y = 0.0)
    {
        RenderizedChar rch;
        rch.data = font.renderCharacter(ch, size, rch.width, rch.height, shift_x, shift_y);
        return rch;
    }

    /**
    *   I'm no good packer. The image will be at least 2048xMinPowOf2
    */
    ubyte[] generateTexture(int size, dstring charset = defaultCharset, uint maxWidth = 2048, uint maxHeight = 2048)
    {
        import hip.util.memory;
        //First guarantee the big size
        ubyte[] texture = allocSlice!ubyte(maxWidth*maxHeight);

        uint width = maxWidth;
        uint height = maxHeight;

        int ascent, descent, line_gap;
        stbtt_GetFontVMetrics(&font.font, &ascent, &descent, &line_gap);

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
        auto scale = stbtt_ScaleForPixelHeight(&font.font, size);
        int x = 2;
        int y = 0;
        int largestHeightInRow = 0;
        foreach(fontCh; sort!"a.height < b.height"(fontChars))
        {

            // stbtt_GetCodepointBitmapBoxSubpixel(&font.font, fontCh.ch, scale, scale, )

            fontCh.blitToTexture(texture, x, y, maxWidth, maxHeight);
            if(x + fontCh.width + fontCh.advance > maxWidth)
            {
                x = 0;
                y+= largestHeightInRow;
                largestHeightInRow = 0;
            }
            else
            {
                // x+= scale * stbtt_GetCodepointKernAdvance(&font.font, )
            }

            if(fontCh.height > largestHeightInRow)
                largestHeightInRow = fontCh.height;

        }

        //Clamp here if needed

        return texture;
    }


    void dispose(ubyte[] texture)
    {
        import core.stdc.stdlib;
        free(texture.ptr);
        texture = null;
    }
}