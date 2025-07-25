module hip.audio.backend.webaudio.clip;

version(WebAssembly):
import hip.audio.clip;
import hip.audio_decoding.audio;

/**
*   This class is extremely linked/dependent on HipWebAudioDecoder.
*   It was done that way because WebAudio don't let the data be put inside
*   a buffer.
*   See the function `WasmDecodeAudio` on webaudio.js
*/
class HipWebAudioClip : HipAudioClip
{
    HipWebAudioDecoder decoder;
    this(IHipAudioDecoder decoder, HipAudioClipHint hint)
    {
        super(decoder, hint);
    }
    override void setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size = 0)
    {
        buffer.webaudio = *cast(size_t*)data.ptr; //Only a handle to the real data.
    }

    ///Nothing to do
    override protected void onUpdateStream(ubyte[] data, uint decodedSize){}

    ///Wraps an XAudio buffer
    override protected HipAudioBufferWrapper createBuffer(ubyte[] data)
    {
        HipAudioBufferWrapper ret; // TODO: implement
        ret.buffer.webaudio = *cast(size_t*)data.ptr;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(HipAudioBuffer* buffer)
    {

    }

}