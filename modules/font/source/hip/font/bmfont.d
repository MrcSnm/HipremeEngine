module hip.font.bmfont;
import hip.api.data.font;
import hip.api.renderer.texture;
import hip.error.handler;


class HipBitmapFont : HipFont
{
    ///The atlas path is saved inside the class
    string atlasPath;
    ///This variable is defined when the atlas is being read
    string atlasTexturePath;

    ///Use that property to know how many characters was read inside the atlas
    uint charactersCount;

    uint height;

    private string error;


    HipFontKerning kerning;

    bool loadAtlas(string data, string atlasPath)
    {
        import hip.util.string;
        this.atlasPath = atlasPath;

        static int advanceSpace(string data, int i)
        {
            while(i < data.length && (data[i].isWhitespace || data[i] == '='))
                i++;
            return i;
        }
        static int nextToken(string data, int i)
        {
            i = advanceSpace(data, i);
            if(i >= data.length)
                return -1;
            else if(data[i] == '"') //Find the '"'
            {
                i++;
                while(i < data.length && data[i] != '"')
                {
                    if(data[i] == '\\')
                        i++;
                    i++;
                }
                if(i < data.length)i++;
                
            }
            else if(data[i].isAlpha)
            {
                while(i <= data.length && data[i].isAlpha)
                    i++;
            }
            else if(data[i].isNumeric)
            {
                while(i <= data.length && data[i].isNumeric)
                    i++;
            }
            return i;
        }

        static int getNextInt(string data, ref int i)
        {
            import hip.util.conv;
            int start = advanceSpace(data, i);
            i = nextToken(data, start);
            if(i != -1)
            {
                return to!int(data[start..i]);
            }
            return i;
        }

        static string getNextString(string data, ref int i)
        {
            int start = advanceSpace(data, i);
            i = nextToken(data, start);
            if(i != -1)
            {
                if(data[start] == '"')
                    return data[start+1..i-1];
                else
                    return data[start..i];
            }
            return "";
        }
        string name;
        int size;

        int bold, italic;
        string charset;
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
        //chars
        int count;

        int index = 0;
        enum Context
        {
            info,
            common,
            page,
            chars,
            kernings,
            unknown
        }
        int context = Context.unknown;
        string key;
        while(index != -1 && index < data.length)
        {
            key = getNextString(data, index);
            final switch(context)
            {
                case Context.info:
                {
                    switch(key)
                    {
                        case "face": 
                            name = getNextString(data, index);
                            break;
                        case "size":
                            size = getNextInt(data, index);
                            height = size;
                            break;
                        case "bold":
                            bold = getNextInt(data, index);
                            break;
                        case "italic":
                            italic = getNextInt(data, index);
                            break;
                        case "charset":
                            charset = getNextString(data, index);
                            break;
                        case "unicode":
                            unicode = getNextInt(data, index);
                            break;
                        case "stretchH":
                            stretchH = getNextInt(data, index);
                            break;
                        case "smooth":
                            smooth = getNextInt(data, index);
                            break;
                        case "aa":
                            aa = getNextInt(data, index);
                            break;
                        case "padding":
                            paddingX = getNextInt(data, index);
                            index++;
                            paddingY = getNextInt(data, index);
                            index++;
                            paddingW = getNextInt(data, index);
                            index++;
                            paddingH = getNextInt(data, index);
                            index++;
                            break;
                        case "spacing":
                            spacingX = getNextInt(data, index);
                            index++;
                            spacingY = getNextInt(data, index);
                            index++;
                            break;
                        case "outline":
                            outline = getNextInt(data, index);
                            break;
                        default:
                            goto checkUnknown;
                    }
                    break;
                }
                case Context.common:
                {
                    int tempIndex = index;
                    int next = getNextInt(data, index);
                    switch(key)
                    {
                        case "lineHeight":
                            lineHeight = next;
                            break;
                        case "base":
                            base = next;
                            break;
                        case "scaleW":
                            scaleW = next;
                            break;
                        case "scaleH":
                            scaleH = next;
                            break;
                        case "pages":
                            pages = next;
                            break;
                        case "packed":
                            packed = next;
                            break;
                        case "alphaChnl":
                            alpha = next;
                            break;
                        case "redChnl":
                            red = next;
                            break;
                        case "greenChnl":
                            green = next;
                            break;
                        case"blueChnl":
                            blue = next;
                            break;
                        default:
                            index = tempIndex;
                            goto checkUnknown;
                    }
                    break;
                }
                case Context.page:
                {
                    switch(key)
                    {
                        case "id":
                            pageId = getNextInt(data, index);
                            break;
                        case "file":
                            atlasTexturePath = getNextString(data, index);
                            break;
                        default:
                            goto checkUnknown;
                    }
                    break;
                }
                case Context.chars:
                {
                    //Advance "count"
                    charactersCount = count = getNextInt(data, index);
                    uint maxWidth = 0;


                    for(int i = 0; i < count; i++)
                    {
                        HipFontChar ch;
                        int*[10] fields = [cast(int*)&ch.id, &ch.x, &ch.y, &ch.width, &ch.height, &ch.xoffset, &ch.yoffset, &ch.xadvance, &ch.page, &ch.chnl];
                        //Advance "char"
                        index = nextToken(data, index);
                        for(int fIndex = 0; fIndex < fields.length; fIndex++)
                        {
                            index = nextToken(data, index);
                            *fields[fIndex] = getNextInt(data, index);
                        }
                        if(ch.width > maxWidth)
                            maxWidth = ch.width;
                        characters[ch.id] = ch;
                    }
                    auto space = ' ' in characters;
                    if(space is null || (space.width == 0 && space.xadvance == 0))
                        spaceWidth = maxWidth;
                    else
                        spaceWidth = space.xadvance > space.width ? space.xadvance : space.width;
                    lineBreakHeight = lineHeight;
                    context = Context.unknown;
                    break;
                }
                case Context.kernings:
                {
                    //Advance "count"
                    index = nextToken(data, index);
                    int kerningCount = getNextInt(data, index);
                    for(int i = 0; i < kerningCount; i++)
                    {
                        //Advance "kerning "
                        index = nextToken(data, index);
                        int[3] values = void; //first, second, amount
                        for(int fIndex = 0; fIndex < 3; fIndex++)
                        {
                            index = nextToken(data, index);
                            values[fIndex] = getNextInt(data, index);
                        }
                        if((values[0] in kerning) is null)
                            kerning[values[0]] = HipCharKerning.init;
                        kerning[values[0]][values[1]] = values[2];
                    }
                    break;
                }
                //Tries to find the context
                checkUnknown: case Context.unknown:
                    contextSwitch: switch(key)
                    {
                        static foreach(mem; __traits(allMembers, Context))
                        {
                            case mem:
                                context = __traits(getMember, Context, mem);
                                break contextSwitch;
                        }
                        default:
                            assert(false, "Unknown key received: "~key);
                    }
                    continue;
            }
        }
        

        return true;
    }

    bool loadTexture(IHipTexture t)
    {
        texture = t;
        int width = t.getWidth;
        int height = t.getHeight;
        if(width == 0 || height == 0)
            return false;
        
        foreach(ref ch; characters)
        {
            if(ch.id != 0)
            {
                ch.normalizedX = cast(float)ch.x/width;
                ch.normalizedY = cast(float)ch.y/height;
                ch.normalizedWidth = cast(float)ch.width/width;
                ch.normalizedHeight = cast(float)ch.height/height;
            }
        }
        return true;
    }

    override uint getHeight() const { return height; }

    string getTexturePath()
    {
        import hip.util.path;
        string texturePath;
        if(atlasTexturePath != "")
        {
            string atlasDir = atlasPath.dirName;
            if(atlasDir != atlasPath)
                texturePath = atlasDir.joinPath(atlasTexturePath);
            else
                texturePath = atlasTexturePath;
        }
        return texturePath;
    }

    /**
    *   This won't do anything in case of a bitmap font, as no one can change it.
    */
    override HipFont getFontWithSize(uint size)
    {
        HipBitmapFont ret = new HipBitmapFont();
        ret.atlasPath = this.atlasPath;
        ret.atlasTexturePath = this.atlasTexturePath;
        ret.kerning = cast(HipFontKerning)this.kerning;
        ret.charactersCount = this.charactersCount;
        ret._texture = cast(IHipTexture)this._texture;
        return cast(HipFont)ret;
    }
    void readTexture(string texturePath = "")
    {
        texturePath = texturePath == "" ? getTexturePath() :  texturePath;
        // auto t = new HipTexture();
        // t.load(texturePath);
        // loadTexture(t);
    }


    static HipBitmapFont fromFile(string atlasPath, string texturePath = "")
    {
        auto ret = new HipBitmapFont();
        ret.loadAtlas("", atlasPath);
        ret.readTexture(texturePath);
        return ret;
    }
    
    override int getKerning(const(HipFontChar)* current, const(HipFontChar)* next) const
    {
        return getKerning(dchar(current.id), dchar(next.id));
    }
    override int getKerning(dchar current, dchar next) const
    {
        const HipCharKerning* chKerning = current in kerning;
        if(chKerning is null)
            return 0;
        const int* kerningValue = next in (*chKerning);
        if(kerningValue is null)
            return 0;
        return *kerningValue;
    }
    

}
