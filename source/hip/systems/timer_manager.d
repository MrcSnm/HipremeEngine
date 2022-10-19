module hip.systems.timer_manager;
import hip.timer;
import hip.tween;

class HipTimerManager
{
    private HipTimer[] timers;
    private HipTween[] tweens;

    HipTween addTween(HipTween tween)
    {
        tweens~= tween;
        return tween;
    }

    HipTimer addTimer(HipTimer timer)
    {
        timers~= timer;
        return timer;
    }

    void update(float delta)
    {
        foreach(timer; timers)
            timer.tick(delta);
        foreach(tween; tweens)
            tween.tick(delta);
    }
}