module implementations.audio.audiobase;
import implementations.audio.backend.audiosource;

public abstract class AudioBuffer
{
    enum TYPE
    {
        SFX,
        MUSIC
    }
    /**
    *   Should implement the specific loading here
    */
    public abstract bool load(string audioPath, TYPE audioType, bool isStreamed = false);
    public abstract void unload();

    public final bool defaultLoad(string audioPath, TYPE audioType, bool isStreamed = false)
    {
        bufferType = audioType;
        fullPath = audioPath;
        this.isStreamed = isStreamed;
        return load(audioPath, audioType, isStreamed);
    }

    TYPE bufferType;
    bool isStreamed;
    string fullPath;
    string fileName;

}


public interface IAudio
{
    //COMMON TASK
    public bool isMusicPlaying(AudioSource src);
    public bool isMusicPaused(AudioSource src);
    public bool resume(AudioSource src);
    public bool play(AudioSource src);
    public bool stop(AudioSource src);
    public bool pause(AudioSource src);

    //LOAD RELATED
    public bool play_streamed(AudioSource src);
    public AudioBuffer load(string path, AudioBuffer.TYPE bufferType);
    public AudioSource getSource();
    public final AudioBuffer loadMusic(string mus){return load(mus, AudioBuffer.TYPE.MUSIC);}
    public final AudioBuffer loadSfx(string sfx){return load(sfx, AudioBuffer.TYPE.SFX);}

    //EFFECTS
    public void setPitch(AudioSource src, float pitch);
    public void setPanning(AudioSource src, float panning);
    public void setVolume(AudioSource src, float volume);
    public void setMaxDistance(AudioSource src, float dist);
    public void setRolloffFactor(AudioSource src, float factor);
    public void setReferenceDistance(AudioSource src, float dist);

    public void onDestroy();
/*    final public bool clearMusic()
    {
        foreach(ref music; musics)
        {
            if(!unloadMusic(music))
                return false;
            music = null;
        }
        return true;
    }
    final public bool clearSfx()
    {
        foreach(ref sfx; soundEffects)
        {
            if(!unloadSfx(sfx))
                return false;
            sfx = null;
        }
        return true;
    }*/
    /*final public void _destroy()
    {
        onDestroy();
        clearSfx();
        clearMusic();
    }*/
}
