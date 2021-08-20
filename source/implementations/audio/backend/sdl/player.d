/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.backend.sdl.player;
import implementations.audio.backend.sdl.buffer;
import implementations.audio.backend.audiosource;
import implementations.audio.audiobase;
import def.debugging.log;
import audio.audio;
import bindbc.sdl.mixer;
import implementations.audio.backend.audioconfig;

class HipSDLAudioPlayer : IHipAudioPlayer
{
    public this(AudioConfig cfg)
    {
        HipSDL_MixerDecoder.initDecoder();
        Mix_OpenAudio(cfg.sampleRate, cfg.format, cfg.channels, cfg.bufferSize);
    }
    public bool isMusicPlaying(HipAudioSource src){return Mix_PlayingMusic() == 1;}
    public bool isMusicPaused(HipAudioSource src){return Mix_PausedMusic() == 1;}
    public bool resume(HipAudioSource src){Mix_ResumeMusic();return false;}
    public bool stop(HipAudioSource src){Mix_HaltMusic();return false;}
    public bool pause(HipAudioSource src){Mix_PauseMusic();return false;}
    public bool play_streamed(HipAudioSource src){return false;}

    public HipAudioBuffer load(string audioName, HipAudioType bufferType)
    {
        HipAudioBuffer buffer = new HipAudioBuffer(new HipSDL_MixerDecoder());
        buffer.load(audioName,getEncodingFromName(audioName), bufferType);
        return buffer;
    }
    public HipAudioSource getSource(){return new HipAudioSource();}

    bool play(HipAudioSource src)
    {
        HipSDL_MixerDecoder dec = cast(HipSDL_MixerDecoder)src.buffer.decoder;
        if(src.buffer.type == HipAudioType.SFX)   
            return Mix_PlayChannel(-1, dec.getChunk(), 1) == 1;
        else
            return Mix_PlayMusic(dec.getMusic(), -1) == 1;
    }
    void setPitch(HipAudioSource src, float pitch){}
    void setPanning(HipAudioSource src, float panning){}
    void setVolume(HipAudioSource src, float volume){}
    public void setMaxDistance(HipAudioSource src, float dist){}
    public void setRolloffFactor(HipAudioSource src, float factor){}
    public void setReferenceDistance(HipAudioSource src, float dist){}

    public void onDestroy()
    {
        logln("Audio Died");
        Mix_CloseAudio();
        Mix_Quit();
    }
}
