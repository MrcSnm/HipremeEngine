module hip.api.console;

version(PSVita) version = ErrorOnLoadSymbol;
version(WebAssembly) version = ErrorOnLoadSymbol;

version(DirectCall)
{
	import hip.console.log;
	///Only the scripting API will need to have this mixed.
	version(Have_hipreme_engine){}else
	{
		mixin mxGenLogDefs!();
	}
    alias log = rawlog;
	alias logg = logln;
}
else version(ScriptAPI)
{
	alias logFn = extern(System) void function(string);
    __gshared logFn log = null;
	void initConsole()
	{
		version(ErrorOnLoadSymbol)
		{
			assert(false, "Cannot load symbols in this version.");
		}
		else
		{
			import hip.api.internal : _loadSymbol, _dll;
			log = cast(typeof(log))_loadSymbol(_dll, "log".ptr);
			log("HipengineAPI: Initialized Console");
		}
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
	else version(ScriptAPI)
		log(toPrint ~ "\n\t at "~file~":"~to!string(line));
}