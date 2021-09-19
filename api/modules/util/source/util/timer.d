module util.timer;
enum TimerType 
{
	oneShot,
	progressive,
}

interface IHipTimer
{
	void setProperties(string name, float durationSeconds, TimerType type, bool loops = false);
	float getDuration();
	float getProgress();
	void addHandler(void delegate(float progress, uint loopCount) handler);
	void forceFinish();
	void pause();
	IHipTimer play();
	void stop();
	void reset();
	void loopRestart();
	bool tick(float dt);
}
abstract class AHipTimer : IHipTimer
{
	string name;
	protected uint loopCount = 0;
	protected bool loops = false;
	protected float deltaTime = 0;
	protected float accumulator = 0;
	protected float durationSeconds = 0;
	protected bool isRunning = false;
	protected void delegate(float progress, uint loopCount)[] handlers;
	protected TimerType type;
	this(string name, float durationSeconds, TimerType type, bool loops = false)
	{
		setProperties(name, durationSeconds, type, loops);
	}
}
