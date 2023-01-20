module hip.assets.audioclip;
public import hip.asset;
public import hip.api.audio.audioclip;

class HipAudioClip : HipAsset, IHipAudioClip
{
    import hip.util.reflection;
    IHipAudioClip clip;
    this()
    {
        super("HipAudioClip");
        _typeID = assetTypeID!HipAudioClip();
        import hip.hipaudio.audio;
        clip = HipAudio.getClip();
    }
    public bool loadFromMemory(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
    void delegate(in ubyte[]) onSuccess, void delegate() onFailure)
    {
        return clip.loadFromMemory(data,encoding,type,onSuccess,onFailure);
    }

    uint loadStreamed(in ubyte[] data, HipAudioEncoding encoding){return clip.loadStreamed(data,encoding);}
    uint getSampleRate(){return clip.getSampleRate;}
    uint updateStream(){return clip.updateStream;}
    void onUpdateStream(ubyte[] data, uint decodedSize){clip.onUpdateStream(data,decodedSize);}
    ubyte[] getClipData(){return clip.getClipData;}
    size_t getClipSize(){return clip.getClipSize;}
    float getDuration(){return clip.getDuration;}
    float getDecodedDuration(){return clip.getDecodedDuration;}
    void unload(){clip.unload;}
    immutable(HipAudioClipHint)* getHint(){return clip.getHint;}

    override void onFinishLoading(){}
    override void onDispose(){clip.unload();}
    HipAudioBufferAPI* _getBufferAPI(ubyte[] data, uint size){return clip._getBufferAPI(data, size);}
}