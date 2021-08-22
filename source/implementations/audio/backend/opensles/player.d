module implementations.audio.backend.opensles.player;
import implementations.audio.backend.audiosource;
import implementations.audio.backend.audioconfig;
import implementations.audio.audiobase;
import implementations.audio.backend.sles;
import audio.audio;
import opensles.sles;
import error.handler;
import implementations.audio.audio;

version(Android):


package __gshared SLIAudioPlayer*[] playerPool;
package uint poolRingIndex = 0;
enum MAX_SLI_AUDIO_PLAYERS = 32;


package SLIAudioPlayer* hipGenAudioPlayer()
{
    SLDataFormat_PCM fmt = HipAudio.getConfig().getFormatAsOpenSLES();
    version(Android)
    {
        import opensles.android;
        SLDataLocator_AndroidSimpleBufferQueue locator;
        locator.locatorType = SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE;
        locator.numBuffers = 1;
    }
    else
    {
        SLDataLocator_Address locator;
        locator.locatorType = SL_DATALOCATOR_ADDRESS;
        // locator.pAddress = bufferPtr;
        // locator.length = bufferLength;
    }
    SLDataSource src;
    src.pLocator = &locator;
    src.pFormat = &fmt;

    //Okay
    SLDataLocator_OutputMix locatorMix;
    locatorMix.locatorType = SL_DATALOCATOR_OUTPUTMIX;
    locatorMix.outputMix = outputMix.outputMixObj;

    SLDataSink destination;
    destination.pLocator = &locatorMix;
    destination.pFormat = null;

    return sliGenAudioPlayer(src, destination);
}

package SLIAudioPlayer* hipGetPlayerFromPool()
{
    foreach(p; playerPool)
    {
        if(!p.isPlaying)
            return p;
    }
    if(playerPool.length == MAX_SLI_AUDIO_PLAYERS)
    {
        SLIAudioPlayer* temp = playerPool[poolRingIndex];
        SLIAudioPlayer.stop(*temp);
        poolRingIndex = (poolRingIndex+1)%MAX_SLI_AUDIO_PLAYERS;
        return temp;
    }
    return hipGenAudioPlayer();
}

class HipOpenSLESAudioPlayer : IHipAudioPlayer
{
    AudioConfig cfg;
    SLIOutputMix output;
    SLEngineItf itf;
    this(AudioConfig cfg)
    {
        this.cfg = cfg;
        HipSDL_SoundDecoder.initDecoder();
        ErrorHandler.assertErrorMessage(sliCreateOutputContext(),
        "Error creating OpenSLES context.", sliGetErrorMessages());
    }
    public bool isMusicPlaying(HipAudioSource src){return false;}
    public bool isMusicPaused(HipAudioSource src){return false;}
    public bool resume(HipAudioSource src){return false;}
    public bool play(HipAudioSource src)
    {
        SLIAudioPlayer* p = hipGetPlayerFromPool();
        SLIAudioPlayer.play(*p,
            src.buffer.getBuffer(),
            cast(uint)src.buffer.getBufferSize()
        );

        return true;
    }
    public bool stop(HipAudioSource src){return false;}
    public bool pause(HipAudioSource src){return false;}

    //LOAD RELATED
    public bool play_streamed(HipAudioSource src){return false;}
    public HipAudioBuffer load(string path, HipAudioType type)
    {
        HipAudioBuffer buffer = new HipAudioBuffer(new HipSDL_SoundDecoder());
        buffer.load(path, getEncodingFromName(path), type);
        return buffer;
    }
    public HipAudioSource getSource(){return new HipAudioSource();}

    //EFFECTS
    public void setPitch(HipAudioSource src, float pitch){}
    public void setPanning(HipAudioSource src, float panning){}
    public void setVolume(HipAudioSource src, float volume){}
    public void setMaxDistance(HipAudioSource src, float dist){}
    public void setRolloffFactor(HipAudioSource src, float factor){}
    public void setReferenceDistance(HipAudioSource src, float dist){}

    public void onDestroy(){sliDestroyContext();}
}