module hip.hipaudio.backend.xaudio.source;

version(Windows):
version(DirectX):

import hip.hipaudio.backend.xaudio.player;
import hip.hipaudio.backend.xaudio.clip;
import hip.hipaudio.audiosource;
import directx.xaudio2;
import directx.win32;
import hip.util.system:getWindowsErrorMessage;
import hip.error.handler;

enum WAVE_FORMAT_IEEE_FLOAT = 0x0003;

class HipXAudioSource : HipAudioSource
{
    IXAudio2SourceVoice sourceVoice;
    protected bool isClipDirty = true;

    this(HipXAudioPlayer player)
    {

        AudioConfig cfg = player.config;
        WAVEFORMATEX fmt;
        WORD format;

        switch(cfg.getBitDepth)
        {
            case 8:
            case 16:
                format = WAVE_FORMAT_PCM;
                break;
            case 32:
                format = WAVE_FORMAT_IEEE_FLOAT;
                break;
            default:
                ErrorHandler.assertExit(false, "XAudio2 Does not support the current bit depth");
                break;
        }
        fmt.wFormatTag      = format;
        fmt.nChannels       = cast(ushort)cfg.channels;
        fmt.nAvgBytesPerSec = cfg.sampleRate * (cfg.getBitDepth/8) * cfg.channels;
        fmt.nSamplesPerSec  = cfg.sampleRate;
        fmt.nBlockAlign     = cast(ushort)(cfg.channels * cfg.getBitDepth())/8;
        fmt.wBitsPerSample  = cast(ushort)cfg.getBitDepth;
        fmt.cbSize          = 0;
        HRESULT hr = player.xAudio.CreateSourceVoice(&sourceVoice, &fmt);

        ErrorHandler.assertExit(SUCCEEDED(hr), "Could not create source voice: \n\t"~HipXAudioPlayer.getError(hr));
        
    }
    alias clip = HipAudioSource.clip;


    protected void submitClip()
    {
        HipXAudioClip c = cast(HipXAudioClip)clip;
        XAUDIO2_BUFFER* buffer = c.getBuffer(c.getClipData(), cast(uint)c.getClipSize()).xaudio;

        if(isClipDirty)
        {
            isClipDirty = false;
            HRESULT hr = sourceVoice.SetSourceSampleRate(c.decoder.getSamplerate());
            ErrorHandler.assertExit(SUCCEEDED(hr),
            "Could not set source voice Sample Rate:\n\t"~HipXAudioPlayer.getError(hr));
        }

        HRESULT hr = sourceVoice.SubmitSourceBuffer(buffer, null);
        ErrorHandler.assertExit(SUCCEEDED(hr),
        "Could not submit XAudio2 source voice:\n\t"~HipXAudioPlayer.getError(hr));
    }

    override IHipAudioClip clip(IHipAudioClip newClip)
    {
        if(newClip != clip)
            isClipDirty = true;
        super.clip(newClip);
        return newClip;
    }

    alias loop = HipAudioSource.loop;
    override bool loop(bool value)
    {
        bool ret = super.loop(value);
        HipXAudioClip c = (cast(HipXAudioClip)clip);
        c.buffer.LoopCount = loop ? XAUDIO2_LOOP_INFINITE : 0;
        return ret;
    }

    
        
    override bool play()
    {
        if(isPlaying)
        {
            sourceVoice.Stop();
            sourceVoice.FlushSourceBuffers();
        }
        submitClip();
        
        HRESULT hr = sourceVoice.Start(0);
        ErrorHandler.assertExit(SUCCEEDED(hr), "XAudio2 Failed to play: \n\t"~HipXAudioPlayer.getError(hr));
        isPlaying = true;        
        return SUCCEEDED(hr);
    }
    override bool stop()
    {
        //May need to use XAUDIO2_PLAY_TAILS for outputting reverb too.
        auto hr = sourceVoice.Stop(XAUDIO2_PLAY_TAILS);
        ///Makes it return to 0
        sourceVoice.FlushSourceBuffers();
        debug
            ErrorHandler.assertErrorMessage(SUCCEEDED(hr), "XAudio2 stop failure", HipXAudioPlayer.getError(hr));

        isPlaying = false;
        return SUCCEEDED(hr);
    }
    override bool pause()
    {
        isPaused = true;
        //May need to use XAUDIO2_PLAY_TAILS for outputting reverb too.
        return SUCCEEDED(sourceVoice.Stop(XAUDIO2_PLAY_TAILS));
    }
    override bool play_streamed() => false;
    

    ~this()
    {
        if(sourceVoice !is null)
        {
            sourceVoice.DestroyVoice();
            sourceVoice = null;
        }
    }
}
