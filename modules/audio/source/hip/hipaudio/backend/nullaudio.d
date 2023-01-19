/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hipaudio.backend.nullaudio;
import hip.hipaudio.audio;
import hip.hipaudio.audiosource;
import hip.audio_decoding.audio;


public class HipNullAudioClip : HipAudioClip
{
    this(IHipAudioDecoder decoder, HipAudioClipHint hint){super(null, hint);}
    public override bool load(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
    void delegate(in ubyte[]) onSuccess, void delegate() onFailure){return false;}

    public override void unload(){}
    public override void onUpdateStream(void[] data, uint decodedSize){}
    protected override  void  destroyBuffer(HipAudioBuffer* buffer){}
    protected override HipAudioBufferWrapper2 createBuffer(void[] data){return HipAudioBufferWrapper2(HipAudioBuffer.init, false);}
    public override void setBufferData(HipAudioBuffer* buffer, void[] data, uint size = 0){}
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
    public IHipAudioClip getClip(){return new HipNullAudioClip(null, HipAudioClipHint.init);}
    public IHipAudioClip load(string path, HipAudioType bufferType){return new HipNullAudioClip(null, HipAudioClipHint.init);}
    public IHipAudioClip loadStreamed(string path, uint chunkSize){return new HipNullAudioClip(null, HipAudioClipHint.init);}
    public void updateStream(AHipAudioSource source){}
    public AHipAudioSource getSource(bool isStreamed){return new HipAudioSource();}

    public void onDestroy(){}
    public void update(){}
}