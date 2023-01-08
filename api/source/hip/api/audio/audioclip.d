module hip.api.audio.audioclip;

public import hip.api.audio;
public import hip.api.data.audio;

interface IHipAudioClip
{
    bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
    bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
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
    ///If false, no resample will occur, and the AudioAPI will deal with it
    bool needsResample;
    ///If false, no decode will occur, and the AudioAPI will deal with it
    bool needsDecode;
}