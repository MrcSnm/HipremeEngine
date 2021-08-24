/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.backend.openal.buffer;
import audio.audio;
import implementations.audio.audio;
import implementations.audio.backend.audiosource;
import implementations.audio.backend.audioconfig;
import implementations.audio.backend.openal.player;
import bindbc.openal;

public class HipOpenALBuffer : HipAudioBuffer
{
    this(IHipAudioDecoder decoder)
    {
        super(decoder);
        getNextBuffer();
    }
    this(IHipAudioDecoder decoder, uint chunkSize)
    {
        super(decoder, chunkSize);
    }

    override public bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        if(super.load(data, encoding, type, isStreamed))
        {
            alBufferData(
                bufferPool[0],
                HipOpenALAudioPlayer.config.getFormatAsOpenAL(),
                getBuffer(),
                cast(ALsizei)getBufferSize(),
                HipOpenALAudioPlayer.config.sampleRate
            );
            return true;
        }
        return false;
    }
    override public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        uint ret = super.loadStreamed(data, encoding);
        if(ret != 0)
        {
            alBufferData(
                getNextBuffer(),
                HipOpenALAudioPlayer.config.getFormatAsOpenAL(),
                getBuffer(),
                cast(ALsizei)getBufferSize(),
                HipOpenALAudioPlayer.config.sampleRate
            );
            return true;
        }
        return false;
    }

    ref ALuint getNextBuffer()
    {
        hasBuffer = true;
        poolCursor++;
        if(poolCursor == bufferPool.length)
        {
            import def.debugging.log;
            bufferPool.length++;
            alGenBuffers(1, &bufferPool[$-1]);
        }
        return bufferPool[poolCursor];
    }
    int* getFreeBuffer()
    {
        int buffersProcessed;
        return null;
        // alGetSourcei(srcId, AL_BUFFERS_PROCESSED, &buffersProcessed);
    }
    
    override public void unload()
    {
        super.unload();
        if(bufferPool.length > 0)
            alDeleteBuffers(cast(ALsizei)bufferPool.length, bufferPool.ptr);
        hasBuffer = false;
    }

    /**
    * Id for accessing via OpenAL Soft
    */
    public ALuint[] bufferPool;
    bool hasBuffer;
    int poolCursor = -1;


    ///If not present, it won't call the super class .load(string) for some reason
    alias load = HipAudioBuffer.load;
}
