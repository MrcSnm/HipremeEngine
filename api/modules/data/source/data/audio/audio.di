// D import file generated from 'source\data\audio\audio.d'
module data.audio.audio;
import data.audio.audioconfig;
import sdl_sound;

enum HipAudioEncoding 
{
	WAV,
	MP3,
	OGG,
	MIDI,
	FLAC,
}
enum HipAudioType 
{
	SFX,
	MUSIC,
}
HipAudioEncoding getEncodingFromName(string name);
private char* getNameFromEncoding(HipAudioEncoding encoding);
interface IHipAudioDecoder
{
	bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type);
	uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding);
	uint updateDecoding(void* outputDecodedData);
	AudioConfig getAudioConfig();
	void* getClipData();
	ulong getClipSize();
	float getDuration();
	void dispose();
}
class HipSDL_MixerDecoder : IHipAudioDecoder
{
	protected static AudioConfig cfg;
	public static bool initDecoder(AudioConfig cfg);
	uint startDecoding(in void[] data, void* outputDecodedData, uint chunkSize, HipAudioEncoding encoding);
	uint updateDecoding(void* outputDecodedData);
	bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type);
	public AudioConfig getAudioConfig();
	void* getChunk();
	void* getMusic();
	float getDuration();
	void* getClipData();
	ulong getClipSize();
	void dispose();
	union
	{
		void* chunk;
		void* music;
	}
	HipAudioType type;
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
