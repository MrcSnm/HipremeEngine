
module data.audio.audioconfig;
struct AudioConfig
{
	int sampleRate;
	ushort format;
	int channels;
	int bufferSize;
	public static immutable uint defaultBufferSize = 4096;
	static AudioConfig musicConfig();
	static AudioConfig lightweightConfig();
	uint getBitDepth();
}
