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
public class HipAudioBuffer
{
    IHipAudioDecoder decoder;
    this(IHipAudioDecoder decoder){this.decoder = decoder;}
    /**
    *   Should implement the specific loading here
    */
    public bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        this.type = type;
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
 * This is an interface that should be created only once inside the application.
 *  Every audio function is global, meaning that every AudioSource will refer to the player
 */
public interface IHipAudioPlayer
{
    //COMMON TASK
    public bool isMusicPlaying(HipAudioSource src);
    public bool isMusicPaused(HipAudioSource src);
    public bool resume(HipAudioSource src);
    public bool play(HipAudioSource src);
    public bool stop(HipAudioSource src);
    public bool pause(HipAudioSource src);

    //LOAD RELATED
    public bool play_streamed(HipAudioSource src);
    public HipAudioBuffer load(string path, HipAudioType type);
    public HipAudioSource getSource();
    public final HipAudioBuffer loadMusic(string mus){return load(mus, HipAudioType.MUSIC);}
    public final HipAudioBuffer loadSfx(string sfx){return load(sfx, HipAudioType.SFX);}

    //EFFECTS
    public void setPitch(HipAudioSource src, float pitch);
    public void setPanning(HipAudioSource src, float panning);
    public void setVolume(HipAudioSource src, float volume);
    public void setMaxDistance(HipAudioSource src, float dist);
    public void setRolloffFactor(HipAudioSource src, float factor);
    public void setReferenceDistance(HipAudioSource src, float dist);

    public void onDestroy();
}


