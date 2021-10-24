module hipaudio.backend.xaudio.clip;

version(Windows):
import hipaudio.audioclip;
import directx.xaudio2;

class HipXAudioClip : HipAudioClip
{
    XAUDIO2_BUFFER buffer;
    this(IHipAudioDecoder decoder)
    {
        super(decoder);
        buffer.Flags = 0;
        buffer.AudioBytes = 0; //How many bytes there is in this buffer
        buffer.pAudioData = null; //Data
        buffer.PlayBegin  = 0; //Seek?
        buffer.PlayLength = 0; //Play the entire buffer
        buffer.LoopBegin  = 0;
        buffer.LoopCount  = 0;
        buffer.LoopLength = 0;
        buffer.pContext   = null;
    }
    override void setBufferData(void* buffer, uint size, void* data)
    {
        this.buffer.AudioBytes = size;
        this.buffer.pAudioData = cast(ubyte*)data;
    }
    
    ///Nothing to do
    override protected void onUpdateStream(void* data, uint decodedSize){}

    ///Wraps an XAudio buffer    
    override protected HipAudioBufferWrapper createBuffer(void* data, uint size)
    {
        HipAudioBufferWrapper ret; // TODO: implement
        ret.buffer = &buffer;
        ret.bufferSize = buffer.sizeof;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(void* buffer)
    {
        
    }

}