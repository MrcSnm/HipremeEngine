module hipaudio.backend.opensles.source;
version(Android):
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

    override void pullStreamData()
    {
        import util.memory;

        assert(buffer !is null, "Can't pull stream data without any buffer attached");
        assert(audioPlayer.playerObj != null, "Can't pull stream data without null audioplayer");
        uint decoded = buffer.updateStream(buffer.outBuffer);
        
        void* buf = alloc!void(decoded);

        memcpy(buf, buffer.outBuffer, decoded);
        SLIAudioPlayer.Enqueue(*audioPlayer,  buf, decoded);


        // SLIBuffer* buf = sliGenBuffer(buffer.outBuffer, decoded);
        // audioPlayer.pushBuffer(buf);
    }
}