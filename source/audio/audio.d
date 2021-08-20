module audio.audio;
import bindbc.sdl;
import sdl.sdl_sound;


enum HipAudioEncoding
{
    WAV,
    MP3,
    OGG,
    MIDI, //Probably won't support
    FLAC
}
enum HipAudioType
{
    SFX,
    MUSIC
}

HipAudioEncoding getEncodingFromName(string name)
{
    import std.string;
    string temp = name[name.lastIndexOf(".")+1..$];
    switch(temp)
    {
        case "wav":return HipAudioEncoding.WAV;
        case "ogg":return HipAudioEncoding.OGG;
        case "mp3":return HipAudioEncoding.MP3;
        case "flac":return HipAudioEncoding.FLAC;
        case "mid":
        case "midi":return HipAudioEncoding.MIDI;
        default: assert(false, "Encoding from file '"~name~"', "~temp~", is not supported.");
    }
}
private char* getNameFromEncoding(HipAudioEncoding encoding)
{
    final switch(encoding)
    {
        case HipAudioEncoding.FLAC:return "flac\0";
        case HipAudioEncoding.MIDI:return "midi\0";
        case HipAudioEncoding.MP3:return "mp3\0";
        case HipAudioEncoding.OGG:return "ogg\0";
        case HipAudioEncoding.WAV:return "wav\0";
    }
}

interface IHipAudioDecoder
{
    bool startDecoding(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
    void* getBuffer();
    ulong getBufferSize();
    void dispose();
}

class HipSDL_MixerDecoder : IHipAudioDecoder
{
    public static bool initDecoder()
    {
        SDLMixerSupport sup = loadSDLMixer();
        if(sup == SDLMixerSupport.badLibrary)
            ErrorHandler.showErrorMessage("Bad SDL_Mixer support", "Unknown version of SDL_Mixer");
        else if(sup == SDLMixerSupport.noLibrary)
        {
            ErrorHandler.showErrorMessage("No SDL_Mixer found", "Could not find any SDL_Mixer version");
            return false;
        }
        return true;
    }
    bool startDecoding(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        SDL_RWops* ops = SDL_RWFromMem(cast(void*)data.ptr, cast(int)data.length);
        this.type = type; 
        if(type == HipAudioType.SFX)
        {
            //Loads .ogg,  .wav, .aiff, .riff, .voc
            chunk = Mix_LoadWAV_RW(ops, 1);
            return chunk != null;
        }
        else
        {
            //Loads .ogg, .mp3, .wav, .flac, .midi
            music = Mix_LoadMUS_RW(ops, 1);
            return music != null;
        }
    }
    void* getBuffer()
    {
        if(type == HipAudioType.SFX)
            return chunk.abuf;
        return null;
    }
    ulong getBufferSize()
    {
        if(type == HipAudioType.SFX && chunk != null)
            return cast(ulong)chunk.alen;
        return 0;
    }

    void dispose()
    {
        if(type == HipAudioType.SFX && chunk != null)
        {
            Mix_FreeChunk(chunk);
            chunk = null;
        }
        else if(music != null)
        {
            Mix_FreeMusic(music);
            music = null;
        }
    }
    union
    {
        Mix_Chunk* chunk;
        Mix_Music* music;
    }
    HipAudioType type;
}

class HipSDL_SoundDecoder : IHipAudioDecoder
{
    public static bool initDecoder()
    {
        return !ErrorHandler.assertErrorMessage(loadSDLSound(), "Error Loading SDL_Sound", "SDL_Sound not found");
    }
    Sound_Sample* sample;
    bool startDecoding(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        SDL_RWops* rw = SDL_RWFromMem(cast(void*)data.ptr, cast(int)data.length);
        import def.debugging.log;
        sample = Sound_NewSample(rw, getNameFromEncoding(encoding), &Audio3DBackend.info, Audio3DBackend.defaultBufferSize);
        SDL_RWclose(rw);
        if(!isStreamed && sample != null)
            Sound_DecodeAll(sample);
        return sample != null;
    }
    void* getBuffer()
    {
        if(sample != null)
            return sample.buffer;
        return null;
    }
    ulong getBufferSize()
    {
        if(sample != null)
            return cast(ulong)sample.buffer_size;
        return 0;
    }
    void dispose()
    {
        if(sample != null)
            Sound_FreeSample(sample);       
    }
}