module hipaudio.backend.opensles.player;
version(Android):
import hipaudio.backend.opensles.source;
import hipaudio.backend.opensles.clip;
import hipaudio.backend.audiosource;
import data.audio.audioconfig;
import hipaudio.backend.sles;
import config.opts : HIP_OPENSLES_OPTIMAL, HIP_OPENSLES_FAST_MIXER;
import data.audio.audio;
import std.conv:to;
import opensles.sles;
import error.handler;
import hipaudio.audio;
import bindbc.sdl;

version(Android):
SLDataFormat_PCM getFormatAsOpenSLES(AudioConfig cfg)
{
    SLDataFormat_PCM ret;
    ret.formatType = SL_DATAFORMAT_PCM;
    ret.numChannels = cfg.channels; //2 channels seems to not be supported yet

    static if(HIP_OPENSLES_OPTIMAL)
        ret.samplesPerSec = HipOpenSLESAudioPlayer.optimalSampleRate*1000;
    else
        ret.samplesPerSec = cfg.sampleRate*1000;

    switch(cfg.format)
    {
        //Big
        case SDL_AudioFormat.AUDIO_S16MSB:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.endianness = SL_BYTEORDER_BIGENDIAN;
            break;
        case SDL_AudioFormat.AUDIO_S32MSB:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.endianness = SL_BYTEORDER_BIGENDIAN;
            break;

        case SDL_AudioFormat.AUDIO_S8:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_8;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_8;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            break;
        default:
        case SDL_AudioFormat.AUDIO_S16LSB:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            break;
        //Little
        case SDL_AudioFormat.AUDIO_S32LSB:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            break;
    }
    if(cfg.channels == 2)
        ret.channelMask = SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT;
    else if(cfg.channels == 1)
        ret.channelMask = SL_SPEAKER_FRONT_CENTER;
    else
        ErrorHandler.assertExit(false, "OpenSL ES Audio Config does not supports " ~
        to!string(cfg.channels)~" channels");

    return ret;
}

package __gshared SLIAudioPlayer*[] playerPool;
package uint poolRingIndex = 0;

/// Probably should take into account fast mixer: https://source.android.com/devices/audio/latency/design
enum MAX_SLI_AUDIO_PLAYERS = 32;
enum MAX_SLI_BUFFERS       = 16;


package SLIAudioPlayer* hipGenAudioPlayer()
{
    SLDataFormat_PCM fmt = HipAudio.getConfig().getFormatAsOpenSLES();
    version(Android)
    {
        import opensles.android;
        SLDataLocator_AndroidSimpleBufferQueue locator;
        locator.locatorType = SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE;
        ///This options says how many buffers it is possible to enqueue
        locator.numBuffers = MAX_SLI_BUFFERS;
    }
    else
    {
        SLDataLocator_Address locator;
        locator.locatorType = SL_DATALOCATOR_ADDRESS;
        // locator.pAddress = bufferPtr;
        // locator.length = bufferLength;
    }
    SLDataSource src;
    src.pLocator = &locator;
    src.pFormat = &fmt;

    //Okay
    SLDataLocator_OutputMix locatorMix;
    locatorMix.locatorType = SL_DATALOCATOR_OUTPUTMIX;
    locatorMix.outputMix = outputMix.outputMixObj;

    SLDataSink destination;
    destination.pLocator = &locatorMix;
    destination.pFormat = null;

    return sliGenAudioPlayer(src, destination);
}

package SLIAudioPlayer* hipGetPlayerFromPool()
{
    foreach(p; playerPool)
    {
        if(!p.isPlaying)
            return p;
    }
    if(playerPool.length == MAX_SLI_AUDIO_PLAYERS)
    {
        SLIAudioPlayer* temp = playerPool[poolRingIndex];
        SLIAudioPlayer.stop(*temp);
        poolRingIndex = (poolRingIndex+1)%MAX_SLI_AUDIO_PLAYERS;
        return temp;
    }
    return hipGenAudioPlayer();
}

class HipOpenSLESAudioPlayer : IHipAudioPlayer
{
    AudioConfig cfg;
    SLIOutputMix output;
    SLEngineItf itf;

    static bool hasProAudio;
    static bool hasLowLatencyAudio;
    static int  optimalBufferSize;
    static int  optimalSampleRate;

    /**
    *   For understanding a bit better how the buffer size works, take a look into the documentation
    *   provided by google: https://developer.android.com/ndk/guides/audio/audio-latency#buffer-size
    *
    *   As the buffersize can be a multiple, for not sending a buffer too small, it is get the closest
    *   multiple to the optimal buffer size.
    *
    *   If first play takes a greater latency, it will be time to implement warmup silence:
    *   https://developer.android.com/ndk/guides/audio/audio-latency#warmup-latency
    */
    this
    (
        AudioConfig cfg,
        bool hasProAudio,
        bool hasLowLatencyAudio,
        int  optimalBufferSize,
        int  optimalSampleRate
    )
    {
        this.cfg = cfg;
        import math.utils:getClosestMultiple;
        optimalBufferSize = getClosestMultiple(optimalBufferSize, AudioConfig.defaultBufferSize);
        HipOpenSLESAudioPlayer.hasProAudio = hasProAudio;
        HipOpenSLESAudioPlayer.hasLowLatencyAudio = hasLowLatencyAudio;
        HipOpenSLESAudioPlayer.optimalBufferSize = optimalBufferSize;
        HipOpenSLESAudioPlayer.optimalSampleRate = optimalSampleRate;

        HipSDL_SoundDecoder.initDecoder(cfg, optimalBufferSize);
        ErrorHandler.assertErrorMessage(sliCreateOutputContext(
            hasProAudio,
            hasLowLatencyAudio,
            optimalBufferSize,
            optimalSampleRate,
            HIP_OPENSLES_FAST_MIXER
        ),
        "Error creating OpenSLES context.", sliGetErrorMessages());
    }
    public bool isMusicPlaying(HipAudioSource src){return false;}
    public bool isMusicPaused(HipAudioSource src){return false;}
    public bool resume(HipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.resume(*source.audioPlayer);
        return false;
    }
    public bool play(HipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        static if(HIP_OPENSLES_OPTIMAL)
            uint clipSize = cast(uint)HipOpenSLESAudioPlayer.optimalBufferSize;
        else
            uint clipSize = cast(uint)src.clip.getClipSize();
        SLIAudioPlayer.play(*source.audioPlayer,
            src.clip.getClipData(),
            clipSize
        );

        return true;
    }
    public bool stop(HipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.stop(*source.audioPlayer);
        source.audioPlayer = null; //?
        return false;
    }
    public bool pause(HipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.pause(*source.audioPlayer);
        return false;
    }

    //LOAD RELATED
    public bool play_streamed(HipAudioSource src)
    {
        return play(src);
    }
    public HipAudioClip load(string path, HipAudioType type)
    {
        HipAudioClip buffer = new HipOpenSLESAudioClip(new HipSDL_SoundDecoder());
        buffer.load(path, getEncodingFromName(path), type);
        return buffer;
    }
    public HipAudioClip loadStreamed(string path, uint chunkSize)
    {
        HipAudioClip buffer = new HipOpenSLESAudioClip(new HipSDL_SoundDecoder(), chunkSize);
        buffer.loadStreamed(path, getEncodingFromName(path));
        return buffer;
    }
    void updateStream(HipAudioSource source){}
    public void updateStreamed(HipAudioSource source){}
    
    public HipAudioSource getSource(bool isStreamed)
    {
        SLIAudioPlayer* p = hipGetPlayerFromPool();
        return new HipOpenSLESAudioSource(p, isStreamed);
    }

    //EFFECTS
    public void setPitch(HipAudioSource src, float pitch){}
    public void setPanning(HipAudioSource src, float panning){}
    public void setVolume(HipAudioSource src, float volume){}
    public void setMaxDistance(HipAudioSource src, float dist){}
    public void setRolloffFactor(HipAudioSource src, float factor){}
    public void setReferenceDistance(HipAudioSource src, float dist){}

    public void onDestroy(){sliDestroyContext();}
}