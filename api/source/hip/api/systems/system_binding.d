module hip.api.systems.system_binding;
import hip.api.internal;

public import hip.api.systems.timer;

private alias thisModule = __traits(parent, {});

void initTimerAPI()
{
    version(Script)
    {
        loadClassFunctionPointers!(HipTimerManager, "HipTimerManager");
    }
}


extern(System)
{
    class HipTimerManager
    {
        @disable this();
        static IHipTween function(IHipTween tween) addTween;
        static IHipTimer function(IHipTimer timer) addTimer;
        static IHipTimer function(IHipTimer timer) addRenderTimer;
        static bool function() isPaused;
        static void function(bool shouldPause) setPaused;
        static void function(float factor) setAccelerationFactor;
        static float function() getAccelartionFactor;
    }
}