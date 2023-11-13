module hip.systems.timer_manager;
public import hip.api.systems.timer;

extern class HipTimerManager
{
    static IHipTimer addTimer(IHipTimer timer);
    static IHipTimer addRenderTimer(IHipTimer timer);
    static bool isPaused(){return _isPaused;}
    static void setPaused(bool shouldPause);
    static void setAccelerationFactor(float factor);
    static float getAccelerationFactor();
}

