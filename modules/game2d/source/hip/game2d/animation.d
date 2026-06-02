module hip.game2d.animation;
import hip.error.handler;
import hip.assets.textureatlas;
import hip.api.graphics.color;
import hip.api.renderer.texture : IHipTextureRegion;



/**
*   The frame user is responsible for using the frame properties, while the track is responsible
*   for returning the correct frame
*/
struct HipAnimationFrame
{
    IHipTextureRegion region;
    HipColor color = HipColor.white;
    ///X, Y
    float[2] offset = [0,0];

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

enum HipAnimationLoopingMode : ubyte
{
    none,
    reset,
    pingpong
}

/**
*   This class uses multiplication for selecting the current frame, so, depending on the frame rate, it can cause
*   frame skipping, for giving better freedom for speeding up animation
*/
class HipAnimationTrack
{
    private immutable string _name;

    protected HipAnimationFrame[] frames;
    protected float accumulator = 0;

    ///Internal state management
    protected uint framesPerSecond = 0;
    protected uint currentFrame = 0;

    ///Micro optimization for not doing frames.length - 1 every time
    private uint lastFrame = 0;

    //Those three are a question if they should be in the track or in the animation controller
    protected bool isPlaying = false;
    protected bool isAdvancingForward = true;
    protected HipAnimationLoopingMode _loopingMode;
    protected bool _reverse  = false;

    this(string trackName, uint framesPerSecond, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none)
    {
        this._name = trackName;
        setFramesPerSecond(framesPerSecond);
        _loopingMode = loopingMode;
    }
    string name() const => _name;
    HipAnimationLoopingMode loopingMode() const =>  _loopingMode;
    HipAnimationLoopingMode loopingMode(HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.reset) => _loopingMode = loopingMode;
    bool reverse() const => _reverse;
    bool reverse(bool setReverse) => _reverse = setReverse;
    float getDuration() const => cast(float)frames.length / framesPerSecond;


    static HipAnimationTrack fromAtlas(IHipTextureAtlas atlas, string trackName, uint framesPerSecond, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none)
    {
        HipAnimationTrack track =  new HipAnimationTrack(trackName, framesPerSecond, loopingMode);
        track.addFrames(atlas.animations[trackName]);
        return track;
    }

    /**
    *   Use this version if you wish a more custom frame
    */
    HipAnimationTrack addFrames(HipAnimationFrame[] frame...)
    {
        frames~= frame;
        if(frames.length > 0)
            lastFrame = cast(typeof(lastFrame))frames.length - 1;
        return this;
    }

    HipAnimationTrack addFrames(AtlasFrame[] atlasFrames...)
    {
        int length = cast(int)frames.length;
        frames.length += atlasFrames.length;
        foreach(r; atlasFrames)
            frames[length++] = HipAnimationFrame(r);
        if(frames.length > 0)
            lastFrame = cast(typeof(lastFrame))frames.length - 1;
        return this;
    }

    HipAnimationTrack addFrames(IHipTextureRegion[] regions...)
    {
        int length = cast(int)frames.length;
        frames.length += regions.length;
        foreach(r; regions)
            frames[length++] = HipAnimationFrame(r);
        if(frames.length > 0)
            lastFrame = cast(typeof(lastFrame))frames.length - 1;
        return this;
    }
    void reset(){currentFrame = 0;accumulator = 0;}
    void setFrame(uint frame)
    {
        accumulator = frame*(1.0f/framesPerSecond);
        currentFrame = frame;
    }
    void setFramesPerSecond(uint fps){framesPerSecond = fps;}

    HipAnimationFrame* getFrameForTime(float time)
    {
        uint frame = (cast(uint)time*framesPerSecond);
        if(frame > lastFrame)
            frame = lastFrame;
        if(_reverse)
            frame = lastFrame - frame;
        return &frames[frame];
    }

    HipAnimationFrame* getFrameForProgress(float progress)
    {
        uint frame = cast(uint)(progress*frames.length);
        if(frame > lastFrame)
            frame = lastFrame;
        if(_reverse)
            frame = lastFrame - frame;
        return &frames[frame];
    }

    HipAnimationFrame* update(float dt)
    {
        if(frames.length == 0)
            return null;
        accumulator+= dt;
        uint frame = cast(uint)(accumulator*framesPerSecond);
        if(frame > lastFrame)
        {
            final switch(_loopingMode) with(HipAnimationLoopingMode)
            {
                case reset:
                    accumulator = 0;
                    frame = 0;
                    break;
                case pingpong:
                    frame = 0;
                    accumulator = 0;
                    isAdvancingForward = !isAdvancingForward;
                    break;
                case none:
                    accumulator-=dt;
                    frame = lastFrame;
                    break;
            }
        }
        if((_loopingMode == HipAnimationLoopingMode.pingpong && !isAdvancingForward) || 
        (_reverse && _loopingMode != HipAnimationLoopingMode.pingpong))
            frame = lastFrame - frame;
        currentFrame = frame;
        return &frames[frame];
    }
    
}

/**
*   Currently used as a wrapper for holding animation tracks. Could probably do
*   advanced work as setting track markers for playing tracks sequentially. Setting general animation
*   speed 
*/
final class HipAnimation
{
    protected HipAnimationTrack[string] tracks;
    immutable string name;
    protected float timeScale;
    protected HipAnimationTrack currentTrack;
    protected HipAnimationFrame* currentFrame;


    this(string name, HipAnimationTrack[] tracks...)
    {
        this.name = name;
        this.timeScale = 1.0f;
        foreach(t; tracks)
            addTrack(t);
    }

    static HipAnimation fromAtlas(HipTextureAtlas atlas, string which, uint fps, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none)
    {
        import hip.util.string:SmallString;
        HipAnimation ret = new HipAnimation(which);
        HipAnimationTrack track = new HipAnimationTrack(which, fps, loopingMode);

        //Per image based.
        AtlasFrame* frame;
        int i = 1;
        do {
            SmallString animName = SmallString(which, "_", i);
            frame = animName.toString in atlas;
            if(frame != null)
            {
                track.addFrames(HipAnimationFrame(frame.region));
                i++;   
            }
        } while(frame != null);

        AtlasFrame[]* frames = which in atlas.animations;
        if(frames)
            track.addFrames(*frames);
        ret.addTrack(track);

        return ret;
    }

    HipAnimation addTrack(HipAnimationTrack track)
    {
        if(currentTrack is null)
        {
            currentTrack = track;
            update(0);//Updates the current frame
        }
        ErrorHandler.assertExit((track.name in tracks) == null,
        "Track named "~track.name~" is already on animation '"~name~"'");
        tracks[track.name] = track;
        return this;
    }
    HipAnimationTrack getCurrentTrack() {return currentTrack;}
    HipAnimationFrame* getCurrentFrame() {return currentFrame;}

    IHipTextureRegion getCurrentRegion()
    {
        HipAnimationFrame* frame = getCurrentFrame();
        if(frame == null)
            return null;
        return frame.region;
    }

    string getCurrentTrackName() {return getCurrentTrack().name;}
    void setTimeScale(float scale){timeScale = scale;}
    void play(string trackName)
    {
        HipAnimationTrack* track = trackName in tracks;
        version(HipOptimize){}
        else
            ErrorHandler.assertLazyExit(track != null,
                "Track "~trackName~" does not exists in the animation '"~name~"'.");

        if(currentTrack !is null)
            currentTrack.reset();
        currentTrack = *track;
        update(0); //Updates the current frame
    }

    HipAnimationTrack getTrack(string trackName)
    {
        HipAnimationTrack* track = trackName in tracks;
        if(track is null) return null;
        return *track;
    }


    void update(float dt)
    {
        if(currentTrack is null)
            return;
        currentFrame = currentTrack.update(dt*timeScale);
    }

    /**
    *   Creates an HipAnimation from a loaded texture atlas.
    *   Its frames will be checked such as `mySprite${frameNumber}`.
    *   The animation will be named as the string without the number.
    */
    static HipAnimation createFromAtlas(IHipTextureAtlas atlas, string animationName, uint framesPerSecond = 24)
    {
        import hip.util.string:getNumericEnding, lastIndexOf;
        import hip.util.algorithm;
        import hip.api;
        import std.algorithm:sort;

        HipAnimation anim = new HipAnimation(animationName);
        foreach(string frameName; sort(atlas.frames.keys))
        {
            AtlasFrame* frame = frameName in atlas;
            string name = frameName;
            int index = frameName.lastIndexOf(frameName.getNumericEnding);
            if(index != -1)
                name = frameName[0..index];
            HipAnimationTrack track = anim.getTrack(name);
            if(track is null)
            {
                anim.addTrack(track = new HipAnimationTrack(name, framesPerSecond, HipAnimationLoopingMode.reset));
            }
            track.addFrames(HipAnimationFrame(frame.region, HipColor.white, [0,0]));
        }
        return anim;
    }
}