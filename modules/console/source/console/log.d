/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module console.log;
import console.console;
import util.conv:to;
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

void rawfatal(alias fmt, Args... )(Args a)
{
    string toLog = format!fmt(a);
    Console.DEFAULT.fatal(toLog~"\n");
}

void rawfatal(Args... )(Args a)
{
    string toLog = "";
    foreach(arg; a)
        toLog~= to!string(arg);
    Console.DEFAULT.fatal(toLog~"\n");
}