// D import file generated from 'source\hipaudio\audio.d'
module hipaudio.audio;
public import hipaudio.audioclip;
public import hipaudio.backend.audiosource;
public import data.audio.audioconfig;
import hipaudio.backend.openal.player;
import hipaudio.backend.sdl.player;
version (Android)
{
	import hipaudio.backend.opensles.player;
}
import data.audio.audio;
import math.utils : getClosestMultiple;
import error.handler;
enum DistanceModel 
{
	DISTANCE_MODEL,
	INVERSE,
	INVERSE_CLAMPED,
	LINEAR,
	LINEAR_CLAMPED,
	EXPONENT,
	EXPONENT_CLAMPED,
}
enum HipAudioImplementation 
{
	OPENAL,
	SDL,
	OPENSLES,
}
public interface IHipAudioPlayer
{
	public bool isMusicPlaying(HipAudioSource src);
	public bool isMusicPaused(HipAudioSource src);
	public bool resume(HipAudioSource src);
	public bool play(HipAudioSource src);
	public bool stop(HipAudioSource src);
	public bool pause(HipAudioSource src);
	public bool play_streamed(HipAudioSource src);
	public HipAudioClip load(string path, HipAudioType type);
	public HipAudioClip loadStreamed(string path, uint chunkSize);
	public void updateStream(HipAudioSource source);
	public HipAudioSource getSource(bool isStreamed);
	public final HipAudioClip loadMusic(string mus);
	public final HipAudioClip loadSfx(string sfx);
	public void setPitch(HipAudioSource src, float pitch);
	public void setPanning(HipAudioSource src, float panning);
	public void setVolume(HipAudioSource src, float volume);
	public void setMaxDistance(HipAudioSource src, float dist);
	public void setRolloffFactor(HipAudioSource src, float factor);
	public void setReferenceDistance(HipAudioSource src, float dist);
	public void onDestroy();
}
class HipAudio
{
	public static bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OPENAL, bool hasProAudio = false, bool hasLowLatencyAudio = false, int optimalBufferSize = 4096, int optimalSampleRate = 44100);
	static bool play(HipAudioSource src);
	static bool pause(HipAudioSource src);
	static bool play_streamed(HipAudioSource src);
	static bool resume(HipAudioSource src);
	static bool stop(HipAudioSource src);
	static HipAudioClip load(string path, HipAudioType bufferType, bool forceLoad = false);
	static HipAudioClip loadStreamed(string path, uint chunkSize = (ushort).max + 1);
	static void updateStream(HipAudioSource source);
	static HipAudioSource getSource(bool isStreamed = false, HipAudioClip clip = null);
	static bool isMusicPlaying(HipAudioSource src);
	static bool isMusicPaused(HipAudioSource src);
	static void onDestroy();
	static void setPitch(HipAudioSource src, float pitch);
	static void setPanning(HipAudioSource src, float panning);
	static void setVolume(HipAudioSource src, float volume);
	public static void setReferenceDistance(HipAudioSource src, float dist);
	public static void setRolloffFactor(HipAudioSource src, float factor);
	public static void setMaxDistance(HipAudioSource src, float dist);
	public static AudioConfig getConfig();
	public static void update(HipAudioSource src);
	protected static AudioConfig config;
	protected static bool hasProAudio;
	protected static bool hasLowLatencyAudio;
	protected static int optimalBufferSize;
	protected static int optimalSampleRate;
	private static bool is3D;
	private static HipAudioClip[string] bufferPool;
	private static HipAudioSource[] sourcePool;
	private static uint activeSources;
	static IHipAudioPlayer audioInterface;
	version (HIPREME_DEBUG)
	{
		public static bool hasInitializedAudio = false;
	}
}
