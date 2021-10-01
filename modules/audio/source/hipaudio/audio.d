/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipaudio.audio;

public import hipaudio.audioclip;
public import hipaudio.audiosource;
public import data.audio.audioconfig;
public import hipengine.api.audio;
import hipaudio.backend.openal.player;
import hipaudio.backend.sdl.player;
version(Android){import hipaudio.backend.opensles.player;}
import data.audio.audio;
import math.utils:getClosestMultiple;
import util.reflection;
import error.handler;

/** 
 * This is an interface that should be created only once inside the application.
 *  Every audio function is global, meaning that every AudioSource will refer to the player
 */
public interface IHipAudioPlayer
{
    //COMMON TASK
    public bool isMusicPlaying(AHipAudioSource src);
    public bool isMusicPaused(AHipAudioSource src);
    public bool resume(AHipAudioSource src);
    public bool play(AHipAudioSource src);
    public bool stop(AHipAudioSource src);
    public bool pause(AHipAudioSource src);

    //LOAD RELATED
    public bool play_streamed(AHipAudioSource src);
    public IHipAudioClip load(string path, HipAudioType type);
    public IHipAudioClip loadStreamed(string path, uint chunkSize);
    public void updateStream(AHipAudioSource source);
    public AHipAudioSource getSource(bool isStreamed);
    public final IHipAudioClip loadMusic(string mus){return load(mus, HipAudioType.MUSIC);}
    public final IHipAudioClip loadSfx(string sfx){return load(sfx, HipAudioType.SFX);}

    //EFFECTS
    public void setPitch(AHipAudioSource src, float pitch);
    public void setPanning(AHipAudioSource src, float panning);
    public void setVolume(AHipAudioSource src, float volume);
    public void setMaxDistance(AHipAudioSource src, float dist);
    public void setRolloffFactor(AHipAudioSource src, float factor);
    public void setReferenceDistance(AHipAudioSource src, float dist);

    public void onDestroy();
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
        import console.log;
        HipAudio.is3D = is3D;
        config = AudioConfig.lightweightConfig;
        
        switch(implementation)
        {
            case HipAudioImplementation.OPENSLES:
                version(Android)
                {
                    audioInterface = new HipOpenSLESAudioPlayer(AudioConfig.lightweightConfig,
                    hasProAudio,
                    hasLowLatencyAudio,
                    optimalBufferSize,
                    optimalSampleRate);
                    break;
                }
            case HipAudioImplementation.SDL:
                audioInterface = new HipSDLAudioPlayer(AudioConfig.lightweightConfig);
                break;
            case HipAudioImplementation.OPENAL:
            default:
                //Please note that OpenAL HRTF(spatial sound) only works with Mono Channel
                audioInterface = new HipOpenALAudioPlayer(AudioConfig.musicConfig);
        }
        HipAudio.hasProAudio        = hasProAudio;
        HipAudio.hasLowLatencyAudio = hasLowLatencyAudio;
        HipAudio.optimalBufferSize  = optimalBufferSize;
        HipAudio.optimalSampleRate  = optimalSampleRate;
        return ErrorHandler.stopListeningForErrors();
    }

    @ExportD static bool play(AHipAudioSource src)
    {
        if(audioInterface.play(src))
        {
            src.isPlaying = true;
            src.time = 0;
            return true;
        }
        return false;
    }
    @ExportD static bool pause(AHipAudioSource src)
    {
        audioInterface.pause(src);
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
        audioInterface.resume(src);
        src.isPlaying = true;
        return false;
    }
    @ExportD static bool stop(AHipAudioSource src)
    {
        audioInterface.stop(src);
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
            ret.setClip(clip);
        activeSources++;
        return ret;
    }

    @ExportD static bool isMusicPlaying(HipAudioSource src)
    {
        audioInterface.isMusicPlaying(src);
        return false;
    }
    @ExportD static bool isMusicPaused(HipAudioSource src)
    {
        audioInterface.isMusicPaused(src);
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


    @ExportD static void setPitch(HipAudioSource src, float pitch)
    {
        audioInterface.setPitch(src, pitch);
        src.pitch = pitch;
    }
    @ExportD static void setPanning(HipAudioSource src, float panning)
    {
        audioInterface.setPanning(src, panning);
        src.panning = panning;
    }
    @ExportD static void setVolume(HipAudioSource src, float volume)
    {
        audioInterface.setVolume(src, volume);
        src.volume = volume;
    }
    @ExportD static void setReferenceDistance(HipAudioSource src, float dist)
    {
        audioInterface.setReferenceDistance(src, dist);
        src.referenceDistance = dist;
    }
    @ExportD static void setRolloffFactor(HipAudioSource src, float factor)
    {
        audioInterface.setRolloffFactor(src, factor);
        src.rolloffFactor = factor;
    }
    @ExportD static void setMaxDistance(HipAudioSource src, float dist)
    {
        audioInterface.setMaxDistance(src, dist);
        src.maxDistance = dist;
    }
    public static AudioConfig getConfig(){return config;}
    
    /**
    *   Call this function whenever you update any HipAudioSource property
    * without calling its setter.
    */
    @ExportD static void update(HipAudioSource src)
    {
        if(!src.isPlaying)
            HipAudio.pause(src);
        else
            HipAudio.resume(src);
        audioInterface.setMaxDistance(src, src.maxDistance);
        audioInterface.setRolloffFactor(src, src.rolloffFactor);
        audioInterface.setReferenceDistance(src, src.referenceDistance);
        audioInterface.setVolume(src, src.volume);
        audioInterface.setPanning(src, src.panning);
        audioInterface.setPitch(src, src.pitch);

    }
    protected static AudioConfig config;
    protected static bool hasProAudio;
    protected static bool hasLowLatencyAudio;
    protected static int  optimalBufferSize;
    protected static int  optimalSampleRate;
    private static bool is3D;
    private static HipAudioClip[string] bufferPool; 
    private static HipAudioSource[] sourcePool;
    private static uint activeSources;

    static IHipAudioPlayer audioInterface;

    //Debug vars
    version(HIPREME_DEBUG)
    {
        public static bool hasInitializedAudio = false;
    }
}


mixin ExportDFunctions!(hipaudio.audio);