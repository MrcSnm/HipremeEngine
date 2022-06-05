module hip.hipaudio.backend.xaudio.source;

version(Windows):

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

    override void setClip(IHipAudioClip clip)
    {
        super.setClip(clip);
        HipXAudioClip c = cast(HipXAudioClip)clip;
        XAUDIO2_BUFFER* buffer = cast(XAUDIO2_BUFFER*)c.getBuffer(c.getClipData(), cast(uint)c.getClipSize());
        HRESULT hr = sourceVoice.SubmitSourceBuffer(buffer, null);
        debug
        {
            import hip.console.log;
            ErrorHandler.assertExit(SUCCEEDED(hr),
            "Could not submit XAudio2 source voice:\n\t"~HipXAudioPlayer.getError(hr));
        }
    }
    

    ~this()
    {
    }
}
