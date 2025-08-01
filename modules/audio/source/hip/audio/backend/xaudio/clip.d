module hip.audio.backend.xaudio.clip;

version(Windows):
version(XAudio2):
import hip.audio.clip;
import directx.xaudio2;

class HipXAudioClip : HipAudioClip
{
    XAUDIO2_BUFFER buffer;
    this(IHipAudioDecoder decoder, HipAudioClipHint hint)
    {
        super(decoder, hint); //TODO: Change num channels
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
    override void setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size = 0)
    {
        this.buffer.AudioBytes = size == 0 ? cast(uint)data.length : size;
        this.buffer.pAudioData = cast(ubyte*)data.ptr;
    }

    ///Nothing to do
    override protected void onUpdateStream(ubyte[] data, uint decodedSize){}

    ///Wraps an XAudio buffer
    override protected HipAudioBufferWrapper createBuffer(ubyte[] data)
    {
        HipAudioBufferWrapper ret; // TODO: implement
        ret.buffer.xaudio = &buffer;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(HipAudioBuffer* buffer)
    {

    }
}