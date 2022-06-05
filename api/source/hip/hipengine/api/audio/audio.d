module hip.hipengine.api.audio.audio;

public import hip.hipengine.api.audio.audiosource;



version(Script)
{
    extern(System)
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

    
}


void initAudio()
{
    version(Script)
    {
        import hipengine.internal;
        enum Class = "HipAudio";

        //Create an instance per unique type
        mixin(loadSymbolsFromExportD!(Class,
            resume,
            play,
            pause,
            play_streamed,
            resume,
            stop,
            load,
            loadStreamed,
            updateStream,
            getSource,
            setPitch,
            setPanning,
            setVolume,
            setReferenceDistance,
            setRolloffFactor,
            setMaxDistance,
            update
        ));
    }
}