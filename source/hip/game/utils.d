module hip.game.utils;
import hip.systems.timer_manager;
import hip.util.reflection : ExportD;
import hip.graphics.g2d.renderer2d;
public import hip.graphics.g2d.animation;

class HipGameUtils
{
    /**
    *   This function will never modify the track state
    */
    @ExportD static void playAnimationAtPosition(int x, int y, IHipAnimationTrack track, float anchorX = 0.5, float anchorY = 0.5)
    {
        HipTimerManager.addRenderTimer(
            new HipTimer("Play Animation Track: "~track.name, track.getDuration(), HipTimerType.progressive)
            .addHandler((float progress)
            {
                HipAnimationFrame* frame = track.getFrameForProgress(progress);
                int x = cast(int)(frame.offset[0]+x - frame.region.getWidth() * anchorX);
                int y = cast(int)(frame.offset[1]+y + frame.region.getHeight() * anchorY);
                drawRegion(
                    frame.region, 
                    x, y,
                    0, frame.color
                );
            })
        );
    }
}