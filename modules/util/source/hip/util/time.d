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
    import hip.util.windows;
    extern(Windows) BOOL QueryPerformanceFrequency(LARGE_INTEGER* lpPerformanceCount) nothrow;
    extern(Windows) BOOL QueryPerformanceCounter(LARGE_INTEGER* lpPerformanceCount) nothrow;
}
else version(PSVita)
{
    extern(C) ulong get_psv_time() @nogc nothrow;
}
else version(WebAssembly)
{
    extern(C) float monotimeNow() @nogc nothrow;
}
else
{
    import core.stdc.config:c_long;
    version(PSVita)
    {
        enum CLOCK_MONOTONIC = 4;
    }
    else
    {
        enum CLOCK_MONOTONIC = 1;
    }
    struct timespec
    {
        int tv_sec; //Seconds
        c_long tv_nsec; //Nanoseconds
    }
    extern(C) int clock_gettime(int clock_id, timespec* tm) nothrow;
}

ulong getSystemTime() nothrow
{
    version(Windows)
    {
        LARGE_INTEGER counter = void;
        QueryPerformanceCounter(&counter);
        return counter.QuadPart * 1_000_000_000; //Convert to nanos
    }
    else version(WebAssembly)
    {
        return cast(ulong)(monotimeNow() * 1_000_000); //ms to nano
    }
    else version(PSVita)
    {
        return get_psv_time();
    }
    else
    {
        timespec tm = void;
        if(clock_gettime(CLOCK_MONOTONIC, &tm) != 0)
            return 0;
        return cast(size_t)(tm.tv_nsec + tm.tv_sec * 1e9);
    }
}
private ulong getSystemTicksPerSecond() nothrow
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

    private __gshared ulong startTime;
    private __gshared ulong ticksPerSecond;
    protected __gshared long[string] performanceMeasurement;

    static void initialize()
    {
        ticksPerSecond = getSystemTicksPerSecond();
        startTime =  getSystemTime();
    }

    static long getCurrentTime() nothrow
    {
        ulong time = 0;
        version(Windows)
        {
            time = (getSystemTime() - startTime) / ticksPerSecond;
        }
        else
            time = getSystemTime() - startTime;
        return time;
    }
    static double getCurrentTimeDouble() nothrow
    {
        version(PSVita)
            return Double(getCurrentTime());
        else
            return cast(double)getCurrentTime();
    }

    ///For some reason, float arithmetic is wrong on PSVita, so, use long instead...
    static long getCurrentTimeAsMsLong() nothrow
    {
        return getCurrentTime() / 1_000_000;
    }

    static double getCurrentTimeAsMs() nothrow
    {
        return getCurrentTimeDouble() / 1_000_000.0f;
    }
    static double getCurrentTimeAsSeconds() nothrow
    {
        return getCurrentTimeDouble() / 1_000_000_000;
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

float seconds(float v){return v;}
float msecs(float v){return v*1_000;}
float usecs(float v){return v*1_000_000;}
float nsecs(float v){return v*1_000_000_000;}