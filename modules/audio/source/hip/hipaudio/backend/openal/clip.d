/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hipaudio.backend.openal.clip;

version(OpenAL):
import hip.audio_decoding.audio;
import hip.hipaudio.audio;
import hip.hipaudio.audiosource;
import hip.hipaudio.backend.openal.player;
import bindbc.openal;
import hip.hipaudio.backend.openal.al_err;

/** 
 * OpenAL Buffer works in the following way:
 * If the buffer is streamed, it won't be owned by any source, so it will have total control
 * over itself. That way, it can be reused by any source.
 *
 * Else, the buffer will be owned by the source for decoding, updating, and pulling data.
 *
 */
public class HipOpenALClip : HipAudioClip
{
    this(IHipAudioDecoder decoder, HipAudioClipHint hint){super(decoder, hint);}
    this(IHipAudioDecoder decoder, HipAudioClipHint hint, uint chunkSize){super(decoder, hint, chunkSize);}
    
    override public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        uint ret = super.loadStreamed(data, encoding);
        return ret;
    }

    override void onUpdateStream(void[] data, uint decodedSize){}

    /** Allocates ALuint in the bufferwrapper */
    override HipAudioBufferWrapper2 createBuffer(void[] data)
    {
        // import hip.console.log;
        HipAudioBufferWrapper2 w;
        alGenBuffers(1, &w.buffer.al);
        alCheckError("Error generating OpenAL Buffer");
        hasBuffer = true;
        return w;
    }

    override void destroyBuffer(HipAudioBuffer* buffer)
    {
        alDeleteBuffers(1, &buffer.al);
        alCheckError("Error deleting OpenAL Buffer");
    }

    override void setBufferData(HipAudioBuffer* buffer, void[] data, uint size = 0)
    {
        alBufferData(
            buffer.al,
            HipOpenALAudioPlayer.config.getFormatAsOpenAL,
            data.ptr,
            size == 0 ? cast(int)data.length : size,
            decoder.getSamplerate()
        );
        alCheckError("Error setting OpenAL Buffer Data");
    }

    bool hasBuffer;

    ///If not present, it won't call the super class .load(string) for some reason
    alias load = HipAudioClip.load;
}
