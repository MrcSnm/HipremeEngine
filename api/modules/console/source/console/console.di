// D import file generated from 'source\console\console.d'
module console.console;
import config.opts;
import util.reflection : isLiteral;
import std.conv : to;
import std.format : format;
import std.string : toStringz;
import debugging.gui : InterfaceImplementation;
enum Platforms 
{
	DEFAULT,
	DESKTOP,
	ANDROID,
	UWP,
	NULL,
}
static enum androidTag = "HipremeEngine";
enum GUI_CONSOLE = true;
__gshared void function(string toPrint) _log;
__gshared void function(string toPrint) _warn;
__gshared void function(string toPrint) _err;
__gshared void function(string toPrint) _fatal;
static string _format(alias fmt, Args...)(Args a)
{
	return format!fmt(a);
}
static string _format(Args...)(Args args)
{
	import std.traits : isIntegral, isBoolean;
	import std.conv : to;
	string ret = "";
	foreach (i, arg; args)
	{
		alias T = typeof(arg);
		static if (__traits(hasMember, arg, "toString") && is(typeof(arg.toString) == string))
		{
			ret ~= arg.toString;
		}
		else
		{
			static if (is(T == string))
			{
				ret ~= arg;
			}
			else
			{
				ret ~= to!string(arg);
			}
		}
	}
	return ret;
}
@(InterfaceImplementation(function (ref void* console)
{
	version (CIMGUI)
	{
		Console c = cast(Console)console;
		igBegin(c.name.toStringz, &c.isShowing, 0);
		foreach_reverse (line; c.lines)
		{
			igText(line.toStringz);
		}
		igEnd();
	}

}
))class Console
{
	string name;
	string[] lines;
	static ushort idCount = 0;
	ushort id;
	string indentation;
	int indentationCount;
	int maxLines = 255;
	int indentationSize = 4;
	bool useTab = true;
	bool isShowing = true;
	static __gshared Console DEFAULT;
	import core.sync.mutex : Mutex;
	static __gshared Mutex mtx;
	static this();
	static void install(Platforms p = Platforms.DEFAULT, void function(string) printFunc = null);
	private this(string consoleName, ushort id)
	{
		lines.reserve(255);
		name = consoleName;
		this.id = id;
	}
	this(string consoleName)
	{
		lines.reserve(255);
		name = consoleName;
		id = idCount;
		idCount++;
	}
	private void _formatLog(ref string log);
	void log(alias fmt, Args...)(Args a)
	{
		static if (!HE_NO_LOG && !HE_ERR_ONLY)
		{
			string toLog = _format!(fmt, a);
			_log(toLog);
		}

	}
	void log(Args...)(Args a)
	{
		static if (!HE_NO_LOG && !HE_ERR_ONLY)
		{
			string toLog = "";
			foreach (_a; a)
			{
				toLog ~= to!string(_a);
			}
			_formatLog(toLog);
			_log(toLog);
		}

	}
	void warn(alias fmt, Args...)(Args a)
	{
		static if (!HE_NO_LOG && !HE_ERR_ONLY)
		{
			string toLog = _format!(fmt, a);
			_formatLog(toLog);
			_log(toLog);
		}

	}
	void warn(Args...)(Args a)
	{
		static if (!HE_NO_LOG && !HE_ERR_ONLY)
		{
			string toLog = _format!(fmt, a);
			_formatLog(toLog);
			_log(toLog);
		}

	}
	void error(alias fmt, Args...)(Args a)
	{
		static if (!HE_NO_LOG)
		{
			string toLog = _format!(fmt, a);
			_formatLog(toLog);
			_err(toLog);
		}

	}
	void error(Args...)(Args a)
	{
		static if (!HE_NO_LOG)
		{
			string toLog;
			static foreach (arg; a)
			{
				toLog ~= to!string(arg);
			}
			_formatLog(toLog);
			_err(toLog);
		}

	}
	void fatal(alias fmt, Args...)(Args a)
	{
		static if (!HE_NO_LOG)
		{
			string toLog = _format!(fmt, a);
			_formatLog(toLog);
			_fatal(toLog);
		}

	}
	void fatal(Args...)(Args a)
	{
		static if (!HE_NO_LOG)
		{
			string toLog;
			static foreach (arg; a)
			{
				toLog ~= to!string(arg);
			}
			_formatLog(toLog);
			_fatal(toLog);
		}

	}
	void indent();
	void unindent();
}
void varPrint(A...)()
{
	foreach (i, arg; A)
	{
		static if (isLiteral!(A[i]))
		{
			writeln(A[i]);
		}
		else
		{
			static if (is(typeof(A[i]) == string))
			{
				writeln((typeof(A[i])).stringof ~ " ", A[i].stringof, " = ", "\"", A[i], "\"");
			}
			else
			{
				writeln((typeof(A[i])).stringof ~ " ", A[i].stringof, " = ", A[i]);
			}
		}
	}
}
