module implementations.audio.audiobase;

public abstract class AudioBase(TMus, TSfx)
{

    abstract public bool play();
    abstract public bool stop();
    abstract public bool pause();
    abstract public bool play_streamed();

    abstract public bool loadMusic();
    abstract public bool unloadMusic(TMus mus);
    abstract public bool unloadMusic(string mus, string ext = "");

    abstract public bool loadSfx();
    abstract public bool unloadSfx(TSfx sfx);
    abstract public bool unloadSfx(string sfx, string ext = "");

    final public bool clearMusic()
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
    }

    public abstract void onDestroy();

    final public void _destroy()
    {
        onDestroy();
        clearSfx();
        clearMusic();
    }

    protected TMus[string] musicPool;
    protected TSfx[string] sfxPool;
    protected static string defaultSfxExt;
    protected static string defaultMusicExt;
}
