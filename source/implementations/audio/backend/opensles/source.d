module implementations.audio.backend.opensles.source;
import implementations.audio.backend.sles;
import util.time;
import implementations.audio.backend.audiosource;

version(Android):

class HipOpenSLESAudioSource : HipAudioSource
{
    SLIAudioPlayer* audioPlayer;
    this(SLIAudioPlayer* player)
    {
        audioPlayer = player;
    }
}