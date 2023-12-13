module hip.hipaudio.backend.avaudio.clip;

version(iOS):
public import avaudiobuffer;
public import avaudiotypes;
import objc.runtime;
import avaudiosinknode;
import hip.hipaudio.audioclip;
import hip.hipaudio.backend.avaudio.player;
import hip.api.data.audio;
import avaudiosourcenode;
import avaudioconverter;


extern(C++) void tempDeallocator(const AudioBufferList*)
{

}

class HipAVAudioClip : HipAudioClip
{
    AVAudioSourceNode source;
    AVAudioPCMBuffer buffer;
    AVAudioConverter converter;

    this(IHipAudioDecoder decoder, HipAudioClipHint hint)
    {
        super(decoder, hint); //TODO: Change num channels
        buffer = AVAudioPCMBuffer.alloc.init;
    }
    override void setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size = 0)
    {
        if(getHint.needsChannelConversion || getHint.needsDecode || getHint.needsResample)
        {
            AVAudioFormat rawFormat = HipAVAudioPlayer.fromConfig(decoder.getAudioConfig);
            converter = AVAudioConverter.alloc.initFromFormat(
                rawFormat,
                HipAVAudioPlayer.fromConfig(HipAVAudioPlayer.getAudioConfig)
            );

            AudioBufferList list = AudioBufferList(1, AudioBuffer(decoder.getClipChannels, 
                cast(uint)getClipSize, getClipData.ptr)
            );

            AVAudioPCMBuffer temp = AVAudioPCMBuffer.alloc.initWithPCMFormat(
                rawFormat, &list, &tempDeallocator
            );

            NSError err;
            if(!converter.convertToBuffer(this.buffer, temp, &err))
            {
                import hip.error.handler;
                ErrorHandler.assertExit(false, "Could not convert buffer: "~err.toString);
            }
        }
        else
        {
            AVAudioFormat rawFormat = HipAVAudioPlayer.fromConfig(decoder.getAudioConfig);
            AudioBufferList list = AudioBufferList(1, AudioBuffer(decoder.getClipChannels, 
                cast(uint)getClipSize, getClipData.ptr)
            );
            this.buffer = AVAudioPCMBuffer.alloc.initWithPCMFormat(
                rawFormat, &list, &tempDeallocator
            );
        }
        
    }
    
    ///Nothing to do
    override protected void onUpdateStream(ubyte[] data, uint decodedSize){}

    ///Wraps an XAudio buffer    
    override protected HipAudioBufferWrapper createBuffer(ubyte[] data)
    {
        HipAudioBufferWrapper ret; // TODO: implement
        ret.buffer.avaudio = buffer;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(HipAudioBuffer* buffer)
    {
        
    }
}