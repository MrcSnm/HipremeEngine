module hip.hipaudio.config;

version(Android) enum HasOpenSLES = true;
else enum HasOpenSLES = false;

version(XAudio2) enum HasXAudio2 = true;
else enum HasXAudio2 = false;

version(OpenAL) enum HasOpenAL = true;
else enum HasOpenAL = false;

version(WebAssembly) enum HasWebAudio = true;
else enum HasWebAudio = false;

version(iOS) enum HasAVAudioEngine = true;
else enum HasAVAudioEngine = false;