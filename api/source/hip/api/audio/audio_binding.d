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
            bool function (AHipAudioSource src) pause;
            bool function (AHipAudioSource src) play_streamed;
            IHipAudioClip function(string path, uint chunkSize = ushort.max+1)  loadStreamed;
            void function (AHipAudioSource source) updateStream;
            IHipAudioClip function() getClip;
            AHipAudioSource function(bool isStreamed = false, IHipAudioClip clip = null) getSource;
        }
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipAudioBinding;


    
}