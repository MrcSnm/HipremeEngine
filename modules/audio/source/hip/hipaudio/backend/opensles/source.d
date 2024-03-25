module hip.hipaudio.backend.opensles.source;
version(Android):
import hip.error.handler;
import hip.hipaudio.backend.audioclipbase;
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
        return clip;
    }

    override bool play()
    {
        SLIBuffer* buf = getBufferFromAPI(clip).sles;
        SLIAudioPlayer.Enqueue(*audioPlayer, buf.data.ptr, buf.size);
        buf.isLocked = true;
        buf.hasBeenProcessed = false;

        import hip.console.log;

        logln("SampleRate: ", clip.getSampleRate);
        logln("Output: ", clip.getHint().outputSamplerate);
        float rate = cast(float)clip.getSampleRate() / cast(float)clip.getHint().outputSamplerate;
        
        SLIAudioPlayer.setRate(*audioPlayer, rate);

        SLIAudioPlayer.play(*audioPlayer);
        return true;
    }

    alias loop = HipAudioSource.loop;
    override bool loop(bool shouldLoop)
    {
        super.loop(shouldLoop);
        SLIAudioPlayer.setLoop(*audioPlayer, shouldLoop);
        return shouldLoop;
    }

    override bool stop()
    {
        SLIAudioPlayer.stop(*audioPlayer);
        return false;
    }

    override bool pause()
    {
        SLIAudioPlayer.pause(*audioPlayer);
        return false;
    }
    bool resume()
    {
        SLIAudioPlayer.resume(*audioPlayer);
        return false;   
    }


    override void pullStreamData()
    {
        import hip.util.memory;

        ErrorHandler.assertExit(clip !is null, "Can't pull stream data without any buffer attached");
        ErrorHandler.assertExit(audioPlayer.playerObj != null, "Can't pull stream data without null audioplayer");
        uint decoded = clip.updateStream();
        import hip.console.log;
        HipAudioBufferWrapper* freeBuf = getFreeBuffer();
        
        if(freeBuf != null)
        {
            audioPlayer.removeFreeBuffer(freeBuf.buffer.sles);
            (cast(HipAudioClip)this.clip).setBufferAvailable(freeBuf.buffer);
        }
        HipAudioClip c = cast(HipAudioClip)clip;
        SLIBuffer* buf = c.getBuffer(c.getClipData(), c.chunkSize).sles;
        audioPlayer.pushBuffer(buf);

    }

    override HipAudioBufferWrapper* getFreeBuffer()
    {
        SLIBuffer* b = audioPlayer.getProcessedBuffer();
        if(b == null)
            return null;
        HipAudioBuffer buffer;
        buffer.sles = b;
        return (cast(HipAudioClip)clip).findBuffer(buffer);
    }
    
}