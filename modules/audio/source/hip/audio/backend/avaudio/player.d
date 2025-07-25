module hip.audio.backend.avaudio.player;

version(iOS):
public import hip.audio.backend.avaudio.clip;
public import hip.audio.backend.avaudio.source;
public import hip.audio_decoding.audio;
import avaudioengine;
import avaudiomixernode;
import avaudioplayernode;
import hip.audio;
import hip.error.handler;

class HipAVAudioPlayer : IHipAudioPlayer
{
    AVAudioEngine engine;
    AVAudioPlayerNode playerNode;
    AVAudioMixerNode mixerNode;

    private static AudioConfig config;
    package static AudioConfig getAudioConfig(){return config;}

    /**
    *   For getting better debug information, you need to run this application on Visual Studio.
    *   The debug messages actually appears inside the `Output` window.
    */
    public this(AudioConfig cfg)
    {
        HipAVAudioPlayer.config = cfg;
        engine = AVAudioEngine.alloc.init;
        mixerNode = AVAudioMixerNode.alloc.init;
        playerNode = AVAudioPlayerNode.alloc.init;

        engine.attachNode(mixerNode);
        engine.attachNode(playerNode);
        AVAudioFormat format = fromConfig(cfg);
        engine.connect(cast(AVAudioNode)playerNode, cast(AVAudioNode)engine.outputNode, format);

        engine.prepare();
        NSError err;
        if(!engine.start(&err))
            ErrorHandler.assertExit(false, "Could not initialize AVAudioEngine: "~err.toString);
    }

    public static AVAudioFormat fromConfig(immutable AudioConfig cfg)
    {
        import hip.util.conv;
        AVAudioCommonFormat format;
        switch(cfg.format)
        {
            case AudioFormat.signed16Big:
            case AudioFormat.signed16Little:
                format = AVAudioCommonFormat.PCMFormatInt16;
                break;
            case AudioFormat.signed32Big:
            case AudioFormat.signed32Little:
                format = AVAudioCommonFormat.PCMFormatInt32;
                break;
            case AudioFormat.float32Big:
            case AudioFormat.float32Little:
                format = AVAudioCommonFormat.PCMFormatFloat32;
                break;
            default:
                ErrorHandler.assertExit(false, "AVAudioEngine Does not support the current bit depth");
                break;
        }
        AVAudioFormat fmt = AVAudioFormat.alloc.initWithCommonFormat(format, cfg.sampleRate, cfg.channels, interleaved: cfg.channels == 2 ? true : false);
        ErrorHandler.assertLazyExit(fmt !is null, "Could not create audio format with config " ~ cfg.to!string);
        return fmt;
    }

    public bool play_streamed(AHipAudioSource src){return src.play_streamed();}

    public AHipAudioSource getSource(bool isStreamed = false, IHipAudioClip clip = null){return new HipAVAudioSource(this);}
    public IHipAudioClip getClip(){return new HipAVAudioClip(new HipAudioDecoder(), HipAudioClipHint(config.channels, config.sampleRate, false, true));}

    public IHipAudioClip loadStreamed(string audioName, uint chunkSize)
    {
        ErrorHandler.assertExit(false, "AVAudioPlayer Player does not support chunked decoding");
        return null;
    }
    public void updateStream(AHipAudioSource source){}

    public void onDestroy()
    {
    }
    public void update(){}
}
