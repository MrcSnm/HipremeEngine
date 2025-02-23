module hip.game2d.ninepatch;
public import hip.api.renderer.texture;
public import hip.game2d.sprite;
import hip.api.renderer.shaders.spritebatch;
import hip.api.data.textureatlas;

enum NinePatchType
{
    SCALED,
    TILED //I Think this effect is quite ugly, but maybe it'll be useful at some time
}

class NinePatch
{
    uint width, height;
    float x = 0, y = 0;
    float scaleX = 1, scaleY = 1;
     HipSprite[9] sprites;
    protected HipSpriteVertex[9*4] vertices;
    IHipTexture texture;
    NinePatchType stretchStrategy;

    this(IHipTexture tex, NinePatchType t = NinePatchType.SCALED)
    {
        texture = tex;
        foreach(i; 0..9)
        {
            sprites[i] = new HipSprite(tex);
            sprites[i].setOrigin(0,0);
        }
        stretchStrategy = t;
    }

    this(uint width, uint height, IHipTexture tex, NinePatchType type = NinePatchType.SCALED)
    {
        this.width = width;
        this.height = height;
        texture = tex;
        stretchStrategy = type;
        for(int i = 0; i < 9; i++)
        {
            sprites[i] = new HipSprite(tex);
            sprites[i].setOrigin(0,0);
        }

        setTextureRegions();
        setSize(width, height);
    }

    void setSize(int width, int height)
    {
        this.width = width;
        this.height = height;
        build();
    }

    /**
    *   The arguments will be divided by the texture width and height for
    *   generating the UVs
    */
    void setTextureRegions(uint x, uint y, uint width, uint height)
    {
        int texWidth = sprites[0].getTextureWidth;
        int texHeight = sprites[0].getTextureHeight;

        float tx = cast(float)x/texWidth;
        float ty = cast(float)y/texHeight;

        float xw = (cast(float)width/3.0f)/texWidth;
        float yh = (cast(float)height/3.0f)/texHeight;
        float xw2 = xw*2;
        float xw3 = xw*3;
        float yh2 = yh*2;
        float yh3 = yh*3;

        sprites[TOP_LEFT].setRegion (tx+0,   ty+0, tx+xw,  ty+yh);
        sprites[TOP_MID].setRegion  (tx+xw,  ty+0, tx+xw2, ty+yh);
        sprites[TOP_RIGHT].setRegion(tx+xw2, ty+0, tx+xw3, ty+yh);

        sprites[MID_LEFT].setRegion (tx+0,  ty+yh, tx+xw,  ty+yh2);
        sprites[MID_MID].setRegion  (tx+xw, ty+ yh,tx+ xw2,ty+ yh2);
        sprites[MID_RIGHT].setRegion(tx+xw2,ty+ yh,tx+ xw3,ty+ yh2);

        sprites[BOT_LEFT].setRegion (tx+0,  ty+yh2, tx+xw,  ty+yh3);
        sprites[BOT_MID].setRegion  (tx+xw, ty+ yh2,tx+ xw2,ty+ yh3);
        sprites[BOT_RIGHT].setRegion(tx+xw2,ty+ yh2,tx+ xw3,ty+ yh3);
    }

    /**
    *   Cuts the entire image in 9 slices
    */
    void setTextureRegions()
    {
        setTextureRegions(0, 0, sprites[0].getTextureWidth, sprites[0].getTextureHeight);
    }


    void build()
    {
        static float getXScalingFactor(ubyte index, HipSprite[] sprites, uint width)
        {
            float ret = (width - (sprites[index-1].width + sprites[index+1].width));
            if(sprites[index].width != 0)
                ret/= cast(float)sprites[index].width;
            return ret;
        }

        static float getYScalingFactor(ubyte index, HipSprite[] sprites, uint height)
        {
            float ret = (height - (sprites[index-3].height + sprites[index+3].height));
            if(sprites[index].height != 0)
                ret/= cast(float)sprites[index].height;
            return ret;
        }
        /**
         * Receives the _LEFT part to calculate the scale.
         * This scale is used whenever there is a need of scale being less than 1
         * Params:
         *   index =
         *   sprites =
         *   width =
         * Returns:
         */
        static float getSingleXScaling(ubyte index, HipSprite[] sprites, uint width)
        {
            if(width < sprites[index].width + sprites[index+2].width)
                return cast(float)width / (sprites[index].width + sprites[index+2].width);
            return 1;
        }
        static float getSingleYScaling(ubyte index, HipSprite[] sprites, uint height)
        {
            if(height < sprites[index].height + sprites[index+6].height)
                return cast(float)height / (sprites[index].height + sprites[index+6].height);
            return 1;
        }

        float scaleXTop = getSingleXScaling(TOP_LEFT, sprites, width);
        float scaleYTop = getSingleYScaling(TOP_LEFT, sprites, height);


        int spWidth = sprites[TOP_LEFT].width;
        int spHeight = sprites[TOP_LEFT].height;

        int px2 = cast(int)(width-spWidth*scaleXTop);
        int py2 = cast(int)(height-spHeight*scaleYTop);


        //First, take care of those which don't scale.
        sprites[TOP_LEFT].setPosition(x, y);
        sprites[TOP_RIGHT].setPosition(x + px2, y);
        sprites[BOT_LEFT].setPosition(x, y + py2);
        sprites[BOT_RIGHT].setPosition(x + px2, y + py2);

        ///Those scales may only change whenever they are actually smaller than a scalable size
        sprites[TOP_LEFT].setScale(scaleXTop, scaleYTop);
        sprites[TOP_RIGHT].setScale(scaleXTop, scaleYTop);
        sprites[BOT_LEFT].setScale(scaleXTop, scaleYTop);
        sprites[BOT_RIGHT].setScale(scaleXTop, scaleYTop);

        //Now, those which scales in only one direction
        sprites[TOP_MID].setPosition(x+spWidth, y);
        sprites[MID_LEFT].setPosition(x, y+spHeight);
        sprites[MID_RIGHT].setPosition(x+ px2, y+spHeight);
        sprites[BOT_MID].setPosition(x+spWidth, y + py2);
        sprites[MID_MID].setPosition(spWidth+x, spHeight+y);



        if(stretchStrategy == NinePatchType.SCALED)
        {
            sprites[TOP_MID].setScale(getXScalingFactor(TOP_MID ,sprites, width), scaleYTop);
            sprites[MID_LEFT].setScale(scaleXTop, getYScalingFactor(MID_LEFT, sprites, height));
            sprites[MID_RIGHT].setScale(scaleXTop, getYScalingFactor(MID_RIGHT, sprites, height));
            sprites[BOT_MID].setScale(getXScalingFactor(BOT_MID, sprites, width), scaleYTop);

            //The last one
            sprites[MID_MID].setScale(getXScalingFactor(MID_MID, sprites, width),  getYScalingFactor(MID_MID, sprites, height));
        }
        else
        {
            sprites[TOP_MID].setTiling(getXScalingFactor(TOP_MID ,sprites, width), scaleYTop);
            sprites[MID_LEFT].setTiling(scaleXTop, getYScalingFactor(MID_LEFT, sprites, height));
            sprites[MID_RIGHT].setTiling(scaleXTop, getYScalingFactor(MID_RIGHT, sprites, height));
            sprites[BOT_MID].setTiling(getXScalingFactor(BOT_MID, sprites, width), scaleYTop);

            //The last one
            sprites[MID_MID].setTiling(getXScalingFactor(MID_MID, sprites, width),  getYScalingFactor(MID_MID, sprites, height));
        }

        // uint thresholdWidth = spWidth*2;
        // uint thresholdHeight = spHeight*2;
        
        // if(width < thresholdWidth)
        // {
        //     float sX = (width/2.0)/thresholdWidth;
        //     sprites[TOP_LEFT].setScale(sX, sprites[TOP_LEFT].scaleY);
        //     sprites[TOP_RIGHT].setScale(sX, sprites[TOP_RIGHT].scaleY);

        //     sprites[MID_LEFT].setScale(sX, sprites[MID_LEFT].scaleY);
        //     sprites[MID_RIGHT].setScale(sX, sprites[MID_RIGHT].scaleY);

        //     sprites[BOT_LEFT].setScale(sX, sprites[BOT_LEFT].scaleY);
        //     sprites[BOT_RIGHT].setScale(sX, sprites[BOT_RIGHT].scaleY);

        //     sprites[TOP_MID].setScale(0,0);
        //     sprites[MID_MID].setScale(0,0);
        //     sprites[BOT_MID].setScale(0,0);
        // }
        // if(height < thresholdHeight)
        // {
        //     float sY = (height/2.0)/thresholdHeight;
        //     sprites[TOP_LEFT].setScale(sprites[TOP_LEFT].scaleX, sY);
        //     sprites[TOP_RIGHT].setScale(sprites[TOP_RIGHT].scaleX, sY);

        //     sprites[MID_LEFT].setScale(sprites[MID_LEFT].scaleX, sY);
        //     sprites[MID_RIGHT].setScale(sprites[MID_RIGHT].scaleX, sY);

        //     sprites[BOT_LEFT].setScale(sprites[BOT_LEFT].scaleX, sY);
        //     sprites[BOT_RIGHT].setScale(sprites[BOT_RIGHT].scaleX, sY);

        //     sprites[TOP_MID].setScale(0,0);
        //     sprites[MID_MID].setScale(0,0);
        //     sprites[BOT_MID].setScale(0,0);
        // }

        vertices[0..4] = sprites[TOP_LEFT].getVertices();
        vertices[4..8] = sprites[TOP_MID].getVertices();
        vertices[8..12] = sprites[TOP_RIGHT].getVertices();
        vertices[12..16] = sprites[MID_LEFT].getVertices();
        vertices[16..20] = sprites[MID_MID].getVertices();
        vertices[20..24] = sprites[MID_RIGHT].getVertices();
        vertices[24..28] = sprites[BOT_LEFT].getVertices();
        vertices[28..32] = sprites[BOT_MID].getVertices();
        vertices[32..36] = sprites[BOT_RIGHT].getVertices();
    }

    void setTopLeft(TextureCoordinatesQuad q){sprites[TOP_LEFT].setRegion(q);}
    void setTopMid(TextureCoordinatesQuad q){sprites[TOP_MID].setRegion(q);}
    void setTopRight(TextureCoordinatesQuad q){sprites[TOP_RIGHT].setRegion(q);}
    

    void setMidLeft (TextureCoordinatesQuad q){sprites[MID_LEFT].setRegion(q);}
    void setMidMid  (TextureCoordinatesQuad q){sprites[MID_MID].setRegion(q);}
    void setMidRight(TextureCoordinatesQuad q){sprites[MID_RIGHT].setRegion(q);}

    void setBotLeft (TextureCoordinatesQuad q){sprites[BOT_LEFT].setRegion(q);}
    void setBotMid  (TextureCoordinatesQuad q){sprites[BOT_MID].setRegion(q);}
    void setBotRight(TextureCoordinatesQuad q){sprites[BOT_RIGHT].setRegion(q);}


    void setPosition(float x, float y)
    {
        this.x = x;
        this.y = y;
        updatePosition();
    }


   void setColor(HipColor color)
   {
       int quad = 0;
       for(int i = 0; i < 9; i++)
       {
            quad = cast(int)(i*4);
            vertices[quad].vColor = color;
            vertices[quad+1].vColor = color;
            vertices[quad+2].vColor = color;
            vertices[quad+3].vColor = color;
        }
   }
   public ref HipSpriteVertex[4*9] getVertices(){return vertices;}


    /**
    *   Use this function instead of build for less overhead
    */
    protected void updatePosition()
    {
        uint spWidth = sprites[TOP_LEFT].width;
        uint spHeight = sprites[TOP_LEFT].height;
        sprites[TOP_LEFT].setPosition(x, y);
        sprites[TOP_RIGHT].setPosition(x + (width-spWidth), y);
        sprites[BOT_LEFT].setPosition(x, y + (height-spHeight));
        sprites[BOT_RIGHT].setPosition(x + (width-spWidth), y + (height-spHeight));
        sprites[TOP_MID].setPosition(x+spWidth, y);
        sprites[MID_LEFT].setPosition(x, y+spHeight);
        sprites[MID_RIGHT].setPosition(x+width-spWidth, y+spHeight);
        sprites[BOT_MID].setPosition(x+spWidth, y + (height-spHeight));
        sprites[MID_MID].setPosition(spWidth+x, spHeight+y);

        for(uint i = 0; i < 9; i++)
        {
            uint quad = i*4;
            HipSpriteVertex[] verts = sprites[i].getVertices();
            vertices[quad].vPosition = verts[0].vPosition;
            vertices[quad+1].vPosition = verts[1].vPosition;
            vertices[quad+2].vPosition = verts[2].vPosition;
            vertices[quad+3].vPosition = verts[3].vPosition;
        }
    }

    void draw()
    {
        foreach(HipSprite sp; sprites)
            sp.draw;
    }
    /**
     Creates a NinePatch from the matrix, starting from left to right, top to bottom
     * Params:
     *   rects = The rects that defines the sprite regions
     *   tex = The texture being used as a reference to the regions
     *   width = The width of the resulting nine patch
     *   height = The height of the resulting nine patch
     *   t = The scaling type
     * Returns:
     */
    static NinePatch fromQuads(AtlasRect[9] rects, IHipTexture tex, int width, int height, NinePatchType t = NinePatchType.SCALED)
    {
        NinePatch ret = new NinePatch(tex, t);

        AtlasSize sz = AtlasSize(tex.getWidth, tex.getHeight);
        foreach(i, sp; ret.sprites)
        {
            // rects[i].y = sz.height - rects[i].y;
            sp.width  = cast(uint)rects[i].width;
            sp.height = cast(uint)rects[i].height;
            sp.setRegion(rects[i].toQuad(sz));
        }

        ret.setSize(width, height);
        return ret;
    }


}

private enum : ubyte
{
    TOP_LEFT = 0,
    TOP_MID,
    TOP_RIGHT,

    MID_LEFT,
    MID_MID,
    MID_RIGHT,

    BOT_LEFT,
    BOT_MID,
    BOT_RIGHT
}