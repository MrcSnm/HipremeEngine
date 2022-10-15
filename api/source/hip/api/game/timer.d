module hip.api.game.timer;

enum HipTimerType
{
    oneShot,
    progressive
}

alias HipTimerCallback = void delegate(float progress, uint loopCount);

interface IHipTimer
{
    float getDuration();
    float getProgress();
    void addHandler(HipTimerCallback handler);
    void forceFinish();
    void stop();
    void pause();
    IHipTimer play();
    void reset();
    void loopRestart();
}