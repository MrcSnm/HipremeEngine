module hip.hipaudio.backend.openal.player;
import hip.hipaudio.backend.openal.clip;
import hip.hipaudio.backend.openal.source;
import hip.hipaudio.backend.openal.al_err;
import hip.hipaudio.audio;
import hip.error.handler;
import hip.audio_decoding.audio;
import hip.math.vector;
import bindbc.openal;


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
    alias Decoder = HipAudioFormatsDecoder;

    public this(AudioConfig cfg)
    {
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
    public AHipAudioSource getSource(bool isStreamed = false)
    {
        HipOpenALAudioSource src = new HipOpenALAudioSource(isStreamed);
        alGenSources(1, &src.id);
        alCheckError("Error creating OpenAL source");
        ALuint id = src.id;
        alSourcef(id, AL_GAIN, 1);
        alSourcef(id, AL_PITCH, 1);
        alSource3f(id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(id, AL_VELOCITY, 0f, 0f, 0f);
    	alSourcei(id, AL_LOOPING, AL_FALSE);
        alCheckError("Error setting OpenAL source properties");
       

        return src;
    }

    public bool isMusicPlaying(AHipAudioSource src){return false;}
    public bool isMusicPaused(AHipAudioSource src){return false;}
    public bool resume(AHipAudioSource src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        if(!src.isPlaying)
        {
            alSourcePlay(source.id);
            alCheckError("Error querying OpenAL play");
            return true;
        }
        return false;
    }
    public bool play(AHipAudioSource src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        HipOpenALClip _buf = cast(HipOpenALClip)source.clip;
        
        if(_buf.hasBuffer)
        {
            alSourcePlay(source.id);
            alCheckError("Error querying OpenAL play");
            return true;
        }
        else
            ErrorHandler.showErrorMessage("Tried to play without a buffer", "");
        return false;
    }
    public bool stop(AHipAudioSource src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;

        alSourceStop(source.id);
        alCheckError("Error querying OpenAL stop");
        return false;
    }
    public bool pause(AHipAudioSource src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcePause(source.id);
        alCheckError("Error querying OpenAL pause");
        return false;
    }

    public bool play_streamed(AHipAudioSource src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        HipOpenALClip _buf = cast(HipOpenALClip)source.clip;
        if(_buf.hasBuffer)
        {
            alSourcePlay(source.id);
            alCheckError("Error querying OpenAL play streamed");
            return true;
        }
        return false;
    }
    
    public HipAudioClipAPI load(string path, HipAudioType clipType)
    {
        HipOpenALClip clip = new HipOpenALClip(new Decoder(), getClipHint());
        if(!clip.load(path, getEncodingFromName(path), clipType))
        {
            import hip.error.handler;
            ErrorHandler.showErrorMessage("Error loading OpenAL Audio Clip", path);
        }
        return clip;
    }
    public HipAudioClipAPI loadStreamed(string path, uint chunkSize)
    {
        HipAudioClipAPI clip = new HipOpenALClip(new Decoder(), getClipHint(), chunkSize);
        clip.loadStreamed(path, getEncodingFromName(path));
        return clip;
    }

    public void updateStream(AHipAudioSource source)
    {
        // HipOpenALAudioSource src = cast(HipOpenALAudioSource)source;
        // HipOpenALClip clip = cast(HipOpenALClip)src.buffer;
        // ALuint b = clip.getALBuffer();
        // alSourceQueueBuffers(src.id, 1, &b);
        // alCheckError("Error enqueueing OpenAL buffer on source"));
    }

    public void setDistanceModel(DistanceModel model)
    {
        alDistanceModel(getALDistanceModel(model));
        alCheckError("Error setting OpenAL source distance model");
    }
    /**
    * After the max distance, the volume won't decrease anymore
    */
    public void setMaxDistance(AHipAudioSource src, float dist)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_MAX_DISTANCE, dist);
        alCheckError("Error setting OpenAL source max distance");
    }
    /**
    * The factor which the sound volume decreases when the distance is greater
    * than the reference
    */
    public void setRolloffFactor(AHipAudioSource src, float factor)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_ROLLOFF_FACTOR, factor);
        alCheckError("Error setting OpenAL source rolloff factor");
    }
    /**
    * Sets the distance where the volume will be equal to 1
    */
    public void setReferenceDistance(AHipAudioSource src, float dist)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_REFERENCE_DISTANCE, dist);
        alCheckError("Error setting OpenAL source reference distance");
    }

    //Start Effects
    public void setVolume(AHipAudioSource src, float volume)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_GAIN, volume);
        alCheckError("Error setting OpenAL source volume");
    }
    public void setPanning(AHipAudioSource src, float panning)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_POSITION, src.position[0] + (panning*PANNING_CONSTANT), src.position[1], src.position[2]);
        alCheckError("Error setting OpenAL source panning");
    }
    public void setPitch(AHipAudioSource src, float pitch)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSourcef(source.id, AL_PITCH, pitch);
        alCheckError("Error setting OpenAL source pitch");
    }
    public void setPosition(AHipAudioSource src, ref Vector3 pos)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_POSITION, pos.x + (src.panning*PANNING_CONSTANT), pos.y, pos.z);
        src.position = [pos.x, pos.y, pos.z];
        alCheckError("Error setting OpenAL source position");
    }

    public void setVelocity(AHipAudioSource src, ref Vector3 vel)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_VELOCITY, vel.x, vel.y, vel.z);
        alCheckError("Error setting OpenAL source velocity");
        
    }
    public void setDoppler(AHipAudioSource src, ref Vector3 vel)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        alSource3f(source.id, AL_DOPPLER_VELOCITY, vel.x, vel.y, vel.z);
        alCheckError("Error setting OpenAL source doppler factor");
    }
    //End Effects
    public void onDestroy()
    {
        alcDestroyContext(context);
        alcCloseDevice(device);
        context = null;
        device = null;               
    }

    /**
    *   OpenAL has an embedded resampler
    */
    protected static HipAudioClipHint getClipHint()
    {
        HipAudioClipHint hint = {
            outputChannels: HipOpenALAudioPlayer.config.channels,
            outputSamplerate: HipOpenALAudioPlayer.config.sampleRate,
            needsResample: false,
            needsDecode: true
        };
        return hint;
    }

    package static AudioConfig config;
    protected static ALCdevice* device;
    protected static ALCcontext* context;

    /**
    * Constant used for making the panning distance offset from the listener
    */
    public static ALfloat PANNING_CONSTANT = 1000;
}