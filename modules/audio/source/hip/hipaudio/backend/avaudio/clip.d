module hip.hipaudio.backend.avaudio.clip;

version(iOS):
public import avaudiobuffer;
public import avaudiotypes;
import objc.runtime;
import avaudiosinknode;
import hip.hipaudio.backend.audioclipbase;
import hip.hipaudio.backend.avaudio.player;
import hip.api.data.audio;
import avaudiosourcenode;
import avaudioconverter;


extern(C) void tempDeallocator(const(AudioBufferList)* bufferList)
{
    import hip.util.memory;
    free(cast(void*)bufferList);
}

AudioBufferList* getAudioBufferList(AudioBuffer buff)
{
    import hip.util.memory;
    AudioBufferList* ret = cast(AudioBufferList*)malloc(AudioBufferList.sizeof);
    ret.mNumberBuffers = 1;
    ret.mBuffers[0] = buff;
    return ret;
}

class HipAVAudioClip : HipAudioClip
{
    AVAudioSourceNode source;
    AVAudioPCMBuffer buffer;
    AVAudioConverter converter;

    this(IHipAudioDecoder decoder, HipAudioClipHint hint)
    {
        super(decoder, hint); //TODO: Change num channels
    }
    override void setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size = 0)
    {
        if(getHint.needsChannelConversion || getHint.needsDecode || getHint.needsResample)
        {
            import hip.console.log;
            import hip.util.conv;

            static void debugFormat(AVAudioFormat f)
            {
                import hip.console.log;
                logln("sampleRate: ", f.sampleRate, " , interleaved: ", f.isInterleaved, " format: ", f.commonFormat );
            }
            static void debugBuffer(AVAudioPCMBuffer b)
            {
                import hip.console.log;
                logln("frameLength: ", b.frameLength, " , frameCapacity: ", b.frameCapacity, " stride: ", b.stride);
            }
            
            AVAudioFormat rawFormat = HipAVAudioPlayer.fromConfig(decoder.getAudioConfig);
            converter = AVAudioConverter.alloc.initFromFormat(
                rawFormat,
                HipAVAudioPlayer.fromConfig(HipAVAudioPlayer.getAudioConfig)
            );

            AudioBufferList* list = getAudioBufferList(AudioBuffer(decoder.getClipChannels, 
                cast(uint)getClipSize, getClipData.ptr)
            );

            AVAudioPCMBuffer temp = AVAudioPCMBuffer.alloc.initWithPCMFormat(
                rawFormat, list, &tempDeallocator
            );


            NSError err;
            auto convFn = block((AVAudioPacketCount inNumberOfPackets, AVAudioConverterInputStatus* outStatus)
            {
                if(temp.frameLength > 0)
                {
                    *outStatus = AVAudioConverterInputStatus._HaveData;
                    return cast(AVAudioBuffer)temp;
                }
                else
                {
                    *outStatus = AVAudioConverterInputStatus._NoDataNow;
                    return null;
                }
            });

            converter.convertToBuffer(cast(AVAudioBuffer)buffer.avaudio, &err, &convFn);

            if(err)
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

    ///Wraps an AVAudioBuffer buffer    
    override protected HipAudioBufferWrapper createBuffer(ubyte[] data)
    {
        this.buffer = AVAudioPCMBuffer.alloc.initWithPCMFormat(HipAVAudioPlayer.fromConfig(HipAVAudioPlayer.getAudioConfig), cast(uint)data.length);
        HipAudioBufferWrapper ret; // TODO: implement
        ret.buffer.avaudio = buffer;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(HipAudioBuffer* buffer)
    {
        
    }
}