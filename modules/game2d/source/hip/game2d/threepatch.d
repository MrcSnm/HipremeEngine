module hip.game2d.threepatch;

public import hip.api.renderer.texture;
public import hip.game2d.sprite;
import hip.game2d.renderer_data;
import hip.api.data.textureatlas;

enum ThreePatchOrientation
{
    horizontal,
    vertical,
    inferred
}


final class ThreePatch
{
    int x, y;
    int width, height;
    HipSpriteVertex[4*3] vertices;
    HipSprite[3] sprites;
    protected ThreePatchOrientation orientation = ThreePatchOrientation.inferred;

    protected this(IHipTexture tex, ThreePatchOrientation o)
    {
        foreach(i; 0..3)
        {
            sprites[i] = new HipSprite(tex);
            sprites[i].setOrigin(0,0);
        }
        this.orientation = o == ThreePatchOrientation.inferred ? infer(tex) : o;
    }

    pragma(inline) ThreePatchOrientation getOrientation()
    {
        return orientation;
    }
    void setOrientation(ThreePatchOrientation ori = ThreePatchOrientation.horizontal)
    {
        if(ori == ThreePatchOrientation.inferred)
            ori = infer(this.sprites[0].getTexture);
        if(ori != orientation)
        {
            orientation = ori;
            build();
        }
    }

    /**
     *
     * Params:
     *   rects = The regions that is used as reference for this three patch
     *   tex = Texture reference for the regions
     *   width = Width of the resulting threepatch
     *   height = Height of the resulting threepatch
     *   o = Orientation of the threepatch, default is inferred.
     * Returns:
     */
    static ThreePatch fromQuads(AtlasRect[3] rects, IHipTexture tex, int width, int height,  ThreePatchOrientation o = ThreePatchOrientation.inferred)
    {
        ThreePatch t = new ThreePatch(tex, o);
        AtlasSize sz = AtlasSize(tex.getWidth, tex.getHeight);
        foreach(i; 0..3)
            t.sprites[i].setRegion(rects[i].toQuad(sz));
        t.setSize(width, height);
        return t;
    }

    /**
     *
     * Params:
     *   tex = Takes a texture, divide it into 3 [depending on orientation], and assemble the threepatch
     *   width = Width of the resulting texture
     *   height = Height of the resulting texture
     *   o = Orientation of the threepatch, default is inferred.
     * Returns:
     */
    static ThreePatch fromTexture(IHipTexture tex, int width, int height, ThreePatchOrientation o = ThreePatchOrientation.inferred)
    {
        ThreePatch ret = new ThreePatch(tex, o);

        int w = tex.getWidth;
        int h = tex.getHeight;

        if(o == ThreePatchOrientation.inferred)
            o = w >= h ? ThreePatchOrientation.horizontal : ThreePatchOrientation.vertical;

        if(o == ThreePatchOrientation.horizontal)
        {
            float rw = cast(float)w/3;
            ret.sprites[0].setRegion(0, 0, rw, 1.0);
            ret.sprites[1].setRegion(rw, 0, rw*2, 1.0);
            ret.sprites[2].setRegion(rw*2, 0, rw*3, 1.0);
        }
        else
        {
            float rh = cast(float)h/3;
            ret.sprites[0].setRegion(0, 0, rh, 1.0);
            ret.sprites[1].setRegion(rh, 0, rh*2, 1.0);
            ret.sprites[2].setRegion(rh*2, 0, rh*3, 1.0);
        }
        ret.setSize(width, height);
        return ret;
    }

    void setSize(int width, int height)
    {
        this.width = width;
        this.height = height;
        build();
    }

    protected void updatePosition()
    {
        if(getOrientation == ThreePatchOrientation.horizontal)
        {
            sprites[0].setPosition(x, y);
            sprites[1].setPosition(x+sprites[0].width, y);
            sprites[2].setPosition(x+width - (sprites[2].width),  y);
        }
        else
        {
            sprites[0].setPosition(x, y);
            sprites[1].setPosition(x, y + sprites[0].getHeight);
            sprites[2].setPosition(x, y + height - sprites[2].height);
        }
    }

    void build()
    {
        import hip.api;
        updatePosition();
        if(getOrientation == ThreePatchOrientation.horizontal)
        {
            int spWidth = sprites[0].getWidth+sprites[2].getWidth;
            float xScalingFactor = cast(float)(width - spWidth) / sprites[1].getWidth;
            sprites[1].setScale(xScalingFactor, 1);
        }
        else
        {
            int spHeight = sprites[0].getHeight+sprites[2].getHeight;
            float yScalingFactor = cast(float)(height - spHeight) / sprites[1].getHeight;

            sprites[1].setScale(1, yScalingFactor);
        }


    }

    void draw()
    {
        import hip.api;
        foreach(sp; sprites)
            sp.draw;
    }

    

    void setPosition(int x, int y)
    {
        this.x = x;
        this.y = y;
        updatePosition();
    }

    ref HipSpriteVertex[4*3] getVertices(){return vertices;}

}

private ThreePatchOrientation infer(int width, int height){return width > height ? ThreePatchOrientation.horizontal : ThreePatchOrientation.vertical;}
private ThreePatchOrientation infer(const IHipTexture tex){return tex.getWidth > tex.getHeight ? ThreePatchOrientation.horizontal : ThreePatchOrientation.vertical;}


/**
*     0  1  2 
*    ________
*   |________|
*
*
*    ___
*   |   | 0
*   |   | 1
*   |___| 2
*/