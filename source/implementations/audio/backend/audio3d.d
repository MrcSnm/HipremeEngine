module implementations.audio.backend.audio3d;
import implementations.audio.backend.audiobase;

public class Audio3DBackend : AudioBase
{
    public bool play()
    {
        return false;
    }
    public bool stop()
    {
        return false;
    }
    public bool pause()
    {
        return false;
    }
    public bool play_streamed()
    {
        return false;
    }

    public bool loadMusic()
    {
        return false;
    }
    public bool unloadMusic(TMus mus)
    {
        return false;
    }
    public bool unloadMusic(string mus, string ext = "")
    {
        return false;
    }

    public bool loadSfx()
    {
        return false;
    }
    public bool unloadSfx(TSfx sfx)
    {
        return false;
    }
    public bool unloadSfx(string sfx, string ext = "")
    {

        return false;
    }
}