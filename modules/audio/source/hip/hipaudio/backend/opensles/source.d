module hip.hipaudio.backend.opensles.source;
version(Android):
import hip.error.handler;
import hip.hipaudio.audioclip;
import hip.hipaudio.backend.sles;
import hip.util.time;
import hip.hipaudio.audiosource;

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

    alias clip = HipAudioSource.clip;
    override IHipAudioClip clip(IHipAudioClip clip)
    {
        super.clip(clip);
        SLIBuffer* buf = (cast(HipAudioClip)clip).getBuffer(clip.getClipData(), cast(uint)clip.getClipSize()).sles;
        SLIAudioPlayer.Enqueue(*audioPlayer, buf.data.ptr, buf.size);
        buf.isLocked = true;
        buf.hasBeenProcessed = false;

        return clip;
    }

    override void pullStreamData()
    {
        import hip.util.memory;

        ErrorHandler.assertExit(clip !is null, "Can't pull stream data without any buffer attached");
        ErrorHandler.assertExit(audioPlayer.playerObj != null, "Can't pull stream data without null audioplayer");
        uint decoded = clip.updateStream();
        import hip.console.log;
        HipAudioBufferWrapper2* freeBuf = getFreeBuffer();
        
        if(freeBuf != null)
        {
            audioPlayer.removeFreeBuffer(freeBuf.buffer.sles);
            sendAvailableBuffer(freeBuf.buffer);
        }
        HipAudioClip c = cast(HipAudioClip)clip;
        SLIBuffer* buf = c.getBuffer(c.getClipData(), c.chunkSize).sles;
        audioPlayer.pushBuffer(buf);

    }

    override HipAudioBufferWrapper2* getFreeBuffer()
    {
        SLIBuffer* b = audioPlayer.getProcessedBuffer();
        if(b == null)
            return null;
        HipAudioBuffer buffer;
        buffer.sles = b;
        return (cast(HipAudioClip)clip).findBuffer(buffer);
    }
    
}