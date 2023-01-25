module hip.api.audio.audioclip;

public import hip.api.audio;
public import hip.api.data.audio;


struct HipAudioBufferAPI;

interface IHipAudioClip
{
    public bool loadFromMemory(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
    void delegate(in ubyte[]) onSuccess, void delegate() onFailure);

    uint loadStreamed(in ubyte[] data, HipAudioEncoding encoding);
    uint getSampleRate();
    uint updateStream();
    void onUpdateStream(ubyte[] data, uint decodedSize);

    /** 
     * This function is reserved for HipAudio for being able to take the buffer out of an
     *  audio asset.
     */
    HipAudioBufferAPI* _getBufferAPI(ubyte[] data, uint size); 
    ///Reserved for internal engine methods.
    IHipAudioClip getAudioClipBackend();
    T getAudioClipBackend(T)(){return cast(T)getAudioClipBackend;}
    ubyte[] getClipData();
    size_t getClipSize();
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