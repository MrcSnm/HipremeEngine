// D import file generated from 'source\hip\util\time.d'
module hip.util.time;
import core.stdc.time;
version (Windows)
{
	import core.sys.windows.windef;
	extern (C) nothrow BOOL QueryPerformanceFrequency(LARGE_INTEGER* lpPerformanceCount);
	extern (C) nothrow BOOL QueryPerformanceCounter(LARGE_INTEGER* lpPerformanceCount);
}
else
{
	import core.stdc.config : c_long;
	struct timespec
	{
		int tv_sec;
		c_long tv_nsec;
	}
	extern (C) nothrow int clock_gettime(int clock_id, timespec* tm);
}
private nothrow size_t getSystemTime();
private nothrow size_t getSystemTicksPerSecond();
class HipTime
{
	private static size_t startTime;
	private static size_t ticksPerSecond;
	protected static long[string] performanceMeasurement;
	static this();
	static nothrow long getCurrentTime();
	static nothrow float getCurrentTimeAsMilliseconds();
	static nothrow float getCurrentTimeAsSeconds();
	static void initPerformanceMeasurement(string name);
	static void finishPerformanceMeasurement(string name);
	static struct Profiler
	{
		private string name;
		this(string name)
		{
			this.name = name;
			HipTime.initPerformanceMeasurement(name);
		}
		~this();
	}
	static template Profile(string name)
	{
		mixin("HipTime.Profiler _profile" ~ name ~ " = HipTime.Profiler(" ~ name ~ ");");
	}
	static template ProfileFunction()
	{
		mixin("HipTime.Profiler _profileFunc = HipTime.Profiler(__PRETTY_FUNCTION__);");
	}
}
