// D import file generated from 'source\hipaudio\backend\opensles\player.d'
module hipaudio.backend.opensles.player;
version (Android)
{
	import hipaudio.backend.opensles.source;
	import hipaudio.backend.opensles.clip;
	import hipaudio.backend.audiosource;
	import data.audio.audioconfig;
	import hipaudio.backend.sles;
	import config.opts : HIP_OPENSLES_OPTIMAL, HIP_OPENSLES_FAST_MIXER;
	import data.audio.audio;
	import std.conv : to;
	import opensles.sles;
	import error.handler;
	import hipaudio.audio;
	import bindbc.sdl;
	version (Android)
	{
		private SLDataFormat_PCM getFormatAsOpenSLES(AudioConfig cfg);
		package __gshared SLIAudioPlayer*[] playerPool;
		package uint poolRingIndex = 0;
		enum MAX_SLI_AUDIO_PLAYERS = 32;
		enum MAX_SLI_BUFFERS = 16;
		package SLIAudioPlayer* hipGenAudioPlayer();
		package SLIAudioPlayer* hipGetPlayerFromPool();
		class HipOpenSLESAudioPlayer : IHipAudioPlayer
		{
			AudioConfig cfg;
			SLIOutputMix output;
			SLEngineItf itf;
			static bool hasProAudio;
			static bool hasLowLatencyAudio;
			static int optimalBufferSize;
			static int optimalSampleRate;
			this(AudioConfig cfg, bool hasProAudio, bool hasLowLatencyAudio, int optimalBufferSize, int optimalSampleRate)
			{
				this.cfg = cfg;
				import math.utils : getClosestMultiple;
				optimalBufferSize = getClosestMultiple(optimalBufferSize, AudioConfig.defaultBufferSize);
				HipOpenSLESAudioPlayer.hasProAudio = hasProAudio;
				HipOpenSLESAudioPlayer.hasLowLatencyAudio = hasLowLatencyAudio;
				HipOpenSLESAudioPlayer.optimalBufferSize = optimalBufferSize;
				HipOpenSLESAudioPlayer.optimalSampleRate = optimalSampleRate;
				static if (HIP_OPENSLES_OPTIMAL)
				{
					cfg.sampleRate = optimalSampleRate;
				}

				HipSDL_SoundDecoder.initDecoder(cfg, optimalBufferSize);
				ErrorHandler.assertErrorMessage(sliCreateOutputContext(hasProAudio, hasLowLatencyAudio, optimalBufferSize, optimalSampleRate, HIP_OPENSLES_FAST_MIXER), "Error creating OpenSLES context.", sliGetErrorMessages());
			}
			public bool isMusicPlaying(HipAudioSource src);
			public bool isMusicPaused(HipAudioSource src);
			public bool resume(HipAudioSource src);
			public bool play(HipAudioSource src);
			public bool stop(HipAudioSource src);
			public bool pause(HipAudioSource src);
			public bool play_streamed(HipAudioSource src);
			public HipAudioClip load(string path, HipAudioType type);
			public HipAudioClip loadStreamed(string path, uint chunkSize);
			void updateStream(HipAudioSource source);
			public void updateStreamed(HipAudioSource source);
			public HipAudioSource getSource(bool isStreamed);
			public void setPitch(HipAudioSource src, float pitch);
			public void setPanning(HipAudioSource src, float panning);
			public void setVolume(HipAudioSource src, float volume);
			public void setMaxDistance(HipAudioSource src, float dist);
			public void setRolloffFactor(HipAudioSource src, float factor);
			public void setReferenceDistance(HipAudioSource src, float dist);
			public void onDestroy();
		}
	}
}
