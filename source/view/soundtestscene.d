module view.soundtestscene;
import implementations.audio.audio;
import implementations.audio.audiobase;
import audio.audio;
import view.scene;

class SoundTestScene : Scene
{
    this()
    {
        HipAudioBuffer buf = HipAudio.load("assets/audio/the-sound-of-silence.wav", HipAudioType.SFX);
        HipAudioSource sc = HipAudio.getSource(buf);
        HipAudio.setPitch(sc, 1);
        HipAudio.play(sc);

    }
}