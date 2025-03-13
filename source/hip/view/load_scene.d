module hip.view.load_scene;
import hip.view.scene;
import hip.api.view.scene;
import hip.graphics.g2d.renderer2d;
import hip.assetmanager;


private __gshared
{
    HipColor fgColor = color(50, 200, 20);
    HipColor bgColor = color(40,40,40);

}

class LoadingScene: AScene
{
    mixin Preload;
    int x, y;
    private float percentage = 0;
    private int width, height, borderSize;
    int assetsToLoad;

    override void initialize()
    {
        Viewport vp = getCurrentViewport();
        int[2] window = [vp.width, vp.height];
        width = cast(int)(window[0] * 0.8);
        height = cast(int)(window[1] / 8);
        borderSize = cast(int)(window[0] * 0.05);
        x = (window[0] / 2) - (width / 2);
        y = (window[1] / 2) - (height / 2);

        assetsToLoad = HipAssetManager.getAssetsToLoadCount();
    }

    override void update(float dt)
    {
        setPercentage(cast(float)(assetsToLoad - HipAssetManager.getAssetsToLoadCount()) / assetsToLoad);
    }

    /** 
     * Percentage must be a value between 0 and 1
     */
    void setPercentage(float percentage)
    {
        import hip.math.utils;
        this.percentage = clamp(percentage, 0, 1);
    }

    override void render()
    {
        fillRectangle(x, y, width, height, bgColor);

        int halfB = borderSize/2;
        fillRectangle(x+halfB, y+halfB, cast(int)((width-borderSize)*percentage), (height - borderSize), fgColor);

        drawRectangle(x+halfB, y+halfB, (width-borderSize), (height - borderSize), fgColor);

        String s = String("Loaded: ", assetsToLoad - HipAssetManager.getAssetsToLoadCount(), "/", assetsToLoad);
        drawText(s.toString, x, y, 1, HipColor.yellow, HipTextAlign.topCenter, Size(width, height));


    }

    override void onResize(uint width, uint height){}
    override void dispose(){}
}