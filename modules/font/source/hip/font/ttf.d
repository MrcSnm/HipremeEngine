/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.font.ttf;
import hip.hipengine.api.data.font;

class Hip_TTF_Font : HipFont
{
    import arsd.ttf;
    protected float fontScale;
    protected TtfFont font;
    string path;
    protected ubyte[] generatedTexture;
    public static immutable dstring defaultCharset = " \náéíóúãñçabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\\|'\"`/*-+,.;_=!@#$%&()[]{}~^?";

    this(string path)
    {
        this.path = path;
    }
    bool loadFromMemory(in ubyte[] data)
    {
        font = TtfFont(data);
        return true;
    }
    override int getKerning(dchar current, dchar next)
    {
        return cast(int)(fontScale*stbtt_GetCodepointKernAdvance(&font.font, int(current), int(next)));
    }

    
    protected RenderizedChar renderCharacter(dchar ch, int size, float shift_x = 0.0, float shift_y = 0.0)
    {
        RenderizedChar rch;
        rch.ch = ch;
        rch.data = font.renderCharacter(ch, size, rch.width, rch.height, shift_x, shift_y);
        return rch;
    }

    public void loadTexture()
    {
        assert(generatedTexture !is null, "Must first generate a texture before uploading to GPU");
        import hip.assets.image;
        import hip.assets.texture;
        Image img = new Image("Font");
        img.loadRaw(generatedTexture, 800, 600, 1);
        HipTexture t = new HipTexture();
        t.load(img);

        texture = t;

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
        float optY = 0;
        float scale = stbtt_ScaleForPixelHeight(&font.font, size);

        //Setting details
        fontScale = scale;
        
        int ascent, descent, lineGap;
        stbtt_GetFontVMetrics(&font.font, &ascent, &descent, &lineGap);
        if(lineGap > 0)
        {
            lineBreakHeight = cast(uint)(int(ascent - descent + lineGap));
        }


        int largestHeightInRow = 0;
        foreach(fontCh; sort!"a.height > b.height"(fontChars))
        {
            int g = stbtt_FindGlyphIndex(&font.font, fontCh.ch);
            int xAdvance, xOffset, yOffset, lsb;
            int x1, y1;
            stbtt_GetGlyphHMetrics(&font.font, g, &xAdvance, &lsb);
            stbtt_GetGlyphBitmapBox(&font.font, g, scale,scale, &xOffset,&yOffset,&x1,&y1);
            if(fontCh.ch == ' ')
            {
                int space_x0, space_x1;
                if(fontCh.width == 0)
                {
                    stbtt_GetCodepointBitmapBox(&font.font, int('n'), scale,scale, &space_x0, null, &space_x1, null);
                    spaceWidth = space_x1 - space_x0;
                }
                else
                    spaceWidth = fontCh.width;
            }

            if(x + fontCh.width + hSpacing > maxWidth)
            {
                x = hSpacing;
                y+= largestHeightInRow + vSpacing;
                largestHeightInRow = 0;
            }


            characters[fontCh.ch] = HipFontChar(fontCh.ch, cast(int)x, cast(int)y, fontCh.width, fontCh.height, 
                xOffset, yOffset, cast(int)(xAdvance*scale), 0, 0,
                cast(float)x/maxWidth, cast(float)y/maxHeight,
                cast(float)fontCh.width/maxWidth, cast(float)fontCh.height/maxHeight, 
            );
            fontCh.blitToTexture(texture, cast(int)(x), cast(int)(y), maxWidth, maxHeight);
            x+= fontCh.width + hSpacing;

            if(fontCh.height > largestHeightInRow)
                largestHeightInRow = fontCh.height;

        }
        generatedTexture = texture;
        return texture;
    }


    void dispose(ubyte[] texture)
    {
        import core.stdc.stdlib;
        free(texture.ptr);
        texture = null;
    }
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
            import arsd.ttf;
            stbtt_FreeBitmap(data.ptr, null);
            data = null;
        }
    }
}
