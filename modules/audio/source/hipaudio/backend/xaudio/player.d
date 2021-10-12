module hipaudio.backend.xaudio.player;

version(Windows):
import util.system:getWindowsErrorMessage;
import hipaudio.backend.xaudio.source;
import error.handler;
import hipaudio.audio;
import core.sys.windows.windows;
import directx.xaudio2;

class HipXAudioPlayer : IHipAudioPlayer
{
    IXAudio2 xAudio;
    IXAudio2MasteringVoice masterVoice;

    immutable(AudioConfig) config;
    public this(AudioConfig cfg)
    {
        this.config = cfg;
        HRESULT hr = CoInitializeEx(null, COINIT.COINIT_MULTITHREADED);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could not CoInitialize\n\t"~getWindowsErrorMessage(hr));

        UINT32 flags;
        version(HIPREME_DEBUG)
            flags|= XAUDIO2_DEBUG_ENGINE;
        
        hr = XAudio2Create(xAudio, 0, XAUDIO2_DEFAULT_PROCESSOR);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could not initialize XAudio:\n\t"~getWindowsErrorMessage(hr));

        hr = xAudio.CreateMasteringVoice(&masterVoice, cfg.channels,  cfg.sampleRate);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could create mastering voice:\n\t"~getWindowsErrorMessage(hr));


    }
    public bool isMusicPlaying(HipAudioSourceAPI src){return false;}
    public bool isMusicPaused(HipAudioSourceAPI src){return false;}
    public bool resume(HipAudioSourceAPI src){return false;}
    public bool stop(HipAudioSourceAPI src){return false;}
    public bool pause(HipAudioSourceAPI src){return false;}
    public bool play_streamed(HipAudioSourceAPI src){return false;}

    public HipAudioClip load(string audioName, HipAudioType bufferType)
    {
        return null;
        // HipAudioClip buffer = new HipAudioClip(new HipSDL_MixerDecoder());
        // buffer.load(audioName,getEncodingFromName(audioName), bufferType);
        // return buffer;
    }
    public HipAudioClip loadStreamed(string audioName, uint chunkSize)
    {
        ErrorHandler.assertExit(false, "SDL Audio Player does not support chunked decoding");
        return null;
    }
    public void updateStream(HipAudioSourceAPI source){}

    public HipAudioSourceAPI getSource(bool isStreamed){return new HipXAudioSource(this);}

    bool play(HipAudioSourceAPI src)
    {
        HipXAudioSource s = (cast(HipXAudioSource)src);
        HRESULT hr = s.sourceVoice.Start(0);
        return SUCCEEDED(hr);
    }
    void setPitch(HipAudioSourceAPI src, float pitch){}
    void setPanning(HipAudioSourceAPI src, float panning){}
    void setVolume(HipAudioSourceAPI src, float volume){}
    public void setMaxDistance(HipAudioSourceAPI src, float dist){}
    public void setRolloffFactor(HipAudioSourceAPI src, float factor){}
    public void setReferenceDistance(HipAudioSourceAPI src, float dist){}

    public void onDestroy()
    {
        xAudio.Release();
    }
}