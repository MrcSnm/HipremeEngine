module hip.api.audio.audio_binding;
public import hip.api.audio.audiosource;
public import hip.api.audio.audioclip;
void initAudio()
{
    import hip.api.internal;
    alias fn = extern(C) IHipAudioPlayer function();
    setIHipAudioPlayer((cast(fn)_loadSymbol(_dll, "HipAudioPlayerAPI"))());
    import hip.api.console;
    log("HipengineAPI: Initialized Audio");
}
public import hip.api.audio;