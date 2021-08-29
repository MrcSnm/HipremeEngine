/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hipaudio.backend.sdl.player;
import hipaudio.backend.sdl.clip;
import hipaudio.backend.audiosource;
import hipaudio.audio;
import error.handler;
import console.log;
import data.audio.audio;
import bindbc.sdl.mixer;
import data.audio.audioconfig;

class HipSDLAudioPlayer : IHipAudioPlayer
{
    public this(AudioConfig cfg)
    {
        HipSDL_MixerDecoder.initDecoder(cfg);
        Mix_OpenAudio(cfg.sampleRate, cfg.format, cfg.channels, cfg.bufferSize);
    }
    public bool isMusicPlaying(HipAudioSource src){return Mix_PlayingMusic() == 1;}
    public bool isMusicPaused(HipAudioSource src){return Mix_PausedMusic() == 1;}
    public bool resume(HipAudioSource src){Mix_ResumeMusic();return false;}
    public bool stop(HipAudioSource src){Mix_HaltMusic();return false;}
    public bool pause(HipAudioSource src){Mix_PauseMusic();return false;}
    public bool play_streamed(HipAudioSource src){return false;}

    public HipAudioClip load(string audioName, HipAudioType bufferType)
    {
        return null;
        // HipAudioClip buffer = new HipAudioClip(new HipSDL_MixerDecoder());
        // buffer.load(audioName,getEncodingFromName(audioName), bufferType);
        // return buffer;
    }
    public HipAudioClip loadStreamed(string audioName, uint chunkSize)
    {
        ErrorHandler.assertExit(false, "SDL Audio Player does not support chunked decoding");
        return null;
    }
    public void updateStream(HipAudioSource source){}

    public HipAudioSource getSource(bool isStreamed){return new HipAudioSource();}

    bool play(HipAudioSource src)
    {
        HipSDL_MixerDecoder dec = cast(HipSDL_MixerDecoder)src.clip.decoder;
        if(src.clip.type == HipAudioType.SFX)   
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
