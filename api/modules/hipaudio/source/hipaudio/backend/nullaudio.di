// D import file generated from 'source\hipaudio\backend\nullaudio.d'
module hipaudio.backend.nullaudio;
import hipaudio.audio;
import hipaudio.backend.audiosource;
import data.audio.audio;
public class HipNullAudioClip : HipAudioClip
{
	this(IHipAudioDecoder decoder)
	{
		super(null);
	}
	public override bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
	public override void unload();
	public override void onUpdateStream(void* data, uint decodedSize);
	protected override void destroyBuffer(void* buffer);
	protected override HipAudioBufferWrapper createBuffer(void* data, uint size);
	public override void setBufferData(void* buffer, uint size, void* data);
}
public class HipNullAudio : IHipAudioPlayer
{
	public bool isMusicPlaying(HipAudioSource src);
	public bool isMusicPaused(HipAudioSource src);
	public bool resume(HipAudioSource src);
	public bool play(HipAudioSource src);
	public bool stop(HipAudioSource src);
	public bool pause(HipAudioSource src);
	public bool play_streamed(HipAudioSource src);
	public HipAudioClip load(string path, HipAudioType bufferType);
	public HipAudioClip loadStreamed(string path, uint chunkSize);
	public void updateStream(HipAudioSource source);
	public HipAudioSource getSource(bool isStreamed);
	public void setPitch(HipAudioSource src, float pitch);
	public void setPanning(HipAudioSource src, float panning);
	public void setVolume(HipAudioSource src, float volume);
	public void setMaxDistance(HipAudioSource src, float dist);
	public void setRolloffFactor(HipAudioSource src, float factor);
	public void setReferenceDistance(HipAudioSource src, float dist);
	public void onDestroy();
}
