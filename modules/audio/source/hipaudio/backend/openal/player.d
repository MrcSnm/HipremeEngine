module hipaudio.backend.openal.player;
import hipaudio.backend.openal.clip;
import data.audio.audioconfig;
import hipaudio.backend.openal.source;
import hipaudio.audio;
import data.audio.audioconfig;
import error.handler;
import data.audio.audio;
import math.vector;
import bindbc.openal;

package string alGetErrorString(ALenum err)
{
    if(err != AL_NO_ERROR)
    {
        final switch(err)
        {
            case AL_INVALID_NAME:
                return "AL_INVALID_NAME: A bad name (ID) was passed to an OpenAL function";
            case AL_INVALID_ENUM:
                return "AL_INVALID_ENUM: An invalid enum value was passed to an OpenAL function";
            case AL_INVALID_VALUE:
                return "AL_INVALID_VALUE: An invalid value was passed to an OpenAL function";
            case AL_INVALID_OPERATION:
                return "AL_INVALID_OPERATION: A requested operation is not valid";
            case AL_OUT_OF_MEMORY:
                return "AL_OUT_OF_MEMORY: The requested operation resulted in OpenAL running out of memory";
        }
    }
    return "";
}

package ALenum getFormatAsOpenAL(AudioConfig cfg)
{
    if(cfg.channels == 1)
    {
        if(cfg.format == AudioFormat.float32Big || cfg.format == AudioFormat.float32Little)
            return AL_FORMAT_MONO_FLOAT32;
        else if(cfg.format == AudioFormat.signed16Little || cfg.format == AudioFormat.signed16Big)
            return AL_FORMAT_MONO16;
        else
            return AL_FORMAT_MONO8;
    }
    else
    {
        if(cfg.format == AudioFormat.float32Big || cfg.format == AudioFormat.float32Little)
            return AL_FORMAT_STEREO_FLOAT32;
        else if(cfg.format == AudioFormat.signed16Little || cfg.format == AudioFormat.signed16Big)
            return AL_FORMAT_STEREO16;
        else
            return AL_FORMAT_STEREO8;
    }
}

package string alCheckError(string title="", string message="")()
{
    static if(message != "")
        message = "\n"~message;

    enum t = "\"OpenAL Error: "~title~"\"";
    enum m = "alGetErrorString(alCheckError_err) ~ \""~message~"\"";

    return `version(HIPREME_DEBUG)
    {
        static if(!is(typeof(alCheckError_err)))
            ALenum alCheckError_err = alGetError();
        else
            alCheckError_err = alGetError();
        if(alCheckError_err != AL_NO_ERROR)
            ErrorHandler.showErrorMessage(
    ` ~t~", " ~ m  ~");
    }";
}

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
* Wraps OpenAL API onto the IAudioPlayer interface. With that, when HipAudioSourceAPI receives that interface,
* it will update OpenAL properties through that interface.
*/
public class HipOpenALAudioPlayer : IHipAudioPlayer
{
    // alias Decoder = HipSDL_SoundDecoder;
    alias Decoder = HipAudioFormatsDecoder;

    public this(AudioConfig cfg)
    {
        // HipSDL_SoundDecoder.initDecoder(cfg, audioConfigDefaultBufferSize);
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
    public HipAudioSourceAPI getSource(bool isStreamed = false)
    {
        HipOpenALAudioSource src = new HipOpenALAudioSource(isStreamed);
        alGenSources(1, &src.id);
        mixin(alCheckError!("Error creating OpenAL source"));
        ALuint id = src.id;
        alSourcef(id, AL_GAIN, 1);
        alSourcef(id, AL_PITCH, 1);
        alSource3f(id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(id, AL_VELOCITY, 0f, 0f, 0f);
    	alSourcei(id, AL_LOOPING, AL_FALSE);
        mixin(alCheckError!("Error setting OpenAL source properties"));
       

        return src;
    }

    public bool isMusicPlaying(HipAudioSourceAPI src){return false;}
    public bool isMusicPaused(HipAudioSourceAPI src){return false;}
    public bool resume(HipAudioSourceAPI src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        if(!src.isPlaying)
        {
            alSourcePlay(source.id);
            mixin(alCheckError!("Error querying OpenAL play"));
            return true;
        }
        return false;
    }
    public bool play(HipAudioSourceAPI src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        HipOpenALClip _buf = cast(HipOpenALClip)source.clip;
        
        if(_buf.hasBuffer)
        {
            alSourcePlay(source.id);
            mixin(alCheckError!("Error querying OpenAL play"));
            return true;
        }
        else
            ErrorHandler.showErrorMessage("Tried to play without a buffer", "");
        return false;
    }
    public bool stop(HipAudioSourceAPI src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;

        alSourceStop(source.id);
        mixin(alCheckError!("Error querying OpenAL stop"));
        return false;
    }
    public bool pause(HipAudioSourceAPI src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcePause(source.id);
        mixin(alCheckError!("Error querying OpenAL pause"));
        return false;
    }

    public bool play_streamed(HipAudioSourceAPI src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        HipOpenALClip _buf = cast(HipOpenALClip)source.clip;
        if(_buf.hasBuffer)
        {
            alSourcePlay(source.id);
            mixin(alCheckError!("Error querying OpenAL play streamed"));
            return true;
        }
        return false;
    }
    
    public HipAudioClipAPI load(string path, HipAudioType clipType)
    {
        HipOpenALClip clip = new HipOpenALClip(new Decoder());
        clip.load(path, getEncodingFromName(path), clipType);
        return clip;
    }
    public HipAudioClipAPI loadStreamed(string path, uint chunkSize)
    {
        HipAudioClipAPI clip = new HipOpenALClip(new Decoder(), chunkSize);
        clip.loadStreamed(path, getEncodingFromName(path));
        return clip;
    }

    public void updateStream(HipAudioSourceAPI source)
    {
        // HipOpenALAudioSource src = cast(HipOpenALAudioSource)source;
        // HipOpenALClip clip = cast(HipOpenALClip)src.buffer;
        // ALuint b = clip.getALBuffer();
        // alSourceQueueBuffers(src.id, 1, &b);
        // mixin(alCheckError!("Error enqueueing OpenAL buffer on source"));
    }

    public void setDistanceModel(DistanceModel model)
    {
        alDistanceModel(getALDistanceModel(model));
        mixin(alCheckError!("Error setting OpenAL source distance model"));
    }
    /**
    * After the max distance, the volume won't decrease anymore
    */
    public void setMaxDistance(HipAudioSourceAPI src, float dist)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_MAX_DISTANCE, dist);
        mixin(alCheckError!("Error setting OpenAL source max distance"));
    }
    /**
    * The factor which the sound volume decreases when the distance is greater
    * than the reference
    */
    public void setRolloffFactor(HipAudioSourceAPI src, float factor)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_ROLLOFF_FACTOR, factor);
        mixin(alCheckError!("Error setting OpenAL source rolloff factor"));
    }
    /**
    * Sets the distance where the volume will be equal to 1
    */
    public void setReferenceDistance(HipAudioSourceAPI src, float dist)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_REFERENCE_DISTANCE, dist);
        mixin(alCheckError!("Error setting OpenAL source reference distance"));
    }

    //Start Effects
    public void setVolume(HipAudioSourceAPI src, float volume)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_GAIN, volume);
        mixin(alCheckError!("Error setting OpenAL source volume"));
    }
    public void setPanning(HipAudioSourceAPI src, float panning)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_POSITION, src.position.x + (panning*PANNING_CONSTANT), src.position.y, src.position.z);
        mixin(alCheckError!("Error setting OpenAL source panning"));
    }
    public void setPitch(HipAudioSourceAPI src, float pitch)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_PITCH, pitch);
        mixin(alCheckError!("Error setting OpenAL source pitch"));
    }
    public void setPosition(HipAudioSourceAPI src, ref Vector3 pos)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_POSITION, pos.x + (src.panning*PANNING_CONSTANT), pos.y, pos.z);
        src.position = pos;
        mixin(alCheckError!("Error setting OpenAL source position"));
    }

    public void setVelocity(HipAudioSourceAPI src, ref Vector3 vel)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_VELOCITY, vel.x, vel.y, vel.z);
        mixin(alCheckError!("Error setting OpenAL source velocity"));
        
    }
    public void setDoppler(HipAudioSourceAPI src, ref Vector3 vel)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_DOPPLER_VELOCITY, vel.x, vel.y, vel.z);
        mixin(alCheckError!("Error setting OpenAL source doppler factor"));
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