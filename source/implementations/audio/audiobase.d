/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.audiobase;
import std.path : baseName;
import data.hipfs;
import audio.audio;
import implementations.audio.backend.audiosource;

/** 
 * Wraps a decoder onto it. Basically an easier interface with some more controls
 *  that would be needed inside specific APIs.
 */
public abstract class HipAudioBuffer
{
    IHipAudioDecoder decoder;
    this(IHipAudioDecoder decoder){this.decoder = decoder;}
    /**
    *   Should implement the specific loading here
    */
    public bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        bufferType = audioType;
        this.isStreamed = isStreamed;
        return decoder.startDecoding(data, encoding, type, isStreamed);
    }
    public void* getBuffer(){return decoder.getBuffer();}
    public ulong getBufferSize(){return decoder.getBufferSize();}
    ///Probably isStreamed does not makes any sense when reading entire file
    public final bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        void[] data;
        fullPath = audioPath;
        fileName = baseName(audioPath);
        HipFS.read(audioPath, data);
        return load(data, encoding, type, isStreamed);
    }
    public void unload(){decoder.dispose();}

    HipAudioType type;
    bool isStreamed;
    string fullPath;
    string fileName;

}

/** 
 * This is an interface that should re
 */
public interface IHipAudioPlayer
{
    //COMMON TASK
    public bool isMusicPlaying(AudioSource src);
    public bool isMusicPaused(AudioSource src);
    public bool resume(AudioSource src);
    public bool play(AudioSource src);
    public bool stop(AudioSource src);
    public bool pause(AudioSource src);

    //LOAD RELATED
    public bool play_streamed(AudioSource src);
    public HipAudioBuffer load(string path, HipAudioType type);
    public AudioSource getSource();
    public final HipAudioBuffer loadMusic(string mus){return load(mus, HipAudioType.MUSIC);}
    public final HipAudioBuffer loadSfx(string sfx){return load(sfx, HipAudioType.SFX);}

    //EFFECTS
    public void setPitch(AudioSource src, float pitch);
    public void setPanning(AudioSource src, float panning);
    public void setVolume(AudioSource src, float volume);
    public void setMaxDistance(AudioSource src, float dist);
    public void setRolloffFactor(AudioSource src, float factor);
    public void setReferenceDistance(AudioSource src, float dist);

    public void onDestroy();
/*    final public bool clearMusic()
    {
        foreach(ref music; musics)
        {
            if(!unloadMusic(music))
                return false;
            music = null;
        }
        return true;
    }
    final public bool clearSfx()
    {
        foreach(ref sfx; soundEffects)
        {
            if(!unloadSfx(sfx))
                return false;
            sfx = null;
        }
        return true;
    }*/
    /*final public void _destroy()
    {
        onDestroy();
        clearSfx();
        clearMusic();
    }*/
}


