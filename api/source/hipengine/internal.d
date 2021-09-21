module hipengine.internal;
private __gshared void* _dll;

void initializeHip()
{
	version(Windows)
	{
		import core.sys.windows.windows;
		_dll = GetModuleHandle(null);
	}
	else
	{
		import core.sys.posix.dlfcn:dlopen, RTLD_LAZY;
		_dll = dlopen(null, RTLD_LAZY);
	}
}
version(Windows)
{
	import core.sys.windows.windows:GetProcAddress;
	private alias _loadSymbol = GetProcAddress;
}
else
{
	import core.sys.posix.dlfcn:dlsym;
	private alias _loadSymbol = dlsym;
}

///Loads the symbol directly inside 's'
void loadSymbol(alias s)()
{
	s = cast(typeof(s))_loadSymbol(_dll, (s.stringof~"\0").ptr);
}

///Gets the symbol from 's' casted to 's' type ( useful when not loading directly into the function pointers)
typeof(s) getSymbol(alias s)()
{
    return cast(typeof(s))_loadSymbol(_dll, (s.stringof~"\0").ptr);
}