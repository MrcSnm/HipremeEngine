module hipaudio.backend.xaudio.source;

version(Windows):

import hipaudio.backend.xaudio.player;
import hipaudio.audiosource;
import directx.xaudio2;
import directx.win32;
import util.system:getWindowsErrorMessage;
import error.handler;

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
        fmt.nAvgBytesPerSec = cast(ushort)cfg.sampleRate;
        fmt.nSamplesPerSec  = cfg.sampleRate;
        fmt.nBlockAlign     = cast(ushort)(cfg.channels * cfg.getBitDepth())/8;
        fmt.wBitsPerSample  = cast(ushort)cfg.getBitDepth;
        fmt.cbSize          = 0;

        HRESULT hr = player.xAudio.CreateSourceVoice(&sourceVoice, &fmt);
        ErrorHandler.assertExit(SUCCEEDED(hr), "Could not create source voice: \n\t"~getWindowsErrorMessage(hr));
        
    }

    override void setClip(IHipAudioClip clip)
    {
        super.setClip(clip);
        //HipXAudioClip c = cast(HipXAudioClip)clip;
        // sourceVoice.SubmitSourceBuffer(c.buffer, null);
    }
    

    ~this()
    {
    }
}
