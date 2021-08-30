module data.audio.audio;
import data.audio.audioconfig;
import std.format;
import bindbc.sdl;
import sdl_sound;
import error.handler;


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
    import std.string : lastIndexOf;
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
        case HipAudioEncoding.FLAC:return cast(char*)"flac\0".ptr;
        case HipAudioEncoding.MIDI:return cast(char*)"midi\0".ptr;
        case HipAudioEncoding.MP3:return cast(char*)"mp3\0".ptr;
        case HipAudioEncoding.OGG:return cast(char*)"ogg\0".ptr;
        case HipAudioEncoding.WAV:return cast(char*)"wav\0".ptr;
    }
}

interface IHipAudioDecoder
{
    bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type);
    uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    in (chunkSize > 0 , "Chunk size must be greater than 0");
    uint updateDecoding(void* outputDecodedData);
    AudioConfig getAudioConfig();
    void* getClipData();
    ulong getClipSize();
    ///Don't apply to streamed audio. Gets the duration in seconds
    float getDuration();

    void dispose();
}

class HipSDL_MixerDecoder : IHipAudioDecoder
{
    protected static AudioConfig cfg;

    public static bool initDecoder(AudioConfig cfg)
    {
        SDLMixerSupport sup = loadSDLMixer();
        if(sup == SDLMixerSupport.badLibrary)
            ErrorHandler.showErrorMessage("Bad SDL_Mixer support", "Unknown version of SDL_Mixer");
        else if(sup == SDLMixerSupport.noLibrary)
        {
            ErrorHandler.showErrorMessage("No SDL_Mixer found", "Could not find any SDL_Mixer version");
            return false;
        }
        HipSDL_MixerDecoder.cfg = cfg;
        return true;
    }
    uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    {assert(false, "SDL_MixerDecoder does not support chunk decoding");}
    uint updateDecoding(void* outputDecodedData)
    {assert(false, "SDL_MixerDecoder does not support chunk decoding");}

    bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type)
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

    public AudioConfig getAudioConfig(){return AudioConfig.lightweightConfig;}
    Mix_Chunk* getChunk(){return chunk;}
    Mix_Music* getMusic(){return music;}
    float getDuration(){return 0;}
    void* getClipData()
    {
        if(type == HipAudioType.SFX)
            return chunk.abuf;
        return null;
    }
    ulong getClipSize()
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

/**
*   SDL_Sound decoder does suport resampling too. So, it won't be needed to implement
*/
class HipSDL_SoundDecoder : IHipAudioDecoder
{
    Sound_Sample* sample;
    HipAudioEncoding selectedEncoding;
    uint chunkSize;
    float duration;
    protected static int bufferSize;
    protected static AudioConfig cfg;

    public static bool initDecoder(AudioConfig cfg, int bufferSize)
    {
        bool ret = ErrorHandler.assertErrorMessage(loadSDLSound(), "Error Loading SDL_Sound", "SDL_Sound not found");
        if(!ret)
            Sound_Init();
        HipSDL_SoundDecoder.bufferSize = bufferSize;
        HipSDL_SoundDecoder.cfg = cfg;
        return ret;
    }
    bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type)
    {
        import console.log;
        selectedEncoding = encoding;
        Sound_AudioInfo info = cfg.getSDL_SoundInfo();
        sample = Sound_NewSampleFromMem(cast(ubyte*)data.ptr, cast(uint)data.length, getNameFromEncoding(encoding), &info, HipSDL_SoundDecoder.bufferSize);
        if(sample != null)
            Sound_DecodeAll(sample);
        return sample != null;
    }
    uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    {
        Sound_AudioInfo info = cfg.getSDL_SoundInfo();
        this.selectedEncoding = encoding;
        this.sample = Sound_NewSampleFromMem(cast(ubyte*)data.ptr, cast(uint)data.length,
            getNameFromEncoding(encoding), &info, HipSDL_SoundDecoder.bufferSize);
        this.chunkSize = chunkSize;

        ErrorHandler.assertExit(sample != null, "SDL_Sound could not create a sample from memory.");
        if(Sound_SetBufferSize(sample, chunkSize) == 0)
            ErrorHandler.showErrorMessage("SDL_Sound decoding error",
            format!"Could not set sample with chunk size %s"(chunkSize));
        return updateDecoding(outputDecodedData);
    }

    uint updateDecoding(void* outputDecodedData)
    {
        import core.stdc.string:memcpy;
        uint ret = 0;
        uint decodedTotal = 0;
        while(decodedTotal != chunkSize && (ret = Sound_Decode(sample)) != 0)
        {
            memcpy(outputDecodedData+decodedTotal, sample.buffer, ret);
            decodedTotal+= ret;
            duration+= ret;
            if(ErrorHandler.assertErrorMessage(decodedTotal <= chunkSize, "SDL_Sound decoding error", 
            format!"Chunk size %s is invalid for decoding step %s"(chunkSize, ret)))
                return 0;
        }
        if(sample.flags & Sound_SampleFlags.SOUND_SAMPLEFLAG_ERROR)
            ErrorHandler.showErrorMessage("SDL_Sound decoding error",
            format!"Error decoding sample.\nReason: %s"(Sound_GetError()));
        return decodedTotal;
    }
    float getDuration()
    {
        import data.audio.format_utils;
        if(duration != 0)
            return duration;
        if(sample != null)
        {
            if(selectedEncoding == HipAudioEncoding.MP3)
                return HipMp3GetDuration(sample.buffer_size, sample.actual.rate);
            return Sound_GetDuration(sample);
        }
        return 0;
    }
    AudioConfig getAudioConfig()
    {
        AudioConfig ret;
        if(sample != null)
        {
            Sound_AudioInfo info = sample.actual;
            ret.channels = info.channels;
            ret.sampleRate = info.rate;
            ret.format = info.format;
        }
        return ret;
    }
    void* getClipData()
    {
        if(sample != null)
            return sample.buffer;
        return null;
    }
    ulong getClipSize()
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