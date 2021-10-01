/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipaudio.backend.nullaudio;
import hipaudio.audio;
import hipaudio.audiosource;
import data.audio.audio;


public class HipNullAudioClip : HipAudioClip
{
    this(IHipAudioDecoder decoder){super(null);}
    public override bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false){return false;}
    public override void unload(){}
    public override void onUpdateStream(void* data, uint decodedSize){}
    protected override  void  destroyBuffer(void* buffer){}
    protected override HipAudioBufferWrapper createBuffer(void* data, uint size){return HipAudioBufferWrapper(null, 0, false);}
    public override void setBufferData(void* buffer, uint size, void* data){}
    
}

public class HipNullAudio : IHipAudioPlayer
{
    public bool isMusicPlaying(AHipAudioSource src){return false;}
    public bool isMusicPaused(AHipAudioSource src){return false;}
    public bool resume(AHipAudioSource src){return false;}
    public bool play(AHipAudioSource src){return false;}
    public bool stop(AHipAudioSource src){return false;}
    public bool pause(AHipAudioSource src){return false;}

    //LOAD RELATED
    public bool play_streamed(AHipAudioSource src){return false;}
    public HipAudioClip load(string path, HipAudioType bufferType){return new HipNullAudioClip(null);}
    public HipAudioClip loadStreamed(string path, uint chunkSize){return new HipNullAudioClip(null);}
    public void updateStream(AHipAudioSource source){}
    public AHipAudioSource getSource(bool isStreamed){return new HipAudioSource();}

    //EFFECTS
    public void setPitch(AHipAudioSource src, float pitch){}
    public void setPanning(AHipAudioSource src, float panning){}
    public void setVolume(AHipAudioSource src, float volume){}
    public void setMaxDistance(AHipAudioSource src, float dist){}
    public void setRolloffFactor(AHipAudioSource src, float factor){}
    public void setReferenceDistance(AHipAudioSource src, float dist){}

    public void onDestroy(){}
}