module view.soundtestscene;
import data.hipfs;
import implementations.audio.audio;
import audio.audio;
import view.scene;

import bindbc.openal;
class SoundTestScene : Scene
{
    HipAudioSource sc;
    this()
    {
        import def.debugging.log;
        
        HipAudioBuffer buf = HipAudio.loadStreamed("assets/audio/the-sound-of-silence.wav", (ushort.max+1));
        uint alBuffer;
        alGenBuffers(1,&alBuffer);
        uint src;
        alGenSources(1, &src);

        alBufferData(alBuffer, HipAudio.getConfig.getFormatAsOpenAL, buf.outBuffer, (ushort.max+1), 22050);
        alSourceQueueBuffers(src, 1, &alBuffer);
        alSourcePlay(src);

        rawlog(buf.getDecodedDuration);
        // for(int i =0; i < 5000; i++)
        // {
        //     buf.updateStream();
        //     HipAudio.updateStream(src);
        // }
        // import implementations.audio.backend.openal.buffer;
        // HipOpenALBuffer alBuf = cast(HipOpenALBuffer)buf;
        // HipAudio.play_streamed(src);
        // rawlog(buf.getDuration());
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