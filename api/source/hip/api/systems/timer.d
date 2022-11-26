module hip.api.systems.timer;

enum HipTimerType
{
    oneShot,
    progressive
}

alias HipTimerCallback = void delegate(float progress, uint loopCount);

interface IHipTimer
{
    string getName();
    float getDuration();
    float getProgress();

    final bool hasFinished(){return getProgress() == 1.0f;}
    IHipTimer addHandler(void delegate() handler);
    IHipTimer addHandler(void delegate(float progress) handler);
    IHipTimer addHandler(HipTimerCallback handler);
    void forceFinish();
    void stop();
    void pause();
    ///Remember to call "play" for setting it up to tick
    IHipTimer play();
    void reset();
    void loopRestart();
    ///Returns wether it has finished
    bool tick(float deltaTime);
}

interface IHipFiniteTask
{
    IHipFiniteTask addOnFinish(void delegate() onFinish);
}

interface IHipTimerList : IHipFiniteTask
{
    IHipTimerList add(IHipTimer timer);
}
