module hip.audio.backend.openal.source;
version(OpenAL):

import hip.audio.backend.openal.clip;
import hip.error.handler;
import hip.audio;
import hip.audio.audiosource;
import hip.util.memory;
import hip.audio.backend.openal.al_err;
import hip.audio.clip;
import bindbc.openal;


/**
* Constant used for making the panning distance offset from the listener
*/
enum ALfloat PANNING_CONSTANT = 1000;

public class HipOpenALAudioSource : HipAudioSource
{
    import hip.console.log;
    //id is created from OpenAL player
    uint id;
    bool isStreamed;

    this(bool isStreamed)
    {
        this.isStreamed=isStreamed;
        alGenSources(1, &id);
        alCheckError("Error creating OpenAL source");
        alSourcef(id, AL_GAIN, 1);
        alSourcef(id, AL_PITCH, 1);
        alSource3f(id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(id, AL_VELOCITY, 0f, 0f, 0f);
    	alSourcei(id, AL_LOOPING, AL_FALSE);
        alCheckError("Error setting OpenAL source properties");
    }

    alias pitch = AHipAudioSource.pitch;
    alias panning = AHipAudioSource.panning;
    alias volume = AHipAudioSource.volume;
    alias pitch = AHipAudioSource.pitch;
    alias clip = HipAudioSource.clip;
    alias position = AHipAudioSource.position;
    alias loop = AHipAudioSource.loop;


    override float pitch(float value)
    {
        auto ret = super.pitch(value);
        if(isDirty && isPlaying)
        {
            alSourcef(id, AL_PITCH, ret);
            alCheckError("Error setting OpenAL source pitch");
            isDirty = false;
        }
        return ret;
    }

    override float panning(float value)
    {
        auto ret = super.panning(value);
        if(isDirty && isPlaying)
        {
            isDirty = false;
            alSource3f(id, AL_POSITION, position[0] + (ret*PANNING_CONSTANT), position[1], position[2]);
            alCheckError("Error setting OpenAL source position/panning");
        }
        return ret;
    }
    override float volume(float value)
    {
        auto ret  = super.volume(value);
        if(isDirty && isPlaying)
        {
            isDirty = false;
            alSourcef(id, AL_GAIN, ret);
            alCheckError("Error setting OpenAL source volume");
        }
        return ret;
    }

    override float[3] position(float[3] value)
    {
        auto ret = super.position(value);
        if(isDirty && isPlaying)
        {
            isDirty = false;
            alSource3f(id, AL_POSITION, ret[0] + (panning*PANNING_CONSTANT), ret[1], ret[2]);
            alCheckError("Error setting OpenAL source position/panning");
        }
        return ret;
    }

    override bool loop(bool value)
    {
        bool ret = super.loop(value);
        if(isDirty && isPlaying)
        {
    	    alSourcei(id, AL_LOOPING, ret ? AL_TRUE : AL_FALSE);
            alCheckError("Error setting OpenAL loop");
        }
        return ret;
    }

    public void setDistanceModel(DistanceModel model)
    {
        alDistanceModel(getALDistanceModel(model));
        alCheckError("Error setting OpenAL source distance model");
    }
    /**
    * After the max distance, the volume won't decrease anymore
    */
    public void setMaxDistance(float dist)
    {
        alSourcef(id, AL_MAX_DISTANCE, dist);
        alCheckError("Error setting OpenAL source max distance");
    }

    /**
    * Sets the distance where the volume will be equal to 1
    */
    void setReferenceDistance(float dist)
    {
        alSourcef(id, AL_REFERENCE_DISTANCE, dist);
        alCheckError("Error setting OpenAL source reference distance");
    }
    /**
    * The factor which the sound volume decreases when the distance is greater
    * than the reference
    */
    public void setRolloffFactor(float factor)
    {
        alSourcef(id, AL_ROLLOFF_FACTOR, factor);
        alCheckError("Error setting OpenAL source rolloff factor");
    }

    public void setVelocity(in float[3] vel)
    {
        alSource3f(id, AL_VELOCITY, vel[0], vel[1], vel[2]);
        alCheckError("Error setting OpenAL source velocity");

    }
    void setDoppler(in float[3] vel)
    {
        alSource3f(id, AL_DOPPLER_VELOCITY, vel[0], vel[1], vel[2]);
        alCheckError("Error setting OpenAL source doppler factor");
    }

    override bool play()
    {
        HipOpenALClip clp = clip.getAudioClipBackend!(HipOpenALClip);
        if(clp.hasBuffer)
        {
            if(isDirty)
            {
                isDirty = false;
                alSourcef(id, AL_PITCH, pitch);
                alCheckError("Error setting OpenAL source pitch");
                alSourcef(id, AL_GAIN, volume);
                alCheckError("Error setting OpenAL source volume");
                alSource3f(id, AL_POSITION, position[0] + (panning*PANNING_CONSTANT), position[1], position[2]);
                alCheckError("Error setting OpenAL source position/panning");
                alSourcei(id, AL_LOOPING, loop ? AL_TRUE : AL_FALSE);
                alCheckError("Error setting OpenAL loop");
            }
            alSourcePlay(id);
            alCheckError("Error querying OpenAL play");
            return true;
        }
        else
            ErrorHandler.showErrorMessage("Tried to play without a buffer", "");
        return false;
    }

    public bool resume()
    {
        if(!isPlaying)
        {
            alSourcePlay(id);
            alCheckError("Error querying OpenAL play");
            return true;
        }
        return false;
    }


    override bool stop()
    {
        alSourceStop(id);
        alCheckError("Error querying OpenAL stop");
        return false;
    }

    override bool pause()
    {
        alSourcePause(id);
        alCheckError("Error querying OpenAL pause");
        return false;
    }
    override bool play_streamed(){return play();}


    override IHipAudioClip clip(IHipAudioClip newClip)
    {
        super.clip(newClip);
        // if(!newClip.isStreamed)
        // {
        //     HipAudioBuffer buf = getBufferFromAPI(newClip);
        //     alSourcei(id, AL_BUFFER, buf.al);
        // }
        // else
        {
            HipAudioBuffer buf = getBufferFromAPI(newClip); //use clip.chunkSize in future
            alSourceQueueBuffers(id, 1, &buf.al);
        }
        logln(id);
        return newClip;
    }


    override void pullStreamData()
    {
        ErrorHandler.assertExit(clip !is null, "Can't pull stream data without any buffer attached");
        ErrorHandler.assertExit(id != 0, "Can't pull stream data without source id");

        HipAudioBuffer buffer;
        int processed;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &processed);//Gets the queueId
        buffer.al = cast(uint)processed;
        if(buffer.al != 0)
        {
            //Returns the bufferId to freeBuf
            alSourceUnqueueBuffers(id, 1, &buffer.al);
            (cast(HipAudioClip)this.clip).setBufferAvailable(buffer);
        }
        clip.updateStream();

        HipOpenALClip c = cast(HipOpenALClip)clip;
        buffer = c.getBuffer(c.getClipData(), c.chunkSize);
        alSourceQueueBuffers(id, 1, &buffer.al);

    }


    uint getALFreeBuffer()
    {
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        return cast(uint)b;
    }

    override HipAudioBufferWrapper* getFreeBuffer()
    {
        HipAudioBuffer buffer;
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        buffer.al = cast(uint)b;
        if(b == 0)
            return null;
        return (cast(HipAudioClip)clip).findBuffer(buffer);
    }



    ~this()
    {
        logln("HipAudioSource Killed!");
        alDeleteSources(1, &id);
        id = 0;
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
