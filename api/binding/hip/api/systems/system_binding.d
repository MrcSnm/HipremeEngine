module hip.api.systems.system_binding;
import hip.api.internal;
public import hip.api.systems.timer;

version(ScriptAPI)
{
    void initTimerAPI()
    {
        loadClassFunctionPointers!(HipTimerManager, UseExportedClass.Yes, "HipTimerManager");
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