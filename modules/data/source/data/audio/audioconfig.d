module data.audio.audioconfig;

/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
import error.handler;
import std.conv:to;
import bindbc.sdl.mixer;
import bindbc.sdl : SDL_AudioFormat;
import sdl_sound;


package SDL_AudioFormat getFormatAsSDL_AudioFormat(AudioConfig cfg)
{
    if(cfg.format == MIX_DEFAULT_FORMAT)
    {
        version(LittleEndian) return SDL_AudioFormat.AUDIO_S16LSB;
        else return SDL_AudioFormat.AUDIO_S16MSB;
    }
    return SDL_AudioFormat.AUDIO_S16;
}
package Sound_AudioInfo getSDL_SoundInfo(AudioConfig cfg)
{
    return Sound_AudioInfo(cfg.getFormatAsSDL_AudioFormat, cast(ubyte)cfg.channels, cfg.sampleRate);
}

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