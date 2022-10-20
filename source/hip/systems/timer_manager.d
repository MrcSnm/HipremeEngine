module hip.systems.timer_manager;
import hip.util.reflection;
import hip.console.log;
public import hip.timer;
public import hip.tween;

class HipTimerManager
{
    @disable this();
    private static IHipTimer[] timers;
    private static IHipTween[] tweens;
    private static bool _isPaused = false;
    private static float accelerationFactor = 1.0f;

    @ExportD static IHipTween addTween(IHipTween tween)
    {
        tweens~= tween.play();
        return tween;
    }

    @ExportD static IHipTimer addTimer(IHipTimer timer)
    {
        timers~= timer.play();
        return timer;
    }

    @ExportD static bool isPaused(){return _isPaused;}
    @ExportD static void setPaused(bool shouldPause)
    {
        _isPaused = shouldPause;
    }

    @ExportD static void setAccelerationFactor(float factor){accelerationFactor = factor;}
    @ExportD static float getAccelartionFactor(){return accelerationFactor;}

    /**
    *   This functions is used in development mode (should clear all the schedule after a hotreload)
    */
    static void clearSchedule()
    {
        timers.length = 0;
        tweens.length = 0;
    }

    static void update(float delta)
    {
        if(_isPaused)
            return;
        delta*= accelerationFactor;
        int count = 0;
        foreach(timer; timers)
        {
            count+= cast(int)timer.tick(delta);
        }
        if(count && count == timers.length)
        {
            timers.length = 0;
        }
        count = 0;

        foreach(tween; tweens)
        {
            count+= cast(int)tween.tick(delta);
        }
        if(count && count == tweens.length)
        {
            tweens.length = 0;
        }
    }
}