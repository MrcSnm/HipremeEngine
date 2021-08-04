module graphics.g2d.viewport;
import math.vector;
import math.scaling;
import implementations.renderer.renderer;
import bindbc.sdl;

public class Viewport
{
    SDL_Rect bounds;
    this(){}

    this(int x, int y, uint width, uint height)
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
    void setBounds(int x, int y, uint width, uint height)
    {
        bounds.x=x;
        bounds.y=y;
        bounds.w=width;
        bounds.h=height;
    }
    void setSize(uint width, uint height)
    {
        this.w = width;
        this.h = height;
    }
    alias bounds this;
}

public class FitViewport : Viewport
{
    this(int x, int y, uint worldWidth, uint worldHeight)
    {
        super();
        this.setSize(worldWidth, worldHeight);
    }
    this(int worldWidth, int worldHeight){this(0,0,worldWidth,worldHeight);}
    override void setSize(uint width, uint height)
    {
        Vector2 scale = Scaling.fit(width, height, HipRenderer.width, HipRenderer.height);
        this.setBounds(
            (HipRenderer.width - cast(int)scale.x)/2,
            (HipRenderer.height- cast(int)scale.y)/2,
            cast(uint)scale.x, cast(uint)scale.y
        );
    }
}