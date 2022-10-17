module hip.api.renderer.viewport;
public import hip.api.math.rect: Rect;


enum ViewportType
{
    default_,
    fit
}

class Viewport
{
    Rect bounds;
    ViewportType type;
    int worldWidth, worldHeight;
    this(int x, int y, int width, int height)
    {
        bounds = Rect(x, y, width, height);
        type = ViewportType.default_;
        setWorldSize(width, height);
    }
    void setBounds(int x, int y, int width, int height)
    {
        bounds = Rect(x, y, width, height);
    }
    void setWorldSize(int worldWidth, int worldHeight)
    {
        this.worldWidth = worldWidth;
        this.worldHeight = worldHeight;
    }
    alias bounds this;
}
