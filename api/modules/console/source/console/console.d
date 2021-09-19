
module console.console;
import std.string:toStringz;
import util.reflection : isLiteral;
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

interface IConsole
{
	void log(alias fmt, Args...)(Args a);
	void log(Args...)(Args a);
	void warn(alias fmt, Args...)(Args a);
	void warn(Args...)(Args a);
	void error(alias fmt, Args...)(Args a);
	void error(Args...)(Args a);
	void fatal(alias fmt, Args...)(Args a);
	void fatal(Args...)(Args a);
	void indent();
	void unindent();
}

@(InterfaceImplementation(function (ref void* console)
{
	version (CIMGUI)
	{
		AConsole c = cast(AConsole)console;
		igBegin(c.name.toStringz, &c.isShowing, 0);
		foreach_reverse (line; c.lines)
		{
			igText(line.toStringz);
		}
		igEnd();
	}

}
))abstract class AConsole : IConsole
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
	static __gshared AConsole DEFAULT;
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
