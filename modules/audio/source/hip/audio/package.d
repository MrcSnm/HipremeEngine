/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.audio;

public import hip.audio.audiosource;
public import hip.api.audio : HipAudioType, DistanceModel, HipAudioImplementation, getAudioImplementationForOS, IHipAudioPlayer, setIHipAudioPlayer;
import hip.config.audio;

//Backends
import hip.audio_decoding.audio;
import hip.math.utils:getClosestMultiple;
import hip.error.handler;

class HipAudioImpl : IHipAudioPlayer
{
    public bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OpenAL,
    bool hasProAudio = false,
    bool hasLowLatencyAudio = false,
    int  optimalBufferSize = 4096,
    int optimalSampleRate = 44_100)
    {
        import hip.console.log;
        ErrorHandler.startListeningForErrors("HipremeAudio initialization");
        _hasInitializedAudio = true;
        this.is3D = is3D;
        audioInterface = getAudioInterface(implementation);
        this.hasProAudio        = hasProAudio;
        this.hasLowLatencyAudio = hasLowLatencyAudio;
        this.optimalBufferSize  = optimalBufferSize;
        this.optimalSampleRate  = optimalSampleRate;

        loglnInfo("Hipreme Audio Started: ", implementation,
            "\nPro Audio: ", hasProAudio,
            "\nLow Latency: ", hasLowLatencyAudio,
            "\nOptimal Buffer Size: ", optimalBufferSize,
            "\nOptimal Sample Rate: ", optimalSampleRate
        );
        return ErrorHandler.stopListeningForErrors();
    }
    bool pause(AHipAudioSource src)
    {
        src.isPlaying = false;
        return false;
    }
    bool play_streamed(AHipAudioSource src)
    {
        audioInterface.play_streamed(src);
        src.isPlaying = true;
        return false;
    }
    IHipAudioClip getClip(){return audioInterface.getClip();}

    /**
    *   Loads a file from disk, sets the chunkSize for streaming and does one decoding frame
    */
    IHipAudioClip loadStreamed(string path, uint chunkSize = ushort.max+1)
    {
        chunkSize = getClosestMultiple(optimalBufferSize, chunkSize);
        IHipAudioClip buf = audioInterface.loadStreamed(path, chunkSize);
        return buf;
    }

    void updateStream(AHipAudioSource source)
    {
        audioInterface.updateStream(source);
    }
    AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null)
    {
        if(isStreamed) ErrorHandler.assertExit(clip !is null, "Can't get streamed source without any buffer");
        HipAudioSource ret = cast(HipAudioSource)audioInterface.getSource(isStreamed);
        if(clip)
            ret.clip = clip;
        return ret;
    }
    void onDestroy()
    {
        if(audioInterface !is null)
            audioInterface.onDestroy();
        audioInterface = null;
    }

    void update()
    {
        if(audioInterface !is null)
            audioInterface.update();
    }

    private static IHipAudioPlayer getAudioInterface(HipAudioImplementation impl,
    bool hasProAudio = false,
    bool hasLowLatencyAudio = false,
    int  optimalBufferSize = 4096,
    int optimalSampleRate = 44_100)
    {
        import hip.console.log;
        final switch(impl)
        {
            case HipAudioImplementation.WebAudio:
            {
                static if(HasWebAudio)
                {
                    import hip.audio.backend.webaudio.player;
                    return new HipWebAudioPlayer(AudioConfig.musicConfig);
                }
                else
                {
                    loglnWarn("Tried to use WebAudio implementation, but not in WebAssembly. No audio available");
                    goto case HipAudioImplementation.Null;
                }
            }
            case HipAudioImplementation.OpenSLES:
                static if(HasOpenSLES)
                {
                    import hip.audio.backend.opensles.player;
                    return new HipOpenSLESAudioPlayer(AudioConfig.androidConfig,
                    hasProAudio,
                    hasLowLatencyAudio,
                    optimalBufferSize,
                    optimalSampleRate);
                    break;
                }
            case HipAudioImplementation.XAudio2:
                static if(HasXAudio2)
                {
                    import hip.audio.backend.xaudio.player;
                    loglnInfo("Initializing XAudio2 with audio config ", AudioConfig.musicConfig);
                    return new HipXAudioPlayer(AudioConfig.musicConfig);
                }
                else 
                {
                    loglnWarn("Tried to use XAudio2 implementation, but no XAudio2 version was provided. OpenAL will be used instead");
                    goto case HipAudioImplementation.OpenAL;
                }
            case HipAudioImplementation.AVAudioEngine:
            {
                static if(HasAVAudioEngine)
                {
                    import hip.audio.backend.avaudio.player;
                    return new HipAVAudioPlayer(AudioConfig.androidConfig);
                }
                else
                {
                    loglnWarn("Tried to use AVAudioEngine implementation, but no AVAudioEngine found. OpenAL will be used instead");
                    goto case HipAudioImplementation.OpenAL;
                }
            }
            case HipAudioImplementation.OpenAL:
            {
                static if(HasOpenAL)
                {
                    import hip.audio.backend.openal.player;
                    //Please note that OpenAL HRTF(spatial sound) only works with Mono Channel
                    return new HipOpenALAudioPlayer(AudioConfig.musicConfig);
                }
                else
                {
                    loglnWarn("Tried to use OpenAL implementation, but no OpenAL version was provided. No audio available.");
                    goto case HipAudioImplementation.Null;
                }
            }
            case HipAudioImplementation.Null:
            {
                import hip.audio.backend.nullaudio;
                loglnWarn("No AudioInterface was found. Using NullAudio");
                return new HipNullAudio();
            }
        }
    }


   
    protected bool hasProAudio;
    protected bool hasLowLatencyAudio;
    protected int  optimalBufferSize;
    protected int  optimalSampleRate;
    private   bool is3D;
    private   uint activeSources;

    IHipAudioPlayer audioInterface;

    //Debug vars
    private bool _hasInitializedAudio = false;
    public bool hasInitializedAudio() => _hasInitializedAudio;
}


private __gshared HipAudioImpl player;
void PreInitializeHipAudio()
{
    player = new HipAudioImpl();
    setIHipAudioPlayer(player);
}

pragma(inline, true)
HipAudioImpl HipAudio(){return player;}

export extern(C) IHipAudioPlayer HipAudioPlayerAPI()
{
    return player;
}