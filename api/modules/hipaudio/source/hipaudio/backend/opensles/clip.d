
module hipaudio.backend.opensles.clip;
version (Android)
{
	import hipaudio.backend.sles;
	import hipaudio.audioclip;
	import data.audio.audio;
	class HipOpenSLESAudioClip : HipAudioClip
	{
		this(IHipAudioDecoder decoder)
		{
			super(decoder);
		}
		this(IHipAudioDecoder decoder, uint chunkSize)
		{
			super(decoder, chunkSize);
		}
		public override uint loadStreamed(in void[] data, HipAudioEncoding encoding);
		override void onUpdateStream(void* data, uint decodedSize);
		override HipAudioBufferWrapper createBuffer(void* data, uint size);
		override void destroyBuffer(void* buffer);
		override void setBufferData(void* buffer, uint size, void* data);
		bool hasBuffer;
	}
}
