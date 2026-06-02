module hip.game2d.utils;
import hip.game2d.animation;

void playAnimationAtPosition(int x, int y, HipAnimationTrack track, float anchorX = 0.5, float anchorY = 0.5)
{
    import hip.api;
    import hip.game.timer;

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