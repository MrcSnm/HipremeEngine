module hip.api.audio.audioclip;

public import hip.api.audio;
public import hip.api.data.audio;

interface IHipAudioClip
{
    public bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false,
    void delegate(in ubyte[]) onSuccess = null, void delegate() onFailure = null);

    public bool load(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
    void delegate(in ubyte[]) onSuccess, void delegate() onFailure);

    uint loadStreamed(in void[] data, HipAudioEncoding encoding);
    uint loadStreamed(string audioPath, HipAudioEncoding encoding);
    uint getSampleRate();
    uint updateStream();
    void onUpdateStream(void[] data, uint decodedSize);
    void[] getClipData();
    ulong getClipSize();
    float getDuration();
    float getDecodedDuration();
    void unload();
    immutable(HipAudioClipHint)* getHint();
}

struct HipAudioClipHint
{
    ///Information may be needed by the audio API
    uint outputChannels;
    ///Information may be needed by the audio API
    uint outputSamplerate;
    ///Delegate to the Audio API the resampling.
    bool needsResample;
    ///Delegate to the Audio API the decoding.
    bool needsDecode;
    ///Delegate to the Audio API the channel conversion.
    bool needsChannelConversion = true;
}