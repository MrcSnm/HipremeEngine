module implementations.audio.backend.opensles.player;
import implementations.audio.backend.audiosource;
import implementations.audio.backend.audioconfig;
import implementations.audio.audiobase;
import implementations.audio.backend.sles;
import audio.audio;
import opensles.sles;

version(Android):
class HipOpenSLESAudioPlayer : IHipAudioPlayer
{
    AudioConfig cfg;
    SLIOutputMix output;
    SLEngineItf itf;
    this(AudioConfig cfg)
    {
        this.cfg = cfg;
        sliCreateOutputContext();
    }
    public bool isMusicPlaying(HipAudioSource src){return false;}
    public bool isMusicPaused(HipAudioSource src){return false;}
    public bool resume(HipAudioSource src){return false;}
    public bool play(HipAudioSource src)
    {
        import def.debugging.log;
        rawlog(src.buffer.getBufferSize);
        SLIAudioPlayer.play(gAudioPlayer, src.buffer.getBuffer(), cast(uint)src.buffer.getBufferSize());
        return true;
    }
    public bool stop(HipAudioSource src){return false;}
    public bool pause(HipAudioSource src){return false;}

    //LOAD RELATED
    public bool play_streamed(HipAudioSource src){return false;}
    public HipAudioBuffer load(string path, HipAudioType type)
    {
        HipAudioBuffer buffer = new HipAudioBuffer(new HipSDL_SoundDecoder());
        buffer.load(path, getEncodingFromName(path), type);
        return buffer;
    }
    public HipAudioSource getSource(){return new HipAudioSource();}

    //EFFECTS
    public void setPitch(HipAudioSource src, float pitch){}
    public void setPanning(HipAudioSource src, float panning){}
    public void setVolume(HipAudioSource src, float volume){}
    public void setMaxDistance(HipAudioSource src, float dist){}
    public void setRolloffFactor(HipAudioSource src, float factor){}
    public void setReferenceDistance(HipAudioSource src, float dist){}

    public void onDestroy(){}
}