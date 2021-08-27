module hipaudio.backend.opensles.source;
import hipaudio.backend.sles;
import util.time;
import hipaudio.backend.audiosource;

version(Android):

class HipOpenSLESAudioSource : HipAudioSource
{
    SLIAudioPlayer* audioPlayer;
    this(SLIAudioPlayer* player)
    {
        audioPlayer = player;
    }

    override void pullStreamData()
    {
        import util.memory;

        assert(buffer !is null, "Can't pull stream data without any buffer attached");
        assert(audioPlayer.playerObj != null, "Can't pull stream data without null audioplayer");
        uint decoded = buffer.updateStream();
        void* temp = malloc(decoded);
        memcpy(temp, buffer.outBuffer, decoded);
        
        SLIAudioPlayer.Enqueue(*audioPlayer, temp, decoded);
    }
}