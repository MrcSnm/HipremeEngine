module implementations.audio.backend.sdl.buffer;
import implementations.audio.audiobase;
import audio.audio;

class HipSDL_MixerAudioBuffer : HipAudioBuffer
{
    this(){super(new HipSDL_MixerDecoder());}
}