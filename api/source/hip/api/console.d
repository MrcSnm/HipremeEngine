module hip.api.console;

version(Have_hipreme_engine) version = DirectCall;
version(DirectCall)
{
	import hip.console.log:logln, rawlog;
    alias log = rawlog;
	alias logg = logln;
}
else
{
	alias logFn = extern(System) void function(string);
    __gshared logFn log;
	void initConsole()
	{
		import hip.api.internal : _loadSymbol, _dll;
		log = cast(typeof(log))_loadSymbol(_dll, "log".ptr);
		log("HipengineAPI: Initialized Console");
	}
    void logg(Args...)(Args a, string file = __FILE__, size_t line = __LINE__)
	{
		import hip.util.conv;
		string toLog;
		foreach(arg; a)
			toLog~= arg.to!string;
		log(toLog ~ "\n\t at "~file~":"~to!string(line));
	}
}

void logVars(Args...)(string file = __FILE__, size_t line = __LINE__)
{
	import hip.util.conv;
	string toPrint;
	bool isFirst = true;
	static foreach(i; 0..Args.length)
	{
		if(!isFirst)
			toPrint~=", ";
		toPrint~= __traits(identifier, Args[i])~": "~Args[i].to!string;
		isFirst = false;
	}
	version(DirectCall)
	{
		import hip.console.log:rawlog;
		rawlog(toPrint ~ "\n\t at "~file~":"~to!string(line));
	}
	else
		log(toPrint ~ "\n\t at "~file~":"~to!string(line));
}