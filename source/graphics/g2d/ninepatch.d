module graphics.g2d.ninepatch;
import hiprenderer.texture;
import graphics.g2d.spritebatch;
import graphics.g2d.sprite;

class NinePatch
{
    uint width, height;
    float x, y;
    TextureRegion[9] regions;
    Texture texture;

    this(uint width, uint height, Texture tex)
    {
        this.width = width;
        this.height = height;
        texture = tex;
        build();
    }

    void build()
    {
        uint xw = width/3;
        uint yh = height/3;
        uint xw2 = xw*2;
        uint xw3 = xw*3;
        uint yh2 = yh*2;
        uint yh3 = yh*3;

        regions[TOP_LEFT]   = new TextureRegion(texture, 0u,  0u, xw,  yh);
        regions[TOP_MID]    = new TextureRegion(texture, xw,  0u, xw2, yh);
        regions[TOP_RIGHT]  = new TextureRegion(texture, xw2, 0u, xw3, yh);

        regions[MID_LEFT]   = new TextureRegion(texture, 0u,  yh, xw,  yh2);
        regions[MID_MID]    = new TextureRegion(texture, xw,  yh, xw2, yh2);
        regions[MID_RIGHT]  = new TextureRegion(texture, xw2, yh, xw3, yh2);

        regions[BOT_LEFT]   = new TextureRegion(texture, 0u,  yh2, xw,  yh3);
        regions[BOT_MID]    = new TextureRegion(texture, xw,  yh2, xw2, yh3);
        regions[BOT_RIGHT]  = new TextureRegion(texture, xw2, yh2, xw3, yh3);
    }

    void setTopLeft(uint u1, uint v1, uint u2, uint v2){regions[TOP_LEFT].setRegion(u1,v1,u2,v2);}
    void setTopMid(uint u1, uint v1, uint u2, uint v2){regions[TOP_MID].setRegion(u1,v1,u2,v2);}
    void setTopRight(uint u1, uint v1, uint u2, uint v2){regions[TOP_RIGHT].setRegion(u1,v1,u2,v2);}
    

    void setMidLeft (uint u1, uint v1, uint u2, uint v2){regions[MID_LEFT].setRegion(u1,v1,u2,v2);}
    void setMidMid  (uint u1, uint v1, uint u2, uint v2){regions[MID_MID].setRegion(u1,v1,u2,v2);}
    void setMidRight(uint u1, uint v1, uint u2, uint v2){regions[MID_RIGHT].setRegion(u1,v1,u2,v2);}

    void setBotLeft (uint u1, uint v1, uint u2, uint v2){regions[BOT_LEFT].setRegion(u1,v1,u2,v2);}
    void setBotMid  (uint u1, uint v1, uint u2, uint v2){regions[BOT_MID].setRegion(u1,v1,u2,v2);}
    void setBotRight(uint u1, uint v1, uint u2, uint v2){regions[BOT_RIGHT].setRegion(u1,v1,u2,v2);}


    void setPosition(float x, float y)
    {
        this.x = x;
        this.y = y;
    }

}

private enum : ulong
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