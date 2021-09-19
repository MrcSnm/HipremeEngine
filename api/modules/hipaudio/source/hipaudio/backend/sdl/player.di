// D import file generated from 'source\hipaudio\backend\sdl\player.d'
module hipaudio.backend.sdl.player;
import hipaudio.backend.sdl.clip;
import hipaudio.backend.audiosource;
import hipaudio.audio;
import error.handler;
import console.log;
import data.audio.audio;
import data.audio.audioconfig;
class HipSDLAudioPlayer : IHipAudioPlayer
{
	public this(AudioConfig cfg);
	public bool isMusicPlaying(HipAudioSource src);
	public bool isMusicPaused(HipAudioSource src);
	public bool resume(HipAudioSource src);
	public bool stop(HipAudioSource src);
	public bool pause(HipAudioSource src);
	public bool play_streamed(HipAudioSource src);
	public HipAudioClip load(string audioName, HipAudioType bufferType);
	public HipAudioClip loadStreamed(string audioName, uint chunkSize);
	public void updateStream(HipAudioSource source);
	public HipAudioSource getSource(bool isStreamed);
	bool play(HipAudioSource src);
	void setPitch(HipAudioSource src, float pitch);
	void setPanning(HipAudioSource src, float panning);
	void setVolume(HipAudioSource src, float volume);
	public void setMaxDistance(HipAudioSource src, float dist);
	public void setRolloffFactor(HipAudioSource src, float factor);
	public void setReferenceDistance(HipAudioSource src, float dist);
	public void onDestroy();
}
