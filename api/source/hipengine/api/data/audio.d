module hipengine.api.data.audio;

public import hipengine.api.audio;

HipAudioEncoding getEncodingFromName(string name)
{
    int index = 0;
    for(int i = cast(int)name.length-1; i >= 0; i--)
    {
        if(name[i] == '.')
        {
            index = i+1;
            break;
        }
    }
    string temp = name[index..$];
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


struct AudioConfig
{
    int sampleRate;
    AudioFormat format;
    uint channels;
    int bufferSize;

    /**
    *   Returns a default audio configuration for 2D
    */
    static AudioConfig musicConfig()
    {
        return AudioConfig(44_100, AudioFormat._default, 2, audioConfigDefaultBufferSize);
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