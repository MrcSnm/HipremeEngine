
module hipaudio.backend.opensles.source;
version (Android)
{
	import error.handler;
	import bindbc.sdl;
	import hipaudio.audioclip;
	import hipaudio.backend.sles;
	import util.time;
	import hipaudio.backend.audiosource;
	version (Android)
	{
		class HipOpenSLESAudioSource : HipAudioSource
		{
			SLIAudioPlayer* audioPlayer;
			bool isStreamed;
			this(SLIAudioPlayer* player, bool isStreamed)
			{
				audioPlayer = player;
				this.isStreamed = isStreamed;
			}
			override void setClip(HipAudioClip clip);
			override void pullStreamData();
			SLIBuffer* getSLIFreeBuffer();
			override HipAudioBufferWrapper* getFreeBuffer();
		}
	}
}
