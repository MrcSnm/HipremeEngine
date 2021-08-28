/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hipaudio.audio;

import bindbc.openal;
import bindbc.sdl.mixer;
public import hipaudio.audioclip;
public import hipaudio.backend.audiosource;
public import data.audio.audioconfig;
import hipaudio.backend.openal.player;
import hipaudio.backend.sdl.player;
version(Android){import hipaudio.backend.opensles.player;}
import data.audio.audio;
import error.handler;

/**
* Controls how the gain will falloff
*/
enum DistanceModel
{
    DISTANCE_MODEL,
    /**
    * Very similar to the exponential curve
    */
    INVERSE,
    INVERSE_CLAMPED,
    /**
    * Linear curve, the only which can achieve 0 volume
    */
    LINEAR,
    LINEAR_CLAMPED,

    /**
    * Exponential curve for the model
    */
    EXPONENT,
    /**
    * When the distance is below the reference, it will clamp the volume to 1
    * When the distance is higher than max distance, it will not decrease volume any longer
    */
    EXPONENT_CLAMPED
}

enum HipAudioImplementation
{
    OPENAL,
    SDL,
    OPENSLES
}

/** 
 * This is an interface that should be created only once inside the application.
 *  Every audio function is global, meaning that every AudioSource will refer to the player
 */
public interface IHipAudioPlayer
{
    //COMMON TASK
    public bool isMusicPlaying(HipAudioSource src);
    public bool isMusicPaused(HipAudioSource src);
    public bool resume(HipAudioSource src);
    public bool play(HipAudioSource src);
    public bool stop(HipAudioSource src);
    public bool pause(HipAudioSource src);

    //LOAD RELATED
    public bool play_streamed(HipAudioSource src);
    public HipAudioClip load(string path, HipAudioType type);
    public HipAudioClip loadStreamed(string path, uint chunkSize);
    public void updateStream(HipAudioSource source);
    public HipAudioSource getSource(bool isStreamed);
    public final HipAudioClip loadMusic(string mus){return load(mus, HipAudioType.MUSIC);}
    public final HipAudioClip loadSfx(string sfx){return load(sfx, HipAudioType.SFX);}

    //EFFECTS
    public void setPitch(HipAudioSource src, float pitch);
    public void setPanning(HipAudioSource src, float panning);
    public void setVolume(HipAudioSource src, float volume);
    public void setMaxDistance(HipAudioSource src, float dist);
    public void setRolloffFactor(HipAudioSource src, float factor);
    public void setReferenceDistance(HipAudioSource src, float dist);

    public void onDestroy();
}

class HipAudio
{
    public static bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OPENAL)
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
                    audioInterface = new HipOpenSLESAudioPlayer(AudioConfig.lightweightConfig);
                    break;
                }
            case HipAudioImplementation.SDL:
                audioInterface = new HipSDLAudioPlayer(AudioConfig.lightweightConfig);
                break;
            case HipAudioImplementation.OPENAL:
            default:
                //Please note that OpenAL HRTF(spatial sound) only works with Mono Channel
                audioInterface = new HipOpenALAudioPlayer(AudioConfig.lightweightConfig);
        }
        
        return ErrorHandler.stopListeningForErrors();
    }

    static bool play(HipAudioSource src)
    {
        if(audioInterface.play(src))
        {
            src.isPlaying = true;
            src.time = 0;
            return true;
        }
        return false;
    }
    static bool pause(HipAudioSource src)
    {
        audioInterface.pause(src);
        src.isPlaying = false;
        return false;
    }
    static bool play_streamed(HipAudioSource src)
    {
        audioInterface.play_streamed(src);
        src.isPlaying = true;
        return false;
    }
    static bool resume(HipAudioSource src)
    {
        audioInterface.resume(src);
        src.isPlaying = true;
        return false;
    }
    static bool stop(HipAudioSource src)
    {
        audioInterface.stop(src);
        return false;
    }


    /**
    *   If forceLoad is set to true, you will need to manage it's destruction yourself
    *   Just call audioBufferInstance.unload()
    */
    static HipAudioClip load(string path, HipAudioType bufferType, bool forceLoad = false)
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
            HipAudioClip buf = audioInterface.load(path, bufferType);
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
    static HipAudioClip loadStreamed(string path, uint chunkSize)
    {
        HipAudioClip buf = audioInterface.loadStreamed(path, chunkSize);
        return buf;
    }

    static void updateStream(HipAudioSource source)
    {
        audioInterface.updateStream(source);
    }

    static HipAudioSource getSource(bool isStreamed = false, HipAudioClip clip = null)
    {
        if(isStreamed) assert(clip !is null, "Can't get streamed source without any buffer");
        HipAudioSource ret;
        if(sourcePool.length == activeSources)
        {
            ret = audioInterface.getSource(isStreamed);
            sourcePool~= ret;
        }
        else
            ret = sourcePool[activeSources].clean();
        if(clip)
            ret.setClip(clip);
        activeSources++;
        return ret;
    }

    static bool isMusicPlaying(HipAudioSource src)
    {
        audioInterface.isMusicPlaying(src);
        return false;
    }
    static bool isMusicPaused(HipAudioSource src)
    {
        audioInterface.isMusicPaused(src);
        return false;
    }
    
    static void onDestroy()
    {
        foreach(ref buf; bufferPool)
            buf.unload();
        bufferPool.clear();
        if(audioInterface !is null)
            audioInterface.onDestroy();
        audioInterface = null;
    }


    static void setPitch(HipAudioSource src, float pitch)
    {
        audioInterface.setPitch(src, pitch);
        src.pitch = pitch;
    }
    static void setPanning(HipAudioSource src, float panning)
    {
        audioInterface.setPanning(src, panning);
        src.panning = panning;
    }
    static void setVolume(HipAudioSource src, float volume)
    {
        audioInterface.setVolume(src, volume);
        src.volume = volume;
    }
    public static void setReferenceDistance(HipAudioSource src, float dist)
    {
        audioInterface.setReferenceDistance(src, dist);
        src.referenceDistance = dist;
    }
    public static void setRolloffFactor(HipAudioSource src, float factor)
    {
        audioInterface.setRolloffFactor(src, factor);
        src.rolloffFactor = factor;
    }
    public static void setMaxDistance(HipAudioSource src, float dist)
    {
        audioInterface.setMaxDistance(src, dist);
        src.maxDistance = dist;
    }
    public static AudioConfig getConfig(){return config;}
    
    /**
    *   Call this function whenever you update any HipAudioSource property
    * without calling its setter.
    */
    public static void update(HipAudioSource src)
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
        // float* pos;
        // alGetSourcef(src.id, AL_POSITION, pos);

    }
    protected static AudioConfig config;
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
