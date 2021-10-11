/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module util.time;
public import std.datetime:Duration, dur;
private import std.datetime.stopwatch;
private import core.time;
private import std.conv : to;



class HipTime
{
    protected static StopWatch stopwatch;
    protected static long[string] performanceMeasurement;
    static this()
    {
        stopwatch = StopWatch(AutoStart.yes);
    }

    static long getCurrentTime() nothrow
    {
        return stopwatch.peek.total!"nsecs";
    }

    static float getCurrentTimeAsMilliseconds() nothrow
    {
        return stopwatch.peek.total!"nsecs" / 1_000_000;
    }
    static float getCurrentTimeAsSeconds() nothrow
    {
        return stopwatch.peek.total!"nsecs" / 1_000_000_000;
    }

    static void initPerformanceMeasurement(string name)
    {
        performanceMeasurement[name] = getCurrentTime();
    }
    static void finishPerformanceMeasurement(string name)
    {
        import std.stdio:writeln;
        writeln(name, " took ", (getCurrentTime() - performanceMeasurement[name])/1_000_000, "ms");
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