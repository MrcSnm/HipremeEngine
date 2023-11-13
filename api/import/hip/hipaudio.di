module hip.hipaudio;
public import hip.api.audio.audiosource;
public import hip.api.audio.audioclip;

extern class HipAudio
{
    static
    {
        bool pause(AHipAudioSource src);
        bool play_streamed(AHipAudioSource src);
        IHipAudioClip loadStreamed(string path, uint chunkSize = ushort.max+1) ;
        void updateStream(AHipAudioSource source);
        IHipAudioClip getClip();
        AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null);
    }
}

extern public abstract class HipAudioClip : IHipAudioClip{}