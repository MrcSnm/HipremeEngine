module implementations.audio.backend.audio2d;
import implementations.audio.backend.audiobase;
import bindbc.sdl.mixer;

class Audio2DBackend : AudioBase!(Mix_Music*, Mix_Chunk*)
{
    public bool playSfx(string )
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

    public bool loadMusic(string musicName, string extension = "", bool forceReload = false)
    {
        if(extension=="")
            extension=defaultMusicExt;
        string music = musicName~extension;
        Mix_Music** msc = (music in musicPool);
        if(*msc == null || forceReload)
        {
            *msc = Mix_LoadMUS(cast(const(char)*)music);
            musicPool[music] = *msc;
            return *msc != null;
        }

        return false;
    }
    public bool unloadMusic(TMus mus)
    {
        
        return false;
    }
    public bool unloadMusic(string mus, string ext = "")
    {
        if(extension == "")
            extension = defaultMusicExt;
        string music = musicName~extension;
        Mix_Music** msc = (music in musicPool);
        if(*msc != null)
        {
            Mix_FreeMusic(*msc);
            *msc = null;
            musicPool[music] = null;
            return true;
        }
        return false;
    }

    public bool loadSfx(string soundName, string extension = "", bool forceReload = false)
    {
        if(extension=="")
            extension=defaultSfxExt;
        string sound = soundName~extension;
        Mix_Chunk** snd = (sound in sfxPool);
        if(*snd == null || forceReload)
        {
            *snd = Mix_LoadWAV(cast(const(char)*)sound);
            sfxPool[sound] = *snd;
            return *snd != null;
        }
        return false;
    }

    public bool unloadSfx(TSfx sfx)
    {
        
        return false;
    }
    public bool unloadSfx(string sfx, string ext = "")
    {
        if(extension == "")
            extension = defaultSfxExt;
        string sound = soundName~extension;
        Mix_Chunk** sfx = (sound in sfxPool);
        if(*sfx != null)
        {
            Mix_FreeChunk(*sfx);
            *sfx = null;
            sfxPool[sound] = null;
            return true;
        }
        return false;
    }

    public void onDestroy()
    {
        Mix_CloseAudio();
    }
}
