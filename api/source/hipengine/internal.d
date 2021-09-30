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


string dlangGetStaticClassFuncName(alias func)(string _module)
{
	return cast(string)mangleFunc!(typeof(func))(_module~"."~func.stringof);
}

string[] dlangGetStaticClassFuncNames(Ts...)(string _module)
{
	string[] ret;
	static foreach(func; Ts)
		ret~= cast(string)mangleFunc!(typeof(func))(_module~"."~func.stringof);
	return ret;
}

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
	enum simpleMangler = simpleManglerModule(mod) ~ func.stringof.length.stringof[0..$-2] ~ func.stringof ~ typeof(func).mangleof;
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