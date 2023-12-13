module hip.hipaudio.backend.avaudio.clip;

version(iOS):
import avaudiosinknode;
import avaudiobuffer;
import hip.hipaudio.audioclip;
import hip.api.data.audio;
import avaudiosourcenode;
import avaudiobuffer;
import avaudioconverter;

class HipAVAudioClip : HipAudioClip
{
    AVAudioSourceNode source;
    AVAudioBuffer buffer;
    AVAudioConverter converter;

    this(IHipAudioDecoder decoder, HipAudioClipHint hint)
    {
        super(decoder, hint); //TODO: Change num channels
        buffer = AVAudioBuffer.alloc.init;
        
        converter = AVAudioConverter.alloc.initFromFormat(
            HipAVAudioPlayer.fromFormat(decoder.getAudioConfig),
            HipAVAudioPlayer.fromFormat(HipAVAudioPlayer.getAudioConfig)
        );
    }
    override void setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size = 0)
    {
    }
    
    ///Nothing to do
    override protected void onUpdateStream(ubyte[] data, uint decodedSize){}

    ///Wraps an XAudio buffer    
    override protected HipAudioBufferWrapper createBuffer(ubyte[] data)
    {
        HipAudioBufferWrapper ret; // TODO: implement
        // ret.buffer.xaudio = &buffer;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(HipAudioBuffer* buffer)
    {
        
    }
}