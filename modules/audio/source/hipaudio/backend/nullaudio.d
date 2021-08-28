/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hipaudio.backend.nullaudio;
import hipaudio.audio;
import hipaudio.backend.audiosource;
import data.audio.audio;


public class HipNullAudioClip : HipAudioClip
{
    this(IHipAudioDecoder decoder){super(null);}
    public override bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false){return false;}
    public override void unload(){}
    public override void onUpdateStream(uint decodedSize, void* data){}
    protected override  void  destroyBuffer(void* buffer){}
    protected override HipAudioBufferWrapper createBuffer(uint size, void* data){return HipAudioBufferWrapper(null, 0, false);}
    public override void setBufferData(void* buffer, uint size, void* data){}
    
}

public class HipNullAudio : IHipAudioPlayer
{
    public bool isMusicPlaying(HipAudioSource src){return false;}
    public bool isMusicPaused(HipAudioSource src){return false;}
    public bool resume(HipAudioSource src){return false;}
    public bool play(HipAudioSource src){return false;}
    public bool stop(HipAudioSource src){return false;}
    public bool pause(HipAudioSource src){return false;}

    //LOAD RELATED
    public bool play_streamed(HipAudioSource src){return false;}
    public HipAudioClip load(string path, HipAudioType bufferType){return new HipNullAudioClip(null);}
    public HipAudioClip loadStreamed(string path, uint chunkSize){return new HipNullAudioClip(null);}
    public void updateStream(HipAudioSource source){}
    public HipAudioSource getSource(bool isStreamed){return new HipAudioSource();}

    //EFFECTS
    public void setPitch(HipAudioSource src, float pitch){}
    public void setPanning(HipAudioSource src, float panning){}
    public void setVolume(HipAudioSource src, float volume){}
    public void setMaxDistance(HipAudioSource src, float dist){}
    public void setRolloffFactor(HipAudioSource src, float factor){}
    public void setReferenceDistance(HipAudioSource src, float dist){}

    public void onDestroy(){}
}