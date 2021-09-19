// D import file generated from 'source\view\soundtestscene.d'
module view.soundtestscene;
import data.hipfs;
import hipaudio.audio;
import data.audio.audio;
import view.scene;
import util.tween;
class Test
{
	int x;
	int y;
}
class SoundTestScene : Scene
{
	HipAudioSource src;
	Test t;
	HipTween timer;
	this()
	{
		import console.log;
		t = new Test;
		t.x = 0;
		t.y = 0;
		timer = new HipTweenSequence(false, new HipTweenSpawn(false, HipTween.by!(["x"])(0.2, t, 300), HipTween.by!(["y"])(8, t, 900)), HipTween.to!(["x"])(15, t, 0));
		timer.play();
		HipAudioClip buf = HipAudio.loadStreamed("audio/StrategicZone.mp3", (ushort).max + 1);
		src = HipAudio.getSource(true, buf);
		src.pullStreamData();
		src.pullStreamData();
		HipAudio.play_streamed(src);
	}
	override void update(float dt);
	override void render();
}
