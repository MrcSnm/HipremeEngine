/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module util.time;
private import std.datetime.stopwatch;
private import core.time;
private import std.conv : to;



class Time
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