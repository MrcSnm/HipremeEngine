module hip.api.renderer.viewport;


enum ViewportType
{
    default_,
    fit
}

class Viewport
{
    int x, y, width, height;
    ViewportType type;
    int worldWidth, worldHeight;
    this(int x, int y, int width, int height)
    {
        setBounds(x, y, width, height);
        type = ViewportType.default_;
        setWorldSize(width, height);
    }
    void setBounds(int x, int y, int width, int height)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }
    void setWorldSize(int worldWidth, int worldHeight)
    {
        this.worldWidth = worldWidth;
        this.worldHeight = worldHeight;
    }
}
