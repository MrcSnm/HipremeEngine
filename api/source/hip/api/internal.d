/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.internal;
import hip.api;

///Used for creating a function which will generate an overload to call a function pointer
struct Overload
{
	string targetName;
}


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
		hipDestroy = cast(typeof(hipDestroy))_loadSymbol(_dll, "hipDestroy");
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


enum bool isFunctionPointer(alias T) = is(typeof(*T) == function);

/**
*	Prefer using that function instead of loadSymbol, as compile
*	time sequences reduced the binary size in almost 100kb.
*
*	The problem is not yet solved, but it is a lot better than doing several
*	template instantiations
*/
enum loadSymbols(Ts...)()
{
	static foreach(s; Ts)
		s = cast(typeof(s))_loadSymbol(_dll, s.stringof);
}

/**
*	This function will load all function pointers defined in the module passed.
*/
enum loadModuleFunctionPointers(alias targetModule, string exportedClass = "")()
{
	string prefix = "";
	string importedFunctionName;
	static if(exportedClass != "")
		prefix = exportedClass~"_";
	static foreach(member; __traits(allMembers, targetModule))
	{{
		alias f = __traits(getMember, targetModule, member);
		static if(isFunctionPointer!(f))
		{
			importedFunctionName = prefix~member~'\0';
			if(f is null)
			{
				f = cast(typeof(f))_loadSymbol(_dll, importedFunctionName.ptr);
				if(f is null)
				{
					import std.stdio;
					writeln(f.stringof, " wasn't able to load (tried with ", importedFunctionName, ")");
				}
			}
		}
	}}
}


enum generateFunctionDefinitionFromFunctionPointer(alias funcPointerSymbol, string name)()
{
	import std.traits;
	string params;
	string identifiers;

	bool isFirst = true;
	alias storage = ParameterStorageClassTuple!funcPointerSymbol;
	static foreach(i, p; Parameters!funcPointerSymbol)
	{
		if(!isFirst)
		{
			params~= ",";
			identifiers~= ",";
		}
		else
			isFirst = false;
		if(storage[i] != ParameterStorageClass.none)
			params~= storage[i].stringof["ParameterStorageClass.".length..$-1] ~" "; //Remove enum namespace and the "_"
		params~= p.stringof ~ " _"~i.stringof;
		identifiers~= "_"~i.stringof;
	}

	return (ReturnType!funcPointerSymbol).stringof ~ " "~ name ~ "("~params ~"){"~
		(is(ReturnType!funcPointerSymbol == void) ? "" : "return ")~ funcPointerSymbol.stringof ~ "("~identifiers ~ ");}";

}

mixin template OverloadsForFunctionPointers(alias targetModule)
{
	import std.traits;
	static foreach(symbol; getSymbolsByUDA!(targetModule, Overload))
	{
		pragma(msg, generateFunctionDefinitionFromFunctionPointer!(symbol, getUDAs!(symbol, Overload)[0].targetName));
		mixin(generateFunctionDefinitionFromFunctionPointer!(symbol, getUDAs!(symbol, Overload)[0].targetName));
	}
}

enum loadClassFunctionPointers(alias targetClass, string exportedClass = "")()
{
	string prefix = "";
	string importedFunctionName;

	static if(exportedClass == "")
		exportedClass = targetClass.stringof;
	prefix = exportedClass~"_";
	static foreach(member; __traits(allMembers, targetClass))
	{{
		alias f = __traits(getMember, targetClass, member);
		static if(isFunctionPointer!(f))
		{
			importedFunctionName = prefix~member~'\0';
			f = cast(typeof(f))_loadSymbol(_dll, importedFunctionName.ptr);
			if(f is null)
			{
				import std.stdio;
				writeln(f.stringof, " wasn't able to load");
			}
		}
	}}
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
