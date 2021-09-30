module hipengine.api.audio.audio;

public import hipengine.api.audio.audiosource;


version(Script)
{
    bool function (AHipAudioSource src) play;
    bool function (AHipAudioSource src) pause;
    bool function (AHipAudioSource src) play_streamed;
    bool function (AHipAudioSource src) resume;
    bool function (AHipAudioSource src) stop;
    /**
    *   If forceLoad is set to true, you will need to manage it's destruction yourself
    *   Just call audioBufferInstance.unload()
    */
    IHipAudioClip function(string path, HipAudioType bufferType, bool forceLoad = false) load;
    /**
    *   Loads a file from disk, sets the chunkSize for streaming and does one decoding frame
    */
    IHipAudioClip function(string path, uint chunkSize = ushort.max+1)  loadStreamed;
    void function (AHipAudioSource source) updateStream;
    AHipAudioSource function(bool isStreamed = false, IHipAudioClip clip = null) getSource;
    void function (AHipAudioSource src, float pitch) setPitch;
    void function (AHipAudioSource src, float panning) setPanning;
    void function (AHipAudioSource src, float volume) setVolume;
    void function (AHipAudioSource src, float dist) setReferenceDistance;
    void function (AHipAudioSource src, float factor) setRolloffFactor;
    void function (AHipAudioSource src, float dist) setMaxDistance;
    /**
    *   Call this function whenever you update any AHipAudioSource property
    * without calling its setter.
    */
    void function(AHipAudioSource src) update;
}


void loadAudio()
{
    version(Script)
    {
        import hipengine.internal;
        import core.sys.windows.windows;
        enum Class = "hipaudio.audio.HipAudio";

        loadSymbol!(resume);
        loadSymbol!(play,                dlangGetStaticClassFuncName!play(Class));
        loadSymbol!(pause,               dlangGetStaticClassFuncName!pause(Class));
        loadSymbol!(play_streamed,       dlangGetStaticClassFuncName!play_streamed(Class));
        loadSymbol!(resume,              dlangGetStaticClassFuncName!resume(Class));
        loadSymbol!(stop,                dlangGetStaticClassFuncName!stop(Class));
        loadSymbol!(load,                dlangGetStaticClassFuncName!load(Class));
        loadSymbol!(loadStreamed,        dlangGetStaticClassFuncName!loadStreamed(Class));
        loadSymbol!(updateStream,        dlangGetStaticClassFuncName!updateStream(Class));
        loadSymbol!(getSource,           dlangGetStaticClassFuncName!getSource(Class));
        loadSymbol!(setPitch,            dlangGetStaticClassFuncName!setPitch(Class));
        loadSymbol!(setPanning,          dlangGetStaticClassFuncName!setPanning(Class));
        loadSymbol!(setVolume,           dlangGetStaticClassFuncName!setVolume(Class));
        loadSymbol!(setReferenceDistance,dlangGetStaticClassFuncName!setReferenceDistance(Class));
        loadSymbol!(setRolloffFactor,    dlangGetStaticClassFuncName!setRolloffFactor(Class));
        loadSymbol!(setMaxDistance,      dlangGetStaticClassFuncName!setMaxDistance(Class));
        loadSymbol!(update,              dlangGetStaticClassFuncName!update(Class));
    }
}