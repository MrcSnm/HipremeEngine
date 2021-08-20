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
import bindbc.sdl.mixer;

class HipSDLAudioPlayer : IAudioPlayer
{
    public this(AudioConfig cfg)
    {
        Mix_OpenAudio(cfg.sampleRate, cfg.format, cfg.channels, cfg.bufferSize);
    }
    public bool isMusicPlaying(AudioSource src){return Mix_PlayingMusic() == 1;}
    public bool isMusicPaused(AudioSource src){return Mix_PausedMusic() == 1;}
    public bool resume(AudioSource src){Mix_ResumeMusic();return false;}
    public bool stop(AudioSource src){Mix_HaltMusic();return false;}
    public bool pause(AudioSource src){Mix_PauseMusic();return false;}
    public bool play_streamed(AudioSource src){return false;}

    public AudioBuffer load(string audioName, AudioBuffer.TYPE bufferType)
    {
        SDL_MixerBuffer buffer = new SDL_MixerBuffer();
        buffer.defaultLoad(audioName, bufferType);
        return buffer;
    }
    public AudioSource getSource(){return new AudioSource();}

    bool play(AudioSource src)
    {
        if(src.buffer.bufferType == AudioBuffer.TYPE.SFX)   
            return Mix_PlayChannel(-1, (cast(SDL_MixerBuffer)src.buffer).chunk, 1) == 1;
        else
            return Mix_PlayMusic((cast(SDL_MixerBuffer)src.buffer).music, -1) == 1;
    }
    void setPitch(AudioSource src, float pitch){}
    void setPanning(AudioSource src, float panning){}
    void setVolume(AudioSource src, float volume){}
    public void setMaxDistance(AudioSource src, float dist){}
    public void setRolloffFactor(AudioSource src, float factor){}
    public void setReferenceDistance(AudioSource src, float dist){}

    public void onDestroy()
    {
        logln("Audio Died");
        Mix_CloseAudio();
        Mix_Quit();
    }
}
