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
public import hip.audio_decoding.config;
public import hip.api.audio;

//Backends
import hip.hipaudio.backend.openal.player;
import hip.hipaudio.backend.sdl.player;
version(Android){import hip.hipaudio.backend.opensles.player;}
version(Windows){import hip.hipaudio.backend.xaudio.player;}


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
    //COMMON TASK
    public bool isMusicPlaying(HipAudioSourceAPI src);
    public bool isMusicPaused(HipAudioSourceAPI src);
    public bool resume(HipAudioSourceAPI src);
    public bool play(HipAudioSourceAPI src);
    public bool stop(HipAudioSourceAPI src);
    public bool pause(HipAudioSourceAPI src);

    //LOAD RELATED
    public bool play_streamed(HipAudioSourceAPI src);
    public HipAudioClipAPI load(string path, HipAudioType type);
    public HipAudioClipAPI loadStreamed(string path, uint chunkSize);
    public void updateStream(HipAudioSourceAPI source);
    public HipAudioSourceAPI getSource(bool isStreamed);
    public final HipAudioClipAPI loadMusic(string mus){return load(mus, HipAudioType.MUSIC);}
    public final HipAudioClipAPI loadSfx(string sfx){return load(sfx, HipAudioType.SFX);}

    //EFFECTS
    public void setPitch(HipAudioSourceAPI src, float pitch);
    public void setPanning(HipAudioSourceAPI src, float panning);
    public void setVolume(HipAudioSourceAPI src, float volume);
    public void setMaxDistance(HipAudioSourceAPI src, float dist);
    public void setRolloffFactor(HipAudioSourceAPI src, float factor);
    public void setReferenceDistance(HipAudioSourceAPI src, float dist);

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
        import hip.console.log;
        HipAudio.is3D = is3D;
        config = AudioConfig.lightweightConfig;

        implementation = HipAudioImplementation.OPENAL;
        
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
            case HipAudioImplementation.XAUDIO2:
                version(DirectX)
                {
                    audioInterface = new HipXAudioPlayer(AudioConfig.musicConfig);
                    break;
                }
                else 
                {
                    goto case HipAudioImplementation.OPENAL;
                }
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

    @ExportD static bool play(HipAudioSourceAPI src)
    {
        if(audioInterface.play(src))
        {
            src.isPlaying = true;
            src.time = 0;
            return true;
        }
        return false;
    }
    @ExportD static bool pause(HipAudioSourceAPI src)
    {
        audioInterface.pause(src);
        src.isPlaying = false;
        return false;
    }
    @ExportD static bool play_streamed(HipAudioSourceAPI src)
    {
        audioInterface.play_streamed(src);
        src.isPlaying = true;
        return false;
    }
    @ExportD static bool resume(HipAudioSourceAPI src)
    {
        audioInterface.resume(src);
        src.isPlaying = true;
        return false;
    }
    @ExportD static bool stop(HipAudioSourceAPI src)
    {
        audioInterface.stop(src);
        return false;
    }

    /**
    *   If forceLoad is set to true, you will need to manage it's destruction yourself
    *   Just call audioBufferInstance.unload()
    */
    @ExportD static HipAudioClipAPI load(string path, HipAudioType bufferType, bool forceLoad = false)
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
    @ExportD static HipAudioClipAPI loadStreamed(string path, uint chunkSize = ushort.max+1)
    {
        chunkSize = getClosestMultiple(optimalBufferSize, chunkSize);
        HipAudioClip buf = cast(HipAudioClip)audioInterface.loadStreamed(path, chunkSize);
        return buf;
    }

    @ExportD static void updateStream(HipAudioSource source)
    {
        audioInterface.updateStream(source);
    }
    @ExportD static HipAudioSourceAPI getSource(bool isStreamed = false, HipAudioClipAPI clip = null)
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