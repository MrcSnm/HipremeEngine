/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module data.audio.audioconfig;
import bindbc.sdl.bind.sdlaudio;
import util.reflection;
import sdl_sound;
public import hipengine.api.data.audio;

private enum SDL_AudioFormat[AudioFormat] _getFormatAsSDL_AudioFormat =
[
    AudioFormat.unsigned8       : SDL_AudioFormat.AUDIO_U8,
    AudioFormat.signed8         : SDL_AudioFormat.AUDIO_S8,
    AudioFormat.signed16Little  : SDL_AudioFormat.AUDIO_S16LSB,
    AudioFormat.signed16Big     : SDL_AudioFormat.AUDIO_S16MSB,
    AudioFormat.unsigned16Little: SDL_AudioFormat.AUDIO_U16LSB,
    AudioFormat.unsigned16Big   : SDL_AudioFormat.AUDIO_U16MSB,
    AudioFormat.signed32Little  : SDL_AudioFormat.AUDIO_S32LSB,
    AudioFormat.signed32Big     : SDL_AudioFormat.AUDIO_S32MSB,
    AudioFormat.float32Little   : SDL_AudioFormat.AUDIO_F32LSB,
    AudioFormat.float32Big      : SDL_AudioFormat.AUDIO_F32MSB
];


/**
*   Params:
*       value =  AudioFormat
*   Returns: SDL_AudioFormat
*/
alias getFormatAsSDL_AudioFormat = aaToSwitch!_getFormatAsSDL_AudioFormat;


/** 
 *  Params: 
 *       value = SDL_AudioFormat
 *  Returns: AudioFormat
 */
alias getFormatFromSDL_AudioFormat = aaToSwitch!(_getFormatAsSDL_AudioFormat, true);

package Sound_AudioInfo getSDL_SoundInfo(AudioConfig cfg)
{
    return Sound_AudioInfo(getFormatAsSDL_AudioFormat(cfg.format), cast(ubyte)cfg.channels, cfg.sampleRate);
}