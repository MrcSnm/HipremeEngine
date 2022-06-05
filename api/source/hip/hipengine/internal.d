/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.hipengine.internal;
import hip.hipengine;

version(Script){__gshared void* _dll;}
version(Windows)
{
	@nogc nothrow extern(Windows)
	{
		void* GetModuleHandleW(const(wchar)* str);
		void* GetProcAddress(void* mod, const(char)* func);
		void* FreeLibrary(void* lib);
		uint GetLastError();
	}
	alias GetModuleHandle = GetModuleHandleW;
}

void initializeHip()
{
	version(Script)
	{
		version(Windows)
		{
			_dll = GetModuleHandle(null);
		}
		else
		{
			import core.sys.posix.dlfcn:dlopen, RTLD_LAZY;
			_dll = dlopen(null, RTLD_LAZY);
		}
		mixin(loadSymbol("hipDestroy"));
	}
}
version(Script):
version(Windows)
{
	alias _loadSymbol = GetProcAddress;
}
else
{
	import core.sys.posix.dlfcn:dlsym;
	alias _loadSymbol = dlsym;
}

///Loads the symbol directly inside 's'
string loadSymbol(string s)
{
	return s ~ " = cast(typeof(" ~ s ~"))_loadSymbol(_dll, (\""~s~"\").ptr);";
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

template loadSymbolsForStaticClass(string staticClassPath, Ts...)
{
	enum names = simpleManglerFuncs!(staticClassPath, Ts);
	enum funcToMix()
	{
		string ret;
		static foreach(i,s; Ts)
			ret~= s.stringof ~"= cast(typeof("~s.stringof~ " ))_loadSymbol(_dll, (\""~names[i]~"\\0\").ptr);";
		return ret;
	}
	enum loadSymbolsForStaticClass = funcToMix;
}

template loadSymbolsFromExportD(string exportedClass, Ts...)
{
	enum impl = ()
	{
		enum e = '"'~exportedClass~"_\"";
		string ret;
		static foreach(i, s; Ts)
			ret~= s.stringof ~"= cast(typeof("~s.stringof~ " ))_loadSymbol(_dll, ("~e~"~\""~s.stringof~"\\0\").ptr);";
		return ret;
	}();

	enum loadSymbolsFromExportD = impl;
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
alias dlangGetFuncName = simpleMangler;


string toString(ulong x){return toString(cast(int)x);}
string toString(int x)
{
    enum numbers = "0123456789";
    int div = 10;
    int length = 1;
    int count = 1;
    while(div < x)
    {
        div*=10;
        length++;
    }
    char[] ret = new char[](length);
    div = 10;
    while(div < x)
    {
        count++;
        ret[length-count]=numbers[(x/div)%10];
        div*=10;
    }
    ret[length-1] = numbers[x%10];
    return cast(string)ret;
}



string simpleManglerModule(string mod)
{
	string ret = "_D";
	string temp;
	int counter = 0;
	for(ulong i = 0; i < mod.length; i++)
	{
		if(mod[i] == '.')
		{
			ret~= toString(counter)~temp;
			counter = 0;
			temp = null;
			continue;
		}
		counter++;
		temp~= mod[i];
	}
	if(counter != 0)
		ret~= toString(counter)~temp;
	return ret;
}

template simpleMangler(alias func, string mod)
{
	import std.traits:moduleName;
	enum modSize = simpleManglerModule(moduleName!func).length;
	enum funcLength = func.stringof.length.stringof[0..$-2];
	enum mangle = func.mangleof[modSize..$];
	enum simpleMangler = simpleManglerModule(mod) ~ funcLength ~ func.stringof ~ mangle;
}

template simpleMangler(alias func, string mod, string funcName)
{
	import std.traits:moduleName;
	enum modSize = simpleManglerModule(moduleName!func).length;
	enum funcLength = func.stringof.length.stringof[0..$-2];
	enum mangle = func.mangleof[modSize..$];
	enum simpleMangler = simpleManglerModule(mod) ~funcLength ~ funcName ~ mangle;
}

template simpleManglerFuncs(string mod, Ts...)
{
	enum modMangle = simpleManglerModule(mod);
	enum helper = ()
	{
		string[Ts.length] ret;
		static foreach(i,t;Ts)
			ret[i]= modMangle~ t.stringof.length.stringof[0..$-2]~t.stringof ~ typeof(t).mangleof;
		return ret;
	}();
	enum simpleManglerFuncs = helper;
}

long indexOf(string content, string what, ulong start = 0)
{
	ulong matchIndex = 0;
	for(ulong i = start; i < content.length; i++)
	{
		while(content[i+matchIndex] == what[matchIndex])
		{
			matchIndex++;
			if(matchIndex == what.length)
				return i;
		}
		matchIndex = 0;
	}
	return -1;
}
string strip(string reference, string what)
{
	long ind = reference.indexOf(what);
	if(ind != -1)
		reference = reference[0..ind]~reference[ind+what.length..$];
	return reference;
}
string join(string[] args, string separator)
{
	if(args.length == 0) return "";
	string ret = args[0];
	for(int i = 1; i < args.length; i++)
		ret~=separator~args[i];
	return ret;
}