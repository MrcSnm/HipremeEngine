
module hipaudio.backend.sles;
import error.handler;
import console.log;
import std.conv : to;
import std.format : format;
import core.atomic;
import std.algorithm : count;
import opensles.sles;
version (Android)
{
	import opensles.android;
}
version (Android)
{
	package __gshared SLresult[] sliErrorQueue;
	package __gshared string[] sliErrorMessages;
	struct SLIEngine
	{
		SLObjectItf engineObject = null;
		SLEngineItf engine;
		SLEngineCapabilitiesItf engineCapabilities;
		bool willUseFastMixer;
		void initialize();
		uint CreateOutputMix(const(SLObjectItf_*)** outputMix, uint interfacesCount, const(SLInterfaceID_*)* interfaces, const(uint)* requirements);
		uint CreateAudioPlayer(SLObjectItf* audioPlayer, SLDataSource* source, SLDataSink* sink, uint interfacesCount, SLInterfaceID* interfaces, uint* requirements);
		void Destroy();
	}
	package __gshared SLIEngine engine;
	package __gshared short engineMajor = 1;
	package __gshared short engineMinor = 0;
	package __gshared short enginePatch = 1;
	package __gshared SLIOutputMix outputMix;
	package __gshared SLIAudioPlayer*[] genPlayers;
	string sliGetError(SLresult res);
	package void sliClearErrors();
	bool sliError(SLresult res, lazy string errMessage, string file = __FILE__, string func = __PRETTY_FUNCTION__, uint line = __LINE__);
	private bool sliCall(SLresult opRes, string errMessage, string file = __FILE__, string func = __PRETTY_FUNCTION__, uint line = __LINE__);
	struct SLIOutputMix
	{
		SLEnvironmentalReverbItf environmentReverb;
		SLPresetReverbItf presetReverb;
		SLBassBoostItf bassBoost;
		SLEqualizerItf equalizer;
		SLVirtualizerItf virtualizer;
		SLObjectItf outputMixObj;
		static bool initializeForAndroid(ref SLIOutputMix output, ref SLIEngine e, bool willUseFastMixer);
	}
	float sliToAttenuation(float gain);
	SLInterfaceID[] getAudioPlayerInterfaces(bool willUseFastMixer);
	SLboolean[] getAudioPlayerRequirements(ref SLInterfaceID[] itfs);
	string sliGetErrorMessages();
	struct SLIBuffer
	{
		uint size;
		bool isLocked;
		bool hasBeenProcessed;
		void[0] data;
	}
	SLIBuffer* sliGenBuffer(void* data, uint size);
	void sliBufferData(SLIBuffer* buffer, void* data);
	void sliDestroyBuffer(ref SLIBuffer* buff);
	__gshared struct SLIAudioPlayer
	{
		SLObjectItf playerObj;
		SLPlayItf player;
		SLVolumeItf playerVol;
		SLSeekItf playerSeek;
		SLBassBoostItf bassBoost;
		SLEnvironmentalReverbItf envReverb;
		SLEqualizerItf equalizer;
		SLPlaybackRateItf playbackRate;
		SLPresetReverbItf presetReverb;
		SLVirtualizerItf virtualizer;
		SLAndroidEffectItf androidEffect;
		SLAndroidEffectSendItf androidEffectSend;
		SLEffectSendItf playerEffectSend;
		SLMetadataExtractionItf playerMetadata;
		protected SLIBuffer** streamQueue;
		protected ushort streamQueueLength;
		protected ushort streamQueueFree;
		protected ushort streamQueueCapacity;
		protected ushort totalChunksEnqueued;
		protected ushort totalChunksPlayed;
		version (Android)
		{
			SLAndroidSimpleBufferQueueItf playerAndroidSimpleBufferQueue;
		}
		else
		{
			SL3DSourceItf source3D;
			SL3DDopplerItf doppler3D;
			SL3DLocationItf location3D;
		}
		SLIBuffer* nextBuffer;
		bool isPlaying;
		bool hasFinishedTrack;
		float volume;
		void update();
		static void setVolume(ref SLIAudioPlayer audioPlayer, float gain);
		static void destroyAudioPlayer(ref SLIAudioPlayer audioPlayer);
		extern (C) alias PlayerCallback = void function(SLPlayItf player, void* context, SLuint32 event);
		void RegisterCallback(PlayerCallback callback, void* context);
		void SetCallbackEventsMask(uint mask);
		extern (C) static void checkStreamCallback(SLPlayItf player, void* context, SLuint32 event);
		void pushBuffer(SLIBuffer* buffer);
		SLIBuffer* getProcessedBuffer();
		void removeFreeBuffer(SLIBuffer* freeBuffer);
		int GetState();
		static void Enqueue(ref SLIAudioPlayer audioPlayer, void* samples, uint sampleSize);
		static void Clear(ref SLIAudioPlayer audioPlayer);
		void unqueue(SLIBuffer* processedBuffer);
		static void resume(ref SLIAudioPlayer audioPlayer);
		static void play(ref SLIAudioPlayer audioPlayer);
		static void stop(ref SLIAudioPlayer audioPlayer);
		static void pause(ref SLIAudioPlayer audioPlayer);
	}
	SLIAudioPlayer* sliGenAudioPlayer(SLDataSource src, SLDataSink dest, bool autoRegisterCallback = true);
	void sliDestroyContext();
	version (Android)
	{
		alias SLIDataLocator_Address = SLDataLocator_AndroidSimpleBufferQueue;
	}
	else
	{
		alias SLIDataLocator_Address = SLDataLocator_Address;
	}
	bool sliCreateOutputContext(bool hasProAudio = false, bool hasLowLatencyAudio = false, int optimalBufferSize = 44100, int optimalSampleRate = 4096, bool willUseFastMixer = false);
}
