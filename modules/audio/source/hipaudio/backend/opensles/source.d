module hipaudio.backend.opensles.source;
version(Android):
import error.handler;
import hipaudio.audioclip;
import hipaudio.backend.sles;
import util.time;
import hipaudio.audiosource;

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
        SLIBuffer* buf = cast(SLIBuffer*)clip.getBuffer(clip.getClipData(), cast(uint)clip.getClipSize());
        SLIAudioPlayer.Enqueue(*audioPlayer, buf.data.ptr, buf.size);
        buf.isLocked = true;
        buf.hasBeenProcessed = false;
    }

    override void pullStreamData()
    {
        import util.memory;

        ErrorHandler.assertExit(clip !is null, "Can't pull stream data without any buffer attached");
        ErrorHandler.assertExit(audioPlayer.playerObj != null, "Can't pull stream data without null audioplayer");
        uint decoded = clip.updateStream();
        import console.log;
        SLIBuffer* freeBuf = getSLIFreeBuffer();
        
        if(freeBuf != null)
        {
            audioPlayer.removeFreeBuffer(freeBuf);
            sendAvailableBuffer(freeBuf);
        }
        
        SLIBuffer* buf = cast(SLIBuffer*)clip.getBuffer(clip.getClipData(), clip.chunkSize);
        audioPlayer.pushBuffer(buf);

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
        if(b == null)
            return null;
        return clip.findBuffer(b);
    }
    
}