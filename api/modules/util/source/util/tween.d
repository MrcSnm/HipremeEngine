
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

interface IHipTween
{
	HipTween setEasing(HipEasing easing);
	void setProperties(string name, float durationSeconds, bool loops = false);
}

abstract class HipTween : AHipTimer, IHipTween
{
	import util.memory;
	HipEasing easing = null;
	void* savedData = null;
	uint savedDataSize = 0;
	protected void delegate() onPlay;
	this(float durationSeconds, bool loops)
	{
		super("Tween", durationSeconds, TimerType.progressive, loops);
		this.easing = null;
	}
}

template to(string[] Props, T, V)
{
	HipTween function(float durationSeconds, T target, V[] values...) to;
}
template by(string[] Props, T, V)
{
	HipTween function (float durationSeconds, T target, V[] values...) by;
}
HipTween function (bool loops, HipTween[] tweens...) HipTweenSequence;
HipTween function (bool loops, HipTween[] tweens...) HipTweenSpawn;