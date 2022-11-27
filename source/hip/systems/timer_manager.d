module hip.systems.timer_manager;
import hip.util.reflection;
import hip.console.log;
public import hip.timer;

class HipTimerManager
{
    @disable this();
    private __gshared IHipTimer[] timers;
    private __gshared IHipTimer[] renderTimers;
    private __gshared bool _isPaused = false;
    private __gshared float deltaTime = 0;
    private __gshared float accelerationFactor = 1.0f;


    @ExportD static IHipTimer addTimer(IHipTimer timer)
    {
        timers~= timer.play();
        return timer;
    }

    @ExportD static IHipTimer addRenderTimer(IHipTimer timer)
    {
        renderTimers~= timer.play();
        return timer;
    }

    @ExportD static bool isPaused(){return _isPaused;}
    @ExportD static void setPaused(bool shouldPause)
    {
        _isPaused = shouldPause;
    }

    @ExportD static void setAccelerationFactor(float factor){accelerationFactor = factor;}
    @ExportD static float getAccelerationFactor(){return accelerationFactor;}

    /**
    *   This functions is used in development mode (should clear all the schedule after a hotreload)
    */
    static void clearSchedule()
    {
        renderTimers.length = 0;
        timers.length = 0;
    }

    /**
    *   Update saves the delta time to be used on the render
    */
    static void update(float delta)
    {
        if(_isPaused)
            return;
        delta*= accelerationFactor;
        this.deltaTime = delta;
        int count = 0;
        foreach(timer; timers)
        {
            count+= cast(int)timer.tick(delta);
        }
        if(count && count == timers.length)
        {
            timers.length = 0;
        }
    }

    /**
    *   Rendered on top of everything.
    *   Use it as a debug renderer
    */
    static void render()
    {
        int count = 0;
        foreach(renderTimer; renderTimers)
        {
            count+= cast(int)renderTimer.tick(this.deltaTime);
        }
        if(count && count == renderTimers.length)
            renderTimers.length = 0;
    }
}