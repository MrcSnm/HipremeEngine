module hip.data.audio.audio;
import hip.data.audio.audioconfig;
import sdl_sound;

public import hip.hipengine.api.data.audio;


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

version(HipSDLMixer) class HipSDL_MixerDecoder : IHipAudioDecoder
{
    protected static AudioConfig cfg;
    //import bindbc.sdl.mixer; Unused?

    public static bool initDecoder(AudioConfig cfg)
    {
        import hip.error.handler;
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
        import hip.error.handler;
        bool ret = ErrorHandler.assertErrorMessage(loadSDLSound(), "Error Loading SDL_Sound", "SDL_Sound not found");
        if(!ret)
            Sound_Init();
        HipSDL_SoundDecoder.bufferSize = bufferSize;
        HipSDL_SoundDecoder.cfg = cfg;
        return ret;
    }
    bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type)
    {
        selectedEncoding = encoding;
        Sound_AudioInfo info = cfg.getSDL_SoundInfo();
        sample = Sound_NewSampleFromMem(cast(ubyte*)data.ptr, cast(uint)data.length, getNameFromEncoding(encoding), &info, HipSDL_SoundDecoder.bufferSize);
        if(sample != null)
            Sound_DecodeAll(sample);
        return sample != null;
    }
    uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    {
        import hip.error.handler;
        import hip.util.conv;
        Sound_AudioInfo info = cfg.getSDL_SoundInfo();
        this.selectedEncoding = encoding;
        this.sample = Sound_NewSampleFromMem(cast(ubyte*)data.ptr, cast(uint)data.length,
            getNameFromEncoding(encoding), &info, HipSDL_SoundDecoder.bufferSize);

        ErrorHandler.assertExit(sample != null, "SDL_Sound could not create a sample from memory.");
        if(Sound_SetBufferSize(sample, chunkSize) == 0)
            ErrorHandler.showErrorMessage("SDL_Sound decoding error",
            "Could not set sample with chunk size "~to!string(chunkSize));

        import hip.math.utils:getClosestMultiple;
        uint decodeSize = Sound_Decode(sample);
        this.chunkSize = getClosestMultiple(decodeSize, chunkSize);
        ErrorHandler.assertExit(Sound_Rewind(sample) != 0, "SDL_Sound could not get back to sample start.");

        return updateDecoding(outputDecodedData);
    }

    uint updateDecoding(void* outputDecodedData)
    {
        import core.stdc.string:memcpy;
        import hip.error.handler;
        import hip.util.conv;
        import hip.util.string;

        uint ret = 0;
        uint decodedTotal = 0;
        while(decodedTotal != chunkSize && (ret = Sound_Decode(sample)) != 0)
        {
            memcpy(outputDecodedData+decodedTotal, sample.buffer, ret);
            decodedTotal+= ret;
            duration+= ret;
            ErrorHandler.assertExit(decodedTotal <= chunkSize, "SDL_Sound decoding error", 
            "Chunk size "~ to!string(chunkSize) ~ "is invalid for decoding step "~ to!string(ret));

        }
        if(sample.flags & Sound_SampleFlags.SOUND_SAMPLEFLAG_ERROR)
            ErrorHandler.showErrorMessage("SDL_Sound decoding error",
            "Error decoding sample.\nReason: "~ Sound_GetError().fromStringz);
        return decodedTotal;
    }
    float getDuration()
    {
        import hip.data.audio.format_utils;
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
            ret.format = getFormatFromSDL_AudioFormat(info.format);
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


T* monoToStereo(T)(T* data, ulong framesLength)
{
    import core.stdc.stdlib;
    T* ret = cast(T*)malloc(framesLength*2 * T.sizeof);

    for(ulong i = 0; i < framesLength; i++)
    {
        ret[i*2]    = data[i];
        ret[i*2+1]  = data[i];
    }
    return ret;
}

T[] monoToStereo(T)(T[] data)
{
    T[] ret = new T[data.length*2];
    for(ulong i = 0; i < data.length; i++)
    {
        ret[i*2]    = data[i];
        ret[i*2+1]  = data[i];
    }
    return ret;
}

private struct _AudioStreamImpl
{
    void* block;
    void initialize()
    {
        import core.stdc.stdlib:malloc;
        import audioformats;
        block = malloc(AudioStream.sizeof);
    }

    void openFromMemory(in ubyte[] inputData)
    {
        if(block == null)
            initialize();
        import audioformats;
        (cast(AudioStream*)block).openFromMemory(inputData);
    }
    long getLengthInFrames()
    {
        import audioformats;
        return (cast(AudioStream*)block).getLengthInFrames();
    }
    int getNumChannels()
    {
        import audioformats;
        return (cast(AudioStream*)block).getNumChannels();
    }
    float getSamplerate()
    {
        import audioformats;
        return (cast(AudioStream*)block).getSamplerate();
    }
    int readSamplesFloat(float[] outputBuffer)
    {
        import audioformats;
        return (cast(AudioStream*)block).readSamplesFloat(outputBuffer);
    }
    void cleanUp()
    {
        import audioformats;
        import core.stdc.stdlib;
        (cast(AudioStream*)block).cleanUp();
        free(block);
        block = null;
    }
}

class HipAudioFormatsDecoder : IHipAudioDecoder
{
    _AudioStreamImpl input;
    float sampleRate;
    int channels;
    float duration;
    ulong clipSize;
    uint chunkSize;

    float[] buffer;
    float[] decodedBuffer;


    bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type)
    {
        import audioformats : audiostreamUnknownLength;
        input.openFromMemory(cast(ubyte[])data);

        long lengthFrames = input.getLengthInFrames();
        channels = input.getNumChannels();
        sampleRate = input.getSamplerate();

        bool decodeSuccesful;

        if(lengthFrames == audiostreamUnknownLength)
        {
            uint bytesRead = 0;
        
            decodedBuffer.length = audioConfigDefaultBufferSize;
            void* output = decodedBuffer.ptr;
            startDecoding(data, output, audioConfigDefaultBufferSize, encoding);
            while((bytesRead = updateDecoding(output)) != 0)
            {
                bytesRead/= float.sizeof;
                decodedBuffer.length+= bytesRead;
                output+= bytesRead;
            }
            duration = (clipSize / channels) / sampleRate;
        }
        else
        {
            duration = lengthFrames/cast(double)sampleRate;
            decodedBuffer = new float[lengthFrames*channels];
            int bytesRead = input.readSamplesFloat(decodedBuffer);
            clipSize = decodedBuffer.length*float.sizeof;
            decodeSuccesful = bytesRead == lengthFrames;
        }
        if(decodeSuccesful)
        {
            if(channels == 1)
            {
                decodedBuffer = monoToStereo(decodedBuffer);
                clipSize+=clipSize;
            }
            // if(sampleRate != 44_100)
            // {
            //     decodedBuffer = resampleBuffer(decodedBuffer, sampleRate, 44_100);
            // }
        }

        input.cleanUp();

        return decodeSuccesful;
    }
    uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    {
        input.openFromMemory(cast(ubyte[])data);
        channels = input.getNumChannels();
        sampleRate = input.getSamplerate();

        chunkSize = (chunkSize / channels) / float.sizeof;
        buffer = new float[chunkSize];
        this.chunkSize = chunkSize;
        
        return updateDecoding(outputDecodedData);
    }
    uint updateDecoding(void* outputDecodedData)
    {
        import core.stdc.string:memcpy;
        int framesRead = 0;
        uint currentRead = 0;
        do
        {
            framesRead = input.readSamplesFloat(buffer);
            if(framesRead != 0)
                memcpy(currentRead + outputDecodedData,
                buffer.ptr, framesRead * channels * float.sizeof);
            
            currentRead += framesRead  * channels * float.sizeof;
        } while(framesRead > 0 && currentRead <= chunkSize);
        

        clipSize+= currentRead;
        return currentRead;
    }
    AudioConfig getAudioConfig(){return AudioConfig.init;}
    void* getClipData(){return cast(void*)decodedBuffer.ptr;}
    ulong getClipSize(){return clipSize;}
    ///Don't apply to streamed audio. Gets the duration in seconds
    float getDuration(){return duration;}

    void dispose(){input.cleanUp();}
}