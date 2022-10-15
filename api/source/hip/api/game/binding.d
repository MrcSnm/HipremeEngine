module hip.api.game.binding;
import hip.api.internal;

public import hip.api.game.timer;

void initGameAPI()
{
    version(Script)
    {
        loadSymbols!(
            newTimer,
            scheduleTimer
        );
    }
}


extern(System)
{
    ///Creates a timer managed by the user
    IHipTimer function (string name, float durationSeconds, HipTimerCallback handler = null, HipTimerType type = HipTimerType.oneShot, bool loops = false) newTimer;
    ///Creates a timer on the game scheduler. There will be no need to call tick()
    IHipTimer function (string name, float durationSeconds, HipTimerCallback handler = null, HipTimerType type = HipTimerType.oneShot, bool loops = false) scheduleTimer;

}