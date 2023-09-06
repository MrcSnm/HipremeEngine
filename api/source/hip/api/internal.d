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

version(WebAssembly) version = ErrorOnLoadSymbol;
version(PSVita) version = ErrorOnLoadSymbol;

version(Have_hipreme_engine) version = DirectCall;
else version = LoadFunctionPointers;


version(LoadFunctionPointers)
{
	__gshared void* _dll;
	void initializeHip()
	{
		version(ErrorOnLoadSymbol)
		{
			assert(false, "Cannot load symbols in this version.");
		}
		else
		{
			version(Windows){_dll = GetModuleHandle(null);}
			else
			{
				import core.sys.posix.dlfcn:dlopen, RTLD_NOW;
				_dll = dlopen(null, RTLD_NOW);
			}
			import core.stdc.stdio;
			if(_dll == null)
				printf("Could not load GetModuleHandle(null)\n");
			hipDestroy = cast(typeof(hipDestroy))_loadSymbol(_dll, "hipDestroy");
			if(hipDestroy == null)
				printf("Fatal error: could not load hipDestroy\n");
		}
	}
}
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
	alias _loadSymbol = GetProcAddress;
}

version(Posix)
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
					import core.stdc.stdio;
					printf(f.stringof~" wasn't able to load (tried with %s)\n", importedFunctionName.ptr);
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

mixin template ExpandClassFunctionPointers(alias targetClass)
{
	import hip.api.internal: isFunctionPointer;

	static foreach(mem; __traits(allMembers, targetClass))
	{
		static if(isFunctionPointer!(__traits(getMember, targetClass, mem)))
		{
			mixin(__traits(getVisibility, __traits(getMember, targetClass, mem)), " alias ", mem, " = ", __traits(identifier, targetClass), ".", mem,";");
		}
	}
}
template Flag(string f)
{
	enum Flag : bool
	{
		No = false,
		Yes = true
	}
}

alias UseExportedClass = Flag!"UseExportedClass";

enum loadClassFunctionPointers(alias targetClass, 
	UseExportedClass useExported = UseExportedClass.No, 
	string exportedClass = "")
()
{
	string prefix = "";
	string importedFunctionName;

	version(ErrorOnLoadSymbol)
	{
		assert(false, "Cannot load symbols in this version.");
	}
	else
	{
		string nExportedClass = exportedClass;
		static if(useExported)
		{
			static if(exportedClass == "")
				nExportedClass = targetClass.stringof;
			prefix = nExportedClass~"_";
		}
		static foreach(member; __traits(allMembers, targetClass))
		{{
			alias f = __traits(getMember, targetClass, member);
			static if(isFunctionPointer!(f))
			{
				importedFunctionName = prefix~member~'\0';
				f = cast(typeof(f))_loadSymbol(_dll, importedFunctionName.ptr);
				if(f is null)
				{
					import core.stdc.stdio;
					printf(f.stringof ~ " wasn't able to load (tried with %s)\n", importedFunctionName.ptr);
				}
			}
		}}
	}
}

template loadSymbolsFromExportD(string exportedClass, Ts...)
{
	version(ErrorOnLoadSymbol)
	{
		enum impl = "";
	}
	else
	{
		enum impl = ()
		{
			enum e = '"'~exportedClass~"_\"";
			string ret;
			static foreach(i, s; Ts)
			{
				ret~= s.stringof ~"= cast(typeof("~s.stringof~ " ))_loadSymbol(_dll, ("~e~"~\""~s.stringof~"\\0\").ptr);";
				if(s.stringof is null)
				{
					import core.stdc.stdio;
					printf("Could not load "~s.stringof~" (tried with %s"~ e~s.stringof~")\n");
				}
			}
			return ret;
		}();
	}

	enum loadSymbolsFromExportD = impl;
}
