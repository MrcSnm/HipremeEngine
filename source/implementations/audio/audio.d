/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.audio;

import bindbc.openal;
import bindbc.sdl.mixer;
public import implementations.audio.audiobase;
public import implementations.audio.backend.audiosource;
public import implementations.audio.backend.audioconfig;
import implementations.audio.backend.openal.player;
import implementations.audio.backend.sdl.player;
// import implementations.audio.backend.opensles.player;
import audio.audio;
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

class HipAudio
{
    public static bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OPENAL)
    {
        ErrorHandler.startListeningForErrors("HipremeAudio initialization");
        version(HIPREME_DEBUG)
        {
            hasInitializedAudio = true;
        }
        import def.debugging.log;
        HipAudio.is3D = is3D;
        config = AudioConfig.lightweightConfig;
        
        switch(implementation)
        {
            case HipAudioImplementation.OPENSLES:
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
    static HipAudioBuffer load(string path, HipAudioType bufferType, bool forceLoad = false)
    {
        //Creates a buffer compatible with the target interface
        version(HIPREME_DEBUG)
        {
            if(ErrorHandler.assertErrorMessage(hasInitializedAudio, "Audio not initialized", "Call Audio.initialize before loading buffers"))
                return null;
        }
        HipAudioBuffer* checker = null;
        checker = path in bufferPool;
        if(!checker)
        {
            HipAudioBuffer buf = audioInterface.load(path, bufferType);
            bufferPool[path] = buf;
            checker = &buf;
        }
        else if(forceLoad)
            return audioInterface.load(path, bufferType);
        return *checker;
    }

    static HipAudioSource getSource(HipAudioBuffer buff = null)
    {
        HipAudioSource ret;
        if(sourcePool.length == activeSources)
            ret = audioInterface.getSource();
        else
            ret = sourcePool[activeSources].clean();
        if(buff)
            ret.setBuffer(buff);
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
    public immutable static uint defaultBufferSize = 4096;
    private static bool is3D;
    private static HipAudioBuffer[string] bufferPool; 
    private static HipAudioSource[] sourcePool;
    private static uint activeSources;

    static IHipAudioPlayer audioInterface;

    //Debug vars
    version(HIPREME_DEBUG)
    {
        public static bool hasInitializedAudio = false;
    }
}
