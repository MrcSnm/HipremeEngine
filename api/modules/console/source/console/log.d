
module console.log;
import console.console;
import std.conv : to;
import std.format : format;
private string[] logHistory = [];
private string formatPrettyFunction(string f);
void logln(alias fmt, string file = __FILE__, string func = __PRETTY_FUNCTION__, ulong line = __LINE__, Args...)(Args a)
{
	string toLog = format!fmt(a) ~ "\x09\x09" ~ file ~ ":" ~ to!string(line) ~ " at " ~ func.formatPrettyFunction;
	logHistory ~= toLog;
	Console.DEFAULT.log(toLog ~ "\x0a");
}
void logln(string file = __FILE__, string func = __PRETTY_FUNCTION__, ulong line = __LINE__, Args...)(Args a)
{
	string toLog = "";
	foreach (arg; a)
	{
		toLog ~= to!string(arg);
	}
	toLog ~= "\x09\x09" ~ file ~ ":" ~ to!string(line) ~ " at " ~ func.formatPrettyFunction;
	logHistory ~= toLog;
	Console.DEFAULT.log(toLog ~ "\x0a");
}
void rawlog(alias fmt, Args...)(Args a)
{
	string toLog = format!fmt(a);
	Console.DEFAULT.log(toLog ~ "\x0a");
}
void rawlog(Args...)(Args a)
{
	string toLog = "";
	foreach (arg; a)
	{
		toLog ~= to!string(arg);
	}
	Console.DEFAULT.log(toLog ~ "\x0a");
}
void rawerror(alias fmt, Args...)(Args a)
{
	string toLog = format!fmt(a);
	Console.DEFAULT.error(toLog ~ "\x0a");
}
void rawerror(Args...)(Args a)
{
	string toLog = "";
	foreach (arg; a)
	{
		toLog ~= to!string(arg);
	}
	Console.DEFAULT.error(toLog ~ "\x0a");
}
void rawfatal(alias fmt, Args...)(Args a)
{
	string toLog = format!fmt(a);
	Console.DEFAULT.fatal(toLog ~ "\x0a");
}
void rawfatal(Args...)(Args a)
{
	string toLog = "";
	foreach (arg; a)
	{
		toLog ~= to!string(arg);
	}
	Console.DEFAULT.fatal(toLog ~ "\x0a");
}
