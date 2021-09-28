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


version(Script){private __gshared void* _dll;}

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
package string dlangGetFuncName(alias func, string _module)()
{
	// import core.demangle;
	return mangleFunc!(typeof(func))(_module);
}