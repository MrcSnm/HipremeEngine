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
import implementations.audio.audiobase;
import implementations.audio.backend.audiosource;
import implementations.audio.backend.audioconfig;
import implementations.audio.backend.openal.player;
import bindbc.openal;

public class HipOpenALBuffer : HipAudioBuffer
{
    this(IHipAudioDecoder decoder)
    {
        super(decoder);
        alGenBuffers(1, &bufferId);
    }

    override public bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        if(super.load(data, encoding, type, isStreamed))
        {
            alBufferData(
                bufferId,
                HipOpenALAudioPlayer.config.getFormatAsOpenAL(),
                getBuffer(),
                cast(ALsizei)getBufferSize(),
                HipOpenALAudioPlayer.config.sampleRate
            );
            return true;
        }
        return false;
    }

    override public void unload()
    {
        super.unload();
        alDeleteBuffers(1, &bufferId);
        bufferId = -1;
    }

    /**
    * Id for accessing via OpenAL Soft
    */
    public ALuint bufferId;
}
