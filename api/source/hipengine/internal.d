/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hipengine.internal;


version(Script){__gshared void* _dll;}

void initializeHip()
{
	version(Script)
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
}
version(Script):
version(Windows)
{
	import core.sys.windows.windows:GetProcAddress;
	alias _loadSymbol = GetProcAddress;
}
else
{
	import core.sys.posix.dlfcn:dlsym;
	private alias _loadSymbol = dlsym;
}

private void _loadSymbolEnd(void* targetFunc, const char* name)
{
	*cast(void**)targetFunc = cast(void*)_loadSymbol(_dll, name);
}

///Loads the symbol directly inside 's'
void loadSymbol(alias s, string symName = "")()
{
	static if(symName == "")
		s = cast(typeof(s))_loadSymbol(_dll, (s.stringof~"\0").ptr);
	else
		s = cast(typeof(s))_loadSymbol(_dll, (symName~"\0").ptr);
}
/**
*	Prefer using that function instead of loadSymbol, as compile
*	time sequences reduced the binary size in almost 100kb.
*
*	The problem is not yet solved, but it is a lot better than doing several
*	template instantiations
*/
void loadSymbols(Ts...)()
{
	static foreach(s; Ts)
		s = cast(typeof(s))_loadSymbol(_dll, s.stringof);
}


///Gets the symbol from 's' casted to 's' type ( useful when not loading directly into the function pointers)
typeof(s) getSymbol(alias s)()
{
    return cast(typeof(s))_loadSymbol(_dll, s.stringof);
}


/**
*	This function receives a function alias and the module name to represent.
*
*	Example:
*	```d
*	void function() someFunction;
*	dlangGetFuncName!(someFunction, "hipengine.api.something");
*	```
* 
*	PS: Won't import isFunction for mantaining binary minimal
*/
string dlangGetFuncName(alias func)(string _module)
{
	import core.demangle;
	return mangleFunc!(typeof(func))(_module);
}

string dlangGetStaticClassFuncName(alias func)(string _module)
{
	return dlangGetFuncName!(func)(_module~"."~func.stringof);
}