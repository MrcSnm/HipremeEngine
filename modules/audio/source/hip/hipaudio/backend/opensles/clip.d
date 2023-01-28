module hip.hipaudio.backend.opensles.clip;
version(Android):
import hip.hipaudio.backend.sles;
import hip.hipaudio.audioclip;
import hip.audio_decoding.audio;

class HipOpenSLESAudioClip : HipAudioClip
{
    this(IHipAudioDecoder decoder, HipAudioClipHint hint){super(decoder, hint);}
    this(IHipAudioDecoder decoder, HipAudioClipHint hint, uint chunkSize){super(decoder, hint, chunkSize);}

    override public uint loadStreamed(in ubyte[] data, HipAudioEncoding encoding)
    {
        uint ret = super.loadStreamed(data, encoding);
        if(ret != 0)
        {
            HipAudioBuffer sliBuf = getBuffer(getClipData(), chunkSize);
            setBufferAvailable(sliBuf);
            hasBuffer = true;
        }
        return ret;
    }
    override void onUpdateStream(ubyte[] data, uint decodedSize){}

    /** Allocates SLIBuffer* in the wrapper*/
    override HipAudioBufferWrapper2 createBuffer(ubyte[] data)
    {
        HipAudioBufferWrapper2 w;
        w.buffer.sles = sliGenBuffer(null, data.length); //Null init buffer
        hasBuffer = true;
        return w;
    }
    override void  destroyBuffer(HipAudioBuffer* buffer)
    {
        sliDestroyBuffer(buffer.sles);
    }
    override void  setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size)
    {
        sliBufferData(buffer.sles, data);
    }


    bool hasBuffer;
}