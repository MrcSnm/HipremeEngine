module hip.hipaudio.backend.openal.source;
version(OpenAL):

import hip.hipaudio.backend.openal.clip;
import hip.error.handler;
import hip.hipaudio.audio;
import hip.hipaudio.audiosource;
import hip.util.memory;
import hip.hipaudio.backend.openal.al_err;
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

    override bool play()
    {
        if((cast(HipOpenALClip)clip).hasBuffer)
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
        HipOpenALClip c = cast(HipOpenALClip)newClip;
        if(!c.isStreamed)
        {
            HipAudioBuffer buf = c.getBuffer(c.getClipData(), cast(uint)c.getClipSize());
            alSourcei(id, AL_BUFFER, buf.al);
        }
        else
        {
            HipAudioBuffer buf = c.getBuffer(c.getClipData(), c.chunkSize);
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
            sendAvailableBuffer(buffer);
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

    override HipAudioBufferWrapper2* getFreeBuffer()
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