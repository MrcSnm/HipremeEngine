module implementations.audio.audio;

import bindbc.openal;
import bindbc.sdl.mixer;
public import implementations.audio.audiobase;
public import implementations.audio.backend.audiosource;
public import implementations.audio.backend.audioconfig;
import implementations.audio.backend.audio2d;
import implementations.audio.backend.audio3d;
import sdl.sdl_sound;
import error.handler;


class Audio
{
    public static bool initialize(bool is3D = true)
    {
        version(HIPREME_DEBUG)
        {
            hasInitializedAudio = true;
        }
        Audio.is3D = is3D;
        ErrorHandler.assertErrorMessage(loadSDLSound(), "Error Loading SDL_Sound", "SDL_Sound not found");
        if(is3D)
        {
            ErrorHandler.startListeningForErrors("HipremeAudio3D initialization");
            ALSupport sup = loadOpenAL();
            if(ErrorHandler.assertErrorMessage(sup == ALSupport.al11, "Error loading OpenAL", "No OpenAL support found"))
            {
                if(sup == ALSupport.badLibrary)
                    ErrorHandler.showErrorMessage("Bad OpenAL Support", "Unknown version of OpenAL");
                else
                    ErrorHandler.showErrorMessage("OpenAL not found", "Could not find OpenAL library");
            }
            //Please note that OpenAL HRTF(spatial sound) only works with Mono Channel
            audioInterface = new Audio3DBackend(AudioConfig.lightweightConfig);
        }
        else
        {
            ErrorHandler.startListeningForErrors("HipremeAudio2D initialization");
            SDLMixerSupport sup = loadSDLMixer();
            if(sup == SDLMixerSupport.badLibrary)
                ErrorHandler.showErrorMessage("Bad SDL_Mixer support", "Unknown version of SDL_Mixer");
            else if(sup == SDLMixerSupport.noLibrary)
                ErrorHandler.showErrorMessage("No SDL_Mixer found", "Could not find any SDL_Mixer version");
            // ErrorHandler.assertErrorMessage(Mix_OpenAudio(44100));

            audioInterface = new Audio2DBackend(AudioConfig.lightweightConfig);
        }

        return ErrorHandler.stopListeningForErrors();
    }

    static bool play(AudioSource src)
    {
        if(audioInterface.play(src))
        {
            src.isPlaying = true;
            src.time = 0;
            return true;
        }
        return false;
    }
    static bool pause(AudioSource src)
    {
        audioInterface.pause(src);
        src.isPlaying = false;
        return false;
    }
    static bool play_streamed(AudioSource src)
    {
        audioInterface.play_streamed(src);
        src.isPlaying = true;
        return false;
    }
    static bool resume(AudioSource src)
    {
        audioInterface.resume(src);
        src.isPlaying = true;
        return false;
    }
    static bool stop(AudioSource src)
    {
        audioInterface.stop(src);
        return false;
    }


    /**
    *   If forceLoad is set to true, you will need to manage it's destruction yourself
    *   Just call audioBufferInstance.unload()
    */
    static AudioBuffer load(string path, AudioBuffer.TYPE bufferType, bool forceLoad = false)
    {
        //Creates a buffer compatible with the target interface
        version(HIPREME_DEBUG)
        {
            if(ErrorHandler.assertErrorMessage(hasInitializedAudio, "Audio not initialized", "Call Audio.initialize before loading buffers"))
                return null;
        }
        AudioBuffer* checker = null;
        checker = path in bufferPool;
        if(!checker)
        {
            AudioBuffer buf = audioInterface.load(path, bufferType);
            bufferPool[path] = buf;
            checker = &buf;
        }
        else if(forceLoad)
            return audioInterface.load(path, bufferType);
        return *checker;
    }

    static AudioSource getSource(AudioBuffer buff = null)
    {
        AudioSource ret;
        if(sourcePool.length == activeSources)
            ret = audioInterface.getSource();
        else
            ret = sourcePool[activeSources].clean();
        if(buff)
            ret.setBuffer(buff);
        activeSources++;
        return ret;
    }

    static bool isMusicPlaying(AudioSource src)
    {
        audioInterface.isMusicPlaying(src);
        return false;
    }
    static bool isMusicPaused(AudioSource src)
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


    static void setPitch(AudioSource src, float pitch)
    {
        audioInterface.setPitch(src, pitch);
        src.pitch = pitch;
    }
    static void setPanning(AudioSource src, float panning)
    {
        audioInterface.setPanning(src, panning);
        src.panning = panning;
    }
    static void setVolume(AudioSource src, float volume)
    {
        audioInterface.setVolume(src, volume);
        src.volume = volume;
    }
    public static void setReferenceDistance(AudioSource src, float dist)
    {
        audioInterface.setReferenceDistance(src, dist);
        src.referenceDistance = dist;
    }
    public static void setRolloffFactor(AudioSource src, float factor)
    {
        audioInterface.setRolloffFactor(src, factor);
        src.rolloffFactor = factor;
    }
    public static void setMaxDistance(AudioSource src, float dist)
    {
        audioInterface.setMaxDistance(src, dist);
        src.maxDistance = dist;
    }

    public static void update(AudioSource src)
    {
        if(!src.isPlaying)
            Audio.pause(src);
        else
            Audio.resume(src);
        audioInterface.setMaxDistance(src, src.maxDistance);
        audioInterface.setRolloffFactor(src, src.rolloffFactor);
        audioInterface.setReferenceDistance(src, src.referenceDistance);
        audioInterface.setVolume(src, src.volume);
        audioInterface.setPanning(src, src.panning);
        audioInterface.setPitch(src, src.pitch);
        import std.stdio:writefln;
        // float* pos;
        // alGetSourcef(src.id, AL_POSITION, pos);

    }




    private static bool is3D;
    private static AudioBuffer[string] bufferPool; 
    private static AudioSource[] sourcePool;
    private static uint activeSources;

    static IAudio audioInterface;

    //Debug vars
    version(HIPREME_DEBUG)
    {
        public static bool hasInitializedAudio = false;
    }    
}
