
module graphics.g2d.animation;
import graphics.g2d.textureatlas;
import graphics.color;
import math.vector;
import hiprenderer.texture : TextureRegion;

struct HipAnimationFrame
{
	import util.data_structures : Array2D;
	TextureRegion region;
	HipColor color = HipColor(1, 1, 1, 1);
	Vector2 offset = Vector2(0, 0);
	static HipAnimationFrame[] fromTextureRegions(Array2D!TextureRegion reg, uint startY, uint startX, uint endY, uint endX);
}

interface IHipAnimationTrack
{
	HipAnimationTrack addFrames(HipAnimationFrame[] frame...);
	void reset();
	void setFrame(uint frame);
	void setLooping(bool looping);
	void setReverse(bool reverse);
	void setFramesPerSecond(uint fps);
	HipAnimationFrame* update(float dt);
}

abstract class AHipAnimationTrack : IHipAnimationTrack
{
	immutable string name;
	protected HipAnimationFrame[] frames;
	protected float accumulator = 0;
	protected uint framesPerSecond = 0;
	protected uint currentFrame = 0;
	private uint lastFrame = 0;
	protected bool isPlaying = false;
	protected bool isLooping = false;
	protected bool isReverse = false;
	this(string name, uint framesPerSecond, bool shouldLoop)
	{
		this.name = name;
		setFramesPerSecond(framesPerSecond);
		isLooping = shouldLoop;
	}
	
}

interface IHipAnimation
{
	HipAnimation addTrack(HipAnimationTrack track);
	HipAnimationTrack getCurrentTrack();
	string getCurrentTrackName();
	HipAnimationFrame* getCurrentFrame();
	void setTimeScale(float scale);
	void setTrack(string trackName);
	void update(float dt);
}

abstract class AHipAnimation : IHipAnimation
{
	protected HipAnimationTrack[string] tracks;
	immutable string name;
	protected float timeScale;
	protected HipAnimationTrack currentTrack;
	protected HipAnimationFrame* currentFrame;
	this(string name)
	{
		this.name = name;
		this.timeScale = 1.0F;
	}
	static HipAnimation fromAtlas(TextureAtlas atlas, string which, uint fps, bool shouldLoop = false);
}
