module view.soundtestscene;
import data.hipfs;
import implementations.audio.audio;
import implementations.audio.backend.openal.source;
import audio.audio;
import view.scene;

class SoundTestScene : Scene
{
    HipAudioSource src;
    this()
    {
        import def.debugging.log;

        HipAudioBuffer buf = HipAudio.load("audio/the-sound-of-silence.wav", HipAudioType.SFX);
        src = HipAudio.getSource(false, buf);
        HipAudio.play(src);
        
        // HipAudioBuffer buf = HipAudio.loadStreamed("assets/audio/the-sound-of-silence.wav", (ushort.max+1));
        // src = HipAudio.getSource(true, buf);
        // src.pullStreamData();
        // src.pullStreamData();

        // HipAudio.play_streamed(src);


    }

    override void render()
    {
        import def.debugging.log;
        // auto s = cast(HipOpenALAudioSource)src;
        // int b = s.getFreeBuffer();
        // if(b != 0)
        // {
        //     src.pullStreamData();
        // }
        // rawlog(sc.isPlaying);
    }
}