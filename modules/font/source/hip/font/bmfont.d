module hip.font.bmfont;
import hip.hipengine.api.data.font;
import hip.hiprenderer.texture;
import hip.error.handler;


class HipBitmapFont : HipFont
{
    Texture texture;
    ///The atlas path is saved inside the class
    string atlasPath;
    ///This variable is defined when the atlas is being read
    string atlasTexturePath;

    ///Use that property to know how many characters was read inside the atlas
    uint charactersCount;

    private string error;


    HipFontKerning kerning;
    // Pair!(int, int)[][int] kerning;

    void readAtlas(string atlasPath)
    {
        import core.stdc.string : strlen;
        import core.stdc.stdio;
        this.atlasPath = atlasPath;
        char[512] name;
        int size;

        int bold, italic;
        char[512] charset;
        int unicode;
        int stretchH;
        int smooth, aa;

        int paddingX, paddingY, paddingW, paddingH;
        int spacingX, spacingY;
        int outline;

        //Common
        int lineHeight, base, scaleW, scaleH, pages, packed, alpha, red, green,blue;
        //Page
        int pageId;
        char[512] file;
        //chars
        int count;


        FILE* f = fopen(atlasPath.ptr, "r");
        if(f == null)
        {
            error = "Error! Could not read file "~ atlasPath ~ "!!\n\n";
            return;
        }

        //Doing that disables the warning
        string format = "info face=\"%[^\"]%512s size=%d bold=%d italic=%d charset=%512s unicode=%d stretchH=%d smooth=%d aa=%d padding=%d,%d,%d,%d spacing=%d,%d outline=%d\n";
        fscanf(f, format.ptr,
        name.ptr, &size, &bold, &italic, charset.ptr, &unicode, &stretchH, &smooth, &aa,
        &paddingX, &paddingY, &paddingW, &paddingH, &spacingX, &spacingY, &outline);

        //Common
        fscanf(f, "common lineHeight=%d base=%d scaleW=%d scaleH=%d pages=%d packed=%d alphaChnl=%d redChnl=%d greenChnl=%d blueChnl=%d\n",
        &lineHeight, &base, &scaleW, &scaleH, &pages, &packed, &alpha, &red, &green, &blue);

        //Page
        format = "page id=%d file=\"%[^\"]%512s\n";
        fscanf(f, format.ptr, &pageId, file.ptr);

        atlasTexturePath = (cast(string)file)[0..strlen(file.ptr)];
        //Count
        fscanf(f, "chars count=%d\n", &count);


        
        size_t memSize = (count > 256 ? count : 256);

        scope HipFontChar[] ch = new HipFontChar[memSize];
        charactersCount = count;

        uint maxWidth = 0;
        for(int i = 0; i < count; i++)
        {
            HipFontChar c;
            fscanf(f, "char id=%u x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d xadvance=%d page=%d chnl=%d\n",
            &c.id, &c.x, &c.y, &c.width, &c.height, &c.xoffset, &c.yoffset, &c.xadvance, &c.page, &c.chnl);
            ch[c.id] = c;

            if(c.width > maxWidth)
                maxWidth = c.width;
        }
        if(characters[' '].width == 0 && characters[' '].xadvance == 0)
            spaceWidth = maxWidth;
        else
            spaceWidth = characters[' '].xadvance;

        lineBreakHeight = lineHeight;
        
        int kerningCount = 0;

        fscanf(f, "kernings count=%d\n", &kerningCount);
        
        int kFirst, kSecond, kValue;
        for(int i = 0; i < kerningCount; i++)
        {
            fscanf(f, "kerning first=%d second=%d amount=%d\n", &kFirst, &kSecond, &kValue);
            if((kFirst in kerning) is null)
                kerning[kFirst] = HipCharKerning.init;
            kerning[kFirst][kSecond] = kValue;
        }
        fclose(f);
        foreach(HipFontChar hChar; ch)
            characters[hChar.id] = hChar;
        

    }

    void loadTexture(Texture t)
    {
        texture = t;
        for(int i = 0; i < characters.length; i++)
        {
            auto ch = &characters[i];
            if(ch.id != 0)
            {
                ch.normalizedX = cast(float)ch.x/texture.width;
                ch.normalizedY = cast(float)ch.y/texture.height;
                ch.normalizedWidth = cast(float)ch.width/texture.width;
                ch.normalizedHeight = cast(float)ch.height/texture.height;
            }
        }
    }
    void readTexture(string texturePath = "")
    {
        import hip.util.path;
        if(texturePath == "" && atlasTexturePath != "")
        {
            if(atlasPath.dirName != atlasPath)
                texturePath = atlasPath.dirName.joinPath(atlasTexturePath);
            else
                texturePath = atlasTexturePath;
        }
        auto t = new Texture();
        t.load(texturePath);
        loadTexture(t);
    }


    static HipBitmapFont fromFile(string atlasPath, string texturePath = "")
    {
        auto ret = new HipBitmapFont();
        ret.readAtlas(atlasPath);
        ret.readTexture(texturePath);
        return ret;
    }
    
    override int getKerning(dchar current, dchar next)
    {
        HipCharKerning* chKerning = current in kerning;
        if(chKerning is null)
            return 0;
        int* kerningValue = next in (*chKerning);
        if(kerningValue is null)
            return 0;
        return *kerningValue;
    }
    

}
