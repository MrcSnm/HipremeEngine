module hipaudio.backend.opensles.clip;
version(Android):
import hipaudio.backend.sles;
import hipaudio.audioclip;
import data.audio.audio;

class HipOpenSLESAudioClip : HipAudioClip
{
    this(IHipAudioDecoder decoder){super(decoder);}
    this(IHipAudioDecoder decoder, uint chunkSize){super(decoder, chunkSize);}

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
    override HipAudioBufferWrapper createBuffer(void* data, uint size)
    {
        HipAudioBufferWrapper w;
        w.buffer = sliGenBuffer(data, size);
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