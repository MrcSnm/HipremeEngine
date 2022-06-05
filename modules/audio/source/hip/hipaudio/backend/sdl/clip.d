module hip.hipaudio.backend.sdl.clip;

version(HipSDLMixer):
import hip.hipaudio.audioclip;
import hip.data.audio.audio;

class HipSDL_MixerAudioClip : HipAudioClip
{
    this(){super(new HipSDL_MixerDecoder());}
    alias load = HipAudioClip.load;
}