module hip.game.utils;
public import hip.api.graphics.g2d.animation;


extern class HipGameUtils
{
    static void playAnimationAtPosition(int x, int y, IHipAnimationTrack track, float anchorX = 0.5, float anchorY = 0.5);
}