/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.time;
import core.stdc.time;

version(Windows)
{
    import core.sys.windows.windef;
    extern(C) BOOL QueryPerformanceFrequency(LARGE_INTEGER* lpPerformanceCount) nothrow;
    extern(C) BOOL QueryPerformanceCounter(LARGE_INTEGER* lpPerformanceCount) nothrow;
}
else
{
    import core.stdc.config:c_long;
    struct timespec
    {
        int tv_sec; //Seconds
        c_long tv_nsec; //Nanoseconds
    }
    extern(C) int clock_gettime(int clock_id, timespec* tm) nothrow;
}

private size_t getSystemTime() nothrow
{
    version(Windows)
    {
        LARGE_INTEGER counter = void;
        QueryPerformanceCounter(&counter);
        return counter.QuadPart * 1000;
    }
    else
    {
        timespec tm;
        if(clock_gettime(0, &tm))
            return 0;
        return tm.tv_nsec;
    }
}
private size_t getSystemTicksPerSecond() nothrow
{
    version(Windows)
    {
        LARGE_INTEGER ticksPerSecond = void;
        QueryPerformanceFrequency(&ticksPerSecond);
        return ticksPerSecond.QuadPart;
    }
    else
    {
        return 0;
    }
}

class HipTime
{

    private static size_t startTime;
    private static size_t ticksPerSecond;
    protected static long[string] performanceMeasurement;

    static this()
    {
        ticksPerSecond = getSystemTicksPerSecond();
        startTime =  getSystemTime();
    }

    static long getCurrentTime() nothrow
    {
        size_t time = 0;
        version(Windows)
        {
            time = ((getSystemTime() - startTime)* 1_000_000) / ticksPerSecond;
        }
        else
            time = getSystemTime() - startTime;
        return time;
    }

    static float getCurrentTimeAsMilliseconds() nothrow
    {
        return getCurrentTime() / 1_000_000;
    }
    static float getCurrentTimeAsSeconds() nothrow
    {
        return getCurrentTime() / 1_000_000_000;
    }

    static void initPerformanceMeasurement(string name)
    {
        performanceMeasurement[name] = getCurrentTime();
    }
    static void finishPerformanceMeasurement(string name)
    {
        // import std.stdio:writeln;
        // writeln(name, " took ", (getCurrentTime() - performanceMeasurement[name])/1_000_000, "ms");
    }

    static struct Profiler
    {
        private string name;
        this(string name){this.name = name;HipTime.initPerformanceMeasurement(name);}
        ~this(){HipTime.finishPerformanceMeasurement(name);}
    }
    static mixin template Profile(string name){mixin("HipTime.Profiler _profile"~name~" = HipTime.Profiler("~name~");");}
    static mixin template ProfileFunction(){mixin("HipTime.Profiler _profileFunc = HipTime.Profiler(__PRETTY_FUNCTION__);");}

}