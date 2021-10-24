module hipaudio.backend.xaudio.player;

version(Windows):
import util.system:getWindowsErrorMessage;
import hipaudio.backend.xaudio.source;
import hipaudio.backend.xaudio.clip;
import data.audio.audio;
import error.handler;
import hipaudio.audio;
import core.sys.windows.windows;
import directx.xaudio2;


pragma(lib, "xaudio2");

class HipXAudioPlayer : IHipAudioPlayer
{
    IXAudio2 xAudio;
    IXAudio2MasteringVoice masterVoice;

    immutable(AudioConfig) config;

    /**
    *   For getting better debug information, you need to run this application on Visual Studio.
    *   The debug messages actually appears inside the `Output` window.
    */
    public this(AudioConfig cfg)
    {
        this.config = cfg;
        HRESULT hr = CoInitializeEx(null, COINIT.COINIT_MULTITHREADED);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could not CoInitialize\n\t"~HipXAudioPlayer.getError(hr));

        UINT32 flags;
        version(HIPREME_DEBUG)
            flags|= XAUDIO2_DEBUG_ENGINE;
        
        hr = XAudio2Create(xAudio, flags, XAUDIO2_DEFAULT_PROCESSOR);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could not initialize XAudio:\n\t"~HipXAudioPlayer.getError(hr));

    
        hr = xAudio.CreateMasteringVoice(&masterVoice, cfg.channels,  cfg.sampleRate);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could create mastering voice:\n\t"~HipXAudioPlayer.getError(hr));

        version(HIPREME_DEBUG)
        {
            XAUDIO2_DEBUG_CONFIGURATION debugConfig = XAUDIO2_DEBUG_CONFIGURATION(
                XAUDIO2_LOG_ERRORS | XAUDIO2_LOG_WARNINGS, XAUDIO2_LOG_ERRORS, true, true, true, true
            );
            xAudio.SetDebugConfiguration(&debugConfig);
        }


    }

    public static string getError(HRESULT hr)
    {
        switch(hr)
        {
            case XAUDIO2_E_INVALID_CALL: return "XAUDIO2_E_INVALID_CALL: An API call or one of its arguments was illegal";
            case XAUDIO2_E_XMA_DECODER_ERROR: return "XAUDIO2_E_XMA_DECODER_ERROR: The XMA hardware suffered an unrecoverable error";
            case XAUDIO2_E_XAPO_CREATION_FAILED: return "XAUDIO2_E_XAPO_CREATION_FAILED: XAudio2 failed to initialize an XAPO effect";
            case XAUDIO2_E_DEVICE_INVALIDATED: return "XAUDIO2_E_DEVICE_INVALIDATED: An audio device became unusable (unplugged, etc)";
            default: return getWindowsErrorMessage(hr);
        }
    }
    public bool isMusicPlaying(HipAudioSourceAPI src){return false;}
    public bool isMusicPaused(HipAudioSourceAPI src){return false;}
    public bool resume(HipAudioSourceAPI src){return false;}
    public bool stop(HipAudioSourceAPI src){return false;}
    public bool pause(HipAudioSourceAPI src){return false;}
    public bool play_streamed(HipAudioSourceAPI src){return false;}

    public HipAudioClip load(string audioName, HipAudioType bufferType)
    {
        HipAudioClip buffer = new HipXAudioClip(new HipAudioFormatsDecoder());
        buffer.load(audioName,getEncodingFromName(audioName), bufferType);
        return buffer;
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
        debug
        {
            ErrorHandler.assertExit(SUCCEEDED(hr), "XAudio2 Failed to play: \n\t"~HipXAudioPlayer.getError(hr));
        }
        
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
