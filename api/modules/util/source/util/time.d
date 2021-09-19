
module util.time;

struct Profiler
{
	private string name;
	this(string name)
	{
		this.name = name;
		initPerformanceMeasurement(name);
	}
}
template Profile(string name)
{
	mixin("Profiler _profile" ~ name ~ " = Profiler(" ~ name ~ ");");
}
template ProfileFunction()
{
	mixin("Profiler _profileFunc = Profiler(__PRETTY_FUNCTION__);");
}

long function() getCurrentTime;
float function() getCurrentTimeAsMilliseconds;
float function() getCurrentTimeAsSeconds;
void function(string name) initPerformanceMeasurement;
void function(string name) finishPerformanceMeasurement;