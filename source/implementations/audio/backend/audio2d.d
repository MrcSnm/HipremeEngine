/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.backend.audio2d;
import implementations.audio.audiobase;
import implementations.audio.audio;
import std.string : lastIndexOf;
import bindbc.sdl.mixer;
import bindbc.sdl;
import def.debugging.log;

class SDL_MixerBuffer : AudioBuffer
{
    override public bool load(string audioPath, TYPE audioType, bool isStreamed = false)
    {
        if(audioType == AudioBuffer.TYPE.SFX)
        {
            //Loads .ogg,  .wav, .aiff, .riff, .voc
            chunk = Mix_LoadWAV(cast(const(char)*)audioPath);
            return chunk != null;
        }
        else
        {
            //Loads .ogg, .mp3, .wav, .flac, .midi
            music = Mix_LoadMUS(cast(const(char)*)audioPath);
            return music != null;
        }
    }

    override public void unload()
    {
        if(bufferType == AudioBuffer.TYPE.SFX)
        {
            Mix_FreeChunk(chunk);
            chunk = null;
        }
        else
        {
            Mix_FreeMusic(music);
            music = null;
        }
    }

    union
    {
        Mix_Chunk* chunk;
        Mix_Music* music;
    }
}

class Audio2DBackend : IAudio
{
    public this(AudioConfig cfg)
    {
        Mix_OpenAudio(cfg.sampleRate, cfg.format, cfg.channels, cfg.bufferSize);
    }
    public bool isMusicPlaying(AudioSource src)
    {
        return Mix_PlayingMusic() == 1;
    }
    public bool isMusicPaused(AudioSource src){return Mix_PausedMusic() == 1;}

    public bool resume(AudioSource src)
    {
        Mix_ResumeMusic();
        return false;
    }
    
    public bool stop(AudioSource src)
    {
        Mix_HaltMusic();
        return false;
    }
    public bool pause(AudioSource src)
    {
        Mix_PauseMusic();
        return false;
    }
    public bool play_streamed(AudioSource src)
    {

        return false;
    }

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
    void setPitch(AudioSource src, float pitch)
    {
        
    }
    void setPanning(AudioSource src, float panning){}
    void setVolume(AudioSource src, float volume){}

    public void setMaxDistance(AudioSource src, float dist){}
    public void setRolloffFactor(AudioSource src, float factor){}
    public void setReferenceDistance(AudioSource src, float dist){}

    public void onDestroy()
    {
        // foreach(ref buffer; audioBuffers)
        // {
        //     buffer.unload();
        //     buffer = null;
        // }
        logln("Audio Died");
        Mix_CloseAudio();
        Mix_Quit();
    }
}
