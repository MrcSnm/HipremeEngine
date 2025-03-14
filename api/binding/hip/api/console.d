module hip.api.console;

version(PSVita) version = ErrorOnLoadSymbol;
version(WebAssembly) version = ErrorOnLoadSymbol;

version(DirectCall)
{
	import hip.console.log;
    alias log = rawlog;
	alias logg = logln;
}
else version(ScriptAPI)
{
	alias logFn = extern(System) void function(string);
    extern(D) __gshared logFn log = null;
	void initConsole()
	{
		version(ErrorOnLoadSymbol)
		{
			assert(false, "Cannot load symbols in this version.");
		}
		else
		{
			import hip.api.internal : _loadSymbol, _dll;
			log = cast(typeof(log))_loadSymbol(_dll, "logMessage".ptr);
			log("HipengineAPI: Initialized Console");
		}
	}
    void logg(Args...)(Args a, string file = __FILE__, size_t line = __LINE__)
	{
		import hip.util.string;
		log(BigString(a, "\n\t at ", file, ":", line).toString);
	}
}
