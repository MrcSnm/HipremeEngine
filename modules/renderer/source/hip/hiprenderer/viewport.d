/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.viewport;
import hip.math.vector;
import hip.math.scaling;
import hip.hiprenderer.renderer;
import hip.math.rect;

public class Viewport
{
    Rect bounds;
    this(){}

    this(int x, int y, int width, int height)
    {
        this.setBounds(x,y,width,height);
    }

    void setAsCurrentViewport()
    {
        HipRenderer.setViewport(this);
    }

    void setPosition(int x, int y)
    {
        bounds.x=x;
        bounds.y=y;
    }
    void setBounds(int x, int y, int width, int height)
    {
        bounds.x=x;
        bounds.y=y;
        bounds.w=width;
        bounds.h=height;
        sanityCheck();
    }
    void update()
    {
        this.setSize(cast(int)this.w, cast(int)this.h);
        if(HipRenderer.getCurrentViewport() == this)
            this.setAsCurrentViewport();
    }
    void setSize(int width, int height)
    {
        this.w = width;
        this.h = height;
        sanityCheck();
    }
    protected void sanityCheck()
    {
        assert(width > 0, "Can't have viewport with width less than 0");
        assert(height > 0, "Can't have viewport with height less than 0");
    }
    alias bounds this;
}

public class FitViewport : Viewport
{
    int worldWidth, worldHeight;    
    this(int x, int y, int worldWidth, int worldHeight)
    {
        super(x, y, worldWidth,worldHeight);
        this.worldWidth = worldWidth;
        this.worldHeight = worldHeight;
        this.setSize(worldWidth, worldHeight);
    }
    this(int worldWidth, int worldHeight){this(0,0,worldWidth,worldHeight);}
    override void setSize(int width, int height)
    {
        this.worldWidth = worldWidth;
        this.worldHeight = worldHeight;
        Vector2 scale = Scaling.fit(width, height, HipRenderer.width, HipRenderer.height);
        this.setBounds(
            (HipRenderer.width - cast(int)scale.x)/2,
            (HipRenderer.height- cast(int)scale.y)/2,
            cast(int)scale.x, cast(int)scale.y
        );
        sanityCheck();
    }
}