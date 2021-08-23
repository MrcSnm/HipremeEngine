module view.soundtestscene;
import data.hipfs;
import implementations.audio.audio;
import implementations.audio.audiobase;
import audio.audio;
import view.scene;

class SoundTestScene : Scene
{
    HipAudioSource sc;
    this()
    {
        import def.debugging.log;
        HipAudioBuffer buf = HipAudio.loadStreamed("assets/audio/junkyard-a-class.mp3");
        HipAudioSource src = HipAudio.getSource(true, buf);
        for(int i =0; i < 10000; i++)
        {
            buf.updateStream();
            HipAudio.updateStream(src);
        }
        import bindbc.openal;
        rawlog(alGetError());
        HipAudio.play_streamed(src);

        HipAudio.play(src);
        rawlog(buf.getDuration());
        // import def.debugging.log;
        // rawlog(buf.getDuration());
        // sc = HipAudio.getSource(buf);
        // HipAudio.setPitch(sc, 1);
        // HipAudio.play(sc);

    }

    override void render()
    {
        import def.debugging.log;
        // rawlog(sc.isPlaying);
    }
}