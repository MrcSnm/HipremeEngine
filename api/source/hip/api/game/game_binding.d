module hip.api.game.game_binding;
import hip.api.internal;
public import hip.api.graphics.g2d.animation;

version(Script) void initGameAPI()
{
    loadClassFunctionPointers!(HipGameUtils, "HipGameUtils");
    import hip.api.console;
    log("HipengineAPI: Initialized GameUtils");
}


extern(System)
{
    class HipGameUtils
    {
        @disable this();
        static void function(int x, int y, IHipAnimationTrack track, float anchorX = 0.5, float anchorY = 0.5) playAnimationAtPosition;
    }
}