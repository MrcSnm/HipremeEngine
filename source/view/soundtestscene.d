module view.soundtestscene;
import implementations.audio.audio;
import implementations.audio.audiobase;
import view.scene;

class SoundTestScene : Scene
{
    this()
    {
        AudioBuffer buf = Audio.load("assets/audio/the-sound-of-silence.wav", AudioBuffer.TYPE.SFX);
        AudioSource sc = Audio.getSource(buf);
        Audio.setPitch(sc, 1);
        Audio.play(sc);

    }
}