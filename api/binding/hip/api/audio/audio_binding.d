module hip.api.audio.audio_binding;
public import hip.api.audio.audiosource;

version(ScriptAPI)
{
    void initAudio()
    {
        import hip.api.internal;
        loadClassFunctionPointers!(HipAudioBinding, UseExportedClass.Yes, "HipAudio");
        import hip.api.console;
        log("HipengineAPI: Initialized Audio");
    }
    class HipAudioBinding
    {
        extern(System) __gshared
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


version(DirectCall) { public import hip.hipaudio; }
else version(ScriptAPI)
{
    public import HipAudio = hip.api.audio.audio_binding;
    public import hip.api.audio.audioclip:IHipAudioClip;
    public import hip.api.audio.audiosource:AHipAudioSource;
}