/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hipaudio.audio;

public import hip.hipaudio.audiosource;
public import hip.api.audio;
import hip.hipaudio.config;

//Backends



import hip.audio_decoding.audio;
import hip.math.utils:getClosestMultiple;
import hip.util.reflection;
import hip.error.handler;


/** 
 * This is an interface that should be created only once inside the application.
 *  Every audio function is global, meaning that every AudioSource will refer to the player
 */
public interface IHipAudioPlayer
{
    //LOAD RELATED
    public bool play_streamed(AHipAudioSource src);
    public IHipAudioClip getClip();
    public IHipAudioClip loadStreamed(string path, uint chunkSize);
    public void updateStream(AHipAudioSource source);
    public AHipAudioSource getSource(bool isStreamed);

    public void onDestroy();
    public void update();
}

class HipAudio
{
    public static bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OpenAL,
    bool hasProAudio = false,
    bool hasLowLatencyAudio = false,
    int  optimalBufferSize = 4096,
    int optimalSampleRate = 44_100)
    {
        ErrorHandler.startListeningForErrors("HipremeAudio initialization");
        _hasInitializedAudio = true;
        HipAudio.is3D = is3D;
        audioInterface = getAudioInterface(implementation);
        HipAudio.hasProAudio        = hasProAudio;
        HipAudio.hasLowLatencyAudio = hasLowLatencyAudio;
        HipAudio.optimalBufferSize  = optimalBufferSize;
        HipAudio.optimalSampleRate  = optimalSampleRate;
        return ErrorHandler.stopListeningForErrors();
    }
    @ExportD static bool pause(AHipAudioSource src)
    {
        src.isPlaying = false;
        return false;
    }
    @ExportD static bool play_streamed(AHipAudioSource src)
    {
        audioInterface.play_streamed(src);
        src.isPlaying = true;
        return false;
    }
    @ExportD static IHipAudioClip getClip(){return audioInterface.getClip();}

    /**
    *   Loads a file from disk, sets the chunkSize for streaming and does one decoding frame
    */
    @ExportD static IHipAudioClip loadStreamed(string path, uint chunkSize = ushort.max+1)
    {
        chunkSize = getClosestMultiple(optimalBufferSize, chunkSize);
        IHipAudioClip buf = audioInterface.loadStreamed(path, chunkSize);
        return buf;
    }

    @ExportD static void updateStream(HipAudioSource source)
    {
        audioInterface.updateStream(source);
    }
    @ExportD static AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null)
    {
        if(isStreamed) ErrorHandler.assertExit(clip !is null, "Can't get streamed source without any buffer");
        HipAudioSource ret = cast(HipAudioSource)audioInterface.getSource(isStreamed);
        if(clip)
            ret.clip = clip;
        return ret;
    }
    @ExportD static void onDestroy()
    {
        if(audioInterface !is null)
            audioInterface.onDestroy();
        audioInterface = null;
    }

    static void update()
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
                    import hip.hipaudio.backend.webaudio.player;
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
                    import hip.hipaudio.backend.opensles.player;
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
                    import hip.hipaudio.backend.xaudio.player;
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
                    import hip.hipaudio.backend.avaudio.player;
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
                    import hip.hipaudio.backend.openal.player;
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
                import hip.hipaudio.backend.nullaudio;
                loglnWarn("No AudioInterface was found. Using NullAudio");
                return new HipNullAudio();
            }
        }
    }


   
    protected __gshared bool hasProAudio;
    protected __gshared bool hasLowLatencyAudio;
    protected __gshared int  optimalBufferSize;
    protected __gshared int  optimalSampleRate;
    private   __gshared bool is3D;
    private   __gshared uint activeSources;

    __gshared IHipAudioPlayer audioInterface;

    //Debug vars
    private __gshared bool _hasInitializedAudio = false;
    public bool hasInitializedAudio() => _hasInitializedAudio;
}