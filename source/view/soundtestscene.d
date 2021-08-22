module view.soundtestscene;
import implementations.audio.audio;
import implementations.audio.audiobase;
import audio.audio;
import view.scene;

class SoundTestScene : Scene
{
    this()
    {
        import util.libinfos;
        show_sdl_sound_info();
        HipAudioBuffer buf = HipAudio.load("audio/junkyard-a-class.mp3", HipAudioType.MUSIC);
        HipAudioSource sc = HipAudio.getSource(buf);
        HipAudio.setPitch(sc, 1);
        HipAudio.play(sc);

    }
}