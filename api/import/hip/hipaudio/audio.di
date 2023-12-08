module hip.hipaudio.audio;
public import hip.api.audio.audioclip;
public import hip.api.audio.audiosource;
class HipAudio
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