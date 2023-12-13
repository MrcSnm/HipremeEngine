module hip.hipaudio.backend.avaudio.source;

version(iOS):
import avaudiosourcenode;
import avaudioplayernode;
import avaudiosinknode;
import avaudioionode;
import hip.hipaudio.backend.avaudio.clip;
import hip.error.handler;
import hip.hipaudio.backend.avaudio.player;
import hip.hipaudio.audiosource;

class HipAVAudioSource : HipAudioSource
{
    AVAudioSinkNode sink;
    AVAudioPlayerNode player;
    AVAudioPCMBuffer buffer;

    protected bool isClipDirty = true;


    this(HipAVAudioPlayer player)
    {
        this.player = player.playerNode;
    }
    alias clip = HipAudioSource.clip;


    override IHipAudioClip clip(IHipAudioClip newClip)
    {
        if(newClip != clip)
            isClipDirty = true;
        super.clip(newClip);
        return newClip;
    }

    alias loop = HipAudioSource.loop;
    override bool loop(bool value)
    {
        bool ret = super.loop(value);
        return ret;
    }

    
        
    override bool play()
    {
        if(isPlaying)
        {
        }
        player.scheduleBuffer(getBufferFromAPI(clip).avaudio);
        player.play();
        return true;
    }
    override bool stop()
    {
        player.stop();
        isPlaying = false;
        return false;
    }
    override bool pause()
    {
        player.pause();
        isPaused = true;
        return false;
    }
    override bool play_streamed() => false;
    

    ~this()
    {
        
    }
}
