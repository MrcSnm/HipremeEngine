// D import file generated from 'source\hipaudio\backend\openal\clip.d'
module hipaudio.backend.openal.clip;
import data.audio.audio;
import hipaudio.audio;
import hipaudio.backend.audiosource;
import data.audio.audioconfig;
import hipaudio.backend.openal.player;
import bindbc.openal;
public class HipOpenALClip : HipAudioClip
{
	this(IHipAudioDecoder decoder)
	{
		super(decoder);
	}
	this(IHipAudioDecoder decoder, uint chunkSize)
	{
		super(decoder, chunkSize);
	}
	void loadALBuffer(uint bufferId, void* data, uint dataSize);
	public override uint loadStreamed(in void[] data, HipAudioEncoding encoding);
	override void onUpdateStream(void* data, uint decodedSize);
	override HipAudioBufferWrapper createBuffer(void* data, uint bufferSize);
	override void destroyBuffer(void* buffer);
	override void setBufferData(void* buffer, uint size, void* data);
	ALuint getALBuffer(void* data, uint size);
	bool hasBuffer;
	alias load = HipAudioClip.load;
}
