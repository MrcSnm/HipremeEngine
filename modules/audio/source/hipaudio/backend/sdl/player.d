/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipaudio.backend.sdl.player;
import hipaudio.backend.sdl.clip;
import hipaudio.audiosource;
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
    public bool isMusicPlaying(AHipAudioSource src){return Mix_PlayingMusic() == 1;}
    public bool isMusicPaused(AHipAudioSource src){return Mix_PausedMusic() == 1;}
    public bool resume(AHipAudioSource src){Mix_ResumeMusic();return false;}
    public bool stop(AHipAudioSource src){Mix_HaltMusic();return false;}
    public bool pause(AHipAudioSource src){Mix_PauseMusic();return false;}
    public bool play_streamed(AHipAudioSource src){return false;}

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
    public void updateStream(AHipAudioSource source){}

    public AHipAudioSource getSource(bool isStreamed){return new HipAudioSource();}

    bool play(AHipAudioSource src)
    {
        HipAudioClip clip = (cast(HipAudioClip)src.clip);
        HipSDL_MixerDecoder dec = cast(HipSDL_MixerDecoder)clip.decoder;
        if(clip.type == HipAudioType.SFX)   
            return Mix_PlayChannel(-1, dec.getChunk(), 1) == 1;
        else
            return Mix_PlayMusic(dec.getMusic(), -1) == 1;
    }
    void setPitch(AHipAudioSource src, float pitch){}
    void setPanning(AHipAudioSource src, float panning){}
    void setVolume(AHipAudioSource src, float volume){}
    public void setMaxDistance(AHipAudioSource src, float dist){}
    public void setRolloffFactor(AHipAudioSource src, float factor){}
    public void setReferenceDistance(AHipAudioSource src, float dist){}

    public void onDestroy()
    {
        logln("Audio Died");
        Mix_CloseAudio();
        Mix_Quit();
    }
}
