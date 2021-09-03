module view.soundtestscene;
import data.hipfs;
import hipaudio.audio;
// import hipaudio.backend.openal.source;
import data.audio.audio;
import view.scene;
import util.tween;

class Test
{
    int x, y;
}

class SoundTestScene : Scene
{
    HipAudioSource src;
    Test t;
    HipTween timer;
    this()
    {
        import console.log;
        t = new Test();
        t.x = 0;
        t.y = 0;
        timer = new HipTweenSequence(false, 
        new HipTweenSpawn(false, 
            HipTween.by!(["x"])(0.2, t, 300), 
            HipTween.by!(["y"])(8, t, 900),
        ),
        HipTween.to!(["x"])(15, t, 0)
        );

        timer.play();

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
        import console.log;
        timer.tick(0.01);
        rawlog("X: ", t.x, " Y: ", t.y);
        // if(!HipAudio.isMusicPlaying(src))
            // HipAudio.resume(src);
        import systems.input;
        import hipaudio.backend.opensles;

        HipInput.InputEvent* ev;
        while((ev = HipInput.poll(0)) != null)
        {
            switch(ev.type)
            {
                case HipInput.InputType.TOUCH_DOWN:

                    logln("Resuming audiosurce");
                    
                    // HipAudio.resume(src);
                // case HipInput.InputType.TOUCH_UP:
                // case HipInput.InputType.TOUCH_MOVE:
                // case HipInput.InputType.TOUCH_SCROLL:
                    break;
                default:break;
            }
        }
        // ((cast(HipOpenSLESAudioSource)src).audioPlayer).update();
        if(src.getFreeBuffer() != null)
        {
            src.pullStreamData();
        }
    }

    override void render()
    {
    }
}