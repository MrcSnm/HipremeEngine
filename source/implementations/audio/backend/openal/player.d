module implementations.audio.backend.openal.player;
import implementations.audio.backend.openal.buffer;
import implementations.audio.backend.audioconfig;
import implementations.audio.backend.openal.source;
import implementations.audio.audiobase;
import implementations.audio.audio;
import error.handler;
import audio.audio;
import math.vector;
import bindbc.openal;

ALenum getALDistanceModel(DistanceModel model)
{
    final switch(model) with(DistanceModel)
    {
        case DISTANCE_MODEL: return AL_DISTANCE_MODEL;
        case INVERSE: return AL_INVERSE_DISTANCE;
        case INVERSE_CLAMPED: return AL_INVERSE_DISTANCE_CLAMPED;
        case LINEAR: return AL_LINEAR_DISTANCE;
        case LINEAR_CLAMPED: return AL_LINEAR_DISTANCE_CLAMPED;
        case EXPONENT: return AL_EXPONENT_DISTANCE;
        case EXPONENT_CLAMPED: return AL_EXPONENT_DISTANCE_CLAMPED;
    }
}

/**
* Wraps OpenAL API onto the IAudioPlayer interface. With that, when HipAudioSource receives that interface,
* it will update OpenAL properties through that interface.
*/
public class HipOpenALAudioPlayer : IHipAudioPlayer
{
    public this(AudioConfig cfg)
    {
        HipSDL_SoundDecoder.initDecoder();
        initializeOpenAL();
        config = cfg;
    }
    public static bool initializeOpenAL()
    {
        ErrorHandler.startListeningForErrors("HipremeAudio3D initialization");
        ALSupport sup = loadOpenAL();
        if(sup != ALSupport.al11) //Probably should not load a non al11 version.
        {
            if(sup == ALSupport.badLibrary)
                ErrorHandler.showErrorMessage("Bad OpenAL Support", "Unknown version of OpenAL");
            else
            {
                ErrorHandler.showErrorMessage("OpenAL not found", "Could not find OpenAL library");
                return false;
            }
        }
        device = alcOpenDevice(alcGetString(null, ALC_DEVICE_SPECIFIER));
        if(device == null)
        {
            ErrorHandler.showErrorMessage("OpenAL Initialization", "Error on creating device");
            return false;
        }
        //static const ALCint* contextAttr = [ALC_FREQUENCY, 22_050, 0];
        context = alcCreateContext(device, null);
        if(context == null)
        {
            ErrorHandler.showErrorMessage("OpenAL context error", "Error creating OpenAL context");
            return false;
        }
        if(!alcMakeContextCurrent(context))
		    ErrorHandler.showErrorMessage("OpenAL context error", "Error setting context");

        //Set Listener

        alListener3f(AL_POSITION, 0f, 0f, 0f);
        alListener3f(AL_VELOCITY, 0f, 0f, 0f);

        if(!alEffecti)
            ErrorHandler.showErrorMessage("OpenAL EFX Error", "Could not load OpenAL EFX");

        return true;
    }
    public HipAudioSource getSource()
    {
        HipAudioSource src = new HipOpenALAudioSource();
        alGenSources(1, &src.id);
        ALuint id = src.id;
        alSourcef(id, AL_GAIN, 1);
        alSourcef(id, AL_PITCH, 1);
        alSource3f(id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(id, AL_VELOCITY, 0f, 0f, 0f);
    	alSourcei(id, AL_LOOPING, AL_FALSE);
       

        return src;
    }

    public bool isMusicPlaying(HipAudioSource src){return false;}
    public bool isMusicPaused(HipAudioSource src){return false;}
    public bool resume(HipAudioSource src)
    {
        if(!src.isPlaying)
        {
            alSourcePlay(src.id);
            return true;
        }
        return false;
    }
    public bool play(HipAudioSource src)
    {
        HipOpenALBuffer _buf = cast(HipOpenALBuffer)src.buffer;
        if(_buf.bufferId != -1)
        {
            alSourcePlay(src.id);
            return true;
        }
        return false;
    }
    public bool stop(HipAudioSource src)
    {
        alSourceStop(src.id);
        return false;
    }
    public bool pause(HipAudioSource src)
    {
        alSourcePause(src.id);
        return false;
    }

    public bool play_streamed(HipAudioSource src)
    {
        return false;
    }
    
    public HipAudioBuffer load(string path, HipAudioType bufferType)
    {
        HipOpenALBuffer buffer = new HipOpenALBuffer(new HipSDL_SoundDecoder());
        buffer.load(path, getEncodingFromName(path), bufferType);
        import def.debugging.log;
        rawlog(buffer.getBufferSize);
        return buffer;
    }

    public void setDistanceModel(DistanceModel model)
    {
        alDistanceModel(getALDistanceModel(model));
    }
    /**
    * After the max distance, the volume won't decrease anymore
    */
    public void setMaxDistance(HipAudioSource src, float dist)
    {
        alSourcef(src.id, AL_MAX_DISTANCE, dist);
    }
    /**
    * The factor which the sound volume decreases when the distance is greater
    * than the reference
    */
    public void setRolloffFactor(HipAudioSource src, float factor)
    {
        alSourcef(src.id, AL_ROLLOFF_FACTOR, factor);
    }
    /**
    * Sets the distance where the volume will be equal to 1
    */
    public void setReferenceDistance(HipAudioSource src, float dist)
    {
        alSourcef(src.id, AL_REFERENCE_DISTANCE, dist);
    }

    //Start Effects
    public void setVolume(HipAudioSource src, float volume)
    {
        alSourcef(src.id, AL_GAIN, volume);
    }
    public void setPanning(HipAudioSource src, float panning)
    {
        alSource3f(src.id, AL_POSITION, src.position.x + (panning*PANNING_CONSTANT), src.position.y, src.position.z);
    }
    public void setPitch(HipAudioSource src, float pitch)
    {
        alSourcef(src.id, AL_PITCH, pitch);
    }
    public void setPosition(HipAudioSource src, ref Vector3 pos)
    {
        alSource3f(src.id, AL_POSITION, pos.x + (src.panning*PANNING_CONSTANT), pos.y, pos.z);
        src.position = pos;
    }

    public void setVelocity(HipAudioSource src, ref Vector3 vel)
    {
        alSource3f(src.id, AL_VELOCITY, vel.x, vel.y, vel.z);
        
    }
    public void setDoppler(HipAudioSource src, ref Vector3 vel)
    {
        alSource3f(src.id, AL_DOPPLER_VELOCITY, vel.x, vel.y, vel.z);

    }
    //End Effects
    public void onDestroy()
    {
        alcDestroyContext(context);
        alcCloseDevice(device);
        context = null;
        device = null;               
    }

    package static AudioConfig config;
    protected static ALCdevice* device;
    protected static ALCcontext* context;

    /**
    * Constant used for making the panning distance offset from the listener
    */
    public static ALfloat PANNING_CONSTANT = 1000;
}