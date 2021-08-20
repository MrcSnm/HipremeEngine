/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.backend.nullaudio;
import implementations.audio.audiobase;
import implementations.audio.backend.audiosource;


public class NullBuffer : AudioBuffer
{
    public override bool load(string audioPath, TYPE audioType, bool isStreamed = false){return false;}
    public override void unload(){}
}

public class NullAudio : IAudio
{
    public bool isMusicPlaying(AudioSource src){return false;}
    public bool isMusicPaused(AudioSource src){return false;}
    public bool resume(AudioSource src){return false;}
    public bool play(AudioSource src){return false;}
    public bool stop(AudioSource src){return false;}
    public bool pause(AudioSource src){return false;}

    //LOAD RELATED
    public bool play_streamed(AudioSource src){return false;}
    public AudioBuffer load(string path, AudioBuffer.TYPE bufferType){return new NullBuffer();}
    public AudioSource getSource(){return new AudioSource();}

    //EFFECTS
    public void setPitch(AudioSource src, float pitch){}
    public void setPanning(AudioSource src, float panning){}
    public void setVolume(AudioSource src, float volume){}
    public void setMaxDistance(AudioSource src, float dist){}
    public void setRolloffFactor(AudioSource src, float factor){}
    public void setReferenceDistance(AudioSource src, float dist){}

    public void onDestroy(){}
}