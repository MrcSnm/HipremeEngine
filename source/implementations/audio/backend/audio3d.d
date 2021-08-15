/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.backend.audio3d;
import implementations.audio.audiobase;
import implementations.audio.backend.audiosource;
import implementations.audio.backend.audioconfig;
import math.vector;
import error.handler;
import bindbc.openal;
import sdl.sdl_sound;

/**
* Controls how the gain will falloff
*/
enum DistanceModel : ALenum
{
    DISTANCE_MODEL      = AL_DISTANCE_MODEL,
    /**
    * Very similar to the exponential curve
    */
    INVERSE             = AL_INVERSE_DISTANCE,
    INVERSE_CLAMPED     = AL_INVERSE_DISTANCE_CLAMPED,
    /**
    * Linear curve, the only which can achieve 0 volume
    */
    LINEAR              = AL_LINEAR_DISTANCE,
    LINEAR_CLAMPED      = AL_LINEAR_DISTANCE_CLAMPED,

    /**
    * Exponential curve for the model
    */
    EXPONENT            = AL_EXPONENT_DISTANCE,
    /**
    * When the distance is below the reference, it will clamp the volume to 1
    * When the distance is higher than max distance, it will not decrease volume any longer
    */
    EXPONENT_CLAMPED    = AL_EXPONENT_DISTANCE_CLAMPED
}


public class OpenALBuffer : AudioBuffer
{
    this()
    {
        alGenBuffers(1, &bufferId);
    }

    override public bool load(string audioPath, TYPE audioType, bool isStreamed = false)
    {
        sample = Sound_NewSampleFromFile(cast(const(char)*)audioPath, &Audio3DBackend.info, Audio3DBackend.defaultBufferSize);
        if(!isStreamed)
        {
            Sound_DecodeAll(sample);
        }
        else
        {   
            //Need to study yet how to stream            
        }
        alBufferData(bufferId, Audio3DBackend.config.getFormatAsOpenAL(), sample.buffer, sample.buffer_size, Audio3DBackend.config.sampleRate);
        return false;
    }

    override public void unload()
    {
        alDeleteBuffers(1, &bufferId);
        Sound_FreeSample(sample);
        sample = null;
        bufferId = -1;
    }

    /**
    * Id for accessing via OpenAL Soft
    */
    public ALuint bufferId;
    /**
    * Buffer where data is stored
    */
    public Sound_Sample* sample;
}

public class Audio3DBackend : IAudio
{
    public this(AudioConfig cfg)
    {
        initializeOpenAL();
        config = cfg;
        
        info.channels = cast(ubyte)cfg.channels;        
        info.format = cfg.getFormatAsSDL_AudioFormat();
        info.rate = cfg.sampleRate;
    }
    public static bool initializeOpenAL()
    {
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
    public AudioSource getSource()
    {
        AudioSource src = new AudioSource3D();
        alGenSources(1, &src.id);
        ALuint id = src.id;
        alSourcef(id, AL_GAIN, 1);
        alSourcef(id, AL_PITCH, 1);
        alSource3f(id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(id, AL_VELOCITY, 0f, 0f, 0f);
    	alSourcei(id, AL_LOOPING, AL_FALSE);

        return src;
    }

    public bool isMusicPlaying(AudioSource src)
    {
        return false;
    }
    public bool isMusicPaused(AudioSource src)
    {
        
        return false;
    }
    public bool resume(AudioSource src)
    {
        if(!src.isPlaying)
        {
            alSourcePlay(src.id);
            return true;
        }
        return false;
    }
    public bool play(AudioSource src)
    {
        OpenALBuffer _buf = cast(OpenALBuffer)src.buffer;
        if(_buf.bufferId != -1)
        {
            alSourcePlay(src.id);
            return true;
        }
        return false;
    }
    public bool stop(AudioSource src)
    {
        alSourceStop(src.id);
        return false;
    }
    public bool pause(AudioSource src)
    {
        alSourcePause(src.id);
        return false;
    }

    public bool play_streamed(AudioSource src)
    {
        return false;
    }
    
    public AudioBuffer load(string path, AudioBuffer.TYPE bufferType)
    {
        OpenALBuffer buffer = new OpenALBuffer();
        buffer.defaultLoad(path, bufferType);
        return buffer;
    }

    public void setDistanceModel(DistanceModel model)
    {
        alDistanceModel(model);
    }
    /**
    * After the max distance, the volume won't decrease anymore
    */
    public void setMaxDistance(AudioSource src, float dist)
    {
        alSourcef(src.id, AL_MAX_DISTANCE, dist);
    }
    /**
    * The factor which the sound volume decreases when the distance is greater
    * than the reference
    */
    public void setRolloffFactor(AudioSource src, float factor)
    {
        alSourcef(src.id, AL_ROLLOFF_FACTOR, factor);
    }
    /**
    * Sets the distance where the volume will be equal to 1
    */
    public void setReferenceDistance(AudioSource src, float dist)
    {
        alSourcef(src.id, AL_REFERENCE_DISTANCE, dist);
    }

    //Start Effects
    public void setVolume(AudioSource src, float volume)
    {
        alSourcef(src.id, AL_GAIN, volume);
    }
    public void setPanning(AudioSource src, float panning)
    {
        alSource3f(src.id, AL_POSITION, src.position.x + (panning*Audio3DBackend.PANNING_CONSTANT), src.position.y, src.position.z);
    }
    public void setPitch(AudioSource src, float pitch)
    {
        alSourcef(src.id, AL_PITCH, pitch);
    }
    public void setPosition(AudioSource src, ref Vector3 pos)
    {
        alSource3f(src.id, AL_POSITION, pos.x + (src.panning*Audio3DBackend.PANNING_CONSTANT), pos.y, pos.z);
        src.position = pos;
    }

    public void setVelocity(AudioSource src, ref Vector3 vel)
    {
        alSource3f(src.id, AL_VELOCITY, vel.x, vel.y, vel.z);
        
    }
    public void setDoppler(AudioSource src, ref Vector3 vel)
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

    protected static Sound_AudioInfo info;
    protected static AudioConfig config;
    protected static ALCdevice* device;
    protected static ALCcontext* context;


    protected static ALuint defaultBufferSize = 4096;

    /**
    * Constant used for making the panning distance offset from the listener
    */
    public static ALfloat PANNING_CONSTANT = 1000;
}