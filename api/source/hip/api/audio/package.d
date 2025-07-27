module hip.api.audio;
public import hip.api.audio.audiosource;
public import hip.api.audio.audioclip;

//Low weight shared data
enum HipAudioType : ubyte
{
    SFX,
    MUSIC
}

/**
* Controls how the gain will falloff
*/
enum DistanceModel
{
    DISTANCE_MODEL,
    /**
    * Very similar to the exponential curve
    */
    INVERSE,
    INVERSE_CLAMPED,
    /**
    * Linear curve, the only which can achieve 0 volume
    */
    LINEAR,
    LINEAR_CLAMPED,

    /**
    * Exponential curve for the model
    */
    EXPONENT,
    /**
    * When the distance is below the reference, it will clamp the volume to 1
    * When the distance is higher than max distance, it will not decrease volume any longer
    */
    EXPONENT_CLAMPED
}

enum HipAudioImplementation : ubyte
{
    Null,
    OpenAL,
    OpenSLES,
    XAudio2,
    WebAudio,
    AVAudioEngine
}

HipAudioImplementation getAudioImplementationForOS()
{
    with(HipAudioImplementation)
    {
        version(NullAudio) return Null;
        else version(Android) return OpenSLES;
        else version(Windows) return XAudio2;
        else version(WebAssembly) return WebAudio;
        else version(iOS) return AVAudioEngine;
        else return OpenAL;
    }
}

/**
 * This is an interface that should be created only once inside the application.
 *  Every audio function is global, meaning that every AudioSource will refer to the player
 */
public interface IHipAudioPlayer
{
    //LOAD RELATED
    public bool play_streamed(AHipAudioSource src);
    public IHipAudioClip getClip();
    public IHipAudioClip loadStreamed(string path, uint chunkSize);
    public void updateStream(AHipAudioSource source);
    public AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null);

    public void onDestroy();
    public void update();
}

private __gshared IHipAudioPlayer audioPlayer;
void setIHipAudioPlayer(IHipAudioPlayer player)
{
    audioPlayer = player;
}

IHipAudioPlayer HipAudio()
{
    return audioPlayer;
}