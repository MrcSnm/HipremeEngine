module hip.timer;
public import hip.api.systems.timer;

version(HipTimerAPI):
class HipTimer : IHipTimer
{
    ///Enforce naming for making debugging easier
    string name;
    protected uint loopCount = 0;
    protected bool loops = false;
    protected float deltaTime = 0;
    protected float accumulator = 0;
    protected float durationSeconds = 0;
    protected bool isRunning = false;
    protected void delegate(float progress, uint loopCount)[] handlers;
    protected HipTimerType type;

    /**
    *   Call `addHandler` after creation for adding what to do
    */
    this(string name, float durationSeconds, HipTimerType type = HipTimerType.oneShot, bool loops = false)
    {
        this.setProperties(name, durationSeconds, type, loops);
    }
    /**
    *   Perfect function for making a timer pool
    */
    void setProperties(string name, float durationSeconds, HipTimerType type, bool loops = false)
    {
        this.name = name;
        this.durationSeconds = durationSeconds;
        this.type = type;
        assert(type == HipTimerType.oneShot || type == HipTimerType.progressive, "Invalid timer type");
        this.loops = loops;
        stop();
    }
    string getName(){return name;}
    float getDuration(){return durationSeconds;}
    float getProgress()
    {
        if(durationSeconds == 0 || accumulator >= durationSeconds)
            return 1.0;
        return accumulator/durationSeconds;
    }
    HipTimer addHandler(void delegate() handler)
    {
        handlers~=(prog, count){handler();};
        return this;
    }
    HipTimer addHandler(void delegate(float progress) handler)
    {
        handlers~=(prog, count){handler(prog);};
        return this;
    }
    HipTimer addHandler(void delegate(float progress, uint loopCount) handler)
    {
        handlers~=handler;
        return this;
    }
    void forceFinish()
    {
        foreach (h; handlers) h(1, loopCount);
        stop();
    }

    void pause(){isRunning = false;}
    HipTimer play()
    {
        if(durationSeconds == 0)
            forceFinish();
        else
            isRunning = true;
        return this;
    }
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

    private void executeHandlers()
    {
        foreach(h;handlers)h(getProgress(), loopCount);
    }
    private bool checkLoops()
    {
        if(loops)
        {
            loopRestart();
            return false;
        }
        stop();
        return true;
    }


    ///Returns wether it has finished
    bool tick(float dt)
    {
        if(isRunning)
        {
            this.deltaTime = dt;
            accumulator+= dt;
            switch(type)
            {
                case HipTimerType.oneShot:
                    if(accumulator >= durationSeconds)
                    {
                        executeHandlers();
                        return checkLoops();
                    }
                    break;
                case HipTimerType.progressive:
                    executeHandlers();
                    if(accumulator >= durationSeconds)
                        return checkLoops();
                    break;
                default:break;
            }
        }
        return false;
    }
}


