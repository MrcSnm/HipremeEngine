/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.view.soundtestscene;
import hip.filesystem.hipfs;
import hip.hipaudio.audio;
// import hip.hipaudio.backend.openal.source;
import hip.audio_decoding.audio;
import hip.view.scene;
import hip.tween;

class Test
{
    int x, y;
}

class SoundTestScene : Scene
{
    HipAudioSource src;
    Test t;
    IHipTimer timer;
    this()
    {
        import hip.console.log;
        t = new Test();
        t.x = 0;
        t.y = 0;
        timer = new HipSequence( 
            new HipSpawn( 
                HipTween.by!(["x"])(0.2, t, 300), 
                HipTween.by!(["y"])(8, t, 900),
            ),
            HipTween.to!(["x"])(15, t, 0)
        );


        timer.play();

        // HipAudioClip buf = HipAudio.load("audio/the-sound-of-silence.wav", HipAudioType.SFX);
        // src = HipAudio.getSource(false, buf);
        HipAudio.play(src);
        
        // HipAudioClip buf = HipAudio.loadStreamed("audio/StrategicZone.mp3", (ushort.max+1));
        // src = HipAudio.getSource(false, buf);
        // HipAudio.play_streamed(src);
        // src.pullStreamData();
        // src.pullStreamData();
        // HipAudio.play_streamed(src);


    }
    override void update(float dt)
    {
        // import hip.console.log;
        // timer.tick(0.01);
        // rawlog("X: ", t.x, " Y: ", t.y);
        // if(!HipAudio.isMusicPlaying(src))
            // HipAudio.resume(src);
        import hip.systems.input;
        import hip.hipaudio.backend.opensles;
        // ((cast(HipOpenSLESAudioSource)src).audioPlayer).update();
        // if(src.getFreeBuffer() != null)
        // {
        //     src.pullStreamData();
        // }
    }

    override void render()
    {
    }
}