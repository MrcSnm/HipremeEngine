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
    void setProperties(string name, float durationSeconds, HipTimerType type, bool loops)
    {
        this.name = name;
        this.durationSeconds = durationSeconds;
        this.type = type;
        this.loops = loops;
        assert(type == HipTimerType.oneShot || type == HipTimerType.progressive, "Invalid timer type");
        isRunning = false;
        accumulator = 0;
        loopCount = 0;
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
    bool tick (float dt)
    {
        import std.stdio;
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

class HipSequence : HipTimer, IHipTimerList
{
    protected IHipTimer[] timerList;
    protected uint listCursor;
    protected float cursorDuration = 0;
    protected float listAccumulator = 0;
    protected void delegate()[] onFinishList;

    this(string name = "Sequence", scope IHipTimer[] timers = []...)
    {
        super(name, 0, HipTimerType.progressive);
        foreach(t;timers)
        {
            timerList~= t;
        }
        cursorDuration = timerList[0].getDuration();
        recalculateDuration();

        addHandler((prog, count)
        {
            if(accumulator - listAccumulator >= cursorDuration)
            {
                if(listCursor + 1 < timerList.length)
                {
                    //Guarantee that it finishes here
                    timerList[listCursor].tick(deltaTime);
                    cursorDuration = timerList[++listCursor].getDuration();
                    timerList[listCursor].play();
                    listAccumulator+= cursorDuration;
                }
            }
            timerList[listCursor].tick(deltaTime);
        });
    }
    override HipSequence play()
    {
        super.play();
        timerList[0].play();
        return this;
    }
    override void stop()
    {
        super.stop();
        foreach(onFinish; onFinishList)
            onFinish();
    }

    void recalculateDuration()
    {
        foreach(t;timerList)
            durationSeconds+= t.getDuration();
        setProperties(this.name, durationSeconds, HipTimerType.progressive, false);
    }
    HipSequence add(IHipTimer timer)
    {
        if(cursorDuration == 0)
            cursorDuration = timer.getDuration();
        timerList~= timer;
        recalculateDuration();
        return this;
    }
    HipSequence addOnFinish(void delegate() onFinish)
    {
        onFinishList~= onFinish;
        return this;
    }
}

class HipSpawn : HipTimer, IHipTimerList
{
    protected IHipTimer[] timerList;
    protected void delegate()[] onFinishList;

    this(string name = "Spawn", scope IHipTimer[] timers = []...)
    {
        super(name, 0, HipTimerType.progressive);
        foreach(t;timers)
        {
            timerList~= t;
        }
        recalculateDuration();
        addHandler((prog, count)
        {
            foreach(t; timerList)
                t.tick(deltaTime);
        });
    }
    override HipSpawn play()
    {
        super.play();
        foreach(t; timerList)
        {
            t.play();
        }
        return this;
    }
    protected void recalculateDuration()
    {
        float durationSeconds = 0;
        foreach(t;timerList)
        {
            if(t.getDuration() > durationSeconds)
                durationSeconds = t.getDuration();
        }
        setProperties(this.name, durationSeconds, HipTimerType.progressive, false);
    }

    override void stop()
    {
        super.stop();
        foreach(onFinish; onFinishList)
            onFinish();
    }

    HipSpawn add(IHipTimer timer)
    {
        timerList~= timer;
        recalculateDuration();
        return this;
    }

    HipSpawn addOnFinish(void delegate() onFinish)
    {
        onFinishList~= onFinish;
        return this;
    }
}