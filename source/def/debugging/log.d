/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module def.debugging.log;
import def.debugging.console;
import std.conv:to;
import std.format:format;

private string[] logHistory = [];

private string formatPrettyFunction(string f)
{
    import std.string:lastIndexOf;

    return f[0..f.lastIndexOf("(")];
}



void logln(alias fmt, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__,  Args...)(Args a)
{
    string toLog = format!fmt(a) ~ "\t\t"~file~":"~to!string(line)~" at "~func.formatPrettyFunction;
    logHistory~= toLog;
    Console.DEFAULT.log(toLog~"\n");
}

void logln(string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__, Args...)(Args a)
{
    string toLog = "";
    foreach(arg; a)
        toLog~= to!string(arg);
    toLog~= "\t\t"~file~":"~to!string(line)~" at "~func.formatPrettyFunction;
    logHistory~= toLog;
    Console.DEFAULT.log(toLog~"\n");
}

void rawlog(alias fmt, Args... )(Args a)
{
    string toLog = format!fmt(a);
    Console.DEFAULT.log(toLog~"\n");
}

void rawlog(Args... )(Args a)
{
    string toLog = "";
    foreach(arg; a)
        toLog~= to!string(arg);
    Console.DEFAULT.log(toLog~"\n");
}


void rawerror(alias fmt, Args... )(Args a)
{
    string toLog = format!fmt(a);
    Console.DEFAULT.error(toLog~"\n");
}

void rawerror(Args... )(Args a)
{
    string toLog = "";
    foreach(arg; a)
        toLog~= to!string(arg);
    Console.DEFAULT.error(toLog~"\n");
}