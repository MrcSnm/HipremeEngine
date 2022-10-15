module hip.game.api;

import hip.game.timer;

export extern(C):

IHipTimer newTimer(string name, float durationSeconds, HipTimerCallback handler = null, HipTimerType type = HipTimerType.oneShot, bool loops = false)
{
    auto ret = new HipTimer(name, durationSeconds, type, loops);
    if(handler !is null)
        ret.addHandler(handler);
    return ret;
}