module hip.hipaudio.backend.avaudio.source;

version(iOS):
import avaudiosourcenode;
import avaudioplayernode;
import avaudiosinknode;
import avaudioionode;
import hip.error.handler;
import hip.hipaudio.backend.avaudio.player;
import hip.hipaudio.audiosource;

class HipAVAudioSource : HipAudioSource
{
    AVAudioSinkNode sink;
    AVAudioOutputNode output;

    protected bool isClipDirty = true;


    this(HipAVAudioPlayer player)
    {
        import hip.util.conv;
        output = player.engine.outputNode;        
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

        return true;
    }
    override bool stop()
    {
        isPlaying = false;
        return false;
    }
    override bool pause()
    {
        isPaused = true;
        return false;
    }
    override bool play_streamed() => false;
    

    ~this()
    {
        
    }
}
