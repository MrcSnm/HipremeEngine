module hip.api.systems.system_binding;
import hip.api.internal;
public import hip.api.systems.timer;

version(Have_hipreme_engine) version = DirectCall;
version(DirectCall){}
else
{
    void initTimerAPI()
    {
        loadClassFunctionPointers!(HipTimerManager, "HipTimerManager");
        import hip.api.console;
        log("HipengineAPI: Initialized TimerManager");
    }
    class HipTimerManager
    {
        extern(System) __gshared
        {
            @disable this();
            IHipTimer function(IHipTimer timer) addTimer;
            IHipTimer function(IHipTimer timer) addRenderTimer;
            bool function() isPaused;
            void function(bool shouldPause) setPaused;
            void function(float factor) setAccelerationFactor;
            float function() getAccelerationFactor;
        }
    }
}