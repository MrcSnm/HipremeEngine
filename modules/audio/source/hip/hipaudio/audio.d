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

public import hip.hipaudio.audioclip;
public import hip.hipaudio.audiosource;
public import hip.api.audio;

//Backends
version(OpenAL){import hip.hipaudio.backend.openal.player;}
version(Android){import hip.hipaudio.backend.opensles.player;}
version(XAudio2){import hip.hipaudio.backend.xaudio.player;}


import hip.audio_decoding.audio;
import hip.math.utils:getClosestMultiple;
import hip.util.reflection;
import hip.error.handler;

version(Standalone)
{
    alias HipAudioSourceAPI = HipAudioSource;
    alias HipAudioClipAPI = HipAudioClip;
}
else
{
    alias HipAudioSourceAPI = AHipAudioSource;
    alias HipAudioClipAPI = IHipAudioClip;
}

/** 
 * This is an interface that should be created only once inside the application.
 *  Every audio function is global, meaning that every AudioSource will refer to the player
 */
public interface IHipAudioPlayer
{
    //LOAD RELATED
    public bool play_streamed(AHipAudioSource src);
    public IHipAudioClip load(string path, HipAudioType type);
    public IHipAudioClip loadStreamed(string path, uint chunkSize);
    public void updateStream(AHipAudioSource source);
    public AHipAudioSource getSource(bool isStreamed);
    public final IHipAudioClip loadMusic(string mus){return load(mus, HipAudioType.MUSIC);}
    public final IHipAudioClip loadSfx(string sfx){return load(sfx, HipAudioType.SFX);}


    public void onDestroy();
    public void update();
}

class HipAudio
{
    public static bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OPENAL,
    bool hasProAudio = false,
    bool hasLowLatencyAudio = false,
    int  optimalBufferSize = 4096,
    int optimalSampleRate = 44_100)
    {
        ErrorHandler.startListeningForErrors("HipremeAudio initialization");
        version(HIPREME_DEBUG)
        {
            hasInitializedAudio = true;
        }
        import hip.console.log;
        HipAudio.is3D = is3D;
        
        final switch(implementation)
        {
            case HipAudioImplementation.OPENSLES:
                version(Android)
                {
                    audioInterface = new HipOpenSLESAudioPlayer(AudioConfig.androidConfig,
                    hasProAudio,
                    hasLowLatencyAudio,
                    optimalBufferSize,
                    optimalSampleRate);
                    break;
                }
            case HipAudioImplementation.XAUDIO2:
                version(XAudio2)
                {
                    loglnInfo("Initializing XAudio2 with audio config ", AudioConfig.musicConfig);
                    audioInterface = new HipXAudioPlayer(AudioConfig.musicConfig);
                    break;
                }
                else 
                {
                    loglnWarn("Tried to use XAudio2 implementation, but no XAudio2 version was provided. OpenAL will be used instead");
                    goto case HipAudioImplementation.OPENAL;
                }
            case HipAudioImplementation.OPENAL:
            {
                version(OpenAL)
                {
                    //Please note that OpenAL HRTF(spatial sound) only works with Mono Channel
                    audioInterface = new HipOpenALAudioPlayer(AudioConfig.musicConfig);
                    break;
                }
                else
                {
                    loglnWarn("Tried to use OpenAL implementation, but no OpenAL version was provided. No audio available.");
                    break;
                }
            }
        }
        HipAudio.hasProAudio        = hasProAudio;
        HipAudio.hasLowLatencyAudio = hasLowLatencyAudio;
        HipAudio.optimalBufferSize  = optimalBufferSize;
        HipAudio.optimalSampleRate  = optimalSampleRate;
        return ErrorHandler.stopListeningForErrors();
    }

    @ExportD static bool play(AHipAudioSource src)
    {
        return false;
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
    @ExportD static bool resume(AHipAudioSource src)
    {
        src.isPlaying = true;
        return false;
    }
    @ExportD static bool stop(AHipAudioSource src)
    {
        return false;
    }

    /**
    *   If forceLoad is set to true, you will need to manage it's destruction yourself
    *   Just call audioBufferInstance.unload()
    */
    @ExportD static IHipAudioClip load(string path, HipAudioType bufferType, bool forceLoad = false)
    {
        //Creates a buffer compatible with the target interface
        version(HIPREME_DEBUG)
        {
            if(ErrorHandler.assertErrorMessage(hasInitializedAudio, "Audio not initialized", "Call Audio.initialize before loading buffers"))
                return null;
        }
        HipAudioClip* checker = null;
        checker = path in bufferPool;
        if(!checker)
        {
            HipAudioClip buf = cast(HipAudioClip)audioInterface.load(path, bufferType);
            bufferPool[path] = buf;
            checker = &buf;
        }
        else if(forceLoad)
            return audioInterface.load(path, bufferType);
        return *checker;
    }
    /**
    *   Loads a file from disk, sets the chunkSize for streaming and does one decoding frame
    */
    @ExportD static IHipAudioClip loadStreamed(string path, uint chunkSize = ushort.max+1)
    {
        chunkSize = getClosestMultiple(optimalBufferSize, chunkSize);
        HipAudioClip buf = cast(HipAudioClip)audioInterface.loadStreamed(path, chunkSize);
        return buf;
    }

    @ExportD static void updateStream(HipAudioSource source)
    {
        audioInterface.updateStream(source);
    }
    @ExportD static AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null)
    {
        if(isStreamed) ErrorHandler.assertExit(clip !is null, "Can't get streamed source without any buffer");
        HipAudioSource ret;
        if(sourcePool.length == activeSources)
        {
            ret = cast(HipAudioSource)audioInterface.getSource(isStreamed);
            sourcePool~= ret;
        }
        else
            ret = sourcePool[activeSources].clean();
        if(clip)
            ret.clip = clip;
        activeSources++;
        return ret;
    }

    @ExportD static bool isMusicPlaying()
    {
        return false;
    }
    @ExportD static bool isMusicPaused()
    {
        return false;
    }
    
    @ExportD static void onDestroy()
    {
        foreach(ref buf; bufferPool)
            buf.unload();
        bufferPool.clear();
        if(audioInterface !is null)
            audioInterface.onDestroy();
        audioInterface = null;
    }

    static void update()
    {
        if(audioInterface !is null)
            audioInterface.update();
    }


   
    protected static bool hasProAudio;
    protected static bool hasLowLatencyAudio;
    protected static int  optimalBufferSize;
    protected static int  optimalSampleRate;
    private static bool is3D;
    private static HipAudioClip[string] bufferPool; 
    private static HipAudioSource[] sourcePool;
    private static uint activeSources;

    __gshared IHipAudioPlayer audioInterface;

    //Debug vars
    version(HIPREME_DEBUG)
    {
        public static bool hasInitializedAudio = false;
    }
}