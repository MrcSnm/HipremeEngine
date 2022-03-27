// D import file generated from 'source\data\audio\audio.d'
module data.audio.audio;
import data.audio.audioconfig;
import sdl_sound;
public import hipengine.api.data.audio;
private char* getNameFromEncoding(HipAudioEncoding encoding);
version (HipSDLMixer)
{
	class HipSDL_MixerDecoder : IHipAudioDecoder
	{
		protected static AudioConfig cfg;
		public static bool initDecoder(AudioConfig cfg);
		uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding);
		uint updateDecoding(void* outputDecodedData);
		bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type);
		public AudioConfig getAudioConfig();
		Mix_Chunk* getChunk();
		Mix_Music* getMusic();
		float getDuration();
		void* getClipData();
		ulong getClipSize();
		void dispose();
		union
		{
			Mix_Chunk* chunk;
			Mix_Music* music;
		}
		HipAudioType type;
	}
}
class HipSDL_SoundDecoder : IHipAudioDecoder
{
	Sound_Sample* sample;
	HipAudioEncoding selectedEncoding;
	uint chunkSize;
	float duration;
	protected static int bufferSize;
	protected static AudioConfig cfg;
	public static bool initDecoder(AudioConfig cfg, int bufferSize);
	bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type);
	uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding);
	uint updateDecoding(void* outputDecodedData);
	float getDuration();
	AudioConfig getAudioConfig();
	void* getClipData();
	ulong getClipSize();
	void dispose();
}
T* monoToStereo(T)(T* data, ulong framesLength)
{
	import core.stdc.stdlib;
	T* ret = cast(T*)malloc(framesLength * 2 * T.sizeof);
	for (ulong i = 0;
	 i < framesLength; i++)
	{
		{
			ret[i * 2] = data[i];
			ret[i * 2 + 1] = data[i];
		}
	}
	return ret;
}
T[] monoToStereo(T)(T[] data)
{
	T[] ret = new T[data.length * 2];
	for (ulong i = 0;
	 i < data.length; i++)
	{
		{
			ret[i * 2] = data[i];
			ret[i * 2 + 1] = data[i];
		}
	}
	return ret;
}
private struct _AudioStreamImpl
{
	void* block;
	void initialize();
	void openFromMemory(in ubyte[] inputData);
	long getLengthInFrames();
	int getNumChannels();
	float getSamplerate();
	int readSamplesFloat(float[] outputBuffer);
	void cleanUp();
}
class HipAudioFormatsDecoder : IHipAudioDecoder
{
	_AudioStreamImpl input;
	float sampleRate;
	int channels;
	float duration;
	ulong clipSize;
	uint chunkSize;
	float[] buffer;
	float[] decodedBuffer;
	bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type);
	uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding);
	uint updateDecoding(void* outputDecodedData);
	AudioConfig getAudioConfig();
	void* getClipData();
	ulong getClipSize();
	float getDuration();
	void dispose();
}
