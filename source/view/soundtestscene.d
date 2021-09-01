module view.soundtestscene;
import data.hipfs;
import hipaudio.audio;
// import hipaudio.backend.openal.source;
import data.audio.audio;
import view.scene;

class SoundTestScene : Scene
{
    HipAudioSource src;
    this()
    {
        import console.log;

        // HipAudioClip buf = HipAudio.load("audio/the-sound-of-silence.wav", HipAudioType.SFX);
        // src = HipAudio.getSource(false, buf);
        // HipAudio.play(src);
        
        HipAudioClip buf = HipAudio.loadStreamed("audio/StrategicZone.mp3", (ushort.max+1));
        src = HipAudio.getSource(true, buf);
        src.pullStreamData();
        src.pullStreamData();
        HipAudio.play_streamed(src);


    }
    override void update(float dt)
    {
        // if(!HipAudio.isMusicPlaying(src))
            // HipAudio.resume(src);
        import systems.input;
        import console.log;
        import hipaudio.backend.opensles;
        HipInput.InputEvent* ev;
        while((ev = HipInput.poll(0)) != null)
        {
            switch(ev.type)
            {
                case HipInput.InputType.TOUCH_DOWN:

                    logln("Resuming audiosurce");
                    
                    HipAudio.resume(src);
                // case HipInput.InputType.TOUCH_UP:
                // case HipInput.InputType.TOUCH_MOVE:
                // case HipInput.InputType.TOUCH_SCROLL:
                    break;
                default:break;
            }
        }
        ((cast(HipOpenSLESAudioSource)src).audioPlayer).update();       
        if(src.getFreeBuffer() != null)
        {
            src.pullStreamData();
        }
    }

    override void render()
    {
    }
}