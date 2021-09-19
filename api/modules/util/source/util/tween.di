// D import file generated from 'source\util\tween.d'
module util.tween;
import std.math : cos, sin, PI, pow, sqrt;
import util.timer;
private enum c1 = 1.70158F;
private enum c2 = c1 * 1.525;
private enum c3 = c1 + 1;
private enum c4 = 2.0F * PI / 3.0F;
private enum c5 = 2 * PI / 4.5F;
private enum n1 = 7.5625F;
private enum d1 = 2.75F;
enum HipEasing : float function(float x)
{
	identity = null,
	easeInSine = (x) => 1 - cos(x * PI / 2),
	easeOutSine = (x) => sin(x * PI / 2),
	easeInOutSine = (x) => -(cos(PI * x) - 1) / 2,
	easeInQuad = (x) => x * x,
	easeOutQuad = (x) => 1 - (1 - x) * (1 - x),
	easeInOutQuad = (x) => x < 0.5F ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2,
	easeInCubic = (x) => x * x * x,
	easeOutCubic = (x) => 1 - pow(1 - x, 3),
	easeInOutCubic = (x) => x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2,
	easeInQuart = (x) => x * x * x * x,
	easeOutQuart = (x) => 1 - pow(1 - x, 4),
	easeInOutQuart = (x) => x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2,
	easeInQuint = (x) => x * x * x * x * x,
	easeOutQuint = (x) => 1 - pow(1 - x, 5),
	easeInOutQuint = (x) => x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2,
	easeInExpo = (x) => x == 0 ? 0 : pow(2, 10 * x - 10),
	easeOutExpo = (x) => x == 1 ? 1 : 1 - pow(2, -10 * x),
	easeInOutExpo = (x) => x == 0 ? 0 : x == 1 ? 1 : x < 0.5 ? pow(2, 20 * x - 10) / 2 : (2 - pow(2, -20 * x + 10)) / 2,
	easeInCirc = (x) => 1 - sqrt(1 - pow(x, 2)),
	easeOutCirc = (x) => sqrt(1 - pow(x - 1, 2)),
	easeInOutCirc = (x) => x < 0.5 ? (1 - sqrt(1 - pow(2 * x, 2))) / 2 : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2,
	easeInBack = (x) => c3 * x * x * x - c1 * x * x,
	easeOutBack = (x) => 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2),
	easeInOutBack = (x) => x < 0.5 ? pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2) / 2 : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2,
	easeInElastic = (x) => x == 0 ? 0 : x == 1 ? 1 : -pow(2, 10 * x - 10) * sin((x * 10 - 10.75F) * c4),
	easeOutElastic = (x) => x == 0 ? 0 : x == 1 ? 1 : pow(2, -10 * x) * sin((x * 10 - 0.75F) * c4) + 1,
	easeInOutElastic = (x) => x == 0 ? 0 : x == 1 ? 1 : x < 0.5 ? -(pow(2, 20 * x - 10) * sin((20 * x - 11.125F) * c5)) / 2 : pow(2, -20 * x + 10) * sin((20 * x - 11.125F) * c5) / 2 + 1,
	easeInBounce = (x) => 1 - HipEasing.easeOutBounce(1 - x),
	easeOutBounce = function float(float x)
	{
		if (x < 1.0F / d1)
			return n1 * x * x;
		else if (x < 2.0F / d1)
			return n1 * (x -= 1.5F / d1) * x + 0.75;
		else if (x < 2.5F / d1)
			return n1 * (x -= 2.25F / d1) * x + 0.9375F;
		else
			return n1 * (x -= 2.625F / d1) * x + 0.984375F;
	}
	,
	easeInOutBounce = (x) => x < 0.5 ? (1 - easeOutBounce(1 - 2 * x)) / 2 : (1 + easeOutBounce(2 * x - 1)) / 2,
}
class HipTween : HipTimer
{
	import util.memory;
	HipEasing easing = null;
	void* savedData = null;
	uint savedDataSize = 0;
	protected void delegate() onPlay;
	this(float durationSeconds, bool loops)
	{
		super("Tween", durationSeconds, HipTimer.TimerType.progressive, loops);
		this.easing = null;
	}
	HipTween setEasing(HipEasing easing);
	void setProperties(string name, float durationSeconds, bool loops = false);
	override HipTween play();
	protected void allocSaveData(uint size);
	static HipTween to(string[] Props, T, V)(float durationSeconds, T target, V[] values...)
	{
		HipTween t = new HipTween(durationSeconds, false);
		t.allocSaveData(Props.length * V.sizeof);
		V[] v2 = values.dup;
		t.onPlay = ()
		{
			static foreach (i, p; Props)
			{
				mixin("memcpy(t.savedData+", V.sizeof * i, ", &target.", p, ", ", V.sizeof, ");");
			}
			t.addHandler((float prog, uint loops)
			{
				float multiplier = prog;
				if (t.easing != null)
					multiplier = t.easing(multiplier);
				V initialValue;
				V newValue;
				static foreach (i, p; Props)
				{
					initialValue = *cast(V*)(t.savedData + i * V.sizeof);
					newValue = cast(V)((1 - multiplier) * initialValue + v2[i] * multiplier);
					mixin("target.", p, " = newValue;");
				}
			}
			);
		}
		;
		return t;
	}
	static HipTween by(string[] Props, T, V)(float durationSeconds, T target, V[] values...)
	{
		HipTween t = new HipTween(durationSeconds, false);
		t.allocSaveData(Props.length * V.sizeof);
		memset(t.savedData, 0, t.savedDataSize);
		V[] v2 = values.dup;
		t.onPlay = ()
		{
			t.addHandler((float prog, uint loops)
			{
				float multiplier = prog;
				if (t.easing != null)
					multiplier = t.easing(multiplier);
				V temp;
				V temp2;
				static foreach (i, p; Props)
				{
					temp = *(cast(V*)t.savedData + i);
					temp2 = cast(V)(v2[i] * multiplier);
					mixin("target.", p, "+= -temp + temp2;");
					memcpy(t.savedData + i * V.sizeof, &temp2, V.sizeof);
				}
			}
			);
		}
		;
		return t;
	}
	~this();
}
class HipTweenSequence : HipTween
{
	HipTween[] tweenList;
	uint listCursor;
	float cursorDuration = 0;
	float listAccumulator = 0;
	this(bool loops, HipTween[] tweens...)
	{
		super(0, loops);
		foreach (t; tweens)
		{
			tweenList ~= t;
			durationSeconds += t.getDuration();
		}
		cursorDuration = tweenList[0].getDuration();
		setProperties("TweenSequence", durationSeconds, loops);
		onPlay = ()
		{
			tweenList[0].play();
		}
		;
		addHandler((prog, count)
		{
			if (accumulator - listAccumulator >= cursorDuration)
			{
				if (listCursor + 1 < tweenList.length)
				{
					tweenList[listCursor].tick(deltaTime);
					cursorDuration = tweenList[++listCursor].getDuration();
					tweenList[listCursor].play();
					listAccumulator += cursorDuration;
				}
			}
			tweenList[listCursor].tick(deltaTime);
		}
		);
	}
}
class HipTweenSpawn : HipTween
{
	HipTween[] tweenList;
	this(bool loops, HipTween[] tweens...)
	{
		super(0, loops);
		foreach (t; tweens)
		{
			tweenList ~= t;
			if (t.getDuration() > durationSeconds)
				durationSeconds = t.getDuration();
		}
		onPlay = ()
		{
			foreach (t; tweenList)
			{
				t.play();
			}
		}
		;
		setProperties("TweenSpawn", durationSeconds, loops);
		addHandler((prog, count)
		{
			foreach (t; tweenList)
			{
				t.tick(deltaTime);
			}
		}
		);
	}
}
