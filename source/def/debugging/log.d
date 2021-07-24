module def.debugging.log;
import std.conv:to;
import std.stdio:write;
import std.format:format;

private string[] logHistory = [];

void logln(alias fmt, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__,  Args...)(Args a)
{
    string toLog = format!fmt(a) ~ "\t\t"~file~":"~to!string(line)~" at "~func;
    logHistory~= toLog;
    write(toLog, "\n");
}

void logln(string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__, Args...)(Args a)
{
    string toLog = "";
    foreach(arg; a)
        toLog~= to!string(arg);
    toLog~= "\t\t"~file~":"~to!string(line)~" at "~func;
    logHistory~= toLog;
    write(toLog, "\n");
}