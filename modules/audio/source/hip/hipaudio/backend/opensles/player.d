module hip.hipaudio.backend.opensles.player;


version(Android):
import opensles.sles;
import opensles.android;

import hip.hipaudio.backend.opensles.source;
import hip.hipaudio.backend.opensles.clip;
import hip.hipaudio.audiosource;
import hip.hipaudio.backend.sles;
import hip.config.opts : HIP_OPENSLES_OPTIMAL, HIP_OPENSLES_FAST_MIXER;
import hip.audio_decoding.audio;
import hip.util.conv:to;
import hip.error.handler;
import hip.hipaudio.audio;


version(OpenSLES1)
    alias SLDataFormat = SLDataFormat_PCM;
else
    alias SLDataFormat = SLAndroidDataFormat_PCM_EX;

private SLDataFormat getFormatAsOpenSLES(AudioConfig cfg)
{
    SLDataFormat ret;
    version(OpenSLES1)
        ret.formatType = SL_DATAFORMAT_PCM;
    else
        ret.formatType = SL_ANDROID_DATAFORMAT_PCM_EX;

    ret.numChannels = cfg.channels; //2 channels seems to not be supported yet

    static if(HIP_OPENSLES_OPTIMAL)
        ret.samplesPerSec = HipOpenSLESAudioPlayer.optimalSampleRate*1000;
    else
        ret.samplesPerSec = cfg.sampleRate*1000;

    switch(cfg.format)
    {
        //Big
        case AudioFormat.signed16Big:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.endianness = SL_BYTEORDER_BIGENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_SIGNED_INT;
            break;
        case AudioFormat.signed32Big:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.endianness = SL_BYTEORDER_BIGENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_SIGNED_INT;
            break;
        case AudioFormat.signed8:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_8;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_8;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_SIGNED_INT;
            break;
        default:
        case AudioFormat.signed16Little:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_SIGNED_INT;
            break;
        case AudioFormat.signed32Little:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_SIGNED_INT;
            break;
        //Little
        case AudioFormat.float32Little:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_FLOAT;
            else
                ErrorHandler.assertExit(false, "Needs OpenSLES 1.1 (Achieved by -version=OpenSLES1_1) to support float PCM");
            break;
        case AudioFormat.float32Big:
            ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
            ret.endianness = SL_BYTEORDER_BIGENDIAN;
            version(OpenSLES1_1)
                ret.representation = SL_ANDROID_PCM_REPRESENTATION_FLOAT;
            else
                ErrorHandler.assertExit(false, "Needs OpenSLES 1.1 (Achieved by -version=OpenSLES1_1) to support float PCM");
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


/**
*   If wish to use fast mixer, this function should only create
*   players with the same stats from the android output
*/
package SLIAudioPlayer* hipGenAudioPlayer()
{
    SLDataFormat fmt = HipOpenSLESAudioPlayer.config.getFormatAsOpenSLES();
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

    SLIAudioPlayer* player = sliGenAudioPlayer(src, destination);
    if(player == null)
        ErrorHandler.showErrorMessage("SLIAudioPlayer creation error:", sliGetErrorMessages());

    return player;
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
    static AudioConfig config;
    SLIOutputMix output;
    SLEngineItf itf;

    static bool hasProAudio;
    static bool hasLowLatencyAudio;
    static int  optimalBufferSize;
    static int  optimalSampleRate;

    protected SLIAudioPlayer*[] spawnedPlayers;

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
        import hip.math.utils:getClosestMultiple;
        import hip.console.log;
        optimalBufferSize = getClosestMultiple(optimalBufferSize, AudioConfig.defaultBufferSize);
        HipOpenSLESAudioPlayer.hasProAudio = hasProAudio;
        HipOpenSLESAudioPlayer.hasLowLatencyAudio = hasLowLatencyAudio;
        HipOpenSLESAudioPlayer.optimalBufferSize = optimalBufferSize;
        HipOpenSLESAudioPlayer.optimalSampleRate = optimalSampleRate;
        static if(HIP_OPENSLES_OPTIMAL)
            cfg.sampleRate = optimalSampleRate;
        config = cfg;


        logln("OpenSL ES Initialization with:
hasProAudio? ", hasProAudio, "
hasLowLatencyAudio? ", hasLowLatencyAudio, "
optimalBufferSize: ", optimalBufferSize, " 
outputSampleRate: ", cfg.sampleRate);

        

        // HipSDL_SoundDecoder.initDecoder(cfg, optimalBufferSize);
        ErrorHandler.assertErrorMessage(sliCreateOutputContext(
            hasProAudio,
            hasLowLatencyAudio,
            optimalBufferSize,
            config.sampleRate,
            HIP_OPENSLES_FAST_MIXER
        ),
        "Error creating OpenSLES context.", sliGetErrorMessages());
    }
    public bool isMusicPlaying(AHipAudioSource src)
    {
        return (cast(HipOpenSLESAudioSource)src).audioPlayer.isPlaying;
    }
    public bool isMusicPaused(AHipAudioSource src){return false;}
    public bool resume(AHipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.resume(*source.audioPlayer);
        return false;
    }
    public bool play(AHipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.play(*source.audioPlayer);

        return true;
    }
    public bool stop(AHipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.stop(*source.audioPlayer);
        source.audioPlayer = null; //?
        return false;
    }
    public bool pause(AHipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        SLIAudioPlayer.pause(*source.audioPlayer);
        return false;
    }

    //LOAD RELATED
    public bool play_streamed(AHipAudioSource src)
    {
        HipOpenSLESAudioSource source = cast(HipOpenSLESAudioSource)src;
        static if(HIP_OPENSLES_OPTIMAL)
            uint clipSize = cast(uint)HipOpenSLESAudioPlayer.optimalBufferSize;
        else
            uint clipSize = cast(uint)src.clip.getClipSize();

        SLIAudioPlayer.play(*source.audioPlayer);
        return true;
    }
    public HipAudioClipAPI load(string path, HipAudioType type)
    {
        HipAudioClipAPI buffer = new HipOpenSLESAudioClip(new HipAudioDecoder(), HipAudioClipHint(config.channels, config.sampleRate, false, true));
        buffer.load(path, getEncodingFromName(path), type);
        return buffer;
    }
    public HipAudioClipAPI loadStreamed(string path, uint chunkSize)
    {
        HipAudioClipAPI buffer = new HipOpenSLESAudioClip(new HipAudioDecoder(), HipAudioClipHint(config.channels, config.sampleRate, false, true), chunkSize);
        buffer.loadStreamed(path, getEncodingFromName(path));
        return buffer;
    }
    void updateStream(AHipAudioSource source){}
    public void updateStreamed(AHipAudioSource source){}
    
    public AHipAudioSource getSource(bool isStreamed)
    {
        SLIAudioPlayer* p = hipGetPlayerFromPool();
        spawnedPlayers~= p;
        return new HipOpenSLESAudioSource(p, isStreamed);
    }

    public void onDestroy(){sliDestroyContext();}

    public void update()
    {
        foreach(p; spawnedPlayers)
            p.update();
    }
}