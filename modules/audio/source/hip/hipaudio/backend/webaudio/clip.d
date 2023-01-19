module hip.hipaudio.backend.webaudio.clip;

version(WebAssembly):
import hip.hipaudio.audioclip;
import hip.audio_decoding.audio;

/**
*   This class is extremely linked/dependent on HipWebAudioDecoder.
*   It was done that way because WebAudio don't let the data be put inside
*   a buffer.
*   See the function `WasmDecodeAudio` on webaudio.js
*/
class HipWebAudioClip : HipAudioClip
{
    size_t buffer;
    HipWebAudioDecoder decoder;
    this(IHipAudioDecoder decoder, HipAudioClipHint hint)
    {
        super(decoder, hint); //TODO: Change num channels
        this.decoder = cast(HipWebAudioDecoder)decoder;
    }
    override void setBufferData(HipAudioBuffer* buffer, void[] data, uint size = 0)
    {
        this.buffer = buffer.webaudio = *cast(size_t*)data.ptr; //Only a handle to the real data.
    }
    
    ///Nothing to do
    override protected void onUpdateStream(void[] data, uint decodedSize){}

    ///Wraps an XAudio buffer    
    override protected HipAudioBufferWrapper2 createBuffer(void[] data)
    {
        HipAudioBufferWrapper2 ret; // TODO: implement
        ret.buffer.webaudio = buffer;
        return ret;
    }


    ///Calls XAudio2.9 specific buffer destroy
    override protected void destroyBuffer(HipAudioBuffer* buffer)
    {
        
    }

}