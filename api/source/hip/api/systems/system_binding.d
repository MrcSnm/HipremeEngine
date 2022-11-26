module hip.api.systems.system_binding;
import hip.api.internal;

public import hip.api.systems.timer;

private alias thisModule = __traits(parent, {});

version(Script) void initTimerAPI()
{
    loadClassFunctionPointers!(HipTimerManager, "HipTimerManager");
    import hip.api.console;
    log("HipengineAPI: Initialized TimerManager");
}


extern(System)
{
    class HipTimerManager
    {
        @disable this();
        static IHipTimer function(IHipTimer timer) addTimer;
        static IHipTimer function(IHipTimer timer) addRenderTimer;
        static bool function() isPaused;
        static void function(bool shouldPause) setPaused;
        static void function(float factor) setAccelerationFactor;
        static float function() getAccelerationFactor;
    }
}