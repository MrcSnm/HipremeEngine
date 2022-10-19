module hip.timer;

enum HipTimerType
{
    oneShot,
    progressive
}

alias HipTimerCallback = void delegate(float progress, uint loopCount);


version(HipTimerAPI):
class HipTimer
{
    alias TimerType = HipTimerType;
    ///Enforce naming for making debugging easier
    string name;
    protected uint loopCount = 0;
    protected bool loops = false;
    protected float deltaTime = 0;
    protected float accumulator = 0;
    protected float durationSeconds = 0;
    protected bool isRunning = false;
    protected void delegate(float progress, uint loopCount)[] handlers;
    protected TimerType type;


    this(string name, float durationSeconds, TimerType type, bool loops = false)
    {
        this.setProperties(name, durationSeconds, type, loops);
    }
    /**
    *   Perfect function for making a timer pool
    */
    void setProperties(string name, float durationSeconds, TimerType type, bool loops = false)
    {
        this.name = name;
        this.durationSeconds = durationSeconds;
        this.type = type;
        assert(type == TimerType.oneShot || type == TimerType.progressive, "Invalid timer type");
        this.loops = loops;
        stop();
    }
    float getDuration(){return durationSeconds;}
    float getProgress(){return accumulator/durationSeconds;}
    void addHandler(void delegate(float progress, uint loopCount) handler){handlers~=handler;}
    void forceFinish()
    {
        foreach (h; handlers) h(1, loopCount);
        stop();
    }

    void pause(){isRunning = false;}
    HipTimer play(){isRunning = true;return this;}
    void stop()
    {
        isRunning = false;
        accumulator = 0;
        loopCount = 0;
    }
    void reset()
    {
        stop();
        play();
    }
    void loopRestart()
    {
        loopCount++;
        accumulator = 0;
    }


    ///Returns wether it has finished
    bool tick(float dt)
    {
        if(isRunning)
        {
            this.deltaTime = dt;
            accumulator = dt+accumulator;
            if(accumulator>durationSeconds)accumulator = durationSeconds;
            switch(type)
            {
                case TimerType.oneShot:
                    if(accumulator == durationSeconds)
                    {
                        foreach(h;handlers)h(accumulator/durationSeconds, loopCount);
                        if(loops)
                            loopRestart();
                        else
                        {
                            stop();
                            return true;
                        }
                    }
                    break;
                case TimerType.progressive:
                    if(accumulator <= durationSeconds)
                    {
                        foreach(h;handlers)h(accumulator/durationSeconds, loopCount);
                        if(accumulator == durationSeconds)
                        {
                            if(loops)
                                loopRestart();
                            else
                            {
                                stop();
                                return true;
                            }
                        }
                    }
                    break;
                default:break;
            }
        }
        return false;
    }
}


