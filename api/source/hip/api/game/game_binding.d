module hip.api.game.game_binding;
import hip.api.internal;
public import hip.api.graphics.g2d.animation;
void initGameAPI()
{
    version(Script)
    {
        loadClassFunctionPointers!(HipGameUtils, "HipGameUtils");
    }
}


extern(System)
{
    class HipGameUtils
    {
        @disable this();
        static void function(int x, int y, IHipAnimationTrack track, float anchorX = 0.5, float anchorY = 0.5) playAnimationAtPosition;
    }
}