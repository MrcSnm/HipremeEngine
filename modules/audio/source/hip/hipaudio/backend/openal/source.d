module hip.hipaudio.backend.openal.source;
import hip.hipaudio.backend.openal.clip;
import hip.error.handler;
import hip.hipaudio.audio;
import hip.hipaudio.audiosource;
import hip.util.memory;
import bindbc.openal;

public class HipOpenALAudioSource : HipAudioSource
{   
    import hip.console.log;
    //id is created from OpenAL player
    bool isStreamed;

    this(bool isStreamed)
    {
        this.isStreamed=isStreamed;
    }

    alias clip = HipAudioSource.clip;

    override IHipAudioClip clip(IHipAudioClip newClip)
    {
        super.clip(newClip);
        HipOpenALClip c = cast(HipOpenALClip)newClip;
        if(!c.isStreamed)
        {
            ALuint buf = *cast(ALuint*)c.getBuffer(c.getClipData(), cast(uint)c.getClipSize());
            alSourcei(id, AL_BUFFER, buf);
        }
        else
        {
            ALuint buf = c.getALBuffer(c.getClipData(), c.chunkSize);
            alSourceQueueBuffers(id, 1, &buf);
        }
        logln(id);
        return newClip;
    }

    override void pullStreamData()
    {
        ErrorHandler.assertExit(clip !is null, "Can't pull stream data without any buffer attached");
        ErrorHandler.assertExit(id != 0, "Can't pull stream data without source id");
        uint freeBuf = getALFreeBuffer(); //Gets the queueId
        if(freeBuf != 0)
        {
            //Returns the bufferId to freeBuf
            alSourceUnqueueBuffers(id, 1, &freeBuf);
            sendAvailableBuffer(&freeBuf);
        }
        clip.updateStream();
        HipOpenALClip c = cast(HipOpenALClip)clip;
        freeBuf = c.getALBuffer(c.getClipData(), c.chunkSize);
        alSourceQueueBuffers(id, 1, &freeBuf);
        
    }

    uint getALFreeBuffer()
    {
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        return cast(uint)b;
    }

    override HipAudioBufferWrapper* getFreeBuffer()
    {
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        if(b == 0)
            return null;
        return (cast(HipAudioClip)clip).findBuffer(&b);
    }
    

    ~this()
    {
        logln("HipAudioSource Killed!");
        alDeleteSources(1, &id);
        id = 0;
    }
}