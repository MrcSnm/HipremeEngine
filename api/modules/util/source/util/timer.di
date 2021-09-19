// D import file generated from 'source\util\timer.d'
module util.timer;
class HipTimer
{
	enum TimerType 
	{
		oneShot,
		progressive,
	}
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
		this.setProperties(name, durationSeconds, type, loops);
	}
	void setProperties(string name, float durationSeconds, TimerType type, bool loops = false);
	float getDuration();
	float getProgress();
	void addHandler(void delegate(float progress, uint loopCount) handler);
	void forceFinish();
	void pause();
	HipTimer play();
	void stop();
	void reset();
	void loopRestart();
	bool tick(float dt);
}
