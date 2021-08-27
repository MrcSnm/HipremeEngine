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
}