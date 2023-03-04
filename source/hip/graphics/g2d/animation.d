module hip.graphics.g2d.animation;

import hip.util.reflection : ExportD;
import hip.error.handler;
import hip.assets.textureatlas;

import hip.api.graphics.color;
import hip.api.renderer.texture : IHipTextureRegion;
public import hip.api.graphics.g2d.animation;

/**
*   This class uses multiplication for selecting the current frame, so, depending on the frame rate, it can cause
*   frame skipping, for giving better freedom for speeding up animation
*/
@ExportD class HipAnimationTrack : IHipAnimationTrack
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

    /**
    *   Use this version if you wish a more custom frame
    */
    IHipAnimationTrack addFrames(HipAnimationFrame[] frame...)
    {
        foreach(f; frame)
            frames~= f;
        if(frames.length > 0)
            lastFrame = cast(typeof(lastFrame))frames.length - 1;
        return this;
    }

    IHipAnimationTrack addFrames(IHipTextureRegion[] regions...)
    {
        foreach(r; regions)
            frames~= HipAnimationFrame(r);
        if(frames.length > 0)
            lastFrame = cast(typeof(lastFrame))frames.length - 1;
        return this;
    }
    void reset(){currentFrame = 0;accumulator = 0;}
    void setFrame(uint frame)
    {
        version(HipOptimize){}
        else
            ErrorHandler.assertLazyExit(frame < frames.length, "Frame is out of bounds on track "~name);
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
@ExportD class HipAnimation : IHipAnimation
{
    protected IHipAnimationTrack[string] tracks;
    immutable string name;
    protected float timeScale;
    protected IHipAnimationTrack currentTrack;
    protected HipAnimationFrame* currentFrame;


    this(string name)
    {
        this.name = name;
        this.timeScale = 1.0f;
    }

    static HipAnimation fromAtlas(HipTextureAtlas atlas, string which, uint fps, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none)
    {
        import hip.util.conv:to;
        HipAnimation ret = new HipAnimation(which);
        HipAnimationTrack track = new HipAnimationTrack(which, fps, loopingMode);
        AtlasFrame* frame;
        int i = 1;
        while((frame = (which~"_"~to!string(i) in atlas)) != null)
        {
            track.addFrames(HipAnimationFrame(frame.region));
            i++;
        }
        ret.addTrack(track);

        return ret;
    }

    IHipAnimation addTrack(IHipAnimationTrack track)
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
    IHipAnimationTrack getCurrentTrack() {return currentTrack;}
    HipAnimationFrame* getCurrentFrame() {return currentFrame;}
    void setTimeScale(float scale){timeScale = scale;}
    void play(string trackName)
    {
        IHipAnimationTrack* track = trackName in tracks;
        version(HipOptimize){}
        else
            ErrorHandler.assertLazyExit(track != null,
                "Track "~trackName~" does not exists in the animation '"~name~"'.");

        if(currentTrack !is null)
            currentTrack.reset();
        currentTrack = *track;
        update(0); //Updates the current frame
    }

    IHipAnimationTrack getTrack(string trackName)
    {
        IHipAnimationTrack* track = trackName in tracks;
        if(track is null) return null;
        return *track;
    }


    void update(float dt)
    {
        if(currentTrack is null)
            return;
        currentFrame = currentTrack.update(dt*timeScale);
    }
}