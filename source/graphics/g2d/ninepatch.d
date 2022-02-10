module graphics.g2d.ninepatch;
public import hiprenderer.texture;
public import graphics.g2d.spritebatch;
import graphics.g2d.sprite;

class NinePatch
{
    uint width, height;
    float x, y;
     HipSprite[9] sprites;
    protected float[HipSpriteVertex.quadCount*9] vertices;
    Texture texture;

    this(uint width, uint height, Texture tex)
    {
        this.width = width;
        this.height = height;
        x = 0;
        y = 0;
        vertices[] = 0;
        texture = tex;
        for(int i = 0; i < 9; i++)
            sprites[i] = new HipSprite(tex);

        setupTextureRegions();
        build();
    }

    void setupTextureRegions()
    {
        float xw = (cast(float)sprites[0].width/3.0f)/sprites[0].width;
        float yh = (cast(float)sprites[0].height/3.0f)/sprites[0].height;
        float xw2 = xw*2;
        float xw3 = xw*3;
        float yh2 = yh*2;
        float yh3 = yh*3;

        sprites[TOP_LEFT].setRegion(0, 0, xw, yh);
        sprites[TOP_MID].setRegion(xw, 0, xw2, yh);
        sprites[TOP_RIGHT].setRegion(xw2, 0, xw3, yh);

        sprites[MID_LEFT].setRegion(0,  yh, xw,  yh2);
        sprites[MID_MID].setRegion(xw,  yh, xw2, yh2);
        sprites[MID_RIGHT].setRegion(xw2, yh, xw3, yh2);

        sprites[BOT_LEFT].setRegion(0,  yh2, xw,  yh3);
        sprites[BOT_MID].setRegion(xw,  yh2, xw2, yh3);
        sprites[BOT_RIGHT].setRegion(xw2, yh2, xw3, yh3);
    }

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
            uint quad = cast(uint)HipSpriteVertex.quadCount*i;
            vertices[quad+X1] = sprites[i].getVertices()[X1];
            vertices[quad+X2] = sprites[i].getVertices()[X2];
            vertices[quad+X3] = sprites[i].getVertices()[X3];
            vertices[quad+X4] = sprites[i].getVertices()[X4];

            vertices[quad+Y1] = sprites[i].getVertices()[Y1];
            vertices[quad+Y2] = sprites[i].getVertices()[Y2];
            vertices[quad+Y3] = sprites[i].getVertices()[Y3];
            vertices[quad+Y4] = sprites[i].getVertices()[Y4];
        }
    }

    void build()
    {
        float xScalingFactor = width - (sprites[TOP_LEFT].width*2);
        xScalingFactor/= sprites[TOP_LEFT].width;

        float yScalingFactor = height - (sprites[TOP_LEFT].height*2);
        yScalingFactor/= sprites[TOP_LEFT].height;


        uint spWidth = sprites[TOP_LEFT].width;
        uint spHeight = sprites[TOP_LEFT].height;

        //First, take care of those which don't scale.
        sprites[TOP_LEFT].setPosition(x, y);
        sprites[TOP_RIGHT].setPosition(x + (width-spWidth), y);
        sprites[BOT_LEFT].setPosition(x, y + (height-spHeight));
        sprites[BOT_RIGHT].setPosition(x + (width-spWidth), y + (height-spHeight));

        //Now, those which scales in only one direction
        sprites[TOP_MID].setPosition(x+spWidth, y);
        sprites[TOP_MID].setScale(xScalingFactor, 1);

        sprites[MID_LEFT].setPosition(x, y+spHeight);
        sprites[MID_LEFT].setScale(1, yScalingFactor);

        sprites[MID_RIGHT].setPosition(x+width-spWidth, y+spHeight);
        sprites[MID_RIGHT].setScale(1, yScalingFactor);

        sprites[BOT_MID].setPosition(x+spWidth, y + (height-spHeight));
        sprites[BOT_MID].setScale(xScalingFactor, 1);

        //The last one
        sprites[MID_MID].setPosition(spWidth+x, spHeight+y);
        sprites[MID_MID].setScale(xScalingFactor,  yScalingFactor);

        for(int i = 0; i < HipSpriteVertex.quadCount; i++)
        {
            vertices[i] = sprites[TOP_LEFT].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*1+i] = sprites[TOP_MID].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*2+i] = sprites[TOP_RIGHT].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*3+i] = sprites[MID_LEFT].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*4+i] = sprites[MID_MID].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*5+i] = sprites[MID_RIGHT].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*6+i] = sprites[BOT_LEFT].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*7+i] = sprites[BOT_MID].getVertices()[i];
            vertices[HipSpriteVertex.quadCount*8+i] = sprites[BOT_RIGHT].getVertices()[i];
        }
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

    public ref float[HipSpriteVertex.quadCount*9] getVertices(){return vertices;}

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