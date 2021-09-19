// D import file generated from 'source\hipaudio\backend\openal\player.d'
module hipaudio.backend.openal.player;
import hipaudio.backend.openal.clip;
import data.audio.audioconfig;
import hipaudio.backend.openal.source;
import hipaudio.audio;
import data.audio.audioconfig;
import data.audio.audio;
import bindbc.openal;
import math.vector;

package string alGetErrorString(ALenum err);
package ALenum getFormatAsOpenAL(AudioConfig cfg);
package string alCheckError(string title = "", string message = "")()
{
	import std.format : format;
	static if (message != "")
	{
		message = "\x0a" ~ message;
	}

	return format!"version(HIPREME_DEBUG)\x0d\x0a    {\x0d\x0a        static if(!is(typeof(alCheckError_err)))\x0d\x0a            ALenum alCheckError_err = alGetError();\x0d\x0a        else\x0d\x0a            alCheckError_err = alGetError();\x0d\x0a        if(alCheckError_err != AL_NO_ERROR)\x0d\x0a            ErrorHandler.showErrorMessage(\"OpenAL Error: %s\", alGetErrorString(alCheckError_err)~\"%s\");\x0d\x0a    }"(title, message);
}

ALenum getALDistanceModel(DistanceModel model);
public class HipOpenALAudioPlayer : IHipAudioPlayer
{
	public this(AudioConfig cfg)
	{
		HipSDL_SoundDecoder.initDecoder(cfg, AudioConfig.defaultBufferSize);
		initializeOpenAL();
		config = cfg;
	}
	public static bool initializeOpenAL();
	public HipAudioSource getSource(bool isStreamed = false);
	public bool isMusicPlaying(HipAudioSource src);
	public bool isMusicPaused(HipAudioSource src);
	public bool resume(HipAudioSource src);
	public bool play(HipAudioSource src);
	public bool stop(HipAudioSource src);
	public bool pause(HipAudioSource src);
	public bool play_streamed(HipAudioSource src);
	public HipAudioClip load(string path, HipAudioType clipType);
	public HipAudioClip loadStreamed(string path, uint chunkSize);
	public void updateStream(HipAudioSource source);
	public void setDistanceModel(DistanceModel model);
	public void setMaxDistance(HipAudioSource src, float dist);
	public void setRolloffFactor(HipAudioSource src, float factor);
	public void setReferenceDistance(HipAudioSource src, float dist);
	public void setVolume(HipAudioSource src, float volume);
	public void setPanning(HipAudioSource src, float panning);
	public void setPitch(HipAudioSource src, float pitch);
	public void setPosition(HipAudioSource src, ref Vector3 pos);
	public void setVelocity(HipAudioSource src, ref Vector3 vel);
	public void setDoppler(HipAudioSource src, ref Vector3 vel);
	public void onDestroy();
	package static AudioConfig config;
	protected static ALCdevice* device;
	protected static ALCcontext* context;
	public static ALfloat PANNING_CONSTANT = 1000;
}
