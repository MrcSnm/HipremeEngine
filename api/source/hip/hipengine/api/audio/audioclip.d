module hip.hipengine.api.audio.audioclip;
public import hip.hipengine.api.data.audio;

interface IHipAudioClip
{
    bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
    bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
    uint loadStreamed(in void[] data, HipAudioEncoding encoding);
    uint loadStreamed(string audioPath, HipAudioEncoding encoding);
    uint updateStream();
    void onUpdateStream(void* data, uint decodedSize);
    void* getClipData();
    ulong getClipSize();
    float getDuration();
    float getDecodedDuration();
    void unload();
}