module data.audio.audioconfig;

/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

import error.handler;
import std.conv:to;
import bindbc.sdl.mixer;
import bindbc.sdl : SDL_AudioFormat;
import sdl_sound;

struct AudioConfig
{
    int sampleRate;
    ushort format;
    int channels;
    int bufferSize;
    public immutable static uint defaultBufferSize = 4096;

    /**
    *   Returns a default audio configuration for 2D
    */
    static AudioConfig musicConfig()
    {
        AudioConfig cfg;
        cfg.sampleRate = 44_100;
        cfg.format = MIX_DEFAULT_FORMAT;
        cfg.channels = 2U;
        cfg.bufferSize = 4096;
        return cfg;
    }
    static AudioConfig lightweightConfig()
    {
        AudioConfig cfg;
        cfg.sampleRate = 22_050;
        cfg.format = MIX_DEFAULT_FORMAT;
        cfg.channels = 1U;
        cfg.bufferSize = 2048;
        return cfg;
    }
    SDL_AudioFormat getFormatAsSDL_AudioFormat()
    {
        if(format == MIX_DEFAULT_FORMAT)
        {
            version(LittleEndian)
            {
                return SDL_AudioFormat.AUDIO_S16LSB;
            }
            else
            {
                return SDL_AudioFormat.AUDIO_S16MSB;
            }
        }
        return SDL_AudioFormat.AUDIO_S16;
    }
    Sound_AudioInfo getSDL_SoundInfo()
    {
        return Sound_AudioInfo(getFormatAsSDL_AudioFormat(), cast(ubyte)channels, sampleRate);
    }
    version(Android)
    {
        import opensles.sles;
        SLDataFormat_PCM getFormatAsOpenSLES()
        {
            SLDataFormat_PCM ret;
            ret.formatType = SL_DATAFORMAT_PCM;
            ret.numChannels = channels; //2 channels seems to not be supported yet
            ret.samplesPerSec = sampleRate*1000;
            switch(format)
            {
                //Big
                case SDL_AudioFormat.AUDIO_S16MSB:
                    ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
                    ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
                    ret.endianness = SL_BYTEORDER_BIGENDIAN;
                    break;
                case SDL_AudioFormat.AUDIO_S32MSB:
                    ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
                    ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
                    ret.endianness = SL_BYTEORDER_BIGENDIAN;
                    break;

                case SDL_AudioFormat.AUDIO_S8:
                    ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_8;
                    ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_8;
                    ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
                    break;
                default:
                case SDL_AudioFormat.AUDIO_S16LSB:
                    ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
                    ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
                    ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
                    break;
                //Little
                case SDL_AudioFormat.AUDIO_S32LSB:
                    ret.containerSize = SL_PCMSAMPLEFORMAT_FIXED_32;
                    ret.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_32;
                    ret.endianness = SL_BYTEORDER_LITTLEENDIAN;
                    break;
            }
            if(channels == 2)
                ret.channelMask = SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT;
            else if(channels == 1)
                ret.channelMask = SL_SPEAKER_FRONT_CENTER;
            else
                ErrorHandler.showErrorMessage("OpenSL ES Audio Config.", "OpenSL ES does not supports " ~ to!string(channels)~" channels");

            return ret;
        }
    }

    uint getBitDepth()
    {
        switch(format)
        {
            case SDL_AudioFormat.AUDIO_U8:
            case SDL_AudioFormat.AUDIO_S8:
                return 8;
            case SDL_AudioFormat.AUDIO_S16LSB:
            case SDL_AudioFormat.AUDIO_S16MSB:
            case SDL_AudioFormat.AUDIO_U16LSB:
            case SDL_AudioFormat.AUDIO_U16MSB:
                return 16;
            case SDL_AudioFormat.AUDIO_S32LSB:
            case SDL_AudioFormat.AUDIO_S32MSB:
            case SDL_AudioFormat.AUDIO_F32LSB:
            case SDL_AudioFormat.AUDIO_F32MSB:
                return 32;
            default:return 0;
        }
    }
}