module gamescript.background;
import gamescript.config;
import hip.math.utils;
import hip.api;
import hip.tween;

class Background : IHipPreloadable
{
    import std.traits:getUDAs;
    mixin Preload;
    @Asset("images/background.png")
    protected IHipTexture bkg;
    @Asset("images/background_blur.png")
    protected IHipTexture bkgBlur;

    float bkgOpacity = 1;
    float bkgBlurOpacity = 0;

    private float targetScaleRate = 1;
    
    this()
    {
        preload();
        if(bkg !is null)
        {
            targetScaleRate = max(cast(float)GAME_WIDTH / bkg.getWidth(), cast(float)GAME_HEIGHT / bkg.getHeight());
        }
    }
    void fade()
    {
        HipTimerManager.addTimer(HipTween.to!(["bkgOpacity", "bkgBlurOpacity"])(2.5, this, [0.0, 1.0]));
    }
    void draw()
    {
        if(bkg !is null)
        {
            drawTexture(bkg, 0, 0, 0, HipColor(1, 1, 1, bkgOpacity), targetScaleRate, targetScaleRate);
            drawTexture(bkgBlur, 0, 0, 0, HipColor(1, 1, 1, bkgBlurOpacity), targetScaleRate, targetScaleRate);
        }
    }    
}