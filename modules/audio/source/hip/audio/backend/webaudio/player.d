module hip.audio.backend.webaudio.player;

version(WebAssembly):
import hip.audio.backend.webaudio.source;
import hip.audio.backend.webaudio.clip;
import hip.audio_decoding.audio;
import hip.error.handler;
import hip.audio;


class HipWebAudioPlayer : IHipAudioPlayer
{
    package immutable(AudioConfig) config;

    public this(AudioConfig cfg)
    {
        this.config = cfg;
    }

    public bool play_streamed(AHipAudioSource src){return src.play_streamed();}

    public IHipAudioClip getClip()
    {
        return new HipWebAudioClip(new HipAudioDecoder(), HipAudioClipHint(2, 44_100, false, true));
    }
    public IHipAudioClip loadStreamed(string audioName, uint chunkSize)
    {
        ErrorHandler.assertExit(false, "XAudio Player does not support chunked decoding");
        return null;
    }
    public void updateStream(AHipAudioSource source){}

    public AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null){return new HipWebAudioSource(this);}

    public void onDestroy()
    {
    }

    public void update(){}
}
