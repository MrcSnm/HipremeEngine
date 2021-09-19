// D import file generated from 'source\hipaudio\backend\sdl\clip.d'
module hipaudio.backend.sdl.clip;
import hipaudio.audioclip;
import data.audio.audio;
class HipSDL_MixerAudioClip : HipAudioClip
{
	this()
	{
		super(new HipSDL_MixerDecoder);
	}
	alias load = HipAudioClip.load;
}
