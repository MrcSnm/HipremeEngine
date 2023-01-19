module hip.hipaudio.backend.webaudio.source;

version(WebAssembly):

extern(C) size_t WebAudioSourceCreate();
extern(C) void WebAudioSourceStop(size_t src);
extern(C) void WebAudioSourceSetData(size_t src, size_t buffer);
extern(C) void WebAudioSourceSetPlaying(size_t src, bool playing);
extern(C) void WebAudioSourceSetPitch(size_t src, float pitch);
extern(C) void WebAudioSourceSetVolume(size_t src, float volume);
extern(C) void WebAudioSourceSetPlaybackRate(size_t src, float rate);

import hip.hipaudio.backend.webaudio.player;
import hip.hipaudio.backend.webaudio.clip;
import hip.hipaudio.audiosource;
import hip.error.handler;


class HipWebAudioSource : HipAudioSource
{
    protected bool isClipDirty = true;
    protected size_t webSrc = 0;

    this(HipWebAudioPlayer player)
    {
        AudioConfig cfg = player.config;
        webSrc = WebAudioSourceCreate();
    }
    alias clip = HipAudioSource.clip;


    override IHipAudioClip clip(IHipAudioClip newClip)
    {
        if(newClip != clip)
            isClipDirty = true;

        HipWebAudioClip c = cast(HipWebAudioClip)newClip;
        WebAudioSourceSetData(webSrc, c.getBuffer(c.getClipData(), c.getClipSize()).webaudio);
        super.clip(newClip);
        return newClip;
    }

    alias loop = HipAudioSource.loop;
    override bool loop(bool value)
    {
        bool ret = super.loop(value);
        HipWebAudioClip c = (cast(HipWebAudioClip)clip);
        return ret;
    }

    
        
    override bool play()
    {
        WebAudioSourceSetPlaying(webSrc, true);
        return true;
    }
    override bool stop()
    {
        WebAudioSourceStop(webSrc);
        return true;
    }
    override bool pause()
    {
        WebAudioSourceSetPlaying(webSrc, false);
        return true;
    }
    override bool play_streamed() => false;
    

    ~this(){webSrc = 0;}
}
