module hip.audio.backend.xaudio.player;

version(Windows):
version(XAudio2):
import hip.util.system:getWindowsErrorMessage;
import hip.audio.backend.xaudio.source;
import hip.audio.backend.xaudio.clip;
import hip.audio_decoding.audio;
import hip.error.handler;
import hip.audio;
import core.sys.windows.windef;
import directx.xaudio2;

extern(Windows)
{
    // import core.sys.windows.objbase; //This would import all the uuid table.
    enum COINIT {
        COINIT_APARTMENTTHREADED = 2,
        COINIT_MULTITHREADED     = 0,
        COINIT_DISABLE_OLE1DDE   = 4,
        COINIT_SPEED_OVER_MEMORY = 8
    }
    HRESULT CoInitialize(PVOID);
    HRESULT CoInitializeEx(LPVOID, DWORD);
}

class HipXAudioPlayer : IHipAudioPlayer
{
    IXAudio2 xAudio;
    IXAudio2MasteringVoice masterVoice;

    package immutable(AudioConfig) config;

    /**
    *   For getting better debug information, you need to run this application on Visual Studio.
    *   The debug messages actually appears inside the `Output` window.
    */
    public this(AudioConfig cfg)
    {
        this.config = cfg;

        HRESULT hr;
        version(UWP)
        {}
        else
        {
            CoInitializeEx(null, COINIT.COINIT_MULTITHREADED);
            ErrorHandler.assertLazyExit(SUCCEEDED(hr), "CoInitializeEx error:\n\t"~HipXAudioPlayer.getError(hr));
        }

        UINT32 flags;
        version(HIPREME_DEBUG)
            flags|= XAUDIO2_DEBUG_ENGINE;

        hr = XAudio2Create(xAudio, flags, XAUDIO2_DEFAULT_PROCESSOR);
        ErrorHandler.assertLazyExit(SUCCEEDED(hr), "XAudio2Create error:\n\t"~HipXAudioPlayer.getError(hr));


        hr = xAudio.CreateMasteringVoice(&masterVoice, cfg.channels,  cfg.sampleRate, 0);
        ErrorHandler.assertLazyExit(SUCCEEDED(hr), "CreateMasteringVoice error:\n\t"~HipXAudioPlayer.getError(hr));

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
    public bool play_streamed(AHipAudioSource src){return src.play_streamed();}

    public AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null){return new HipXAudioSource(this);}
    public IHipAudioClip getClip(){return new HipXAudioClip(new HipAudioDecoder(), HipAudioClipHint(2, 44_100, false, true));}

    public IHipAudioClip loadStreamed(string audioName, uint chunkSize)
    {
        ErrorHandler.assertExit(false, "XAudio Player does not support chunked decoding");
        return null;
    }
    public void updateStream(AHipAudioSource source){}

    public void onDestroy()
    {
        xAudio.Release();
    }
    public void update(){}
}
