module hip.api.audio.audio_binding;
public import hip.api.audio.audiosource;

version(Script) void initAudio()
{
    import hip.api.internal;
    loadClassFunctionPointers!(HipAudioBinding, "HipAudio");
    import hip.api.console;
    log("HipengineAPI: Initialized Audio");
}


version(Script)
{
    class HipAudioBinding
    {
        extern(System) static
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
        }
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipAudioBinding;


    
}