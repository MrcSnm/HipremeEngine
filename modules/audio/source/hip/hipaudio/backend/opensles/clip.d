module hip.hipaudio.backend.opensles.clip;
version(Android):
import hip.hipaudio.backend.sles;
import hip.hipaudio.audioclip;
import hip.audio_decoding.audio;

class HipOpenSLESAudioClip : HipAudioClip
{
    this(IHipAudioDecoder decoder, HipAudioClipHint hint){super(decoder, hint);}
    this(IHipAudioDecoder decoder, HipAudioClipHint hint, uint chunkSize){super(decoder, hint, chunkSize);}

    override public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        uint ret = super.loadStreamed(data, encoding);
        if(ret != 0)
        {
            void* sliBuf = getBuffer(getClipData(), chunkSize);
            setBufferAvailable(sliBuf);
            hasBuffer = true;
        }
        return ret;
    }
    override void onUpdateStream(void* data, uint decodedSize){}

    /** Allocates SLIBuffer* in the wrapper*/
    override HipAudioBufferWrapper createBuffer(void* data, uint size)
    {
        HipAudioBufferWrapper w;
        w.buffer = sliGenBuffer(null, size); //Null init buffer
        w.bufferSize = (SLIBuffer*).sizeof;
        hasBuffer = true;
        return w;
    }
    override void destroyBuffer(void* buffer)
    {
        SLIBuffer* buf = cast(SLIBuffer*)buffer;
        sliDestroyBuffer(buf);
    }
    override void setBufferData(void* buffer, uint size, void* data)
    {
        SLIBuffer* buf = cast(SLIBuffer*)buffer;
        sliBufferData(buf, data);
    }


    bool hasBuffer;
}