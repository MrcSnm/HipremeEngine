module hip.hipaudio.backend.openal.player;
version(OpenAL):
import hip.hipaudio.backend.openal.clip;
import hip.hipaudio.backend.openal.source;
import hip.hipaudio.backend.openal.al_err;
import hip.hipaudio.audio;
import hip.error.handler;
import hip.audio_decoding.audio;
import hip.math.vector;
import bindbc.openal;


package ALenum getFormatAsOpenAL(AudioConfig cfg)
{
    if(cfg.channels == 1)
    {
        if(cfg.format == AudioFormat.float32Big || cfg.format == AudioFormat.float32Little)
            return AL_FORMAT_MONO_FLOAT32;
        else if(cfg.format == AudioFormat.signed16Little || cfg.format == AudioFormat.signed16Big)
            return AL_FORMAT_MONO16;
        else
            return AL_FORMAT_MONO8;
    }
    else
    {
        if(cfg.format == AudioFormat.float32Big || cfg.format == AudioFormat.float32Little)
            return AL_FORMAT_STEREO_FLOAT32;
        else if(cfg.format == AudioFormat.signed16Little || cfg.format == AudioFormat.signed16Big)
            return AL_FORMAT_STEREO16;
        else
            return AL_FORMAT_STEREO8;
    }
}



/**
* Wraps OpenAL API onto the IAudioPlayer interface. With that, when HipAudioSourceAPI receives that interface,
* it will update OpenAL properties through that interface.
*/
public class HipOpenALAudioPlayer : IHipAudioPlayer
{
    public this(AudioConfig cfg)
    {
        initializeOpenAL();
        config = cfg;
    }
    public static bool initializeOpenAL()
    {
        ErrorHandler.startListeningForErrors("HipremeAudio3D initialization");
        ALSupport sup = loadOpenAL();
        if(sup != ALSupport.al11) //Probably should not load a non al11 version.
        {
            if(sup == ALSupport.badLibrary)
                ErrorHandler.showErrorMessage("Bad OpenAL Support", "Unknown version of OpenAL");
            else
            {
                ErrorHandler.showErrorMessage("OpenAL not found", "Could not find OpenAL library");
                return false;
            }
        }
        device = alcOpenDevice(alcGetString(null, ALC_DEVICE_SPECIFIER));
        if(device == null)
        {
            ErrorHandler.showErrorMessage("OpenAL Initialization", "Error on creating device");
            return false;
        }
        //static const ALCint* contextAttr = [ALC_FREQUENCY, 22_050, 0];
        context = alcCreateContext(device, null);
        if(context == null)
        {
            ErrorHandler.showErrorMessage("OpenAL context error", "Error creating OpenAL context");
            return false;
        }
        if(!alcMakeContextCurrent(context))
		    ErrorHandler.showErrorMessage("OpenAL context error", "Error setting context");

        //Set Listener

        alListener3f(AL_POSITION, 0f, 0f, 0f);
        alListener3f(AL_VELOCITY, 0f, 0f, 0f);

        if(!alEffecti)
            ErrorHandler.showErrorMessage("OpenAL EFX Error", "Could not load OpenAL EFX");

        return ErrorHandler.stopListeningForErrors();
    }
    public AHipAudioSource getSource(bool isStreamed = false){return  new HipOpenALAudioSource(isStreamed);}

    public bool play_streamed(AHipAudioSource src)
    {
        HipOpenALAudioSource source = cast(HipOpenALAudioSource)src;
        HipOpenALClip _buf = cast(HipOpenALClip)source.clip;
        if(_buf.hasBuffer)
        {
            alSourcePlay(source.id);
            alCheckError("Error querying OpenAL play streamed");
            return true;
        }
        return false;
    }
    
    public HipAudioClipAPI getClip(){return new HipOpenALClip(new HipAudioDecoder(), getClipHint());}
    
    public HipAudioClipAPI loadStreamed(string path, uint chunkSize)
    {
        HipAudioClipAPI clip = new HipOpenALClip(new HipAudioDecoder(), getClipHint(), chunkSize);
        // clip.loadStreamed(path, getEncodingFromName(path));
        return clip;
    }

    public void updateStream(AHipAudioSource source)
    {
        // HipOpenALAudioSource src = cast(HipOpenALAudioSource)source;
        // HipOpenALClip clip = cast(HipOpenALClip)src.buffer;
        // ALuint b = clip.getALBuffer();
        // alSourceQueueBuffers(src.id, 1, &b);
        // alCheckError("Error enqueueing OpenAL buffer on source"));
    }


    //End Effects
    public void onDestroy()
    {
        alcDestroyContext(context);
        alcCloseDevice(device);
        context = null;
        device = null;               
    }

    public void update()
    {
        
    }

    /**
    *   OpenAL has an embedded resampler
    */
    protected static HipAudioClipHint getClipHint()
    {
        HipAudioClipHint hint = {
            outputChannels: HipOpenALAudioPlayer.config.channels,
            outputSamplerate: HipOpenALAudioPlayer.config.sampleRate,
            needsResample: false,
            needsDecode: true
        };
        return hint;
    }

    package static AudioConfig config;
    protected static ALCdevice* device;
    protected static ALCcontext* context;

    /**
    * Constant used for making the panning distance offset from the listener
    */
    public static ALfloat PANNING_CONSTANT = 1000;
}