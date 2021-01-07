module graphics.g2d.viewport;
import implementations.renderer.renderer;
import bindbc.sdl;

public class Viewport
{
    SDL_Rect bounds;

    this(int x, int y, int width, int height)
    {
        this.setBounds(x,y,width,height);
    }

    void setAsCurrentViewport()
    {
        Renderer.setViewport(this);
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
    }
    alias bounds this;
}