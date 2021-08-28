module hipaudio.backend.opensles.clip;
version(Android):
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
            sliGenBuffer(getClipData(), chunkSize);
            hasBuffer = true;
        }
        return ret;
    }

    bool hasBuffer;
}