module implementations.renderer.bitmaptext;
import util.data_structures;
import std.algorithm.comparison : max;
import std.string;
import std.conv:to;
import error.handler;
import std.stdio;
import def.debugging.log;
import math.matrix;
import implementations.renderer;
import core.stdc.string;
import core.stdc.stdio;

enum HipTextAlign
{
    CENTER,
    TOP,
    LEFT,
    RIGHT,
    BOTTOM
}

interface IHipBitmapText
{

}


struct HipBitmapChar
{
    ///Not meant to support more than ushort right now
    ushort id;
    ///Those are in absolute values
    int x, y, width, height;

    int xoffset, yoffset, xadvance, page, chnl; 

    ///Normalized values
    float normalizedX, normalizedY, normalizedWidth, normalizedHeight;
}

class HipBitmapFont
{
    Texture texture;
    ///The atlas path is saved inside the class
    string atlasPath;
    ///This variable is defined when the atlas is being read
    string atlasTexturePath;
    HipBitmapChar[] characters;

    ///Use that property to know how many characters was read inside the atlas
    uint charactersCount;
    
    ///Saves the space width for the bitmap text process the ' '. If the original spaceWidth is == 0, it won't draw a quad
    uint spaceWidth;

    ///How much the line break will offset in Y the next char
    uint lineBreakHeight;


    Pair!(int, int)[int] kerning;

    void readAtlas(string atlasPath)
    {
        this.atlasPath = atlasPath;
        char[100] name;
        int size;
        bool bold, italic;
        char[100] charset;
        bool unicode;
        int stretchH;
        bool smooth, aa;

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
            logln("Error! Could not read file ", atlasPath, "!!\n\n");
            return;
        }

        fscanf(f, "info face=\"%[^\"]%s size=%d bold=%d italic=%d charset=%s unicode=%d stretchH=%d smooth=%d aa=%d padding=%d,%d,%d,%d spacing=%d,%d outline=%d\n",
        name.ptr, &size, &bold, &italic, charset.ptr, &unicode, &stretchH, &smooth, &aa,
        &paddingX, &paddingY, &paddingW, &paddingH, &spacingX, &spacingY, &outline);

        //Common
        fscanf(f, "common lineHeight=%d base=%d scaleW=%d scaleH=%d pages=%d packed=%d alphaChnl=%d redChnl=%d greenChnl=%d blueChnl=%d\n",
        &lineHeight, &base, &scaleW, &scaleH, &pages, &packed, &alpha, &red, &green, &blue);

        //Page
        fscanf(f, "page id=%d file=\"%[^\"]%s\n", &pageId, file.ptr);

        atlasTexturePath = to!string(file)[0..strlen(file.ptr)];
        //Count
        fscanf(f, "chars count=%d\n", &count);


        
        size_t memSize = (count > 256 ? count : 256);

        HipBitmapChar[] ch = new HipBitmapChar[memSize];
        charactersCount = count;
        characters = ch;

        uint maxWidth = 0;
        uint maxHeight = 0;
        for(int i = 0; i < count; i++)
        {
            HipBitmapChar c;
            fscanf(f, "char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d xadvance=%d page=%d chnl=%d\n",
            &c.id, &c.x, &c.y, &c.width, &c.height, &c.xoffset, &c.yoffset, &c.xadvance, &c.page, &c.chnl);
            ch[c.id] = c;
            
            maxWidth = max(maxWidth, c.width);
            maxHeight = max(maxHeight, c.height);
        }
        if(characters[' '].width == 0 && characters[' '].xadvance == 0)
            spaceWidth = maxWidth;
        else
            spaceWidth = characters[' '].xadvance;

        if(characters['\n'].height == 0)
            lineBreakHeight = maxHeight;
        else
            lineBreakHeight = characters['\n'].height;
        
        int kerningCount = 0;
        int k1, k2, kv;

        fscanf(f, "kernings count=%d\n", &kerningCount);
        
        for(int i = 0; i < kerningCount; i++)
        {
            fscanf(f, "kerning first=%d second=%d amount=%d\n", &k1, &k2, &kv);
            kerning[k1] = Pair!(int, int)(k2, kv);
        }

        fclose(f);
    }

    void readTexture(string texturePath = "")
    {
        if(texturePath == "" && atlasTexturePath != "")
        {
            const long ind = atlasPath.lastIndexOf('/');
            if(ind != -1)
                texturePath = atlasPath[0..ind+1]~ atlasTexturePath;
            else
                texturePath = atlasTexturePath;
        }
        auto t = new Texture();
        ErrorHandler.assertErrorMessage(t.load(texturePath), "BitmapFontError", "Could not load texture at path "~texturePath);
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


    static HipBitmapFont fromFile(string atlasPath, string texturePath = "")
    {
        auto ret = new HipBitmapFont();
        ret.readAtlas(atlasPath);
        ret.readTexture(texturePath);
        return ret;
    }

}


private Shader bmTextShader = null;

class HipBitmapText
{
    HipBitmapFont font;
    Mesh mesh;
    ///For controlling easier without having to mess with align
    int x, y;
    ///Where it is actually rendered
    int displayX, displayY;

    ///Update dynamically based on the font, the text scale and the text length
    uint width, height;

    HipTextAlign alignh = HipTextAlign.LEFT;
    HipTextAlign alignv = HipTextAlign.TOP;
    uint[] indices;
    float[] vertices;
    string text;

    this()
    {
        if(bmTextShader is null)
        {
            bmTextShader = HipRenderer.newShader(HipShaderPresets.BITMAP_TEXT);
            bmTextShader.bind();
            bmTextShader.setVar("uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]);
            bmTextShader.setVar("uModel", Matrix4.identity);
            bmTextShader.setVar("uView", Matrix4.orthoLH(0, 800, 600, 0, 0.01, 100));
            bmTextShader.setVar("uProj", Matrix4.identity);
        }
        text = "";
        mesh = new Mesh(HipVertexArrayObject.getXY_ST_VAO(), bmTextShader);
        //4 vertices per quad
        mesh.createVertexBuffer("DEFAULT".length*4, HipBufferUsage.DYNAMIC);
        //6 indices per quad
        mesh.createIndexBuffer("DEFAULT".length*6, HipBufferUsage.DYNAMIC);
        mesh.sendAttributes();
    }
    void setBitmapFont(HipBitmapFont font)
    {
        this.font = font;
    }
    protected void updateAlign()
    {
        displayX = x;
        displayY = y;
        with(HipTextAlign)
        {
            switch(alignh)
            {
                case CENTER:
                    displayX+= width/2;
                    break;
                case RIGHT:
                    displayX+= width;
                    break;
                case LEFT:
                default:
                    break;
            }
            switch(alignv)
            {
                case CENTER:
                    displayY+= height/2;
                    break;
                case BOTTOM:
                    displayY+= height;
                    break;
                case TOP:
                default:
                    break;
            }
        }
    }

    float[] getVertices()
    {
        HipBitmapChar ch;
        int yoffset = 0;
        int xoffset = 0;
        //4 floats(vec2 pos, vec2 texst) and 4 vertices per character
        float[] v = new float[text.length*4*4];
        int vI = 0;
        for(int i = 0; i < text.length; i++)
        {
            ch = font.characters[text[i]];
            switch(ch.id)
            {
                case '\n':
                    if(ch.height == 0)
                    {
                        yoffset+= font.lineBreakHeight;
                        xoffset = 0;
                        break;
                    }
                    break;
                case ' ':
                    if(ch.width == 0)
                    {
                        xoffset+= font.spaceWidth;
                        break;
                    }
                    goto default;
                default:
                    xoffset+= ch.xoffset;
                    yoffset+= ch.yoffset;
                    //Gen vertices 

                    //Top left
                    v[vI++] = xoffset+displayX; //X
                    v[vI++] = yoffset+displayY; //Y
                    v[vI++] = ch.normalizedX; //S
                    v[vI++] = ch.normalizedY; //T

                    //Top Right
                    v[vI++] = xoffset+displayX+ch.width; //X+W
                    v[vI++] = yoffset+displayY; //Y
                    v[vI++] = ch.normalizedX + ch.normalizedWidth; //S+W
                    v[vI++] = ch.normalizedY; //T

                    //Bot right
                    v[vI++] = xoffset+displayX+ch.width; //X+W
                    v[vI++] = yoffset+displayY + ch.height; //Y
                    v[vI++] = ch.normalizedX + ch.normalizedWidth; //S+W
                    v[vI++] = ch.normalizedY + ch.normalizedHeight; //T

                    //Bot left
                    v[vI++] = xoffset+displayX; //X
                    v[vI++] = yoffset+displayY + ch.height; //Y+H
                    v[vI++] = ch.normalizedX; //S
                    v[vI++] = ch.normalizedY + ch.normalizedHeight; //T+H

                    yoffset-= ch.yoffset;

                    xoffset-= ch.xoffset;
                    xoffset+= ch.xadvance;

            }
        }
        return v;
    }

    void setText(string text)
    {
        if(text.length > this.text.length)
        {
            if(indices is null)
                indices = new uint[text.length*6];
            else
                indices.reserve(text.length*6);
            ulong index = 0;
            for(uint i = 0; i < text.length; i++)
            {
                indices[index+0] = i*4+0;
                indices[index+1] = i*4+1;
                indices[index+2] = i*4+2;

                indices[index+3] = i*4+2;
                indices[index+4] = i*4+3;
                indices[index+5] = i*4+0;
                index+=6;
            }
            mesh.setIndices(indices);
        }
        this.text = text;
        updateAlign();
        vertices = getVertices();
        mesh.setVertices(vertices);
    }

    void render()
    {
        import std.stdio;
        mesh.draw(indices.length);
    }
}