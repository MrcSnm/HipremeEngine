/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.audio;

public import hip.audio.audiosource;
public import hip.api.audio : HipAudioType, DistanceModel, HipAudioImplementation, getAudioImplementationForOS, IHipAudioPlayer, setIHipAudioPlayer;
import hip.config.audio;

//Backends
import hip.audio_decoding.audio;
import hip.math.utils:getClosestMultiple;
import hip.error.handler;

static if(HipAudioBackgroundInit)
{
    import core.thread : Thread;
}

struct HipAudioResources
{
    HipAudioSource[] audioSources;
    IHipAudioClip[] audioClips;
}

class HipAudioImpl : IHipAudioPlayer
{
    HipAudioResources res;

    public bool initialize(HipAudioImplementation implementation = HipAudioImplementation.OpenAL,
    bool hasProAudio = false,
    bool hasLowLatencyAudio = false,
    int  optimalBufferSize = 4096,
    int optimalSampleRate = 44_100)
    {
        import hip.console.report;
        ErrorHandler.startListeningForErrors("HipremeAudio initialization");
        _hasInitializedAudio = true;
        this.is3D = is3D;
        this.implementation     = implementation;
        this.hasProAudio        = hasProAudio;
        this.hasLowLatencyAudio = hasLowLatencyAudio;
        this.optimalBufferSize  = optimalBufferSize;
        this.optimalSampleRate  = optimalSampleRate;

        reportRow("audio", "requested", implementation);
        reportRow("audio", "pro audio", hasProAudio);
        reportRow("audio", "low latency", hasLowLatencyAudio);
        reportRow("audio", "optimal buffer", optimalBufferSize);
        reportRow("audio", "optimal rate", optimalSampleRate);
        static if(HasXAudio2)
        {
            if(implementation == HipAudioImplementation.XAudio2)
            {
                AudioConfig cfg = AudioConfig.musicConfig;
                reportRow("audio", "backend", "XAudio2");
                reportRow("audio", "sample rate", cfg.sampleRate);
                reportRow("audio", "format", cfg.format);
                reportRow("audio", "channels", cfg.channels);
                reportRow("audio", "buffer", cfg.bufferSize);
            }
        }
        // Creating the device can take hundreds of ms (WASAPI endpoint wakeup),
        // so on Windows it runs in the background instead of blocking startup.
        bool startedInBackground = false;
        reportRow("audio", "device init", HipAudioBackgroundInit ? "background" : "eager");
        static if(HipAudioBackgroundInit)
        {
            static if(HasXAudio2)
            {
                if(implementation == HipAudioImplementation.XAudio2)
                {
                    startAudioInitThread();
                    startedInBackground = true;
                }
            }
        }
        if(!startedInBackground)
            createInterface(true);
        return ErrorHandler.stopListeningForErrors();
    }

    static if(HipAudioBackgroundInit)
    {
        private Thread audioInitThread;

        private void startAudioInitThread()
        {
            if(audioInitThread !is null)
                return;
            audioInitThread = new Thread(&backgroundAudioInit);
            audioInitThread.start();
        }

        private void backgroundAudioInit()
        {
            try createInterface(false);
            catch(Throwable e)
            {
                pendingInitError = (e.msg !is null ? e.msg : "unknown error").dup;
                pendingInitBackground = true;
                pendingInit = true;
                if(audioInterface is null)
                {
                    import hip.audio.backend.nullaudio : HipNullAudio;
                    audioInterface = new HipNullAudio();
                }
            }
        }
    }

    private void createInterface(bool reportTimings)
    {
        import hip.console.report : ReportTimer;
        ReportTimer timer = ReportTimer.start();
        audioInterface = getAudioInterface(implementation, hasProAudio, hasLowLatencyAudio,
            optimalBufferSize, optimalSampleRate, reportTimings);
        pendingInitMs = timer.lap();
        pendingInitBackground = !reportTimings;
        pendingInit = true;
    }

    private IHipAudioPlayer ensureInterface()
    {
        if(audioInterface is null)
        {
            static if(HipAudioBackgroundInit)
            {
                // The background thread is the only creator; just wait for it.
                if(audioInitThread !is null)
                {
                    try audioInitThread.join();
                    catch(Throwable) {}
                    return audioInterface;
                }
            }
            createInterface(true);
        }
        return audioInterface;
    }
    bool pause(AHipAudioSource src)
    {
        src.isPlaying = false;
        return false;
    }
    bool play_streamed(AHipAudioSource src)
    {
        ensureInterface().play_streamed(src);
        src.isPlaying = true;
        return false;
    }
    IHipAudioClip getClip()
    {
        IHipAudioClip clip = ensureInterface().getClip();
        res.audioClips~= clip;
        return clip;
    }

    /**
    *   Loads a file from disk, sets the chunkSize for streaming and does one decoding frame
    */
    IHipAudioClip loadStreamed(string path, uint chunkSize = ushort.max+1)
    {
        chunkSize = getClosestMultiple(optimalBufferSize, chunkSize);
        IHipAudioClip buf = ensureInterface().loadStreamed(path, chunkSize);
        return buf;
    }

    void updateStream(AHipAudioSource source)
    {
        ensureInterface().updateStream(source);
    }
    AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null)
    {
        if(isStreamed) ErrorHandler.assertExit(clip !is null, "Can't get streamed source without any buffer");
        HipAudioSource ret = cast(HipAudioSource)ensureInterface().getSource(isStreamed);
        if(clip)
            ret.clip = clip;

        res.audioSources ~= ret;
        return ret;
    }
    void onDestroy()
    {
        foreach(clip; res.audioClips)
            clip.unload();
        foreach(source; res.audioSources)
            source.dispose();
        res.audioSources.length = res.audioClips.length = 0;
        
        static if(HipAudioBackgroundInit)
        {
            if(audioInitThread !is null)
            {
                // join() waits for the device creation to finish and closes the
                // OS thread handle. destroy() releases the Thread object now
                // instead of leaving it to the GC during runtime teardown.
                try audioInitThread.join();
                catch(Throwable) {}
                destroy(audioInitThread);
                audioInitThread = null;
            }
        }
        if(audioInterface !is null)
            audioInterface.onDestroy();
        audioInterface = null;
    }

    void update()
    {
        // Keep the startup report first: only print the audio init result after
        // it has been flushed (or at the first-frame flush, see HipremeRender).
        import hip.console.report : reportWasFlushed;
        if(pendingInit && reportWasFlushed())
            printPendingInit();
        if(audioInterface !is null)
            audioInterface.update();
    }

    ///If the device finished before the report, include it in the table.
    void reportPendingInitIfReady()
    {
        if(!pendingInit || pendingInitError !is null || pendingInitMs < 0)
            return;
        pendingInit = false;
        import hip.console.report : reportRow;
        reportRow("timings", "audio", pendingInitMs, " ms");
        pendingInitMs = -1;
    }

    ///Prints the deferred init result after the startup report.
    void printPendingInit()
    {
        if(!pendingInit)
            return;
        pendingInit = false;
        import hip.util.string : BigString;
        import hip.console.log : rawlog;
        string suffix = pendingInitBackground ? " (background)" : "";
        if(pendingInitError !is null)
            rawlog(BigString("HIP: Audio device initialization failed: ", pendingInitError).toString);
        else if(pendingInitMs >= 0)
            rawlog(BigString("HIP: Audio device initialized in ", pendingInitMs, " ms", suffix).toString);
        else
            rawlog(BigString("HIP: Audio device initialized", suffix).toString);
        pendingInitMs = -1;
        pendingInitError = null;
    }

    private static IHipAudioPlayer getAudioInterface(HipAudioImplementation impl,
    bool hasProAudio = false,
    bool hasLowLatencyAudio = false,
    int  optimalBufferSize = 4096,
    int optimalSampleRate = 44_100,
    bool reportTimings = true)
    {
        import hip.console.log;
        final switch(impl)
        {
            case HipAudioImplementation.WebAudio:
            {
                static if(HasWebAudio)
                {
                    import hip.audio.backend.webaudio.player;
                    return new HipWebAudioPlayer(AudioConfig.musicConfig);
                }
                else
                {
                    loglnWarn("Tried to use WebAudio implementation, but not in WebAssembly. No audio available");
                    goto case HipAudioImplementation.Null;
                }
            }
            case HipAudioImplementation.OpenSLES:
                static if(HasOpenSLES)
                {
                    import hip.audio.backend.opensles.player;
                    return new HipOpenSLESAudioPlayer(AudioConfig.androidConfig,
                    hasProAudio,
                    hasLowLatencyAudio,
                    optimalBufferSize,
                    optimalSampleRate);
                    break;
                }
            case HipAudioImplementation.XAudio2:
                static if(HasXAudio2)
                {
                    import hip.audio.backend.xaudio.player;
                    return new HipXAudioPlayer(AudioConfig.musicConfig, reportTimings);
                }
                else 
                {
                    loglnWarn("Tried to use XAudio2 implementation, but no XAudio2 version was provided. OpenAL will be used instead");
                    goto case HipAudioImplementation.OpenAL;
                }
            case HipAudioImplementation.AVAudioEngine:
            {
                static if(HasAVAudioEngine)
                {
                    import hip.audio.backend.avaudio.player;
                    return new HipAVAudioPlayer(AudioConfig.androidConfig);
                }
                else
                {
                    loglnWarn("Tried to use AVAudioEngine implementation, but no AVAudioEngine found. OpenAL will be used instead");
                    goto case HipAudioImplementation.OpenAL;
                }
            }
            case HipAudioImplementation.OpenAL:
            {
                static if(HasOpenAL)
                {
                    import hip.audio.backend.openal.player;
                    //Please note that OpenAL HRTF(spatial sound) only works with Mono Channel
                    return new HipOpenALAudioPlayer(AudioConfig.musicConfig);
                }
                else
                {
                    loglnWarn("Tried to use OpenAL implementation, but no OpenAL version was provided. No audio available.");
                    goto case HipAudioImplementation.Null;
                }
            }
            case HipAudioImplementation.Null:
            {
                import hip.audio.backend.nullaudio;
                loglnWarn("No AudioInterface was found. Using NullAudio");
                return new HipNullAudio();
            }
        }
    }


   
    protected HipAudioImplementation implementation;
    ///Deferred "audio initialized" message, printed after the startup report.
    private long pendingInitMs = -1;
    private string pendingInitError;
    private bool pendingInit;
    private bool pendingInitBackground;
    protected bool hasProAudio;
    protected bool hasLowLatencyAudio;
    protected int  optimalBufferSize;
    protected int  optimalSampleRate;
    private   bool is3D;
    private   uint activeSources;

    IHipAudioPlayer audioInterface;

    //Debug vars
    private bool _hasInitializedAudio = false;
    public bool hasInitializedAudio() => _hasInitializedAudio;
}


private __gshared HipAudioImpl player;
void PreInitializeHipAudio()
{
    player = new HipAudioImpl();
    setIHipAudioPlayer(player);
}
export extern(C) IHipAudioPlayer HipAudioPlayerAPI()
{
    return player;
}
HipAudioImpl HipAudio(){return player;}