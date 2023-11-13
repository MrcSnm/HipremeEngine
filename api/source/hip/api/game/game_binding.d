module hip.api.game.game_binding;
import hip.api.internal;
public import hip.api.graphics.g2d.animation;

version(ScriptAPI)
{
    void initGameAPI()
    {
        loadClassFunctionPointers!(HipGameUtils, UseExportedClass.Yes, "HipGameUtils");
        import hip.api.console;
        log("HipengineAPI: Initialized GameUtils");
    }
    class HipGameUtils
    {
        extern(System) __gshared
        {
            @disable this();
            void function(int x, int y, IHipAnimationTrack track, float anchorX = 0.5, float anchorY = 0.5) playAnimationAtPosition;
        }
    }
}
