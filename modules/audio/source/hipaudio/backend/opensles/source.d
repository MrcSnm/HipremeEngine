module hipaudio.backend.opensles.source;
version(Android):
import bindbc.sdl;
import hipaudio.audioclip;
import hipaudio.backend.sles;
import util.time;
import hipaudio.backend.audiosource;

version(Android):

class HipOpenSLESAudioSource : HipAudioSource
{
    SLIAudioPlayer* audioPlayer;
    bool isStreamed;
    this(SLIAudioPlayer* player, bool isStreamed)
    {
        audioPlayer = player;
        this.isStreamed = isStreamed;
    }

    override void setClip(HipAudioClip clip)
    {
        super.setClip(clip);
        import console.log;
        SLIBuffer* buf = cast(SLIBuffer*)clip.getBuffer(clip.getClipData(), cast(uint)clip.getClipSize());
        rawlog(buf.size);
        SLIAudioPlayer.Enqueue(*audioPlayer, buf.data.ptr, buf.size);
        buf.isLocked = true;
    }

    override void pullStreamData()
    {
        import util.memory;

        assert(clip !is null, "Can't pull stream data without any buffer attached");
        assert(audioPlayer.playerObj != null, "Can't pull stream data without null audioplayer");
        uint decoded = clip.updateStream();

        SLIBuffer* freeBuf = getSLIFreeBuffer();
        import console.log;
        rawlog(freeBuf);
        
        if(freeBuf != null)
        {
            audioPlayer.unqueue(freeBuf);
            sendAvailableBuffer(&freeBuf);
        }
        
        void* buf = clip.getBuffer(clip.getClipData(), clip.chunkSize);
        audioPlayer.pushBuffer(cast(SLIBuffer*)buf);

        // audioPlayer.pushBuffer()


        // SLIBuffer* buf = sliGenBuffer(buffer.outBuffer, decoded);
        // audioPlayer.pushBuffer(buf);
    }

    SLIBuffer* getSLIFreeBuffer()
    {
        HipAudioBufferWrapper* freeBuf = getFreeBuffer();
        if(freeBuf != null)
            return cast(SLIBuffer*)freeBuf.buffer;
        return null;
    }

    override HipAudioBufferWrapper* getFreeBuffer()
    {
        void* b = audioPlayer.getProcessedBuffer();
        import console.log;
        if(b == null)
            return null;
        rawlog("ACHOU");
        return clip.findBuffer(&b);
    }
    
}