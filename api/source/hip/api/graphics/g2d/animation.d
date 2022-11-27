module hip.api.graphics.g2d.animation;
public import hip.api.renderer.texture;
public import hip.api.graphics.color;

/**
*   The frame user is responsible for using the frame properties, while the track is responsible
*   for returning the correct frame
*/
struct HipAnimationFrame
{
    IHipTextureRegion region;
    HipColor color = HipColor(1,1,1,1);
    ///X, Y
    float[2] offset = [0,0];

    version(Have_util)
    {
        public import hip.util.data_structures:Array2D, Array2D_GC;
        static HipAnimationFrame[] fromTextureRegions(Array2D!IHipTextureRegion reg, uint startY, uint startX, uint endY, uint endX)
        {
            HipAnimationFrame[] ret;

            for(int i = startY; i <= endY; i++)
                for(int j = startX; j <= endX; j++)
                    ret~= HipAnimationFrame(reg[i,j]);
            return ret;
        }
        static HipAnimationFrame[] fromTextureRegions(Array2D_GC!IHipTextureRegion reg, uint startY, uint startX, uint endY, uint endX)
        {
            HipAnimationFrame[] ret;

            for(int i = startY; i <= endY; i++)
                for(int j = startX; j <= endX; j++)
                    ret~= HipAnimationFrame(reg[i,j]);
            return ret;
        }
    }

}

interface IHipAnimationTrack
{   
    string name() const;
    bool looping() const;
    bool looping(bool setLooping);
    bool reverse() const;
    bool reverse(bool setReverse);
    ///Returns how many seconds the animation lasts
    float getDuration() const;

    IHipAnimationTrack addFrames(HipAnimationFrame[] frame...);
    IHipAnimationTrack addFrames(IHipTextureRegion[] regions...);
    version(Have_util)
    {
        import hip.util.data_structures:Array2D_GC;
        final IHipAnimationTrack addFrames(Array2D_GC!IHipTextureRegion sheet)
        {
            scope IHipTextureRegion[] regions;
            for(int y = 0; y < sheet.getHeight; y++)
                for(int x = 0; x < sheet.getWidth; x++)
                    regions~= sheet[y,x];
            return addFrames(regions);
        }
    }
    void reset();
    void setFrame(uint frame);
    void setFramesPerSecond(uint framesPerSecond);
    HipAnimationFrame* getFrameForTime(float time);
    HipAnimationFrame* getFrameForProgress(float progress);
    HipAnimationFrame* update(float deltaTime);
}

interface IHipAnimation
{
    IHipAnimationTrack getCurrentTrack();
    HipAnimationFrame* getCurrentFrame();
    final IHipTextureRegion getCurrentRegion()
    {
        HipAnimationFrame* frame = getCurrentFrame();
        if(frame == null)
            return null;
        return frame.region;
    }
    final string getCurrentTrackName() {return getCurrentTrack().name;}
    IHipAnimation addTrack(IHipAnimationTrack track);
    void update(float deltaTime);
    void setTimeScale(float scale);
    void play(string trackName);
    IHipAnimationTrack getTrack(string rtackName);
    
}