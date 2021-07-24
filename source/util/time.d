module util.time;
private import std.datetime.stopwatch;
private import core.time;
private import std.conv : to;



static class Time
{
    static StopWatch stopwatch;
    static this()
    {
        stopwatch = StopWatch(AutoStart.yes);
    }

    static float getCurrentTime()
    {
        return stopwatch.peek.total!"nsecs" / 1_000_000;
    }
    static float getCurrentTimeAsSeconds()
    {
        return stopwatch.peek.total!"nsecs" / 1_000_000_000;
    }
}