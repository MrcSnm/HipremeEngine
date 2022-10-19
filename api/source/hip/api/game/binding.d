module hip.api.game.binding;
import hip.api.internal;

public import hip.api.game.timer;

private alias thisModule = __traits(parent, {});

void initGameAPI()
{
    version(Script)
    {
        loadModuleFunctionPointers!thisModule;
    }
}


extern(System)
{
    IHipTimer function(IHipTimer timer) addTimer;
    IHipTween function(IHipTween tween) addTween;
}