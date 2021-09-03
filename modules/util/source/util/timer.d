module util.timer;
class HipTimer
{
    enum TimerType
    {
        oneShot,
        progressive,
    }
    ///Enforce naming for making debugging easier
    string name;
    protected uint loopCount;
    protected bool loops;
    protected float accumulator;
    protected float durationSeconds;
    protected bool isRunning;
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
        this.loops = loops;
        stop();
    }
    void addHandler(void delegate(float progress, uint loopCount) handler){handlers~=handler;}
    void forceFinish()
    {
        foreach (h; handlers) h(1, loopCount);
        stop();
    }

    void pause(){isRunning = false;}
    void play(){isRunning = true;}
    void stop()
    {
        isRunning = false;
        accumulator = 0;
        loopCount = 0;
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
            accumulator = dt+accumulator;
            if(accumulator>durationSeconds)accumulator = durationSeconds;
            final switch(type)
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
            }
        }
        return false;
    }


}