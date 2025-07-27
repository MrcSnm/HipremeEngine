module hip.api.data.audio;

import hip.api.audio;
public import hip.api.audio.audioclip;

enum HipAudioEncoding : ubyte
{
    WAV,
    MP3,
    OGG,
    MIDI, //Probably won't support
    FLAC,
    MOD,
    XM
}

HipAudioEncoding getEncodingFromName(string name)
{
    int i = cast(int)name.length-1;
    while(i >= 0 && name[i] != '.'){i--;} if(name[i] == '.') i++;
    switch(name[i..$])
    {
        case "wav":return HipAudioEncoding.WAV;
        case "ogg":return HipAudioEncoding.OGG;
        case "mp3":return HipAudioEncoding.MP3;
        case "flac":return HipAudioEncoding.FLAC;
        case "mod": return HipAudioEncoding.MOD;
        case "xm": return HipAudioEncoding.XM;
        case "mid":
        case "midi":return HipAudioEncoding.MIDI;
        default: assert(false, "Encoding from file '"~name~", is not supported.");
    }
}

interface IHipAudioDecoder
{
    bool decode(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type, 
    void delegate(in ubyte[] data) onSuccess, void delegate() onFailure);

    bool resample(in ubyte[] data, HipAudioType type, uint outputSampleRate, uint outputChannels,
    void delegate(in ubyte[] data) onSuccess, void delegate() onFailure);

    ///Channel conversion is a very simple implementation, so, I won't use delegates for it.
    bool channelConversion(in ubyte[] data, ubyte from, ubyte to);
    /**
    *   Receives the raw data. Deals with the data based on clip hint.
    */
    final bool loadData(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type, HipAudioClipHint hint,
    void delegate(in ubyte[] data) onSuccess, void delegate() onFailure)
    {
        if(data.length == 0)
        {
            onFailure();
            return false;
        }

        if(hint.needsDecode)
        {
            decode(data, encoding, type, (in ubyte[] decodedData)
            {
                if(hint.needsResample && getSamplerate != hint.outputSamplerate)
                {
                    resample(decodedData, type, hint.outputSamplerate, hint.outputChannels, (in ubyte[] resampledData)
                    {
                        if(hint.needsChannelConversion && getClipChannels != hint.outputChannels &&
                        !channelConversion(resampledData, getClipChannels, cast(ubyte)hint.outputChannels))
                        {
                            onFailure(); 
                            return;
                        }
                        onSuccess(getClipData);
                    }, onFailure);
                }
                else
                    onSuccess(decodedData);
            }, onFailure);
        }
        else if(hint.needsResample && getSamplerate != hint.outputSamplerate)
        {
            resample(getClipData, type, hint.outputSamplerate, hint.outputChannels, (in ubyte[] resampledData)
            {
                if(hint.needsChannelConversion && getClipChannels != hint.outputChannels &&
                !channelConversion(resampledData, getClipChannels, cast(ubyte)hint.outputChannels))
                    onFailure(); 
                onSuccess(getClipData);
            }, onFailure);
        }
        else if(hint.needsChannelConversion && getClipChannels != hint.outputChannels)
        {
            channelConversion(getClipData, getClipChannels, cast(ubyte)hint.outputChannels);
            onSuccess(getClipData);
        }

        return true;
    }
    ///Used for streaming.
    uint startDecoding(in ubyte[] data, ubyte[] outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    in (chunkSize > 0 , "Chunk size must be greater than 0");
    uint updateDecoding(ubyte[] outputDecodedData);
    AudioConfig getAudioConfig();
    ubyte[] getClipData();
    ubyte getClipChannels();
    size_t getClipSize();
    ///Don't apply to streamed audio. Gets the duration in seconds
    float getDuration();

    void dispose();
    uint getSamplerate();

}

enum AudioFormat : ushort
{
    signed8,
    signed16Little,
    signed16Big,
    signed32Little,
    signed32Big,
    unsigned8,
    unsigned16Little,
    unsigned16Big,
    float32Little,
    float32Big,
    _default = signed16Little
}

enum audioConfigDefaultBufferSize = 4096;


pragma(LDC_no_typeinfo)
struct AudioConfig
{
    int sampleRate;
    AudioFormat format;
    uint channels;
    int bufferSize;

    static enum defaultBufferSize = audioConfigDefaultBufferSize;



    /**
    *   Returns a default audio configuration for 2D
    */
    static AudioConfig musicConfig()
    {
        return AudioConfig(44_100, AudioFormat.float32Little, 2, audioConfigDefaultBufferSize);
    }
    static AudioConfig androidConfig()
    {
        return AudioConfig(22_050, AudioFormat.float32Little, 1U, 2048);
    }
    static AudioConfig lightweightConfig()
    {
        return AudioConfig(22_050, AudioFormat._default, 1U, 2048);
    }

    uint getBitDepth()
    {
        switch(format) with(AudioFormat)
        {
            case signed8:
            case unsigned8:
                return 8;
            case signed16Big:
            case signed16Little:
            case unsigned16Big:
            case unsigned16Little:
                return 16;
            case signed32Big:
            case signed32Little:
            case float32Big:
            case float32Little:
                return 32;
            default:return 0;
        }
    }
}
