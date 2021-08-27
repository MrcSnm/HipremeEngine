module hipaudio.backend.sdl.buffer;
import hipaudio.audiobuffer;
import data.audio.audio;

class HipSDL_MixerAudioBuffer : HipAudioBuffer
{
    this(){super(new HipSDL_MixerDecoder());}
    alias load = HipAudioBuffer.load;
}