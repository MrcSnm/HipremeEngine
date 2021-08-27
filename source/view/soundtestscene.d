module view.soundtestscene;
import data.hipfs;
import hipaudio.audio;
import hipaudio.backend.openal.source;
import data.audio.audio;
import view.scene;

class SoundTestScene : Scene
{
    HipAudioSource src;
    this()
    {
        import console.log;

        HipAudioBuffer buf = HipAudio.load("audio/wind-sfx.mp3", HipAudioType.SFX);
        src = HipAudio.getSource(false, buf);
        HipAudio.play(src);
        
        // HipAudioBuffer buf = HipAudio.loadStreamed("assets/audio/junkyard-a-class.mp3", (ushort.max+1));
        // src = HipAudio.getSource(true, buf);
        // src.pullStreamData();
        // src.pullStreamData();

        // HipAudio.play_streamed(src);


    }

    override void render()
    {
        import console.log;
        // auto s = cast(HipOpenALAudioSource)src;
        // int b = s.getFreeBuffer();
        // if(b != 0)
        // {
        //     src.pullStreamData();
        // }
        // rawlog(sc.isPlaying);
    }
}