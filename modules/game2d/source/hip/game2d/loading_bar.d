module hip.game2d.loading_bar;

class LoadingBar
{
    import hip.api;
    int x, y;
    private float percentage = 0;
    private int width, height, borderSize;
    HipColor fgColor, bgColor;


    this(int width, int height, int borderSize, HipColor fgColor = color(50, 200, 20), HipColor bgColor = color(40,40,40))
    {
        this.width = width;
        this.height = height;
        this.borderSize = borderSize;
        this.bgColor = bgColor;
        this.fgColor = fgColor;
    }

    static LoadingBar defaultSize(Viewport vp)
    {
        int[2] window = [vp.worldWidth, vp.worldHeight];

        LoadingBar ret = new LoadingBar(cast(int)(window[0] * 0.8), cast(int)(window[1] / 8), cast(int)(window[0] * 0.05));

        ret.x = (window[0] / 2) - (ret.width / 2);
        ret.y = (window[1] / 2) - (ret.height / 2);

        return ret;
    }

    void setPosition(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    /** 
     * Percentage must be a value between 0 and 1
     */
    void setPercentage(float percentage)
    {
        import hip.math.utils;
        this.percentage = clamp(percentage, 0, 1);
    }

    void render()
    {
        fillRectangle(x, y, width, height, bgColor);

        int halfB = borderSize/2;
        fillRectangle(x+halfB, y+halfB, cast(int)((width-borderSize)*percentage), (height - borderSize), fgColor);

        drawRectangle(x+halfB, y+halfB, (width-borderSize), (height - borderSize), fgColor);

    }
}