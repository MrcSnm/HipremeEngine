module hip.game2d.ninepatch;
public import hip.api.renderer.texture;
public import hip.game2d.sprite;
import hip.game2d.renderer_data;

enum NinePatchType
{
    SCALED,
    TILED //I Think this effect is quite ugly, but maybe it'll be useful at some time
}

class NinePatch
{
    uint width, height;
    float x, y;
    float scaleX, scaleY;
    protected HipSprite[9] sprites;
    protected HipSpriteVertex[9*4] vertices;
    IHipTexture texture;
    NinePatchType stretchStrategy;

    this(uint width, uint height, IHipTexture tex, NinePatchType type = NinePatchType.SCALED)
    {
        this.width = width;
        this.height = height;
        x = y = 0;
        scaleX = scaleY = 1;
        texture = tex;
        stretchStrategy = type;
        for(int i = 0; i < 9; i++)
            sprites[i] = new HipSprite(tex);

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
        float xScalingFactor = cast(float)(width - cast(float)(sprites[TOP_LEFT].width*2));
        if(sprites[TOP_LEFT].width != 0)
            xScalingFactor/= cast(float)sprites[TOP_LEFT].width;
        else  
            xScalingFactor = 0;

        float yScalingFactor = cast(float)height - cast(float)(sprites[TOP_LEFT].height*2);
        if(sprites[TOP_LEFT].height != 0)
            yScalingFactor/= cast(float)sprites[TOP_LEFT].height;
        else
            yScalingFactor = 0;

        if(xScalingFactor < 1) xScalingFactor = 1;
        if(yScalingFactor < 1) yScalingFactor = 1;


        int spWidth = sprites[TOP_LEFT].width;
        int spHeight = sprites[TOP_LEFT].height;

        int px2 = width-spWidth;
        if(px2 < spWidth) px2 = spWidth;

        int py2 = height-spHeight;
        if(py2 < spHeight) py2 = spHeight;


        //First, take care of those which don't scale.
        sprites[TOP_LEFT].setPosition(x, y);
        sprites[TOP_RIGHT].setPosition(x + px2, y);
        sprites[BOT_LEFT].setPosition(x, y + py2);
        sprites[BOT_RIGHT].setPosition(x + px2, y + py2);

        //Now, those which scales in only one direction
        sprites[TOP_MID].setPosition(x+spWidth, y);
        sprites[MID_LEFT].setPosition(x, y+spHeight);
        sprites[MID_RIGHT].setPosition(x+ px2, y+spHeight);
        sprites[BOT_MID].setPosition(x+spWidth, y + py2);
        sprites[MID_MID].setPosition(spWidth+x, spHeight+y);


        if(stretchStrategy == NinePatchType.SCALED)
        {
            sprites[TOP_MID].setScale(xScalingFactor, 1);
            sprites[MID_LEFT].setScale(1, yScalingFactor);
            sprites[MID_RIGHT].setScale(1, yScalingFactor);
            sprites[BOT_MID].setScale(xScalingFactor, 1);

            //The last one
            sprites[MID_MID].setScale(xScalingFactor,  yScalingFactor);
        }
        else
        {
            sprites[TOP_MID].setTiling(xScalingFactor, 1);
            sprites[MID_LEFT].setTiling(1, yScalingFactor);
            sprites[MID_RIGHT].setTiling(1, yScalingFactor);
            sprites[BOT_MID].setTiling(xScalingFactor, 1);

            //The last one
            sprites[MID_MID].setTiling(xScalingFactor,  yScalingFactor);
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

        uint i = 0;
        vertices[i++..i*4] = sprites[TOP_LEFT].getVertices();
        vertices[i++..i*4] = sprites[TOP_MID].getVertices();
        vertices[i++..i*4] = sprites[TOP_RIGHT].getVertices();
        vertices[i++..i*4] = sprites[MID_LEFT].getVertices();
        vertices[i++..i*4] = sprites[MID_MID].getVertices();
        vertices[i++..i*4] = sprites[MID_RIGHT].getVertices();
        vertices[i++..i*4] = sprites[BOT_LEFT].getVertices();
        vertices[i++..i*4] = sprites[BOT_MID].getVertices();
        vertices[i++..i*4] = sprites[BOT_RIGHT].getVertices();
    }

    void setTopLeft(uint u1, uint v1, uint u2, uint v2){sprites[TOP_LEFT].setRegion(u1,v1,u2,v2);}
    void setTopMid(uint u1, uint v1, uint u2, uint v2){sprites[TOP_MID].setRegion(u1,v1,u2,v2);}
    void setTopRight(uint u1, uint v1, uint u2, uint v2){sprites[TOP_RIGHT].setRegion(u1,v1,u2,v2);}
    

    void setMidLeft (uint u1, uint v1, uint u2, uint v2){sprites[MID_LEFT].setRegion(u1,v1,u2,v2);}
    void setMidMid  (uint u1, uint v1, uint u2, uint v2){sprites[MID_MID].setRegion(u1,v1,u2,v2);}
    void setMidRight(uint u1, uint v1, uint u2, uint v2){sprites[MID_RIGHT].setRegion(u1,v1,u2,v2);}

    void setBotLeft (uint u1, uint v1, uint u2, uint v2){sprites[BOT_LEFT].setRegion(u1,v1,u2,v2);}
    void setBotMid  (uint u1, uint v1, uint u2, uint v2){sprites[BOT_MID].setRegion(u1,v1,u2,v2);}
    void setBotRight(uint u1, uint v1, uint u2, uint v2){sprites[BOT_RIGHT].setRegion(u1,v1,u2,v2);}


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