/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipaudio.backend.openal.clip;
import data.audio.audio;
import hipaudio.audio;
import hipaudio.audiosource;
import data.audio.audioconfig;
import hipaudio.backend.openal.player;
import bindbc.openal;

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
    this(IHipAudioDecoder decoder){super(decoder);}
    this(IHipAudioDecoder decoder, uint chunkSize){super(decoder, chunkSize);}
    void loadALBuffer(uint bufferId, void* data, uint dataSize)
    {
        alBufferData(
            bufferId,
            HipOpenALAudioPlayer.config.getFormatAsOpenAL,
            data,
            dataSize,
            HipOpenALAudioPlayer.config.sampleRate
        );
    }
    
    override public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        uint ret = super.loadStreamed(data, encoding);
        return ret;
    }

    override void onUpdateStream(void* data, uint decodedSize)
    {
        // if(buffer == 0)
            // buffer = getNextBuffer();
        // loadALBuffer(buffer, this.outBuffer, decoded);
    }
    override HipAudioBufferWrapper createBuffer(void* data, uint bufferSize)
    {
        import core.stdc.stdlib:malloc;
        import core.stdc.string:memcpy;
        import console.log;
        ALuint id;
        alGenBuffers(1, &id);
        loadALBuffer(id, data, bufferSize);

        HipAudioBufferWrapper w;
        w.buffer = malloc(ALuint.sizeof);
        w.bufferSize = ALuint.sizeof;
        memcpy(w.buffer, &id, ALuint.sizeof);
        hasBuffer = true;
        return w;
    }
    override void destroyBuffer(void* buffer)
    {
        import core.stdc.stdlib:free;
        ALuint id = *cast(ALuint*)buffer;
        alDeleteBuffers(1, &id);
        free(buffer);
    }

    override void setBufferData(void* buffer, uint size, void* data)
    {
        ALuint bufferId = *(cast(ALuint*)buffer);
        loadALBuffer(bufferId, data, size);
    }

    ALuint getALBuffer(void* data, uint size){return *cast(ALuint*)getBuffer(data, size);}


    bool hasBuffer;

    ///If not present, it won't call the super class .load(string) for some reason
    alias load = HipAudioClip.load;
}
