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
import hip.api.data.font;

immutable dstring defaultCharset = " \náéíóúãñçabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\\|'\"`/*-+,.;:´_=!@#$%&()[]{}~^?";

version = HipArsdFont;


private uint nextPowerOfTwo(uint number)
{
    ulong value = 1;
    while(value < number)
    {
        value <<= 1;
    }
    return cast(uint)value;
}

private int round(float f)
{
    return cast(int)(f+0.5);
}

class HipNullFont : HipFont
{
    string path;
    this(){}
    this(string path, uint fontSize = 32){}
    override uint getHeight() const { return 0; }

    /**
    *   This will cause a full load of the .ttf file, image generation and GPU upload. Should only be used
    *   If you don't care about async
    */
    bool loadFromMemory(in ubyte[] data){return false;}
    bool partialLoad(in ubyte[] data, out ubyte[] rawImage){return false;}
    bool loadTexture(ubyte[] rawImage){return false;}
    override int getKerning(dchar current, dchar next) const{return 0;}
    override int getKerning(const(HipFontChar)* current, const(HipFontChar)* next) const{return 0;}
    override HipFont getFontWithSize(uint size){return new HipNullFont();}
}


version(HipArsdFont)
/**
*   Check the unicode table: https://unicode-table.com/en/blocks/
*   There is a lot of character ranges that defines a set of characters in a language, such as:
*   0000—007F Basic Latin
*   0080—00FF Latin-1 Supplement
*   0100—017F Latin Extended-A
*   0180—024F Latin Extended-B
*   Maybe it will prove more useful than having a default charset
*/
class HipArsd_TTF_Font : HipFont
{
    import arsd.ttf;
    protected float fontScale;
    protected TtfFont font;
    string path;
    protected uint fontSize = 32;
    protected uint _textureWidth, _textureHeight;
    protected Hip_TTF_Font mainInstance;
    protected Hip_TTF_Font[] clones;

    this(string path, uint fontSize = 32)
    {
        this.path = path;
        this.fontSize = fontSize;
    }
    override uint getHeight() const { return fontSize; }
    /**
    *   This will cause a full load of the .ttf file, image generation and GPU upload. Should only be used
    *   If you don't care about async
    */
    bool loadFromMemory(in ubyte[] data)
    {
        if(data == null || data.length == 0)
            return false;
        try{font = TtfFont(data);}
        catch(Exception e){return false;}
        return loadTexture(
            generateImage(fontSize, _textureWidth, _textureHeight)
        );
    }

    bool partialLoad(in ubyte[] data, out ubyte[] rawImage)
    {
        font = TtfFont(data);
        rawImage = generateImage(fontSize, _textureWidth, _textureHeight);
        return true;
    }

    override int getKerning(const(HipFontChar)* current, const(HipFontChar)* next) const
    {
        return cast(int)(fontScale*stbtt_GetGlyphKernAdvance(cast(stbtt_fontinfo*)&font.font, current.glyphIndex, next.glyphIndex));
    }
    override int getKerning(dchar current, dchar next) const
    {
        return cast(int)(fontScale*stbtt_GetCodepointKernAdvance(cast(stbtt_fontinfo*)&font.font, int(current), int(next)));
    }


    bool loadTexture(ubyte[] rawImage)
    {
        assert(rawImage !is null, "Must first generate a texture before uploading to GPU");
        import hip.assets.image;
        import hip.assets.texture;
        import hip.error.handler;
        Image img = new Image();
        img.loadRaw(rawImage, _textureWidth, _textureHeight, 1);
        HipTexture t = new HipTexture(null);

        bool ret = t.load(img);
        ErrorHandler.assertErrorMessage(ret, "Loading TTF", "Could not create texture for TTF");
        texture = t;
        import core.memory;
        GC.free(rawImage.ptr);
        return ret;
    }

    /**
    * This function returns a new font using the same data file, with a new size.
    * The font data will reference to this same one
    */
    override HipFont getFontWithSize(uint size)
    {
        Hip_TTF_Font ret = new Hip_TTF_Font(this.path, size);
        ret.font = cast(TtfFont)this.font;
        ret.mainInstance = cast(Hip_TTF_Font)(mainInstance is null ? this : mainInstance);
        if(mainInstance)
            mainInstance.clones~= ret;
        else
            clones~= ret;

        if(!ret.loadTexture(ret.generateImage(size, ret._textureWidth, ret._textureHeight)))
            return null;

        return cast(HipFont)ret;
    }

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
    protected ubyte[] generateImage(int size, out uint width, out uint height, dstring charset = defaultCharset)
    {
        if(charset.length == 0)
            return null;
        scope RenderizedChar[] fontChars = new RenderizedChar[charset.length]; //TODO: USe that as it is more optimised
        scope(exit)
        {
            foreach(ch; fontChars)
                ch.dispose();
            import core.memory;
            GC.free(fontChars.ptr);
        }

        uint avgWidth = 0;
        uint avgHeight = 0;
        size_t i = 0;
        foreach(dc; charset)
        {
            RenderizedChar rc = renderCharacter(dc, size);
            avgWidth+= rc.width;
            avgHeight+= rc.height;
            fontChars[i++] = rc;
        }
        //Add as an error (pixel bleeding)
        avgWidth = cast(uint)(avgWidth / charset.length) + 2;
        avgHeight = cast(uint)(avgHeight / charset.length) + 2;
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


        lineBreakHeight = cast(uint)(int(ascent - descent + lineGap) * scale);

        //First guarantee the big size
        import core.math:sqrt;
        uint sqrtOfCharset = cast(uint)sqrt(cast(float)charset.length) + 1;
        uint imageWidth = avgWidth * sqrtOfCharset;
        uint imageHeight = avgHeight * sqrtOfCharset;
        imageHeight = nextPowerOfTwo(imageHeight);
        imageWidth = nextPowerOfTwo(imageWidth);

        width = imageWidth;
        height = imageHeight;

        ubyte[] image = new ubyte[](imageWidth*imageHeight);

        int largestHeightInRow = 0;
        import hip.util.algorithm;

        foreach(fontCh; quicksort(fontChars, (RenderizedChar a, RenderizedChar b) => a.height > b.height))
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

            if(x + fontCh.width + hSpacing > imageWidth)
            {
                x = hSpacing;
                y+= largestHeightInRow + vSpacing;
                largestHeightInRow = 0;
            }


            characters[fontCh.ch] = HipFontChar(fontCh.ch, cast(int)x, cast(int)y, fontCh.width, fontCh.height,

                xOffset, yOffset, round(xAdvance*scale), 0, 0,
                cast(float)x/imageWidth, cast(float)y/imageHeight,
                cast(float)fontCh.width/imageWidth, cast(float)fontCh.height/imageHeight,
                g
            );
            fontCh.blitToImage(image, cast(int)(x), cast(int)(y), imageWidth, imageHeight);
            x+= fontCh.width + hSpacing;

            if(fontCh.height > largestHeightInRow)
                largestHeightInRow = fontCh.height;
        }
        return image;
    }

}

version(HipNullFont)
    alias Hip_TTF_Font = HipNullFont;
else version(HipArsdFont)
    alias Hip_TTF_Font = HipArsd_TTF_Font;


private struct RenderizedChar
{
    dchar ch;
    int size;
    int width;
    int height;

    ubyte[] data;

    void blitToImage(ref ubyte[] texture, int startX, int startY, int textureWidth, int textureHeight)
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
        version(HipArsdFont)
        {
            if(data.ptr != null)
            {
                import arsd.ttf;
                stbtt_FreeBitmap(data.ptr, null);
            }
        }
        data = null;
    }
}
