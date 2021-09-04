module graphics.g2d.animation;
import graphics.color;
import math.vector;
import hiprenderer.texture : TextureRegion;
import error.handler;

/**
*   The frame user is responsible for using the frame properties, while the track is responsible
*   for returning the correct frame
*/
struct HipAnimationFrame
{
    TextureRegion region;
    HipColor color = HipColor(1,1,1,1);
    Vector2 offset = Vector2(0,0);
}

/**
*   This class uses multiplication for selecting the current frame, so, depending on the frame rate, it can cause
*   frame skipping, for giving better freedom for speeding up animation
*/
class HipAnimationTrack
{
    immutable string name;

    protected HipAnimationFrame[] frames;
    protected float accumulator = 0;

    ///Internal state management
    protected uint framesPerSecond = 0;
    protected uint currentFrame = 0;

    ///Micro optimization for not doing frames.length - 1 every time
    private uint lastFrame = 0;

    //Those three are a question if they should be in the track or in the animation controller
    protected bool isPlaying = false;
    protected bool isLooping = false;
    protected bool isReverse = false;

    this(string name, uint framesPerSecond, bool shouldLoop)
    {
        this.name = name;
        isLooping = shouldLoop;
    }
    HipAnimationTrack addFrames(HipAnimationFrame[] frame...)
    {
        foreach(f; frame)
            frames~= f;
        lastFrame = cast(uint)(frames.length-1);
        return this;
    }
    void reset(){currentFrame = 0;accumulator = 0;}
    void setFrame(uint frame)
    {
        ErrorHandler.assertExit(frame < frames.length, "Frame is out of bounds on track "~name);
        accumulator = frame*(1.0f/framesPerSecond);
        currentFrame = frame;
    }
    void setLooping(bool looping){isLooping = looping;}
    void setReverse(bool reverse){isReverse = reverse;}
    void setFramesPerSecond(uint fps){framesPerSecond = fps;}

    HipAnimationFrame* update(float dt)
    {
        accumulator+= dt;
        uint frame = cast(uint)(accumulator*framesPerSecond);
        if(frame > lastFrame)
        {
            if(isLooping)
            {
                accumulator = 0;
                frame = 0;
            }
            else
            {
                accumulator-=dt;
                frame--;
            }
        }
        if(isReverse)
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
class HipAnimation
{
    protected HipAnimationTrack[string] tracks;
    immutable string name;
    protected float timeScale;
    protected HipAnimationTrack currentTrack;
    protected HipAnimationFrame* currentFrame;



    this(string name)
    {
        this.name = name;
        this.timeScale = 1.0f;
    }

    void addTrack(HipAnimationTrack track){tracks[track.name] = track;}

    HipAnimationTrack getCurrentTrack(){return currentTrack;}
    string getCurrentTrackName(){return currentTrack.name;}
    HipAnimationFrame* getCurrentFrame(){return currentFrame;}
    void setTimeScale(float scale){timeScale = scale;}
    void setTrack(string trackName)
    {
        ErrorHandler.assertExit((trackName in tracks) != null,
        "Track "~trackName~" does not exists in the animation '"~name~"'.");

        if(currentTrack !is null)
            currentTrack.reset();
        currentTrack = tracks[trackName];
    }


    void update(float dt)
    {
        if(currentTrack is null)
            return;
        currentFrame = currentTrack.update(dt*timeScale);
    }
}